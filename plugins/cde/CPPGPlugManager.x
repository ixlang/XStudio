//xlang Source, Name:CPPGPlugManager.x 
//Date: Tue Feb 20:25:34 2020 

class CPPGPlugManager{

    static CPPProjectPlugin _projectplugin = new CPPProjectPlugin();
    static IXStudioController xcontroller;
    public static WorkspaceController workspace;
    static QXMainWindow _mainWindow;
    static TextEditorController disasm_wnd = nilptr;
    static XSourceEditor asm_editor = nilptr;
    static QXSci __gdb_command = nilptr;
    public static bool bATTDisasmMode = Setting.get("cde_gdb_disasm").equals("True");
    static QXDockWidget __cde_dock = nilptr;
    static bool __cde_dock_visible = false;
    
    public static String disassemble_pipe = "#/XStudio/DisassemblePipe" + (int)(Math.random() * 100000);
    
    static Map<long, String> disassembleLines = new Map<long, String>();
    
    public static bool isATTDisasmMode(){
        return bATTDisasmMode;
    }
    
    public static class DisassembleReceiver : public GDBShell.Receiver{
        void onComplete(@NotNilptr String content, bool res){
            workspace.RunOnUi(new UIRunnable(){
                void run(){
                    showDisassemble(content);
                }
            });
        }
    };
    
    int compateLine(@NotNilptr QXSci _sci, int line, long addr){
        String linetxt = _sci.getText(line);
        return linetxt.trim(true).parseHex() - addr;
    }
    public int binarySearch(@NotNilptr QXSci _sci, int cnt, long addr){//以int数组为例，aim为需要查找的数
        int start = 0;
        int end = cnt - 1;
        int mid = (start + end) / 2;//a
        
        while(compateLine(_sci, mid, addr) != 0 && end > start){//如果data[mid]等于aim则死循环，所以排除
            if(compateLine(_sci, mid, addr) > 0){
                end = mid-1;
            }else if(compateLine(_sci, mid, addr) < 0){
                start = mid+1;
            }
            mid = (start+end)/2;//b，注意a，b
        }
        return (compateLine(_sci, mid, addr) != 0)?-1:mid;//返回结果
    }
    
    public static long getDisassembleAddress(int line){
        if (asm_editor != nilptr && line > 0){
            String text = asm_editor._sci.getText(line - 1);
            return text.trim(true).parseHex();
        }
        return 0;
    }
    
    static Map<long, bool> __breakpointerlist = new Map<long, bool>();
    
    static bool addrHasBreakpoint(long addr){
        return __breakpointerlist.containsKey(addr);
    }
    
    public static void clearBreakOn(){
        workspace.RunOnUi(new UIRunnable(){
                            void run(){
                                if (asm_editor != nilptr){
                                    asm_editor.clearBreakOn();
                                }
                            }
                        });
    }
    
   
    
    static void showDisassemble(@NotNilptr String content){
        
        asm_editor._sci.setReadOnly(false);
        int cnt = asm_editor._sci.countOfLine();
        int line = 0;
        String [] asms = content.split('\n');
        for (int i = 0; i < asms.length; i++){
            String lineText = asms[i];
            if (lineText != nilptr && lineText.startWith("=>")){
                line = i;
                asms[i] = "  " + lineText.substring(2, lineText.length());
                break;
            }
        }
        content = content.replace("=>", "  ");
        String bkLine = asms[line];
        
        String beginLine = asm_editor._sci.getText(0);
        long beginOffset = beginLine.trim(true).parseHex();
        long endOffset = 0;
        if (cnt > 0){
            String endline = asm_editor._sci.getText(cnt - 1);
            if (endline.length() == 0 && cnt > 2){
                endline = asm_editor._sci.getText(cnt - 2);
            }
            endOffset = endline.trim(true).parseHex();
        }
        
        long newBeginOffset = asms[0].trim(true).parseHex();
        long newEndOffste = 0;
        if (asms.length > 0){
            newEndOffste = asms[asms.length - 1].trim(true).parseHex();
        }
        
        Vector<int> bplines = new Vector<int> ();
        
        if (!(newBeginOffset < endOffset && beginOffset < newEndOffste) ){
            disassembleLines.clear();
        }
        
        for (int i = 0; i < asms.length; i++){
            long address = asms[i].trim(true).parseHex();
            disassembleLines.put(address, asms[i]);
        }
        
        Map.Iterator<long, String> iter = disassembleLines.iterator();
            
        String texts = "";
        int idl = 0;
        while (iter.hasNext()){
            String lineTxt = iter.getValue();
            if (lineTxt != nilptr){
                if (lineTxt.equals(bkLine)){
                    line = idl;
                }
                if (addrHasBreakpoint(iter.getKey())){
                    bplines.add(idl);
                }
                texts = texts + lineTxt + "\n";
            }
            idl++;
            iter.next();
        }
        
        asm_editor._sci.setText(texts);
        
        disasm_wnd.setBreakOn(line,0,true,true);
        
        asm_editor.removeAllModified();
        asm_editor.resetAllModified();
        asm_editor._sci.clearUndo();
        asm_editor._sci.setSavePoint();
        
        asm_editor.setWindowTitle("反汇编");
        
        int [] bkps = bplines.toArray(new int [0]);
        
        for (int i = 0; i < bkps.length; i++){
            asm_editor.toggleBreakPoint(bkps[i], true);
        }
        
        asm_editor._sci.setReadOnly(true);
    }
    
