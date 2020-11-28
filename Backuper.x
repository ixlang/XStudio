//xlang Source, Name:Backuper.x 
//Date: Sat Nov 10:22:41 2020 

class Backuper{
    String newfile, oldfile;
    bool success = false;
    
    public Backuper(String file){
        oldfile = file;
        newfile = oldfile.append(".bak");
        XPlatform.deleteFile(newfile);
        success = XPlatform.renameFile(oldfile,newfile);
    }

    public void complete(){
        if (success){
            XPlatform.deleteFile(newfile);
        }
    }
    
    public void restore(){
        if (success){
            XPlatform.deleteFile(oldfile);
            XPlatform.renameFile(newfile,oldfile);
        }
    }
};