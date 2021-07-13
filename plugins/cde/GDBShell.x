//xlang Source, Name:GDBShell.x 
//Date: Wed Mar 14:22:00 2020 

class GDBShell{
    long debug_port = -1;
    int _dbgserial;
    
    Process _gdb_process;
    Stream _xp, _client_pipe;
    IBuilder __builder;
    String gdbPath = nilptr;
    int DEBUG_TYPE = 0; //0 normal 1 attach 2 remote
    
    String [] target_args;
    bool bExit = false;
    bool support_non_stop = false;
    int debuggee_type = 0;
    public Process termina_process;
    static const int DEBUGGEE_GDB = 1, DEBUGGEE_LLDB = 2;
    static const int 	
		Unknow = 0,
		Interrupt = 1,
		Continue = 2,
		StepIn = 3,
		StepOver = 4,
		StepOut = 5,
		SetBreakPoint = 6,
		SetMemoryBreakPoint = 7,
		SetFunctionBreakPoint = 8,
		QueryStackStruct = 9,
		QueryStackObject = 10,
		QueryStackObjectDetails = 11,
		QueryHeapStruct = 12,
		QueryHeapObject = 13,
		QueryHeapObjectDetails = 14,
		QueryThreadCount = 15,
		QueryStackFrame = 16,
		SwitchThread = 17,
		QueryFrame = 18,
		QueryMemoryInfo = 19,
		GC = 20,
        Log = 21,
        TriggeBreakPoint = 22,
        WatchObject = 23,
        Active = 24,
        ExceptionInterrput = 25,
        Debug = 26,
        QueryObject = 27,
        GcDump = 28,
        QueryByName = 29,
        ModuleLoaded = 30,
        LookupMemory = 31,
        DumpMemory = 32,
        GCInfo = 33,
        DBGExit = 34,
        MessageBox = 35,
        MessageBoxReply = 36;
            
    public Stream getPipe(){
        //if (_client_pipe.createstream())
        {
            return _client_pipe;
        }
        return nilptr;
    }
    
    public GDBShell(){
        VirtualPipe sv = new VirtualPipe(), cv = new VirtualPipe();
        _xp = sv.getStream(cv);// new XDebugPipe(dbgserial);
        _client_pipe = cv.getStream(sv);// = new XDebugPipe(dbgserial);
        //_xp.setForServer(true);
    }
    
    public bool prepareForPipe(){
       /* if (_client_pipe.prepareForPipe())
        return _xp.prepareForPipe();
        return false;*/
        return true;
    }
    
    public Process createProcess(String exec, String [] args, String dir){
        try{
            _gdb_process = new Process(exec, args);
            gdbPath = exec;
            if (dir != nilptr){
                _gdb_process.setWorkDirectory(dir);
            }
        }catch(Exception e){
            
        }
        return _gdb_process;
    }
    
    
    void setEnvir(String gdbPath){
        if (gdbPath != nilptr && _system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            String path = EnvironmentMgr.getEnvironmentPath();
            if (path != nilptr){
                String gdbDir = gdbPath.findVolumePath();
                if (gdbDir.length() != 0){
                    String gdbDirprt = gdbDir.findVolumePath();
                    if (gdbDirprt.length() > 0){
                        path = gdbDirprt + ";" + path;
                    }
                    path = gdbDir + ";" + path;
                }
                path =  ".;" + path;
                writeGdbCommand("set environment path " + path + "\n");
            }
        }
    }


    public bool beginDebug(){
        try{
            if (_gdb_process.create(Process.StdOut | Process.StdIn | Process.RedirectStdErr)){
                bExit = false;
                
                new Thread(){
                    void run(){
                        Thread.setName("threadSendloop");
                        threadSendloop();
                    }
                }.start();
                
                
                new Thread(){
                    void run(){
                        Thread.setName("readresp");
                        readresp();
                        if (termina_process != nilptr){
                            termina_process.exit(5);
                        }
                        exitSender();
                    }
                }.start();
                
                setEnvir(gdbPath);
                writeGdbCommand("set confirm off\n");
                writeGdbCommand("set breakpoint pending on\n");
                writeGdbCommand("set unwindonsignal on\n");
                if (CPPGPlugManager.isCacheThrow()){
                    writeGdbCommand("catch throw\n");
                }
                writeGdbCommand(CPPGPlugManager.isATTDisasmMode() ? "set disassembly-flavor att\n" : "set disassembly-flavor intel\n");
                new Thread(){
                    void run(){
                        Thread.setName("threadReadloop");
                        threadReadloop();
                    }
                }.start();
                
                return true;
            }
        }catch(Exception  e){
        }
        return false;
    }
    
    public bool attachProcess(String [] args){
        DEBUG_TYPE = 1;
        target_args = args;
        return beginDebug();
    }
    
    public bool remoteDebug(String [] args){
        DEBUG_TYPE = 2;
        target_args = args;
        return beginDebug();
    }
    
    public bool startDebuggee(String [] args){
        target_args = args;
        DEBUG_TYPE = 0;
        return beginDebug();
    }
    
    public bool isQuit(){
        return bExit;
    } 
    
    List<byte[]> sendList = new List<byte[]>();
    
    void threadSendloop(){
        synchronized(sendList){
            sendList.clear();
        }
        
        byte [] data;
        
        while (isQuit() == false){
            synchronized(sendList){
                while (sendList.size() == 0 && isQuit() == false){
                    sendList.wait();
                }
                if (sendList.size() > 0){
                    data = sendList.pollHead();
                }else{
                    data = nilptr;
                }
            }
            if (data != nilptr){
                _xp.write(data,0,data.length);
            }
        }
    }
    
    int command_token = 1000000;
    int custome_token = 100;
    
    Object cmdlock = new Object();
    
    public int writeGdbCommand(String cmd){
    
        int ncmd = 0;
        
        synchronized(cmdlock){
            ncmd = command_token++;
        }
        
        return writeGdbCommand(ncmd, cmd);
    }
    
    void sendToGdbPipe(@NotNilptr byte [] data){
        try{
            //_system_.consoleWrite(finalcmd + "\n");
            _gdb_process.write(data,0,data.length);
        }catch(Exception e){
            
        }
    }
    
    Thread __sendThread = nilptr;
    List<byte[]> _sendArray = new List<byte[]>();
    
    void exitSender(){
        synchronized(_sendArray){
            _sendArray.notify();
        }
    }
    
    class CommandSender : public Thread{
        void run()override{
            Thread.setName("GdbSender");
            byte [] data = nilptr;
            while (bExit == false){
                synchronized(_sendArray){
                    while (_sendArray.size() == 0 && bExit == false){
                        _sendArray.wait();
                    }
                    if (_sendArray.size() > 0){
                        data = _sendArray.pollHead();
                    }
                }
                
                if (data != nilptr){
                    //_system_.output("send:\n" + new String(data));
                    sendToGdbPipe(data);
                    data = nilptr;
                }
            }
            
            synchronized(_sendArray){
                __sendThread = nilptr;
            }
        }
    };
    
    int writeGdbCommand(int token, String cmd){        
        String finalcmd = "" + token + " " + cmd;
        
        byte [] data = finalcmd.getBytes();
        synchronized(_sendArray){
            _sendArray.add(data);
            if (__sendThread == nilptr){
                __sendThread = new CommandSender();
                __sendThread.start();
            }
            _sendArray.notify();
        }
        return token;
    }
    
    void threadReadloop(){
        byte [] buffer = new byte[4096];
        //if (_xp.createstream())
        {
            while (isQuit() == false){
                int rd = _xp.read(buffer,0,4096);
                String helo = "XDEBUGGEE_V1 HELO\n";
                String helr = "XDEBUG_CLIENT_V1 RECV\n";
                
                while (rd < helo.length()){
                    int sd = _xp.read(buffer, rd, 4096 - rd);
                    if (sd > 0){
                        rd += sd;
                    }else{
                        break;
                    }
                }
                
                if (rd == helo.length()){
                    if (new String(buffer, 0, rd).equals(helo)){
                        _xp.write(helr.getBytes(),0,helr.length());
                        //_system_.output("debuggee connected!");
                        debug();
                      /*  bExit = true;
                        exit();*/
                    }
                }
            }
            _xp.close(); 
        }
        
    }
    
    void debug(){
        sendCommand(Active,0,new byte[0],0);
        
        byte [] buffer = new byte[4096];
        int rd = 0;
        EchoBuffer ebuffer = new EchoBuffer();
        do{
            rd = _xp.read(buffer,0,4096);
            if (rd > 0){
                ebuffer.append(buffer, 0, rd);
                int len = analyzeCommand(ebuffer);
                if (len > 0){
                    ebuffer.remove(len);
                }
            }
        }while (rd > 0 && isQuit() == false);
    }
    
    
    int analyzeCommand(@NotNilptr EchoBuffer buf){
    
        byte [] buffer = buf.getData();
        
        XRegular.Result result = nilptr;
				 
        int offset = 0;
        
        while(nilptr != (result = XRegular.Match(buffer, offset, buf.getLength() - offset, "[FFFE]{c:LEBB}<len:2>{t:LEBB}<len:8>{l:LEBB}<len:4>*<len:l>"))){
            int cmd = result.getValue('c');
            long tid = result.getValue('t');
            int conlen = result.getValue('l');
            
            JsonObject json;
            
            try{
                json = new JsonObject(new String(buffer, 16 + offset, conlen));
            }catch(Exception e){
                json = new JsonObject();
            }
            
            processCommand(cmd, tid, json);
            
            int al = result.getRegularLength();
            if (al > 0){
                offset += al;
            }
        }
        return offset;
    }
    
    
    void setupBreakPoint(@NotNilptr String file, int line ,bool bset){
        BreakpointCreator bpc = new BreakpointCreator(file, line);
        addtoqueue(bpc);
        bpc.set(bset);
    }
    
