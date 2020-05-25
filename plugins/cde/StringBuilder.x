//xlang Source, Name:StringBuilder.x 
//Date: Fri Mar 17:30:45 2020 

class StringBuilder{
    String mText;
    public StringBuilder(String t){
        mText = t;
    }
    public StringBuilder(){
        mText = "";
    }
    
    public String toString(){
        return mText;
    }
    
    public void append(String text){
        mText = mText + text;
    }
    
    public void append(char text){
        mText = mText + text;
    }
    
    public int length(){
        return mText.length();
    }
};