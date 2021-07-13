//xlang Source, Name:DebugValueParser.x 
//Date: Fri Feb 12:54:17 2021 

class DebugValueParser{
    public DebugValueParser(String _tag){
        tag = _tag;
    }
    
    String tag = "";
    static class Range{
		public long start;
        public long length;
        public long object;
        public long itemload;
        public int unit;
        
        public Range(long s,long l,long o,int u, long load){
			start = s ;
            length = l;
            object = o;
            unit = u;
            itemload = load;
        }
    };
    
    public enum COMMAND{
        CMD_DISPLAYWATCH,
        CMD_LOADOBJECT,
        CMD_PARSEFRAME,
        CMD_CLEAR,
        CMD_PARSEWATCH
    };
    
    List<Object[]> commandQueue = new List<Object[]>();
    
    public void sendCommand(Object[] oa){
        synchronized (commandQueue) {
        	commandQueue.add(oa);
            processCommand();
        }
    }
    
    Object[] getCommand(){
        Object[]  cmd = nilptr;
        if (commandQueue.size() > 0){
            cmd = commandQueue.pollHead();
        }
        return cmd;
    }
    
    bool cmd_running = false;
    void processCommand(){
        if (cmd_running == false){
            cmd_running = true;
            Object[] cmd = getCommand();
            while (cmd != nilptr){
                executeCommand(cmd);
                cmd = getCommand();
            }
            cmd_running = false;
        }
    }
    
    void executeCommand(Object[] cmd){
        int n = (int)cmd[0];
        switch (n) {
        	case COMMAND.CMD_DISPLAYWATCH: /*TODO*/
                displayWatch((QTreeWidget) cmd[1],(Map<String,long>) cmd[2],(JsonObject) cmd[3]);
        	break;
            case COMMAND.CMD_LOADOBJECT: /*TODO*/
                loadObject((QTreeWidget) cmd[1],(JsonObject) cmd[2]);
        	break;
            case COMMAND.CMD_PARSEFRAME: /*TODO*/
                parseFrameInfo((QTreeWidget)cmd[1],(long)cmd[2],(JsonObject )cmd[3]);
        	break;
            case COMMAND.CMD_CLEAR: /*TODO*/
                clear((QTreeWidget)cmd[1]);
        	break;
            case COMMAND.CMD_PARSEWATCH: /*TODO*/
                parseWatchInfoCore((QTreeWidget) cmd[1],(Map<String,long>) cmd[2],(JsonObject) cmd[3]);
        	break;
        	default:
        	break;
        }
    }
    
    Map<long, JsonNode> expandTask = new Map<long, JsonNode>();
    JsonNode saveState;

    int serial = 0;
    Map<long, Range> array_objects = new Map<long, Range>();
    int getSerial(){
        return serial;
    }
    
    public String getIdentifier(){
        return tag + serial;
    }
    
    void querySaveState(QTreeWidget list, long item){
        try{
            JsonNode node = expandTask.get(item);
            if (node != nilptr){
                expandTask.remove(item);
                long [] items = list.getItemChildren(item);
                if (items != nilptr){
                    applyStateEx(list, items, (JsonArray)node);
                }
            }
        }catch(Exception e){
            
        }
    }
    
