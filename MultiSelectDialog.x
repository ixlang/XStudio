//xlang Source, Name:MultiSelectDialog.x 
//Date: Sat Apr 04:24:36 2020 

class MultiSelectDialog : QDialog{    
    InputDialog.onInputListener listener;
	public MultiSelectDialog(InputDialog.onInputListener intputlis, String [] items){
		listener = intputlis;
        displayItems = items;
    }
    
    String [] displayItems;
    QPushButton btnOk, btnCancel;
    QTreeWidget treeWidget;

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
    
        setWindowFlags(Constant.CustomizeWindowHint | Constant.WindowMinMaxButtonsHint | Constant.WindowCloseButtonHint);
        
        btnOk = (QPushButton)attachByName(new QPushButton(), "btnOk");
        btnCancel = (QPushButton)attachByName(new QPushButton(), "btnCancel");
        treeWidget = (QTreeWidget)attachByName(new QTreeWidget(), "treeWidget");
                
        
        
        treeWidget.setOnTreeViewItemEvent(new onTreeViewItemEvent(){
            void onItemDoubleClicked(QTreeWidget,long item, int column) {
                onOk();
            }
        });
        btnOk.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
                onOk();
            }
        });
        
        btnCancel.setOnClickListener(
        new onClickListener(){
            void onClick(QObject obj, bool checked)override{
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
		QDialog newDlg = new QDialog();
        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/mulsel.ui"))) == false){
            return 0;
        }
        MultiSelectDialog wizard = new MultiSelectDialog(lis, items);	
        
        wizard.attach(newDlg);
        
        return wizard.exec();
    }
};