    public static bool isInDisassemble(){
        if (asm_editor == nilptr){
            return false;
        }
        return XWorkspace.workspace.currentSubWindow() == asm_editor;
    }
    
    
    public static String getSourceContent(String file){
        SourceContent sc = workspace.getSourceContent(file);
        if (sc != nilptr){
            return sc.getContent();
        }
        return nilptr;
    }
    
    public static void toggleBreakPoint(long addr, int line , bool set){
        if (set){
            __breakpointerlist.put(addr, true);
        }else{
            __breakpointerlist.remove(addr);
        }
        if (asm_editor == nilptr){
            return ;
        }
        asm_editor.toggleBreakPoint(line, set);
    }
	public static class CPPLangPlugin : IXPlugin{
        static IXPlugin _this;
		CPPTextEditor textPlugin = new CPPTextEditor();
        
        public @NotNilptr static IXPlugin getInstance(){
            if (_this == nilptr){
                _this = new CPPGPlugManager.CPPLangPlugin();
            }
            return _this;
        }
        
		String getName(){
			return "cde";
		}
		
        public static String readFileContent(@NotNilptr String file){
            FileInputStream fis = nilptr;
            
            try{
                fis = new FileInputStream(file);
                byte []data = fis.read();
                fis.close();
                return new String(data);
            }catch(Exception e){
            
            }finally{
                if (fis != nilptr){
                    fis.close();
                }  
            }
            
            return nilptr;
        }
    
		void onTextEditorCreated(TextEditorController editor){
		
		}
        
		IProjectPlugin getProjectPlugin(){
            return _projectplugin;
        }
        
		void onTextEditorClosed(TextEditorController editor){
            if (disasm_wnd == editor){
                disasm_wnd = nilptr;
                asm_editor = nilptr;
            }
		}
		
         /*** 
        @brief 初始化插件
        @param controller XStudio的控制句柄
        @param enabled 是否启用
        */
        public void syntaxForOutput(@NotNilptr QXSci _sci)
        {
            if (Setting.isDarkStyle()) {
                syntaxForOutputDark(_sci);
                return ;
            }
            _sci.sendEditor(QXSci.SCI_SETCODEPAGE, QXSci.SC_CP_UTF8);
            //_sci.setWrap(true);
            _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_DEFAULT, 0xffffffff);
            _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_DEFAULT, 0xff222827);
            _sci.sendEditor(QXSci.SCI_STYLESETFORE, 75, 0xff222827);
            _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
            _sci.sendEditor(QXSci.SCI_CLEARDOCUMENTSTYLE, 0, 0);