    bool expandArrays(QTreeWidget list, long item){
		Map.Iterator<long, Range> iter = array_objects.find(item);
		if (iter != nilptr){
			Range rg = iter.getValue();
            array_objects.remove(iter);
            list.setItemTag(item, 0, 0);
            
			if (rg != nilptr){
				if (rg.itemload != 0){
					list.removeItem(rg.itemload);
                    rg.itemload = 0;
                }
				//void splitArray(QTreeWidget list, long newitem , long object,long start, long length, int unit, bool recursion){
				splitArray(list, item, rg.object, rg.start, rg.length, rg.unit, true);
			}
            return true;
		}
		return false;
    }
    

    
    void loadObject(QTreeWidget list, @NotNilptr JsonObject json){
        synchronized(this){
            //long id = json.getString("id").parseLong();
            String qid = json.getString("queryid");
            if (qid != nilptr){
                if (qid.startsWith("detail:")){
                    try{
                        TextDetail td = new TextDetail();
                        String text = json.getString("value"); 
                        JsonObject text_root = new JsonObject(text);
                        String content = text_root.getString("value");
                        String caption = qid.substring(7, qid.length());
                        if (content != nilptr){
                            caption = caption + " : length=" + content.length();
                            td.create(caption, content, nilptr, false);
                        }
                    }catch(Exception e){
                    
                    }
                    
                }else{ 
                    long item = qid.parseLong();
                    
                    if (item != 0){
                        String param = json.getString("param");
                        if (param != nilptr){
                            long seri = param.substring(tag.length(), param.length()).parseLong();
                            String szType  = json.getString("type");
                            if (seri == serial){
                                String values = json.getString("value"); 
                                long loaditem = list.getItemTag(item, 1);
                                
                                if (loaditem != 0){
                                    list.removeItem(loaditem);
                                    list.setItemTag(item, 1, 0);
                                }
                                
                                if (values != nilptr && values.length() > 0){
                                    try{
                                        JsonObject valueroot = new JsonObject(values);
                                        if (szType != nilptr){
                                            list.setItemText(item,1 , szType);
                                        }
                                        displayValue(list, item, valueroot);
                                    }catch(Exception e){
                                        //_system_.consoleWrite("parse error:[" + values + "]\n");
                                    }
                                }else{
                                    list.setItemText(item, 2, "<找不到调试数据>");
                                }
                            }
                            querySaveState(list, item);
                        }
                    }
                }
            }
        }
    }
    
    public void expandItem(@NotNilptr QTreeWidget tree,long item, QOCallback r){
        synchronized(this){
            if (expandArrays(tree, item) == false){
                long objectId = tree.getItemTag(item, 0);
                if (objectId != 0){
                    tree.setItemTag(item, 0, 0);
                    synchronized(this){
                        long start = tree.getItemTag(item, 2);
                        long end = tree.getItemTag(item, 3);
                        XWorkspace.workspace.debuggee.queryObject("" + item, "" + objectId, getIdentifier(), start, end, r);
                    }
                }else{
                    querySaveState(tree, item);
                }
            }else{
                querySaveState(tree, item);
            }
        }
    }
    
    void setExpandItem(QTreeWidget list, long item,@NotNilptr  JsonNode child){
        expandTask.put(item, child);
        list.setExpand(item,true);
    }
    
    void applyState(QTreeWidget list){
        if (saveState == nilptr){
            return;
        }
        
        JsonArray state = (JsonArray)saveState;
        if (state != nilptr){
            long [] items = list.getTopItems();
            
            if (items == nilptr || items.length != state.length()){
                saveState = nilptr;
                return ;
            }
            
            for (int i =0; i < items.length; i++){
                String text = list.getItemText(items[i], 0);
                JsonObject item = (JsonObject)state.get(i);
                if (item != nilptr){
                    String slab = item.getString("label");
                    if (slab != nilptr && slab.equals(text) == false){
                        saveState = nilptr;
                        return ;
                    }
                }
            }
            
            applyStateEx(list, items, state);
        }
    }
    
    void applyStateEx(QTreeWidget list, @NotNilptr long [] items,@NotNilptr JsonArray state){
        int stlen = state.length();
        for (int i = 0; i < items.length; i++){
            if (i < stlen){
                JsonObject item = (JsonObject)state.get(i);
                if (item != nilptr){
                    bool exp = item.getBool("exp");
                    if (exp){
                        setExpandItem(list, items[i], item.get("child"));
                    }else{
                        String text = list.getItemText(items[i], 2);
                        String sval = item.getString("value");
                        if (sval != nilptr && sval.equals(text) == false){
                            list.setItemColor(items[i],0,0xffff0000);
                            list.setItemColor(items[i],2,0xffff0000);
                        }
                    }
                }
            }else{
                list.setItemColor(items[i],0,0xffff0000);
                list.setItemColor(items[i],2,0xffff0000);
            }
        }
    }
    
