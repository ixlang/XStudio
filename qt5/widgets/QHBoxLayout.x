//xlang Source, Name:qt5/widgets/QHBoxLayout.x 
//Date: Wed May 01:54:15 2020 

class QHBoxLayout : QBoxLayout{

    public bool create(QXWidget parent){
        nativehandle = createQObject(QType.qtHLayout, this, parent.nativehandle);
        if (nativehandle == 0){
            return false;
        }
        return true;
    }

};