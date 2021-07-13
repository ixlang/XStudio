//xlang Source, Name:DocumentView.x 
//Date: Sat Oct 13:32:50 2020 

class DocumentView : QMdiSubWindow{
    private String szTitle = "未标题";
    private String filePath = "#" + Math.random() + "" + _system_.currentTimeMillis();
    public static Map<String, DocumentView> editorMgr = new Map<String, DocumentView>();
    static Map<String, String> charsetCache = new Map<String, String>();
    
    bool bModified = false;
    XWorkspace __mdiarea = nilptr;
    
    private void setMdiArea(XWorkspace qm){
        __mdiarea = qm;
    }
    public static DocumentView findFileWindow(@NotNilptr String file) {

        try {
            file = String.formatPath(file, _system_.getPlatformId() == _system_.PLATFORM_WINDOWS);
            return editorMgr.get(file);
        } catch(Exception e) {

        }
        return nilptr;
    }
    
    public static String getDocumentExtension(){
        String filter = nilptr;
        ProjectPropInterface prop = XWorkspace.workspace.getCurrentProjectProp();
        if (prop != nilptr){
            filter = prop.getFileExtensionFilter();
        }
        if (filter != nilptr){
            filter = filter.trim(true);
        }
        
        if (filter == nilptr){
            filter = "";
        }else
        if (filter.length() > 0){
            if (filter.endsWith(";;") == false){
                filter = filter + ";;";
            }
        }
        return filter + "All Files(*.* *)";
    }
      
    public static void addToCharset(String file, String asCharset){
        if (file != nilptr){
            charsetCache.put(String.formatPath(file,false),asCharset);
        }
    }
    
    public static DocumentView findDocumentWindow(XWorkspace parent,@NotNilptr String source, bool open) {
        DocumentView wnd =  nilptr;
        source = source.replace("\\", "/");
        Project project = XWorkspace.workspace.getCurrentProject();
        if (XPlatform.existsSystemFile(source) == false){
            if (project != nilptr){
                source = String.formatPath(project.getProjectDir().appendPath(source), false);
                if (XPlatform.existsSystemFile(source) == false){
                    return nilptr;
                }
            }else{
                return nilptr;
            }
        }
        
        wnd = findFileWindow(source);
        
        if (wnd == nilptr){
            if (open && parent != nilptr) {
                if (XPlatform.existsSystemFile(source)){
                    wnd = DocumentView.createView(parent, source);
                    if (wnd.create(parent)) {
                        if (wnd.loadFile(source, nilptr)) {
                            wnd.show();
                        } else {
                            wnd.close();
                            wnd = nilptr;
                        }
                    }
                }else{
                    wnd = nilptr;
                }
            }
        }

        return wnd;
    }
    
    public static bool closeForFile(@NotNilptr String source) {
        DocumentView wnd =  findDocumentWindow(nilptr, source, false);

        if (wnd != nilptr) {
            wnd.close();
            return true;
        }
        return false;
    }
    
    public static void toggleBreakPointOnFile(XWorkspace parent,@NotNilptr String source,int line, bool set) {
        DocumentView wnd =  findDocumentWindow(parent, source, true);
        if (wnd != nilptr) {
            wnd.toggleBreakPoint(line, set);
        }
    }
    public void insertNewLine(){}
    public void appendNewLine(){}
    public void convertCharset() {}   
    public void UpdateCodepage(){}
    public void Copy(){}
    public void Paste(){}
    public void Cut(){}
    public void Delete(){}
    public void DeleteCurLine(){}
    public void UnDo() {}
    public void ReDo() {}
    public void toggleBreakpoint() {}
    public void gotoCursordef() {}
    public void findAgain() {}
    public void saveFileAs(){}
    public String getSelectedText(){return "";}
    public String getText(int ,int ){return "";}
    public int getSelectStart(){return -1;}
    public int getSelectEnd(){return -1;}
    public void matchBrace(){}
    public void overrideObject() {}
    public void setUpper(){}
    public void setLower(){}
    public void setIntellisense(XIntelliSense.XIntelliResult [] names) {}
    public void showHoverInformation(String texts, int pos) {}
    public void setFileSymbols(XIntelliSense.XIntelliResult [] names) {}
        
    public void CursorUp() {}
    public void CursorLeft() {}
    public void CursorRight() {}
    public void CursorDown() {}
    public void CursorLineBegin() {}
    public void CursorLineEnd() {}
    public void CursorPrevPage() {}
    public void CursorNextPage() {}
    public int getContentLength (){return 0;}
    public void CursortoTop() {}
    public void CursortoBottom() {}
    public void clearFoundMark(){}
    public void markFound(int pos, int length){}
    public void clearSelectedMark(){}
    public void markSelected(int pos, int length){}
    public QPoint getSelectMarkRange(){return nilptr;}
    public void doPrint(){}
    public static String getCharsetCache(String file){
        if (file != nilptr){
            try{
                return charsetCache.get(String.formatPath(file,false));
            }catch(Exception e){
                
            }
        }
        return nilptr;
    }
    
    public static bool findSaveFile(@NotNilptr String file) {
        DocumentView wnd =  findDocumentWindow(nilptr, file, false);
        if (wnd != nilptr) {
        
            wnd.resetInformationPoint();
            
            if (wnd.isModified()) {
                return wnd.saveFile();
            }
            return false;
        }
        return false;
    }
    
    public void resetInformationPoint(){
        
    }
    
    public String getFilePath(){
        return filePath;
    }
    
    public String getTitle() {
        return szTitle;
    }
    
    public void setModified(bool bM){
        if (bModified != bM){
            bModified = bM;
            updateTitle();
        }
    }
    
