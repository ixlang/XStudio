//xlang Source, Name:MultiSelectDialog.x 
//Date: Sat Apr 04:24:36 2020 

class MultiSelectDialog : QXDialog{    
    InputDialog.onInputListener listener;
	public MultiSelectDialog(InputDialog.onInputListener intputlis, String [] items){
		listener = intputlis;
        displayItems = items;
    }
    
    String [] displayItems;
    QXPushButton btnOk, btnCancel;
    QXTreeView treeWidget;

    public void onOk(){
        long item = treeWidget.getSelItem();
        int id = -1;
        if (item != 0){
            id = treeWidget.getItemTag(item,0);
        }
        if (listener.onSelectOk(id)){
            done(1);
        }
    }
    public void onAttach()override{ 
    
        setWindowFlags(CustomizeWindowHint | WindowMinMaxButtonsHint | WindowCloseButtonHint);
        
        btnOk = (QXPushButton)attachByName(new QXPushButton(), "btnOk");
        btnCancel = (QXPushButton)attachByName(new QXPushButton(), "btnCancel");
        treeWidget = (QXTreeView)attachByName(new QXTreeView(), "treeWidget");
                
        
        
        treeWidget.setOnTreeViewItemEvent(new onTreeViewItemEvent(){
            void onItemDoubleClicked(QXTreeView,long item, int column) {
                onOk();
            }
        });
        btnOk.setOnClickListener(
        new onClickListener(){
            void onClick(QXObject obj, bool checked)override{
                onOk();
            }
        });
        
        btnCancel.setOnClickListener(
        new onClickListener(){
            void onClick(QXObject obj, bool checked)override{
                if (listener.onInputCancel()){
					done(0);
                }
            }
        });
        
        String defid = listener.getDefault();
        int defnid = 0;
        if (defid != nilptr){
            defnid = defid.parseInt();
        }
        
        for (int i = 0; i < displayItems.length; i++){
            long  hi = treeWidget.addItem(nilptr,displayItems[i]);
            treeWidget.setItemTag(hi,0,i);
            if (defnid == i){
                treeWidget.setItemSelected(hi,true);
            }
        }
        
		setWindowTitle(listener.getTitle());
        setModal(true);
        
    }
    
    public static int requestSelect(InputDialog.onInputListener lis, String [] items){
		QXDialog newDlg = new QXDialog();
        if (newDlg.load("ui/mulsel.ui") == false){
            return 0;
        }
        MultiSelectDialog wizard = new MultiSelectDialog(lis, items);	
        
        wizard.attach(newDlg);
        
        return wizard.exec();
    }
};