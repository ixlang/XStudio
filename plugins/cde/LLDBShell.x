//xlang Source, Name:LLDBShell.x 
//Date: Mon Apr 01:22:30 2020 

class LLDBShell{
    long debug_port = -1;
    int _dbgserial;
    
    Process _gdb_process;
    Stream _xp, _client_pipe;
    
    String [] target_args;
    String target_path = nilptr;
    bool bExit = false;
    bool support_non_stop = false;
    int debuggee_type = 0;
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
        DBGExit = 34;
            
    Stream getPipe(){
        //if (_client_pipe.createstream())
        {
            return _client_pipe;
        }
        return nilptr;
    }
    
    LLDBShell(int dbgserial){
        VirtualPipe sv = new VirtualPipe(), cv = new VirtualPipe();
        _xp = sv.getStream(cv);// new XDebugPipe(dbgserial);
        _client_pipe = cv.getStream(sv);// = new XDebugPipe(dbgserial);
        //_xp.setForServer(true);
    }
    
    bool prepareForPipe(){
       /* if (_client_pipe.prepareForPipe())
        return _xp.prepareForPipe();
        return false;*/
        return true;
    }
    
    Process createProcess(String exec, String [] args, String dir){
        try{
            target_path = args[2];
            _gdb_process = new Process(exec, nilptr);
            _gdb_process.setWorkDirectory(dir);
        }catch(Exception e){
            
        }
        return _gdb_process;
    }
    
    bool startDebuggee(String [] args){
        target_args = args;
        if (_gdb_process.create(Process.StdOut | Process.StdIn | Process.RedirectStdErr)){
            bExit = false;
            new Thread(){
                void run(){
                    Thread.setName("threadReadloop");
                    threadReadloop();
                }
            }.start();
            
            new Thread(){
                void run(){
                    Thread.setName("readresp");
                    readresp();
                }
            }.start();
            
            new Thread(){
                void run(){
                    Thread.setName("threadSendloop");
                    threadSendloop();
                }
            }.start();
            
            return true;
        }
        return false;
    }
    
