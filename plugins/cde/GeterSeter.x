//xlang Source, Name:GeterSeter.x 
//Date: Sat Nov 11:23:11 2020 

class GeterSeter : QDialog{
    QCheckBox cbseter, cbsref, cbsconst, cbgeter, cbgref, cbgconst, cbgrconst, cbpublic, cbprotected, cbprivate, cbstatic;
    int access_flag = -1;
    String source_file;
    String stype, sname;
    bool bstatic, bvolatile;
    QPushButton pushButton, pushButton_2;
    
    void onAttach()override{
        setWindowIcon("res/toolbar/override.png"); 
        cbseter = (QCheckBox)attachByName(new QCheckBox(),"cbseter");
        cbsref = (QCheckBox)attachByName(new QCheckBox(),"cbsref");
        cbsconst = (QCheckBox)attachByName(new QCheckBox(),"cbsconst");
        cbgeter = (QCheckBox)attachByName(new QCheckBox(),"cbgeter");
        cbgref = (QCheckBox)attachByName(new QCheckBox(),"cbgref");
        cbgconst = (QCheckBox)attachByName(new QCheckBox(),"cbgconst");
        cbgrconst = (QCheckBox)attachByName(new QCheckBox(),"cbgrconst");
        
        cbpublic = (QCheckBox)attachByName(new QCheckBox(),"cbpublic");
        cbprotected = (QCheckBox)attachByName(new QCheckBox(),"cbprotected");
        cbprivate = (QCheckBox)attachByName(new QCheckBox(),"cbprivate");
        cbstatic = (QCheckBox)attachByName(new QCheckBox(),"cbstatic");
        
        pushButton = (QPushButton)attachByName(new QPushButton(),"pushButton");
        pushButton_2 = (QPushButton)attachByName(new QPushButton(),"pushButton_2");
        
        cbstatic.setCheck(bstatic);
        if (bstatic == false){
            cbstatic.setEnabled(false);
        }
        
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
        
        cbseter.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                cbsref.setEnabled(checked);
                cbsconst.setEnabled(checked);
                
                pushButton.setEnabled(!(checked == false && cbgeter.getCheck() == false));
                
            }
        });
        
        cbgeter.setOnClickListener(new onClickListener(){
            void onClick(QObject obj,bool checked)override{
                cbgref.setEnabled(checked);
                cbgconst.setEnabled(checked);
                cbgrconst.setEnabled(checked);
                pushButton.setEnabled(!(checked == false && cbseter.getCheck() == false));
            }
        });
        
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
    
    public static void showGeterSeter(String file, String type, String idname, bool bstatic, bool bvolatile){
        QDialog newDlg = new QDialog();
        newDlg.create();
        byte [] buffer = __xPackageResource("geterster.ui");
        QBuffer qb = new QBuffer();
        qb.setBuffer(buffer, 0, buffer.length);
        if (newDlg.load(qb)){
            GeterSeter cppsetting = new GeterSeter();
            cppsetting.source_file = file;
            cppsetting.stype = type;
            cppsetting.sname = idname;
            cppsetting.bstatic = bstatic;
            cppsetting.bvolatile = bvolatile;
            
            cppsetting.attach(newDlg);
            
            cppsetting.setModal(true);
            cppsetting.show();
        }
    }
    

    bool generate(){
        
        String headFile = source_file.replaceExtension(".h");
        String cppFile = source_file.replaceExtension(".cpp");

        
        SourceContent sc_head = CPPGPlugManager.workspace.getSourceContent(headFile);
        if (sc_head != nilptr){
            String headcontent = sc_head.getContent();
            int prop_pos = headcontent.indexOf("//XAMH Method End");
            if (prop_pos != -1){
                String accessable = "";
                String declare = "";
                
                switch (access_flag ){
                    case 0:
                        accessable =  "public:\n";
                    break;
                    case 1:
                        accessable =  "protected:\n";
                    break;
                    case 2:
                        accessable =  "private:\n";
                    break;
                }

                declare = declare + "\t";
                
                bool bstatic = cbstatic.getCheck();
                if (bstatic){
                    declare = declare + "static ";
                }
                
                String partName = sname.substring(0, 1).upper() + sname.substring(1, sname.length());
                

                String strget = declare;
                
                if (cbgrconst.getCheck()){
                    strget = strget + "const ";
                    if (bvolatile && cbgref.getCheck()){
                        strget = strget + "volatile ";
                    }
                }
                strget = strget + stype + " ";
                
                if (cbgref.getCheck()){
                    strget = strget + "& ";
                }                    
                
                strget = strget + "get" + partName + "()";
                if (cbgconst.getCheck()){
                    strget = strget + " const ";
                }                    
                strget = strget + "{ return " + sname + "; }\n";
                
                String strargs = "";
                if (cbsconst.getCheck()){
                    strargs = strargs + "const ";
                }
                strargs = strargs + stype + " ";
                if (cbsref.getCheck()){
                    strargs = strargs + "& ";
                }
                
                strargs = strargs + "_" + sname;
                String strset = declare + "void" + " " + "set" + partName + "(" + strargs + "){ " + sname + " =" + "_" +  sname + "; }\n";

                if (cbseter.getCheck() == false){
                    strset = "";
                }
                if (cbgeter.getCheck() == false){
                    strget = "";
                }
                
                headcontent = headcontent.substring(0, prop_pos) + "\n" + accessable + strget + strset + headcontent.substring(prop_pos, headcontent.length());
                sc_head.updateContent(headcontent);
            
                return true;
            }
        }
        return false;
    }
};