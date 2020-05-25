//xlang Source, Name:VirtualPipe.x 
//Date: Wed Mar 20:12:00 2020 

class VirtualPipe{
    byte [] buffer;
    int pos;
    int length;
    int writed_len;
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
    int write(byte [] data, int index, int len){
        int wrl = 0;
        synchronized(this){
            while((len > 0) && (closed == false)){
                while ((buffer == nilptr) && (closed == false)){
                    state = STATE_WAIT_READ;
                    this.wait();
                }
                if (closed){
                    return -1;
                }
                int al = length - writed_len;
                if (al > 0){
                    int wl = Math.min(len, al);
                    _system_.arrayCopy(data,index,buffer,pos + writed_len,wl);
                    wrl += wl;
                    writed_len += wl;
                    index += wl;
                    len -= wl;
                }else{
                    buffer = nilptr;
                    if (state == STATE_WAIT_WRITE){
                        this.notify();
                    }
                }
            }
            
            buffer = nilptr;
            if (state == STATE_WAIT_WRITE){
                this.notify();
            }
            if (state == STATE_WAIT_READ){
                state = STATE_FREE;
            }
        }
        return wrl;
    }
    
    int read(byte [] data, int index, int len){
        synchronized(this){
            buffer = data;
            pos = index;
            length = len;
            writed_len = 0;
            
            if (state == STATE_WAIT_READ){
                this.notify();
            }
            
            while ((buffer != nilptr) && (closed == false)){
                state = STATE_WAIT_WRITE;
                this.wait();
            }
            
            if (closed){
                return -1;
            }
                
            if (state == STATE_WAIT_WRITE){
                state = STATE_FREE;
            }
        }
        return writed_len;
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