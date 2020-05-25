//xlang Source, Name:IXIntelliSense.x 
//Date: Tue Feb 15:59:40 2020 


class WordRecognizer{
    public bool isWord(char c, bool first);
    public bool isTriggedChar(char c);
    public bool isDocument(String ext);
    public String getFileFilter(String filepath, bool bopen);
};

class IXIntelliSense{
    public interface XIntelliResult{
        String get_name();
        int get_type();
        bool hasProp(char c);
        XIntelliResult get_class();
        XIntelliResult[] get_params();
        String get_source();
        int get_line();
        int get_row();
    };
    
    public void setCommand(String , String);
    public void appendLibpath(String path);
    public void appendLib(String path);
    public void appendLink(String path);
    public void addSource(String source);
    public XIntelliResult [] getIntelliSenseL(String source,int line, int column);
    public XIntelliResult [] getIntelliSenseObject(String source,int line, int column, String name);
    public XIntelliResult [] getIntelliSenseObjectM(String source,int line);
    public XIntelliResult [] getIntelliSense(String source,String content, long pos, int line, int column);
    public String getIntelliSenseMap();
    public void update(String sourcePath, String content);
    public void updateSource(String sourcePath, String newFile);
    public XIntelliResult [] getResult();
    public WordRecognizer getWordRecognizer(String filePath);
    public void close();
    public bool initializ();
};