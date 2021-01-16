//xlang Source, Name:CPPProjectPlugin.x 
//Date: Thu Feb 15:23:58 2020 

class CPPProjectPlugin : IProjectPlugin{
    JsonObject wizard;
    
    String curslnfile = nilptr;
    ClassViewInfo curclsinfo = nilptr;
    ActionIdent [] __ais = nilptr;
        
    ActionIdent [] getSolutionContextActions()override{
        return nilptr;
    }

    ActionIdent [] getClassViewContextActions()override{
        ActionIdent aip = new ActionIdent("添加成员", "cde_add_member", CPPGPlugManager.CPPLangPlugin.getInstance(), new onEventListener(){
            public void onTrigger(@NotNilptr QObject obj)override
            {
                NewMember.showNewMember(curslnfile, curclsinfo);
            }
        });
        
        ActionIdent aim = new ActionIdent("添加方法", "cde_add_member", CPPGPlugManager.CPPLangPlugin.getInstance(), new onEventListener(){
            public void onTrigger(@NotNilptr QObject obj)override
            {
                NewMethod.showNewMethod(curslnfile, curclsinfo);
            }
        });
        aip.setEnabled(false);
        aim.setEnabled(false);
        ActionIdent [] ais = {aip, aim};
        __ais = ais;
        return ais;
    }

    void updateSolutionActionState(String files)override{

    }
    
    void updateClassViewActionState(String file, ClassViewInfo info)override{
        bool enabled = false;
        
        if (file != nilptr){
            JsonObject classinfo = info.getObject();
            int type = classinfo.getInt("type");
            if (type == 31){
                
                String headFile = file.replaceExtension(".h");
                String cppFile = file.replaceExtension(".cpp");
                
                if (XPlatform.existsSystemFile(headFile) && XPlatform.existsSystemFile(cppFile)){
                    curclsinfo = info;
                    curslnfile = file;
                    enabled = true;
                }
            }
        }
        
        if (__ais != nilptr){
            __ais[0].setEnabled(enabled);
            __ais[1].setEnabled(enabled);
        }
    }
    
	bool onpreRun(IProject project, bool debug) override {
		//TODO:	1
        return true;
	}

	String getWizard(bool projectExist) override {
		//TODO:	
        return wizard.toString(false);
	}

	void onpostRun(IProject project, bool debug) override {
		//TODO:	
        
	}

	bool onpreCompile(IProject project) override {
		//TODO:	
        return true;
	}

    static bool mkdirs(String path) {
        if (path == nilptr || path.length() == 0){
            return false;
        }
        if (XPlatform.existsSystemFile(path) == false) {
            if (XPlatform.mkdir(path) == false) {
                mkdirs(path.findVolumePath());
                return XPlatform.mkdir(path);
            }
        }
        return true;
    }
    
    
    bool write2file(@NotNilptr String file,@NotNilptr String content){
        try{
            FileOutputStream fos = new FileOutputStream(file);
            fos.write(content.getBytes());
            fos.close();
            return true;
        }catch(Exception e){
            
        }
        return false;
    }
    
