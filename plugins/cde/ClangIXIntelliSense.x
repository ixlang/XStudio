//xlang Source, Name:ClangIXIntelliSense.x 
//Date: Tue Apr 13:55:33 2020 

class ClangIXIntelliSense : IXIntelliSense{
    LspClient clangdlsp;
    
    Map<String, String> _compargs = new Map<String, String>();
    // 各个扩展名对应的编译参数
    
    static class Document{
        public bool isEnabled = false;
        public String symbols;
        
        public Document(bool bie){
            isEnabled = bie;
        }
    };
    
    Map<String, Document> _filelist = new Map<String, Document>();
    // 文件列表
    Project cur_project;
    Configure cur_cfig;
    String __completion_result = nilptr;
    
    static String clangd = nilptr;
    
    String initResp = nilptr;
    char [] trigge_chars = nilptr;
    
    class LspCallback : LspClient.LspListener{
        void onCallBack(JsonObject resp){
            String st = resp.toString(true);
           // _system_.output("\n" + st + "\n");
        }
    };
    
    bool initializ()override{
            
        if (clangd == nilptr){
            String clang_path = CDEProjectPropInterface.appendPath(_system_.getAppDirectory(), "plugins/cde/clang");
            switch(_system_.getPlatformId()){
                case _system_.PLATFORM_WINDOWS:
                clang_path = CDEProjectPropInterface.appendPath(clang_path, "win/clang/bin/clangd.exe");
                break;
                
                case _system_.PLATFORM_LINUX:
                if (_system_.getOSBit() == 32){
                    clang_path = CDEProjectPropInterface.appendPath(clang_path, "linux32/clang/bin/clangd");
                }else{
                    clang_path = CDEProjectPropInterface.appendPath(clang_path, "linux64/clang/bin/clangd");
                }
                break;
                
                case _system_.PLATFORM_MACOSX:
                clang_path = CDEProjectPropInterface.appendPath(clang_path, "mac/clang/bin/clangd");
                break;
            }
            
            clangd = String.formatPath(clang_path, false);
        }
        
        String  workDir = cur_project.getProjectDir();
        String [] _clangd_args = {"clangd", "--limit-results=3000", "--compile-commands-dir=\""  + workDir + "\"" }; 
        
        //clangd = "D:\\Cadaqs\\Desktop\\ccls-master\\ccls.exe";
        
        XPlatform.chmodSystemFile(clangd,0777);
        clangdlsp = new LspClient(clangd, _clangd_args, new LspCallback(), workDir);
        
        JsonArray sources = cur_project.getSources();
        
        JsonArray sysdir = CDEProjectPropInterface.getCompilerSystemPath(cur_cfig);
        
        /*String sysmacro = CDEProjectPropInterface.getMacros(cur_cfig);
        sysmacro = sysmacro.replace(" ", " -D"); /*+ " -D__WIDL__ -D_SIZE_T_DEFINED"*/
        String sys_root = " ";// " -isystem \"" + _system_.getAppDirectory().appendPath("plugins/cde/clang/win/clang/lib/clang/10.0.0/include") + "\" " ;
        if (sysdir != nilptr){
            for (int i = 0; i < sysdir.length(); i++){
                sys_root = sys_root + ("-isystem \"" + sysdir.getString(i) + "\" ");
            }
        }
        JsonArray jarray = new JsonArray();
        ProjectPropInterface ppf = cur_project.getPropInterface();
        
        Vector<String> sourceList = new Vector<String>();
        
        String windows_att_flag = "";
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            windows_att_flag = " -mno-mmx -mno-sse -mno-sse2 -mno-sse3 -mno-ssse3 -mno-sse4.1 -mno-sse4.2 --target=i686-pc-mingw32 "/* x86_64-pc-mingw64  i686-pc-mingw32*/;
        }
        for (int i = 0; i < sources.length(); i++) {
            String srcname = sources.getString(i);
            String ext = srcname.findExtension();
            String fname = srcname.findFilenameAndExtension();

            String fullsourcePath = CDEProjectPropInterface.appendPath(workDir, srcname);

            bool avaiable = false;
            if (ext != nilptr && (ext.equalsIgnoreCase(".c") || ext.equalsIgnoreCase(".cpp") || ext.equalsIgnoreCase(".cxx") || ext.equalsIgnoreCase(".m") || 
                ext.equalsIgnoreCase(".mm") || ext.equalsIgnoreCase(".cc") || ext.equalsIgnoreCase(".c++") || ext.equalsIgnoreCase(".cp") || ext.equalsIgnoreCase(".txx") || 
                ext.equalsIgnoreCase(".tpp") || ext.equalsIgnoreCase(".tpl") || ext.equalsIgnoreCase(".h") || ext.equalsIgnoreCase(".hpp"))) 
            {
                String [] arg = ppf.generatorCompArgs(cur_project, cur_cfig, fullsourcePath);
                
                /*if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                    arg[0] = "c++";
                }*/
                String ccmd = "";
                for (int x = 0; x < arg.length; x++){
                    if (ccmd.length() > 0){
                        ccmd = ccmd + " " + arg[x];
                    }else{
                        ccmd = ccmd + arg[x];
                    }
                }
                avaiable = true;
                sourceList.add(fullsourcePath);
                if (!ext.equalsIgnoreCase(".h") && !ext.equalsIgnoreCase(".hpp")){
                    JsonObject jobj = new JsonObject();
                    jobj.put("directory", workDir);
                    jobj.put("command", ccmd + windows_att_flag + sys_root);
                    jobj.put("file", srcname);
                    jarray.put(jobj);
                }
            }
            _filelist.put(fullsourcePath, new Document(avaiable));
        }
        
