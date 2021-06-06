//xlang Source, Name:IXIntelliSense.x 
//Date: Tue Feb 15:59:40 2020 


class WordRecognizer{
    public bool isWord(char c, bool first); /** 判断该字符是否标识符 **/
    public bool isTriggedChar(char c);  /** 触发自动完成的字符 **/
    public bool isDocument(String ext); /** 判断文件扩展是否属于源文件 **/
    public String getFileFilter(String filepath, bool bopen);   /** 获取文件过滤器 **/
};


interface DiagnosisInformation{
    String getCode();
    String getMessage();
    int getLine(bool end);
    int getCharacter(bool end);
    int getType();
};

class IXIntelliSense{

	public static const int XIS_NAME = 0,
				XIS_TYPE  = 1,
				XIS_CLAS = 2,
				XIS_PROP = 3,
                XIS_BACL = 4,
                XIS_SRC = 5,
                XIS_LINE = 6,
                XIS_ROW = 7,
                XIS_VISIBILITY = 8;
    
    
    public interface IntelliClient{
        void diagnosis(String file, DiagnosisInformation[] diags);
        void showMessage(String message);
        void notify(String , String);
    };
    /**
    语言服务器输出对象
    ***/
    public interface XIntelliResult{
        @NotNilptr String get_name();/** 名称**/
        int get_type();/** 类型 **/
        int get_visibility();/** 可见性 **/
        bool hasProp(char c);   /** 属性 **/
        XIntelliResult get_class(); /** 类型对象 **/
        XIntelliResult[] get_params();  /** 参数 **/
        String get_source();    /** 源文件 **/
        int get_line(); /** 行 **/
        int get_row();  /** 列 **/
        InputDescription makeInputText();   /** 获取插入数据 **/
        void accept();  /** 用作自动完成时,提示改项已被接受 **/
    };
    
    public interface InputDescription{
        String getInsertText();
        int [][] getTipsDescription();
    };
    
    /**
        其他命令
    **/
    public void setCommand(String , String);
    
    /**
    增加库搜索路径
    **/
    public void appendLibpath(String path);
    
    /***
    增加库文件
    **/
    public void appendLib(String path);
    
    /***
    增加链接文件
    **/
    public void appendLink(String path);
    
    /**
    增加源文件
    **/
    public void addSource(String source);
    
    /**
    获取文件内的符号
    */
    
    public XIntelliResult [] getObjectListInFile(@NotNilptr String source, String content);
    /**
        获取指定位置的对象列表
    **/
    public XIntelliResult [] getObjectList(String source, String content, int line, int column);
    
    /**
        获取指定位置名称为name的对象
    **/
    public XIntelliResult [] getSpecialObjects(String source,int line, int column, String name);
    
    /**
        获取指定行的域对象
    **/
    public XIntelliResult [] getDomain(String source,int line);
    
    /**
        获取位置处的对象引用
    **/
    public XIntelliResult [] findReferences(String source, String content, long pos);
    
    /**
        获取指定position的自动完成信息
    **/
    public XIntelliResult [] getCompletion(String source,String content, long pos, int line, int column);
    
    /**
        获取指定position的信息
    **/
    public String getInformation(String source,String content, long pos, int line, int column);
    
    /**
        获取符号
        file为空 表示获取全局符号
        file不为空表示获取指定文件内的符号
    **/
    public String getSymbols(String file);
    
    /***
        更新文档内容
    **/
    public void update(String sourcePath, String content);
    
    /**
        文件操作
        source 和 new 同时不等于空  则为重命名
        new为空  删除文件
        source为空 添加文件
    **/
    public void renamefile(String sourcePath, String newFile);
    
    
    //public XIntelliResult [] getResult();
    
    /**
        获取标识符识别器
    **/
    public WordRecognizer getWordRecognizer(String filePath);
    
    
    /**
        关闭语言服务器
    **/
    public void close();
    
    /**
        初始化语言服务器
    **/
    public bool initializ(IntelliClient client);
    
    /**文档已经被打开**/
    public void documentDidOpen(String filePath);
    
    /** 文档已关闭**/
    public void documentDidClose(String filePath);
    
    public void reconfigure();
    
    public String getProperity(String key);
};