            //_sci.sendEditor(QXSci.STYLE_LINENUMBER, 1, 0);
            bool bmac = (_system_.getPlatformId() == 2);
            if (bmac == false) {
                _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,"Consolas");
                _sci.sendEditor(QXSci.SCI_STYLESETSIZE, QXSci.STYLE_DEFAULT,9);
            } else {
                _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,"Monaco");
                _sci.sendEditor(QXSci.SCI_STYLESETSIZE, QXSci.STYLE_DEFAULT,11);
            }

            _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
            _sci.sendEditor(QXSci.SCI_SETEOLMODE, 1, 0);
            _sci.sendEditor(QXSci.SCI_SETSELBACK,1,0xfff1ebe5);
            _sci.sendEditor(QXSci.SCI_SETSELFORE,0,0);

            _sci.sendEditor(QXSci.SCI_SETMARGINTYPEN, 0, QXSci.SC_MARGIN_NUMBER);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 0, 35);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 1, 5);
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
            _sci.setWrap(Setting.isOutputWrap());
        }

        public void syntaxForOutputDark(@NotNilptr QXSci _sci)
        {
            _sci.sendEditor(QXSci.SCI_SETCODEPAGE, QXSci.SC_CP_UTF8);
            //_sci.setWrap(true);
            _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_DEFAULT, 0xff262525);
            _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_DEFAULT, 0xffefefef);
            _sci.sendEditor(QXSci.SCI_STYLESETFORE, 75, 0xffefefef);
            _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
            _sci.sendEditor(QXSci.SCI_CLEARDOCUMENTSTYLE, 0, 0);

            //_sci.sendEditor(QXSci.STYLE_LINENUMBER, 1, 0);
            bool bmac = (_system_.getPlatformId() == 2);
            if (bmac == false) {
                _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,"Consolas");
                _sci.sendEditor(QXSci.SCI_STYLESETSIZE, QXSci.STYLE_DEFAULT,9);
            } else {
                _sci.sendEditor(QXSci.SCI_STYLESETFONT, QXSci.STYLE_DEFAULT,"Monaco");
                _sci.sendEditor(QXSci.SCI_STYLESETSIZE, QXSci.STYLE_DEFAULT,11);
            }
            _sci.sendEditor(QXSci.SCI_STYLECLEARALL, 0, 0);
            _sci.sendEditor(QXSci.SCI_SETEOLMODE, 1, 0);
            _sci.sendEditor(QXSci.SCI_SETSELBACK,1,0xff3e4849);
            _sci.sendEditor(QXSci.SCI_SETSELFORE,0,0);

            _sci.sendEditor(QXSci.SCI_SETMARGINTYPEN, 0, QXSci.SC_MARGIN_NUMBER);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 0, 35);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 1, 5);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 2, 0);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 3, 0);
            _sci.sendEditor(QXSci.SCI_SETMARGINWIDTHN, 4, 0);

            _sci.sendEditor(QXSci.SCI_STYLESETBACK, QXSci.STYLE_LINENUMBER, 0xff262525);
            _sci.sendEditor(QXSci.SCI_STYLESETFORE, QXSci.STYLE_LINENUMBER, 0xff666666);
            _sci.sendEditor(QXSci.SCI_SETMARGINLEFT, 0, 0);

            _sci.sendEditor(QXSci.SCI_SETCARETFORE,0xffffffff,0);

            _sci.sendEditor(QXSci.SCI_SETCARETLINEVISIBLE, 1);
            _sci.sendEditor(QXSci.SCI_SETCARETLINEBACK, 0xff202020);
            _sci.setWrap(Setting.isOutputWrap());
        }
        
        void showDocks(bool bs){
            if (__cde_dock != nilptr && __cde_dock.isValid()){
                if (bs == false){
                    __cde_dock_visible = __cde_dock.isVisible();
                    __cde_dock.setVisible(false);
                }else{
                    __cde_dock.setVisible(__cde_dock_visible);
                }
            }
        }
            
        void createMyDock(){
            QXDockWidget qdock = new QXDockWidget();
            qdock.create(_mainWindow);
            qdock.setFeatures(QXDockWidget.DockWidgetClosable|QXDockWidget.DockWidgetFloatable);
            qdock.setWindowTitle("GDB 命令窗口");
            qdock.setName("gdb_cmd_port");
            __cde_dock = qdock;
            
            QVBoxLayout qhl = new QVBoxLayout();
            qhl.create(qdock);
            
            QXWidget w1 = new QXWidget();
            w1.create();
            
            QXSci buf = new QXSci();
            buf.create(w1);
            qhl.addWidget(buf);
            __gdb_command = buf;
            syntaxForOutput(__gdb_command);
            
            QHBoxLayout inputlayout = new QHBoxLayout();
            inputlayout.create(w1);
            
            QXWidget w2 = new QXWidget();
            w2.create();
            
            QXLabel _cli = new QXLabel();
            _cli.create(w2);
            inputlayout.addWidget(_cli);
            _cli.setText("(gdb)>");
            QXLineEdit cmd = new QXLineEdit();
            cmd.create(w2);
            inputlayout.addWidget(cmd);
            
            cmd.setOnKeyEventListener(new QXLineEdit.onKeyEventListener() {
                Vector<String> cmd_histroy = new Vector<String>();
                
                int histroy_pointer = 0;
                
                void addCommand(String cmd){
                    __nilptr_safe(cmd_histroy);
                    for (int i = 0, c = cmd_histroy.size(); i < c; i++){
                        if (cmd_histroy[i].equals(cmd)){
                            cmd_histroy.remove(i);
                            break;
                        }
                    }
                    
                    cmd_histroy.add(cmd);
                    histroy_pointer = cmd_histroy.size();
                }
                
                String getCommand(bool prev){
                    __nilptr_safe(cmd_histroy);
                    if (prev){
                        if (histroy_pointer > 0 && histroy_pointer <= cmd_histroy.size()){
                            return cmd_histroy[--histroy_pointer];
                        }
                        return nilptr;
                    }else{
                        if (histroy_pointer + 1 < cmd_histroy.size()){
                            return cmd_histroy[++histroy_pointer];
                        }
                        histroy_pointer = cmd_histroy.size();
                        return "";
                    }
                }
                
                bool onKeyPress(QXObject obj,int key,bool repeat,int count,String text,int scanCode,int virtualKey,int modifier)override {
                    if (key == QXObject.Key_Escape) {
                        cmd.setText("");
                    }else
                    if (key == QXObject.Key_Up) {
                        String _cmds = getCommand(true);
                        if (_cmds != nilptr){
                            cmd.setText(_cmds);
                        }
                    }else
                    if (key == QXObject.Key_Down) {
                        String _cmds = getCommand(false);
                        if (_cmds != nilptr){
                            cmd.setText(_cmds);
                        }
                    }else
                    if (key == QXObject.Key_Enter || key == QXObject.Key_Return) {
                        String __cmd = cmd.getText().trim(true);
                        if (__cmd.length() > 0){
                            buf.appendText("(gdb)>" + __cmd + "\n");
                            if (sendCommand(__cmd) == false){
                                buf.appendText("gdb调试器不在运行中." + "\n");
                            }
                            cmd.setText("");
                            addCommand(__cmd);
                        }
                    }
                    return true;
                }
                
            });
        
            QXPushButton sent = new QXPushButton();
            sent.create(w2);
            sent.setText("执行");
            inputlayout.addWidget(sent);
            
            sent.setOnClickListener(new QXPushButton.onClickListener(){
                void onClick(QXObject obj, bool checked) {
                    String __cmd = cmd.getText();
                    buf.appendText("(gdb)>" + __cmd + "\n");
                    if (sendCommand(__cmd) == false){
                        buf.appendText("gdb调试器不在运行中." + "\n");
                    }
                    cmd.setText("");
                }
            });
 
            QXPushButton clr = new QXPushButton();
            clr.create(w2);
            clr.setText("清空");
            inputlayout.addWidget(clr);
            w2.setLayout(inputlayout);
            
            clr.setOnClickListener(new QXPushButton.onClickListener(){
                void onClick(QXObject obj, bool checked) {
                    buf.setText("");
                }
            });
            
            qhl.addWidget(w2);
            w1.setLayout(qhl);
            qdock.setWidget(w1);
            /*qdock.setFlating(true);
            qdock.setAllowedAreas(QXDockWidget.LeftDockWidgetArea |QXDockWidget.RightDockWidgetArea);*/
            qdock.setFeatures(QXDockWidget.AllDockWidgetFeatures);
            _mainWindow.addDockWidget(QXDockWidget.BottomDockWidgetArea, qdock, QXWidget.Orientation.Horizontal);
        }
        
		bool initializPlusin(IXStudioController controller, bool enabled){
            xcontroller = controller;
            workspace = xcontroller.getWorkspace();
            _mainWindow = workspace.getMainWindow();
            String initfile = CDEProjectPropInterface.appendPath(XPlatform.getAppDirectory(), "plugins/cde/cde.init");
            if (XPlatform.existsSystemFile(initfile) == false){
                Setting.setSetting("usbuiltinlsp", "True");
                Setting.setSetting("cde_make_multithread", "True");
                Setting.setSetting("cde_make_thread_num", "4");
                Setting.setSetting("cde_gdb_catchthrow", "True");
                
                if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                    Setting.setSetting("lspcomplimit", "3000");
                }
                if (_system_.getPlatformId() == _system_.PLATFORM_LINUX){
                    Setting.setSetting("cde_gdb_autovmterm", "True");
                    
                    if (Setting.get("cde_gdb_params").trim(true).length() == 0){
                        Setting.setSetting("cde_gdb_params", "-e bash -c $(arg)");
                    }
                }
                new FileOutputStream(initfile).close();
            }
            
			xcontroller = controller;
            
            if (enabled == false){
                return true;
            }
            
            _projectplugin.createWizard();
            workspace.addMenu(4, "c_cpp_setting", "C/C++套件选项", "res/toolbar/class.png",nilptr, this);
            workspace.addMenu(3, "disassem_wnd", "反汇编窗口", nilptr,nilptr, this);
            createMyDock();
            return true; 
		}
        
        TextEditorPlugin getTextEditorPlugin(){
			return textPlugin;
        }
        
        IProject loadProject(JsonObject content, String lang){
			return nilptr;
        }
        
        
        void onMenuTrigged(@NotNilptr String name){
            if (name.equals("c_cpp_setting")) {
                CPPSetting.showCPPSetting();
            }

            if (name.equals("disassem_wnd")){
                if (disasm_wnd == nilptr){
                    disasm_wnd = workspace.createTextEditor();
                    asm_editor = (XSourceEditor)XWorkspace.workspace.currentSubWindow();
                    if (asm_editor.getController() == disasm_wnd){
                        asm_editor.setWindowTitle("反汇编");
                    }
                    asm_editor.removeFromMap(disasm_wnd.getPath());
                    asm_editor.setFilePath(disassemble_pipe);
                    asm_editor.addToMap(disassemble_pipe);
                }else{
                    disasm_wnd.activeEditor();
                }
                updateDisassemble();
            }
            
            if (name.equals("SYS_ADDOBJECT")){
               XWorkspace.workspace.createProject();
            }
        }
        
        String getIcon(){
            return "res/package64.png";
        }
        
        bool onExit(){
            return true;
        }
        
        long getVersion(){
            return 1001;
        } 
        @NotNilptr String getDescrition(){
            return "c/c++ 项目开发扩展.";
        }
        @NotNilptr String publisher(){
            return "https://github.com/ixlang/xlibraries";
        }
        void uninstall(IXStudioController){
            
        }
                
        @NotNilptr JsonObject createBoolOption(){
            JsonObject item_bk = new JsonObject();
            item_bk.put("type", "bool");
            return item_bk;
        }
        
        @NotNilptr JsonObject createFileOpen(){
            JsonObject item_bk = new JsonObject();
            item_bk.put("type", "filein");
            return item_bk;
        }
        
        @NotNilptr JsonObject createInputText(){
            JsonObject item_bk = new JsonObject();
            item_bk.put("type", "string");
            return item_bk;
        }
        
        @NotNilptr JsonObject createParamText(){
            JsonObject item_bk = new JsonObject();
            item_bk.put("type", "params");
            return item_bk;
        }
        
        @NotNilptr JsonObject createOptions(@NotNilptr String [] options){
            JsonObject item_bk = new JsonObject();
            JsonArray swi = new JsonArray();
            swi.put("未配置");
            for (int i = 0; i < options.length; i++){
                swi.put(options[i]);
            }
            item_bk.put("list", swi);
            item_bk.put("type", "options");
            return item_bk;
        }
        
        @NotNilptr String getSetting(){
            JsonObject __root = new JsonObject();
            
            
            { 
            JsonObject _items = new JsonObject();
            
            JsonArray swi = new JsonArray();
            
            _items.put("显示 AT&T 格式汇编:cde_gdb_disasm", createBoolOption());
            _items.put("捕获抛出的异常:cde_gdb_catchthrow", createBoolOption());
            if (_system_.getPlatformId() == _system_.PLATFORM_LINUX){
                _items.put("自动检测虚拟终端:cde_gdb_autovmterm", createBoolOption());
                _items.put("指定虚拟终端:cde_gdb_setvmterm", createFileOpen());
                _items.put("虚拟终端启动参数:cde_gdb_params", createInputText());
            }
            __root.put("GDB调试选项", _items);
            }
            {
            JsonObject _items = new JsonObject();
            
            JsonArray swi = new JsonArray();
            
            _items.put("Make 时使用多线程:cde_make_multithread", createBoolOption());
            _items.put("Make 线程数:cde_make_thread_num", createInputText());
            _items.put("默认编译套件:default_kit", createOptions(CDEProjectPropInterface.getConfigures()));
            __root.put("C/C++ 设置", _items);
            }
            {
            JsonObject _items = new JsonObject();
            
            JsonArray swi = new JsonArray();
            _items.put("使用内置的LSP服务器:usbuiltinlsp", createBoolOption());
            _items.put("LSP服务器:lsppath", createFileOpen());
            _items.put("LSP服务器启动参数:lspstartargs", createParamText());
            _items.put("自动完成输出限制:lspcomplimit", createInputText());
            _items.put("LSP编译参数:lspparam", createParamText());
            __root.put("C/C++ LSP设置", _items);
            }
            return __root.toString(true);
        }
        
        public static class CommandReceiver : public GDBShell.Receiver{
            void onComplete(@NotNilptr String content, bool res){
                workspace.RunOnUi(new UIRunnable(){
                    void run(){
                        __gdb_command.appendText(content + "\n");
                        __gdb_command.gotoPos(__gdb_command.getLength());
                    }
                });
            }
        };
        
        bool sendCommand(String cmd){
            CDEProjectPropInterface iface = CDEProjectPropInterface.getInstance();
            GDBShell gshell = iface.getGdb();
            if (gshell != nilptr){
                gshell.runCustomCommand(cmd, new CommandReceiver());
                return true;
            }
            return false;
        }
        
        void settingFlushed(){
            bATTDisasmMode = Setting.get("cde_gdb_disasm").equals("True");
            
            CDEProjectPropInterface iface = CDEProjectPropInterface.getInstance();

            GDBShell gshell = iface.getGdb();
            if (gshell != nilptr){
                gshell.writeGdbCommand( bATTDisasmMode ? "set disassembly-flavor att\n" : "set disassembly-flavor intel\n");
                if(isCacheThrow()){
                    gshell.writeGdbCommand("catch throw\n");
                }
            }
        
            syntaxForOutput(__gdb_command);
        }
	};
    
    public static bool isCacheThrow(){
        return Setting.get("cde_gdb_catchthrow").equals("True");
    }
    
    public static int getMultiMake(){
        if (Setting.get("cde_make_multithread").equals("True")){
            return Setting.get("cde_make_thread_num").parseInt();
        }
        return 0;
    }
    
    
    public static void updateDisassemble(){
        CDEProjectPropInterface iface = CDEProjectPropInterface.getInstance();
        GDBShell gshell = iface.getGdb();
        if (gshell != nilptr){
            gshell.DisassembleReq dq = new gshell.DisassembleReq(
            new GDBShell.Receiver(){
                void onComplete(@NotNilptr String content, bool res){
                    workspace.RunOnUi(new UIRunnable(){
                        void run(){
                            showDisassemble(content);
                        }
                    });
                }
            });
            dq.exec();
        }
    }
        
    public static void threadUpdateDisassemble(){
        workspace.RunOnUi(new UIRunnable(){
            void run(){
                if (isInDisassemble()){
                    updateDisassemble();
                }
            }
        });
    }
    
    public static void output(String text){
		if (xcontroller != nilptr){
			xcontroller.getWorkspace().output(text, 0);
        }
    }
    
    public static void output(String text, int wid){
		if (xcontroller != nilptr){
			xcontroller.getWorkspace().output(text, wid);
        }
    }
};