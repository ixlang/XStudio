//xlang Source, Name:XStringMapView.x 
//Date: Tue Nov 00:23:03 2020 

class XStringMapView : DocumentView{
    
    QWidget view;
    QTreeWidget  _langlist;
    QTableWidget _container;
    
    XWorkspace _workspace;
    
    int currentPage, curlang = 0;

    QPushButton btnfirst, btnlast, btnprev, btnnext, btndel, btnimport;
    QComboBox pagecmb;
    
    bool bloaded = false, bUpdating = false;
    
    static String unescape(String text){
        return text.replace("\t", "\\t").replace("\b", "\\b").replace("\r", "\\r").replace("\n", "\\n");
    }
    static String escape(String text){
        return text.replace("\\t", "\t").replace("\\b", "\b").replace("\\r", "\r").replace("\\n", "\n");
    }
    
    static class LanguageItem{
        String label ;
        Map<int, String> langlist = new Map<int, String>();
        
        public LanguageItem(String lab, JsonObject node){
            label = lab;
            JsonObject cld = (JsonObject)node.child();
            while (cld != nilptr){
                langlist.put(cld.getName().parseInt(),
                    cld.getString());
                cld = (JsonObject)cld.next();
            }
        }
        
        public String getLabel(){
            return unescape(label);
        }
        
        public String getText(int langid){
            try{
                return unescape(langlist.get(langid));
            }catch(Exception e){
                
            }
            return nilptr;
        }
        
        public bool setLangText(int id, String text){
            if (text.equals("")){
                if (id != 0 && langlist.containsKey(id)){
                    langlist.remove(id);
                    return true;
                }
                return false;
            }
            String src = getText(id);
            if ((src == nilptr) || (src.equals(text) == false)){
                langlist.put(id, escape(text));
                return true;
            }
            
            return false;
        }
        
        public String genLabel(){
            return label;
        }
        
        public JsonObject genObject(){
            JsonObject obj = new JsonObject();
            Map.Iterator<int, String> iter = langlist.iterator();
            while (iter .hasNext()){
                obj.put("" + iter.getKey(), iter.getValue());
                iter.next();
            }
            return obj;
        }
    };
    
    Map<String, LanguageItem> stringlist = new Map<String, LanguageItem>();
    Vector<LanguageItem> langvect = new Vector<LanguageItem>();
    

    
    static class LanguageObject{
    
        public LanguageObject(int id, String lc, String lan, String co){
            lcid = id;
            Locale = lc;
            Language = lan;
            code = co;
        }
        
        public int lcid;
        public String Locale;
        public String Language;
        public String code;
    };
    
