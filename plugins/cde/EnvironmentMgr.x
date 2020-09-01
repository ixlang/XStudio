//xlang Source, Name:EnvironmentMgr.x 
//Date: Sun May 16:01:56 2020 

class EnvironmentMgr{
    static String defaultPath = nilptr;
    static bool loaded = false;
    
    public static String getEnvironmentPath(){
        if (loaded == false){
            defaultPath = _system_.getEnvironmentVariable("PATH");
            loaded = true;
        }
        return defaultPath;
    }
};