    Map<int,long> gidThreadmap = new Map<int,long>();
    
    /*Map<int,long> gidThreadmap = new Map<int,long>();
    Map<long,int> idThreadmap = new Map<long,int>();
    */
    
    void oncreateThread(int gid){
        synchronized(gidThreadmap){
            gidThreadmap.put(gid, gid);
        }
    }
    
    void onexitThread(int gid){
        synchronized(gidThreadmap){
            Map.Iterator<int,long> iter = gidThreadmap.find(gid);
            if (iter != nilptr){
                gidThreadmap.remove(iter);
            }
        }
    }
    
    bool hasThreadMap(int gid){
       synchronized(gidThreadmap){
            return  gidThreadmap.containsKey(gid);
        } 
    }
    /*
    long gid2id(int gid){
        synchronized(gidThreadmap){
            Map.Iterator<int,long> iter = gidThreadmap.find(gid);
            if (iter != nilptr){
                return iter.getValue();
            }
        }
        return 0;
    }
    
    int id2gid(long id){
        synchronized(gidThreadmap){
            Map.Iterator<long,int> iter = idThreadmap.find(id);
            if (iter != nilptr){
                return iter.getValue();
            }
        }
        return 0;
    }
    */
    Map<int, GdbRequest> __request = new Map<int , GdbRequest>();
    
    GdbRequest getRequest(int token){
        try{
            synchronized   (__request){
                return __request.get(token);
            }
        }catch(Exception e){
            
        }
        return nilptr;
    }
    
    void removeRequest(int token){
        synchronized   (__request){
            __request.remove(token);
        }
    }
    
    void requestResp(@NotNilptr GdbMiRecord [] _records, int offset, bool bDone){
        GdbMiRecord resord = _records[offset];
        __nilptr_safe(resord);
        GdbRequest rq = getRequest(resord.userToken);
        if (rq != nilptr){
            int start = rq.findStart(_records,offset);
            if (rq.next(_records, start, offset, bDone) == false){
                removeRequest(resord.userToken);
            }
        }else{
            GdbMiResultRecord _result = (GdbMiResultRecord)_records[offset];
            if (_result.className.equals("running")){
                sendStateRun(nilptr);
            }
        }
    }
    
    enum RequestType{
        SwitchFrame
    };
    
    class GdbRequest{
        public GdbRequest(){
            userToken = custome_token++;
        }
        
        public int userToken = 0;
        public RequestType type;
        String command;
        public bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone);
        
        public bool sendtogdb(String cmd){
            if (cmd != nilptr){
                command = cmd + "\n";
                return userToken == writeGdbCommand(userToken,command);
            }
            return false;
        }
        
