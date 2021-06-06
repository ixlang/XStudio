//xlang Source, Name:LspClient.x 
//Date: Tue Apr 13:57:47 2020 

class LspClient{
    public interface LspListener {
        void onCallBack(JsonObject);
        void onDiagnostics(String file, JsonArray msg);
    };
    
    LspListener _ls = nilptr;
    String _serverPath;
    String [] _args;
    Process lsp_process;
    String workdir;
    bool bExit = false;
    
    public LspClient(String serverPath, String [] args, LspListener lis, String workDir){
        _serverPath = serverPath;
        _args = args;
        _ls = lis;
        workdir = workDir;
    }
    
    class LSPRequest{
        String id;
        public String result;
        
        public LSPRequest(String _id){
            id = _id;
        }
    };
    
    Map<String, LSPRequest> _resuestList = new Map<String, LSPRequest>();
    
    public bool create(){
       if (_serverPath == nilptr || _ls == nilptr) {
           return false;
       }
       
       lsp_process = new Process(_serverPath, _args);
       lsp_process.setWorkDirectory(workdir);
       try{
          if (lsp_process.create(Process.StdOut | Process.StdIn | Process.StdErr)){
           readLoop();
           return true;
          } 
       }catch(Exception e){
           
       }
       return false;
    }
    
    class jsonrpcContext{
        JsonRPC text;
        
        public jsonrpcContext(JsonRPC tx){
            text = tx;
        }
        
        int d2rn = -1, lenofst = -1, line_end = -1, length = -1;
        
        public void reset(){
            d2rn = -1;
            lenofst = -1;
            line_end = -1;
            length = -1;
        }
        
        public int get_d2rn(){
            if (d2rn == -1){
                d2rn = text.indexOf("\r\n\r\n", 0);
            }
            return d2rn;
        }
        
        public int get_lenofst(){
            if (lenofst == -1){
                lenofst = text.lastIndexOf("Content-Length:", d2rn);
            }
            return lenofst;
        }
        
        public int get_line_end(){
            if (line_end == -1){
                line_end = text.indexOf("\n", lenofst);
            }
            return line_end;
        }
        
        public int get_length(){
            if (length == -1){
                String strlen = text.substring(lenofst + 15, line_end).trim(true);
                length = Math.parseInt(strlen, 10);
            }
            return length;
        }
        
        public @NotNilptr String substring(int s, int e){
            return text.substring(s, e);
        }
        
        public void remove(int len){
            reset();
            text.remove(len);
        }
        
        public void clear(){
            reset();
            text.clear();
        }
        
        public int length(){
            return text.length();
        }
    };
    
    void readLoop(){       
        new Thread(){
            void run()override{
                Thread.setName("LSP Err Reader");
                byte [] buf = new byte[4096];

                int n = 0;
                    
                try{
                    while (0 < (n = lsp_process.readError(buf,0,4096))){
                        //_system_.output(new String(buf, 0, n));
                    }
                }catch(Exception e){
                
                }finally{
                }
            }
        }.start();
        
        new Thread(){
            void run()override{
                Thread.setName("LSP Reader");
                byte [] buf = new byte[4096];
                //_system_.createConsole();
                String text = "";
                JsonRPC jsonp = new JsonRPC();
                jsonrpcContext jctx = new jsonrpcContext(jsonp);
                
                int n = 0;
                    
                try{
                    while (0 < (n = lsp_process.read(buf,0,4096))){
                        //_system_.output(new String(buf, 0, n));
                        jsonp.append(buf, 0, n);
                        processText(jctx);
                    }
                }catch(Exception e){
                    //_system_.output(e.getMessage());
                }finally{
                    //_system_.output("clangd quit:" + n + "\n lastread:" + jsonp.toString());
                }
            }
        }.start();
    }
    
