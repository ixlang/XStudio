//xlang Source, Name:JsonRPC.x 
//Date: Sat Apr 02:31:25 2020 

class JsonRPC{

    protected StringBuffer data = new StringBuffer(1024);
    
    public void append(byte[] buffer, int pos, int len){
        data.append(buffer,pos,len);
    }
    
    public byte [] getData(){
        return data.getBytes();
    }
    
    public void clear(){
        data.clear();
    }
    
    public int getLength(){
        return data.length();
    }
    
    public void remove(int size){
        data.replace(0,size,"");
    }
    
    public bool endWith(@NotNilptr byte [] cdata){
        return data.endWith(new String(cdata));
    }
    
    public bool endWithLine(@NotNilptr String line){
        int length = data.length();
        int offset = length - line.length();
        if (offset > 0){
            int pos = data.lastIndexOf('\n', offset);
            if (pos != -1){
                String lastline = data.substring(pos + 1,length - (offset + 1)).trim(true);
                return lastline.equals(line);
            }
        }
        return false;
    }
    
    public String getLine(){
        String out;
        int pos = data.indexOf('\n');
        if (pos != -1){
            pos++;
            out = data.substring(0,pos);
            try{
                if (_system_.getPlatformId() == 0){
                    out = new String(out.getBytes(), "GB18030//IGNORE");
                }
            }catch(Exception e){
            }
            data.replace(0,pos,"");
            return out;
        }
        return out;
    }
    
    int indexOf(char c){
        return data.indexOf(c);
    }
    
    public @NotNilptr  String toString(){
        try{
            if (_system_.getPlatformId() == 0){
                return new String(data.getBytes(), "GB18030//IGNORE");
            }else{
                return data.toString();
            }
        }catch(Exception e){
            
        }
        return data.toString();
    }
    
    public @NotNilptr  String toRawString(int start, int len){
        return data.substring(start, start + len);
    }
    
    public @NotNilptr  String toRawString(){
        return data.toString();
    }
    
    public @NotNilptr int match(@NotNilptr Pattern pattern){
        Pattern.Result res = pattern.matchAll(data.toString(),0, -1, Pattern.NOTEMPTY);
        if (res.length() != 0){
            return res.get(res.length() - 1).end();
        }
        return -1;
    }
    
    public int indexOf(@NotNilptr String pb){
        return data.indexOf(pb);
    }
    
    public int indexOf(@NotNilptr String pb, int ofst){
        return data.indexOf(pb, ofst);
    }
    
    public int lastIndexOf(@NotNilptr String pb){
        return data.lastIndexOf(pb);
    }
    
    public int lastIndexOf(@NotNilptr String pb, int ofst){
        return data.lastIndexOf(pb, ofst);
    }
    
    public @NotNilptr String substring(int start, int end){
        return data.substring(start, end);
    }
    
    public int length(){
        return data.length();
    }
};