    bool createAddition(@NotNilptr WizardLoader loader,@NotNilptr  String projectName,@NotNilptr  String projectDir,@NotNilptr  String uuid, IProject ownProject, bool addToProject) {
        String date = String.formatDate("%c", _system_.currentTimeMillis());
        __nilptr_safe(ownProject);
        if (uuid.equals(cpp_clsuuid)){
            String outcppFile = CDEProjectPropInterface.appendPath(projectDir, projectName + ".cpp");
            String outhppFile = CDEProjectPropInterface.appendPath(projectDir, projectName + ".h");
            
            String cpp_content = ("//XAMH class " + projectName + " 实现,由 XStudio [https://xlang.link] 创建 \n//文件名: " + projectName + ".cpp" + " \n" + "//创建时间: " + date + " \n/**@caution 注意:不要删除或改动由XAMH开头的注释，它由XStudio自动生成并进行项目辅助管理**/\n\n") + 
            "#include \""  + projectName + ".h\"\n\n//XAMH Static object initialization End\n" +
            "\n//默认构造\n" + 
            projectName + "::" + projectName + "(){" + "\n\n//XAMH class initialization\n}\n\n" + 
            "\n//析构\n" + 
            projectName + "::~" + projectName + "(){" + "\n\n}\n\n//XAMH Implenment End\n"; 
            
            String header_content = ("//XAMH class " + projectName + " 定义,由 XStudio [https://xlang.link] 创建 \n//文件名: " + projectName + ".h" + " \n" + "//创建时间: " + date + " \n/**@caution 注意:不要删除或改动由XAMH开头的注释，它由XStudio自动生成并进行项目辅助管理**/\n#pragma once\n\n") + 
       
            "class " + projectName + "{ \npublic:\n\t" + projectName + "();\n\t~" + projectName + "();\n\nprivate:\n\n\n\n\n\n//XAMH Properities End\n\npublic:\n\n\n\n\n\n//XAMH Method End\n};\n\n//XAMH Definition End";
            
            write2file(outcppFile, cpp_content);
            write2file(outhppFile, header_content);
            
            ownProject.addSource(outhppFile);
            ownProject.addSource(outcppFile);
            
            loader.openTextFile(outcppFile);
            loader.openTextFile(outhppFile);
            
            return true;
        }else
        if (uuid.equals(cpp_clsuuid)){
            String outhppFile = CDEProjectPropInterface.appendPath(projectDir, projectName + ".h");
          
            String header_content = ("//XAMH interface接口 " + projectName + " 定义,由 XStudio [https://xlang.link] 创建 \n//文件名: " + projectName + ".h" + " \n" + "//创建时间: " + date + " \n/**@caution 注意:不要删除或改动由XAMH开头的注释，它由XStudio自动生成并进行项目辅助管理**/\n#pragma once\n\n") + 
       
            "interface " + projectName + "{\npublic:\n\n//XAMH Method End\n\n};\n\n//XAMH Definition End";
            
            write2file(outhppFile, header_content);
            
            ownProject.addSource(outhppFile);
            
            loader.openTextFile(outhppFile);
            
            return true;
        }
        
        return false;
    }
    
	bool createProject(@NotNilptr WizardLoader loader,@NotNilptr  String projectName,@NotNilptr  String projectDir,@NotNilptr  String uuid, IProject ownProject, bool addToProject) override {
		//TODO:	

        if (Pattern.test(projectName, "^[A-Za-z0-9_]+$", Pattern.NOTEMPTY, true) == false) {
            QMessageBox.Critical("错误", "项目名称不合法", QMessageBox.Ok, QMessageBox.Ok);
            return false;
        }
        
        if (addToProject){
            return createAddition(loader, projectName, projectDir, uuid, ownProject, addToProject);
        }
        String priject_dir = CDEProjectPropInterface.appendPath(projectDir, projectName);
        if (XPlatform.existsSystemFile(priject_dir)) {
            QMessageBox.Critical("错误", "该位置已存在同名项目, 请重新选择路径或者改变项目名", QMessageBox.Ok, QMessageBox.Ok);
            return false;
        } else {
            if (mkdirs(priject_dir) == false) {
                QMessageBox.Critical("错误", "无法在此位置建立新目录, 请重新选择路径", QMessageBox.Ok, QMessageBox.Ok);
                return false;
            }
        }
            
        String configure = CDEProjectPropInterface.appendPath(XPlatform.getAppDirectory(), "plugins/cde");
        
        String tempfile = nilptr;
        String projfile = CDEProjectPropInterface.appendPath(configure, "cdext.temp");
        
        String projectType = "";
        String nostdinc__ = "";
        String nostdinc = "";
        String subsystem = "";
        String otherlink = "";
        
        String [] headers = 
        {
            "/usr/include/gtk-3.0",
            "/usr/include/glib-2.0",
            "/usr/lib64/glib-2.0/include",
            "/usr/include/pango-1.0",
            "/usr/include/cairo",
            "/usr/include/gdk-pixbuf-2.0",
            "/usr/include/atk-1.0"
        };
        
        JsonArray headerArray = new JsonArray();
        
        switch(uuid){
            case cpp_guiuuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "gtkgui.temp");
            projectType = "-execute";
            if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                subsystem = "-mwindows";
                otherlink = "[\\\"-lgtk-3 \\\", \\\"-lgdk-3 \\\", \\\"-lgdi32 \\\", \\\"-lgobject-2.0\\\"]";
            }else{
                if (_system_.getOSBit() == 64){
                    otherlink = "[\\\"-lgobject-2.0\\\", \\\"/usr/lib64/libgtk-3.so\\\"]";
                    for (int i =0; i < headers.length; i++){
                        headerArray.put(headers[i]);
                    }   
                }else{
                    otherlink = "[\\\"-lgobject-2.0\\\", \\\"/usr/lib/libgtk-3.so\\\"]";
                    for (int i = 0; i < headers.length; i++){
                        headerArray.put(headers[i].replace("lib64", "lib"));
                    }
                }
                
                
            }
            
