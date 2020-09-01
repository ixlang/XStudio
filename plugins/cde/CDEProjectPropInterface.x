//xlang Source, Name:CDEProjectPropInterface.x 
//Date: Tue Feb 20:38:34 2020 

class CDEProjectPropInterface : ProjectPropInterface{
    static CDEProjectPropInterface __cdeifce;
    
    public @NotNilptr static CDEProjectPropInterface getInstance(){
        if (__cdeifce == nilptr){
            __cdeifce = new CDEProjectPropInterface();
        }
        __nilptr_safe(__cdeifce);
        return __cdeifce;
    }
    public CDEProjectPropInterface(){
        __cdeifce = this;
    }
    String getFileExtensionFilter(){
        return "c/c++ 源文件(*.c *.cpp *.cxx *.m *.mm *.cc *.c++ *.cp);;c/c++ 头文件(*.txx *.tpp *.tpl *.h *.hpp);;";
    }
    bool setValue(@NotNilptr Project object, @NotNilptr Configure configure, @NotNilptr String key, @NotNilptr String value) override {
        switch(key){
            case "projname":
            return true;
            case "projtype":
                configure.setOption("command", value);
            break;
            case "icofile":
                object.setOption(key, value);
            break;
            case "projout":
                if (value.indexOf("$(Output)") != -1) {
                    return false;
                }
                configure.setOption("outpath", value);
            break;
            case "outfile":
                if (value.indexOf("$(Output)") != -1) {
                    return false;
                }
                configure.setOption("outname", value);
            break;
            case "libspath":
            configure.setOption("path.libpath", value);
            break;
            case "incspath":
            configure.setOption("path.incpath", value);
            break;
            case "arglist":
            configure.setOption("args", value);
            break;
            default:
            configure.setOption(key, value);
            break;
        }
        return true;
    }
    
    
    public String getValue(@NotNilptr Project object, @NotNilptr Configure configure,  @NotNilptr String key) override {
        switch(key){
            case "projname":
            return object.getName();
            case "projtype":
                return configure.getOption("command");
            break;
            case "icofile":
            return object.getOption(key);
            break;
            case "projout":
                return configure.getOption("outpath");
            break;
            case "outfile":
                return configure.getOption("outname");
            break;
            case "libspath":
                return configure.getOption("path.libpath");
            break;
            case "incspath":
                return configure.getOption("path.incpath");
            break;
            case "arglist":
                return configure.getOption("args");
            break;
            default:
            return configure.getOption(key);
            break;
        }
        return "";
    }
    
    public static String getDebuggeePath(@NotNilptr String kitname) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(kitname);
        if (jconfig != nilptr){
            text = jconfig.getString("dbg");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getDebuggeePath(@NotNilptr Configure configure) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            text = jconfig.getString("dbg");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getCompilerPath(@NotNilptr Configure configure) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            text = jconfig.getString("cc");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getMakePath(@NotNilptr Configure configure) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            text = jconfig.getString("make");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getMacros(@NotNilptr Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("macros");
        }
        return nilptr;
    }
    
    public @NotNilptr static String appendPath(@NotNilptr String first, @NotNilptr String append){
        return String.formatPath(first.appendPath(append), isUnixPath());
    }
    
