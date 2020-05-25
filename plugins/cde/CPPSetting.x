//xlang Source, Name:CPPSetting.x 
//Date: Thu Feb 17:40:17 2020 

class CPPSetting : QXDialog{

    QXPushButton btnnew,  btndel, btncc, btnld, btndbg, btnclose, btnar, btnmake;
    QXLineEdit edtcc, edtld, edtdbg, edtar, edtmake;
    QXComboBox cmbcfg;
    
    QXSci _ccargs, _ldargs, _dbgargs, _arargs;
    QXWidget ccarg, ldarg, dbgarg, ararg;
    JsonArray cpp_configures;
    JsonObject current_config;
    
    bool bClear = false;
    
    void onAttach()override{
        btnnew = (QXPushButton)attachByName(new QXPushButton(), "btnnew");
        btndel = (QXPushButton)attachByName(new QXPushButton(), "btndel");
        btncc = (QXPushButton)attachByName(new QXPushButton(), "btncc");
        btnld = (QXPushButton)attachByName(new QXPushButton(), "btnld");
        btndbg = (QXPushButton)attachByName(new QXPushButton(), "btndbg");
        btnar = (QXPushButton)attachByName(new QXPushButton(), "btnar");
        btnmake = (QXPushButton)attachByName(new QXPushButton(), "btnmake");
        
        
        btnclose = (QXPushButton)attachByName(new QXPushButton(), "btnclose");
        
        edtcc = (QXLineEdit)attachByName(new QXLineEdit(), "edtcc");
        edtld = (QXLineEdit)attachByName(new QXLineEdit(), "edtld");
        edtdbg = (QXLineEdit)attachByName(new QXLineEdit(), "edtdbg");
        edtar = (QXLineEdit)attachByName(new QXLineEdit(), "edtar");
        edtmake = (QXLineEdit)attachByName(new QXLineEdit(), "edtmake");
        
        cmbcfg = (QXComboBox)attachByName(new QXComboBox(), "cmbcfg");
        
        ccarg = (QXWidget)attachByName(new QXWidget(), "ccarg");
        ldarg = (QXWidget)attachByName(new QXWidget(), "ldarg");
        dbgarg = (QXWidget)attachByName(new QXWidget(), "dbgarg");
        ararg = (QXWidget)attachByName(new QXWidget(), "ararg");
        
        _ccargs = new QXSci();
        if (_ccargs.create(ccarg) == false){
            return;
        }
        
        _ldargs = new QXSci();
        if (_ldargs.create(ldarg) == false){
            return;
        }
        
        _dbgargs = new QXSci();
        if (_dbgargs.create(dbgarg) == false){
            return;
        }
        
        _arargs = new QXSci();
        if (_arargs.create(ararg) == false){
            return;
        }
        
        dbgarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QXObject obj, int w, int h, int oldw, int oldh)override {
                if (_dbgargs != nilptr){
                    _dbgargs.resize(w, h);
                }
            }
        });
        
        ccarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QXObject obj, int w, int h, int oldw, int oldh)override {
                if (_ccargs != nilptr){
                    _ccargs.resize(w, h);
                }
            }
        });
        
        ldarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QXObject obj, int w, int h, int oldw, int oldh)override {
                if (_ldargs != nilptr){
                    _ldargs.resize(w, h);
                }
            }
        });
        
        ararg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QXObject obj, int w, int h, int oldw, int oldh)override {
                if (_ldargs != nilptr){
                    _arargs.resize(w, h);
                }
            }
        });
        
        syntaxForOutput(_ccargs);
        syntaxForOutput(_ldargs);
        syntaxForOutput(_dbgargs);
        syntaxForOutput(_arargs);
        
        cmbcfg.setOnComboBoxEventListener(
            new onComboBoxEventListener() {
                void onItemSelected(QXObject obj, int id) {
                    saveconfig();
                    String name = cmbcfg.getCurrentText();
                    for (int i = 0; i < cpp_configures.length(); i++){
                        JsonObject jconf = (JsonObject)cpp_configures.get(i);
                        if (name.equals(jconf.getString("name"))){
                           current_config = jconf;
                           showConfig();
                           return; 
                        }
                     }
                }
            }
        );
        
        btnnew.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                 
                 InputDialog.requestInput(new InputDialog.onInputListener() {
                    bool onInputOk(String text)override {
                        return createConfigure(text);
                    }
                    bool onInputCancel()override {
                        return true;
                    }
                    String getTitle()override {
                        return "输入";
                    }
                    String getTips()override {
                        return "输入配置名称:";
                    }
                    String getDefault()override {
                        return "";
                    }
                });
            
            }
        });
        
        btncc.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                 if (current_config == nilptr){
                     QXMessageBox.Critical("注意","请先选择或者新建一个配置",QXMessageBox.Ok,QXMessageBox.Ok);
                     return;
                 }
                 String filepath = QXFileDialog.getOpenFileName("选择编译器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 setCurrent("cc", filepath);
                 if (filepath.length() > 0){
                    detectIncludeSearchDir(filepath);
                 }
                 
                 autoDetect(filepath);
                 showConfig();
            }
        });
        
        btnld.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                if (current_config == nilptr){
                     QXMessageBox.Critical("注意","请先选择或者新建一个配置",QXMessageBox.Ok,QXMessageBox.Ok);
                     return;
                 }
                 String filepath = QXFileDialog.getOpenFileName("选择链接器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 setCurrent("ld", filepath);
                 showConfig();
            }
        });
        
        btndbg.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                if (current_config == nilptr){
                     QXMessageBox.Critical("注意","请先选择或者新建一个配置",QXMessageBox.Ok,QXMessageBox.Ok);
                     return;
                 }
                 String filepath = QXFileDialog.getOpenFileName("选择调试器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 setCurrent("dbg", filepath);
                 showConfig();
            }
        });
        
        
        btnar.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                if (current_config == nilptr){
                     QXMessageBox.Critical("注意","请先选择或者新建一个配置",QXMessageBox.Ok,QXMessageBox.Ok);
                     return;
                 }
                 String filepath = QXFileDialog.getOpenFileName("选择归档器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 setCurrent("ar", filepath);
                 showConfig();
            }
        });
        
        btnmake.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                if (current_config == nilptr){
                     QXMessageBox.Critical("注意","请先选择或者新建一个配置",QXMessageBox.Ok,QXMessageBox.Ok);
                     return;
                 }
                 String filepath = QXFileDialog.getOpenFileName("选择Make程序","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 setCurrent("make", filepath);
                 showConfig();
            }
        });
        
        btnclose.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                if (cpp_configures != nilptr){
                    saveconfig();
                    FileOutputStream fos = nilptr;
                    try{
                        fos = new FileOutputStream(CDEProjectPropInterface.appendPath(XPlatform.getAppDirectory(), "plugins/cde/configures.cfg"));
                        JsonObject jroot = new JsonObject();
                        jroot.put("configures", cpp_configures);
                        String content = jroot.toString(true);
                        fos.write(content.getBytes());
                    }catch(Exception e){
                        
                    }finally{
                        if (fos != nilptr){
                            fos.close();
                        }
                    }
                }
                close();
            }
        });
        
        btndel.setOnClickListener(new onClickListener(){
            void onClick(QXObject obj, bool checked) {
                String name = cmbcfg.getCurrentText();
                if (removeConfig(name)){
                    loadConfigures();
                }
            }
        });
        
        setModal(true);
        show();
        loadConfigures();
    }
    
    bool removeConfig(String name){
        for (int i = 0; i < cpp_configures.length(); i++){
            if (name.equals(  ( (JsonObject)cpp_configures.get(i)).getString("name"))){
                cpp_configures.remove(i);
                return true; 
            }
         }
         return false;
    }
    
    bool createConfigure(String name){
         if (name == nilptr || name.length() == 0){
             QXMessageBox.Critical("注意","名称无效",QXMessageBox.Ok,QXMessageBox.Ok);
             return false;
         }
         
         for (int i = 0; i < cpp_configures.length(); i++){
            if (name.equals(  ( (JsonObject)cpp_configures.get(i)).getString("name"))){
               QXMessageBox.Critical("注意","名称已存在",QXMessageBox.Ok,QXMessageBox.Ok);
                return false; 
            }
         }
         
         saveconfig();
         
         current_config = new JsonObject();
         current_config.put("name", name);
         cpp_configures.put(current_config);
         
         showConfig();
             
         reloadList(name);
         return true;
    }
    
    void autoDetect(String filepath){
        String ext = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            ext = ".exe";
        }
        
        String dir = filepath.findVolumePath();
        
        String ld = CDEProjectPropInterface.appendPath(dir, "g++" + ext);
        if (XPlatform.existsSystemFile(ld)){
            if (QXMessageBox.Question("注意","已检测到链接器位于 " + ld + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                setCurrent("ld" , ld);
            }
        }
        
        String ar = CDEProjectPropInterface.appendPath(dir, "ar" + ext);
        if (XPlatform.existsSystemFile(ar)){
            if (QXMessageBox.Question("注意","已检测到归档器位于 " + ar + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                setCurrent("ar" , ar);
            }
        }
        
        String gdb = CDEProjectPropInterface.appendPath(dir, "gdb" + ext);
        if (XPlatform.existsSystemFile(gdb)){
            if (QXMessageBox.Question("注意","已检测到调试器位于 " + gdb + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                setCurrent("dbg" , gdb);
            }
        }
        
        String make = CDEProjectPropInterface.appendPath(dir, "make" + ext);
        if (XPlatform.existsSystemFile(make)){
            if (QXMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                setCurrent("make" , make);
            }
        }else{
            make = CDEProjectPropInterface.appendPath(dir, "mingw32-make" + ext); 
            if (XPlatform.existsSystemFile(make)){
                if (QXMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                    setCurrent("make" , make);
                }
            }else{
                make = CDEProjectPropInterface.appendPath(dir, "mingw-w64-make" + ext); 
                if (XPlatform.existsSystemFile(make)){
                    if (QXMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QXMessageBox.Yes | QXMessageBox.No,QXMessageBox.Yes) == QXMessageBox.Yes){
                        setCurrent("make" , make);
                    }
                }
            }
        }
    }
    
    void syntaxForOutput(QXSci _sci){
		if (Setting.isDarkStyle()){
			syntaxForOutputDark(_sci);
            return ;
		}
        _sci.sendEditor(QXSci.SCI_SETCODEPAGE, QXSci.SC_CP_UTF8);
        _sci.setWrap(true);
        _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_DEFAULT, 0xffffffff);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_DEFAULT, 0xff222827);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, 75, 0xff222827);
        _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
        //_sci.sendEditor(QXSci.STYLE_LINENUMBER, 1, 0);
        _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,Setting.getEditorFont()); 
        _sci.sendEditor(QXSci.SCI_STYLESETSIZEFRACTIONAL, QXSci.STYLE_DEFAULT,Setting.getEditorFontSize()); 
        _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0); 
        _sci.sendEditor(QXSci.SCI_SETEOLMODE, 1, 0); 
        
        _sci.sendEditor(QXSci.SCI_SETMARGINTYPEN, 0, QXSci.SC_MARGIN_NUMBER); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 0, 40); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 1, 10); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 2, 0); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 3, 0); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 4, 0); 

        _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_LINENUMBER, 0xffefefef);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_LINENUMBER, 0xffaf912b);
        _sci.sendEditor(QXSci.SCI_SETMARGINLEFT, 0, 0);
        
        _sci.sendEditor(QXSci.SCI_SETCARETFORE,0xff000000,0);
        
        _sci.sendEditor(QXSci.SCI_SETCARETLINEVISIBLE, 1); 
        _sci.sendEditor(QXSci.SCI_SETCARETLINEBACK, 0xffefefef); 

        _sci.sendEditor(QXSci.SCI_SETTABWIDTH, 4); 
    }
    
    void syntaxForOutputDark(QXSci _sci){
        _sci.sendEditor(QXSci.SCI_SETCODEPAGE, QXSci.SC_CP_UTF8);
        _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_DEFAULT, 0xff262525);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_DEFAULT, 0xffefefef);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, 75, 0xffefefef);
        _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
        //_sci.sendEditor(QXSci.STYLE_LINENUMBER, 1, 0);
        _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,Setting.getEditorFont()); 
        _sci.sendEditor(QXSci.SCI_STYLESETSIZEFRACTIONAL, QXSci.STYLE_DEFAULT,Setting.getEditorFontSize()); 
        _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0); 
        //_sci.sendEditor(QXSci.SCI_SETREADONLY, 1);
        //C++语法解析 
        //_sci.sendEditor(QXSci.SCI_SETLEXER, QXSci.SCLEX_CPP, 0); 
        //_sci.sendEditor(QXSci.SCI_SETKEYWORDS, 0, szKeywords1);//设置关键字 
        //_sci.sendEditor(QXSci.SCI_SETKEYWORDS, 1, szKeywords2);//设置关键字 
        // 下面设置各种语法元素风格 
        _sci.sendEditor(QXSci.SCI_SETEOLMODE, 1, 0); 
        
        _sci.sendEditor(QXSci.SCI_SETMARGINTYPEN, 0, QXSci.SC_MARGIN_NUMBER); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 0, 40); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 1, 10); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 2, 0); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 3, 0); 
        _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 4, 0); 
        
        _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_LINENUMBER, 0xff262525);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_LINENUMBER, 0xff666666);
        _sci.sendEditor(QXSci.SCI_SETMARGINLEFT, 0, 0);
        
        _sci.sendEditor(QXSci.SCI_SETCARETFORE,0xffffffff,0);
        
        _sci.sendEditor(QXSci.SCI_SETCARETLINEVISIBLE, 1); 
        _sci.sendEditor(QXSci.SCI_SETCARETLINEBACK, 0xff202020); 
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.SCE_C_COMMENT, 0xff666666);
        _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.SCE_C_COMMENTLINE, 0xff666666);
        
    }
    
    String getDefault(String sz){
        if (sz == nilptr){
            return "";
        }
        return sz;
    }
    
    void showConfig(){
        if (current_config != nilptr){
            String szcc = getDefault(current_config.getString("cc"));
            String szld = getDefault(current_config.getString("ld"));
            String szdbg = getDefault(current_config.getString("dbg"));
            String szar = getDefault(current_config.getString("ar"));
            String szmake = getDefault(current_config.getString("make"));
            
            String ccparams = getDefault(current_config.getString("ccparams"));
            String ldparams = getDefault(current_config.getString("ldparams"));
            String dbgparams = getDefault(current_config.getString("dbgparams"));
            String arparams = getDefault(current_config.getString("arparams"));
            
            edtcc.setText(szcc);
            edtld.setText(szld);
            edtdbg.setText(szdbg);
            edtar.setText(szar);
            edtmake.setText(szmake);
            
            _ccargs.setText(ccparams);
            _ldargs.setText(ldparams);
            _dbgargs.setText(dbgparams);
            _arargs.setText(arparams);
        }
    }
    
    void setCurrent(String key, String value){
        while (current_config.has(key)){
            current_config.remove(key);
        }
        current_config.put(key,value);
    }
    
    void saveconfig(){
        if (current_config != nilptr){
            setCurrent("cc",edtcc.getText());
            setCurrent("ld",edtld.getText());
            setCurrent("dbg",edtdbg.getText());
            setCurrent("ar",edtar.getText());
            setCurrent("make",edtmake.getText());
            
            setCurrent("ccparams",_ccargs.getText());
            setCurrent("ldparams",_ldargs.getText());
            setCurrent("dbgparams",_dbgargs.getText());
            setCurrent("arparams",_arargs.getText());
        }
    }
    void reloadList(String curlab){
        cmbcfg.clear();
        int selid = -1;
        String [] items = new String[cpp_configures.length()];
        for (int i = 0; i < cpp_configures.length(); i++){
            items[i] = ( (JsonObject)cpp_configures.get(i)).getString("name");
            if (curlab != nilptr){
                if (curlab.equals(items[i] )){
                    selid = i;
                }
            }
        }
        
        cmbcfg.addItems(items);
        if (selid != -1){
            cmbcfg.setCurrentIndex(selid);
        }
        showConfig();
    }
    
    void loadConfigures(){
        String configure = CPPGPlugManager.CPPLangPlugin.readFileContent(CDEProjectPropInterface.appendPath(XPlatform.getAppDirectory(), "plugins/cde/configures.cfg"));
        if (configure != nilptr){
            JsonObject root = new JsonObject(configure);
            cpp_configures = (JsonArray)root.get("configures");
        }
        
        if (cpp_configures == nilptr){
            cpp_configures = new JsonArray();
        }
        reloadList(nilptr);
    }
    
    public static void showCPPSetting(){
        QXDialog newDlg = new QXDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("cppsetting.ui");
        QXBuffer qb = new QXBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        if (newDlg.load(qb)){
            CPPSetting cppsetting = new CPPSetting();
            cppsetting.attach(newDlg);
        }
    }
    
    bool onClose()override{
        saveconfig();
        return true;
    }
    
    void detectDefaultMacro(String cc){
        String [] args = {"cmd", "/c", "\"" + String.formatPath(cc,false) + "\"", "-posix", "-m32","-dM", "-E", "-x", "c++", "-", "<nul"};
        
        String execute = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            execute = XKernel32.getWindowsDir();
            if (execute == nilptr) {
                return;
            }

            execute = String.formatPath( CDEProjectPropInterface.appendPath(execute, "system32\\cmd.exe"), false);
        }else{
            args[0] = "bash";
            args[1] = "-c";
            execute = "/bin/bash";
        }
        Process process = new Process(execute, args);
        
        try{
            process.setWorkDirectory(cc.findVolumePath());
            if (process.create(Process.StdOut | Process.RedirectStdErr)){
                new Thread(){
                    void run()override{
                        EchoBuffer ebuf = new EchoBuffer();
                        int rd = 0;
                        byte [] buffer = new byte[4096];
                        
                        try{
                            while ((rd = process.read(buffer, 0, 4096)) > 0){
                                ebuf.append(buffer,0,rd);
                            }
                        }catch(Exception e){
            
                        }
                        
                        parseMacroList(ebuf.toString());
                    }
                }.start();
            }
        }catch(Exception e){
            
        }
    }
    
    void parseMacroList(String lists){
        String macroarr = "";
        
        String [] macros = lists.split('\n');
        for (int i = 0; i < macros.length; i++){
            String mitem = macros[i].trim(true);
            if (mitem.startWith("#define ")){
                mitem = mitem.substring(8, mitem.length());
                int pos = mitem.indexOf(' ');
                if (pos != -1){
                    if (mitem.indexOf(' ',pos + 1) != -1){
                        mitem = mitem.substring(0,pos);
                    }else{
                        mitem = mitem.replace(pos, pos + 1, "=");
                    }
                    macroarr = macroarr + " " + (mitem);
                }
            }
        }
        
        runOnUi( new Runnable(){
            void run() override{
                while (current_config.has("macros")){
                    current_config.remove("macros");
                }
                current_config.put("macros", macroarr);
            }
        });
    }
    
    void detectIncludeSearchDir(String cc){

        String [] args = {"\"" + cc + "\"", "-xc++", "-E", "-v", "-"};
        
        Process process = new Process(cc, args);
        
        try{
            process.setWorkDirectory(cc.findVolumePath());
            if (process.create(Process.StdOut | Process.RedirectStdErr)){
                new Thread(){
                    void run()override{
                        EchoBuffer ebuf = new EchoBuffer();
                        int rd = 0;
                        byte [] buffer = new byte[4096];
                        
                        try{
                            Thread.sleep(500);
                            process.raise(_system_.SIGINT);
                            while ((rd = process.read(buffer, 0, 4096)) > 0){
                                ebuf.append(buffer,0,rd);
                                if (ebuf.endWith("\nEnd of search list.\n".getBytes()) || 
                                    ebuf.endWith("\r\nEnd of search list.\r\n".getBytes()) )
                                {
                                    break;
                                }
                            }
                            process.exit(5);
                        }catch(Exception e){
            
                        }
                        
                        parseSearchList(ebuf.toString());
                        
                    }
                }.start();
            }
        }catch(Exception e){
            
        }
        
        detectDefaultMacro(cc);
    }
    
        
    void parseSearchList(String lists){
        String [] items = lists.split('\n');
        Vector<String> searchs = new Vector<String>();
        int step = 0;
        
        for (int i = 0; i < items.length; i++){
            String item = items[i].trim(true);
            if (step == 0){
                if (item.endWith("<...> search starts here:")){
                    step = 1;
                }
            }else
            if (step == 1){
                if (item.endWith("End of search list.") == false){
                    searchs.add(item);
                }else{
                    break;
                }
            }
        }
        
        runOnUi( new Runnable(){
            void run() override{
                JsonArray jarray = new JsonArray();
                for (int i =0; i < searchs.size(); i++){
                    jarray.put(String.formatPath(searchs[i], false));
                }
                while (current_config.has("searchs")){
                    current_config.remove("searchs");
                }
                current_config.put("searchs", jarray);
            }
        });
    }
    
};