    void processText(@NotNilptr jsonrpcContext jrpc){
        int d2rn = jrpc.get_d2rn();
        
        while (d2rn != -1){
            int lenofst = jrpc.get_lenofst();
            
            if (lenofst != -1){
                int line_end = jrpc.get_line_end();
                int length = jrpc.get_length();
                
                int start = d2rn + 4;
                int endofst = start + length;
                
                if (endofst <= jrpc.length() && start < jrpc.length()){
                    jrpc.reset();
                    
                    String content = jrpc.substring(start, endofst);
                    
                    JsonObject json = new JsonObject(content);
                    
                    LSPRequest lsq = nilptr;
                    
                    if (json.has("id")){
                        String sid = json.getString("id");
                        synchronized(this){
                            Map.Iterator<String, LSPRequest> iter = _resuestList.find(sid);
                            if (iter != nilptr){
                                lsq = iter.getValue();
                                _resuestList.remove(iter);
                            }
                        }
                        
                    }
                    
                    if (lsq == nilptr){
                        bool bcallback = true;
                        if (json.has("method")){
                            String method= json.getString("method");
                            if (method == NotifyDiagnostics){
                                bcallback = false;
                                JsonArray diagnostics = nilptr;
                                String file = nilptr;
                                try{
                                    
                                	JsonObject param = (JsonObject)json.get("params");
                                    file = param.getString("uri");
                                    diagnostics = (JsonArray)param.get("diagnostics");
                                }catch(Exception e){
                                	
                                }

                                if (file != nilptr && diagnostics != nilptr && (diagnostics.length() > 0)){
                                    if (file.startWith("file:///")){
                                        file = file.substring(8, file.length());
                                    }
                                    _ls.onDiagnostics(file, diagnostics);
                                }
                            }
                        }
                        if (bcallback){
                            _ls.onCallBack(json);
                        }
                    }else{
                        synchronized(lsq){
                            lsq.result = content;
                            lsq.notify();
                        }
                    }
                    
                    if (endofst < jrpc.length()){
                        jrpc.remove(endofst) ;//= text.substring(endofst, text.length());
                    }else{
                        jrpc.clear();
                        break;
                    }
                }else{
                    break;
                }
            }else{
                jrpc.reset();
                jrpc.remove(d2rn) ;//text = text.substring(d2rn, text.length());
            }
            d2rn = jrpc.get_d2rn();
        }
        
    }
    
    static const String MethodInitializ = "initialize", 
        MethodDidOpen = "textDocument/didOpen",
        MethodDidClose = "textDocument/didClose",
        MethodCompletion = "textDocument/completion",
        MethodHover = "textDocument/hover",
        didChangeConfiguration = "workspace/didChangeConfiguration",
        didChangeContent = "textDocument/didChange",
        MethodDefinition = "textDocument/definition",
        MethodDeclaration = "textDocument/declaration",
        MethodCompletionItemResolve = "completionItem/resolve",
        MethodDocumentSymbol = "textDocument/documentSymbol", //{"jsonrpc":"2.0","id":2,"method":"textDocument/documentSymbol","params":{"textDocument":{"uri":"test:///main.cpp"}}}
        MethodWorkspaceSymbol = "workspace/symbol",//{"jsonrpc":"2.0","id":1,"method":"workspace/symbol","params":{"query":"vector"}}
        MethodImplementation = "textDocument/implementation",
        MethodReferences = "textDocument/references",
        NotifyDiagnostics = "textDocument/publishDiagnostics";
    
    void notify(@NotNilptr String method, JsonNode params){
        JsonObject json = new JsonObject();
        json.put("jsonrpc","2.0");
        json.put("method",method);
        if (params != nilptr){
            json.put("params" ,params);
        }
        writeJsonRpc(json);
    }

    void exit(){
        notify("exit", nilptr);
    }

    String request(int id, String method,@NotNilptr  JsonNode params){
        JsonObject json = new JsonObject();
        json.put("jsonrpc","2.0");
        json.put("id", method);
        json.put("method",method);
        json.put("params" ,params);
        return writeJsonRpc(json);
    }