    static LanguageObject [] langs = {
        new LanguageObject(0,"Default","Default","DEFAULT"),
        new LanguageObject(0x0436,"Afrikaans","South Africa","AFK"),
        new LanguageObject(0x041c,"Albanian","Albania","SQI"),
        new LanguageObject(0x1401,"Arabic","Algeria","ARG"),
        new LanguageObject(0x3c01,"Arabic","Bahrain","ARH"),
        new LanguageObject(0x0c01,"Arabic","Egypt","ARE"),
        new LanguageObject(0x0801,"Arabic","Iraq","ARI"),
        new LanguageObject(0x2c01,"Arabic","Jordan","ARJ"),
        new LanguageObject(0x3401,"Arabic","Kuwait","ARK"),
        new LanguageObject(0x3001,"Arabic","Lebanon","ARB"),
        new LanguageObject(0x1001,"Arabic","Libya","ARL"),
        new LanguageObject(0x1801,"Arabic","Morocco","ARM"),
        new LanguageObject(0x2001,"Arabic","Oman","ARO"),
        new LanguageObject(0x4001,"Arabic","Qatar","ARQ"),
        new LanguageObject(0x0401,"Arabic","Saudi Arabia","ARA"),
        new LanguageObject(0x2801,"Arabic","Syria","ARS"),
        new LanguageObject(0x1c01,"Arabic","Tunisia","ART"),
        new LanguageObject(0x3801,"Arabic","U.A.E.","ARU"),
        new LanguageObject(0x2401,"Arabic","Yemen","ARY"),
        new LanguageObject(0x042b,"Armenian","Armenia","HYE"),
        new LanguageObject(0x044d,"Assamese","India","ASM"),
        new LanguageObject(0x082c,"Azeri","Azerbaijan (Cyrillic)","AZE"),
        new LanguageObject(0x042c,"Azeri","Azerbaijan (Latin)","AZE1"),
        new LanguageObject(0x042d,"Basque","Spain","EUQ"),
        new LanguageObject(0x0423,"Belarusian","Belarus","BEL"),
        new LanguageObject(0x0445,"Bengali","India","BEN"),
        new LanguageObject(0x0402,"Bulgarian","Bulgaria","BGR"),
        new LanguageObject(0x0403,"Catalan","Spain","CAT"),
        new LanguageObject(0x0c04,"Chinese","Hong Kong SAR","ZHH"),
        new LanguageObject(0x1404,"Chinese","Macao SAR","ZHM"),
        new LanguageObject(0x0804,"Chinese","PRC","CHS"),
        new LanguageObject(0x1004,"Chinese","Singapore","ZHI"),
        new LanguageObject(0x0404,"Chinese","Taiwan","CHT"),
        new LanguageObject(0x0827,"Classic Lithuanian","Lithuania","LTC"),
        new LanguageObject(0x041a,"Croatian","Croatia","HRV"),
        new LanguageObject(0x0405,"Czech","Czech Republic","CSY"),
        new LanguageObject(0x0406,"Danish","Denmark","DAN"),
        new LanguageObject(0x0465,"Divehi","Maldives","DIV"),
        new LanguageObject(0x0813,"Dutch","Belgium","NLB"),
        new LanguageObject(0x0413,"Dutch","Netherlands","NLD"),
        new LanguageObject(0x0c09,"English","Australia","ENA"),
        new LanguageObject(0x2809,"English","Belize","ENL"),
        new LanguageObject(0x1009,"English","Canada","ENC"),
        new LanguageObject(0x2409,"English","Caribbean","ENB"),
        new LanguageObject(0x1809,"English","Ireland","ENI"),
        new LanguageObject(0x2009,"English","Jamaica","ENJ"),
        new LanguageObject(0x1409,"English","New Zealand","ENZ"),
        new LanguageObject(0x3409,"English","Philippines","ENP"),
        new LanguageObject(0x1c09,"English","South Africa","ENS"),
        new LanguageObject(0x2c09,"English","Trinidad","ENT"),
        new LanguageObject(0x0809,"English","United Kingdom","ENG"),
        new LanguageObject(0x0409,"English","United States","USA"),
        new LanguageObject(0x3009,"English","Zimbabwe","ENW"),
        new LanguageObject(0x0425,"Estonian","Estonia","ETI"),
        new LanguageObject(0x0438,"Faeroese","Faeroe Islands","FOS"),
        new LanguageObject(0x0429,"Farsi","Iran","FAR"),
        new LanguageObject(0x040b,"Finnish","Finland","FIN"),
        new LanguageObject(0x080c,"French","Belgium","FRB"),
        new LanguageObject(0x0c0c,"French","Canada","FRC"),
        new LanguageObject(0x040c,"French","France","FRA"),
        new LanguageObject(0x140c,"French","Luxembourg","FRL"),
        new LanguageObject(0x180c,"French","Monaco","FRM"),
        new LanguageObject(0x100c,"French","Switzerland","FRS"),
        new LanguageObject(0x042f,"Macedonian (FYROM)","Macedonian (FYROM)","MKI"),
        new LanguageObject(0x0456,"Galician","Spain","GLC"),
        new LanguageObject(0x0437,"Georgian","Georgia","KAT"),
        new LanguageObject(0x0c07,"German","Austria","DEA"),
        new LanguageObject(0x0407,"German","Germany","DEU"),
        new LanguageObject(0x1407,"German","Liechtenstein","DEC"),
        new LanguageObject(0x1007,"German","Luxembourg","DEL"),
        new LanguageObject(0x0807,"German","Switzerland","DES"),
        new LanguageObject(0x0408,"Greek","Greece","ELL"),
        new LanguageObject(0x0447,"Gujarati","India","GUJ"),
        new LanguageObject(0x040d,"Hebrew","Israel","HEB"),
        new LanguageObject(0x0439,"Hindi","India","HIN"),
        new LanguageObject(0x040e,"Hungarian","Hungary","HUN"),
        new LanguageObject(0x040f,"Icelandic","Iceland","ISL"),
        new LanguageObject(0x0421,"Indonesian","Indonesia (Bahasa)","IND"),
        new LanguageObject(0x0410,"Italian","Italy","ITA"),
        new LanguageObject(0x0810,"Italian","Switzerland","ITS"),
        new LanguageObject(0x0411,"Japanese","Japan","JPN"),
        new LanguageObject(0x044b,"Kannada","India (Kannada script)","KAN"),
        new LanguageObject(0x043f,"Kazakh","Kazakstan","KKZ"),
        new LanguageObject(0x0457,"Konkani","India","KNK"),
        new LanguageObject(0x0412,"Korean","Korea","KOR"),
        new LanguageObject(0x0440,"Kyrgyz","Kyrgyzstan","KYR"),
        new LanguageObject(0x0426,"Latvian","Latvia","LVI"),
        new LanguageObject(0x0427,"Lithuanian","Lithuania","LTH"),
        new LanguageObject(0x083e,"Malay","Brunei Darussalam","MSB"),
        new LanguageObject(0x043e,"Malay","Malaysia","MSL"),
        new LanguageObject(0x044c,"Malayalam","India","MAL"),
        new LanguageObject(0x044e,"Marathi","India","MAR"),
        new LanguageObject(0x0450,"Mongolian (Cyrillic)","Mongolia","MON"),
        new LanguageObject(0x0414,"Norwegian","Norway (Bokm氓l)","NOR"),
        new LanguageObject(0x0814,"Norwegian","Norway (Nynorsk)","NON"),
        new LanguageObject(0x0448,"Oriya","India","ORI"),
        new LanguageObject(0x0415,"Polish","Poland","PLK"),
        new LanguageObject(0x0416,"Portuguese","Brazil","PTB"),
        new LanguageObject(0x0816,"Portuguese","Portugal","PTG"),
        new LanguageObject(0x0446,"Punjabi","India (Gurmukhi script)","PAN"),
        new LanguageObject(0x0418,"Romanian","Romania","ROM"),
        new LanguageObject(0x0419,"Russian","Russia","RUS"),
        new LanguageObject(0x044f,"Sanskrit","India","SAN"),
        new LanguageObject(0x0c1a,"Serbian","Serbia (Cyrillic)","SRB"),
        new LanguageObject(0x081a,"Serbian","Serbia (Latin)","SRL"),
        new LanguageObject(0x041b,"Slovak","Slovakia","SKY"),
        new LanguageObject(0x0424,"Slovenian","Slovenia","SLV"),
        new LanguageObject(0x2c0a,"Spanish","Argentina","ESS"),
        new LanguageObject(0x400a,"Spanish","Bolivia","ESB"),
        new LanguageObject(0x340a,"Spanish","Chile","ESL"),
        new LanguageObject(0x240a,"Spanish","Colombia","ESO"),
        new LanguageObject(0x140a,"Spanish","Costa Rica","ESC"),
        new LanguageObject(0x1c0a,"Spanish","Dominican Republic","ESD"),
        new LanguageObject(0x300a,"Spanish","Ecuador","ESF"),
        new LanguageObject(0x440a,"Spanish","El Salvador","ESE"),
        new LanguageObject(0x100a,"Spanish","Guatemala","ESG"),
        new LanguageObject(0x480a,"Spanish","Honduras","ESH"),
        new LanguageObject(0x080a,"Spanish","Mexico","ESM"),
        new LanguageObject(0x4c0a,"Spanish","Nicaragua","ESI"),
        new LanguageObject(0x180a,"Spanish","Panama","ESA"),
        new LanguageObject(0x3c0a,"Spanish","Paraguay","ESZ"),
        new LanguageObject(0x280a,"Spanish","Peru","ESR"),
        new LanguageObject(0x500a,"Spanish","Puerto Rico","ESU"),
        new LanguageObject(0x040a,"Spanish","Spain (Traditional sort)","ESP"),
        new LanguageObject(0x0c0a,"Spanish","Spain (International sort)","ESN"),
        new LanguageObject(0x380a,"Spanish","Uruguay","ESY"),
        new LanguageObject(0x200a,"Spanish","Venezuela","ESV"),
        new LanguageObject(0x0441,"Swahili","Kenya","SWK"),
        new LanguageObject(0x081d,"Swedish","Finland","SVF"),
        new LanguageObject(0x041d,"Swedish","Sweden","SVE"),
        new LanguageObject(0x045a,"Syriac","Syria","SYR"),
        new LanguageObject(0x0449,"Tamil","India","TAM"),
        new LanguageObject(0x0444,"Tatar","Tatarstan","TTT"),
        new LanguageObject(0x044a,"Telugu","India (Telugu script)","TEL"),
        new LanguageObject(0x041e,"Thai","Thailand","THA"),
        new LanguageObject(0x041f,"Turkish","Turkey","TRK"),
        new LanguageObject(0x0422,"Ukrainian","Ukraine","UKR"),
        new LanguageObject(0x0420,"Urdu","Pakistan","URP"),
        new LanguageObject(0x0820,"Urdu","India","URI"),
        new LanguageObject(0x0843,"Uzbek","Uzbekistan (Cyrillic)","UZB"),
        new LanguageObject(0x0443,"Uzbek","Uzbekistan (Latin)","UZB1"),
        new LanguageObject(0x042a,"Vietnamese","Viet Nam","VIT")
    };
    

