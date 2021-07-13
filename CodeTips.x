//xlang Source, Name:CodeTips.x 
//Date: Tue Apr 11:35:04 2021 

class CodeTips : QWidget{
    QLabel lbltitle, lblcontent, lbllink, pushpin, lblcopy;

    
    String pushpin_qss_unpush = "background-image: url(res/toolbar/unpush.png);";
    String pushpin_qss_push = "background-image: url(res/toolbar/push.png);";
    String defaultPath ;
    bool pushed = false;
    public void onAttach()override{ 
        lbltitle = (QLabel)attachByName(new QLabel(), "lbltitle");
        lblcontent = (QLabel)attachByName(new QLabel(), "lblcontent");
        lbllink = (QLabel)attachByName(new QLabel(), "lbllink");
        lblcopy = (QLabel)attachByName(new QLabel(), "lblcopy");
        pushpin = (QLabel)attachByName(new QLabel(), "pushpin");
        
        
        lbltitle.setOnMouseEventListener(new onMouseEventListener(){
            bool bpressed = false;
            int _ox, _oy, _wx , _wy;
            public void onMouseButtonPress(QObject obj, int Button, int x, int y, int flags, int source) {
                if (bpressed == false){
                    bpressed = true;
                    QPoint qpt = lbltitle.mapToGlobal(x,y);
                    _ox = qpt.x;_oy = qpt.y;
                    _wx = CodeTips.this.x(); _wy = CodeTips.this.y();
                }
            }
            public void onMouseButtonRelease(QObject obj, int Button, int x, int y, int flags, int source) {
                bpressed = false;
            }
            public void onMouseMove(QObject obj, int Button, int x, int y, int flags, int source) {
                if (bpressed){
                    QPoint qpt = lbltitle.mapToGlobal(x,y);
                    x = qpt.x;y = qpt.y;
                    CodeTips.this.move(_wx + (x - _ox), _wy + (y - _oy));
                }
            }
        });
        pushpin.setOnMouseEventListener(new onMouseEventListener(){
            void onMouseButtonRelease(QObject obj, int Button, int x, int y, int flags, int source) {
                pushed = !pushed;
                pushpin.setStyleSheetString(pushed? pushpin_qss_push : pushpin_qss_unpush);
                setFocus();
            }
        });
        
        lbllink.setOnMouseEventListener(new onMouseEventListener(){
            void onMouseButtonPress(QObject obj,int Button,int x,int y,int flags,int source)override{
                //TODO 
                lbllink.setText("<b><u style=\"color:#fb8416\">跟踪链接</u> </b>");
            }
            void onMouseButtonRelease(QObject obj, int Button, int x, int y, int flags, int source) {
                onLink();
                lbllink.setText("<b><u style=\"color:#1684fb\">跟踪链接</u> </b>");
            }
        });
        
        lblcopy.setOnMouseEventListener(new onMouseEventListener(){
            void onMouseButtonPress(QObject obj,int Button,int x,int y,int flags,int source)override{
                lblcopy.setText("<b><u style=\"color:#fb8416\">复制到剪贴板</u> </b>");
            }
            void onMouseButtonRelease(QObject obj, int Button, int x, int y, int flags, int source) {
                setClipboardText(lbltitle.getText() + "\n" + lblcontent.getText());
                lblcopy.setText("<b><u style=\"color:#1684fb\">复制到剪贴板</u> </b>");
            }
        });
        
        setOnKeyEventListener(new onKeyEventListener(){
            bool onKeyPress(QObject obj,int key,bool repeat,int count,String text,int scanCode,int virtualKey,int modifier)override{
                if (key == Constant.Key_Escape){
                    hide();
                }
                return false;
            }
        });
    }
    
    public void onLink(){
        String szContent = lblcontent.getText();
        String [] strs = szContent.split('\n');
        for (int i = 0; i < strs.length; i++){
            String item = strs[i].trim(true);
            if (analyze_link(item)){
                return;
            }
        }
        QPoint cpt = lbllink.mapToGlobal(0,0);
        lbllink.showToolTips(cpt.x,cpt.y,"无可用链接",-1);
    }
    
    public bool analyze_link(String lineText){
        String file = nilptr;
        int line , row;
        if (lineText.length() < 3){
            return false;
        }
        try{
            int lp = lineText.indexOf(':', 3);
            if (lp != -1 && (lp + 1) < lineText.length()) {
                file = lineText.substring(0, lp).trim(true);
                int le = lineText.indexOf(':', lp + 1);
                if (le != -1 && (le + 1) < lineText.length()){
                    line = lineText.substring(lp + 1, le).parseInt();
                    int rp = lineText.indexOf(':', le + 1);
                    if (rp != -1 && le != -1) {
                        row = lineText.substring(le + 1, rp).parseInt();
                    }else{
                        row = 0;
                    }
                }else{
                    return false;
                }
            }else{
                return false;
            }
            
        }catch(Exception e){
            return false;
        }
        if (false == DocumentView.locateForLineRow(XWorkspace.workspace, file, line > 0 ? (line - 1) : line , row, 1)){
            if (defaultPath != nilptr && defaultPath.length() > 0){
                file = defaultPath.findVolumePath().appendPath(file);
                return DocumentView.locateForLineRow(XWorkspace.workspace, file, line > 0 ? (line - 1) : line , row, 1);
            }
        }else{
            return true;
        }
        return false;
    }
    
    public static CodeTips createTips(QWidget w){
		QDialog newDlg = new QDialog();
        if (newDlg.load(UIManager.getUIData(__xPackageResource("ui/tips.ui")), w) == false){
            return nilptr;
        }
        
        CodeTips wizard = new CodeTips();	
        wizard.attach(newDlg);
        return wizard;
    }
    
    public void hide(bool bForce){
        if (!pushed){
            hide();
        }
    }
	void onFocusOut(bool focus,int reson)override{
        hide(false);
	}

    public void showTips(String _defaultPath,  QPoint pt, String title, String content){
        setWindowFlags(Constant.WindowStaysOnTopHint);
        pushed = false;
        pushpin.setStyleSheetString(pushed? pushpin_qss_push : pushpin_qss_unpush);
        if (title != nilptr){
            lbltitle.setText(title);
        }else{
            lbltitle.setText("提示:");
        }
        defaultPath = _defaultPath;
        lblcontent.setText(content);
        lblcontent.adjustSize();
        //setContentsMargins(2,4,4,2);
        move(pt.x, pt.y);
        adjustSize();
        show();
        raise();
        //setFocus();
    }
};