    void parseFrameInfo(QTreeWidget list, long tid,@NotNilptr  JsonObject json){
    
		//_system_.output(json.toString(false));
		JsonArray stack = (JsonArray)json.get("stack");
        JsonObject watch = (JsonObject)json.get("watch");
        JsonObject meminfo = (JsonObject)json.get("memlookup");

		if (meminfo != nilptr){
			MemoryLookupWnd.SetData(meminfo);
        }		
        
		if (stack != nilptr){
            synchronized(this){
				serial++;
                saveState = TreeStateSaver.saveState(list,0);
                expandTask.clear();
				list.clear();
                array_objects.clear();
            }
			for (int i = 0, c = stack.length(); i < c; i++){
				JsonObject obj = (JsonObject)stack.get(i);
				if (obj != nilptr){
					long item = list.addItem(nilptr, obj.getString("name"));
                    String sType = obj.getString("type");
                    if (sType != nilptr){
						list.setItemText(item, 1, sType);
                    }
                    String values = obj.getString("value"); 
                    
                    if (values != nilptr && values.length() > 0){
						try{
							JsonObject valueroot = new JsonObject(values);
							displayValue(list, item, valueroot);
						}catch(Exception e){
							//_system_.consoleWrite("parse error:[" + values + "]\n");
						}
                    }else{
						list.setItemText(item, 2, "<找不到调试数据>");
                    }
				}
			}
        }
        if (watch != nilptr){
            WatchWnd.watchesWnd.parseWatchInfo(watch);
        }
        
        applyState(list);
    }
    
    void displayWatch(QTreeWidget list, Map<String, long> watchs, JsonObject obj){
        long item = 0;
        String name = obj.getString("name");
        int error = obj.getInt("error");
        try{
            item = watchs.get(name);
            if (item != 0){
                list.removeAllchild(item);
                if (error == 0){
                    list.setItemText(item, 2, "");
                    list.setExpand(item, false);
                    String stype = obj.getString("type");
                    if (stype != nilptr){
                        list.setItemText(item, 1, stype);                
                    }
                    String values = obj.getString("value"); 
                    if (values != nilptr && values.length() > 0){
                        try{
                            JsonObject valueroot = new JsonObject(values);
                            displayValue(list, item, valueroot);
                            
                        }catch(Exception e){
                            //_system_.consoleWrite("error:" + e.getMessage());
                        }
                    }else{
                        list.setItemText(item, 2, "<找不到调试数据>");
                    }
                }else{
                    list.setItemText(item, 2, "<找不到调试数据>");
                }
            }
        }catch(Exception e){
        
        }
    }
    
    void parseWatchInfoCore(QTreeWidget list, Map<String, long> watchs, @NotNilptr JsonObject json){
            
        JsonArray watches;
        try{
			watches = (JsonArray)json.get("watch");
        }catch(Exception e){
        
        }
        
		if (watches != nilptr){
            serial++;
            saveState = TreeStateSaver.saveState(list,0);
            expandTask.clear();
            array_objects.clear();
			for (int i = 0, c = watches.length(); i < c; i++){
				JsonObject obj = (JsonObject)watches.get(i);
				if (obj != nilptr){
					displayWatch(list, watchs, obj);
				}
			}
        }
        applyState(list);
    }
    
    static long getSplit(long length){
		long i = 100;
        while (i < length){
			i *= 10;
        }
        return i / 10;
    }
    
    void displayArray(@NotNilptr QTreeWidget list, long item , long object,long start, long length, int unit, bool recursion){
		if (length > 0){
			long newitem = list.insertItem(item, nilptr, String.format("[%d~%d]", start, start + length - 1));
			splitArray(list, newitem, object, start, length, unit, recursion);
        }
    }
    
