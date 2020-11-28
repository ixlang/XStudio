//xlang Source, Name:CPPSetting.x 
//Date: Thu Feb 17:40:17 2020 

class CPPSetting : QDialog{

    QPushButton btnnew,  btndel, btncc, btnld, btndbg, btnclose, btnar, btnmake;
    QLineEdit edtcc, edtld, edtdbg, edtar, edtmake;
    QComboBox cmbcfg;
    
    QScintilla _ccargs, _ldargs, _dbgargs, _arargs;
    QWidget ccarg, ldarg, dbgarg, ararg;
    JsonArray cpp_configures;
    JsonObject current_config;
    
    bool bClear = false;
    
    void onAttach()override{
    
        setWindowIcon("res/toolbar/build.png");
        btnnew = (QPushButton)attachByName(new QPushButton(), "btnnew");
        btndel = (QPushButton)attachByName(new QPushButton(), "btndel");
        btncc = (QPushButton)attachByName(new QPushButton(), "btncc");
        btnld = (QPushButton)attachByName(new QPushButton(), "btnld");
        btndbg = (QPushButton)attachByName(new QPushButton(), "btndbg");
        btnar = (QPushButton)attachByName(new QPushButton(), "btnar");
        btnmake = (QPushButton)attachByName(new QPushButton(), "btnmake");
        
        
        btnclose = (QPushButton)attachByName(new QPushButton(), "btnclose");
        
        edtcc = (QLineEdit)attachByName(new QLineEdit(), "edtcc");
        edtld = (QLineEdit)attachByName(new QLineEdit(), "edtld");
        edtdbg = (QLineEdit)attachByName(new QLineEdit(), "edtdbg");
        edtar = (QLineEdit)attachByName(new QLineEdit(), "edtar");
        edtmake = (QLineEdit)attachByName(new QLineEdit(), "edtmake");
        
        cmbcfg = (QComboBox)attachByName(new QComboBox(), "cmbcfg");
        
        ccarg = (QWidget)attachByName(new QWidget(), "ccarg");
        ldarg = (QWidget)attachByName(new QWidget(), "ldarg");
        dbgarg = (QWidget)attachByName(new QWidget(), "dbgarg");
        ararg = (QWidget)attachByName(new QWidget(), "ararg");
        
        __nilptr_safe(ccarg, ldarg, dbgarg, ararg);
        
        _ccargs = new QScintilla();
        if (_ccargs.create(ccarg) == false){
            return;
        }
        
        _ldargs = new QScintilla();
        if (_ldargs.create(ldarg) == false){
            return;
        }
        
        _dbgargs = new QScintilla();
        if (_dbgargs.create(dbgarg) == false){
            return;
        }
        
        _arargs = new QScintilla();
        if (_arargs.create(ararg) == false){
            return;
        }
        
        dbgarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QObject obj, int w, int h, int oldw, int oldh)override {
                if (_dbgargs != nilptr){
                    _dbgargs.resize(w, h);
                }
            }
        });
        
        ccarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QObject obj, int w, int h, int oldw, int oldh)override {
                if (_ccargs != nilptr){
                    _ccargs.resize(w, h);
                }
            }
        });
        
        ldarg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QObject obj, int w, int h, int oldw, int oldh)override {
                if (_ldargs != nilptr){
                    _ldargs.resize(w, h);
                }
            }
        });
        
        ararg.setOnLayoutEventListener(new onLayoutEventListener(){
            void onResize(QObject obj, int w, int h, int oldw, int oldh)override {
                if (_ldargs != nilptr){
                    _arargs.resize(w, h);
                }
            }
        });
        
        if (_ccargs != nilptr)
        syntaxForOutput(_ccargs);
        
        if (_ldargs != nilptr)
        syntaxForOutput(_ldargs);
        
        if (_dbgargs != nilptr)
        syntaxForOutput(_dbgargs);
        
        if (_arargs != nilptr)
        syntaxForOutput(_arargs);
        
        cmbcfg.setOnComboBoxEventListener(
            new onComboBoxEventListener() {
                void onItemSelected(QObject obj, int id) {
                    saveconfig();
                    String name = cmbcfg.getCurrentText();
                    for (int i = 0; i < cpp_configures.length(); i++){
                        JsonObject jconf = (JsonObject)cpp_configures.get(i);
                        if (jconf != nilptr && name.equals(jconf.getString("name"))){
                           current_config = jconf;
                           showConfig();
                           return; 
                        }
                     }
                }
            }
        );
        
        btnnew.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
                 
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
            void onClick(QObject obj, bool checked) {
                 if (current_config == nilptr){
                     QMessageBox.Critical("注意","请先选择或者新建一个配置",QMessageBox.Ok,QMessageBox.Ok);
                     return;
                 }
                 String filepath = QFileDialog.getOpenFileName("选择编译器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 //setCurrent("cc", filepath);
                 edtcc.setText(filepath);
                 autoDetect(filepath);
                 //showConfig();
            }
        });
        
        btnld.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
                if (current_config == nilptr){
                     QMessageBox.Critical("注意","请先选择或者新建一个配置",QMessageBox.Ok,QMessageBox.Ok);
                     return;
                 }
                 String filepath = QFileDialog.getOpenFileName("选择链接器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 edtld.setText(filepath);
                 /*setCurrent("ld", filepath);
                 showConfig();*/
            }
        });
        
        btndbg.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
                if (current_config == nilptr){
                     QMessageBox.Critical("注意","请先选择或者新建一个配置",QMessageBox.Ok,QMessageBox.Ok);
                     return;
                 }
                 String filepath = QFileDialog.getOpenFileName("选择调试器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 edtdbg.setText(filepath);
                 /*setCurrent("dbg", filepath);
                 showConfig();*/
            }
        });
        
        
        btnar.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
                if (current_config == nilptr){
                     QMessageBox.Critical("注意","请先选择或者新建一个配置",QMessageBox.Ok,QMessageBox.Ok);
                     return;
                 }
                 String filepath = QFileDialog.getOpenFileName("选择归档器","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 edtar.setText(filepath);
                 /*setCurrent("ar", filepath);
                 showConfig();*/
            }
        });
        
        btnmake.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
                if (current_config == nilptr){
                     QMessageBox.Critical("注意","请先选择或者新建一个配置",QMessageBox.Ok,QMessageBox.Ok);
                     return;
                 }
                 String filepath = QFileDialog.getOpenFileName("选择Make程序","","",CPPSetting.this);
                 if (filepath == nilptr ){
                    filepath = "";
                 }
                 filepath = String.formatPath(filepath,false);
                 edtmake.setText(filepath);
                 /*setCurrent("make", filepath);
                 showConfig();*/
            }
        });
        
        btnclose.setOnClickListener(new onClickListener(){
            void onClick(QObject obj, bool checked) {
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
            void onClick(QObject obj, bool checked) {
                String name = cmbcfg.getCurrentText();
                if (removeConfig(name)){
                    reloadList(nilptr);
                }
            }
        });
        
        setModal(true);
        show();
        loadConfigures();
    }
    
    bool removeConfig(@NotNilptr String name){
        for (int i = 0; i < cpp_configures.length(); i++){
            if (name.equals(((JsonObject)cpp_configures.get(i)).getString("name"))){
                cpp_configures.remove(i);
                return true; 
            }
         }
         return false;
    }
    
    bool createConfigure(String name){
         if (name == nilptr || name.length() == 0){
             QMessageBox.Critical("注意","名称无效",QMessageBox.Ok,QMessageBox.Ok);
             return false;
         }
         
         for (int i = 0; i < cpp_configures.length(); i++){
            if (name.equals(  ( (JsonObject)cpp_configures.get(i)).getString("name"))){
               QMessageBox.Critical("注意","名称已存在",QMessageBox.Ok,QMessageBox.Ok);
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
        if (filepath == nilptr){
            return;
        }
        String ext = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            ext = ".exe";
        }
        
        String dir = filepath.findVolumePath();
    
        String ld = CDEProjectPropInterface.appendPath(dir, "g++" + ext);
        if (XPlatform.existsSystemFile(ld)){
            if (QMessageBox.Question("注意","已检测到链接器位于 " + ld + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                edtld.setText(ld);
            }
        }
        
        String ar = CDEProjectPropInterface.appendPath(dir, "ar" + ext);
        if (XPlatform.existsSystemFile(ar)){
            if (QMessageBox.Question("注意","已检测到归档器位于 " + ar + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                edtar.setText(ar);
            }
        }
        
        String gdb = CDEProjectPropInterface.appendPath(dir, "gdb" + ext);
        if (XPlatform.existsSystemFile(gdb)){
            if (QMessageBox.Question("注意","已检测到调试器位于 " + gdb + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                edtdbg.setText(gdb);
            }
        }
        
        String make = CDEProjectPropInterface.appendPath(dir, "make" + ext);
        if (XPlatform.existsSystemFile(make)){
            if (QMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                edtmake.setText(make);
            }
        }else{
            make = CDEProjectPropInterface.appendPath(dir, "mingw32-make" + ext); 
            if (XPlatform.existsSystemFile(make)){
                if (QMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                    edtmake.setText(make);
                }
            }else{
                make = CDEProjectPropInterface.appendPath(dir, "mingw-w64-make" + ext); 
                if (XPlatform.existsSystemFile(make)){
                    if (QMessageBox.Question("注意","已检测到MAKE位于 " + make + ", 是否自动填入?",QMessageBox.Yes | QMessageBox.No,QMessageBox.Yes) == QMessageBox.Yes){
                        edtmake.setText(make);
                    }
                }
            }
        }
    }
    
    void syntaxForOutput(@NotNilptr QScintilla _sci){
		if (Setting.isDarkStyle()){
			syntaxForOutputDark(_sci);
            return ;
		}
        _sci.sendEditor(QScintilla.SCI_SETCODEPAGE, QScintilla.SC_CP_UTF8);
        _sci.setWrap(true);
        _sci.sendEditor(QScintilla.SCI_STYLESETBACK, QScintilla.STYLE_DEFAULT, 0xffffffff);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.STYLE_DEFAULT, 0xff222827);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, 75, 0xff222827);
        _sci.sendEditor(QScintilla.SCI_STYLECLEARALL, 0, 0);
        //_sci.sendEditor(QScintilla.STYLE_LINENUMBER, 1, 0);
        _sci.sendEditor(QScintilla.SCI_STYLESETFONT, QScintilla.STYLE_DEFAULT,Setting.getEditorFont()); 
        _sci.sendEditor(QScintilla.SCI_STYLESETSIZEFRACTIONAL, QScintilla.STYLE_DEFAULT,Setting.getEditorFontSize()); 
        _sci.sendEditor(QScintilla.SCI_STYLECLEARALL, 0, 0); 
        _sci.sendEditor(QScintilla.SCI_SETEOLMODE, 1, 0); 
        
        _sci.sendEditor(QScintilla.SCI_SETMARGINTYPEN, 0, QScintilla.SC_MARGIN_NUMBER); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 0, 40); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 1, 10); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 2, 0); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 3, 0); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 4, 0); 

        _sci.sendEditor(QScintilla.SCI_STYLESETBACK, QScintilla.STYLE_LINENUMBER, 0xffefefef);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.STYLE_LINENUMBER, 0xffaf912b);
        _sci.sendEditor(QScintilla.SCI_SETMARGINLEFT, 0, 0);
        
        _sci.sendEditor(QScintilla.SCI_SETCARETFORE,0xff000000,0);
        
        _sci.sendEditor(QScintilla.SCI_SETCARETLINEVISIBLE, 1); 
        _sci.sendEditor(QScintilla.SCI_SETCARETLINEBACK, 0xffefefef); 

        _sci.sendEditor(QScintilla.SCI_SETTABWIDTH, 4); 
    }
    
    void syntaxForOutputDark(@NotNilptr QScintilla _sci){
        _sci.sendEditor(QScintilla.SCI_SETCODEPAGE, QScintilla.SC_CP_UTF8);
        _sci.sendEditor(QScintilla.SCI_STYLESETBACK, QScintilla.STYLE_DEFAULT, 0xff262525);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.STYLE_DEFAULT, 0xffefefef);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, 75, 0xffefefef);
        _sci.sendEditor(QScintilla.SCI_STYLECLEARALL, 0, 0);
        //_sci.sendEditor(QScintilla.STYLE_LINENUMBER, 1, 0);
        _sci.sendEditor(QScintilla.SCI_STYLESETFONT, QScintilla.STYLE_DEFAULT,Setting.getEditorFont()); 
        _sci.sendEditor(QScintilla.SCI_STYLESETSIZEFRACTIONAL, QScintilla.STYLE_DEFAULT,Setting.getEditorFontSize()); 
        _sci.sendEditor(QScintilla.SCI_STYLECLEARALL, 0, 0); 
        //_sci.sendEditor(QScintilla.SCI_SETREADONLY, 1);
        //C++语法解析 
        //_sci.sendEditor(QScintilla.SCI_SETLEXER, QScintilla.SCLEX_CPP, 0); 
        //_sci.sendEditor(QScintilla.SCI_SETKEYWORDS, 0, szKeywords1);//设置关键字 
        //_sci.sendEditor(QScintilla.SCI_SETKEYWORDS, 1, szKeywords2);//设置关键字 
        // 下面设置各种语法元素风格 
        _sci.sendEditor(QScintilla.SCI_SETEOLMODE, 1, 0); 
        
        _sci.sendEditor(QScintilla.SCI_SETMARGINTYPEN, 0, QScintilla.SC_MARGIN_NUMBER); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 0, 40); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 1, 10); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 2, 0); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 3, 0); 
        _sci.sendEditor(QScintilla.SCI_SETMARGINWIDTHN, 4, 0); 
        
        _sci.sendEditor(QScintilla.SCI_STYLESETBACK, QScintilla.STYLE_LINENUMBER, 0xff262525);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.STYLE_LINENUMBER, 0xff666666);
        _sci.sendEditor(QScintilla.SCI_SETMARGINLEFT, 0, 0);
        
        _sci.sendEditor(QScintilla.SCI_SETCARETFORE,0xffffffff,0);
        
        _sci.sendEditor(QScintilla.SCI_SETCARETLINEVISIBLE, 1); 
        _sci.sendEditor(QScintilla.SCI_SETCARETLINEBACK, 0xff202020); 
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.SCE_C_COMMENT, 0xff666666);
        _sci.sendEditor(QScintilla.SCI_STYLESETFORE, QScintilla.SCE_C_COMMENTLINE, 0xff666666);
        
    }
    
    @NotNilptr String getDefault(String sz){
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
            String ccpath = edtcc.getText();
            
            String oldcc = current_config.getString("cc");
            
            setCurrent("cc",ccpath);
            setCurrent("ld",edtld.getText());
            setCurrent("dbg",edtdbg.getText());
            setCurrent("ar",edtar.getText());
            setCurrent("make",edtmake.getText());
            
            setCurrent("ccparams",_ccargs.getText());
            setCurrent("ldparams",_ldargs.getText());
            setCurrent("dbgparams",_dbgargs.getText());
            setCurrent("arparams",_arargs.getText());
            
            if ((oldcc == nilptr || oldcc.equals(ccpath) == false) && ccpath.length() > 0){
                setWindowTitle("C/C++ 套件设置 - 正在处理...");
                detectIncludeSearchDir(ccpath);
                setWindowTitle("C/C++ 套件设置");
            }
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
        QDialog newDlg = new QDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("cppsetting.ui");
        QBuffer qb = new QBuffer();
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
    
    void detectDefaultMacro(@NotNilptr String cc){
        Process process = nilptr;
        String execute = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            String [] args = {"cmd", "/c", "\"" + String.formatPath(cc,false) + "\"", "-posix",/* "-m32",*/"-dM", "-E", "-x", "c++", "-", "<nul"};
            execute = XKernel32.getWindowsDir();
            if (execute == nilptr) {
                return;
            }
            execute = String.formatPath( CDEProjectPropInterface.appendPath(execute, "system32\\cmd.exe"), false);
            process = new Process(execute, args);
        }else{
            String [] args = {"bash", "-c", "\"" + String.formatPath(cc,false) + "\" -posix -dM -E -x c++ - </dev/null"};
            execute = "/bin/bash";
            process = new Process(execute, args);
        }
        
        try{
            process.setWorkDirectory(cc.findVolumePath());
            if (process.create(Process.StdOut | Process.RedirectStdErr)){
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
        }catch(Exception e){
        }
    }
    
    void parseMacroList(@NotNilptr String lists){
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
        
        while (current_config.has("macros")){
            current_config.remove("macros");
        }
        current_config.put("macros", macroarr);
    }
    
    
    void detectIncludeSearchDir_linux(@NotNilptr String cc){
        String dbg_script = CDEProjectPropInterface.appendPath(CDEProjectPropInterface.appendPath(_system_.getAppDirectory(), "plugins/cde"), "test.sh");
      
        String ress = dbg_script + ".res";
        
        dbg_script = String.formatPath(dbg_script,false);
        
        String dbg_ps = dbg_script + "rs";
        String ps = "\"" + cc + "\" -xc++ -E -v /dev/null -o /dev/null";
        
        FileOutputStream fos = nilptr;
        try{
            fos = new FileOutputStream(dbg_script);
            byte [] bc = ps.getBytes();
            fos.write(bc);
        }catch(Exception e){
            return ;
        }finally{
            if (fos != nilptr){
                fos.close();
            }
        }
        _system_.chmod(dbg_script,0777);
        
        String [] args = {"bash", "-c", dbg_script};
        
        Process process = new Process("/bin/bash", args);
        try{
            if (process.create(Process.StdOut | Process.RedirectStdErr)){
                EchoBuffer ebuf = new EchoBuffer();
                int rd = 0;
                byte [] buffer = new byte[4096];
                
                try{
                    _system_.sleep(500);
                    process.raise(_system_.SIGINT);
                    
                    while ((rd = process.read(buffer, 0, 4096)) > 0){
                        ebuf.append(buffer,0,rd);
                    }
                    process.exit(5);
                }catch(Exception e){
    
                }
                parseSearchList(ebuf.toString());
            }
        }catch(Exception e){
            
        }
        detectDefaultMacro(cc);
    }
    
    void detectIncludeSearchDir(@NotNilptr String cc){
        if (_system_.getPlatformId() == _system_.PLATFORM_LINUX){
            detectIncludeSearchDir_linux(cc);
            return;
        }
        
        String [] args = {"\"" + cc + "\"", "-xc++", "-E", "-v", "-"};
        CDEProjectPropInterface.setEnvir(cc);
        Process process = new Process(cc, args);
        String ccdir = cc.findVolumePath();
        try{
            process.setWorkDirectory(ccdir);
            if (process.create(Process.StdOut | Process.RedirectStdErr)){
                EchoBuffer ebuf = new EchoBuffer();
                int rd = 0;
                byte [] buffer = new byte[4096];
                
                try{
                    _system_.sleep(500);
                    process.raise(_system_.SIGINT);
                    
                    while ((rd = process.read(buffer, 0, 4096)) > 0){
                        ebuf.append(buffer,0,rd);
                    }
                    process.exit(5);
                }catch(Exception e){
    
                }
                parseSearchList(ebuf.toString());
            }
        }catch(Exception e){
            
        }
        detectDefaultMacro(cc);
    }
    
        
    void parseSearchList(@NotNilptr String lists){
        String [] items = lists.split('\n');
        Vector<String> searchs = new Vector<String>();
        int step = 0;
        
        for (int i = items.length - 1; i >= 0; i--){
            String item = items[i];
            __nilptr_safe(item);
            if (item.startWith(" ")){
                FSObject fso = new FSObject(item.trim(true));
                if (fso.exists()){
                    searchs.insert(0, fso.getPath());
                }
            }
        }
        
        JsonArray jarray = new JsonArray();
        for (int i =0; i < searchs.size(); i++){
            jarray.put(String.formatPath(searchs[i], false));
        }
        while (current_config.has("searchs")){
            current_config.remove("searchs");
        }
        current_config.put("searchs", jarray);
    }
};