        String compile_commands = CDEProjectPropInterface.appendPath(workDir, "compile_commands.json");
        
        String content = jarray.toString(true);
        byte [] pbs = content.getBytes();
        
        long hfile = _system_.openFile(compile_commands,"w" );
        if (hfile != 0){
            _system_.writeFile(hfile,pbs,0,pbs.length);
            _system_.closeFile(hfile);
        }
        
        if (clangdlsp.create()){
            initResp = clangdlsp.initializ();
            processInit();
            for (int i = 0; i < sourceList.size(); i++){
                String sc = CPPGPlugManager.getSourceContent(sourceList[i]);
                if (sc != nilptr){
                    clangdlsp.openfile(sourceList[i], sc);
                    //_system_.output("didOpen:" + sourceList[i]);
                }else{
                    //_system_.output("didn't Open:" + sourceList[i]);
                }
                
            }
            return true;
        }
        return false;
    }
    
    public ClangIXIntelliSense(Project project, Configure cfig){
        cur_project = project;
        cur_cfig = cfig;
    }
    
    void setCommand(String cmd, String value)override{
        switch(cmd){
            case "compilationArgs":
                JsonObject obj = new JsonObject(value);
                
            break;
        }
    }
    
    void processInit(){
        try{
            if (initResp != nilptr){
                JsonObject initobj = new JsonObject(initResp);
                if (initobj != nilptr){
                    JsonObject result = (JsonObject)initobj.get("result");
                    if (result != nilptr){
                        JsonObject capabilities =  (JsonObject)result.get("capabilities");
                        if (capabilities != nilptr){
                            JsonObject completionProvider =  (JsonObject)capabilities.get("completionProvider");
                            if (completionProvider != nilptr){
                                JsonArray triggerCharacters = (JsonArray)completionProvider.get("triggerCharacters");
                                if (triggerCharacters != nilptr){
                                    trigge_chars = new char[triggerCharacters.length()];
                                    for (int i =0; i < triggerCharacters.length(); i ++){
                                        String item = triggerCharacters.getString(i);
                                        if (item.length() > 0){
                                            trigge_chars[i] = item.charAt(0);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }catch(Exception e){
            
        }
    }
    void appendLibpath(String path)override{
        
    }
    
    void appendLib(String path)override{
        
    }
    
    void appendLink(String path)override{
        
    }
    
    void addSource(String source)override{
        String ext = source.findExtension();
        bool avaiable = true;
        
        if (ext != nilptr){
            ext = ext.lower();
            switch(ext){
                case ".cpp":
                case ".c":
                case ".cxx":
                case ".c++":
                case ".mm":
                case ".m":
                case ".cc":
                case ".txx":
                case ".tpp":
                case ".tpl":
                case ".h":
                case ".hpp":
                    avaiable = true;
                break;
                default:
                    avaiable = false;
                break;
            }
        }
        
        _filelist.put(source, new Document(avaiable));
        
        if (avaiable){
            String sc = CPPGPlugManager.getSourceContent(source);
            if (sc != nilptr){
                clangdlsp.openfile(source, sc);
            }
        }
    }
    
    XIntelliResult [] getIntelliSenseL(String source,int line, int column)override{
        String complete_res = nilptr;
        synchronized(this){
            __completion_result = nilptr;
            complete_res = clangdlsp.completion(source, line, 1);
        }
        return parseResult(complete_res);
    }
    
    XIntelliResult [] getIntelliSenseObject(String source,int line, int column, String name)override{
        String complete_res = nilptr, complete_are;
        synchronized(this){
            __completion_result = nilptr;
            complete_res = clangdlsp.getDefinition(source, line, column);
            complete_are = clangdlsp.getDeclare(source, line, column);
        }
        return parseDefinitionAndDelare(complete_res, complete_are);
    }
    
    
    void parseDefinitionItem(String result, Vector<XIntelliResult> xrs){
        if (result == nilptr){
            return ;
        }
        
        JsonObject jres = new JsonObject(result);
        if (jres == nilptr){
            return ;
        }
        if (false == jres.has("result")){
            return ;
        }

        JsonArray jarrs = (JsonArray)jres.get("result");
        
        
        for (int i =0; i < jarrs.length(); i++){
            JsonObject item = (JsonObject)jarrs.get(i);
            JsonObject range = (JsonObject)item.get("range");
            
            JsonObject start = (JsonObject)range.get("start");
            JsonObject end = (JsonObject)range.get("end");
            String uri = URIConvertFilePath(item.getString("uri"));
            
            CDEXIntelliResult xr = new CDEXIntelliResult();
            xr.line = start.getInt("line");
            xr.row = start.getInt("character") + 1;
            xr.source = uri;
            
            xr.name = xr.prop = "";
            xrs.add(xr);
        }
        
    }
    XIntelliResult [] parseDefinitionAndDelare(String result, String dlar){
        Vector<XIntelliResult> xrs = new Vector<XIntelliResult>();
        
        parseDefinitionItem(result, xrs);
        
        parseDefinitionItem(dlar, xrs);
        
        return xrs.toArray(new XIntelliResult[0]);
    }
    
    static String URIConvertFilePath(String uri){
        if (uri != nilptr){
            uri = uri.decodeURI();
            
            if (uri.startWith("file:///")){
                if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                    return uri.substring(8, uri.length());
                 }   else{
                    return uri.substring(7, uri.length());
                 }
            }
        }
        return uri;
    }
    
    XIntelliResult [] getIntelliSenseObjectM(String source,int line)override{
        String complete_res = nilptr;
        synchronized(this){
            __completion_result = nilptr;
            complete_res = clangdlsp.completion(source, line, 1);
        }
        return parseResult(complete_res);
    }
    
    XIntelliResult [] getIntelliSense(String source,String content, long pos, int line, int column)override{
        String complete_res = nilptr;
        synchronized(this){
            __completion_result = nilptr;
            clangdlsp.filechange(source, content);
            complete_res = clangdlsp.completion(source, line, column);
        }
        return parseResult(complete_res);
    }
    
    public class CDEXIntelliResult : XIntelliResult{
        JsonObject item;
        bool parsed = false;
        public String name;
        public int type;
        public String prop;
        public CDEXIntelliResult _class;
        public CDEXIntelliResult[] params;
        public String source;
        public int line;
        public int row;
        
        public CDEXIntelliResult [] processParams(String args) {
            byte []data = args.getBytes();
            Vector<CDEXIntelliResult> args_list = new Vector<CDEXIntelliResult>();
            int start = 0;
            byte bskip = 0;

            for (int i = 0; i < data.length; i++) {
                byte b = data[i];
                if (b == '('){ bskip = ')' ;}
                if (b == '['){ bskip = ']' ;}
                if (b == '<'){ bskip = '>' ;}
                
                if (bskip == 0){
                    if (b == ','){
                        CDEXIntelliResult pm = new CDEXIntelliResult();
                        pm.name = "";
                        pm._class = new CDEXIntelliResult();
                        pm._class.name = args.substring(start,i);
                        
                        args_list.add(pm);
                        start = i + 1;
                    }
                }else
                if (b == bskip){
                    bskip = 0;
                }
            }

            if (start < data.length) {
                CDEXIntelliResult pm = new CDEXIntelliResult();
                pm.name = "";
                pm._class = new CDEXIntelliResult();
                pm._class.name = args.substring(start, args.length());
                
                args_list.add(pm);
            }
            return args_list.toArray(new CDEXIntelliResult[0]);
        }
        
        void parse(){
            if (parsed){
                return;
            }
            parsed = true;
            int kind = item.getInt("kind");
            if (kind == 2 || kind == 3){
                type = 23;
            }else{
                type = 31;
            }
            String detail = item.getString("detail");
            String text  = item.getString("insertText");
            if (text == nilptr){
                JsonObject textEdit = (JsonObject)item.get("textEdit");
                text = textEdit.getString("newText");
            }
            if (text == nilptr){
                text = item.getString("filterText");
            }
            if (text == nilptr){
                text = item.getString("label");
            }
            String label = item.getString("label");
            
            if (type == 23 && label != nilptr){
                int pl = label.indexOf("(",0);
                if (pl > 0 && pl < label.length()){
                    int pr =  label.lastIndexOf(")");
                    if (pr != -1 && pr > pl){
                        if (label.indexOf("(", pl + 1) != -1 || label.indexOf("[", pl + 1) != -1 || label.indexOf("<", pl + 1) != -1){
                            params = processParams(label.substring(pl + 1, pr));
                        }else{
                            label = label.substring(pl + 1,pr);
                            String [] params_str = label.split(',');
                            params = new CDEXIntelliResult[params_str.length];
                            for (int i = 0; i < params.length; i++){
                                CDEXIntelliResult pm = new CDEXIntelliResult();
                                pm.name = "";
                                pm._class = new CDEXIntelliResult();
                                pm._class.name = params_str[i];
                                params[i] = pm;
                            }
                        }
                    }
                }
            }
            //String _sort_key = item.getString("sortText");
            
            name = text;
            

            _class = new CDEXIntelliResult();
            _class.parsed = true;
            if (detail != nilptr){
                _class.name = detail.replace("\n", " ↩ ")
							.replace("\r", " ↵ ")
							.replace("\t", " ⇥ ")
                            .replace("\b", " ⇤ ");
            }else{
                _class.name = "?";
            }
            prop = "";
        }
        
        public CDEXIntelliResult(JsonObject ji){
            item = ji;
        }
        public CDEXIntelliResult(){
            parsed = true;
        }
        String get_name(){
            parse();
            return name;
        }
        
        int get_type(){
            parse();
            return type;
        }
        bool hasProp(char c){
            parse();
            return prop.indexOf(c) != -1;
        }
        XIntelliResult get_class(){
            parse();
            return _class;
        }
        XIntelliResult[] get_params(){
            parse();
            return params;
        }
        String get_source(){
            parse();
            return source;
        }
        int get_line(){
            parse();
            return line;
        }
        int get_row(){
            parse();
            return row;
        }
    };
    
    XIntelliResult [] parseResult(String result){
        if (result == nilptr){
            return nilptr;
        }
        
        JsonObject jres = new JsonObject(result);
        if (jres == nilptr){
            return nilptr;
        }
        if (false == jres.has("result")){
            return nilptr;
        }

        JsonObject restuls = (JsonObject)jres.get("result");
        
        if (false == restuls.has("items")){
            return nilptr;
        }
        JsonArray jarrs = (JsonArray)restuls.get("items");
        
        //Vector<XIntelliResult> xrs = new Vector<XIntelliResult>();
        
        //_system_.output("\n start:" + _system_.currentTimeMillis() + "\n");
        

        //for (int i = 0, c = jarrs.length(); i < c; i++)
        CDEXIntelliResult [] outs = new CDEXIntelliResult[jarrs.length()];
        int pos = 0;
        JsonObject item = (JsonObject)jarrs.child();
        
        while(item != nilptr) {
            outs[pos++] = new CDEXIntelliResult(item);
            item = (JsonObject)item.next();
        }
        
        //_system_.output("\n end:" + _system_.currentTimeMillis() + "\n");
        
        return outs;//xrs.toArray(new XIntelliResult[0]);
    }
    
    
    enum SymbolKind {
        File = 1,
        Module = 2,
        Namespace = 3,
        Package = 4,
        Class = 5,
        Method = 6,
        Property = 7,
        Field = 8,
        Constructor = 9,
        Enum = 10,
        Interface = 11,
        Function = 12,
        Variable = 13,
        Constant = 14,
        String = 15,
        Number = 16,
        Boolean = 17,
        Array = 18,
        Object = 19,
        Key = 20,
        Null = 21,
        EnumMember = 22,
        Struct = 23,
        Event = 24,
        Operator = 25,
        TypeParameter = 26
    };

    int kind2type(int kd){
        switch(kd){
            case SymbolKind.Module:
            case SymbolKind.Namespace:
            case SymbolKind.Package:
            case SymbolKind.Class:
            case SymbolKind.Interface:
            case SymbolKind.Enum:
            return 31;
            break;
            
            case SymbolKind.Method:
            case SymbolKind.Function:
            return 23;
            
            break;
        }
        return 18;
    }
    
    
    class ObjectDesxcr {
        JsonObject obj;
        int l = 0, r = 0, el = 0, er = 0;
        public ObjectDesxcr(JsonObject j, int _l, int _r, int _el, int _er){
            obj = j;
            l = _l;
            r = _r;
            el = _el;
            er = _er;
        }
        public bool isContain(JsonObject sub, int type, int line, int row, int eline, int erow){
            if ((line == l && row > r ) || line > l){
                if ((eline == el && erow < er)  || eline < el){
                    JsonArray method_prt = (JsonArray)obj.get("method");
                    JsonArray properites_prt = (JsonArray)obj.get("properites");
                    
                    if (type == 23){
                        method_prt.put(sub);
                    }else{
                        properites_prt.put(sub);
                    }
                    return true;
                }
            }
            return false;
        }
    };
    
    String getIntelliSenseMap()override{
    
        updateDocumentSymbols();
        
        Map.Iterator<String, Document> iter = _filelist.iterator();
        
        Map<String, JsonObject> structmap = new Map<String, JsonObject>();
        JsonArray sources = new JsonArray();
        JsonArray heap = new JsonArray();
        Map<String, int> source_list = new Map<String, int>();
        
        int glv = 0, glf = 0;
        
        JsonObject globalObj = new JsonObject();
        JsonArray gvar , gproc;
        {
            globalObj.put("name", "全局对象");
            
            
            globalObj.put("type", 31);
            //typeobj String 类型
            //interface bool 接口
            //package bool 是否包
            //template bool 是否模板
            //base String 基类型名称
            
            JsonArray properites = new JsonArray();
            JsonArray static_properites = new JsonArray();
            JsonArray method = new JsonArray();
            JsonArray static_method = new JsonArray();
            
            gvar = properites;
            globalObj.put("properites", properites);
            
            globalObj.put("static_properites", static_properites);
            globalObj.put("method", method);
            globalObj.put("static_method", static_method);
        }
        
        JsonObject globalFun = new JsonObject();
        {
            globalFun.put("name", "全局方法");
            
            
            globalFun.put("type", 31);
            //typeobj String 类型
            //interface bool 接口
            //package bool 是否包
            //template bool 是否模板
            //base String 基类型名称
            
            JsonArray properites = new JsonArray();
            JsonArray static_properites = new JsonArray();
            JsonArray method = new JsonArray();
            JsonArray static_method = new JsonArray();
            gproc = method;
            globalFun.put("properites", properites);
            globalFun.put("static_properites", static_properites);
            globalFun.put("method", method);
            globalFun.put("static_method", static_method);
        }
                                
        while (iter.hasNext()){
            String file = iter.getKey();
            Document doc = iter.getValue();
            if (doc.isEnabled && doc.symbols != nilptr){// 34 template， 31 类， 23 function， 18 var;

                JsonObject item = new JsonObject(doc.symbols);
                if(source_list.containsKey(file) == false){
                    source_list.put(file, sources.length());
                    sources.put(file);
                }
                
                JsonArray result = (JsonArray)item.get("result");
                
                if (result != nilptr){
                    JsonObject obj = (JsonObject)result.child();
                    List<ObjectDesxcr> parentstack = new List<ObjectDesxcr>();
                    ObjectDesxcr parent  = nilptr;
                    while(obj != nilptr){
                        JsonObject object = nilptr;
                        
                        String name = obj.getString("name");

                        String containerName = obj.getString("containerName");
                        
                        int nsp = name.indexOf("::",0);
                        if (nsp != -1){
                            containerName = name.substring(0,nsp); 
                        }
                        int type = kind2type(obj.getInt("kind"));
                        
                        Map.Iterator<String, JsonObject> my_iter = nilptr;
                        
                        bool minor_obj = false;
                        
                        if (type == 31){
                            my_iter = structmap.find(name);
                            if (my_iter != nilptr){
                                object = my_iter.getValue();
                                if (object.has("line") == false){
                                    if (object.getInt("type") == 85){
                                        object.remove("type");
                                        object.put("type", 31);
                                        //_system_.output("find pre pro" + name + ":" + object.toString(true));
                                    }else
                                    if (object.getInt("type") != 31){
                                        my_iter = nilptr;
                                    }else{
                                        minor_obj = true;
                                    }
                                }else{
                                    object = nilptr;
                                    my_iter = nilptr;
                                }
                            }
                        }
                        
                        if (minor_obj == false){
                            if (my_iter == nilptr){
                                object = new JsonObject();
                                
                                object.put("name", name);
                                
                                
                                object.put("type", type);
                                //typeobj String 类型
                                //interface bool 接口
                                //package bool 是否包
                                //template bool 是否模板
                                //base String 基类型名称
                                
                                JsonArray properites = new JsonArray();
                                JsonArray static_properites = new JsonArray();
                                JsonArray method = new JsonArray();
                                JsonArray static_method = new JsonArray();
                                
                                object.put("properites", properites);
                                object.put("static_properites", static_properites);
                                object.put("method", method);
                                object.put("static_method", static_method);
                            }
                            
                            int line = 0, row = 0;
                            int eline = 0, erow = 0;
                            
                            JsonObject location = (JsonObject)obj.get("location");
                            if (location != nilptr){
                                String uri = URIConvertFilePath(location.getString("uri"));
                                
                                if(source_list.containsKey(uri)){
                                    object.put("source", source_list.get(uri));
                                }else{
                                    object.put("source", sources.length());
                                    source_list.put(uri, sources.length());
                                    sources.put(uri);
                                }
                                
                                JsonObject range = (JsonObject)location.get("range");
                                if (range != nilptr){
                                    JsonObject start = (JsonObject)range.get("start");
                                    if (start != nilptr){
                                        line = start.getInt("line");
                                        row = start.getInt("character");
                                    }
                                    
                                    start = (JsonObject)range.get("end");
                                    if (start != nilptr){
                                        eline = start.getInt("line");
                                        erow = start.getInt("character");
                                    }
                                }
                            }
                            
                            object.put("line",line);
                            object.put("column",row);
                            object.put("eline",eline);
                            object.put("ecolumn",erow);
                            
                            bool bAdded = false;
                            
                            while (parent != nilptr){
                                if (parent.isContain(object, type, line, row, eline, erow) == false){
                                    parent = nilptr;
                                    if (parentstack.size() > 0){
                                        parent = parentstack.pollLast();
                                    }
                                }else{
                                    bAdded = true;
                                    break;
                                }
                            }
                            
                            if (bAdded == false && containerName != nilptr && containerName.length() != 0){
                                Map.Iterator<String, JsonObject> parent_iter = structmap.find(containerName);
                                
                                JsonObject _parent;
                                
                                if (parent_iter == nilptr){
                                    _parent = makeParent(containerName, object, type);
                                    structmap.put(containerName, _parent);
                                    bAdded = true;
                                }else{
                                    _parent = parent_iter.getValue();
                                    if (_parent != nilptr){
                                        JsonArray method_prt = (JsonArray)_parent.get("method");
                                        JsonArray properites_prt = (JsonArray)_parent.get("properites");
                                        
                                        if (type == 23){
                                            method_prt.put(object);
                                        }else{
                                            properites_prt.put(object);
                                        }
                                        bAdded = true;
                                    }
                                }
                            }
                            
                            if (type == 31){
                                if (parent != nilptr){
                                    parentstack.add(parent);
                                }
                                parent = new ObjectDesxcr(object, line, row, eline, erow);
                            }
                            
                            if (bAdded == false){
                                if (type == 31){
                                    if (name.startWith("(") == false){
                                        heap.put(object);
                                    }
                                }else
                                if (type == 23){
                                    gproc.put(object);glf++;
                                }else{
                                    gvar.put(object);glv++;
                                }
                            }
                            if (type == 31){
                                structmap.put(name, object);
                            }
                        }
                        obj = (JsonObject)obj.next();
                    }
                }
            }
            iter.next();
        }
        
        
        JsonObject full_map = new JsonObject();
        full_map.put("sources", sources);
        if (glv > 0){
            heap.put(globalObj);
        }
        if (glf > 0){
            heap.put(globalFun);
        }
        full_map.put("heap", heap);
        
        return full_map.toString(false);
    }
    
    
    JsonObject makeParent(String name, JsonObject psub, int type){
        JsonObject object = new JsonObject();
        object.put("name", name);
        object.put("type", 85);
        
        JsonArray properites = new JsonArray();
        JsonArray static_properites = new JsonArray();
        JsonArray method = new JsonArray();
        JsonArray static_method = new JsonArray();
        
        if (type == 23){
            method.put(psub);
        }else{
            properites.put(psub);
        }
        
        object.put("properites", properites);
        object.put("static_properites", static_properites);
        object.put("method", method);
        object.put("static_method", static_method);
        return object;
    }
    
    void update(String sourcePath, String content)override{
        synchronized(this){
            clangdlsp.filechange(sourcePath, content);
        }
    }
    
    
    bool updateDocumentSymbols(){
        Map.Iterator<String, Document> iter = _filelist.iterator();
        while (iter.hasNext()){
            String file = iter.getKey();
            Document doc = iter.getValue();
            if (doc.isEnabled){
                if (nilptr == (doc.symbols = clangdlsp.getDocumentSymbols(file))){
                    return false;
                }
            }
            iter.next();
        }
        return true;
    }
    
    WordRecognizer getWordRecognizer(String filepath)
    {
        return new WordRecognizer(){
            bool isWord(char c, bool first)override{
                return ((c =='_') || (c >= 'a' && c <='z') || (c >= 'A' && c <='Z') || ((first == false) && (c >= '0' && c <= '9')));
            }
            
            bool isTriggedChar(char c)override{
                if (trigge_chars != nilptr){
                    for (int i =0; i < trigge_chars.length; i++){
                        if (trigge_chars[i] == c){
                            return true;
                        }
                    }
                }
                return false;
            }
            
            bool isDocument(String ext)override{
                if (ext != nilptr && (ext.equalsIgnoreCase(".c") || ext.equalsIgnoreCase(".cpp") || ext.equalsIgnoreCase(".cxx") || ext.equalsIgnoreCase(".m") || 
                        ext.equalsIgnoreCase(".mm") || ext.equalsIgnoreCase(".cc") || ext.equalsIgnoreCase(".c++") || ext.equalsIgnoreCase(".cp") || ext.equalsIgnoreCase(".txx") || 
                        ext.equalsIgnoreCase(".tpp") || ext.equalsIgnoreCase(".tpl")|| ext.equalsIgnoreCase(".h")|| ext.equalsIgnoreCase(".hpp"))) 
                    {
                        return true;
                    }
                return false;
            }
            String getFileFilter(String filepath, bool bopen){
                return nilptr;
            }
        };
    }
    void updateSource(String sourcePath, String newFile)override{
        
    }
    
    XIntelliResult [] getResult()override{
        return nilptr;
    }
    
    void close()override{
        clangdlsp.quit();
    }
};