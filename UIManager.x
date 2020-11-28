//xlang Source, Name:UIManager.x 
//Date: Fri Nov 22:21:01 2020 

class UIManager{
    public static QBuffer getUIData(byte [] buffer){
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        return qb;
    }
};