    String writeJsonRpc(@NotNilptr JsonObject json){
        String jsstr = json.toString(false) + "\n";
        String final_Str = "Content-Length: " + jsstr.length() + 
            "\r\n" + "Content-Type:charset-utf-8" + 
            "\r\n\r\n" + jsstr ;
        
        byte[] data = final_Str.getBytes();
        
        LSPRequest lsq = nilptr;
        
        synchronized(this){
            if (bExit){
                return nilptr;
            }
            
            if (json.has("id")){
                String sid = json.getString("id");
                lsq = new LSPRequest(sid);
                _resuestList.put(sid, lsq);
            }
        }
        
        try{
            if (lsq != nilptr){
                synchronized(lsq){
                    lsp_process.write(data,0,data.length);
                    lsq.wait();
                    return lsq.result;
                }
            }else{
                lsp_process.write(data,0,data.length);
            }
        }catch(Exception e){
            
        }
        return nilptr;
    }

    JsonObject initworkspaceEdit(){
        JsonObject workspaceEdit = new JsonObject();
        workspaceEdit.put("documentChanges",true);
        workspaceEdit.put("normalizesLineEndings",true);
            JsonArray resourceOperations = new JsonArray();
            resourceOperations.put("create");
            resourceOperations.put("rename");
            resourceOperations.put("delete");
        workspaceEdit.put("resourceOperations", resourceOperations);
            JsonObject changeAnnotationSupport = new JsonObject();
            changeAnnotationSupport.put("groupsOnLabel", true);
        workspaceEdit.put("changeAnnotationSupport", changeAnnotationSupport);
        return workspaceEdit;
    }
    
    public JsonObject inittextDocument(){
        JsonObject textDocument = new JsonObject();
        textDocument.put("completion", initCompletion());
        textDocument.put("hover", initHoverClientCapabilities());
        return textDocument;
    }
    
    public JsonObject initHoverClientCapabilities(){
        JsonObject completion = new JsonObject();
        JsonArray jar = new JsonArray();
        //jar.put("markdown");
        jar.put("plaintext");
        completion.put("contentFormat", jar);
        completion.put("dynamicRegistration", true);
        return completion;
    }
    
    public JsonObject initCompletion(){
        JsonObject completion = new JsonObject();
        completion.put("contextSupport", true);
        completion.put("dynamicRegistration", true);
        return completion;
    }
    
    public JsonObject initworkspacesymbol(){
        JsonObject workspacesymbol = new JsonObject();
        workspacesymbol.put("dynamicRegistration", true);
        
        JsonArray symbolKind = new JsonArray();
        for (int i =1; i < 27; i++)
            symbolKind.put(i);
        workspacesymbol.put("symbolKind", symbolKind);
        
        symbolKind = new JsonArray();
        symbolKind.put(1);
        workspacesymbol.put("tagSupport", symbolKind);
        
        return workspacesymbol;
    }
    
    public JsonObject initworkspace(){
        JsonObject workspace = new JsonObject();
        workspace.put("applyEdit",true);
        workspace.put("configuration",true);
        
        JsonObject didChangeConfiguration = new JsonObject();
        didChangeConfiguration.put("dynamicRegistration", true);
        workspace.put("didChangeConfiguration", didChangeConfiguration);
        
        JsonObject didChangeWatchedFiles = new JsonObject();
        didChangeWatchedFiles.put("dynamicRegistration", true);
        workspace.put("didChangeWatchedFiles", didChangeWatchedFiles);
        workspace.put("workspaceEdit",initworkspaceEdit());
        workspace.put("symbol",initworkspacesymbol());
        return workspace;
    }
    
    public JsonObject initcapabilities(){
        JsonObject capabilities = new JsonObject();
        capabilities.put("workspace", initworkspace());
        capabilities.put("textDocument", inittextDocument());
        return capabilities;
    }
    