    static bool isUnixPath(){
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            return Setting.isUnixPath();
        }
        return false;
    }
    
    public static JsonArray getCompilerSystemPath(@NotNilptr Configure configure) {
        JsonArray array = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            array = (JsonArray)jconfig.get("searchs");
        }
        if (array != nilptr && array.length() > 0){
            JsonArray jsarray = new JsonArray();
            bool bReslash = isUnixPath();
            try{
                for (int i = 0, c = array.length(); i < c; i++){
                    jsarray.put(String.formatPath(array.getString(i),bReslash));
                }
            }catch(Exception e){
                
            }
            array = jsarray;
        }
        return array;
    }
    
    public static String getDbgArgs(@NotNilptr Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("dbgparams");
        }
        return "";
    }
    
    public static String getLinkerPath(@NotNilptr Configure configure) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            text = jconfig.getString("ld");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getArPath(@NotNilptr Configure configure) {
        String text = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            text = jconfig.getString("ar");
        }
        if (text != nilptr && text.length() > 0){
            text = String.formatPath(text,isUnixPath());
        }
        return text;
    }
    
    public static String getCCArgs(@NotNilptr Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("ccparams");
        }
        return "";
    }
    
    public static String getLDArgs(@NotNilptr Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("ldparams");
        }
        return "";
    }
    
    public static String getArArgs(@NotNilptr Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("arparams");
        }
        return "";
    }
    
    public static void generateCCArgs(@NotNilptr Configure configure, @NotNilptr Vector<String> sourceArgs) {
        String cmd = getCCArgs(configure);
        if (cmd != nilptr){
            processArgs(cmd, sourceArgs);
        }
    }
    
    public static void generateLDArgs(@NotNilptr Configure configure, @NotNilptr Vector<String> sourceArgs) {
        String cmd = getLDArgs(configure);
        if (cmd != nilptr){
            processArgs(cmd, sourceArgs);
        }
    }
    
    public static void jarray2Args(@NotNilptr String cmd, @NotNilptr Vector<String> sourceArgs){
        try{
            JsonArray jary = new JsonArray(cmd);
            for (int i =0, c = jary.length(); i < c; i++){
                sourceArgs.add(jary.getString(i));
            }
        }catch(Exception e){
            
        }
    }
    
    public static void generateCommand(@NotNilptr Configure configure, @NotNilptr Vector<String> sourceArgs) {
        String cmd = configure.getOption("otheroptions");
        jarray2Args(cmd, sourceArgs);
    }
    
    public static void processArgs(@NotNilptr String args, @NotNilptr Vector<String> args_list) {
        byte []data = args.getBytes();

        int start = 0;
        bool inline = false;

        for (int i = 0; i < data.length; i++) {
            if (data[i] == '"') {
                inline = !inline;
            }
            if (inline == false) {
                if (data[i] == ' ' || data[i] == '\r' || data[i] == '\n' || data[i] == '\t' ) {
                    data[i] = ' ';
                    if (i > start){
                        args_list.add(new String(data, start, i - start));
                    }
                    start = i + 1;
                }
            }
        }

        if (start < data.length) {
            String arg = new String(data, start, data.length - start);
            args_list.add(arg);
        }

    }
    
    public static void generateLinkerCommand(@NotNilptr Configure configure, @NotNilptr Vector<String> sourceArgs) {
        String cmd = configure.getOption("otherlinkoptions");
        jarray2Args(cmd, sourceArgs);
    }
    
    public @NotNilptr Vector<String> getSourceArgs(IBuilder builder, @NotNilptr Project object, @NotNilptr Configure configure, String workDir, Vector<String> extlist) {
        Vector<String> sourceArgs = new Vector<String>();

        JsonArray sources = object.getSources();
        
        if (sources != nilptr){
            Map<String, bool> ext_map = nilptr;
            if (extlist != nilptr){
                ext_map = new Map<String, bool>();
            }
            for (int i = 0, c = sources.length(); i < c; i++) {
                String srcname = sources.getString(i);
                
                if (srcname != nilptr){
                    String ext = srcname.findExtension();
                    String fname = srcname.findFilenameAndExtension();
                    
                    String fullsourcePath ;
                    if (workDir != nilptr){
                        fullsourcePath = appendPath(workDir, srcname);
                    }else{
                        fullsourcePath = srcname;
                    }
                    
                    if (fname.equalsIgnoreCase("makefile") && builder != nilptr && workDir != nilptr) {
                        XlangProjectProp.makefile(builder, object, configure, workDir);
                    }
                    if ((ext.equalsIgnoreCase(".c") || ext.equalsIgnoreCase(".cpp") || ext.equalsIgnoreCase(".cxx") || ext.equalsIgnoreCase(".m") || 
                        ext.equalsIgnoreCase(".mm") || ext.equalsIgnoreCase(".cc") || ext.equalsIgnoreCase(".c++") || ext.equalsIgnoreCase(".cp") || ext.equalsIgnoreCase(".txx") || 
                        ext.equalsIgnoreCase(".tpp") || ext.equalsIgnoreCase(".tpl"))) 
                    {
                        sourceArgs.add(fullsourcePath);
                        
                        if (extlist != nilptr){
                            String uext = ext.upper();
                            if (ext_map != nilptr && ext_map.containsKey(uext) == false){
                                ext_map.put(uext,true);
                                extlist.add(ext);
                            }
                        }
                    }
                }
            }
        }
        return sourceArgs;
    }
    
    public String getArchArgs(@NotNilptr Configure configure) {
        return "";
    }
    
    public IXIntelliSense allocIntelliSense(@NotNilptr Project project, @NotNilptr Configure cfg)override{
        return new ClangIXIntelliSense(project, cfg);
    }
    
    public static void generateJsonArrayArgs(String key, JsonArray incpath,@NotNilptr  Vector<String> args, bool quot) {
        if (incpath != nilptr) {
            //String incs = "";
            bool isReslash = isUnixPath();
            for (int i = 0, c = incpath.length(); i < c; i++) {
                String inc = incpath.getString(i);
                
                if (inc != nilptr && inc.length() > 0) {
                    
                    if (inc.length() > 0){
                        if (key != nilptr){
                            args.add(key);
                        }
                        if (quot && _system_.getPlatformId() == 0) {
                            args.add("\"" + inc + "\"");
                        } else {
                            args.add(inc);
                        }
                    }
                }
            }
        }
    }
    
    public static void checkOptions(Vector<String> args, Map<String,String> argmap,@NotNilptr  Configure configure, @NotNilptr String []key) {
        for (int i =0; i < key.length; i++) {
            String option = configure.getOption(key[i]);

            if (option.length() > 0) {
                if (args != nilptr) {
                    args.add(option);
                }
                if (argmap != nilptr) {
                    argmap.put(key[i], option);
                }

            }
        }
    }
    
    public static void generateWarning(@NotNilptr Configure configure, @NotNilptr Vector<String> args) {
        JsonArray ignorewl = getArrayOption(configure, "ignorewl");
        if (ignorewl != nilptr) {
            generateJsonArrayArgs(nilptr, ignorewl, args, false);
        }
    }
    
    public static void generateIncPath(@NotNilptr Configure configure, @NotNilptr Vector<String> args) {
        JsonArray libpath = getArrayOption(configure, "path.incpath");
        if (libpath != nilptr) {
            generateJsonArrayArgs("-I", libpath, args, true);
        }
    }
    
    public static void generateLibPath(@NotNilptr Configure configure, @NotNilptr Vector<String> args) {
        JsonArray libpath = getArrayOption(configure, "path.libpath");
        if (libpath != nilptr) {
            generateJsonArrayArgs("-L", libpath, args, true);
        }
    }
    
    
    public @NotNilptr static String [] generatorCompArgs_s(@NotNilptr Project object,@NotNilptr  Configure configure,@NotNilptr  String sourfile, bool forlsp){
        Vector<String> args = new Vector<String>();
        String ccpath = getCompilerPath(configure);
        
        args.add("%cc%");
        
        String ife = ".o";
        
        String comp_sec = configure.getOption("genasm");
        if (forlsp == false && comp_sec.equals("-S")){
            args.add("-S");
            ife = ".S";
        }else if (forlsp == false && comp_sec.equals("-E")){
            args.add("-E");
            ife = ".E";
        }else{
            args.add("-c");
            if (_system_.getPlatformId() == 0){
                ife = ".obj";
            }
        }
        
        args.add("%source%");
        // "staticlibgcc", "staticlibcpp",
        String []options = {"optimize", "gprofile", "fsanitize", "fundefined", "fdatarace", "fshift", "fsignedio", "fbounds", "funreachable", "freturn", "dbits", "noexceptions", "ignorew", "debugable", "ostype", "fpic", "signed_char", "nostdinc", "nostdincpp", "cpp11", "cstd11", "eversose", "fvisibility",
            "march", "gccansi", "gccffp", "mfloat", "codealign", "Wshadow", "instructoptimize", "nobuiltin", "enumint", "stackprotected"
        };

        checkOptions(args, nilptr, configure, options);

        //路径变量
        generateWarning(configure, args);

        //路径变量
        generateIncPath(configure, args);


        generateCCArgs(configure, args);
        
        
        generateCommand(configure, args);
        //外部库
        //generateLibs(configure, args);

        args.add("-o");

        args.add("%dest%");
           
        String [] szArgs = new String[args.size()];

        for (int i = 0; i < args.size(); i++) {
            szArgs[i] = XPlatform.converToPlatformCharSet(XEnvironment.MapVariable(object, configure, args.get(i)));
        }
                
        String projdir = object.getProjectDir();
        String out_path = configure.getOption("objdir");
        out_path = String.formatPath(XEnvironment.MapVariable(object, configure, out_path), isUnixPath());
        String destfile = sourfile.toRelativePath(projdir,false,true);
        destfile = destfile.toAbsolutePath(out_path);
            
        destfile = destfile.replaceExtension(ife);
        
        if (_system_.getPlatformId() == 0){
            szArgs[0] = "\""  + ccpath + "\"";
            szArgs[2] = "\""  + sourfile + "\"";
            szArgs[szArgs.length - 1] = "\"" + destfile + "\"";
        }else{
            szArgs[0] = ccpath;
            szArgs[2] = sourfile;
            szArgs[szArgs.length - 1] = destfile;
        }
        
        return szArgs;
    }
    
    public String [] generatorCompArgs(@NotNilptr Project object, @NotNilptr Configure configure, @NotNilptr String sourfile)override{
        return generatorCompArgs_s(object, configure, sourfile, true);
    }
    
    
    int nBuildCancel = 0;//0 没有取消  1已设定取消  2已取消
    
    
    public void clearObjectFile(@NotNilptr IBuilder builder,@NotNilptr  Project object,@NotNilptr  Configure configure){
    
        String projdir = object.getProjectDir();
        
        Vector<String> __args = getSourceArgs(nilptr, object, configure, projdir, nilptr);
        
        String out_path = configure.getOption("objdir");
        
        out_path = String.formatPath(XEnvironment.MapVariable(object, configure, out_path), isUnixPath());
        
        for (int i = 0; i < __args.size(); i++) {
            String sourfile = __args.get(i);
            __nilptr_safe(sourfile);
            String destfile = sourfile.toRelativePath(projdir,false,true);
            destfile = String.formatPath(destfile.toAbsolutePath(out_path), isUnixPath());
            destfile = destfile.replaceExtension(".o");
            
            if (XPlatform.existsSystemFile(destfile)) {
                if (false == XPlatform.deleteFile(destfile)) {
                    builder.OutputText("无法删除文件:" + destfile + " ,文件正在使用中\n", 0);
                }else{
                    builder.OutputText("" + destfile + "..\n", 0);
                }
            }
        }
    }
    
    public void generateBuildArgs(@NotNilptr IBuilder builder,@NotNilptr Vector<String> __args,@NotNilptr Project object,@NotNilptr  Configure configure,@NotNilptr  String workdir) {
    
        String target = getTarget(object, configure);
        
        if (target != nilptr && XPlatform.existsSystemFile(target)) {
            if (false == XPlatform.deleteFile(target)) {
                builder.OutputText("无法删除文件:" + target + " ,文件正在使用中\n", 0);
                return ;
            }
        }
        
        Vector<String> args = new Vector<String>();

        Vector<String> objfiles = new Vector<String>();
        
        String ccpath = getCompilerPath(configure);
        
        String cmd = configure.getOption("command");
        
        if (cmd.length() == 0){
            builder.OutputText("未配置项目类型, 请在 [项目属性] 页面配置项目类型.", 0);
            return ;
        }
        if (ccpath == nilptr){
            builder.OutputText("未配置编译器, 请在 [项目属性] 页面配置编译套件, 或前往 [工具]->[C/C++设置] 配置编译器.", 0);
            return ;
        }
        
        args.add("%cc%");
        
        
        String ife = ".o";
        int comp_method = 0;
        
        String comp_sec = configure.getOption("genasm");
        if (comp_sec.equals("-S")){
            args.add("-S");
            ife = ".S";
            comp_method = 1;
        }else if (comp_sec.equals("-E")){
            args.add("-E");
            ife = "$";
            comp_method = 2;
        }else{
            args.add("-c");
            if (_system_.getPlatformId() == 0){
                ife = ".obj";
            }
        }
        
        args.add("%source%");
        // "staticlibgcc", "staticlibcpp",
        String []options = {"optimize", "gprofile", "fsanitize", "fundefined", "fdatarace", "fshift", "fsignedio", "fbounds", "funreachable", "freturn", "dbits", "noexceptions", "ignorew", "debugable", "ostype", "fpic", "signed_char", "nostdinc", "nostdincpp", "cpp11", "cstd11", "eversose", "fvisibility",
            "march", "gccansi", "gccffp", "mfloat", "codealign", "Wshadow", "instructoptimize", "nobuiltin", "enumint", "stackprotected"
        };
        
        checkOptions(args, nilptr, configure, options);

        //路径变量
        generateWarning(configure, args);

        //路径变量
        generateIncPath(configure, args);


        generateCCArgs(configure, args);
        
        
        generateCommand(configure, args);
        //外部库
        //generateLibs(configure, args);

        args.add("-o");

        args.add("%dest%");
           
        String [] szArgs = new String[args.size()];

        for (int i = 0; i < args.size(); i++) {
            szArgs[i] = XPlatform.converToPlatformCharSet(XEnvironment.MapVariable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        String projdir = object.getProjectDir();
        String out_path = configure.getOption("objdir");
        out_path = String.formatPath(XEnvironment.MapVariable(object, configure, out_path), isUnixPath());
        bool bReslash = isUnixPath();
        
        for (int i = 0; i < __args.size(); i++) {
           
            String sourfile = __args.get(i);
            __nilptr_safe(sourfile);
            String destfile = sourfile.toRelativePath(projdir,false,true);
            
            sourfile = String.formatPath(sourfile, bReslash);
            destfile = String.formatPath(destfile.toAbsolutePath(out_path), bReslash);
            
            XlangProjectProp.mkdirs(String.formatPath(destfile.findVolumePath(), false));
            
            destfile = destfile.replaceExtension(ife);
            
            if (_system_.getPlatformId() == 0){
                objfiles.add(destfile);
                szArgs[0] = "\""  + ccpath + "\"";
                szArgs[2] = "\""  + sourfile + "\"";
                szArgs[szArgs.length - 1] = "\"" + destfile + "\"";
            }else{
                objfiles.add(destfile);
                szArgs[0] = ccpath;
                szArgs[2] = sourfile;
                szArgs[szArgs.length - 1] = destfile;
            }
            
            CDEProjectPropInterface.setEnvir(ccpath);
            /*String wd = ccpath.findVolumePath();
            if (wd == nilptr){
                wd = workdir;
            }*/
            allInfo = allInfo + builder.build(ccpath, szArgs,  workdir, nilptr, false);
            
            int start = allInfo.length() - 1;
            
            if (start > 0){
                int n = allInfo.lastIndexOf('\n', start);
                
                while (n + 1 == allInfo.length() || allInfo.charAt(n + 1) == ' '){
                    if (n > 0){
                        start = n - 1;
                        n = allInfo.lastIndexOf('\n', start);
                    }else{
                        n = -1;
                        break;
                    }
                }
                if (n != -1){
                    String compmsg = allInfo.substring(0, n);
                    allInfo = allInfo.substring(n + 1,allInfo.length());
                    builder.setCompileInfor(parseInfo(compmsg));
                }
            }
            
            if (nBuildCancel != 0){
                if (nBuildCancel == 1){
                    nBuildCancel = 2;
                    builder.OutputText("\n已取消组建\n", 0);
                }
                break;
            }
        }
        
        builder.setCompileInfor(parseInfo(allInfo));
        
        if (nBuildCancel == 0){
            builder.OutputText("\n链接...\n",1);
            //ExecuteLinkLib
            if (comp_method == 0){
                if (cmd.equals("-staticlib")){
                    ExecuteLinkLib(builder, objfiles, object, configure, workdir);
                }else{
                    ExecuteLinker(builder, objfiles, object, configure, workdir);
                }
            }
            
            builder.complete();
        }
        
    }
    
    public static JsonArray getArrayOption(@NotNilptr Configure configure,@NotNilptr  String key){
        try{
            String szlibs = configure.getOption(key);
            return new JsonArray(szlibs);
            
        }catch(Exception e){
            
        }
        return nilptr;
    }
    
    public JsonArray getExternLibs(@NotNilptr Configure cfg){
        return getArrayOption(cfg, "libs");
    }
    
    public void generateLibs(@NotNilptr Configure configure, @NotNilptr Vector<String> args) {
        JsonArray libs = getArrayOption(configure, "libs");
        generateJsonArrayArgs(nilptr, libs, args, true);
    }
    
    
    public static String getTarget(@NotNilptr Project object, @NotNilptr Configure configure) {
        String out_path = XEnvironment.MapVariable(object, configure, "$(Output)");
        return String.formatPath(out_path, isUnixPath());
    }
    
    public void ExecuteLinkLib(@NotNilptr IBuilder builder,@NotNilptr Vector<String> __args, @NotNilptr Project object, @NotNilptr Configure configure, @NotNilptr String workdir) {
    
        Vector<String> args = new Vector<String>();
        
        String ldpath = getArPath(configure);
        if (ldpath == nilptr){
            builder.OutputText("未配置归档器, 请在[项目属性] 页面配置编译套件, 或前往[工具]->[C/C++设置]中配置链接器", 0);
            return;
        }
        
        if (_system_.getPlatformId() == 0) { /* windows */
            args.add("\"" + ldpath + "\"");
        } else {
            args.add(ldpath);
        }
        
        args.add("rcs");
        // "staticlibgcc", "staticlibcpp",

        generateLDArgs(configure, args);
        
        String out_path = configure.getOption("outpath");
        
        out_path = String.formatPath(XEnvironment.MapVariable(object, configure, out_path), isUnixPath());
        
        if (out_path.length() > 0){
            XlangProjectProp.mkdirs(out_path);
        }

        String dest = appendPath(out_path, configure.getOption("outname"));
        
        if (_system_.getPlatformId() == 0) { /* windows */
            args.add("\"" + dest + "\"");
        } else {
            args.add(dest);
        }
        
        for (int i = 0; i < __args.size(); i++) {
            String objf = __args.get(i);
            if (_system_.getPlatformId() == 0){
                args.add("\"" + objf + "\"" );
            }else{
                args.add(objf);
            }
        }
        
        String [] szArgs = new String[args.size()];
        
        for (int i = 0; i < args.size(); i++) {
            szArgs[i] = XPlatform.converToPlatformCharSet(XEnvironment.MapVariable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        allInfo = allInfo + builder.build(ldpath, szArgs, workdir, nilptr, false);
        
        builder.setCompileInfor(parseInfo(allInfo));
    }
    
    public void ExecuteLinker(@NotNilptr IBuilder builder,@NotNilptr Vector<String> __args,@NotNilptr  Project object,@NotNilptr  Configure configure, String workdir) {
    
        Vector<String> args = new Vector<String>();
        
        String ldpath = getLinkerPath(configure);
        if (ldpath == nilptr){
            builder.OutputText("未配置链接器, 请在[项目属性] 页面配置编译套件, 或前往[工具]->[C/C++设置]中配置链接器", 0);
            return;
        }
        if (_system_.getPlatformId() == 0) { /* windows */
            args.add("\"" + ldpath + "\"");
        } else {
            args.add(ldpath);
        }
        
        // "staticlibgcc", "staticlibcpp",
        String []options = {"wl_ld_v", "optimize", "gprofile", "fsanitize", "fundefined", "fdatarace", "fshift", "fsignedio", "fbounds", "funreachable", "freturn", "dbits", "noexceptions", "ignorew", "fpic", "pie", "debugable", "ostype", "compdest", "nostdlib", "staticlibcpp", "staticlibgcc", "staticlink","ldsymbols", "noinhibitexec", "ldformat", 
            "wl_ld_zdefs", "wl_ld_muldefs", "wholearchive"
        };
        
        checkOptions(args, nilptr, configure, options);
        
        for (int i =0; i < args.size(); i++){
            if (args[i].startWith("-fsanitize=")){
                args.add("-static-libasan");
                break;
            }
        }
        
        for (int i = 0; i < __args.size(); i++) {
            String objf = __args.get(i);
            if (_system_.getPlatformId() == 0){
                args.add("\"" + objf + "\"" );
            }else{
                args.add(objf);
            }
        }
        
        //路径变量
        generateWarning(configure, args);
        //路径变量
        generateLibPath(configure, args);

        //C++ Setting 
        generateLDArgs(configure, args);
        
        //外部库
        generateLibs(configure, args);

        // other cmds
        generateLinkerCommand(configure, args);

        String speclds = configure.getOption("speclds");
        
        if (speclds.length() > 0){
            args.add("-Wl,-T");
            args.add(speclds);
        }
        
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            String sstype = configure.getOption("sstype");
            
            if (sstype.equals("-mwindows")){
                args.add("-mwindows");
            }
        }
        
        String ptype = configure.getOption("command");
        if (ptype.equals("-shared")){
            args.add("-shared");
        }
        
        args.add("-o");

        String out_path = configure.getOption("outpath");
        
        out_path = String.formatPath(XEnvironment.MapVariable(object, configure, out_path), isUnixPath());
        
        if (out_path.length() > 0){
            XlangProjectProp.mkdirs(out_path);
        }

        if (_system_.getPlatformId() == 0) { /* windows */
            args.add("\"" + appendPath(out_path, configure.getOption("outname")) + "\"");
        } else {
            args.add(appendPath(out_path, configure.getOption("outname")));
        }
        
        
        String [] szArgs = new String[args.size()];
        
        for (int i = 0; i < args.size(); i++) {
            szArgs[i] = XPlatform.converToPlatformCharSet(XEnvironment.MapVariable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        allInfo = allInfo + builder.build(ldpath, szArgs, workdir, nilptr, false);
        
        builder.setCompileInfor(parseInfo(allInfo));
           
    }
    
    public bool verifyFileContent(@NotNilptr String file, @NotNilptr String content){
        try{
            FileInputStream fis = new FileInputStream(file);
            byte [] data = fis.read();
            fis.close();
            return new String(data).equals(content);
        }catch(Exception e){
        }
        return false;
    }
    
    public bool writeFileContent(@NotNilptr String file,@NotNilptr  String content){
        if (verifyFileContent(file, content) == false){
            try{
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(content.getBytes());
                fos.close();
            }catch(Exception e){
                return false;
            }
        }
        return true;
    }
    
    public static void setEnvir(String gdbPath){
        if (gdbPath != nilptr){
            String envLInk = _system_.getPlatformId() == _system_.PLATFORM_WINDOWS ? ";" : ":";
            String path = EnvironmentMgr.getEnvironmentPath();
            if (path != nilptr){
                String gdbDir = gdbPath.findVolumePath();
                if (gdbDir.length() > 0){
                    String gdbDirprt = gdbDir.findVolumePath();
                    if (gdbDirprt.length() > 0){
                        path = gdbDirprt + envLInk + path;
                    }
                    path = gdbDir + envLInk + path;
                }
                path =  "." + envLInk + path;
                _system_.setEnvironmentVariable("path", path, false, false);
            }
        }
    }
    
    bool cleanByMake(@NotNilptr IBuilder builder,@NotNilptr  Project object,@NotNilptr  Configure configure, Object param)  {
        String makecont = generateMake(object, configure);
        
        String projectdir = object.getProjectDir();

        String makefile = appendPath(projectdir, "Makefile");
        
        if (writeFileContent(makefile, makecont) == false){
            builder.OutputText("无法写入文件:" + makefile,0);
            return false;
        }
        
        String makepath = getMakePath(configure);
        if (makepath == nilptr || makepath.length() == 0){
            builder.OutputText("未设置make程序路径或编译套件.",0);
            return false;
        }
        makepath = makepath + " clean";
        Vector<String> args_list = new Vector<String>();
     
        String execute = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            processArgs(makepath, args_list);

            String make = args_list[0];
            __nilptr_safe(make);
            if (make.startWith("\"" ) && make.endWith("\"" )){
                make = make.substring(1, make.length() - 1);
            }

            String batch = "@echo off\nset PATH=\""  +  make.findVolumePath() + "\";%PATH%\n@echo on\n" + makepath;
            String batchfile = appendPath(projectdir, "clean.cmd");
            
            if (writeFileContent(batchfile, batch) == false){
                builder.OutputText("无法写入文件:" + batchfile,0);
                return false;
            }
                   
            args_list.clear();
            args_list.add("cmd");
            args_list.add("/c");
            args_list.add("\""  + batchfile + "\"");
            execute = XKernel32.getWindowsDir(); 
            if (execute == nilptr) {
                builder.OutputText("无法获取 cmd 路径.",0);
                return false;
            }
            execute = appendPath(execute, "system32\\cmd.exe");
        }else{
            processArgs(makepath, args_list);
            execute = args_list[0];
        }
         
            
        if (args_list.size() > 0){    
            InformationParser ip = new InformationParser(){
                String parse(@NotNilptr String text)override{
                    if (text.length() > 1){
                        int pos = text.lastIndexOf('\n', text.length() - 1);
                        if (pos != -1){
                            String lastline = text.substring(pos, text.length());
                            if (lastline.equals(lastline.ltrim(true))){
                                builder.setCompileInfor(parseInfo(text.substring(0, pos)));
                                return lastline;
                            }
                        }
                    }
                    return text;
                }
            };
            
            String text = builder.build(execute, args_list.toArray(new String[0]), object.getProjectDir(), ip, true);
            
            if (text != nilptr){
                builder.setCompileInfor(parseInfo(text));
            }
            builder.complete();
            
            return true;
        }
        builder.OutputText("make无效",0);
        return false;
    }
     
    bool buildByMake(@NotNilptr IBuilder builder, @NotNilptr Project object, @NotNilptr Configure configure, Object param)  {
        String makecont = generateMake(object, configure);
        String projectdir = object.getProjectDir();



        String makefile = appendPath(projectdir, "Makefile");
        
        if (writeFileContent(makefile, makecont) == false){
            builder.OutputText("无法写入文件:" + makefile,0);
            return false;
        }
        
        String makepath = getMakePath(configure);
        if (makepath == nilptr || makepath.length() == 0){
            builder.OutputText("未设置make程序路径或编译套件.",0);
            return false;
        }
        
        Vector<String> args_list = new Vector<String>();

        String execute = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            processArgs(makepath, args_list);

            String make = args_list[0]; __nilptr_safe(make);
            if (make.startWith("\"" ) && make.endWith("\"" )){
                make = make.substring(1, make.length() - 1);
            }

            String batch = "@echo off\nset PATH=\""  +  make.findVolumePath() + "\";%PATH%\n@echo on\n" + makepath;
            String batchfile = appendPath(projectdir, "build.cmd");
            
            if (writeFileContent(batchfile, batch) == false){
                builder.OutputText("无法写入文件:" + batchfile,0);
                return false;
            }
                   
            args_list.clear();
            args_list.add("cmd");
            args_list.add("/c");
            args_list.add("\""  + batchfile + "\"");
            execute = XKernel32.getWindowsDir(); 
            if (execute == nilptr) {
                builder.OutputText("无法获取 cmd 路径.",0);
                return false;
            }
            execute = appendPath(execute, "system32\\cmd.exe");
        }else{
            processArgs(makepath, args_list);
            execute = args_list[0];
        }
            
        if (args_list.size() > 0){    
            InformationParser ip = new InformationParser(){
                String parse(@NotNilptr String text)override{
                    if (text.length() > 1){
                        int pos = text.lastIndexOf('\n', text.length() - 1);
                        if (pos != -1){
                            String lastline = text.substring(pos, text.length());
                            if (lastline.equals(lastline.ltrim(true))){
                                builder.setCompileInfor(parseInfo(text.substring(0, pos)));
                                return lastline;
                            }
                        }
                    }
                    return text;
                }
            };
            int thread = CPPGPlugManager.getMultiMake();
            if (thread > 1){
                args_list.add("-j" + thread);
            }
            
            String text = builder.build(execute, args_list.toArray(new String[0]), projectdir, ip, true);
            
            if (text != nilptr){
                builder.setCompileInfor(parseInfo(text));
            }
            if (nBuildCancel != 0){
                if (nBuildCancel == 1){
                    nBuildCancel = 2;
                    builder.OutputText("\n已取消组建\n", 0);
                }
            }
            builder.complete();
            
            return true;
        }
        builder.OutputText("make无效",0);
        return false;
    }
    
    bool build(@NotNilptr IBuilder builder, @NotNilptr Project object, @NotNilptr Configure configure, Object param) override {
        nBuildCancel = 0;
        String target = getTarget(object, configure);

        if (target != nilptr && XPlatform.existsSystemFile(target)) {
            if (false == XPlatform.deleteFile(target)) {
                builder.OutputText("无法删除文件:" + target + " ,文件正在使用中\n", 0);
                return false;
            }
        }

        String cmd = configure.getOption("command");
        String usemake = configure.getOption("usemake");
        if (usemake.length() > 0 || cmd.equals("-driver")){
            return buildByMake(builder, object, configure, param);
        }
        
        XlangProjectProp.batchbuild(builder, object, configure, "prebuild");

        String workdir = object.projpath.findVolumePath();
        
        
        
        Vector<String> _args = getSourceArgs(builder, object, configure, workdir, nilptr);

        if (configure == nilptr) {
            Map<String, Configure> conf_map = object.configures; __nilptr_safe(conf_map);
            Map.Iterator<String, Configure> iter = conf_map.iterator();

            while (iter.hasNext()) {
                Configure conf = iter.getValue();
                __nilptr_safe(conf);
                generateBuildArgs(builder, _args, object, conf, workdir);
                if (nBuildCancel != 0){
                    if (nBuildCancel == 1){
                        nBuildCancel = 2;
                        builder.OutputText("\n已取消组建\n", 0);
                    }
                    break;
                }
                iter.next();
            }
        } else {
            generateBuildArgs(builder, _args, object, configure, workdir);
        }

        if (nBuildCancel == 0){
            XlangProjectProp.batchbuild(builder, object, configure, "afterbuild");
        }
                
        return true;
    }
    
    int detectInfo(@NotNilptr String lineText) {
        String [] prefix = {": 附注", ": 警告", ": 错误"};
        String [] prefix_en = {": note", ": warning", ": error", ": fatal error"};
        if (lineText.length() < prefix[0].length()){
            return -1;
        }
        for (int i =0; i < prefix.length; i++){
            if (lineText.indexOf(prefix[i],0) != -1){
                return i;
            }
        }
        for (int i =0; i < prefix_en.length; i++){
            if (lineText.indexOf(prefix_en[i],0) != -1){
                if (i > 2){
                    i = 2;
                }
                return i;
            }
        }
        return -1;
    }
    
    static class CPPCompileInfo : ICompileInfo {
        public String file;
        public int line;
        public int row;
        public int type;
        public String tip;
        public CPPCompileInfo(){
            
        }
        public CPPCompileInfo(String f, int l,int r, String i) {
            file = f;
            line = l;
            row = r;
            tip = i;
        }

        public CPPCompileInfo(String text, int t, String _tips) {
            type = t;
            tip = _tips;
        }

        public int getType()override {
            return type;
        }
        public String getFile()override {
            return file;
        }
        public int getLine()override {
            return line;
        }
        public int getRow()override {
            return row;
        }
        public @NotNilptr String getTips() {
            __nilptr_safe(tip);
            if (tip == nilptr){
                return "";
            }
            return tip;
        }
    };
    
    @NotNilptr Vector<ICompileInfo> parseInfo(@NotNilptr String info) {
        Vector<ICompileInfo> infos = new Vector<ICompileInfo>();
        String [] list = info.split("\n");
        for (int i = 0; i < list.length; i++) {
            String message = list[i].trim(true);
            int t = detectInfo(message);
            if (t != -1) {
                String tips_block = message;
                i++;
                for (; i < list.length; i++) {
                    if (list[i].startWith(" ")) {
                        tips_block = tips_block + "\n" + list[i];
                    } else {
                        i--;
                        break;
                    }
                }
                CPPCompileInfo ccinfo = (CPPCompileInfo)parseInformation(message); __nilptr_safe(ccinfo);
                ccinfo.tip = tips_block;
                infos.add(ccinfo);
            }
        }
        return infos;
    }
    
    static String getArch(@NotNilptr Configure configure) {
        String [] archs = {"i386", "i686", "x86_64", "armv7-a", "armv8-a"};

        String arch = "";
        if (arch.equals("")) {
            int aid = _system_.getArchId();

            if (aid < 0 || aid > 5) {
                aid = 0;
            }
            return archs[aid];

        } else {
            int pos = arch.indexOf('=');
            if (pos != -1){
                return arch.substring(pos + 1,arch.length());
            }
            return arch;
        }
    }
    
    public @NotNilptr String map_variable(@NotNilptr Project object, @NotNilptr Configure configure,@NotNilptr  String text) override{
        text = text.replace("$(Output)", appendPath(configure.getOption("outpath"), configure.getOption("outname")));
        text = text.replace("$(IntermediateFolder)", configure.getOption("objdir"));
        text = text.replace("$(Configure)", configure.getName());
        text = text.replace("$(Arch)", getArch(configure));
        
        String ptype = configure.getOption("command");
        String ostype = configure.getOption("ostype");

        String ext = "";

        if (ptype.equals("-execute")) {
            if ((ostype.length() == 0 && _system_.getPlatformId() == 0) || ostype.equalsIgnoreCase("-xcross-windows")) {
                ext = ".exe";
            }
        } else if (ptype.equals("-shared")) {
            if ((ostype.length() == 0 && _system_.getPlatformId() == 0) || ostype.equalsIgnoreCase("-xcross-windows")) {
                ext = ".dll";
            }else
            if ((ostype.length() == 0 && _system_.getPlatformId() == 1) || ostype.equalsIgnoreCase("-xcross-linux")) {
                ext = ".so";
            }else
            if ((ostype.length() == 0 && _system_.getPlatformId() == 2) || ostype.equalsIgnoreCase("-xcross-darwin")) {
                ext = ".dylib";
            }
        } else if (ptype.equals("-staticlib")) {
            if ((ostype.length() == 0 && _system_.getPlatformId() == 0) || ostype.equalsIgnoreCase("-xcross-windows")) {
                ext = ".lib";
            }else{
                ext = ".a";
            }
        }  else if (ptype.equals("-driver")) {
            if ((ostype.length() == 0 && _system_.getPlatformId() == 0) || ostype.equalsIgnoreCase("-xcross-windows")) {
                ext = ".sys";
            }else{
                ext = ".ko";
            }
        }
        
        text = text.replace("$(Ext)", ext);

        return (text);
    }
    
    
    int XDEBUG_SERIAL = 0;
    
    int getDebugSerial() {
        if (XDEBUG_SERIAL == 0) {
            XDEBUG_SERIAL = Process.getId() * 99;
        } else {
            XDEBUG_SERIAL++;
        }
        return XDEBUG_SERIAL;
    }
    
    void cleanup(@NotNilptr IBuilder builder, @NotNilptr Project object, @NotNilptr Configure configure) override {
        nBuildCancel = 0;
        String target = getTarget(object, configure);

        if (target != nilptr && XPlatform.existsSystemFile(target)) {
            if (false == XPlatform.deleteFile(target)) {
                builder.OutputText("无法删除文件:" + target + " ,文件正在使用中\n", 0);
            }
        }

        String cmd = configure.getOption("command");
        String usemake = configure.getOption("usemake");
        if (usemake.length() > 0 || cmd.equals("-driver")){
            cleanByMake(builder, object, configure, nilptr);
        }else{
            clearObjectFile(builder, object, configure);
        }
    }
    
    String getExecuteCmd(@NotNilptr Project object, @NotNilptr Configure configure) {
        String out_path = configure.getOption("cmd");
        out_path = XEnvironment.MapVariable(object, configure, out_path);
        return String.formatPath(out_path, isUnixPath());
    }
    
    @NotNilptr Vector<String> getExecuteArgs(@NotNilptr Project object,@NotNilptr  Configure configure) {

        String out_path = configure.getOption("args");
        Vector<String> argve = XlangProjectProp.processArgs(out_path);

        Vector<String> finalargs = new Vector<String>();
        bool bisUnixPath = isUnixPath();
        for (int i =0; i < argve.size(); i++) {
            finalargs.add(XlangProjectProp.formatArgs(String.formatPath(XEnvironment.MapVariable(object, configure, argve.get(i)), bisUnixPath)));
        }

        return finalargs;
    }
    
    @NotNilptr String getExecuteWd(@NotNilptr Project object,@NotNilptr  Configure configure) {
        String out_path = configure.getOption("workdir");
        out_path = XEnvironment.MapVariable(object, configure, out_path);
        return String.formatPath(out_path, false);
    }
    
    Process process ;
    GDBShell dbg_shell;
    
    public GDBShell getGdb(){
        return dbg_shell;
    }
    
    public void attachDebug(@NotNilptr String kitname, int pid){
        String dbgpath = getDebuggeePath(kitname);
        
        if (dbgpath != nilptr){
            String []args__ = new String[4];
            if (_system_.getPlatformId() == 0){
                args__[0] = "\"" + XPlatform.converToPlatformCharSet(dbgpath) + "\"";
            }else{
                args__[0] = XPlatform.converToPlatformCharSet(dbgpath);
            }
            args__[1] = "--interpreter=mi2";
            args__[2] = "-quiet";
            args__[3] = "--nx";
            
            GDBShell _gdb = new GDBShell();
            if (_gdb.prepareForPipe() == false){
                CPPGPlugManager.output("\n无法创建调试端口!\n", 1);
                return ;
            } 
            
            Process dbg_pro = _gdb.createProcess(XPlatform.converToPlatformCharSet(dbgpath), args__, nilptr);
            
            dbg_shell = _gdb;
            
            if (dbg_pro != nilptr && XWorkspace.workspace.requestDebug(_gdb.getPipe())){
                String [] dbg_arg = {"" + pid};
                if (_gdb.attachProcess(dbg_arg)) {
                    CPPGPlugManager.output("\n已创建进程 ID: " + dbg_pro.id() + "\n", 0);
                    dbg_pro.waitFor(-1);
                    CPPGPlugManager.output("\n退出代码: " + dbg_pro.getExitCode() + "\n", 0);
                } else {
                    CPPGPlugManager.output("\n运行失败.\n", 0);
                }
            }
            dbg_shell = nilptr;
        }
    }
    
    public void remoteDebug(@NotNilptr String kitname, String host, int port, String exePath){
        String dbgpath = getDebuggeePath(kitname);
        if (dbgpath != nilptr){
            String []args__ = new String[5];
            if (_system_.getPlatformId() == 0){
                args__[0] = "\"" + XPlatform.converToPlatformCharSet(dbgpath) + "\"";
            }else{
                args__[0] = XPlatform.converToPlatformCharSet(dbgpath);
            }
            args__[1] = "--interpreter=mi2";
            if (_system_.getPlatformId() == 0){
                args__[2] = "\"" + (exePath) + "\"";
            }else{
                args__[2] = (exePath);
            }
            args__[3] = "-quiet";
            args__[4] = "--nx";
            
            GDBShell _gdb = new GDBShell();
            if (_gdb.prepareForPipe() == false){
                CPPGPlugManager.output("\n无法创建调试端口!\n", 1);
                return ;
            } 
            dbg_shell = _gdb;
            Process dbg_pro = _gdb.createProcess(XPlatform.converToPlatformCharSet(dbgpath), args__, nilptr);
            if (dbg_pro != nilptr && XWorkspace.workspace.requestDebug(_gdb.getPipe())){
                String [] dbg_arg = {host, "" + port, exePath};
                if (_gdb.remoteDebug(dbg_arg)) {
                    CPPGPlugManager.output("\n已创建进程 ID: " + dbg_pro.id() + "\n", 0);
                    dbg_pro.waitFor(-1);
                    CPPGPlugManager.output("\n退出代码: " + dbg_pro.getExitCode() + "\n", 0);
                } else {
                    CPPGPlugManager.output("\n运行失败.\n", 0);
                }
            }
            dbg_shell = nilptr;
        }
    }
    
    void debugRun(@NotNilptr IBuilder builder, @NotNilptr Project proj, @NotNilptr Configure conf) override {
        if (XWorkspace.isDebugging()) {
            builder.OutputText("\调试器已在运行中,请等待当前调试工作结束.\n", 0);
            return ;
        }
        
        int debugSerial = getDebugSerial();
        String dbgpath = getDebuggeePath(conf);
        if (dbgpath == nilptr){
            builder.OutputText("未配置调试器, 请在[项目属性] 页面配置编译套件, 或前往[工具]->[C/C++设置]中配置调试器", 0);
            return ;
        }
        
        String exePath = getExecuteCmd(proj, conf);
        
        if (exePath == nilptr){
            builder.OutputText("\n没有找到目标程序", 0);
            return;
        }
        
        if (XPlatform.existsSystemFile(exePath) == false){
            builder.OutputText("\n没有找到目标程序:" + exePath + ",请先编译生成.\n", 0);
            XWorkspace.workspace.executeNotExists();
            return ;
        }
        
        Vector<String> args = getExecuteArgs(proj, conf);
 
        String []args__ = new String[5];
        if (_system_.getPlatformId() == 0){
            args__[0] = "\"" + XPlatform.converToPlatformCharSet(dbgpath) + "\"";
        }else{
            args__[0] = XPlatform.converToPlatformCharSet(dbgpath);
        }
        args__[1] = "--interpreter=mi2";
        
        
        if (_system_.getPlatformId() == 0){
            args__[2] = "\"" + (exePath) + "\"";
        }else{
            args__[2] = (exePath);
        }
        
        args__[3] = "-quiet";
        
        args__[4] = "--nx";
        
        String [] dbg_args__ = new String[args.size()];
        
        if (args.size() > 0) {
            for (int i = 0; i < dbg_args__.length; i++) {
                dbg_args__[i] = XPlatform.converToPlatformCharSet(args.get(i));
            }
        }
        
        GDBShell _gdb =new GDBShell();
        
        if (_gdb.prepareForPipe() == false){
            builder.OutputText("\n无法创建调试端口!\n", 1);
            return ;
        } 
        
        dbg_shell = _gdb;
        process = dbg_shell.createProcess(XPlatform.converToPlatformCharSet(dbgpath), args__, XPlatform.converToPlatformCharSet(getExecuteWd(proj, conf)));
   
        String statusoutput = "\n运行: " + exePath + " ";

        for (int i = 0; i < args.size(); i++) {
            statusoutput = statusoutput + args.get(i) + " ";
        }

        builder.OutputText(statusoutput + "\n", 0);
        
        try {
            if (XWorkspace.workspace.debugPrepare(getDebugPipe())) {
                if (dbg_shell.startDebuggee(dbg_args__)) {
                    builder.OutputText("\n已创建调试器进程 ID: " + process.id() + "\n", 0);
                    
                    if (XWorkspace.workspace.debug() == false) {
                        builder.OutputText("\n调试器失败.\n", 0);
                        process.exit(0);
                    }
 
                    process.waitFor(-1);
                    
                    builder.OutputText("\n退出代码: " + process.getExitCode() + "\n", 0);
                } else {
                    builder.OutputText("\n运行失败.\n", 0);
                }
            } else {
                builder.OutputText("\n调试器正忙.\n", 0);
            }
        } catch(Exception e) {

            if (e.getErrorCode() == 0x000002E4) {
                XWorkspace.workspace.runOnUi(new Runnable() {
                    void run()override {
                        if (QXMessageBox.Question("注意", "被调试程序需要提升权限, 是否重新以提升的权限运行?", QXMessageBox.Ok | QXMessageBox.Cancel, QXMessageBox.Ok) == QXMessageBox.Ok) {
                            XWorkspace.runAsAdministrator();
                        }
                    }
                });
            }

            String str = e.getMessage();

            if (_system_.getPlatformId() == 0) {
                builder.OutputText("\n错误:" + new String(str.getBytes(), "GB18030//IGNORE") + "\n", 0);
            } else {
                builder.OutputText("\n错误:" + str + "\n", 0);
            }
        } finally {
            XWorkspace.workspace.debugClose();
        }
        
        dbg_shell.close();
        dbg_shell = nilptr;
    }
    
    void Run(@NotNilptr IBuilder builder, @NotNilptr Project proj,@NotNilptr  Configure conf) override {
        
        String exePath = getExecuteCmd(proj, conf);/*getBuildFile(proj, conf);*/

        if (exePath == nilptr || XPlatform.existsSystemFile(exePath) == false) {
            builder.OutputText("\n没有找到目标程序:" + exePath + ",请先编译生成.\n", 0);
            return ;
        }

        Vector<String> args = getExecuteArgs(proj, conf);

        String []args__ = new String[args.size() + 1];
        
        args__[0] = exePath;
        
        if (args.size() > 0) {
            for (int i =0; i < args__.length; i++) {
                String argval = args.get(i);
                if (argval != nilptr){
                    args__[i + 1] = XPlatform.converToPlatformCharSet(argval);
                }
            }
        }

        process = new Process(XPlatform.converToPlatformCharSet(exePath), args__);
        process.setWorkDirectory(XPlatform.converToPlatformCharSet(getExecuteWd(proj, conf)));

        builder.OutputText("\n运行: " + exePath + "\n", 0);

        try {
            bool readforstdout = Setting.isRelocalStdout();
            if (process.create(readforstdout ? (Process.StdOut | Process.RedirectStdErr) : Process.Visible)) {
                if (readforstdout) {
                    Utils.readForProcess(builder, process);
                }
                process.waitFor(-1);
                builder.OutputText("\n退出代码: " + process.getExitCode() + "\n", 0);
            } else {
                builder.OutputText("\n运行失败.\n", 0);
            }
        } catch(Exception e) {
            String str = e.getMessage();
            if (_system_.getPlatformId() == 0) {
                builder.OutputText("\n错误:" + new String(str.getBytes(), "GB18030//IGNORE") + "\n", 0);
            } else {
                builder.OutputText("\n错误:" + str + "\n", 0);
            }
        }
    }
    
	void stopRun() override {
        dbg_shell.exit();
    }
    
    @NotNilptr  String  generateMakeForDriver(@NotNilptr Project object, @NotNilptr Configure configure) {
        Vector<String> _srcs = getSourceArgs(nilptr, object, configure, nilptr, nilptr);
        
        String content = "#Generated by XStudio, Date:" + String.formatDate("%c", _system_.currentTimeMillis()) + "\n\n" +
        "ifneq ($(KERNELRELEASE),)\n\nobj-m +=" ;
        
        String projdir = object.getProjectDir();
        
        for (int i =0; i < _srcs.size(); i++){
            if (_srcs[i].lower().findExtension().equals(".c")){
                content = content + " " + (_srcs[i].replaceExtension(".o")); 
            }
        }
        
        content = content + "\nelse\n\nKERNELDIR?=/lib/modules/$(shell uname -r)/build\n\nPWD :=$(shell pwd)\n\n.PHONY: clean all\n\nall:\n" + 
        "	$(MAKE) -C $(KERNELDIR) M=$(PWD) modules\n\nclean:\n	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versionsm *.order *.symvers\nendif";
        
        return content;
    }
    
    @NotNilptr  String  generateMake(@NotNilptr Project object, @NotNilptr Configure configure) override {
        String cmd = configure.getOption("command");
        
        if (cmd.length() == 0){
            //builder.OutputText("未配置项目类型, 请在 [项目属性] 页面配置项目类型.", 0);
            return "invalid project type";
        }
        
        if (cmd.equals("-driver")){
            return generateMakeForDriver(object, configure);
        }
        
        String comp_sec = configure.getOption("genasm");
        
        String dext = ".o";
        String comp_amd = "-c";
        if (_system_.getPlatformId() == 0){
            dext = ".obj";
        }

        if (comp_sec.equals("-S") || comp_sec.equals("-E") ){
            if (comp_sec.equals("-S")){
                dext = ".S";
                comp_amd = "-S";
            }else{
                dext = ".E";
                comp_amd = "-E";
            }
            cmd = "echo";
        }
        
        String projname = object.getName();
        
        String target = getTarget(object, configure);
        String ccpath = getCompilerPath(configure);
        String ldpath = getLinkerPath(configure);
        String arpath = getArPath(configure);
        
        String [] _args = generatorCompArgs_s(object, configure, "source.cpp", false);
        
        String CCFLAGS = "";
        
        for (int i = 3; i < _args.length - 2; i++){
            if (CCFLAGS.length() != 0){
                CCFLAGS = CCFLAGS + " ";
            }
            CCFLAGS = CCFLAGS + _args[i];
        }
        
        String projdir = object.getProjectDir();
        Vector<String> _exts = new Vector<String>();
        Vector<String> _srcs = getSourceArgs(nilptr, object, configure, nilptr, _exts);
        
        String sources = "";
        bool bisUnixPath = isUnixPath();
        for (int i =0; i < _srcs.size(); i++){
            if (sources.length() != 0){
                sources = sources + " \\\n\t";
            }
            
            String src_path = _srcs[i];
            sources = sources + String.formatPath(src_path, bisUnixPath);
        }
        
        Vector<String> ldArgs = new Vector<String>();
        
        String []options = {"wl_ld_v", "optimize", "gprofile", "fsanitize", "fundefined", "fdatarace", "fshift", "fsignedio", "fbounds", "funreachable", "freturn", "dbits", "noexceptions", "ignorew", "fpic", "pie", "debugable", "ostype", "compdest", "nostdlib", "staticlibcpp", "staticlibgcc", "staticlink", "ldsymbols", "noinhibitexec", "ldformat", 
            "wl_ld_zdefs", "wl_ld_muldefs", "wholearchive"
        };
        
        checkOptions(ldArgs, nilptr, configure, options);
        
        for (int i =0; i < ldArgs.size(); i++){
            if (ldArgs[i].startWith("-fsanitize=")){
                ldArgs.add("-static-libasan");
                break;
            }
        }
        
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            String sstype = configure.getOption("sstype");
            
            if (sstype.equals("-mwindows")){
                ldArgs.add("-mwindows");
            }
        }
        
        String speclds = configure.getOption("speclds");
        
        if (speclds.length() > 0){
            ldArgs.add("-Wl,-T");
            ldArgs.add(speclds);
        }
        
        String confname = configure.getName();

        //路径变量
        generateWarning(configure, ldArgs);
        // c++setting 
        generateLDArgs(configure, ldArgs);
        
        //外部库
        
        String LDFLAGS = "";
        for (int i = 0; i < ldArgs.size(); i++){
            if (LDFLAGS.length() != 0){
                LDFLAGS = LDFLAGS + "\\\n\t";
            }
            LDFLAGS = LDFLAGS + XEnvironment.MapVariable(object, configure, ldArgs[i]);
        }
        
        ldArgs.clear();
        //other 
        
        
        
        generateLinkerCommand(configure, ldArgs);
        String USERLDFLAGS = "";
        for (int i = 0; i < ldArgs.size(); i++){
            if (USERLDFLAGS.length() != 0){
                USERLDFLAGS = USERLDFLAGS + "\\\n\t";
            }
            USERLDFLAGS = USERLDFLAGS + XEnvironment.MapVariable(object, configure, ldArgs[i]);
        }
        
        ldArgs.clear();
        //路径变量
        generateLibPath(configure, ldArgs);
        String LIBDIR = "";
        for (int i = 0; i < ldArgs.size(); i++){
            if (LIBDIR.length() != 0){
                LIBDIR = LIBDIR + "\\\n\t";
            }
            LIBDIR = LIBDIR + XEnvironment.MapVariable(object, configure, ldArgs[i]);
        }
        
        
        Vector<String> libsArgs = new Vector<String>();
        generateLibs(configure, libsArgs);
        
        String strlibs = "";
        String liblink = "";
        
        if (libsArgs.size() != 0){
            for (int i =0; i < libsArgs.size(); i++){
                String dependlibs = XEnvironment.MapVariable(object, configure, libsArgs[i]);
                if (strlibs.length() == 0){
                    strlibs = "IMPORTLIB=" + dependlibs;
                }else{
                    strlibs = strlibs + "\\\n\t" + dependlibs;
                }
            }
            liblink = "$(IMPORTLIB)";
        }
        
        String szarch = getArch(configure);
        
        String content = "#Generated by XStudio, Date:" + String.formatDate("%c", _system_.currentTimeMillis()) + "\n";
        
        String ouputPath = String.formatPath(XEnvironment.MapVariable(object, configure, configure.getOption("outpath")), isUnixPath());
        
        //content = content + "ARCH := $(shell arch)\n\n"
        
        content = content + "ARCH := " + szarch + "\n\n"
        
        + "OUTPUTPATH = ./" + String.formatPath(ouputPath.toRelativePath(projdir, false, true), isUnixPath()) + "/\n\n"
        + "OBJPATH := ./objs\n\n"
        + "$(shell mkdir -p $(OUTPUTPATH))\n\n"
        + "CC = \""  + ccpath + "\"\n\n"  
        + "LD = \"" + ldpath + "\"\n\n" 
        + "AR = \"" + arpath + "\"\n\n"
        + "CCFLAGS = " + CCFLAGS + "\n\n";
        
        if (strlibs.length() > 0){
            content = content + strlibs + "\n\n";
        }
                
        String midContent = "SOURCE = " + sources + "\n\n" 
        + "OBJECTS = $(addprefix $(OBJPATH)/, $(addsuffix " + dext + ", $(basename $(SOURCE))))\n\n"
        + "all: $(TARGET)\n\n"
        + "target: $(TARGET)\n\n";
        
        for (int i = 0; i < _exts.size(); i++){
            midContent = midContent + "$(OBJPATH)/%" + dext + ": %" + _exts[i] + "\n\tif [ ! -d $(dir $@) ]; then mkdir -p $(dir $@);  fi;\\\n\t$(CC) $(CCFLAGS) -o $@ " + comp_amd + " $<\n\n";
        }
        
        if (target != nilptr){
            target = String.formatPath(target.toRelativePath(projdir, false, true), isUnixPath());
            
            if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                target = "\"" + target +  "\"";
            }
             
            content = content + "TARGET = " + target + "\n\n" ;
            
            switch(cmd){
                case "echo":
                    content = content + midContent
                    + "$(TARGET): $(OBJECTS)\n\techo $(OBJECTS)\n\n" + 
                    "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
                break;
                case "-staticlib":
                    content = content + midContent
                    + "$(TARGET): $(OBJECTS)\n\t$(AR) rcs $(TARGET) $(OBJECTS)\n\n" + 
                    "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
                break;
                
                case "-shared":
                    content = content + "LIBDIR = " + LIBDIR + "\n\nLDFLAGS = -shared " + LDFLAGS + "\n\n" + "USERLDFLAGS = " + USERLDFLAGS + "\n\n"
                    + midContent
                    + "$(TARGET): $(OBJECTS)\n\t$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS) $(LIBDIR) " + liblink + " $(USERLDFLAGS)\n\n" + 
                    "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
                break;
                
                case "-execute":
                    content = content + "LIBDIR = " + LIBDIR + "\n\nLDFLAGS = " + LDFLAGS + "\n\n" + "USERLDFLAGS = " + USERLDFLAGS + "\n\n"
                    + midContent
                    + "$(TARGET): $(OBJECTS)\n\t$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS) $(LIBDIR) " + liblink + " $(USERLDFLAGS)\n\n" + 
                    "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
                break;
                
                case "-driver":
                    content = content + "LIBDIR = " + LIBDIR + "\n\nLDFLAGS = " + LDFLAGS + "\n\n" + "USERLDFLAGS = " + USERLDFLAGS + "\n\n"
                    + midContent
                    + "$(TARGET): $(OBJECTS)\n\t$(LD) $(LDFLAGS) -o $(TARGET) $(OBJECTS) $(LIBDIR) " + liblink + " $(USERLDFLAGS)\n\n" + 
                    "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
                break;
            }
        }
        return content;
    }
    
    
    
    bool extartToDir(@NotNilptr String zfile, @NotNilptr String dir, @NotNilptr String projName) {

        FileInputStream fis;

        try {
            fis = new FileInputStream(zfile);
        } catch(Exception e) {
            return false;
        }

        bool bSuccess = true;
        ZipArchive zs = new ZipArchive();
        if (zs.open(fis)) {
            int c = zs.getEntriesCount();
            
            for (int i =0; i < c; i ++) {
                ZipEntry entry = zs.getEntry(i);
                if (bSuccess == false || entry == nilptr) {
                    break;
                }
                
                String entryName = entry.getName();
                entryName = entryName.replace("${ProjectName}", projName);

                String path = appendPath(dir, entryName);

                if (entry.isDirectory() == false) {
                    ZipFile file = entry.getFile();

                    byte []buf = new byte[1024];
                    int rd = 0;
                    if (file.open()) {
                        long filehandler = XPlatform.openSystemFile(path, "w");
                        if (filehandler != 0) {
                            while ((rd = file.read(buf, 0, 1024)) != 0) {
                                _system_.writeFile(filehandler, buf, 0, rd);
                            }
                            _system_.closeFile(filehandler);
                        } else {
                            bSuccess = false;
                        }
                        file.close();
                    } else {
                        bSuccess = false;
                    }
                } else {
                    XPlatform.mkdir(path);
                }
            }
            zs.close();
        } else {
            bSuccess = false;
        }

        return bSuccess;
    }
    
	bool create(@NotNilptr WizardLoader loader,@NotNilptr  String projectName, String projectDir,@NotNilptr  String uuid, Project object, bool isAddToProject, String userType) override {
        if (uuid.equals(CPPProjectPlugin.cpp_guiuuid)){
            
        }else
        if (uuid.equals(CPPProjectPlugin.cpp_conuuid)){
            
        }else
        if (uuid.equals(CPPProjectPlugin.cpp_stauuid)){
            
        }else
        if (uuid.equals(CPPProjectPlugin.cpp_dynuuid)){
            
        }
        return false;
    }
    

    public static JsonArray loadConfigures(){
        String configure = CPPGPlugManager.CPPLangPlugin.readFileContent(appendPath(XPlatform.getAppDirectory(), "plugins/cde/configures.cfg"));
        if (configure != nilptr){
            JsonObject root = new JsonObject(configure);
            return (JsonArray)root.get("configures");
        }
        return nilptr;
    }
    
    public @NotNilptr static String [] getConfigures(){
        Vector<String> kits = new Vector<String>();
        JsonArray ccc = loadConfigures();
        if (ccc != nilptr){
            for (int i = 0; i < ccc.length(); i++){
                JsonObject cconf = (JsonObject)ccc.get(i);
                if (cconf != nilptr){
                    String name = cconf.getString("name");
                    if (name != nilptr && name.length() != 0){
                        kits.add(name);
                    }
                }
            }
        }
        return kits.toArray(new String[0]);
    }
    
    static JsonObject getCCConfigure(String name){
        if (name == nilptr || name.length() == 0){
            name = Setting.get("default_kit");
        }
        if (name.length() == 0){
            return nilptr;
        }
        JsonArray ccc = loadConfigures();
        if (ccc != nilptr){
            for (int i = 0; i < ccc.length(); i++){
                JsonObject cconf = (JsonObject)ccc.get(i);
                if (cconf != nilptr){
                    if (cconf.getString("name").equals(name)){
                        return cconf;
                    }
                }
            }
        }
        return nilptr;
    }
    
    JsonObject getProperitiesConfigure() override {
        JsonObject _root = nilptr;
        String content = new String(__xPackageResource("cde.prop"));

         try{
            _root = new JsonObject(content);
        
            JsonArray cckitary = loadConfigures();
            if (cckitary != nilptr){
                JsonArray lists = new JsonArray();
                lists.put("未配置");
                for (int i = 0; i < cckitary.length(); i++){
                    lists.put(((JsonObject)cckitary.get(i)).getString("name"));
                }
                ((JsonObject)( (JsonObject)_root.get("项目属性")).get("编译套件:cckit")).put("list", lists);
            }
         }catch(Exception e){
             
         }
        return _root;
    }
    
    Stream createDebugPipe(String host, int ip){
        return nilptr;
    }
    
    Stream getDebugPipe(){
        return dbg_shell.getPipe();
    }
    
    ICompileInfo parseInformation(@NotNilptr String lineText){
        String [] prefix = {": 附注", ": 警告", ": 错误"};
        String [] prefix_en = {": note", ": warning", ": error", ": fatal error"};
        
        CPPCompileInfo info = new CPPCompileInfo();
        int pos = -1;
        bool bfd = false;
        
        for (int i =0; i < prefix.length; i++){
            pos = lineText.indexOf(prefix[i],0);
            if (pos != -1){
                info.file = lineText.substring(pos + 2,lineText.length());
                info.type = i;
                bfd = true;
                break;
            }
        }
        
        if (bfd == false){
            for (int i =0; i < prefix_en.length; i++){
                pos = lineText.indexOf(prefix_en[i],0);
                if (pos != -1){
                    info.file = lineText.substring(pos + 2,lineText.length());
                    if (i > 2){
                        i = 2;
                    }
                    info.type = i;
                    break;
                }
            }
        }
        
        bool succeed = false;
        try{
            if (pos != -1) {
                int lp = lineText.indexOf(':', 3);
                if (lp != -1 && (lp + 1) < lineText.length()) {
                    info.file = lineText.substring(0, lp).trim(true);
                    int le = lineText.indexOf(':', lp + 1);
                    if (le != -1 && (le + 1) < lineText.length()){
                        info.line = lineText.substring(lp + 1, le).parseInt();
                        int rp = lineText.indexOf(':', le + 1);
                        if (rp != -1 && le != -1) {
                            info.row = lineText.substring(le + 1, rp).parseInt();
                        }else{
                            info.row = 0;
                        }
                    }
                    
                }
            }
        }catch(Exception e){
            
        }
        
        return info;
    }
    
    void stopBuild(IBuilder builer)override{
        nBuildCancel = 1;
        if (builer != nilptr){
            Process ps = builer.getProcess();
            if (ps != nilptr){
                ps.raise(_system_.SIGINT);
            }
        }
    }
    
    void onProjectSettingChange(Project object)override{
        CPPGPlugManager.workspace.requestReconfigureSystem();
        if(object != nilptr){
            object.reinitIntelliSense();
        }
    }
    
    IXPlugin getXPlugin()override{
        return CPPGPlugManager.CPPLangPlugin.getInstance();
    }
    
    ICompileInfo parseOutputLine(@NotNilptr QXSci sci, int position, int line,@NotNilptr  String lineText){
        String [] prefix = {": 错误", ": 附注", ": 警告"};
        String [] prefix_en = {": note", ": warning", ": error", ": fatal error"};
        
        int pos = -1;
        bool bfd = false;
        
        for (int i =0; i < prefix.length; i++){
            pos = lineText.indexOf(prefix[i],0);
            if (pos != -1){
                bfd = true;
                break;
            }
        }
        
        if (bfd == false){
            for (int i =0; i < prefix_en.length; i++){
                pos = lineText.indexOf(prefix_en[i],0);
                if (pos != -1){
                    break;
                }
            }
        }
        bool succeed = false;
        
        CPPCompileInfo ccinfo = nilptr;
        
        try{
            if (pos != -1) {
                int lp = lineText.indexOf(':', 3);
                if (lp != -1 && (lp + 1) < lineText.length()) {
                    ccinfo = new CPPCompileInfo();
                    ccinfo.file = lineText.substring(0, lp).trim(true);
                    int le = lineText.indexOf(':', lp + 1);
                    if (le != -1 && (le + 1) < lineText.length()){
                        ccinfo.line = lineText.substring(lp + 1, le).parseInt();
                        int rp = lineText.indexOf(':', le + 1);
                        if (rp != -1 && le != -1) {
                            ccinfo.row = lineText.substring(le + 1, rp).parseInt();
                            int i = line + 1;
                            String infos = lineText.substring(pos, lineText.length());
                            for (int c = sci.countOfLine(); i < c; i++) {
                                String linestr = sci.getText(i);

                                if (linestr.startWith(" ") == false) {
                                    break;
                                } else {
                                    infos = infos + "\n" + linestr ;
                                }
                            }
                            /*if (infos.length() < 5){
                                infos = nilptr;
                            }*/
                            ccinfo.tip = infos;
                        }
                    }
                }
            }
        }catch(Exception e){
            
        }
        
        return ccinfo;
    }
    
    void customDebug()override{
        DebuggeeSelector.showDebuggeeSelector();
    }
    
    String getDebuggeeDescription(){
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            return "GDB (GNU Debugger for Windows)";
        }else{
            return "GDB (The GNU Project Debugger)";
        }
    }
};