            break;
            case cpp_winuuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "win32.temp");
            projectType = "-execute";
            if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
                subsystem = "-mwindows";
            }
            break;
            case cpp_conuuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "console.temp");
            projectType = "-execute";
            break;
            case cpp_stauuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "stlib.temp");
            projectType = "-staticlib";
            break;
            case cpp_dynuuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "stlib.temp");
            projectType = "-shared";
            break;
            case cpp_drvuuid:
            tempfile = CDEProjectPropInterface.appendPath(configure, "lindrv.temp");
            projectType = "-driver";
            nostdinc__ = "-nostdinc++";
            nostdinc = "-nostdinc";
            break;
        }
        
        if (tempfile != nilptr){
            bool bDriver = projectType.equals("-driver");
            String project_file = CPPGPlugManager.CPPLangPlugin.readFileContent(projfile);
            String source_file = CPPGPlugManager.CPPLangPlugin.readFileContent(tempfile);
            
            if (project_file != nilptr && source_file != nilptr){
                if (bDriver){
                    project_file = project_file.replace("${ProjectName}.cpp", "${ProjectName}.c");
                }
                project_file = project_file.replace("${ProjectName}", projectName)
                    .replace("${ProjectType}", projectType)
                    .replace("${nostdinc__}", nostdinc__)
                    .replace("${nostdinc}", nostdinc)
                    .replace("${LinkOptions}", otherlink)
                    .replace("${SubSystem}", subsystem)
                    .replace("${Headers}", headerArray.toString(true).replace("\"", "\\\""));
                
                String outFile = CDEProjectPropInterface.appendPath(priject_dir, projectName + ".xprj");
                String srcFile = CDEProjectPropInterface.appendPath(priject_dir, projectName + (bDriver ? ".c" : ".cpp"));
                
                try{
                    FileOutputStream fos = new FileOutputStream(outFile);
                    fos.write(project_file.getBytes());
                    fos.close();
                    
                    fos = new FileOutputStream(srcFile);
                    fos.write(source_file.getBytes());
                    fos.close();
                    
                    loader.loadProject(outFile);
                    
                    return true;
                }catch(Exception e){
                    
                }
                
            }
        }
        return false;
	}

	String getTargetPath(@NotNilptr IProject project) override {
        if (project != nilptr){
            String language = project.getLanguage();
            if (language != nilptr && language.equalsIgnoreCase("c/c++")){
                Configure configure = project.getCurrentConfig();
                if (configure != nilptr){
                    String cmd = configure.getOption("command");
                    if (cmd.equals("-driver")){
                        return project.getProjectDir().appendPath(project.getName() + ".ko");
                    }
                    String out_path = CDEProjectPropInterface.appendPath(configure.getOption("outpath"), configure.getOption("outname"));
                    return String.formatPath(XEnvironment.MapVariable((Project)project, configure, out_path), false);
                }
            }
        }
        return nilptr;
	}

	void onpostCompile(IProject project) override {
		//TODO:	
	
	}
    
    public static const String cpp_guiuuid = "3498cf8d-bd36-4730-88ba-20ba12dadedd";
    public static const String cpp_winuuid = "f2138bdd-5474-4609-8383-99d5f82c3d64";
    public static const String cpp_conuuid = "4041e9ad-b6ee-4b04-961e-65c6eee00a04";
    public static const String cpp_stauuid = "661c2c22-5cca-4556-a01c-f2c9ca0495b6";
    public static const String cpp_dynuuid = "8f75b511-8c85-4a7d-8951-9f5e8735cf7b";
    public static const String cpp_drvuuid = "19f532bc-a23d-4e23-ae65-3a420374aa7a";
    
    public static const String cpp_clsuuid = "c3890f0e-ef56-4c41-acfd-e09a30d839eb";
    public static const String cpp_ifcuuid = "5456d902-540e-4ce0-a455-a4b7175cab91";

    public void createWizard(){
        wizard = new JsonObject();
        JsonObject Navigation = new JsonObject();
        JsonObject project = new JsonObject();
        JsonArray Xlang = new JsonArray();
        
        JsonObject mobile;
        
        mobile = new JsonObject();
        mobile.put("name", "GUI (Gtk)程序");
        mobile.put("uuid", cpp_guiuuid);
        mobile.put("language", "C/C++");
        mobile.put("icon", "config/sys.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于windows linux macos等任何特定的支持平台");
        Xlang.put(mobile);
        
        if (_system_.getPlatformId() == _system_.PLATFORM_WINDOWS){
            mobile = new JsonObject();
            mobile.put("name", "GUI (WinSdk)程序");
            mobile.put("uuid", cpp_winuuid);
            mobile.put("language", "C/C++");
            mobile.put("icon", "config/sys.png");
            mobile.put("platform", "支持C/C++开发的目的平台");
            mobile.put("details", "适用于 windows 平台");
            Xlang.put(mobile);
        }
        
        mobile = new JsonObject();
        mobile.put("name", "控制台程序");
        mobile.put("uuid", cpp_conuuid);
        mobile.put("language", "C/C++");
        mobile.put("icon", "config/xlang.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于windows linux macos等任何特定的支持平台");
        Xlang.put(mobile);
        
        mobile = new JsonObject();
        mobile.put("name", "静态库");
        mobile.put("uuid", cpp_stauuid);
        mobile.put("language", "C/C++");
        mobile.put("icon", "config/xlang.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于windows linux macos等任何特定的支持平台");
        Xlang.put(mobile);
        
        mobile = new JsonObject();
        mobile.put("name", "共享库(动态链接库)");
        mobile.put("uuid", cpp_dynuuid);
        mobile.put("language", "C/C++");
        mobile.put("icon", "config/xlang.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于windows linux macos等任何特定的支持平台");
        Xlang.put(mobile);
        
        if (_system_.getPlatformId() == _system_.PLATFORM_LINUX){
            mobile = new JsonObject();
            mobile.put("name", "Linux 驱动程序");
            mobile.put("uuid", cpp_drvuuid);
            mobile.put("language", "C/C++");
            mobile.put("icon", "config/sys.png");
            mobile.put("platform", "支持C/C++开发的目的平台");
            mobile.put("details", "适用于 Linux 平台");
            Xlang.put(mobile);
        }
        
        project.put("C/C++" , Xlang);
        Navigation.put("project" , project);
        
        
        project = new JsonObject();
        Xlang = new JsonArray();
        
        mobile = new JsonObject();
        mobile.put("name", "类");
        mobile.put("uuid", cpp_clsuuid);
        mobile.put("ext", ".cpp");
        mobile.put("language", "C++");
        mobile.put("icon", "config/sys.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于C++项目");
        Xlang.put(mobile);
        
        mobile = new JsonObject();
        mobile.put("name", "接口");
        mobile.put("uuid", cpp_ifcuuid);
        mobile.put("ext", ".h");
        mobile.put("language", "C++");
        mobile.put("icon", "config/sys.png");
        mobile.put("platform", "支持C/C++开发的目的平台");
        mobile.put("details", "适用于C++项目");
        Xlang.put(mobile);
        project.put("C++" , Xlang);
        Navigation.put("file" , project);
        
        wizard.put("Navigation" , Navigation);
    }
};