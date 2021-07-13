//xlang Source, Name:XVersionEditor.x 
//Date: Mon Oct 23:43:51 2020 

class XVersionEditor : DocumentView{
    QTableWidget _container;
    XWorkspace _workspace;
    JsonObject versionObj = nilptr;
    bool updating = false;
    static String [] HVComulns = {" 公司名称   ", " 版权描述   ", " 产品版本   "," 产品名称   ", " 文件名称   ", " 文件版本   ",  " 文件描述   "};
    static String [] HHComulns = {"值"};
    
    //QTableWidget versionTable;
    
    public XVersionEditor(XWorkspace _w){
        _workspace = _w;
    }
    
    public bool create(@NotNilptr QWidget parent) {
        if (super.create(parent)) {
            _container = new QTableWidget();
            _container.create();
            setWidget(_container);
            /*versionTable = new QTableWidget();
            versionTable.create(_container);
            
            _container.setOnLayoutEventListener(new onLayoutEventListener(){
                void onResize(QObject obj,int w,int h,int oldw,int oldh)override{
                    versionTable.resize(w,h);
                }
            });*/
            
            _container.setColumnCount(1);
            _container.setRowCount(7);
            
            _container.setVHColumns(HVComulns);
            _container.setHHColumns(HHComulns);
            
            _container.setOnTableWidgetEventListener(new TableWidgetEventListener(){
                public void onCellChange(QTableWidget object, int row,int column) {
                    if (updating){
                        return;
                    }
                    String [] keys = {"CompanyName", "LegalCopyright", "ProductVersion", "ProductName", "InternalName", "FileVersion", "FileDescription" };
                    if (versionObj != nilptr && row >= 0 && row < keys.length){
                        while (versionObj.has(keys[row])){
                            versionObj.remove(keys[row]);
                        }
                        String text = object.getText(row,column);
                        versionObj.put(keys[row],text);
                        setModified(true);
                    }
                }
            });
            
            _container.show();
            return true;
        }
        return false;
    }
    
    public bool loadFile(@NotNilptr String file, String asCharset){
    
        String content = XFinder.readFileContent(file);
        try{
            versionObj = new JsonObject(content);
            loadVersion();
            setFilePath(file);
        }catch(Exception e){
            QMessageBox.Critical("注意","无效的版本文件",QMessageBox.Ok,QMessageBox.Ok);
        }
        
        return true;
    }
    
    void setToTable(String key, int row){
        String val = nilptr;
        if (versionObj != nilptr){
            val = versionObj.getString(key);
            if (val == nilptr){
                val = "";
            }
        }
        _container.setItem(row,0, nilptr, val);
    }
    
    void loadVersion(){
        updating = true;
        String [] keys = {"CompanyName", "LegalCopyright", "ProductVersion", "ProductName", "InternalName", "FileVersion", "FileDescription" };
        for (int i =0; i < keys.length; i++){
            setToTable(keys[i], i);
        }
        updating = false;
    }
    

    
    public void saveFileAs() {
        String file = QFileDialog.getSaveFileName("保存文件", getFilePath(),  getDocumentExtension(), this);
        if (file != nilptr && file.length() > 0) {
            saveAs(file);
        }
    }
    
    public bool saveAs(@NotNilptr String path) {
        pauseWatch();
        try {
            FileOutputStream fis = new FileOutputStream(path);
            try {
                String content = "";
                if (versionObj != nilptr){
                    content = versionObj.toString(false);
                }
                byte [] data = content.getBytes();
                fis.write(data);
                fis.close();//必须close 不然GC 关闭文件的时候在watch之后 , watch 会报告被更改
                setFilePath(String.formatPath(path,false).replace("\\","/"));
                setModified(false);
                continueWatch();
                return true;
            } catch(Exception e) {
            }
        } catch(Exception e) {
            Critical("注意", "文件无法在此位置保存,或者此文件正被其他程序使用,请重新选择路径", QMessageBox.Ok, QMessageBox.Ok);
        }
        continueWatch();
        return false;
    }
    
    public bool saveFile() {
        String savepath = getFilePath();
        bool saved = false;
        while (saved == false) {
            if (savepath != nilptr && savepath.startsWith("#")) {
                while (saved == false) {
                    String file = QFileDialog.getSaveFileName("保存文件", savepath,  "Version Files(*.version)", this);
                    if (file != nilptr && file.length() > 0) {
                        saved = saveAs(file);
                    } else {
                        return false;
                    }
                }
            } else 
            if (savepath != nilptr){
                pauseWatch();
                try {
                    String content = "";
                    if (versionObj != nilptr){
                        content = versionObj.toString(false);
                    }
                    byte [] data = content.getBytes();
                    FileOutputStream fis = new FileOutputStream(savepath);
                    fis.write(data);
                    fis.close();//必须close 不然GC 关闭文件的时候在watch之后 , watch 会报告被更改
                    setModified(false);
                    saved = true;
                } catch(Exception e) {
                    Critical("注意", "文件无法在此位置保存,或者此文件正被其他程序使用,请重新选择路径", QMessageBox.Ok, QMessageBox.Ok);
                }
                continueWatch();
            }
        }
        return saved;
    }
};