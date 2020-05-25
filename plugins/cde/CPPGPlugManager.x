//xlang Source, Name:CPPGPlugManager.x 
//Date: Tue Feb 20:25:34 2020 

class CPPGPlugManager{

    static CPPProjectPlugin _projectplugin = new CPPProjectPlugin();
    static IXStudioController xcontroller;
    public static WorkspaceController workspace;
    static QXMainWindow _mainWindow;
    
    public static String getSourceContent(String file){
        SourceContent sc = workspace.getSourceContent(file);
        if (sc != nilptr){
            return sc.getContent();
        }
        return nilptr;
    }
    
	public static class CPPLangPlugin : IXPlugin{
        static IXPlugin _this;
		CPPTextEditor textPlugin = new CPPTextEditor();
        
        public static IXPlugin getInstance(){
            if (_this == nilptr){
                _this = new CPPGPlugManager.CPPLangPlugin();
            }
            return _this;
        }
        
		String getName(){
			return "cde";
		}
		
        public static String readFileContent(String file){
            FileInputStream fis = nilptr;
            
            try{
                fis = new FileInputStream(file);
                byte []data = fis.read();
                fis.close();
                return new String(data);
            }catch(Exception e){
            
            }finally{
                if (fis != nilptr){
                    fis.close();
                }  
            }
            
            return nilptr;
        }
    
		void onTextEditorCreated(TextEditorController editor){
		
		}
		IProjectPlugin getProjectPlugin(){
            return _projectplugin;
        }
		void onTextEditorClosed(TextEditorController editor){
		
		}
		
		bool initializPlusin(IXStudioController controller, bool enabled){
            xcontroller = controller;
            workspace = xcontroller.getWorkspace();
            _mainWindow = workspace.getMainWindow();
            if (enabled == false){
                return true;
            }
			xcontroller = controller;
            _projectplugin.createWizard();
            workspace.addMenu(4, "c_cpp_setting", "C/C++设置", "res/toolbar/class.png",nilptr, this);
            
            
            
            /*QXDockWidget qdock = new QXDockWidget();
            qdock.create(_mainWindow);
            qdock.setFeatures(QXDockWidget.DockWidgetClosable|QXDockWidget.DockWidgetFloatable);
            qdock.setWindowTitle("fuck me ");
            
            QHBoxLayout qhl = new QHBoxLayout();
            qhl.create(qdock);
            
            QXWidget w = new QXWidget();
            w.create();
            
            QXPushButton buf = new QXPushButton();
            buf.create(w);
            qhl.addWidget(buf);
            
            buf = new QXPushButton();
            buf.create(w);
            qhl.addWidget(buf);
            
            w.setLayout(qhl);
            qdock.setWidget(w);
            qdock.setAllowedAreas(QXDockWidget.DockWidgetArea.LeftDockWidgetArea |QXDockWidget.DockWidgetArea.RightDockWidgetArea);
            _mainWindow.addDockWidget(QXDockWidget.DockWidgetArea.BottomDockWidgetArea, qdock, QXWidget.Orientation.Horizontal);*/
            
            return true; 
		}
        
        TextEditorPlugin getTextEditorPlugin(){
			return textPlugin;
        }
        
        IProject loadProject(JsonObject content, String lang){
			return nilptr;
        }
        
        void onMenuTrigged(String name){
            if (name.equals("c_cpp_setting")) {
                CPPSetting.showCPPSetting();
            }
        }
        String getIcon(){
            return "res/package64.png";
        }
        bool onExit(){
            return true;
        }
        
        long getVersion(){
            return 1000;
        } 
        String getDescrition(){
            return "c/c++ 项目开发扩展.";
        }
        String publisher(){
            return "https://github.com/ixlang/xlibraries";
        }
        void uninstall(IXStudioController){
            
        }
	};
    
    public static void output(String text){
		if (xcontroller != nilptr){
			xcontroller.getWorkspace().output(text, 0);
        }
    }
    
    public static void output(String text, int wid){
		if (xcontroller != nilptr){
			xcontroller.getWorkspace().output(text, wid);
        }
    }
};