    public bool isModified(){
        return bModified;
    }
    
    public void setModified(){
        if (bModified == false){
            bModified = true;
            updateTitle();
        }
    }
    public void updateTitle() {
        if (filePath.startsWith("#") == false) {
            szTitle = filePath.findFilenameAndExtension();
        }
        if (bModified) {
            setWindowTitle(szTitle + " *");
        } else {
            setWindowTitle(szTitle);
        }
    }
    
    public void setFilePath(@NotNilptr String file) {
        
        if (filePath != nilptr){
            removeFromMap(getFilePath());
        }
        
        filePath = String.formatPath(file,false).replace("\\","/");
        szTitle = filePath.findFilenameAndExtension();
        addToMap(filePath);
        updateTitle();
    }
    
    public void removeFromMap(@NotNilptr String file) {
        file = String.formatPath(file, _system_.getPlatformId() == _system_.PLATFORM_WINDOWS);
        if (file.startsWith("#") == false) {
            __mdiarea.qfsw.removePath(file);
        }
        editorMgr.remove(file);
    }

    public void addToMap(@NotNilptr String file) {
        file = String.formatPath(file, _system_.getPlatformId() == _system_.PLATFORM_WINDOWS);
        if (file.startsWith("#") == false) {
            __mdiarea.qfsw.addPath(file);
        }
        editorMgr.put(filePath, this);
    }

    public void pauseWatch() {
        __mdiarea.qfsw.removePath(filePath);
    }

    public void continueWatch() {
        __mdiarea.qfsw.addPath(filePath);
    }
    
    public static void notifyFileChange(XWorkspace workspace, @NotNilptr String path, bool autoLoad) {
        DocumentView editor = findDocumentWindow(nilptr, path, false);
        if (editor != nilptr) {
            workspace.setActiveSubWindow(editor);
            editor.notifyFileChange(autoLoad);
        }
    }
    
    public static bool notifyDiagnosis(String file){
        DocumentView wnd =  findDocumentWindow(nilptr, file, true);
        if (wnd != nilptr) {
            wnd.updateInformationPoint();
            return true;
        }
        return false;
    }
    
    public static bool locateForPosition(@NotNilptr XWorkspace parent,@NotNilptr String source,int position, int len) {
        DocumentView wnd =  findDocumentWindow(parent, source, true);

        if (wnd != nilptr) {
            parent.setActiveSubWindow(wnd);
            wnd.setSelection(position, len);
            return true;
        }
        return false;
    }

    public static bool locateForLineRow(@NotNilptr XWorkspace parent,@NotNilptr String source,int line, int column, int len) {
        DocumentView wnd =  findDocumentWindow(parent, source, true);

        if (wnd != nilptr) {
            parent.setActiveSubWindow(wnd);
            wnd.gotoAndSelect(line,column);
            return true;
        }
        return false;
    }
    
    public void notifyFileChange(bool autoLoad) {
        if (Setting.getBoolean("changeautoload")){
            reload();
        }else
        if (autoLoad == true || QMessageBox.Yes == QMessageBox.Question("注意", "检测到文件:" + getFilePath() + "已被外部程序改变,是否重新加载?", QMessageBox.Yes, QMessageBox.No)) {
            reload();
        }
    }
    
    public bool create(@NotNilptr QWidget parent) {
        if (super.create(parent)) {
            addToMap(getFilePath());
            return true;
        }
        return false;
    }
    
    public void onDestroy()override {
        __mdiarea.updateDocumentStatus();
    }
    
    public void reload(){}
            
    public bool requestClose(){
        return true;
    }
    
    public static void updateDocumentTo(@NotNilptr String path,String newname) {
        DocumentView wnd = findDocumentWindow(nilptr, path, false);
        if (wnd != nilptr) {
            wnd.removeFromMap(path);
            wnd.setFilePath(newname);
            wnd.addToMap(newname);
        }
    }

    private bool onClose()override {
        if (onCloseDocument()){
            removeFromMap(getFilePath());
            __mdiarea.updateDocumentStatus();
            return true;
        }
        return false;
    }
    
    public bool onCloseDocument(){
        return true;
    }
    
    public String contentToString(){return nilptr;}
    public @NotNilptr static DocumentView createView(XWorkspace parent, @NotNilptr String file){
        String ext = "";
        if (file != nilptr ){
            ext = file.findExtension();
        }
        DocumentView dv = nilptr;
        if (ext.equalsIgnoreCase(".version")){
            try{
                dv = new XVersionEditor(parent);
            }catch(Exception e){
                
            }
        }
        if (ext.equalsIgnoreCase(".xts")){
            try{
                dv = new XStringMapView(parent);
            }catch(Exception e){
                
            }
        }
        if (dv == nilptr){
            dv = new XSourceEditor(parent);
        }
        dv.setMdiArea(parent);
        return dv;
    }
    
    public bool loadFile(@NotNilptr String file, String asCharset){
        return false;
    }
    
    public void goto(int pos) {
    }
    
    public void goto(int line, int column) {
    }
    
    public void showTips(int line, int column, String title, String content) {
    }
    
    public void showTips(int position, String title, String content){
        
    }
    public void setSelection(int pos, int len) {
    
    }
    public void updateInformationPoint(){
        
    }
    public void gotoAndSelect(int line, int column) {
    }
    
    public bool saveFile() {
        return false;
    }
    
    public void toggleBreakPoint(int line, bool set) {
    }
    
    public void updateConfig() {
    }
    
    public void clearBreakOn() {}
        
    public void breakOn(int line, int column, bool set, bool active, bool onlyActive) {}
        
    public void replaceText(int start, int len,@NotNilptr  String text) {}
};