    public String initializ(){
        
        JsonObject param = new JsonObject();
        param.put("trace", "off");
        param.put("rootPath", workdir);
        param.put("rootUri", "file:///" + workdir);
        
        JsonObject compilationDatabasePath = new JsonObject();
        compilationDatabasePath.put("compilationDatabasePath", workdir);
        param.put("initializationOptions", compilationDatabasePath);
        
        param.put("capabilities", initcapabilities());
        /*JsonObject workspaceFolders = new JsonObject();
        workspaceFolders.put("name", "");
        workspaceFolders.put("uri", "file:///" + workdir);
        param.put("workspaceFolders", workspaceFolders);*/
        
        return request(0, MethodInitializ, param);
    }
    
    
    public void openfile(String filename, String text){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        if (text == nilptr){
            text = readFileUTF8(filename);
        }
        
        if (text == nilptr){
            return ;
        }
        param.put("languageId", "cpp");
        param.put("version", 2);
        param.put("text", text);
        
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        notify(MethodDidOpen, doc);
    }
    
    public void closefile(String filename, String text){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        if (text == nilptr){
            text = readFileUTF8(filename);
        }
        
        if (text == nilptr){
            return ;
        }
        param.put("languageId", "cpp");
        param.put("version", 2);
        param.put("text", text);
        
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        notify(MethodDidOpen, doc);
    }
    
    public void filechange(String filename, String text){
        JsonObject param = new JsonObject();
        
        JsonObject doc = new JsonObject();
        doc.put("uri", "file:///" + filename);
        doc.put("version", 2);
        
        
        param.put("textDocument",doc);
        param.put("version", 2);
        param.put("isSaved", false);
        
        JsonObject content = new JsonObject();
        content.put("text", text);
        
        JsonArray contents = new JsonArray();
        contents.put(content);
        
        param.put("contentChanges", contents);
        notify(didChangeContent, param);
    }
    
    public String getDefinition(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
            
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodDefinition, doc);
    }
    
    public String getDeclare(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
            
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodDeclaration, doc);
    }
    
    
    
    public String getReferences(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
            
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodReferences, doc);
    }
    
    public String getImplement(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
            
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodImplementation, doc);
    }
    
    public String getWorkspaceSymbols(){
        JsonObject doc = new JsonObject();
        doc.put("query","");
        return request(0, MethodWorkspaceSymbol, doc);
    }
    
    public String getDocumentSymbols(String filename){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        return request(0, MethodDocumentSymbol, doc);
    }
    
    public String completion(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
        
        JsonObject context = new JsonObject();
        context.put("triggerKind", 1);
        //context.put("TriggerCharacter", "w");
        param.put("context",context);
        
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodCompletion, doc);
    }
    
    public String hover(String filename, int line, int col){
        JsonObject param = new JsonObject();
        param.put("uri", "file:///" + filename);
        
        JsonObject position = new JsonObject();
        position.put("line", line);
        position.put("character", col);
                
        JsonObject doc = new JsonObject();
        doc.put("textDocument",param);
        doc.put("position", position);
        return request(0, MethodHover, doc);
    }
    
    String readFileUTF8(@NotNilptr String file){
        long hfile = _system_.openFile(file,"r");
        if (hfile != 0 ){
            long fl = _system_.fileLength(hfile);
            byte [] data = new byte [fl];
            _system_.readFile(hfile,data,0,fl);
            _system_.closeFile(hfile);
            try{
                String charset = String.detectCharset(data,0,fl);
                                
                switch(charset){
                    case "ASCII":
                    case "UTF-8":
                    case "UTF8":
                    return new String(data);
                    break;
                    
                    default:
                    return new String(data, 0, fl, charset);
                    break;
                }
            }catch(Exception e){
                return new String(data);
            }
        }
        return nilptr;
    }
    
    void notifyQuit(){
        synchronized(this){
            bExit = true;
            
            Map.Iterator<String, LSPRequest> iter = _resuestList.iterator();
            while (iter.hasNext()){
                LSPRequest lsq = iter.getValue();
                __nilptr_safe(lsq);
                synchronized(lsq){
                    lsq.notifyAll();
                }
                iter.next();
            }
            _resuestList.clear();
        }
    }
    
    public void quit(){
        if (lsp_process != nilptr){
            exit();
        }
        notifyQuit();
    }
};