//xlang Source, Name:EchoBuffer.x 
//Date: Wed Mar 18:11:38 2020 

class EchoBuffer{
    protected int length = 0;
    protected byte [] data = new byte[0];
    
    public void append(byte[] buffer, int pos, int len){
        if (length + len > data.length){
            byte [] new_buffer = new byte[(length + len) * 2];
            _system_.arrayCopy(data, 0, new_buffer, 0, length);
            _system_.arrayCopy(buffer, pos, new_buffer, length, len);
            data = new_buffer;
        }else{
            _system_.arrayCopy(buffer, pos, data, length, len);
        }
        length += len;
    }
    
    public byte [] getData(){
        return data;
    }
    
    public void clear(){
        length = 0;
    }
    
    public int getLength(){
        return length;
    }
    
    public void remove(int size){
        _system_.arrayCopy(data, size, data, 0, length - size);
        length -= size;
    }
    
    public bool endsWith(@NotNilptr byte [] cdata){
        if (length >= cdata.length){
            int start = length - cdata.length;
            for (int i =0; i < cdata.length; i++){
                if (cdata[i] != data[start + i]){
                    return false;
                }
            }
            return true;
        }
        return false;
    }
    
    public bool endWithLine(@NotNilptr String line){
        int offset = length - line.length();
        while (offset > 0){
            if (data[offset] == '\n'){
                String lastline = new String(data, offset + 1, length - (offset + 1)).trim(true);
                return lastline.equals(line);
            }
            offset--;
        }
        return false;
    }
    
    public String getLine(){
        String out;
        for (int i = 0; i < length; i++){
            if (data[i] == '\n'){
                i++;
                try{
                    if (_system_.getPlatformId() == 0){
                        out = new String(data, 0, i, "GB18030//IGNORE");
                    }else{
                        out = new String(data, 0, i);
                    }
                }catch(Exception e){
                    out = new String(data, 0, i);
                }
                _system_.arrayCopy(data, i, data, 0, length - i);
                length -= i;
                return out;
            }
        }
        return out;
    }
    
    int indexOf(char c){
        for (int i = 0; i < length; i++){
            if (data[i] == c){
                return i;
            }
        }
        return -1;
    }
    
    public @NotNilptr  String toString(){
        try{
            if (_system_.getPlatformId() == 0){
                return new String(data, 0, length, "GB18030//IGNORE");
            }else{
                return new String(data, 0, length);
            }
        }catch(Exception e){
            
        }
        return new String(data, 0, length);
    }
    
    public @NotNilptr  String toRawString(int start, int len){
        return new String(data, start, len);
    }
    
    public @NotNilptr  String toRawString(){
        return new String(data, 0, length);
    }
    
    public @NotNilptr int match(@NotNilptr Pattern pattern){
        Pattern.Result res = pattern.matchAll(new String(data, 0, length),0, -1, Pattern.NOTEMPTY);
        if (res.length() != 0){
            return res.get(res.length() - 1).end();
        }
        return -1;
    }
};