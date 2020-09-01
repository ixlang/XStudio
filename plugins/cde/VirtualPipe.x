//xlang Source, Name:VirtualPipe.x 
//Date: Wed Mar 20:12:00 2020 

class VirtualPipe{

    
    bool closed = false;

    static const int STATE_FREE = 0, STATE_WAIT_READ = 1, STATE_WAIT_WRITE = 2;
    
    int state = 0;
    
    static class VPInputStream : Stream{
        VirtualPipe _virtualpipe;
        VirtualPipe _outputpipe;
        
        public VPInputStream(VirtualPipe vp, VirtualPipe os){
            _virtualpipe = vp;
            _outputpipe = os;
        }
        
        public int write(byte[] data,int index,int len)override{
            return _virtualpipe.write(data,index,len);
        }
        public int read(byte[] data,int index,int len)override{
            return _outputpipe.read(data,index,len);
        }
        public long seek(int ,long )override{
            return 0;
        }
        public long getPosition()override{return 0;}
        public long length()override{ return 0;}
        public long available(bool )override{return 0;} 
        public void close()override{_virtualpipe.close();_outputpipe.close();}
    };

    public Stream getStream(VirtualPipe outputpipe){
        return new VPInputStream(this, outputpipe);
    }
    
    bool createstream(){
        return true;
    }
    
    byte [] buffer;
    int pos = 0, length = 0, buffer_len = 0;
    
    int write(byte [] data, int index, int len){
        synchronized(this){
            while (length != 0 && (closed == false)){
                this.wait();
            }
            if (closed){ return -1; }
            if (len > 0){
                if (buffer_len < len){
                    buffer_len = len;
                    buffer = new byte[buffer_len];
                }
                pos = 0;
                length = len;
                _system_.arrayCopy(data,index,buffer,0,len);
            }
            this.notify();
        }
        return len;
    }
    
    int read(byte [] data, int index, int len){
        synchronized(this){
            while ((length == 0) && (closed == false)){
                this.wait();
            }
            if (closed){ return -1; }
            if (len > 0){
                len = readData(data, index, len);
            }
            this.notify();
        }
        return len;
    }
    
    int readData(byte [] data, int index, int len){
        int rd = Math.min(len, length);
        _system_.arrayCopy(buffer,pos,data,index,rd);
        pos += rd;
        length -= rd;
        return rd;
    }
    
    void close(){
        synchronized(this){
            if (closed == false){
                closed = true;
                this.notifyAll();
            }
        }
    }
};