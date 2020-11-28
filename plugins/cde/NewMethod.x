//xlang Source, Name:NewMethod.x 
//Date: Sat Nov 10:07:47 2020 

class NewMethod : QDialog{
    QLineEdit edtype, edid, edargs, eddescr;
    QCheckBox cbpublic, cbprotected, cbprivate, cbstatic, cbvirtual, cbconst;
    QPushButton pushButton, pushButton_2;
    String source_file;
    ClassViewInfo class_info;
    
    int access_flag = -1;

    void onAttach()override{
        setWindowIcon("res/toolbar/methodadd.png");
        edtype = (QLineEdit)attachByName(new QLineEdit(),"edtype");
        edid = (QLineEdit)attachByName(new QLineEdit(),"edid");
        edargs = (QLineEdit)attachByName(new QLineEdit(),"edargs");
        eddescr = (QLineEdit)attachByName(new QLineEdit(),"eddescr");
        
        cbpublic = (QCheckBox)attachByName(new QCheckBox(),"cbpublic");
        cbprotected = (QCheckBox)attachByName(new QCheckBox(),"cbprotected");
        cbprivate = (QCheckBox)attachByName(new QCheckBox(),"cbprivate");
        
        cbstatic = (QCheckBox)attachByName(new QCheckBox(),"cbstatic");
        cbvirtual = (QCheckBox)attachByName(new QCheckBox(),"cbvirtual");
        cbconst = (QCheckBox)attachByName(new QCheckBox(),"cbconst");
        
        pushButton = (QPushButton)attachByName(new QPushButton(),"pushButton");
        pushButton_2 = (QPushButton)attachByName(new QPushButton(),"pushButton_2");

        onClickListener pplis = new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                if (checked){
                    QCheckBox [] ppchk = {cbpublic, cbprotected, cbprivate};
                    for (int i= 0 ;i < ppchk.length; i++){
                        if (ppchk[i] != obj){
                            ppchk[i] .setCheck(false);
                        }else{
                            access_flag = i;
                        }
                    }
                }
            }
        };
        
        cbpublic.setOnClickListener(pplis);
        cbprotected.setOnClickListener(pplis);
        cbprivate.setOnClickListener(pplis);
        
        onClickListener sclis = new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                if (checked){
                    QCheckBox [] ppchk = {cbstatic, cbvirtual, cbconst};
                    int i= 0 ;
                    for (;i < ppchk.length; i++){
                        if (ppchk[i] == obj){
                            break;
                        }
                    }
                    if (i == 0){
                        ppchk[1].setCheck(false);
                        ppchk[2].setCheck(false);
                    }else
                    if (i == 1){
                        ppchk[0].setCheck(false);
                    }else
                    if (i == 2){
                        ppchk[0].setCheck(false);
                    }
                }
            }
        };
        
        cbstatic.setOnClickListener(sclis);
        cbvirtual.setOnClickListener(sclis);
        cbconst.setOnClickListener(sclis);
        
        pushButton.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                if (false == generate()){
                    QMessageBox.Critical("错误","该文档不是由XStudio生成并管理,无法完成操作.",QMessageBox.Ok,QMessageBox.Ok);
                }
                close();
            }
        });
        
        pushButton_2.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                close();
            }
        });
    }

    public static void showNewMethod(String file, ClassViewInfo curclsinfo){
        QDialog newDlg = new QDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("newmethod.ui");
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        if (newDlg.load(qb)){
            NewMethod cppsetting = new NewMethod();
            cppsetting.attach(newDlg);
            cppsetting.source_file = file;
            cppsetting.class_info = curclsinfo;
            cppsetting.setModal(true);
            cppsetting.show();
        }
    }
    
    bool generate(){
        if (Pattern.test(edid.getText(), "^[A-Za-z0-9_]+$", Pattern.NOTEMPTY, true) == false) {
            QMessageBox.Critical("错误", "标识符不合法", QMessageBox.Ok, QMessageBox.Ok);
            return false;
        }
        
        String headFile = source_file.replaceExtension(".h");
        String cppFile = source_file.replaceExtension(".cpp");
        String descr = eddescr.getText();
        if (descr.length() != 0){
            descr = "\t//" + descr + "\n";
        }
        
        SourceContent sc_head = CPPGPlugManager.workspace.getSourceContent(headFile);
        if (sc_head != nilptr){
            String headcontent = sc_head.getContent();
            int prop_pos = headcontent.indexOf("//XAMH Method End");
            if (prop_pos != -1){
            
                String declare = "";
                switch (access_flag ){
                    case 0:
                        declare = declare + "public:\n";
                    break;
                    case 1:
                        declare = declare + "protected:\n";
                    break;
                    case 2:
                        declare = declare + "private:\n";
                    break;
                }
                declare = declare + descr;
                declare = declare + "\t";
                
                bool bstatic = cbstatic.getCheck();
                if (bstatic){
                    declare = declare + "static ";
                }
                
                if (cbvirtual.getCheck()){
                    declare = declare + "virtual ";
                }
                
                declare = declare + edtype.getText() + " ";
                declare = declare + edid.getText() + "(" + edargs.getText() + ")";
                
                if (cbconst.getCheck()){
                    declare = declare + "const";
                }
                
                declare = declare + ";\n";
                
                headcontent = headcontent.substring(0, prop_pos) + declare + headcontent.substring(prop_pos, headcontent.length());
                sc_head.updateContent(headcontent);
            
      
                SourceContent sc_cpp = CPPGPlugManager.workspace.getSourceContent(cppFile);
                if (sc_cpp != nilptr){
                    String cppcontent = sc_cpp.getContent();
                    String finds = "//XAMH Implenment End";
                    int cpp_static_init = cppcontent.indexOf(finds);
                    if (cpp_static_init != -1){
                        JsonObject jobj = class_info.getObject();
                        if (jobj != nilptr){
                            String classname = jobj.getString("name");
                            descr = eddescr.getText();
                            if (descr.length() != 0){
                                descr = "//" + descr + "\n";
                            }
                            String impl = "\n" + descr;
                            impl = impl + edtype.getText() + " ";
                            impl = impl + classname  + "::" ;
                            impl = impl +  edid.getText() + "(" + edargs.getText() + ")";
                            if (cbconst.getCheck()){
                                impl = impl + "const";
                            }
                            impl = impl + "{\n// TODO: \n\n}\n";
                            cppcontent = cppcontent.substring(0, cpp_static_init) + impl + cppcontent.substring(cpp_static_init, cppcontent.length());
                            sc_cpp.updateContent(cppcontent);
                            
                        }
                    }
                }
                return true;
            }
        }
        return false;
    }
};