    bool isQuit(){
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
    
    int writeGdbCommand(String cmd){
    
        int ncmd = 0;
        
        synchronized(cmdlock){
            ncmd = command_token++;
        }
        
        return writeGdbCommand(ncmd, cmd);
    }
    
    int writeGdbCommand(int token, String cmd){        
        String finalcmd = "" + token + " " + cmd;
        
        if (writeGdbCmd(finalcmd)){
            return token;
        }
        return 0;
    }
    
    bool writeGdbCmd(String cmd){
        byte [] data = cmd.getBytes();
        try{
            if (data.length == _gdb_process.write(data,0,data.length)){
                return true;
            }
        }catch(Exception e){
            
        }
        return false;
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
                        _system_.output("debuggee connected!");
                        debug();
                        
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
    
    
    int analyzeCommand(EchoBuffer buf){
    
        byte [] buffer = buf.getData();
        
        XRegular.Result result = nilptr;
				 
        int offset = 0;
        
        while(nilptr != (result = XRegular.Match(buffer, offset, buf.getLength() - offset, "[FFFE]{c:LEBB}<len:2>{t:LEBB}<len:8>{l:LEBB}<len:4>*<len:l>"))){
            if (result != nilptr){
                int cmd = result.getValue('c');
                long tid = result.getValue('t');
                int conlen = result.getValue('l');
                
                JsonObject json;
                
                try{
                    json = new JsonObject(new String(buffer, 16 + offset, conlen));
                }catch(Exception e){
                    _system_.consoleWrite("XDebuggee 181 Exception :" + e.getMessage());
                }
                
                if (json == nilptr){
                    json = new JsonObject();
                }

                processCommand(cmd, tid, json);
                int al = result.getRegularLength();
                if (al > 0){
                    offset += al;
                }
            }
        }
        return offset;
    }
    
    
    void setupBreakPoint(String file, int line ,bool bset){
    
        BreakpointCreator bpc = new BreakpointCreator(file, line);
        addtoqueue(bpc);
        bpc.set(bset);
    }
    
    Map<int,long> gidThreadmap = new Map<int,long>();
    Map<long,int> idThreadmap = new Map<long,int>();
    
    
    void oncreateThread(int gid, long id){
        synchronized(gidThreadmap){
            gidThreadmap.put(gid, id);
            idThreadmap.put(id, gid);
        }
    }
    
    long onexitThread(int gid){
        long tid = 0;
        synchronized(gidThreadmap){
            Map.Iterator<int,long> iter = gidThreadmap.find(gid);
            if (iter != nilptr){
                tid = iter.getValue();
                idThreadmap.remove(tid);
                gidThreadmap.remove(iter);
            }
        }
        return tid;
    }
    
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
    
    void requestResp(GdbMiRecord [] _records, int offset, bool bDone){
        GdbMiRecord resord = _records[offset];
        GdbRequest rq = getRequest(resord.userToken);
        if (rq != nilptr){
            if (rq.next(_records, offset, bDone) == false){
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
        public bool next(GdbMiRecord [] _records,int offset, bool bDone);
        
        public bool sendtogdb(String cmd){
            command = cmd + "\n";
            return userToken == writeGdbCommand(userToken,command);
        }
        
        public int findStart(GdbMiRecord [] _records,int offset){
            while (offset >= 0){
                if (_records[offset].type == GdbMiRecord.Type.Log){
                    if (( (GdbMiStreamRecord)_records[offset]).message.equals(command)){
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
        public bool next(GdbMiRecord [] _records,int offset, bool bDone)override{
            if (step == 0){
                if (bDetaile){
                    sendtogdb("ptype " + name);
                }else{
                    sendtogdb("whatis " + name);
                }
                step++;
                return true;
            }else{
                setType(_records, offset);
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
        
        public void setType(GdbMiRecord [] _records,int offset){
            int count = offset;
            offset = findStart(_records,offset);
            
            if (offset > 0){
                for (int i = offset; i < count; i++){
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    String message  = _rec.message;
                    if (message.startWith("type = ")){
                        sztype = message.substring(7, message.length()).trim(true);
                    }else{
                        sztype = "unknow" ;
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
        
        bool next(GdbMiRecord [] _records,int offset, bool bDone)override{
            int count = offset;
            bool hasError = false;
            offset = findStart(_records,offset);
            String szOffset = nilptr;
            for (int i = offset; i < count; i ++){
                GdbMiRecord gmr = _records[i];
                if (isEndRecord(gmr)){
                    break;
                }else{
                    GdbMiStreamRecord srec = (GdbMiStreamRecord)gmr;
                    String msg = srec.message;
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
            
            String content = "";
            if (buffer.getLength() > 0){
                content = Base64.encodeToString(buffer.getData(),0,buffer.getLength(), false);
            }
            
            JsonObject json = new JsonObject();
            json.put("content", content);
            json.put("address", szOffset.parseHex());
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
    };
        
    class BreakpointCreator
         : GdbRequest{
         
        public BreakpointCreator(String f, int l){
            filepath = f;
            line = l;
        }
        
        String filepath;
        int line;
        bool bEnable;
        
        bool next(GdbMiRecord [] _records,int offset, bool bDone)override{
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
            
            return false;
        }
        
        public void set(bool enable){
            bEnable = enable;
            if (bEnable){
                sendtogdb("b " + filepath + ":" + line);
            }else{
                sendtogdb("clear " + filepath + ":" + line);
            }
        }
    };
    
    int findValuePos(String text, int pos, char end){
        bool se = false, de = false, escape = false;
        int deep = 0;
        
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
            
            if (b == '}'){
                deep--;
            }
            if (deep == 0){
                if (b == end){
                    return pos;
                }
            }
            if (b == '{'){
                deep++;
            }
            pos++;
        }
        return -1;
    }

    bool parseValue(String text, JsonObject object, bool bTop){
        
        int equ = text.indexOf('=');
        String name = "", value = "";
        if (equ != -1){
            name = text.substring(0, equ).trim(true);
            value = text.substring(equ + 1, text.length()).trim(true);
        }else{
            name = value = text.trim(true);
        }
        
        object.put("name", name);
        
        int st = findValuePos(text, 0, '{');
        if (st == -1){
            if (bTop){
                JsonObject __value = new JsonObject();
                __value.put("valuetype", 0);
                __value.put("value", value);
                object.put(("value"),__value);
            }else{
                object.put("valuetype", 0);
                object.put("value", value);
            }
            return true;
        }
        int end = findValuePos(text, st, '}');
        if (end == -1){
            if (bTop){
                JsonObject __value = new JsonObject();
                __value.put("valuetype", 0);
                __value.put("value", value);
                object.put(("value"),__value);
            }else{
                object.put("valuetype", 0);
                object.put("value", value);
            }
            return true;
        }
        
        String substr = text.substring(st + 1,end );
        
        int offset = 0;
        JsonArray members = new JsonArray();
        JsonObject jobj;
        
        int dp = findValuePos(substr, offset, ',');
        while (dp != -1){
            String txt = substr.substring(offset,dp);
            offset = dp + 1; 
            jobj = new JsonObject();
            if (parseValue(txt, jobj, false)){
                members.put(jobj);
            }
            dp = findValuePos(substr, offset, ',');
        }
        
        String txt = substr.substring(offset,substr.length());
        if (txt.length() > 0){
            jobj = new JsonObject();
            if (parseValue(txt, jobj, false)){
                members.put(jobj);
            }
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

    
    void updateAllThread(JsonObject tag, String reson){
        ThreadUpdater.Reson res = ThreadUpdater.Reson.RES_EXCEPTION;
        switch(reson){
            case "end-stepping-range":
            case "breakpoint-hit":
                res = ThreadUpdater.Reson.RES_BREAKPOINTHIT;
                
            break;
            case "exited-signalled":
            case "exception-received":
            case "signal-received":
                res = ThreadUpdater.Reson.RES_EXCEPTION;
            break;
            case "exited":
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
            new Pattern("^frame #([0-9]{1,24}):(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)(\\s+)at(\\s+)(.*)\\:([0-9]{1,24})$"),
            new Pattern("^frame #([0-9]{1,24}):(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)(\\s+)from(\\s+)(.*)$"),
            new Pattern("^frame #([0-9]{1,24}):(\\s+)0x([0-9a-fA-F]{1,16})(\\s+)in(\\s+)(.*)$"),
            new Pattern("^frame #([0-9]{1,24}):(\\s+)(.*)(\\s+)at(\\s+)(.*)\\:([0-9]{1,24})$")
        };
        
        public ThreadUpdater(JsonObject tag, Reson res){
            attach_object = tag;
            _reson = res;
        }
        
        public enum Reson{
            RES_EXCEPTION,
            RES_BREAKPOINTHIT
        };
        

        
        bool parseFrame(String item, JsonObject recv){
                         
            Pattern.Result rt = nilptr;
            int matchedId = -1;
            for (int i = 0; i < frmpattern.length; i++){
                rt = frmpattern[i].match(item, Pattern.NOTEMPTY);
                if (rt.length() > 0){
                    matchedId = i;
                    rt = rt.get(0);
                    break;
                }
            }
            
            String source = "", method = "", path = "", ip = "0";
            int line , row;
             if (rt.length() > 0){
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
            
                recv.put("source", path);
                recv.put("method", method);
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
        
        int generateThreadObject(JsonObject thread, String [] items, int offset){
            
            String thread_str = items[offset].trim(true);
            
            if (thread_str.startWith("*")){
                thread.put("sender", true);
                thread.put("interrupt", true);
                thread_str = thread_str.substring(2, thread_str.length()).trim(true);
            }
            
            if (thread_str.startWith("thread #")){
                thread_str = thread_str.substring(8, thread_str.length()).trim(true);
                int tid = thread_str.parseInt();
                thread.put("id", tid);
                thread.put("name", "Thread " + tid);
            }
            
            offset++;
            
            JsonArray frames = new JsonArray();
            for (; offset < items.length; offset++){
                String strFrame = items[offset].trim(true);
                if (strFrame.startWith("frame #") || strFrame.startWith("* frame #")){
                    JsonObject frame = new JsonObject();
                    if (strFrame.startWith("*")){
                        strFrame = strFrame.substring(1,strFrame.length()).trim(true);
                    }
                    parseFrame(strFrame, frame);
                    frames.put(frame);
                }else{
                    break;
                }
            }
            
            thread.put("stack", frames);
            
            return offset;
        }
        
        int updateThreadStatus(GdbMiRecord [] _records, int offset){
        //* thread # 然后一行为一帧
            GdbMiStreamRecord gmsr = (GdbMiStreamRecord)_records[offset - 1];
            
            String [] threadmsg = gmsr.message.split("\n");
            
            JsonArray tarrs = new JsonArray();
            
            
            if (threadmsg != nilptr){
                int index = 0;
                while (index < threadmsg.length){
                    JsonObject thread = new JsonObject();
                    index = generateThreadObject(thread, threadmsg, index);
                    tarrs.put(thread);
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

        bool next(GdbMiRecord [] _records,int offset, bool bDone)override{
            updateThreadStatus(_records, offset);
            return false;
        }
        
        public void update(){
            sendtogdb("bt all");
        }
        
    };
    
    class FrameRequest  
        : GdbRequest
    {
        public int gid;
        public long tid;
        public int frame;
        public int step = 0;
        public int notifySeted = 0;
        public bool canComplete = false;
        public Vector<GdbVariable> vars = new Vector<GdbVariable>();
        
        bool isCompleted(){
            for (int i =0; i < vars.size(); i++){
                if (vars[i].type.completed == false){
                    return false;
                }
            }
            return true;
        }
        
        bool next(GdbMiRecord [] _records,int offset, bool bDone)override{
            if (step == 3 || step == 4){
                parseLocals(_records, offset);
                if (step == 4){
                    canComplete = notifySeted > 0;
                }
            }
            if (step < 4){
                exec();
                return true;
            }else
            if (step == 4 && notifySeted == 0){
                docomplete();
            }
            return false;
        }
        
        public void exec(){
            switch(step){
                case 0:
                    sendtogdb("t " + gid);
                break;
                
                case 1:
                    sendtogdb("f " + frame);
                break;
                
                case 2:
                    step = 3;
                    sendtogdb("fr v");
                break;
            }
            step++;
        }
        
        void parseItem(String msg){
            int op = msg.find(" = ");
            if (op != -1){
                String name = msg.substring(0, op);
                String value = msg.substring(op + 3, msg.length());
                
                GdbVariable gv = new GdbVariable();
                gv.name = name;
                JsonObject object = new JsonObject();
                if (parseValue(msg, object, false)){
                    gv.jsonValue = object;
                }else{
                    gv.value = value;
                }
                gv.type = new TypeRequest(name);
                addtoqueue(gv.type);
                gv.type.next(nilptr, 0, true);
                gv.type.major = this;
                notifySeted++;
                vars.add(gv);
            }
        }
        
        void parseLocals(GdbMiRecord [] _records,int offset){
            int count = offset;
            
            offset = findStart(_records,offset);
            
            if (offset > 0){
                String msg = "";
                
                for (int i = offset; i < count; i++){
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
                            parseItem(msg);
                        }
                        msg = "";
                    }
                }
                
                if (msg.length() > 0){
                        msg = msg.trim(true);
                        
                        if (msg.length() != 0){
                            parseItem(msg);
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
            
            for (int i =0; i < vars.size(); i++){
                JsonObject _var = new JsonObject();
                GdbVariable gvs = vars[i];
                _var.put("name", gvs.name);
                _var.put("type", gvs.type.sztype);
                
                
                
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
            sendCommand(QueryFrame, tid, data, data.length);
        }
        
    };
    
    void dumpmemory(String p,String address, int size){
        MemoryRequest mreq = new MemoryRequest(p, address, size);
        addtoqueue(mreq);
        mreq.exec();
    }
    
    void addtoqueue(GdbRequest fr){
       synchronized(__request){
           __request.put(fr.userToken,fr);
       }
    }
    
    void queryStackFrame(int tid, int frm){
       FrameRequest fr = new FrameRequest();
       fr.gid = id2gid(tid);
       fr.tid = tid;
       fr.frame = frm;
       fr.type = RequestType.SwitchFrame;

       addtoqueue(fr);
       fr.exec();
    }
    
    
    Map<String, bool> watches_object = new Map<String, bool>();
    
    void addWatch(JsonArray names, bool bDelete){
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
    
    
    class Watcher: GdbRequest{
        WatchRequest _parent;
        
        TypeRequest _type;
        String typeName = nilptr;
        String objname;
        
        public Watcher(String name, WatchRequest _p){
            objname = name;
            _parent = _p;
        }
        
        public void exec(){
            _type = new TypeRequest(objname);
            addtoqueue(_type);
            _type.next(nilptr, 0, true);
            _type.major = this;
        }
        
        public void docomplete(){
            typeName = _type.sztype;
            addtoqueue(this);
            sendtogdb("p " + objname);
        }
        
        public bool next(GdbMiRecord [] _records,int offset, bool bDone){
            int pos = findStart(_records, offset);
            _parent.update(objname, typeName, _records, pos, offset, bDone);
            return false;
        }
    };
    
    class ContinueEnv : GdbRequest{
       public  void exec(){
            addtoqueue(this);
            sendtogdb("c");
        }
        
        bool next(GdbMiRecord[] _records,int offset,bool bDone){
            sendStateRun(nilptr);
            return false;
        }
    };
        
        
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
    
    class WatchRequest 
        : GdbRequest
    {
        
        GdbRequest parentReq = nilptr;
        Map<String, JsonObject> _objects = new Map<String, JsonObject>();
        int request_cnt = 0;
        
        public WatchRequest(Map<String, bool> watches){
            Map.Iterator<String, bool> iter = watches.iterator();
            while(iter.hasNext()){
                String key = iter.getKey();
                _objects.put(key, nilptr);
                iter.next();
            }
        }
        
        public void update(String name, String typename, GdbMiRecord [] _records,int offset, int end, bool bDone){
            request_cnt++;
            
            String content = "";
            for (int i = offset; i < end; i ++){
                content = content + ((GdbMiStreamRecord)_records[i]).message;
            }
            
            JsonObject object = new JsonObject();
            parseValue(content, object, true);
            object.remove("name");
            object.put("name", name);
            object.put("type", typename);
            _objects.put(name,object);
            
            if (request_cnt == _objects.size()){
                docomplete();
            }
        }
        
        bool next(GdbMiRecord [] _records,int offset, bool bDone){
            return false;
        }
        
        JsonObject getWatch(){
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
        
       public  void exec(){
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
    
    void processCommand(int cmd,int tid,JsonObject json){
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
        setupBreakPoint(file, line, set != 0);
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
        
        addWatch(names, bDelete);
        
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
		/*const char * qid = root.root().value("queryid");
		const char * oid = root.root().value("id");
		const char * param = root.root().value("param");
		const char * offset = root.root().value("offset");
		const char * end = root.root().value("end");

		long64 noffset = -1, nend = -1;
		if (offset != 0){
			noffset = cacharset::tolong(offset);
		}
		if (end != 0){
			nend = cacharset::tolong(end);
		}
		onQueryObject(qid, oid, param, noffset, nend);*/
	}
		break;

	case GcDump:
		//dumpGcObject();
		break;

	case QueryByName:
	{
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
        dumpmemory(nilptr, json.getString("address"), json.getInt("size"));
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
    
    void exit(){
        _gdb_process.raise(_system_.SIGINT);
        writeGdbCommand("q\n");
    }
    
    void close(){
        _xp.close();
        _client_pipe.close();
    }
    
    class ThreadTag{
        public String name;
        public int gId;
        public long id;
        public int processid;
        public static Pattern threadprt = new Pattern("^(Thread )([0-9]{1,24})( \\(Thread )([0-9a-fA-F]{1,16})(\\.0x)([0-9a-fA-F]{1,16})\\):$"), 
                       sithrprt = new Pattern("^(Thread )([0-9]{1,24})( \\(process )([0-9a-fA-F]{1,16})\\):$");
                       
        static Pattern createthreadprt = new Pattern("(^\\[New Thread )([0-9a-fA-F]{1,16})(\\.0x)([0-9a-fA-F]{1,16})\\]$");
        
       
        public ThreadTag(String text){
            bool isSim = false;

            Pattern.Result rt = threadprt.match(text, Pattern.NOTEMPTY);
            
            if (rt.length() <= 0){
                rt = sithrprt.match(text, Pattern.NOTEMPTY);
                isSim = true;
            }
            
               Pattern.Result item = rt.get(0);
               
               if (isSim == false && item.length()  == 7){
                   String idName = text.substring(item.get(2).start(),item.get(2).end());
                   String proId = text.substring(item.get(4).start(),item.get(4).end());
                   String thrId = text.substring(item.get(6).start(),item.get(6).end());
                    
                   processid = proId.parseInt();
                   id = thrId.parseHex();
                   gId = idName.parseInt();
                   name = "Thread " + idName;
               }else
               if (isSim && item.length() == 5){
                   String proId = text.substring(item.get(4).start(),item.get(4).end());
                   String idName = text.substring(item.get(2).start(),item.get(2).end());
                   
                   processid = proId.parseInt();
                   gId = id = idName.parseInt();
                   name = "Thread " + idName;
               }
            
        } 
        
        public ThreadTag(String _name, String nameid){
            id = nameid.parseHex();
            gId = nameid.parseInt();
            name = _name;
        }
        public ThreadTag(String _name, String nameid, String crt_text){
             
            Pattern.Result rt = createthreadprt.match(crt_text, Pattern.NOTEMPTY);
            if (rt.length() > 0){
               Pattern.Result item = rt.get(0);
               if (item != nilptr){
                   String proId = crt_text.substring(item.get(2).start(),item.get(2).end());
                   String thrId = crt_text.substring(item.get(4).start(),item.get(4).end());
                    
                   processid = proId.parseInt();
                   id = thrId.parseHex();
                   gId = nameid.parseInt();
                   name = _name;
               }
            }
        }
    };

    
    
    void handleRecord(GdbMiRecord record)
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
    
    void notifyLibraryLoaded(GdbMiResultRecord record){
        if (record.results.size() > 0){
            String path = record.results[0].value.string;
            JsonObject object = new JsonObject();
            object.put("module", path);
            if (record.results.size() > 2){
                String symbol = record.results[3].value.string;
                object.put("symbol", (symbol != nilptr && symbol.length() > 0));
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
            
            to.put("name", "Thread " + tid);
            to.put("interrupt", false);
            
            ThreadTag tag ;
            if (result != nilptr){
                tag = new ThreadTag("Thread", tid, result.message.trim(true));
            }else{
                tag = new ThreadTag("Thread", tid);
            }
            
            to.put("id", tag.id);
            
            JsonArray tarrs = new JsonArray();
            tarrs.put(to);
            
            JsonObject tn = new JsonObject();
            tn.put("threads", tarrs);
            tn.put("action", XDBG_STATE_CREATE);
            oncreateThread(tag.gId, tag.id);
            byte [] data = tn.toString(false).getBytes();
            sendCommand(Interrupt, tag.id, data, data.length);
        }
    }
        
    void notifyThreadExited(GdbMiRecord [] _records, int offset){
        GdbMiResultRecord record = (GdbMiResultRecord)_records[offset];
        
        JsonObject to = new JsonObject();
        if (record.results.size() > 0){
            String gid = record.results[0].value.string;
            long tid = onexitThread(gid.parseInt());
            
            to.put("name", "Thread " + gid);
            to.put("interrupt", false);
            to.put("id", tid);
            
            JsonArray tarrs = new JsonArray();
            tarrs.put(to);
            
            JsonObject tn = new JsonObject();
            tn.put("threads", tarrs);
            tn.put("action", XDBG_STATE_EXIT);
            
            byte [] data = tn.toString(false).getBytes();
            sendCommand(Interrupt, tid, data, data.length);
        }
    }
    
    void stepin(){
        writeGdbCommand("s\n");
    }
    
    void stepover(){
        writeGdbCommand("n\n");
    }
    
    void stepout(){
        writeGdbCommand("fin\n");
    }
    
    void conrun(){
        new ContinueEnv().exec();
    }
    
    void notifyStoped(GdbMiResultRecord record){
    
        if (record.results.size() > 0){
            String reson ,signal_name = "",signal_mean = "",addr = "", tid = "";
            
            reson = record.results[0].value.string;
            
            if (record.results.size() > 1){
                signal_name = record.results[1].value.string;
            }
            
            if (record.results.size() > 2){
                signal_mean = record.results[2].value.string;
            }
            
            if (record.results.size() > 3){
                if (record.results[3].value.tuple != nilptr && record.results[3].value.tuple.size() > 0){
                    addr = record.results[3].value.tuple[0].value.string;
                }
            }
            
            if (record.results.size() > 4){
                tid = record.results[4].value.string;
            }
            
            JsonObject _exception_obj = new JsonObject();
            _exception_obj.put("name", signal_name);
            _exception_obj.put("address", addr);
            _exception_obj.put("msg", signal_mean);
            _exception_obj.put("gid", tid.parseInt());
            
            updateAllThread(_exception_obj, reson);
        }
    }
    
    ThreadTag parseThreadInfo(String item,@NotNilptr JsonObject jobj){
        if (item.startWith("Thread")){
            ThreadTag tg = new ThreadTag(item);
            jobj.put("name", tg.name);
            jobj.put("id", tg.id);
            jobj.put("process", tg.processid);
            jobj.put("interrupt", true);
            return tg;
        }
        return nilptr;
    }
    
    bool isEndRecord(GdbMiRecord rec){
        return rec.type == GdbMiRecord.Type.Immediate;
    }
    
    void handleResponse(List<GdbMiRecord> records){
        GdbMiRecord [] _records = records.toArray(new GdbMiRecord[0]);
        int lastError = -1;
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
                            notifyStoped(_result);
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
                            
                        break;
                    }
                    
                    break;
                case GdbMiRecord.Type.Log:
                if (debuggee_type == 0 || debuggee_type == DEBUGGEE_LLDB){
                    GdbMiStreamRecord _rec = (GdbMiStreamRecord)_records[i];
                    if (_rec.message.startWith("error: ")){
                        lastError = i + 1;
                    }
                }
                break;
                case GdbMiRecord.Type.Target:
                case GdbMiRecord.Type.Console:
                break;
            }
        }
               
    }
    
    class GDBDetect : GdbRequest{
        int step = 0;
        int state_result = 0;
        
        public GDBDetect(){
            
        }
        
        bool next(GdbMiRecord[] _records,int offset,bool bDone){
            switch(step){
                case 0 :
                    run_target();
                break;
                
                default:
                    state_result = -1;
                break;
            }
            
            return false;
        }
        
       public  void exec(){
            addtoqueue(this);
            sendtogdb("version");
        }
        
        void setArgs(){
            if (target_args != nilptr && target_args.length > 0){
                String __args = "";
                for (int i = 0; i < target_args.length; i++){
                    __args = __args + " " + target_args[i];
                }
                sendtogdb("settings set target.run-args" + __args);
            }
        }
        
        void run_target(){ 
            writeGdbCmd("-file-exec-and-symbols "  + target_path + "\n");
            setArgs();
            sendtogdb("pro la -t --");
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
        
        
        int bytes;
        while (bExit == false )
        {
            // Process the data
            try
            {
                ebuffer.clear();
                do{
                    bytes = _gdb_process.read(buffer, 0, 4096);
                    if (bytes > 0){
                        ebuffer.append(buffer, 0, bytes);
                        //_system_.output("recv:\n" + new String(buffer, 0, bytes));
                    }else{
                        throw new IllegalArgumentException("read failed");
                    }
                }while (ebuffer.endWithLine("(gdb)") == false );
            }catch (Exception ex)
            {
                setExit();
                return ;
            }
            
            if (bytes > 0){
                try{
                    //_system_.output("parse:\n" + ebuffer.toString());
                    parser.process(ebuffer.getData(), ebuffer.getLength());
                }catch (IllegalArgumentException e){
                    //_system_.output(e.getMessage());
                    //_system_.output("GDB/MI parsing error. Current buffer contents: \"" + new String(buffer, 0, bytes) + "\"");
                }

                // Handle the records
                List<GdbMiRecord> records = parser.getRecords();
                handleResponse(records);
                records.clear();
            }
        }
        
        return ;
    }
};