    static String [] HHComulns = {"Text", "Default"};
    int langpagecount = 0;
    //QTableWidget versionTable;
    
    public XStringMapView(XWorkspace _w){
        _workspace = _w;
    }
    
    
    void updatepage(){
        langpagecount = langvect.size() / 1024;
        if ((langvect.size() % 1024) > 0){
            langpagecount++;
        }
        
        Vector<String> pages = new Vector<String>();
        for (int i =0; i < langpagecount; i++){
            pages.add("" + (i+1));
        }
        String text = pagecmb.getCurrentText();
        pagecmb.clear();
        pagecmb.addItems(pages.toArray(new String[0]));
        pagecmb.setText(text);
    }
    
    void parseLoad(JsonObject root){
        JsonObject cld = (JsonObject)root.child();
        while (cld != nilptr){
            String lab = cld.getName();
            LanguageItem li = new LanguageItem(lab, cld);
            if (stringlist.containsKey(lab) == false){
                langvect.add(li);
                stringlist.put(lab,li);
            }
            cld = (JsonObject)cld.next();
        }
        updatepage();
    }
    
    public bool create(@NotNilptr QWidget parent) {
        if (super.create(parent)) {
            view = new QWidget();
            if (view.load(UIManager.getUIData(__xPackageResource("ui/stringmap.ui"))) == false) {
                return false;
            }
            _langlist = (QTreeWidget)view.findByName("langlist");
            _container = (QTableWidget)view.findByName("langmap");
            setWidget(view);
            
            _container.setColumnCount(2);
            _container.setRowCount(1024);
            
            _container.setHHColumns(HHComulns);
            /*_container.setVHColumns(HVComulns);
            _container.setHHColumns(HHComulns);*/
            btnimport = (QPushButton)view.findByName("btnimport");
            btnfirst = (QPushButton)view.findByName("btnfirst");
            btnlast = (QPushButton)view.findByName("btnlast"); 
            btnprev = (QPushButton)view.findByName("btnprev"); 
            btnnext = (QPushButton)view.findByName("btnnext");
            pagecmb = (QComboBox)view.findByName("pagecmb");
            btndel = (QPushButton)view.findByName("btndel");
            
            btndel.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    QRect [] rc = _container.getSelectedRanges();
                    if (rc != nilptr){
                        updatecontent();
                        for (int n =0; n < rc.length; n++){
                            int t = rc[n].top;
                            int c = rc[n].bottom - t + 1;
                            for (int i = 0; i < c && t < langvect.size(); i++){
                                langvect.remove(t);
                            }
                        }
                        updatepage();
                        updateDisplay();
                        setModified(true);
                    }
                }
            });
            
            btnfirst.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    updatecontent();
                    currentPage = 0;
                    updateDisplay();
                }
            });
            
            btnprev.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    if (currentPage > 0){
                        updatecontent();
                        currentPage--;
                        updateDisplay();
                    }
                }
            });
            
            btnnext.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    if ((currentPage + 1) < langpagecount){
                        updatecontent();
                        currentPage++;
                        updateDisplay();
                    }
                    
                }
            });
            
            btnlast.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    if (langpagecount > 0){
                        updatecontent();
                        currentPage = langpagecount - 1;
                        updateDisplay();
                    }
                }
            });
            
            btnimport.setOnClickListener(new onClickListener(){
                void onClick(QObject obj,bool checked)override{
                    //TODO 
                    String newfile = QFileDialog.getOpenFileName("导入字符串表",getFilePath(),"*.xts;;",XStringMapView.this);
                    if (newfile.length() > 0){
                        loadFile(newfile, nilptr);
                    }
                }
            });
            
            pagecmb.setOnComboBoxEventListener(
            new onComboBoxEventListener() {
                void onItemSelected(QObject obj, int id) {
                    if (bloaded){
                        updatecontent();
                        String selcfgname = pagecmb.getCurrentText();
                        currentPage = selcfgname.parseInt() - 1;
                        if (currentPage < 0 ){
                            currentPage = 0;
                        }
                        if (currentPage >= langpagecount){
                            currentPage = langpagecount - 1;
                        }
                        updateDisplay();
                    }
                }
            });
            
            for (int i =0; i < langs.length; i++){
                long item = _langlist.addItem(nilptr,langs[i].Locale + " - " + langs[i].Language + String.format("(%d)",langs[i].lcid));
                _langlist.setItemTag(item,0,langs[i].lcid);
            }
            
            _langlist.setOnTreeViewItemEvent(new onTreeViewItemEvent()
                {
                    void onItemClicked(QTreeWidget tree,long item, int column)override {
                        updatecontent();
                        curlang = (int)_langlist.getItemTag(item,0);
                        String [] sHHComulns = {"Text", _langlist.getItemText(item,0)};
                        _container.setHHColumns(sHHComulns);
                        updateDisplay();
                    }
                    void onItemPressed(QTreeWidget, long item, int column)override {
                    
                    }
                });
                
            _container.setOnTableWidgetEventListener(new TableWidgetEventListener(){
                public void onCellChange(QTableWidget object, int row,int column) {
                    if (bUpdating){
                        return ;
                    }
                    int n = currentPage * 1024 + row;
                    if (n >= 0 && n < langvect.size()){
                        if (langvect[n].setLangText(curlang, _container.getText(row, 1))){
                            setModified(true);
                        }
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
            JsonObject langjo = new JsonObject(content);
            parseLoad(langjo);
            setFilePath(file);
            updateDisplay();
            bloaded = true;
        }catch(Exception e){
            QMessageBox.Critical("注意","无效的翻译文件",QMessageBox.Ok,QMessageBox.Ok);
        }
        
        return true;
    }
        
    void updatecontent(){

    }
    
    void updateDisplay(){
        bUpdating = true;
        int begin = currentPage * 1024;
        if (begin < langvect.size()){
 
            int row = 0;
            for (;begin < langvect.size() && row < 1024; begin++){

                String val = langvect[begin].getText(curlang);
                if (val == nilptr){
                    val = "";
                }
                _container.setItem(row,0, nilptr, langvect[begin].getLabel());
                _container.modifyItemFlags(_container.getItem(row, 0),0, QTreeWidget.ItemIsEditable);
                
                
                _container.setItem(row,1, nilptr, val);
                _container.modifyItemFlags(_container.getItem(row, 1),QTreeWidget.ItemIsEditable,0);
                row++;
            }
            
            for (;row < 1024; row++){
                _container.setItem(row,0, nilptr, "");
                _container.modifyItemFlags(_container.getItem(row, 0),0, QTreeWidget.ItemIsEditable);
                
                _container.setItem(row,1, nilptr, "");
                _container.modifyItemFlags(_container.getItem(row, 1),0, QTreeWidget.ItemIsEditable);
            }
        }
        pagecmb.setText("" + (currentPage + 1));
        bUpdating = false;
    }
    

    
    public void saveFileAs() {
        String file = QFileDialog.getSaveFileName("保存文件", getFilePath(),  getDocumentExtension(), this);
        if (file != nilptr && file.length() > 0) {
            saveAs(file);
        }
    }
    
    String generatmap(){
        JsonObject jo = new JsonObject();
        for (int i =0; i < langvect.size(); i++){
            jo.put(langvect[i].genLabel(), langvect[i].genObject());
        }
        return jo.toString(false);
    }
    
    public bool saveAs(@NotNilptr String path) {
        pauseWatch();
        try {
            FileOutputStream fis = new FileOutputStream(path);
            try {
                String content = generatmap();
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
                    String content = generatmap();
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