    void splitArray(@NotNilptr QTreeWidget list, long newitem , long object,long start, long length, int unit, bool recursion){
        if (unit >= 100){
            if (recursion == false){
				long iditem = list.insertItem(newitem, nilptr, "array");
				list.setItemText(iditem, 2, "loading");
                Range rg = new Range(start, length, object, unit, iditem);
                array_objects.put(newitem, rg);
            }else{
				int c = length / unit;
				long pos = start;
				for (int i =0; i < c; i ++){
					displayArray(list, newitem, object, pos, unit, unit / 10, false);
					pos += unit;
				}
				if (pos != start + length){
					displayArray(list, newitem, object, pos, start + length - pos, unit / 10, false);
				}
            }
        }else{
			list.setItemText(newitem, 3, "" + object);
			long iditem = list.insertItem(newitem, nilptr, "array");
			list.setItemText(iditem, 2, "loading");
			list.setItemTag(newitem, 0, object);
			list.setItemTag(newitem, 1, iditem);
            list.setItemTag(newitem, 2, start);
            list.setItemTag(newitem, 3, start + length);
        }
        
    }
    
    
    void displayValue(@NotNilptr QTreeWidget list, long item ,@NotNilptr JsonObject valueroot){
		if (valueroot.has("object_id")){
			String objectId = valueroot.getString("object_id");
            if (objectId != nilptr){
                if (valueroot.has("length")){
                    String address = valueroot.getString("address");
                    String slength = valueroot.getString("length");
                    if (slength != nilptr){
                        long lenitem = list.insertItem(item, nilptr, "length");
                        list.setItemText(lenitem, 1, "int");
                        list.setItemText(lenitem, 2, slength);
                        if (address != nilptr && (address.length() > 0)){
                            list.setItemText(item,2,address);
                        }
                        long length = slength.parseLong();
                        displayArray(list, item, objectId.parseLong(), 0,  length, getSplit(length), false);
                    }
                }else
                if (valueroot.has("thumb")){
                    String text = valueroot.getString("thumb");
                    if (text == nilptr){
                        text = "";
                    }
                    text = text.replace("\n", " ↩ ")
                                .replace("\r", " ↵ ")
                                .replace("\t", " ⇥ ")
                                .replace("\b", " ⇤ ") + " ...";
                                
                    list.setItemText(item, 2, text);
                    list.setItemText(item, 1, "" + valueroot.getString("type"));    
                    list.setItemTag(item, 2, objectId.parseLong());
                }else{
                    long iditem = list.insertItem(item, nilptr, "id");
                    list.setItemText(item, 3, objectId);
                    list.setItemText(iditem, 2, "loading");
                    list.setItemTag(item, 0, objectId.parseLong());
                    list.setItemTag(item, 1, iditem);
                }
            }
			return ;
		}
        
		int valueType = valueroot.getInt("valuetype");
		String values = valueroot.getString("value"); 
        
        if (values == nilptr){
			values = "nilptr";
        }else{
			values = values.replace("\n", " ↩ ")
							.replace("\r", " ↵ ")
							.replace("\t", " ⇥ ")
                            .replace("\b", " ⇤ ");
        }
		switch(valueType){
		case 0:
			list.setItemText(item, 2, values);
		break;
		case 1:
			parseMember(list, item, valueroot);
		break;
		case 2:
			parseArrayValue(list, item, valueroot);
		break;
		}
    }
    
    void parseArrayValue(@NotNilptr QTreeWidget list, long item ,@NotNilptr JsonObject valueroot){
        long dataitem = list.insertItem(item, nilptr, "data");

        JsonArray valarr = (JsonArray)valueroot.get("value");
        if (valarr != nilptr){
			for (int i = 0, c = valarr.length(); i < c; i++ ){                
				JsonObject valroot = (JsonObject)valarr.get(i);
                if (valroot != nilptr){
					long datitem = list.insertItem(dataitem, nilptr, "[" + valroot.getString("index") + "]");
                    String stype = valroot.getString("type");
                    if (stype != nilptr){
						list.setItemText(datitem, 1, stype);                
                    }          
					displayValue(list, datitem, valroot);
                }
            }
        }
    }
    
    void parseMember(@NotNilptr QTreeWidget list, long item ,@NotNilptr JsonObject valueroot){
        JsonArray valarr = (JsonArray)valueroot.get("value");
        if (valarr != nilptr){
			for (int i = 0, c = valarr.length(); i < c; i++ ){
				JsonObject valroot = (JsonObject)valarr.get(i);
                if (valroot != nilptr){
					long datitem = list.insertItem(item, nilptr, ((JsonObject)valarr.get(i)).getString("name"));
                    String stype = valroot.getString("type");
                    if (stype != nilptr){
						list.setItemText(datitem, 1, stype);                
                    }
					displayValue(list, datitem, valroot);
                }
            }
        } 
    }
    
    public void incserial(){
        synchronized(this){
            serial++;
        }
    }
    
    public void clear(QTreeWidget list){
        synchronized(this){
            serial++;
            list.clear();
            array_objects.clear();
        }
    }
};