        public int findStart(GdbMiRecord [] _records,int offset){
            int _end = offset;
            while (offset >= 0){
                if (_records[offset].type == GdbMiRecord.Type.Log){
                    if (( (GdbMiStreamRecord)_records[offset]).message.equals(command)){
                        for (int i = offset; i < _end; i++){
                            _records[i].processed = true;
                        }
                        offset++;
                        break;
                    }else{
                        offset--; 
                    }
                }else{
                   offset--; 
                }
            }
            return offset;
        }
    };
    
    public interface Receiver{
        void onComplete(String content, bool res);
    };
    
    void updateDisassemble(){
        new DisassembleReq(new CPPGPlugManager.DisassembleReceiver()).exec();
    }
    
    public class DisassembleReq : GdbRequest{
        public String content = "";
        Receiver __recv;
        long address = -1;
        public DisassembleReq(Receiver  _r){
            __recv = _r;
        }
        public bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone)override{

            for (int i = start; i < end; i ++){
                GdbMiRecord gmr = _records[i];
                if (isEndRecord(gmr)){
                    break;
                }
                content = content + ((GdbMiStreamRecord)gmr).message;
            }
            
            if (__recv != nilptr){
                __recv.onComplete(content,bDone);
            }
            return false;
        }
                
        public void exec(){
            addtoqueue(this);
            if (address == -1){
                sendtogdb("x/64i $pc");
            }else{
                sendtogdb("x/64i " + address);
            }
        }
    };
    
    class TypeRequest 
        : GdbRequest{
        String name;
        public String sztype;
        int step = 0;
        public bool completed = false;
        public GdbRequest major;
        bool bDetaile = false;
        public TypeRequest(String text){
            name = text;
        }
        public TypeRequest(String text, bool detaile){
            name = text;
            bDetaile = detaile;
        }
        public bool next(GdbMiRecord [] _records,int start, int end, bool bDone)override{
            if (step == 0){
                if (bDetaile){
                    sendtogdb("ptype " + name);
                }else{
                    sendtogdb("whatis " + name);
                }
                step++;
                return true;
            }else
            if (_records != nilptr){
                setType(_records, start, end);
                if (major != nilptr){
                    if (major.instanceOf(FrameRequest)){
                        FrameRequest fr = (FrameRequest)major;
                        fr.try_docomplete();
                    }else
                    if (major.instanceOf(Watcher)){
                        Watcher fr = (Watcher)major;
                        fr.docomplete();
                    }
                }
            }
            return false;
        }
        
        public void setType(GdbMiRecord [] _records,int start, int end){
            int count = end;
            
            if (start > 0){
                for (int i = start; i < count; i++){
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    String message  = _rec.message;
                    if (message != nilptr){
                        if (message.startsWith("type = ")){
                            sztype = message.substring(7, message.length()).trim(true);
                        }else{
                            sztype = "unknow" ;
                        }
                    }
                }
            }
        }
    };

    
    class MemoryRequest 
        : GdbRequest
    {
        public MemoryRequest(String p, String addr, int s){
            address = addr;
            param = p;
            size = s;
        }
        
        EchoBuffer buffer = new EchoBuffer();
        String address;
        String param;
        int size;
        
        bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone)override{
            int count = end;
            bool hasError = false;
            buffer.clear();
            
            String szOffset = address;
            
            for (int i = start; i < count; i ++){
                GdbMiRecord gmr = _records[i];
                if (isEndRecord(gmr)){
                    break;
                }else{
                    GdbMiStreamRecord srec = (GdbMiStreamRecord)gmr;
                    String msg = srec.message;
                    if (msg != nilptr){
                        int op = msg.indexOf(':');
                        if (op !=- 1){
                            if (szOffset == nilptr){
                                int pos = msg.indexOf(' ');
                                if (pos > op){
                                    pos = op;
                                }
                                if (pos != -1){
                                    szOffset = msg.substring(0, pos);
                                }
                            }
                            String [] dbs = msg.substring(op+ 1, msg.length()).trim(true).split("\t");
                            byte [] bdat = new byte[dbs.length];
                            int bds = 0;
                            for (int x = 0; x < dbs.length; x++){
                                String nb = dbs[x].trim(true);
                                if (nb.length() > 0){
                                    bdat[bds++] = nb.parseHex();
                                }else{
                                    hasError = true;
                                    break;
                                }
                            }
                            if (hasError){
                                break;
                            }
                            buffer.append(bdat, 0, bds);
                        }
                    }
                }
            }
            
            String content = "";
            if (buffer.getLength() > 0){
                content = Base64.encodeToString(buffer.getData(),0,buffer.getLength(), false);
            }
            
            if (szOffset == nilptr){
                szOffset = "0";
            }
            
            JsonObject json = new JsonObject();
            json.put("content", content);
            
            if (szOffset.startsWith("0x")){
                json.put("address", szOffset.parseHex());
            }else{
                json.put("address", szOffset.parseLong());
            }
            
            json.put("request",  size);
            json.put("response",  buffer.getLength());
            
            int cmd = LookupMemory;
            
            if (param != nilptr){
                cmd = DumpMemory;
                json.put("param",  param);
            }
            byte [] data = json.toString(false).getBytes();
            sendCommand(cmd, -1, data, data.length);
            return false;
        }
        
        public void exec(){
            sendtogdb("x/" + size+ "xb " + address);
        }
    };
    
    class GdbVariable{
        public String name;
        public TypeRequest type;
        public JsonObject jsonValue;
        public String value;
        public long parseRet;
    };
        
    class BreakpointCreator
         : GdbRequest{
         
        public BreakpointCreator(@NotNilptr String f, int l){
            if (f.equals(CPPGPlugManager.disassemble_pipe)){
                address = CPPGPlugManager.getDisassembleAddress(l + 1);
            }
            filepath = f;
            line = l;
        }
        
        String filepath;
        int line;
        long address;
        bool bEnable;
        
        bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone)override{
            JsonObject json = new JsonObject();
            
            if (bDone){
                json.put("error", 0);
            }else{
                json.put("error", -1);
            }
            
            json.put("file", filepath);
            json.put("realine", line);
            json.put("reqline", line);
            json.put("set", bEnable);
            
            byte [] data = json.toString(false).getBytes();
            sendCommand(SetBreakPoint, 0, data, data.length);
            
            if (address != 0 && bDone){
                CPPGPlugManager.toggleBreakPoint(address, line, bEnable);
            }
            
            return false;
        }
        
        public void set(bool enable){
            bEnable = enable;
            if (address == 0){
                String srcpath = filepath;
                if (filepath.indexOf(' ') != -1){
                    String fn = filepath.findFilenameAndExtension();
                    if (fn != nilptr){
                        srcpath = fn;
                    }
                }
                if (bEnable){
                    sendtogdb("b \""  + srcpath + "\":" + (line + 1));
                }else{
                    sendtogdb("clear \""  + srcpath + "\":" + (line + 1));
                }
            }else
            {
                if (bEnable){
                    sendtogdb("b *"  + address);
                }else{
                    sendtogdb("clear *"  + address);
                }
            }
        }
    };
    
    int findValuePos(@NotNilptr String text, int pos, char end){
        bool se = false, de = false, escape = false;
        int deep = 0;
        int abdeep = 0;
        while (pos < text.length()){
            char b = text.charAt(pos);
                        
            if (escape || b == '\\'){
                pos++;
                escape = !escape;
                continue;
            }
            
            if (se || b == '\''){
                pos++;
                if (b == '\''){
                    se = !se;
                }
                continue;
            }
            
            if (de || b == '\''){
                pos++;
                if (b == '\''){
                    de = !de;
                }
                continue;
            }
            if (b == '>'){
                abdeep--;
            }
            if (b == '}'){
                deep--;
            }
            if (deep == 0 && abdeep == 0){
                if (b == end){
                    return pos;
                }
            }
            if (b == '{'){
                deep++;
            }
            if (b == '<'){
                abdeep++;
            }
            pos++;
        }
        return -1;
    }

    bool parseArrayValue(@NotNilptr String substr, @NotNilptr JsonObject object, bool bTop){
        int offset = 0;
        JsonArray members = new JsonArray();
        JsonObject jobj;
        
        int dp = findValuePos(substr, offset, ',');
        while (dp != -1){
            String txt = substr.substring(offset,dp).trim(true);
            offset = dp + 1; 
            if (txt.startsWith("{")){
                txt = "__unnamed = " + txt;
            }
             
            if (txt.indexOf('=') == -1){
                JsonObject __value = new JsonObject();
                __value.put("valuetype", 0);
                __value.put("value", txt);
                members.put(__value);
            }else{
                jobj = new JsonObject();
                parseValue(txt, jobj, '=',false);
                members.put(jobj);
            }
            dp = findValuePos(substr, offset, ',');
        }
        
        String txt = substr.substring(offset,substr.length());
        if (txt.length() > 0){
            jobj = new JsonObject();
            parseValue(txt, jobj, '=', false);
            members.put(jobj);
        }
        
        if (bTop){
            JsonObject __value = new JsonObject();
            __value.put("valuetype", 1);
            __value.put("value", members);
            object.put(("value"),__value);
        }else{
            object.put("valuetype", 1);
            object.put("value", members);
        }        
        return true;
    }
    bool parseComplexValue(@NotNilptr String text, @NotNilptr JsonObject object, char eq, bool bTop){
        int st = findValuePos(text, 0, '{');
        int end = -1;
        bool bComplexValue = true;
        if (st == -1){
            bComplexValue = false;
        }else{
            end = findValuePos(text, st, '}');
            if (end == -1){
                bComplexValue = false;
            }
        }
        
        if (bComplexValue == false){
            return true;
        }
        
        String substr = text.substring(st + 1,end);
        if (substr.startsWith("{")){
            parseComplexValue(substr, object, eq, bTop);
        }else{
            parseArrayValue(substr.trim(true), object, bTop);
        }
        return true;
    }
    long parseValue(@NotNilptr String text, @NotNilptr JsonObject object, char eq, bool bTop){
        
        
        int equ = text.indexOf(eq);
        String name = "", value = "";
        if (equ != -1){
            if (text.trim(true).startsWith("{")){
                name = "__unnamed";
                value = text.trim(true);
                text = name + " = " + value;
            }else
            if (equ + 1 < text.length()){
                name = text.substring(0, equ).trim(true);
                value = text.substring(equ + 1, text.length()).trim(true);
            }
        }else{
            name = value = text.trim(true);
        }
        
        object.put("name", name);
        if (value.startsWith("@")){
            int op = value.indexOf(':');
            if (op != -1 && (op + 1 < value.length())){
                value = value.substring(op + 1,value.length()).trim(true);
            }
        }
        if (value.startsWith("{")){
            parseComplexValue(text, object, eq, bTop);
            return 1;
        }else{
            if (bTop){
                JsonObject __value = new JsonObject();
                __value.put("valuetype", 0);
                __value.put("value", value);
                object.put(("value"),__value);
            }else{
                object.put("valuetype", 0);
                object.put("value", value);
            }
            
            int rb = value.lastIndexOf(')');
            if (rb != -1){
                if (rb + 1 < value.length()){
                    value = value.substring(rb + 1, value.length());
                }
            }
            return value.trim(true).parseHex();
        }
    }

    
    void updateAllThread(JsonObject tag, String reson){
        ThreadUpdater.Reson res = ThreadUpdater.Reson.RES_BREAKPOINTHIT;
        switch(reson){ 
            case "end-stepping-range":
            case "function-finished":
            case "watchpoint-trigger":
            case "read-watchpoint-trigger":
            case "access-watchpoint-trigger": 
            case "location-reached":
            case "watchpoint-scope":
            case "breakpoint-hit":
                res = ThreadUpdater.Reson.RES_BREAKPOINTHIT;
            break;
            case "exception-received":
            case "signal-received":
                res = ThreadUpdater.Reson.RES_EXCEPTION;
            break;
            case "exited-signalled":
            case "exited":
            case "exited-normally":
                writeGdbCommand("q\n");
                return ;
            break;
        }
        
        ThreadUpdater tu = new ThreadUpdater(tag, res);
        addtoqueue(tu);
        tu.update();
    }
    
    class ThreadUpdater 
        : GdbRequest
    {
        JsonObject attach_object;
        Reson _reson;
        static Pattern [] frmpattern = {
            new Pattern("^#([0-9]{1,24})(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)(\\s+)at(\\s+)(.*)\\:([0-9]{1,24})$"),
            new Pattern("^#([0-9]{1,24})(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)(\\s+)from(\\s+)(.*)$"),
            new Pattern("^#([0-9]{1,24})(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)$"),
            new Pattern("^#([0-9]{1,24})(\\s+)(.*)(\\s+)at(\\s+)(.*)\\:([0-9]{1,24})$")
        };
        
        public ThreadUpdater(JsonObject tag, Reson res){
            attach_object = tag;
            _reson = res;
        }
        
        public enum Reson{
            RES_EXCEPTION,
            RES_BREAKPOINTHIT
        };
        

        
        bool parseFrame(@NotNilptr String item,@NotNilptr JsonObject recv){
            
            if (item.indexOf('\n') != -1){
                item = item.split('\n')[0].trim(true);
            }
            
            Pattern.Result rt = nilptr;
            int matchedId = -1;
            
            bool showInDisam = CPPGPlugManager.isInDisassemble();
            
            for (int i = 0 ;i < frmpattern.length; i++){
                rt = frmpattern[i].matchAll(item, 0, -1, Pattern.NOTEMPTY);
                if (rt.length() > 0){
                    matchedId = i;
                    rt = rt.get(0);
                    break;
                }
            }
            
            String source = "", method = "", path = "", ip = "0";
            
            int line , row;
             if (rt != nilptr && rt.length() > 0){
                switch(matchedId){
                    case 0:
                    if (rt.length() > 10){
                        ip = item.substring(rt.get(3).start(),rt.get(3).end());
                        method = item.substring(rt.get(6).start(),rt.get(6).end());
                        path = item.substring(rt.get(9).start(),rt.get(9).end());
                        line = item.substring(rt.get(10).start(),rt.get(10).end()).parseInt();
                    }
                    break;
                    case 1:
                    if (rt.length() > 9){
                        ip = item.substring(rt.get(3).start(),rt.get(3).end());
                        method = item.substring(rt.get(6).start(),rt.get(6).end());
                        method = method + "@" + item.substring(rt.get(9).start(),rt.get(9).end());
                    }
                    break;
                    case 2:
                    if (rt.length() > 6){
                        ip = item.substring(rt.get(3).start(),rt.get(3).end());
                        method = item.substring(rt.get(6).start(),rt.get(6).end());
                    }
                    break;
                    case 3:
                    if (rt.length() > 7){
                        method = item.substring(rt.get(3).start(),rt.get(3).end());
                        path = item.substring(rt.get(6).start(),rt.get(6).end());
                        line = item.substring(rt.get(7).start(),rt.get(7).end()).parseInt();
                    }
                    break;
                    default:
                    
                    break;
                }
            
                if (showInDisam){
                    path = "";
                }
                recv.put("source", path);
                if (ip.length() > 0){
                    recv.put("method", method + "(" + ip  + ")");
                }else{ 
                    recv.put("method", method); 
                }
                recv.put("path", "");
                if (ip.length() > 0){
                    recv.put("ip", "" + ip.parseHex());
                }else{
                    recv.put("ip", "");
                }
                if (line > 0){
                    line--;
                }
                recv.put("line", line);
                recv.put("column", 1);
                return true;
             }
             
            return false;
        }
        
        int generateThreadObject(@NotNilptr JsonObject thread, @NotNilptr GdbMiRecord [] _records, int offset){
            int p = offset;
            if (_records[p].type == GdbMiRecord.Type.Immediate){
                return 1;
            }
            GdbMiStreamRecord _result = (GdbMiStreamRecord)_records[p];
            String ident = _result.message.trim(true);
            
            int except_tid = 0;
            if (Reson.RES_EXCEPTION == _reson){
                except_tid = attach_object.getInt("gid");
            }
            
            if (ident.startsWith("Thread ")){
                ThreadTag tt = parseThreadInfo(ident, thread);
                
                JsonArray frames = new JsonArray();
                while (++p < _records.length){
                    if (_records[p].type ==  GdbMiRecord.Type.Immediate){
                        p++;
                        break;
                    }else{
                        GdbMiStreamRecord _frame = (GdbMiStreamRecord)_records[p];
                        String strFrame = _frame.message.trim(true);
                        
                        if (strFrame.startsWith("#")){
                            String[] frms = strFrame.split('\n');
                            for (int i = 0; i < frms.length; i++){
                                if (frms[i].startsWith("#")){
                                    JsonObject frame = new JsonObject();
                                    parseFrame(frms[i], frame);
                                    frames.put(frame);
                                }else{
                                    break;
                                }
                            }
                        }else
                        if (strFrame.startsWith("Thread ")){
                            break;
                        }
                    }
                }
                thread.put("stack", frames);
                if (tt != nilptr && except_tid == tt.gId){
                    attach_object.put("tid", tt.gId);
                    thread.put("exception", attach_object);
                    thread.put("sender",true);
                    except_tid = 0;
                }
                return p - offset;
            }
            return 0;
        }
        
        int updateThreadStatus(@NotNilptr GdbMiRecord [] _records, int start, int end){
            int cnt = 0;
            JsonArray tarrs = new JsonArray();
            JsonObject thread = new JsonObject();
            int count = end;
            
            if (start == -1){
                return 0;
            }
            long spectid = 0;
            
            if (_reson == Reson.RES_BREAKPOINTHIT){
                String bktid = attach_object.getString("gid");
                if (bktid != nilptr){
                    spectid = /*gid2id*/( bktid.parseInt());
                }
            }
            
            Map<long,long> currentThread = new Map<long,long>();
            
            bool isInDisassemble = CPPGPlugManager.isInDisassemble();
            
            while ((cnt = generateThreadObject(thread, _records, start)) > 0){
                if (cnt > 1){
                    long id = thread.getLong("id");
                    if (id == spectid){
                        thread.put("sender",isInDisassemble ? false : true);
                    }
                    currentThread.put(id, id);
                    tarrs.put(thread);
                }
                thread = new JsonObject();
                start += cnt;
                if (start >= count){
                    break;
                }
            }
            
            for (int i = 0; i < tarrs.length(); i++){
                long ggid = ((JsonObject)tarrs.get(i)).getLong("id");
                if (false == hasThreadMap(ggid)){
                    sendThreadStatus(ggid, false, XDBG_STATE_CREATE);
                } 
            }
            
            synchronized(gidThreadmap){
                Map.Iterator<int,long> iter = gidThreadmap.iterator();
                while (iter.hasNext()){
                    long ggid = iter.getKey();
                    iter.next();
                    
                    if (currentThread.containsKey(ggid) == false){
                        sendThreadStatus(ggid, false, XDBG_STATE_EXIT);
                    }
                }
            }
        
            JsonObject tn = new JsonObject();
            tn.put("threads", tarrs);
            
            if (_reson == Reson.RES_EXCEPTION){
                long tid = attach_object.getLong("id");
                attach_object = nilptr;
                tn.put("action", XDBG_STATE_EXCEPTION);
                byte [] data = tn.toString(false).getBytes();
                sendCommand(Interrupt, tid, data, data.length);
            }else
            if (_reson == Reson.RES_BREAKPOINTHIT){
                long tid = attach_object.getLong("id");
                attach_object = nilptr;
                tn.put("action", XDBG_STATE_REIGGEBP);
                byte [] data = tn.toString(false).getBytes();
                sendCommand(Interrupt, tid, data, data.length);
            }else{
                tn.put("action", XDBG_STATE_UPDATE);
                byte [] data = tn.toString(false).getBytes();
                sendCommand(Interrupt, -1, data, data.length);
            }
            
            return 0;
        }

        bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone)override{
            updateThreadStatus(_records, start, end);
            return false;
        }
        
        public void update(){
            sendtogdb("thread apply all bt");
        }
        
    };
    
    class FrameRequest  
        : GdbRequest
    {
        public int gid;
        //long tid;
        public int frame;
        int step = 0;
        int notifySeted = 0;
        int nEndId = /*CPPGPlugManager.isInDisassemble() ? 5 : */4;
        bool canComplete = false;
        Vector<GdbVariable> vars = new Vector<GdbVariable>();
        
        bool isCompleted(){
            for (int i =0; i < vars.size(); i++){
                if (vars[i].type.completed == false){
                    return false;
                }
            }
            return true;
        }
        
        bool next(@NotNilptr GdbMiRecord [] _records, int start, int end,  bool bDone)override{
            if (step >= 3 && step <= nEndId){
                parseLocals(_records, start, end, step == 5);
            }
            
            if (step == nEndId){
                canComplete = notifySeted > 0;
            }
                
            if (step < nEndId){
                exec();
                return true;
            }else
            if (step == nEndId){
                CPPGPlugManager.threadUpdateDisassemble();
                if (notifySeted == 0){
                    docomplete();
                }
            }
            return false;
        }
        
        public void exec(){
            switch(step){
                case 0:
                    sendtogdb("thread " + gid);
                break;
                
                case 1:
                    sendtogdb("frame " + frame);
                break;
                
                case 2:
                    sendtogdb("info args");
                break;
                
                case 3:
                    sendtogdb("info locals");
                break;
                
                case 4:
                    sendtogdb("info all-registers");
                break;
            }
            step++;
        }
        
        
        void parseItem(@NotNilptr String msg, char eq){
            
            int op = msg.find(" " + eq + " ");
            if (op != -1){
                String name = msg.substring(0, op);
                String value = msg.substring(op + 3, msg.length());
                
                GdbVariable gv = new GdbVariable();
                gv.name = name;
                JsonObject object = new JsonObject();
                gv.parseRet = parseValue(msg, object,  eq,false);
                
                gv.jsonValue = object;
                /*}else{
                    gv.value = value;
                }*/
                gv.type = new TypeRequest(name);
                addtoqueue(gv.type);
                gv.type.next(nilptr, 0, 0, true);
                gv.type.major = this;
                notifySeted++;
                vars.add(gv);
            }
        }
        
        void parseObjects(@NotNilptr String msg, bool bRegister){
            if (bRegister){
                String [] msgs = msg.split('\n');
                for (int i =0; i < msgs.length;i++){
                    parseItem(msgs[i], bRegister ? ' ' : '=');
                }
            }else{
                parseItem(msg, bRegister ? ' ' : '=');
            }
        }
        
        void parseLocals(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bRegister){
            int count = end;
                        
            if (start > 0){
                String msg = "";
                
                for (int i = start; i < count; i++){
                    if (_records[i].type == GdbMiRecord.Type.Immediate){
                        return;
                    }
                    
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    
                    if (_rec.message.equals("\n") == false){
                        msg = msg + _rec.message;
                    }else
                    if (msg.length() > 0){
                        msg = msg.trim(true);
                        
                        if (msg.length() != 0){
                            parseObjects(msg, bRegister);
                        }
                        msg = "";
                    }
                }
                
                if (msg.length() > 0){
                    msg = msg.trim(true);
                    if (msg.length() != 0){
                        parseObjects(msg, bRegister);
                    }
                    msg = "";
                }
            }
        }
        
        public void try_docomplete(){
            if (notifySeted > 0){
                if (( --notifySeted == 0) && canComplete){
                    docomplete();
                }
            }
        }
        
        void docomplete(){
            JsonObject root = new JsonObject();
            root.put("count", vars.size());
            
            JsonArray js = new JsonArray();
            clearStandby();
            for (int i =0; i < vars.size(); i++){
                JsonObject _var = new JsonObject();
                GdbVariable gvs = vars[i];
                _var.put("name", gvs.name);
                _var.put("type", gvs.type.sztype);
                
                bool hasString = false;
                
                if (gvs.jsonValue != nilptr){
                    String value_str = gvs.jsonValue.getString("value");
                    if (value_str != nilptr && value_str.indexOf("\"") != -1){
                        hasString = true;
                    }
                }
                
                if (hasString == false && ((gvs.type.sztype.endsWith("*") || gvs.type.sztype.endsWith("* const")) && gvs.parseRet != 0 && gvs.jsonValue != nilptr)){
                    putStanby(gvs.parseRet,"p *" + gvs.name);
                    gvs.jsonValue.put("object_id", "" + gvs.parseRet);
                }
                
                if (gvs.jsonValue == nilptr){
                    JsonObject valobj = new JsonObject();
                    valobj.put("valuetype", 0);
                    valobj.put("value", gvs.value);
                    _var.put("value", valobj.toString(false));
                }else{
                    _var.put("value", gvs.jsonValue.toString(false));
                }
                
                js.put(_var);
            }
            root.put("stack", js);
            byte [] data = root.toString(false).getBytes();
            sendCommand(QueryFrame, gid, data, data.length);
        }
        
    };
    
    void dumpmemory(String p,String address, int size){
        MemoryRequest mreq = new MemoryRequest(p, address, size);
        addtoqueue(mreq);
        mreq.exec();
    }
    
    void addtoqueue(@NotNilptr GdbRequest fr){
       synchronized(__request){
           __request.put(fr.userToken,fr);
       }
    }
    
    void queryStackFrame(int tid, int frm){
       FrameRequest fr = new FrameRequest();
       //fr.gid = id2gid(tid);
       fr.gid = tid;
       fr.frame = frm;
       fr.type = RequestType.SwitchFrame;
       addtoqueue(fr);
       fr.exec();
       
       updateWatch();
       
       if (lastLookupMemory != nilptr && lastLookupMemory.length() > 0){
           dumpmemory(nilptr, lastLookupMemory, lookuplen);
       }
    }
    
    
    Map<String, bool> watches_object = new Map<String, bool>();
    
    void addWatch(@NotNilptr JsonArray names, bool bDelete){
        synchronized(watches_object){
            for (int i = 0; i < names.length(); i++){
                String objname = names.getString(i);
                try{ 
                    if (bDelete){
                        watches_object.remove(objname);
                    }else{
                        watches_object.put(objname, true);
                    }
                }catch(Exception e){
                    
                }
            }
        }
        
        updateWatch();
    }
    
    
    void onQueryObject(String queryId, String id, String param, long offset, long end){
        long addr = id.parseLong();
        String cmd = queryStanby(addr);
        if (cmd != nilptr){
            new ObjectDetail(cmd,queryId, id, param, offset, end).exec();
        }else{
            JsonObject object = new JsonObject();
            object.put("error", 0);
            object.put("queryid", queryId);
            object.put("param", param);
            object.put("id", id);
            byte [] data = object.toString(false).getBytes();
            sendCommand(QueryObject, 0, data, data.length);
        }
    }
    
    Map<long, String> object_stanby_list = new Map<long, String> ();
    
    void putStanby(long addr, String cmd){
        synchronized(object_stanby_list){
            object_stanby_list.put(addr, cmd);
        }
    }
    
    String queryStanby(long addr){
        try{
           synchronized(object_stanby_list){
                return object_stanby_list.get(addr);
           } 
        }catch(Exception e){
            
        }
        return nilptr;
    }
    
    void clearStandby(){
        synchronized(object_stanby_list){
            object_stanby_list.clear();
        }
    }
    
    class Watcher: GdbRequest{
        UpdateRequest _parent;
        
        TypeRequest _type;
        String typeName = nilptr;
        String objname;
        
        public Watcher(String name, UpdateRequest _p){
            objname = name;
            _parent = _p;
        }
        
        public void exec(){
            _type = new TypeRequest(objname);
            addtoqueue(_type);
            _type.next(nilptr, 0, 0, true);
            _type.major = this;
        }
        
        public void docomplete(){
            typeName = _type.sztype.trim(true);
            addtoqueue(this);
            sendtogdb("p " + objname);
        }
        
        bool next(@NotNilptr GdbMiRecord [] _records,int start, int end, bool bDone){
            if (objname != nilptr){
                _parent.update(objname, typeName, _records, start, end, bDone);
            }
            return false;
        }
    };
    
    class ContinueEnv : GdbRequest{
        public void exec(){
            addtoqueue(this);
            sendtogdb("c");
        }
        
        bool next(@NotNilptr GdbMiRecord[] _records, int start, int offset,bool bDone){
            sendStateRun(nilptr);
            return false;
        }
    };
        
    class CustomRequest : GdbRequest{
        String _cmd;
        Receiver _r;
        String result = "";
        public CustomRequest(String cmd, Receiver r){
            _cmd = cmd;
            _r = r;
        }
        public void exec(){
            addtoqueue(this);
            sendtogdb(_cmd);
        }
        bool next(@NotNilptr GdbMiRecord[] _records,int start, int end,bool bDone){
            if (start != -1){
                for (;start < end; start++){
                    result = result + _records[start].toString();
                }
            }
            _r.onComplete(result,bDone);
            return false;
        }
    };
    
    public void runCustomCommand(String cmd, Receiver r){
        new CustomRequest(cmd, r).exec();
    }
        
    void sendStateRun(int [] gids){
        Map.Iterator<int, long> iter = gidThreadmap.iterator();
        JsonArray jarr = new JsonArray();
        
        while (iter.hasNext()){
            JsonObject thread = new JsonObject();
            int gid = iter.getKey();
            long tid = iter.getValue();
            thread.put("name", "Thread " + gid);
            thread.put("id", tid);
            thread.put("interrupt", false);
            if (gids == nilptr){
                jarr.put(thread);
            }else{
                for (int x = 0 ; x < gids.length; x++){
                    if (gids[x] == gid){
                        jarr.put(thread);
                    }
                }
            }
            iter.next();
        }
        
        JsonObject tn = new JsonObject();
        tn.put("threads", jarr);
        tn.put("action", XDBG_STATE_UPDATE);
        byte [] data = tn.toString(false).getBytes();
        sendCommand(Interrupt, -1, data, data.length);
    }
    
    class ObjectDetail
         : GdbRequest{
        String obj_cmd;
        String queryId,  id,  param;
        
        public ObjectDetail(String cmd, String _queryId, String _id, String _param, long _offset, long _end){
            obj_cmd = cmd;
            queryId = _queryId;
            id = _id;
            param = _param;
        }
        
        public void exec(){
            addtoqueue(this);
            sendtogdb(obj_cmd);
        }
        
        bool next(@NotNilptr GdbMiRecord [] _records, int start, int end, bool bDone){
            String content = "";
            for (int i = start; i < end; i ++){
                content = content + ((GdbMiStreamRecord)_records[i]).message;
            }
            
            JsonObject object = new JsonObject();
            parseValue(content, object,  '=', true);
            object.put("error", 0);
            object.put("queryid", queryId);
            object.put("param", param);
            object.put("id", id);
            byte [] data = object.toString(false).getBytes();
            sendCommand(QueryObject, 0, data, data.length);
            return false;
        }
    };
    
    void onQueryByName(String queryId, String name, String param){
        new QueryByNameRequest(name, param, queryId).exec();
    }
    
    class UpdateRequest : GdbRequest{
        public void update(@NotNilptr String name,@NotNilptr  String typename, @NotNilptr GdbMiRecord [] _records,int offset, int end, bool bDone);
    };
    
    class QueryByNameRequest 
        : UpdateRequest
    {
        GdbRequest parentReq = nilptr;
        String objname, paramtag, queryid;
        JsonObject object = nilptr;
        
        public QueryByNameRequest(String name, String param, String qid){
            objname = name;
            paramtag = param;
            queryid = qid;
        }
        
        public void update(@NotNilptr String name,@NotNilptr  String typename, @NotNilptr GdbMiRecord [] _records,int offset, int end, bool bDone){
            
            String content = "";
            for (int i = offset; i < end; i ++){
                content = content + ((GdbMiStreamRecord)_records[i]).message;
            }
            object = new JsonObject();
            long rt = parseValue(content, object,  '=', true);
            object.remove("name");
            object.put("name", name);
            object.put("type", typename);
            
            bool hasString = false;
            String value_str = object.getString("value");
            if (value_str != nilptr){
                try{
                    JsonObject in_value = new JsonObject(value_str);
                    value_str = in_value.getString("value");
                    if (value_str.indexOf("\"") != -1){
                        hasString = true;
                    }
                    if (hasString == false && ((typename.endsWith("*") || typename.endsWith("* const")) && rt != 0)){
                        putStanby(rt,"p *" + name);
                        in_value.put("object_id", "" + rt);
                        while (object.has("value")){
                            object.remove("value");
                        }
                        object.put("value", in_value.toString(false));
                    }
                }catch(Exception e){
                    
                }
            }
            
            docomplete();
        }
        
        bool next(@NotNilptr GdbMiRecord [] _records,int,  int offset, bool bDone){
            return false;
        }
        
        @NotNilptr JsonObject getWatch(){
            JsonObject json = new JsonObject();
            JsonArray jarr = new JsonArray();
            jarr.put(object);

            json.put("param", paramtag);
            json.put("queryid", queryid);
            json.put("watch", jarr);
            return json;
        }
        
        void docomplete(){
            if (parentReq != nilptr){
                
            }else{
                JsonObject resobject = getWatch();
                byte [] data = resobject.toString(false).getBytes();
                sendCommand(QueryByName, -1, data, data.length);
            }
        }
        
        public void exec(){
            Watcher w = new Watcher(objname, this);
            w.exec();
        }
    };
    
    class WatchRequest 
        : UpdateRequest
    {
        
        GdbRequest parentReq = nilptr;
        Map<String, JsonObject> _objects = new Map<String, JsonObject>();
        int request_cnt = 0;
        
        public WatchRequest(@NotNilptr Map<String, bool> watches){
            Map.Iterator<String, bool> iter = watches.iterator();
            while(iter.hasNext()){
                String key = iter.getKey();
                _objects.put(key, nilptr);
                iter.next();
            }
        }
        
        public void update(@NotNilptr String name,@NotNilptr  String typename, @NotNilptr GdbMiRecord [] _records,int offset, int end, bool bDone){
            request_cnt++;
            
            String content = "";
            for (int i = offset; i < end; i ++){
                content = content + ((GdbMiStreamRecord)_records[i]).message;
            }
            
            JsonObject object = new JsonObject();
            long rt = parseValue(content, object,  '=', true);
            object.remove("name");
            object.put("name", name);
            object.put("type", typename);
            
            bool hasString = false;
            String value_str = object.getString("value");
            if (value_str != nilptr){
                try{
                    JsonObject in_value = new JsonObject(value_str);
                    value_str = in_value.getString("value");
                    if (value_str.indexOf("\"") != -1){
                        hasString = true;
                    }
                    if (hasString == false && ((typename.endsWith("*") || typename.endsWith("* const")) && rt != 0)){
                        putStanby(rt,"p *" + name);
                        in_value.put("object_id", "" + rt);
                        while (object.has("value")){
                            object.remove("value");
                        }
                        object.put("value", in_value.toString(false));
                    }
                }catch(Exception e){
                    
                }
            }
            
            _objects.put(name,object);

            if (request_cnt == _objects.size()){
                docomplete();
            }
        }
        
        bool next(@NotNilptr GdbMiRecord [] _records,int,  int offset, bool bDone){
            return false;
        }
        
        @NotNilptr JsonObject getWatch(){
            JsonObject json = new JsonObject();
            JsonArray jarr = new JsonArray();
            Map.Iterator<String, JsonObject> iter = _objects.iterator();
            while(iter.hasNext()){
                JsonObject value = iter.getValue();
                if (value != nilptr){
                    jarr.put(value);
                }
                iter.next();
            }
            
            json.put("watch", jarr);
            return json;
        }
        
        void docomplete(){
            if (parentReq != nilptr){
                
            }else{
                JsonObject object = getWatch();
                byte [] data = object.toString(false).getBytes();
                sendCommand(WatchObject, -1, data, data.length);
            }
        }
        
        public void exec(){
            Map.Iterator<String, JsonObject> iter = _objects.iterator();
            while(iter.hasNext()){
                String key = iter.getKey();
                Watcher w = new Watcher(key, this);
                
                w.exec();
                iter.next();
            }
        }
    };
    
    void updateWatch(){
        WatchRequest wr ;
        synchronized(watches_object){
            wr = new WatchRequest(watches_object);
        }
        wr.exec();
    }
    
    
    class FeedbackRequest : GdbRequest{
        String textcmd;
        
        public FeedbackRequest(String cmd){
            textcmd = cmd;
        }
        
        public void exec(){
            addtoqueue(this);
            sendtogdb(textcmd);
        }
        
        bool next(@NotNilptr GdbMiRecord[] _records,int start, int end,bool bDone){
            try{
                int pos = start;
                String szMsg = ((GdbMiStreamRecord)_records[pos]).message;
                if (bDone == false){
                    switch(szMsg.trim(true)){
                        case "Cannot find bounds of current function":
                        szMsg = "所选线程无法进行源码单步.";
                        break;
                    }
                    JsonObject message = new JsonObject();
                    message.put("type", "Critical");
                    message.put("message", "Error:" + szMsg);
                    message.put("button", "Ok");
                    message.put("dmid", "");
                    
                    byte [] content = message.toString(true).getBytes();
                    
                    sendCommand(MessageBox,0,content,content.length);
                }
            }catch(Exception e){
                
            }
            return false;
        }
    };
    
    static String lastLookupMemory = nilptr;
    static int lookuplen = 0;
    
    void processCommand(int cmd,int tid,@NotNilptr JsonObject json){
    //_system_.output("recv : cmd = " + cmd + " req = " + json.toString(true));
    
	switch (cmd){
	case Unknow:

		break;
	case Interrupt:
        _gdb_process.raise(_system_.SIGINT);
        //writeGdbCommand("-interrupt-exec --all\n");
		//InterruptThread(tid);
		break;
	case Continue:
		//ContinueThread(tid);
        conrun();
		break;
	case StepIn:
        stepin();
        break;
	case StepOver:
        stepover();
        break;
	case StepOut:
        stepout();
		//step(tid, (DEBUG_CMD)cmd);
		break;
	case SetBreakPoint:
	{
        String file = json.getString("file");
        int line = json.getInt("line");
        int set = json.getInt("set");
        
        if (file != nilptr){
            setupBreakPoint(file, line, set != 0);
        }
	}
	break;
	case SetMemoryBreakPoint:
		break;
	case SetFunctionBreakPoint:
		break;
	case QueryStackStruct:
		//查询栈结构
		//queryStackStruct(tid);
		break;
	
	case QueryStackObject:
		break;
	case QueryStackObjectDetails:
		break;
	case QueryHeapStruct:
		break;
	case QueryHeapObject:
	case QueryHeapObjectDetails:
		break;
	case QueryThreadCount:
		//查询线程总数
		//countThread();

		break;
	case QueryStackFrame:
	case SwitchThread:

		break;
	case QueryFrame:
		//查询某一帧的详细信息
	{
		int frame = json.getInt("frame");
		queryStackFrame(tid, frame);
	}
		break;
	case QueryMemoryInfo:
		//查询内存使用信息
		//queryMemoryInfo();
		break;
	case GC:
		//requestGC();
		break;

	case WatchObject:
	{
        JsonArray names = (JsonArray)json.get("names");
        bool bDelete = json.getInt("delete") != 0;
        if (names != nilptr){
            addWatch(names, bDelete);
        }
        
		/*cajson::array ary = root.root().getElement("names");
		int frame = root.root().get_int_value("frame");
		bool bDelete = root.root().get_int_value("delete") != 0;

		if (bDelete){
			watchlock.lock();
			for (size_t i = 0; i < ary.size(); i++){
				watchObject.erase(ary[(int)i].value());
			}
			watchlock.unlock();
			return;
		}


		watchlock.lock();

		watchObject.clear();
		for (size_t i = 0; i < ary.size(); i++){
			watchObject.put(ary[(int)i].value());
		}
		watchlock.unlock();

		/*QueryContext qc;
		qc.objectArray.create();* /

		cbjson result;
		result.create();
		updateWatch(tid, frame, result/*, qc* /);

		result.put_internal("error", 0);
		//result.put_internal("objects", &qc.objectArray);

		caastring str;
		result.print(str, false);
		sendCommand(WatchObject, tid, str.c_str(), str.length());*/
	}
		
		break;
	case Active:
		debugActive();
		break;

	case Debug:

		break;

	case QueryObject:
	{
		String qid = json.getString("queryid");
		String oid = json.getString("id");
		String param = json.getString("param");
		String offset = json.getString("offset");
		String end = json.getString("end");

		long noffset = -1, nend = -1;
		if (offset != nilptr){
			noffset = offset.parseLong();
		}
		if (end != nilptr){
			nend = end.parseLong();
		}
		onQueryObject(qid, oid, param, noffset, nend);
	}
		break;

	case GcDump:
		//dumpGcObject();
		break;

	case QueryByName:
	{
        onQueryByName(json.getString("queryid"), json.getString("name"), json.getString("param"));
		/*int _tid = root.root().get_int_value("tid");
		int frame = root.root().get_int_value("frame");
		const char * qid = root.root().value("queryid");
		const char * name = root.root().value("name");
		const char * param = root.root().value("param");
		onQueryByName(_tid, frame, qid, name, param);*/
	}
		break;

	case ModuleLoaded:
		/*casynch(_loadEvent){
			_loadEvent.signal();
		}*/
		break;

	case LookupMemory:{
		/*const char * addr = root.root().value("address");
		size_t size = root.root().get_int_value("size");

		lastLookupMemory = addr;
		lookuplen = size;

		onLookupMemory(addr, size, nilptr);*/
        lastLookupMemory = json.getString("address");
		lookuplen = json.getInt("size");
        dumpmemory(nilptr, lastLookupMemory, lookuplen);
	}
		break;

    
	case DumpMemory:{
		/*const char * addr = root.root().value("address");
		const char * param = root.root().value("param");
		size_t size = root.root().get_int_value("size");

		onDumpMemory(addr, size, param);*/
        dumpmemory(json.getString("param"), json.getString("address"), json.getInt("size"));
	}
		break;
	case DBGExit:
		exit();
		break;
	}
    }
    
    public void exit(){
        _gdb_process.raise(_system_.SIGINT);
        writeGdbCommand("q\n");
    }
    
    public void close(){
        _xp.close();
        _client_pipe.close();
    }
    
    class ThreadTag{
        public String name;
        public int gId = -1;
        public int processid;
        static Pattern [] threadprt = {  new Pattern("^(Thread )([0-9]{1,24})( \\(Thread )([0-9a-fA-F]{1,16})(\\.0x)([0-9a-fA-F]{1,16})\\):$"), 
                        new Pattern("^(Thread )([0-9]{1,24})( \\(process )([0-9a-fA-F]{1,16})\\):$"),
                        new Pattern("^(Thread )([0-9]{1,24})( \\(Thread )0x([0-9a-fA-F]{1,16}) \\((.*) ([0-9]{1,16})\\)\\):$"),
                        new Pattern("^(Thread )([0-9]{1,24}).*$")};
                       
        static Pattern createthreadprt = new Pattern("(^\\[New Thread )([0-9a-fA-F]{1,16})(\\.0x)([0-9a-fA-F]{1,16})\\]$");
        
       
        public ThreadTag(@NotNilptr String text){
            int t_type = 0;

            Pattern.Result rt = nilptr;
            
            for (int i =0; i < threadprt.length; i++){
               rt = threadprt[i].matchAll(text, 0, -1, Pattern.NOTEMPTY);  
               if (rt.length() > 0){
                   t_type = i;
               }
            } 
                        
            if (rt != nilptr && rt.length() > 0){
               Pattern.Result item = rt.get(0);
               int pl = item.length() ;
               
               String[] items = new String[item.length()];
               for (int i = 0; i < item.length(); i++){
                   items[i] = text.substring(item.get(i).start(),item.get(i).end());
               }
               if (t_type == 0){
                   String idName = items[2];
                   String proId = items[4];
                   String thrId = items[6];
                    
                   processid = proId.parseInt();
                   //id = thrId.parseHex();
                   gId = idName.parseInt();
                   name = "Thread " + idName;
               }else
               if (t_type == 1){
                   String proId = items[4];
                   String idName = items[2];
                   
                   processid = proId.parseInt();
                   gId = idName.parseInt();
                   name = "Thread " + idName;
               }else
               if (t_type == 2){
                   String idName = items[2];
                   String thrId = items[6];
                   //id = thrId.parseHex();
                   gId = idName.parseInt();
                   name = "Thread " + idName;
               }else
               if (t_type == 3){
                   String idName = items[2];
                   gId = idName.parseInt();
                   name = "Thread " + idName;
               }
            }
        } 
        
        ThreadTag(String _name, @NotNilptr String nameid){
            gId = nameid.parseInt();
            name = _name;
        }
        ThreadTag(String _name, @NotNilptr String nameid,@NotNilptr  String crt_text){
             
            Pattern.Result rt = createthreadprt.matchAll(crt_text, 0, -1, Pattern.NOTEMPTY);
            if (rt.length() > 0){
               Pattern.Result item = rt.get(0);
               String proId = crt_text.substring(item.get(2).start(),item.get(2).end());
               String thrId = crt_text.substring(item.get(4).start(),item.get(4).end());
                
               processid = proId.parseInt();
               gId = nameid.parseInt();
               name = _name;
            }
        }
    };

    
    
    void handleRecord(@NotNilptr GdbMiRecord record)
	{
		switch (record.type)
		{
		case GdbMiRecord.Type.Target:
		case GdbMiRecord.Type.Console:
		case GdbMiRecord.Type.Log:
			//handleStreamRecord((GdbMiStreamRecord) record);
			break;

		case GdbMiRecord.Type.Immediate:
		case GdbMiRecord.Type.Exec:
		case GdbMiRecord.Type.Notify:
		case GdbMiRecord.Type.Status:
			//handleResultRecord((GdbMiResultRecord) record);
			break;
		}

		// If this is the first record we have received we know we are fully started, so notify the
		// listener
		/*if (m_firstRecord)
		{
			m_firstRecord = false;
			m_listener.onGdbStarted();
		}*/
	}
    
    void notifyLibraryLoaded(@NotNilptr GdbMiResultRecord record){
        if (record.results.size() > 0){
            String path = record.results[0].value.string;
            JsonObject object = new JsonObject();
            object.put("module", path);
            if (record.results.size() > 2){
                String symbol = record.results[3].value.string;
                if (symbol == nilptr){
                    object.put("symbol", false);
                }else{
                    object.put("symbol", symbol.parseInt() != 0);
                }
            }else{
                object.put("symbol", false);
            }
            byte [] data = object.toString(false).getBytes();
            sendCommand(ModuleLoaded, -1, data, data.length);
        }
    }
    
    static const int  XDBG_STATE_UPDATE	    =	0;
    static const int  XDBG_STATE_CREATE	    =	1;
    static const int  XDBG_STATE_EXIT	    =	2;
    static const int  XDBG_STATE_EXCEPTION  =	4;
    static const int  XDBG_STATE_REIGGEBP	=	8;
    
    void sendThreadStatus(int tid, bool bInterrupt, int statue){
        JsonObject to = new JsonObject();
        to.put("name", "Thread " + tid);
        to.put("interrupt", bInterrupt);
                
        to.put("id", tid);
        
        JsonArray tarrs = new JsonArray();
        tarrs.put(to);
        
        JsonObject tn = new JsonObject();
        tn.put("threads", tarrs);
        tn.put("action", statue);
        if (statue == XDBG_STATE_CREATE){
            oncreateThread(tid);
        }else
        if (statue == XDBG_STATE_EXIT){
            onexitThread(tid);
        }
        byte [] data = tn.toString(false).getBytes();
        sendCommand(Interrupt, tid, data, data.length);
    }
    
    void notifyThreadCreated(GdbMiRecord [] _records, int offset){
        GdbMiResultRecord record = (GdbMiResultRecord)_records[offset];
        GdbMiStreamRecord result ;
        
        try{
            result = (GdbMiStreamRecord)_records[offset + 1];
        }catch(Exception e){
            
        }
        
        JsonObject to = new JsonObject();
        if (record.results.size() > 0){
            String tid = record.results[0].value.string;
            sendThreadStatus(tid.parseInt(), false, XDBG_STATE_CREATE);
        }
    }
        
    void notifyThreadExited(GdbMiRecord [] _records, int offset){
        GdbMiResultRecord record = (GdbMiResultRecord)_records[offset];
        
        JsonObject to = new JsonObject();
        if (record.results.size() > 0){
            String gid = record.results[0].value.string;
            int ttid = gid.parseInt();
            onexitThread(ttid);
            
            to.put("name", "Thread " + gid);
            to.put("interrupt", false);
            to.put("id", ttid);
            
            JsonArray tarrs = new JsonArray();
            tarrs.put(to);
            
            JsonObject tn = new JsonObject();
            tn.put("threads", tarrs);
            tn.put("action", XDBG_STATE_EXIT);
            
            byte [] data = tn.toString(false).getBytes();
            sendCommand(Interrupt, ttid, data, data.length);
        }
    }
    
    void stepin(){
        CPPGPlugManager.clearBreakOn();
        if (CPPGPlugManager.isInDisassemble()){
            new FeedbackRequest("si").exec();
        }else{
            new FeedbackRequest("s").exec();
        }
        //writeGdbCommand("s\n");
    }
    
    void stepover(){
        CPPGPlugManager.clearBreakOn();
        
        if (CPPGPlugManager.isInDisassemble()){
            new FeedbackRequest("ni").exec();
        }else{
            new FeedbackRequest("n").exec();
        }
        
        //writeGdbCommand("n\n");
    }
    
    void stepout(){
        CPPGPlugManager.clearBreakOn();
        new FeedbackRequest("fin").exec();
        //writeGdbCommand("fin\n");
    }
    
    void conrun(){
        CPPGPlugManager.clearBreakOn();
        new ContinueEnv().exec();
    }
    
    void notifyStoped(@NotNilptr GdbMiResultRecord record){
        JsonObject to = new JsonObject();
        if (record.results.size() > 0){
            String reson ,signal_name = "",signal_mean = "",addr = "", tid = "", frame = "";
            
            for (int i = 0; i < record.results.size(); i++){
                GdbMiResult gmr = record.results[i];
                switch(gmr.variable){
                    case "reason":
                        reson = gmr.value.string;
                    break;
                    case "thread-id":
                        tid = gmr.value.string;
                    break;
                    case "frame":
                        frame = gmr.value.string;
                        if (gmr.value.tuple != nilptr && gmr.value.tuple.size() > 0){
                            addr = gmr.value.tuple[0].value.string;
                        }
                    break;
                    case "signal-name":
                        signal_name = gmr.value.string;
                    break;
                    case "signal-meaning":
                        signal_mean = gmr.value.string;
                    break;
                }
            }
            
            JsonObject _exception_obj = new JsonObject();
            _exception_obj.put("name", signal_name);
            _exception_obj.put("address", addr);
            _exception_obj.put("msg", signal_mean);
            _exception_obj.put("gid", tid.parseInt());
            
            updateAllThread(_exception_obj, reson);
        }else{
            writeGdbCommand("q\n");
        }
    }
    
    ThreadTag parseThreadInfo(@NotNilptr String item, @NotNilptr JsonObject jobj){
        if (item.startsWith("Thread")){
            ThreadTag tg = new ThreadTag(item);
            jobj.put("name", tg.name);
            jobj.put("id", tg.gId);
            jobj.put("process", tg.processid);
            jobj.put("interrupt", true);
            return tg;
        }
        return nilptr;
    }
    
    bool isEndRecord(@NotNilptr GdbMiRecord rec){
        return rec.type == GdbMiRecord.Type.Immediate;
    }
    
    void handleResponse(@NotNilptr List<GdbMiRecord> records){
        GdbMiRecord [] _records = records.toArray(new GdbMiRecord[0]);
        int lastError = -1;
        int _stopres = -1;
        int replyId = -1;
        
        for (int i = 0; i < _records.length; i++){
            switch(_records[i].type){
                case GdbMiRecord.Type.Immediate:
                case GdbMiRecord.Type.Exec:
                case GdbMiRecord.Type.Notify:
                case GdbMiRecord.Type.Status:
                    GdbMiResultRecord _result = (GdbMiResultRecord)_records[i];
                    switch(_result.className){
                        case "thread-group-added":
                        case "thread-group-started":
                        break;
                        
                        case "thread-created":
                            notifyThreadCreated(_records, i++);
                        break;
                        case "thread-exited":
                            notifyThreadExited(_records, i);
                        break;
                                               
                        case "library-loaded":
                            notifyLibraryLoaded(_result);
                        break;
                        
                        case "stopped":
                            _stopres = i;
                            //notifyStoped(((GdbMiResultRecord)_records[i]));
                        break;
                        
                        case "breakpoint-created":
                        
                        break;
                        case "error":
                            requestResp(_records, i, false);
                        break;
                        case "running":
                        case "done":
                            if (debuggee_type == 0 || debuggee_type == DEBUGGEE_LLDB){
                                requestResp(_records, i, lastError != i);
                            }else{
                                requestResp(_records, i, true);
                            }
                            replyId = i;
                        break;
                    }
                    
                    break;
                case GdbMiRecord.Type.Log:
                if (debuggee_type == 0 || debuggee_type == DEBUGGEE_LLDB){
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    if (_rec.message.startsWith("error: ")){
                        lastError = i + 1;
                    }
                }
                break;
                case GdbMiRecord.Type.Target:
                case GdbMiRecord.Type.Console:
                break;
            }
        }
        
        if (_stopres != -1 && _records[_stopres].processed == false){
            notifyStoped(((GdbMiResultRecord)_records[_stopres]));
        }
               
    }
    

    class GDBDetect : GdbRequest{
        int step = 0;
        int state_result = 0;
        
        public GDBDetect(){
            
        }
        
        void parseThreads(@NotNilptr GdbMiRecord[] _records,int start, int end){
            int count = end;
            int offset = start;
            
            if (offset > 0){
                for (int i = offset; i < count; i++){
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    String message  = _rec.message;
                    if (message.startsWith("*")){
                        message = message.substring(1,message.length());
                    }
                    int tid = message.trim(true).parseInt();
                    if (tid > 0){
                        sendThreadStatus(message.parseInt(), false, XDBG_STATE_CREATE);
                    }
                }
            }
        }
        
        bool next(@NotNilptr GdbMiRecord[] _records,int start, int end,bool bDone){            
            switch(step){
                case 0 :
                    if (bDone){
                        step = 10; // 说明是GDB
                        debuggee_type = DEBUGGEE_GDB;
                        sendtogdb("set non-stop off");
                    }else{
                        CPPGPlugManager.output("不是GDB调试器.请重新设置调试器.");
                        return debugCancel();
                    }
                    
                    return true;
                break;
                
                case 10:
                {
                    if (DEBUG_TYPE == 0){
                        support_non_stop = bDone; 
                        step = 11;
                        
                        String tty = setNewConsole();
                        if (_system_.getPlatformId() != _system_.PLATFORM_WINDOWS){
                            if (tty != nilptr && tty.length() > 0){
                                sendtogdb("tty " + tty);
                            }else{
                                CPPGPlugManager.output("无法与终端程序取得联系,请重试或更换虚拟终端程序.");
                                return debugCancel();
                            }
                        }
                        return true;
                    }else
                    if (DEBUG_TYPE == 1){
                        sendtogdb("attach " + target_args[0]);
                        step = 3;
                        return true;
                    }else
                    if (DEBUG_TYPE == 2){
                        sendtogdb("file " + target_args[2]);
                        step = 6;
                        return true;
                    }
                }
                break;
                
                case 3:
                    if (bDone == false){
                        CPPGPlugManager.output("无法附加到进程:" + target_args[0] + ".");
                        return debugCancel();
                    }else{
                        queryThread();
                        step = 5;
                    }
                    return true;
                break;
                
                case 6:
                    if (bDone == false){
                        CPPGPlugManager.output("无法附加到进程:" + target_args[0] + ".");
                        return debugCancel();
                    }else{
                        sendtogdb("target remote " + target_args[0] + ":" + target_args[1]);
                        step = 4;
                    }
                    return true;
                break;
                
                case 4:
                    if (bDone == false){
                        CPPGPlugManager.output("无法连接到远程主机:" + target_args[0] + ":" + target_args[1] + ".");
                        return debugCancel();
                    }else{
                        queryThread();
                        step = 5;
                    }
                    return true;
                break;
                
                case 5:
                    if (bDone == false){
                        CPPGPlugManager.output("无法进行调试.");
                        return debugCancel();
                    }else{
                        parseThreads(_records, start, end);
                        continue_target();
                        step = 14;
                    }
                    return true;
                break;
                
                case 11:
                    if (setArgs() == false){
                        run_target();
                        step = 13;
                    }else{
                        step = 12;
                    }
                    return true;
                break;
                
                case 12:
                    if (bDone == false){
                        CPPGPlugManager.output("无法应用参数.",0);
                        return debugCancel();
                    }else{
                        run_target();
                        step = 13;
                        return true;
                    }
                break;
                
                case 13:
                    if (bDone == false){
                        CPPGPlugManager.output("目标程序无法运行.",0);
                        return debugCancel();
                    }
                    return false;
                break;
                case 14:
                    if (bDone == false){
                        CPPGPlugManager.output("目标程序无法运行.",0);
                        return debugCancel();
                    }else{
                        sendStateRun(nilptr);
                    }
                    return false;
                break;
                
                default:
                    state_result = -1;
                break;
            }
            debugCancel();
            return false;
        }
        
        public void exec(){
            addtoqueue(this);
            sendtogdb("show version");
        }
        
        bool setArgs(){
            if (target_args != nilptr && target_args.length > 0){
                String __args = "";
                for (int i = 0; i < target_args.length; i++){
                    __args = __args + " " + target_args[i];
                }
                sendtogdb("set args" + __args);
                return true;
            }
            return false;
        }
        
        bool debugCancel(){
            exit();
            return false;
        }
        
        String findTerminal(){
            String termpath = "";
            if (Setting.get("cde_gdb_autovmterm").equals("False")){
                termpath = Setting.get("cde_gdb_setvmterm");
            }
            if ((termpath.length() == 0) || (XPlatform.existsSystemFile(termpath) == false)){
                String [] uri = { "/usr/bin/konsole", "/usr/bin/gnome-terminal", "/usr/bin/xfce4-terminal", "/usr/bin/lxterminal", "/usr/bin/xterm"};
                for (int i =0; i < uri.length; i++){
                    if (XPlatform.existsSystemFile(uri[i])){
                        return uri[i];
                    }
                }
            }
            return termpath;
        }
        
        String [] getTermArgs(String arg){
            String param = Setting.get("cde_gdb_params");
            if (param.length() == 0){
                String [] _default_args = {"konsole", "-e", "bash", "-c", arg};
                return _default_args;
            }
            Vector<String> args_list = new Vector<String>();
            args_list.add("$term");
            CDEProjectPropInterface.processArgs(param,args_list);
            for (int i = 0; i < args_list.size(); i++){
                args_list[i] = args_list[i].replace("$(arg)", arg);
            }
            return args_list.toArray(new String[0]);
        }
    
        String setNewConsole(){
            String  output_tty = nilptr;
            if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                sendtogdb("set new-console on");
                return nilptr;
            }else{
                String dbg_script = CDEProjectPropInterface.appendPath(CDEProjectPropInterface.appendPath(_system_.getAppDirectory(), "plugins/cde"), "" + Math.random());
                int id = 0;
                while (XPlatform.existsSystemFile(dbg_script)){
                    dbg_script = CDEProjectPropInterface.appendPath(CDEProjectPropInterface.appendPath(_system_.getAppDirectory(), "plugins/cde"), "" + (Math.random() + id++));
                }
                
                dbg_script = String.formatPath(dbg_script,false);
                
                String dbg_ps = dbg_script + "rs";
                String ps = "tty > \"" + dbg_ps + "\" ; sleep 80000000";
                
                FileOutputStream fos = nilptr;
                try{
                    fos = new FileOutputStream(dbg_script);
                    byte [] bc = ps.getBytes();
                    fos.write(bc);
                }catch(Exception e){
                    //_system_.output("can not write to " + dbg_script);
                    return nilptr;
                }finally{
                    if (fos != nilptr){
                        fos.close();
                    }
                }
                _system_.chmod(dbg_script,0777);
                
                String [] args = getTermArgs(dbg_script);

                String teruri = findTerminal();
                
                if (teruri != nilptr){
                    args[0] = teruri;
                    termina_process = new Process(teruri, args);
                    if (termina_process.create(Process.Visible)){
                        int retry = 1000;
                        
                        while (output_tty == nilptr && retry-- > 0){
                            if (_system_.fileExists(dbg_ps)){
                                output_tty = CPPGPlugManager.CPPLangPlugin.readFileContent(dbg_ps);
                                if (output_tty == nilptr || output_tty.length() == 0){
                                    output_tty = nilptr;
                                    _system_.sleep(10);
                                }
                            }else{
                                _system_.sleep(10);
                            }
                        }
                        
                        if (output_tty != nilptr){
                            output_tty = output_tty.trim(true);
                        }
                    }
                }
                _system_.deleteFile(dbg_script);
                _system_.deleteFile(dbg_ps);
                
                int retry = 1000;
                if (output_tty != nilptr){
                    while (_system_.fileExists(output_tty) == false && retry-- > 0){
                        _system_.sleep(20);
                    }
                    _system_.sleep(150);
                }
                return output_tty;   
            }
        }
        
        void run_target(){
            sendtogdb("r");
        }
        
        void continue_target(){
            sendtogdb("c");
        }
        
        void queryThread(){
            sendtogdb("info threads");
        }
    };
    

    
    void debugActive(){
        new GDBDetect().exec();
    }
    
    void setExit(){
        sendCommand(DBGExit, -1, new byte[0], 0);
        synchronized(sendList){
            bExit = true;
            sendList.notify();
        }
        
    }
    
    void sendCommand(int cmd, long tid, byte[] data, int length){
		int buf_size = 16 + length;
		byte [] buffer = new byte[buf_size];

		buffer[0] = 0xff;
		buffer[1] = 0xfe;
		buffer[2] = (byte)(cmd & 0xff);
		buffer[3] = (byte)((cmd >> 8) & 0xff);

		buffer[4] = (byte)(tid & 0xff);
		buffer[5] = (byte)((tid >> 8) & 0xff);
		buffer[6] = (byte)((tid >> 16) & 0xff);
		buffer[7] = (byte)((tid >> 24) & 0xff);
        buffer[8] = (byte)((tid >> 32) & 0xff);
        buffer[9] = (byte)((tid >> 40) & 0xff);
        buffer[10] = (byte)((tid >> 48) & 0xff);
        buffer[11] = (byte)((tid >> 56) & 0xff);
            
		buffer[12] = (byte)(length & 0xff);
		buffer[13] = (byte)((length >> 8) & 0xff);
		buffer[14] = (byte)((length >> 16) & 0xff);
		buffer[15] = (byte)((length >> 24) & 0xff);

		_system_.arrayCopy(data, 0, buffer, 16, length);
        
        synchronized(sendList){
            sendList.add(buffer);
            sendList.notify();
        }
	}
        
    void readresp(){
        byte [] buffer = new byte [4096];

        GdbMiParser parser = new GdbMiParser();
        EchoBuffer ebuffer = new EchoBuffer();
        Pattern pattern = new Pattern("(?m)^(\\s*)\\(gdb\\)(\\s*)$");
        
        int bytes;
        while (bExit == false )
        {
            // Process the data
            int gdbend = -1;
            try
            {
                //ebuffer.clear();
                do{
                    bytes = _gdb_process.read(buffer, 0, 4096);
                    if (bytes > 0){
                        ebuffer.append(buffer, 0, bytes);
                        //_system_.output("recv:\n" + new String(buffer, 0, bytes));
                    }else{
                        throw new IllegalArgumentException("read failed");
                    }
                }while ((gdbend = ebuffer.match(pattern)) == -1 && bExit == false);
            }catch (Exception ex)
            {
                //_system_.output(ex.getMessage());
                setExit();
                return ;
            }
            
            
            if (gdbend > 0){
                try{
                    //_system_.output("parse:\n" + ebuffer.toString());
                    parser.process(ebuffer.getData(), gdbend);
                }catch (IllegalArgumentException e){
                    _system_.output(e.getMessage());
                    _system_.output("GDB/MI parsing error. Current buffer contents: \"" + new String(buffer, 0, bytes) + "\"");
                }

            
                // Handle the records
                List<GdbMiRecord> records = parser.getRecords();
                handleResponse(records);
                records.clear();
                ebuffer.remove(gdbend);
            }
        }
        
    }
};