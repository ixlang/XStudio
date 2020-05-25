//xlang Source, Name:CDEProjectPropInterface.x 
//Date: Tue Feb 20:38:34 2020 

class CDEProjectPropInterface : ProjectPropInterface{
    bool setValue(Project object, Configure configure, String key, String value) override {
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
    
    
    public String getValue(Project object, Configure configure,  String key) override {
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
    
    public static String getDebuggeePath(String kitname) {
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
    
    public static String getDebuggeePath(Configure configure) {
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
    
    public static String getCompilerPath(Configure configure) {
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
    
    public static String getMakePath(Configure configure) {
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
    
    public static String getMacros(Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("macros");
        }
        return nilptr;
    }
    
    public static String appendPath(String first, String append){
        return String.formatPath(first.appendPath(append), isUnixPath());
    }
    
    static bool isUnixPath(){
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            return Setting.isUnixPath();
        }
        return false;
    }
    
    public static JsonArray getCompilerSystemPath(Configure configure) {
        JsonArray array = nilptr;
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            array = (JsonArray)jconfig.get("searchs");
        }
        if (array != nilptr && array.length() > 0){
            JsonArray jsarray = new JsonArray();
            bool bReslash = isUnixPath();
            try{
                for (int i = 0; i < array.length(); i++){
                    jsarray.put(String.formatPath(array.getString(i),bReslash));
                }
            }catch(Exception e){
                
            }
            array = jsarray;
        }
        return array;
    }
    
    public static String getDbgArgs(Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("dbgparams");
        }
        return "";
    }
    
    public static String getLinkerPath(Configure configure) {
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
    
    public static String getArPath(Configure configure) {
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
    
    public static String getCCArgs(Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("ccparams");
        }
        return "";
    }
    
    public static String getLDArgs(Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("ldparams");
        }
        return "";
    }
    
    public static String getArArgs(Configure configure) {
        JsonObject jconfig = getCCConfigure(configure.getOption("cckit"));
        if (jconfig != nilptr){
            return jconfig.getString("arparams");
        }
        return "";
    }
    
    public static void generateCCArgs(Configure configure, Vector<String> sourceArgs) {
        String cmd = getCCArgs(configure);
        if (cmd != nilptr){
            processArgs(cmd, sourceArgs);
        }
    }
    
    public static void generateLDArgs(Configure configure, Vector<String> sourceArgs) {
        String cmd = getLDArgs(configure);
        if (cmd != nilptr){
            processArgs(cmd, sourceArgs);
        }
    }
    
    public static void jarray2Args(String cmd, Vector<String> sourceArgs){
        try{
            JsonArray jary = new JsonArray(cmd);
            if (jary != nilptr){
                for (int i =0; i < jary.length(); i++){
                    sourceArgs.add(jary.getString(i));
                }
            }
        }catch(Exception e){
            
        }
    }
    
    public static void generateCommand(Configure configure, Vector<String> sourceArgs) {
        String cmd = configure.getOption("otheroptions");
        jarray2Args(cmd, sourceArgs);
    }
    
    public static void processArgs(String args, Vector<String> args_list) {
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
    
    public static void generateLinkerCommand(Configure configure, Vector<String> sourceArgs) {
        String cmd = configure.getOption("otherlinkoptions");
        jarray2Args(cmd, sourceArgs);
    }
    
    public Vector<String> getSourceArgs(IBuilder builder, Project object, Configure configure, String workDir, Vector<String> extlist) {
        Vector<String> sourceArgs = new Vector<String>();

        JsonArray sources = object.getSources();
        Map<String, bool> ext_map = nilptr;
        if (extlist != nilptr){
            ext_map = new Map<String, bool>();
        }
        for (int i = 0; i < sources.length(); i++) {
            String srcname = sources.getString(i);
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
            if (ext != nilptr && (ext.equalsIgnoreCase(".c") || ext.equalsIgnoreCase(".cpp") || ext.equalsIgnoreCase(".cxx") || ext.equalsIgnoreCase(".m") || 
                ext.equalsIgnoreCase(".mm") || ext.equalsIgnoreCase(".cc") || ext.equalsIgnoreCase(".c++") || ext.equalsIgnoreCase(".cp") || ext.equalsIgnoreCase(".txx") || 
                ext.equalsIgnoreCase(".tpp") || ext.equalsIgnoreCase(".tpl"))) 
            {
                sourceArgs.add(fullsourcePath);
                
                if (extlist != nilptr){
                    String uext = ext.upper();
                    if (ext_map.containsKey(uext) == false){
                        ext_map.put(uext,true);
                        extlist.add(ext);
                    }
                }
            }
        }
        
        return sourceArgs;
    }
    
    public String getArchArgs(Configure configure) {
        return configure.getOption("wtype");
    }
    
    public IXIntelliSense allocIntelliSense(Project project, Configure cfg)override{
        return new ClangIXIntelliSense(project, cfg);
    }
    
    public static void generateJsonArrayArgs(String key, JsonArray incpath, Vector<String> args, bool quot) {
        if (incpath != nilptr) {
            //String incs = "";
            bool isReslash = isUnixPath();
            for (int i = 0; i < incpath.length(); i++) {
                String inc = incpath.getString(i);
                
                if (inc != nilptr && inc.length() > 0) {
                    if (key != nilptr){
                        args.add(key);
                    }
                    inc = String.formatPath(inc,isReslash);
                    if (quot && _system_.getPlatformId() == 0) {
                        args.add("\"" + inc + "\"");
                    } else {
                        args.add(inc);
                    }
                }
            }
        }
    }
    
    public static void checkOptions(Vector<String> args, Map<String,String> argmap, Configure configure, String []key) {
        for (int i =0; i < key.length; i++) {
            String option = configure.getOption(key[i]);

            if (option != nilptr && option.length() > 0) {
                if (args != nilptr) {
                    args.add(option);
                }
                if (argmap != nilptr) {
                    argmap.put(key[i], option);
                }

            } else if (key[i].equals("wtype")) {
                /*String wtype = getArchArgs(configure);
                if (wtype.length() > 0) {
                    if (args != nilptr) {
                        args.add(wtype);
                    }
                    if (argmap != nilptr) {
                        argmap.put(key[i], wtype);
                    }
                }*/
            } else if (key[i].equals("ostype")) {
                /*String ostype = getXcrossName(configure);
                if (ostype.length() > 0) {
                    if (args != nilptr) {
                        args.add(ostype);
                    }
                    if (argmap != nilptr) {
                        argmap.put(key[i], ostype);
                    }
                }*/
            }
        }
    }
    
    public static void generateWarning(Configure configure, Vector<String> args) {
        JsonArray ignorewl = getArrayOption(configure, "ignorewl");
        if (ignorewl != nilptr) {
            generateJsonArrayArgs(nilptr, ignorewl, args, false);
        }
    }
    
    public static void generateIncPath(Configure configure, Vector<String> args) {
        JsonArray libpath = getArrayOption(configure, "path.incpath");
        if (libpath != nilptr) {
            generateJsonArrayArgs("-I", libpath, args, true);
        }
    }
    
    public static void generateLibPath(Configure configure, Vector<String> args) {
        JsonArray libpath = getArrayOption(configure, "path.libpath");
        if (libpath != nilptr) {
            generateJsonArrayArgs("-L", libpath, args, true);
        }
    }
    
    
    public static String [] generatorCompArgs_s(Project object, Configure configure, String sourfile){
        Vector<String> args = new Vector<String>();
        String ccpath = getCompilerPath(configure);
        
        args.add("%cc%");
        
        args.add("-c");
        
        args.add("%source%");
        // "staticlibgcc", "staticlibcpp",
        String []options = {"optimize", "gprofile", "dbits", "noexceptions", "ignorew", "debugable", "wtype", "ostype", "fpic", "signed_char", "nostdinc", "nostdincpp", "cpp11", "cstd11", "eversose", "fvisibility"};

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
            szArgs[i] = XPlatform.converToPlatformCharSet(map_variable(object, configure, args.get(i)));
        }
                
        String projdir = object.getProjectDir();
        String out_path = configure.getOption("objdir");
        out_path = String.formatPath(map_variable(object, configure, out_path), isUnixPath());
        String destfile = sourfile.toRelativePath(projdir,false,true);
        destfile = destfile.toAbsolutePath(out_path);
            
        if (_system_.getPlatformId() == 0){
            destfile = destfile.replaceExtension(".obj");
            szArgs[0] = "\""  + ccpath + "\"";
            szArgs[2] = "\""  + sourfile + "\"";
            szArgs[szArgs.length - 1] = "\"" + destfile + "\"";
        }else{
            destfile = destfile.replaceExtension(".o");
            szArgs[0] = ccpath;
            szArgs[2] = sourfile;
            szArgs[szArgs.length - 1] = destfile;
        }
        
        return szArgs;
    }
    
    public String [] generatorCompArgs(Project object, Configure configure, String sourfile)override{
        return generatorCompArgs_s(object, configure, sourfile);
    }
    
    
    int nBuildCancel = 0;//0 没有取消  1已设定取消  2已取消
    
    
    public void clearObjectFile(IBuilder builder, Project object, Configure configure){
    
        String projdir = object.getProjectDir();
        
        Vector<String> __args = getSourceArgs(nilptr, object, configure, projdir, nilptr);
        
        String out_path = configure.getOption("objdir");
        
        out_path = String.formatPath(map_variable(object, configure, out_path), isUnixPath());
        
        for (int i = 0; i < __args.size(); i++) {
            String sourfile = __args.get(i);
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
    
    public void generateBuildArgs(IBuilder builder,Vector<String> __args, Project object, Configure configure, String workdir) {
    
        String target = getTarget(object, configure);

        if (XPlatform.existsSystemFile(target)) {
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
        
        args.add("-c");
        
        args.add("%source%");
        // "staticlibgcc", "staticlibcpp",
        String []options = {"optimize","gprofile", "dbits", "noexceptions", "ignorew", "debugable", "wtype", "ostype", "fpic", "signed_char", "nostdinc", "nostdincpp", "cpp11", "cstd11", "eversose", "fvisibility"};

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
            szArgs[i] = XPlatform.converToPlatformCharSet(map_variable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        String projdir = object.getProjectDir();
        String out_path = configure.getOption("objdir");
        out_path = String.formatPath(map_variable(object, configure, out_path), isUnixPath());
        bool bReslash = isUnixPath();
        
        for (int i = 0; i < __args.size(); i++) {
           
            String sourfile = __args.get(i);
            
            String destfile = sourfile.toRelativePath(projdir,false,true);
            
            sourfile = String.formatPath(sourfile, bReslash);
            destfile = String.formatPath(destfile.toAbsolutePath(out_path), bReslash);
            
            XlangProjectProp.mkdirs(String.formatPath(destfile.findVolumePath(), false));
            
            destfile = destfile.replaceExtension(".o");
            
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
            
            allInfo = allInfo + builder.build(ccpath, szArgs, workdir, nilptr, false);
            
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
            
            if (cmd.equals("-staticlib")){
                ExecuteLinkLib(builder, objfiles, object, configure, workdir);
            }else{
                ExecuteLinker(builder, objfiles, object, configure, workdir);
            }
            
            builder.complete();
        }
        
    }
    
    public static JsonArray getArrayOption(Configure configure, String key){
        try{
            String szlibs = configure.getOption(key);
            return new JsonArray(szlibs);
            
        }catch(Exception e){
            
        }
        return nilptr;
    }
    
    public JsonArray getExternLibs(Configure cfg){
        return getArrayOption(cfg, "libs");
    }
    
    public void generateLibs(Configure configure, Vector<String> args) {
        JsonArray libs = getArrayOption(configure, "libs");
        generateJsonArrayArgs(nilptr, libs, args, true);
    }
    
    
    public static String getTarget(Project object, Configure configure) {
        String out_path = map_variable(object, configure, "$(Output)");
        return String.formatPath(out_path, isUnixPath());
    }
    
    public void ExecuteLinkLib(IBuilder builder,Vector<String> __args, Project object, Configure configure, String workdir) {
    
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
        
        out_path = String.formatPath(map_variable(object, configure, out_path), isUnixPath());
        
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
            szArgs[i] = XPlatform.converToPlatformCharSet(map_variable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        allInfo = allInfo + builder.build(ldpath, szArgs, workdir, nilptr, false);
        
        builder.setCompileInfor(parseInfo(allInfo));
    }
    
    public void ExecuteLinker(IBuilder builder,Vector<String> __args, Project object, Configure configure, String workdir) {
    
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
        
        for (int i = 0; i < __args.size(); i++) {
            String objf = __args.get(i);
            if (_system_.getPlatformId() == 0){
                args.add("\"" + objf + "\"" );
            }else{
                args.add(objf);
            }
        }
        
        // "staticlibgcc", "staticlibcpp",
        String []options = {"staticlink", "optimize", "gprofile", "dbits", "noexceptions", "ignorew", "fpic", "pie", "debugable", "wtype", "ostype", "compdest", "staticlibcpp", "staticlibgcc", "wl_ld_v", "nostdlib"};

        checkOptions(args, nilptr, configure, options);
        //路径变量
        generateWarning(configure, args);
        //路径变量
        generateLibPath(configure, args);

        generateLDArgs(configure, args);
        
        generateLinkerCommand(configure, args);
        //外部库
        generateLibs(configure, args);


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
        
        out_path = String.formatPath(map_variable(object, configure, out_path), isUnixPath());
        
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
            szArgs[i] = XPlatform.converToPlatformCharSet(map_variable(object, configure, args.get(i)));
        }
        
        String allInfo = "";
        
        allInfo = allInfo + builder.build(ldpath, szArgs, workdir, nilptr, false);
        
        builder.setCompileInfor(parseInfo(allInfo));
           
    }
    
    public bool verifyFileContent(String file, String content){
        try{
            FileInputStream fis = new FileInputStream(file);
            byte [] data = fis.read();
            fis.close();
            return new String(data).equals(content);
        }catch(Exception e){
        }
        return false;
    }
    
    public bool writeFileContent(String file, String content){
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
    
    bool cleanByMake(IBuilder builder, Project object, Configure configure, Object param)  {
        String makecont = generateMake(object, configure);
        String makefile = appendPath(object.getProjectDir(), "makefile");
        
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
            if (make.startWith("\"" ) && make.endWith("\"" )){
                make = make.substring(1, make.length() - 1);
            }

            String batch = "@echo off\nset PATH=\""  +  make.findVolumePath() + "\";%PATH%\n@echo on\n" + makepath;
            String batchfile = appendPath(object.getProjectDir(), "clean.cmd");
            
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
                String parse(String text)override{
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
            builder.setCompileInfor(parseInfo(text));
            
            builder.complete();
            
            return true;
        }
        builder.OutputText("make无效",0);
        return false;
    }
     
    bool buildByMake(IBuilder builder, Project object, Configure configure, Object param)  {
        String makecont = generateMake(object, configure);
        String makefile = appendPath(object.getProjectDir(), "makefile");
        
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

            String make = args_list[0];
            if (make.startWith("\"" ) && make.endWith("\"" )){
                make = make.substring(1, make.length() - 1);
            }

            String batch = "@echo off\nset PATH=\""  +  make.findVolumePath() + "\";%PATH%\n@echo on\n" + makepath;
            String batchfile = appendPath(object.getProjectDir(), "build.cmd");
            
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
                String parse(String text)override{
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
            builder.setCompileInfor(parseInfo(text));
            
            builder.complete();
            
            return true;
        }
        builder.OutputText("make无效",0);
        return false;
    }
    
    bool build(IBuilder builder, Project object, Configure configure, Object param) override {
        nBuildCancel = 0;
        String target = getTarget(object, configure);

        if (XPlatform.existsSystemFile(target)) {
            if (false == XPlatform.deleteFile(target)) {
                builder.OutputText("无法删除文件:" + target + " ,文件正在使用中\n", 0);
                return false;
            }
        }

        String usemake = configure.getOption("usemake");
        if (usemake.length() > 0){
            return buildByMake(builder, object, configure, param);
        }
        
        XlangProjectProp.batchbuild(builder, object, configure, "prebuild");

        String workdir = object.projpath.findVolumePath();

        Vector<String> _args = getSourceArgs(builder, object, configure, workdir, nilptr);

        if (configure == nilptr) {
            Map<String, Configure> conf_map = object.configures;
            Map.Iterator<String, Configure> iter = conf_map.iterator();

            while (iter.hasNext()) {
                Configure conf = iter.getValue();
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
    
    int detectInfo(String lineText) {
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
        public String getTips() {
            return tip;
        }
    };
    
    Vector<ICompileInfo> parseInfo(String info) {
        Vector<ICompileInfo> infos = new Vector<ICompileInfo>();
        String [] list = info.split("\n");
        if (list != nilptr) {
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
                    CPPCompileInfo ccinfo = (CPPCompileInfo)parseInformation(message);
                    ccinfo.tip = tips_block;
                    infos.add(ccinfo);
                }
            }
        }
        return infos;
    }
    
    static String getArch(Configure configure) {
        String [] archs = {"i386", "i686", "x86_64", "armv7-a", "armv8-a"};

        String arch = configure.getOption("wtype");
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
    
    public static String map_variable(Project object, Configure configure, String text) {
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

        return object.map_variable(text);
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
    
    void cleanup(IBuilder builder, Project object, Configure configure) override {
        nBuildCancel = 0;
        String target = getTarget(object, configure);

        if (XPlatform.existsSystemFile(target)) {
            if (false == XPlatform.deleteFile(target)) {
                builder.OutputText("无法删除文件:" + target + " ,文件正在使用中\n", 0);
            }
        }

        String usemake = configure.getOption("usemake");
        if (usemake.length() > 0){
            cleanByMake(builder, object, configure, nilptr);
        }else{
            clearObjectFile(builder, object, configure);
        }
    }
    
    String getExecuteCmd(Project object, Configure configure) {
        String out_path = configure.getOption("cmd");
        out_path = map_variable(object, configure, out_path);
        return String.formatPath(out_path, isUnixPath());
    }
    
    Vector<String> getExecuteArgs(Project object, Configure configure) {

        String out_path = configure.getOption("args");
        Vector<String> argve = XlangProjectProp.processArgs(out_path);

        Vector<String> finalargs = new Vector<String>();
        bool bisUnixPath = isUnixPath();
        for (int i =0; i < argve.size(); i++) {
            finalargs.add(XlangProjectProp.formatArgs(String.formatPath(map_variable(object, configure, argve.get(i)), bisUnixPath)));
        }

        return finalargs;
    }
    
    String getExecuteWd(Project object, Configure configure) {
        String out_path = configure.getOption("workdir");
        out_path = map_variable(object, configure, out_path);
        return String.formatPath(out_path, false);
    }
    
    Process process ;
    GDBShell dbg_shell;
    
    
    public static void attachDebug(String kitname, int pid){
        String dbgpath = getDebuggeePath(kitname);
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
        if (XWorkspace.workspace.requestDebug(_gdb.getPipe())){
            String [] dbg_arg = {"" + pid};
            if (_gdb.attachProcess(dbg_arg)) {
                CPPGPlugManager.output("\n已创建进程 ID: " + dbg_pro.id() + "\n", 0);
                dbg_pro.waitFor(-1);
                CPPGPlugManager.output("\n退出代码: " + dbg_pro.getExitCode() + "\n", 0);
            } else {
                CPPGPlugManager.output("\n运行失败.\n", 0);
            }
        }
    }
    
    public static void remoteDebug(String kitname, String host, int port, String exePath){
        String dbgpath = getDebuggeePath(kitname);
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
        
        Process dbg_pro = _gdb.createProcess(XPlatform.converToPlatformCharSet(dbgpath), args__, nilptr);
        if (XWorkspace.workspace.requestDebug(_gdb.getPipe())){
            String [] dbg_arg = {host, "" + port, exePath};
            if (_gdb.remoteDebug(dbg_arg)) {
                CPPGPlugManager.output("\n已创建进程 ID: " + dbg_pro.id() + "\n", 0);
                dbg_pro.waitFor(-1);
                CPPGPlugManager.output("\n退出代码: " + dbg_pro.getExitCode() + "\n", 0);
            } else {
                CPPGPlugManager.output("\n运行失败.\n", 0);
            }
        }
    }
    
    void debugRun(IBuilder builder, Project proj, Configure conf) override {
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
        
        dbg_shell = new GDBShell();
        
        if (dbg_shell.prepareForPipe() == false){
            builder.OutputText("\n无法创建调试端口!\n", 1);
            return ;
        } 
        
        process = dbg_shell.createProcess(XPlatform.converToPlatformCharSet(dbgpath), args__, XPlatform.converToPlatformCharSet(getExecuteWd(proj, conf)));
   
        String statusoutput = "\n运行: " + exePath + " ";

        for (int i = 0; i < args.size(); i++) {
            statusoutput = statusoutput + args.get(i) + " ";
        }

        builder.OutputText(statusoutput + "\n", 0);
        
        try {
            if (XWorkspace.workspace.debugPrepare(getDebugPipe())) {
                if (dbg_shell.startDebuggee(dbg_args__)) {
                    builder.OutputText("\n已创建进程 ID: " + process.id() + "\n", 0);
                    
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
    }
    
    void Run(IBuilder builder, Project proj, Configure conf) override {
        
    }
    
	void stopRun() override {
        dbg_shell.exit();
    }
    

    
    String generateMake(Project object, Configure configure) override {
        String cmd = configure.getOption("command");
        
        if (cmd.length() == 0){
            //builder.OutputText("未配置项目类型, 请在 [项目属性] 页面配置项目类型.", 0);
            return "invalid project type";
        }
        
        String projname = object.getName();
        
        String target = getTarget(object, configure);
        String ccpath = getCompilerPath(configure);
        String ldpath = getLinkerPath(configure);
        String arpath = getArPath(configure);
        
        String [] _args = generatorCompArgs_s(object, configure, "source.cpp");
        
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
        
        String []options = {"staticlink", "optimize","gprofile", "dbits", "noexceptions", "ignorew", "fpic", "pie", "debugable", "wtype", "ostype", "compdest", "staticlibcpp", "staticlibgcc", "wl_ld_v", "nostdlib"};
        
        checkOptions(ldArgs, nilptr, configure, options);
        
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

        //路径变量
        generateLibPath(configure, ldArgs);

        generateLDArgs(configure, ldArgs);
        
        generateLinkerCommand(configure, ldArgs);
        //外部库
        
        String LDFLAGS = "";
        for (int i = 0; i < ldArgs.size(); i++){
            if (LDFLAGS.length() != 0){
                LDFLAGS = LDFLAGS + "\\\n\t";
            }
            LDFLAGS = LDFLAGS + ldArgs[i];
        }
        
        
        Vector<String> libsArgs = new Vector<String>();
        generateLibs(configure, libsArgs);
        
        String strlibs = "";
        String liblink = "";
        
        if (libsArgs.size() != 0){
            for (int i =0; i < libsArgs.size(); i++){
                if (strlibs.length() == 0){
                    strlibs = "IMPORTLIB=" + libsArgs[i];
                }else{
                    strlibs = strlibs + "\\\n\t" + libsArgs[i];
                }
            }
            liblink = "$(IMPORTLIB)";
        }
        
        String szarch = getArch(configure);
        
        String content = "#Generated by XStudio, Date:" + String.formatDate("%c", _system_.currentTimeMillis()) + "\n";
        
        //content = content + "ARCH := $(shell arch)\n\n"
        
        content = content + "ARCH := " + szarch + "\n\n"
        
        + "OUTPUTPATH = ./$(ARCH)/" + confname + "/\n\n"
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
        + "OBJECTS = $(addprefix $(OBJPATH)/, $(addsuffix .o, $(basename $(SOURCE))))\n\n"
        + "all: $(TARGET)\n\n"
        + "target: $(TARGET)\n\n";
        
        for (int i = 0; i < _exts.size(); i++){
            midContent = midContent + "$(OBJPATH)/%.o: %" + _exts[i] + "\n\tif [ ! -d $(dir $@) ]; then mkdir -p $(dir $@);  fi;\\\n\t$(CC) $(CCFLAGS) -o $@ -c $<\n\n";
        }
        target = String.formatPath(target.toRelativePath(projdir, false, true), isUnixPath());
        
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            target = "\"" + target +  "\"";
        }
         
        content = content + "TARGET = " + target + "\n\n" ;
        
        switch(cmd){
            case "-staticlib":
                content = content + midContent
                + "$(TARGET): $(OBJECTS)\n\t$(AR) rcs $(TARGET) $(OBJECTS)\n\n" + 
                "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
            break;
            
            case "-shared":
                content = content + "LDFLAGS = -shared " + LDFLAGS + "\n\n"
                + midContent
                + "$(TARGET): $(OBJECTS)\n\t$(LD) -o $(TARGET) $(OBJECTS) $(LDFLAGS) " + liblink + "\n\n" + 
                "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
            break;
            
            case "-execute":
                content = content + "LDFLAGS = " + LDFLAGS + "\n\n"
                + midContent
                + "$(TARGET): $(OBJECTS)\n\t$(LD) -o $(TARGET) $(OBJECTS) $(LDFLAGS) " + liblink + "\n\n" + 
                "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
            break;
            
            case "-driver":
                content = content + "LDFLAGS = " + LDFLAGS + "\n\n"
                + midContent
                + "$(TARGET): $(OBJECTS)\n\t$(LD) -o $(TARGET) $(OBJECTS) $(LDFLAGS) " + liblink + " \n\n" + 
                "clean:\n\trm -f $(TARGET) $(OBJECTS)\n";
            break;
        }
        
        return content;
    }
    
    
    
    bool extartToDir(String zfile, String dir, String projName) {

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
                if (bSuccess == false) {
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
    
	bool create(WizardLoader loader, String projectName, String projectDir, String uuid, Project object, bool isAddToProject, String userType) override {
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
    
    static JsonObject getCCConfigure(String name){
        if (name == nilptr){
            return nilptr;
        }
        JsonArray ccc = loadConfigures();
        if (ccc != nilptr){
            for (int i = 0; i < ccc.length(); i++){
                JsonObject cconf = (JsonObject)ccc.get(i);
                if (cconf.getString("name").equals(name)){
                    return cconf;
                }
            }
        }
        return nilptr;
    }
    
    JsonObject getProperitiesConfigure() override {
        JsonObject _root = nilptr;
        String file = _system_.getAppDirectory();
        file = appendPath(appendPath(appendPath(file, "plugins"), "cde"), "cpp.prop");
        String content = CPPGPlugManager.CPPLangPlugin.readFileContent(file);
        if (content != nilptr){
            _root = new JsonObject(content);
            if (_root != nilptr){
                JsonArray cckitary = loadConfigures();
                if (cckitary != nilptr){
                    JsonArray lists = new JsonArray();
                    for (int i = 0; i < cckitary.length(); i++){
                        lists.put(((JsonObject)cckitary.get(i)).getString("name"));
                    }
                    ((JsonObject)( (JsonObject)_root.get("项目属性")).get("编译套件:cckit")).put("list", lists);
                }
            }
        }
        return _root;
    }
    
    Stream createDebugPipe(String host, int ip){
        return nilptr;
    }
    
    Stream getDebugPipe(){
        return dbg_shell.getPipe();
    }
    
    ICompileInfo parseInformation(String lineText){
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
    
    void stopBuild()override{
        nBuildCancel = 1;
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
    
    ICompileInfo parseOutputLine(QXSci sci, int position, int line, String lineText){
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