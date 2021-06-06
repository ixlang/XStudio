//xlang Source, Name:AddObjectProject.x 
//Date: Sat Apr 20:43:26 2021 

class AddObjectProject : QDialog{
    QLineEdit edtpath, edtext;
    QPushButton btnselpath, btnscan, btnremove, btnadd, btnok, btncancel;
    QCheckBox chkrec;
    QTreeWidget listfile;
    QLabel lblcnt;
    String projectdir;
    bool scanInWorking = false;
    bool bStopScan = false;
    static JsonArray results = new JsonArray();
    
    void onAttach()override{
        setWindowIcon("res/toolbar/slnstr.png");
        results = new JsonArray();
        lblcnt = (QLabel)attachByName(new QLabel(), "lblcnt");
        edtpath = (QLineEdit)attachByName(new QLineEdit(), "edtpath");
        edtext = (QLineEdit)attachByName(new QLineEdit(), "edtext");
        edtext.setText(".c;.cpp;.cxx;.m;.mm;.cc;.c++;.cp;.txx;.tpp;.tpl");
        btnselpath = (QPushButton)attachByName(new QPushButton(), "btnselpath");
        btnscan = (QPushButton)attachByName(new QPushButton(), "btnscan");
        btnremove = (QPushButton)attachByName(new QPushButton(), "btnremove");
        btnadd = (QPushButton)attachByName(new QPushButton(), "btnadd");
        btnok = (QPushButton)attachByName(new QPushButton(), "btnok");
        btncancel = (QPushButton)attachByName(new QPushButton(), "btncancel");
        
        chkrec = (QCheckBox)attachByName(new QCheckBox(), "chkrec");
        listfile = (QTreeWidget)attachByName(new QTreeWidget(), "listfile");
        
        listfile.setColumns(new String[]{"文件名", "扩展名", "路径"});
        listfile.setColumnWidth(0,200);
        listfile.setColumnWidth(1,100);
        
        btnselpath.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                String path = QFileDialog.getFolderPath("选择路径", edtpath.getText(), "", AddObjectProject.this);
                if (path != nilptr && path.length() > 0){
                    edtpath.setText(path);
                }
            }
        });
        
        btnremove.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                long [] items = listfile.getSelectedItems();
                for (int i =0; i < items.length; i++){
                    listfile.removeItem(items[i]);
                }
            }
        });
        
        btnadd.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                static String lastPath = "";
                String [] paths = QFileDialog.getOpenFileNames("选择文件",lastPath,"*.*",AddObjectProject.this);
                if (paths != nilptr && paths.length > 0){
                    for (int i = 0; i < paths.length; i++){
                        addFile(paths[i]);
                    }
                }
            }
        });
        
        
        btnscan.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                onscan();
            }
        });
        
        btnok.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                genresult();
                close();
            }
        });
        
        btncancel.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                results = new JsonArray();
                close();
            }
        });
        
        setModal(true);
        exec();
    }
    
    void genresult(){
        results = new JsonArray();
        long [] items = listfile.getTopItems();
        for (int i = 0; i < items.length; i++){
            String rfp = listfile.getItemText(items[i],2);
            rfp = rfp.toRelativePath(projectdir, false, false);
            results.put(rfp);
        }
    }
    
    void onscan(){
        if (scanInWorking){
            bStopScan = true;
            btnscan.setText("正在停止...");
            return ;
        }
        String exts = edtext.getText();
        exts = exts.replace(" ", ";").replace(",", ";").replace("|", ";");
        String [] extlist = exts.split(";");
        Map<String, int> extmap = new Map<String, int>();
        
        for (int i = 0; i < extlist.length; i++){
            if (extlist[i].startWith(".") == false){
                QMessageBox.Information("注意","扩展名填写错误:" + extlist[i],QMessageBox.Ok,QMessageBox.Ok);
                return;
            }
            extmap.put(extlist[i].upper(), 0);
        }
        
        String spath = edtpath.getText();
        if (spath.length() == 0){
            QMessageBox.Information("注意","不正确的扫描路径",QMessageBox.Ok,QMessageBox.Ok);
            return;
        }
        if (extmap.containsKey(".*")){
            extmap = nilptr;
        }
        setScanInWorking(true);
        new Thread(){
            bool brc = chkrec.getCheck();
            void run(){
                scanFolder(spath, extmap, brc);
                
                runOnUi(new Runnable(){
                    void run(){
                        setScanInWorking(false);
                    }
                });
            }
        }.start();
    }
    
    void setScanInWorking(bool b){
        scanInWorking = b;
        bStopScan = !b;
        btnscan.setText(b ? "停止" : "扫描");
        btnok.setEnabled(!b);
        btncancel.setEnabled(!b);
    }
    
    void scanFolder(String path, Map<String, int> extmap, bool rec){
        FSObject fso = new FSObject(path);
        FSObject finded = new FSObject();
        long hf = fso.openDir();
        while (bStopScan == false && fso.findObject(hf,finded)){
            if (finded.isDir()){
                if (rec){
                    scanFolder(finded.getPath(), extmap, rec);
                }
            }else{
             	String ext = finded.getExtension();
                if (extmap == nilptr || extmap.containsKey(ext.upper())){
                    runOnUi(new Runnable(){
                        String fullpath = XPlatform.converPlatformCharSetTo(finded.getPath());
                        void run(){
                            addFile(fullpath);
                        }
                    });
                }
            }
        }
    }
    
    void addFile(String file){
        String name = file.findFilenameAndExtension();
        String extension = file.findExtension();
        if (extension == nilptr){
            extension = "";
        }
        long item = listfile.addItem(nilptr, name);
        listfile.setItemText(item , 1, extension);
        listfile.setItemText(item , 2, file);
        lblcnt.setText("" + listfile.getTopLevelCount() + " 个文件");
    }
    
    bool onClose(){
        if (scanInWorking){
            QMessageBox.Information("注意","请先停止扫描",QMessageBox.Ok,QMessageBox.Ok);
            return false;
        }
        return !scanInWorking;
    }
    
    
    public static JsonArray showAddFiles(String _projectdir){
        QDialog newDlg = new QDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("addfile.ui");
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        if (newDlg.load(qb)){
            AddObjectProject cppsetting = new AddObjectProject();
            cppsetting.projectdir = _projectdir;
            cppsetting.attach(newDlg);
            return results;
        }
        return nilptr;
    }
};