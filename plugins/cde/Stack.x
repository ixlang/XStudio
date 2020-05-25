//xlang Source, Name:Stack.x 
//Date: Sun Mar 22:54:17 2020 

class Stack<_T> 
    : Vector<_T>{

    public void push(_T obj){
        add(obj);
    }
    
    public bool isEmpty(){
        return size() == 0;
    }
    public _T lastElement(){
        return this.operator[](size() - 1);
    }
    
    public _T pop(){
        _T t = lastElement();
        remove(size() - 1);
        return t;
    }
};