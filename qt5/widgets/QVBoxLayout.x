//xlang Source, Name:qt5/widgets/QVBoxLayout.x 
//Date: Wed May 01:54:38 2020 

class QVBoxLayout : QBoxLayout{
    public bool create(QXWidget parent){
        nativehandle = createQObject(QType.qtVLayout, this, parent.nativehandle);
        if (nativehandle == 0){
            return false;
        }
        return true;
    }
};