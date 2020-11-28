//xlang Source, Name:XUIEditor.x 
//Date: Sat Oct 21:47:13 2020 

class XUIEditor : DocumentView{
    QWidget _container;
    XWorkspace _workspace;
    
    public XUIEditor(XWorkspace _w){
        _workspace = _w;
    }
    
    public bool create(@NotNilptr QWidget parent) {
        if (super.create(parent)) {
            _container = new QWidget();
            _container.create(this);
            _container.show();
            return true;
        }
        return false;
    }
    
    public bool loadFile(@NotNilptr String file, String asCharset){
        return true;
    }
};