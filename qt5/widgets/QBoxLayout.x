//xlang Source, Name:qt5/widgets/QBoxLayout.x 
//Date: Wed May 02:04:09 2020 

class QBoxLayout : QLayout{
    public void addWidget(QXWidget  w){
        widget_set_intlongint_value(nativehandle, LAYTOUADDWIDGET, w.nativehandle, 0, 0);
    }
};