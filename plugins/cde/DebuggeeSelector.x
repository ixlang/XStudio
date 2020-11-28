//xlang Source, Name:DebuggeeSelector.x 
//Date: Wed Apr 18:13:12 2020 

class DebuggeeSelector : QDialog{
    QCheckBox chkRemote, chkLocal;
    QTreeWidget treeWidget;
    QLineEdit edtfilter, edtHost, edtport, edtProg;
    QPushButton btnBrowser, btnOk, btnCancel, btnRefresh;
    QWidget grplocal, grpremote;
    QComboBox cmbKit;
    
    static class ProcessItem{
        public long item;
        String name;
        String path;
        
        public ProcessItem(long h, String _name, String _path){
            item = h;
            name = _name;
            path = _path;
        }
        
        public bool test(String key){
            try{
                if (Pattern.test("" + item, key, 0, false)){
                    return true;
                }
                if (name != nilptr && Pattern.test(name.upper(), key, 0, false)){
                    return true;
                }
                if (path != nilptr && Pattern.test(path.upper(), key, 0, false)){
                    return true;
                }
                return false;
            }catch(Exception e){
                
            }
            return true;
        }
    };
    
    ProcessItem [] _processesItems = nilptr;
    
	void onAttach() override {
		//TODO:	
        chkRemote =  (QCheckBox)attachByName(new QCheckBox(), "chkRemote");
        chkLocal =  (QCheckBox)attachByName(new QCheckBox(), "chkLocal");
        treeWidget = (QTreeWidget)attachByName(new QTreeWidget(), "treeWidget");
        edtfilter = (QLineEdit)attachByName(new QLineEdit(), "edtfilter");
        edtHost = (QLineEdit)attachByName(new QLineEdit(), "edtHost");
        edtport = (QLineEdit)attachByName(new QLineEdit(), "edtport");
        edtProg = (QLineEdit)attachByName(new QLineEdit(), "edtProg");
        btnBrowser = (QPushButton)attachByName(new QPushButton(), "btnBrowser");
        btnOk = (QPushButton)attachByName(new QPushButton(), "btnOk");
        btnCancel = (QPushButton)attachByName(new QPushButton(), "btnCancel");
        btnRefresh = (QPushButton)attachByName(new QPushButton(), "btnRefresh");
        cmbKit = (QComboBox)attachByName(new QComboBox(), "cmbKit");
        
        grplocal = (QWidget)attachByName(new QWidget(), "grplocal");
        grpremote = (QWidget)attachByName(new QWidget(), "grpremote");
        
        setWindowIcon("./res/toolbar/dbg.png");
        
        btnCancel.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				close();
            }
        });
        
        btnRefresh.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				refreshProcess();
                
                filterProcess(edtfilter.getText());
            }
        });
        
        chkRemote.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				grpremote.setEnabled(checked);
                grplocal.setEnabled(!checked);
                chkLocal.setCheck(false);
            }
        });
        
        chkLocal.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				grplocal.setEnabled(checked);
                grpremote.setEnabled(!checked);
                chkRemote.setCheck(false);
            }
        });
        
        chkLocal.setCheck(true);
        grplocal.setEnabled(true);
        grpremote.setEnabled(false);
        chkRemote.setCheck(false);
        
        btnBrowser.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				String progpath = QFileDialog.getOpenFileName("选择被调试程序文件",edtProg.getText(),"*.* *",DebuggeeSelector.this);
                if (progpath != nilptr){
                    edtProg.setText(progpath);
                }
            }
        });
        
        btnOk.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
				onStartDebug();
            }
        });
        
        edtfilter.setOnEditEventListener(new onEditEventListener() {
            void onTextChanged(QObject,@NotNilptr String text)override {
                filterProcess(text);
            }
        });
        
        String [] columns = {"名称", "PID", "文件"};
        
        treeWidget.setColumns(columns);
        
        treeWidget.setColumnWidth(0, 200);
        treeWidget.setColumnWidth(1, 50);
        treeWidget.setColumnWidth(2, 400);
        
        refreshProcess();
        loadKits();
        setModal(true);
        show();
	}
    
    void filterProcess(@NotNilptr String text){
        if (text.length() == 0){
            return;
        }
        String key = text.upper();
        if (_processesItems != nilptr){
            for (int i = 0; i < _processesItems.length; i++){
                if (_processesItems[i].test(key)){
                    treeWidget.setItemVisible(_processesItems[i].item, true);
                } else {
                    treeWidget.setItemVisible(_processesItems[i].item, false);
                }
            }
        }
    }
    void loadKits(){
        JsonArray ccc = CDEProjectPropInterface.loadConfigures();
        if (ccc != nilptr){
            String [] kitlist = new String[ccc.length()];
            for (int i = 0; i < ccc.length(); i++){
                JsonObject cconf = (JsonObject)ccc.get(i);
                if (cconf != nilptr){
                    kitlist[i] = cconf.getString("name");
                }
            }
            cmbKit.addItems(kitlist);
        }
        
    }
    
    void onStartDebug(){
        bool bSuccess = false;
        String kitstr = cmbKit.getCurrentText();
        if (kitstr.length() == 0){
            QMessageBox.Critical("注意","没有选择用于调试的C/C++套件",QMessageBox.Ok,QMessageBox.Ok);
            return ;
        }
        if (chkLocal.getCheck()){
            long item = treeWidget.getSelItem();
            
            if (item != 0){
                String szid = treeWidget.getItemText(item, 1);
                int pid = szid.parseInt();
                if (pid > 0){
                    new Thread(){
                        void run()override{
                            CDEProjectPropInterface.getInstance().attachDebug(kitstr, pid);
                        }
                    }.start();
                    bSuccess = true;
                }
            }
            
            if (bSuccess == false){
                QMessageBox.Critical("注意","没有选择一个有效的进程",QMessageBox.Ok,QMessageBox.Ok);
            }
            
        }else
        if (chkRemote.getCheck()){
            String host = edtHost.getText();
            int port = edtport.getText().parseInt();
            String prog = edtProg.getText();
            
            if (host.trim(true).length() == 0){
                QMessageBox.Critical("注意","远程地址填写不正确",QMessageBox.Ok,QMessageBox.Ok);
                return ;
            }
            if (port <= 0 || port >= 65535){
                QMessageBox.Critical("注意","远程端口填写不正确",QMessageBox.Ok,QMessageBox.Ok);
                return ;
            }
            if (prog.trim(true).length() == 0 || (XPlatform.existsSystemFile(prog) == false)){
                QMessageBox.Critical("注意","程序文件填写不正确或者文件不存在",QMessageBox.Ok,QMessageBox.Ok);
                return ;
            }
            
            new Thread(){
                void run()override{
                    CDEProjectPropInterface.getInstance().remoteDebug(kitstr, host, port, prog);
                }
            }.start();
            bSuccess = true;
        }
        
        if (bSuccess){
            close();
        }
    }
    
    void refreshProcess(){
        treeWidget.clear();
        
        List<Runtime.OSProcess> processes = Runtime.OSProcess.listProcesses();
        if (processes != nilptr){
            _processesItems = new ProcessItem [processes.size()];
            int idx = 0;
            List.Iterator<Runtime.OSProcess> iter = processes.iterator();
            while (iter.hasNext()){
                Runtime.OSProcess process = iter.next();
                if (process != nilptr){
                    String name = process.getName();
                    String path = process.getPath();
                    int id = process.getId();
                    
                    long item = treeWidget.addItem(nilptr, name);
                    _processesItems[idx++] = new ProcessItem(item, name, path);
                    treeWidget.setItemText(item, 1, "" + id);
                    treeWidget.setItemText(item, 2, path);
                }
            }
        }
    }
    public static void showDebuggeeSelector(){
        QDialog newDlg = new QDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("dbg.ui");
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        if (newDlg.load(qb)){
            DebuggeeSelector dbgvier = new DebuggeeSelector();
            dbgvier.attach(newDlg);
        }
    }
};