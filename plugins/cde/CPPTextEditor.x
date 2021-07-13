//xlang Source, Name:CPPTextEditor.x 
//Date: Tue Feb 20:28:01 2020 

class CPPTextEditor: TextEditorPlugin{

    CDESyntaxHighlighting chl = new CDESyntaxHighlighting();
    CDEDarkSyntaxHighlighting dchl = new CDEDarkSyntaxHighlighting();
	String getIconFile() override {
		//TODO:	
		return nilptr;
	}
    
    
    static String parseMacros(@NotNilptr String [] macro){
        String str_text = "";
        for (int i =0; i < macro.length; i++){
            if (macro[i] != nilptr && macro[i].startsWith("-D")){
                if (str_text.length() > 0){
                    str_text = str_text + " ";
                }
                str_text = str_text + macro[i].substring(2, macro[i].length());
            }
        }
        return str_text;
    }

	String getKeyWords() override {
		//TODO:	
		return 
			"alignas alignof and and_eq asm atomic_cancel atomic_commit atomic_noexcept " + 
            " auto bitand bitor bool break case catch char char8_t char16_t char32_t class " + 
            " compl concept const consteval constexpr constinit const_cast continue co_await" + 
            " co_return co_yield decltype default delete do __try double dynamic_cast else enum" + 
            " explicit export extern false float for friend goto __except if inline int long mutable" + 
            " namespace new noexcept not not_eq nullptr operator or __finally or_eq private protected" + 
            " public reflexpr register reinterpret_cast requires return short signed sizeof" + 
            " static static_assert static_cast struct switch synchronized template this thread_local" + 
            " throw true try typedef typeid typename union unsigned using virtual void volatile wchar_t while xor xor_eq" + 
            " override final import module transaction_safe transaction_safe_dynamic defined __has_include  __has_cpp_attribute";
	}

	bool requestClose(TextEditorController editor) override {
		//TODO:	
		return true;
	}

	SyntaxHighlighting getColorConfigure(@NotNilptr String styleName) override {
		//TODO:	
        if (styleName.equals("dark")){
            return dchl;
        }
		return chl;
	}
    
    void configEditor(Project project, @NotNilptr String path,@NotNilptr  QScintilla _sci, bool bdark){
    
        if (project == nilptr){
            return;
        }
        Configure curcfg = project.getCurrentConfig();
        if (curcfg == nilptr){
            return;
        }
        String ext = path.findExtension();
        
        if ((ext.equalsIgnoreCase(".c") || ext.equalsIgnoreCase(".cpp") || ext.equalsIgnoreCase(".cxx") || ext.equalsIgnoreCase(".m") || 
                ext.equalsIgnoreCase(".mm") || ext.equalsIgnoreCase(".cc") || ext.equalsIgnoreCase(".c++") || ext.equalsIgnoreCase(".cp") || ext.equalsIgnoreCase(".txx") || 
                ext.equalsIgnoreCase(".tpp") || ext.equalsIgnoreCase(".tpl"))) 
        {
        
            _sci.sendEditor(QScintilla.SCI_SETLEXERLANGUAGE, "cpp");
            _sci.setProperty("lexer.cpp.track.preprocessor", "1");
            _sci.setProperty("lexer.cpp.update.preprocessor", "1");
            _sci.setProperty("styling.within.preprocessor", "1");
            _sci.setProperty("fold.preprocessor", "1");
            _sci.setProperty("fold.at.else", "1");
            bool bcpp = true;
            if (ext.equalsIgnoreCase(".c")){
                bcpp = false;
            }
            
            
            String [] args = CDEProjectPropInterface.generatorCompArgs_s(project, curcfg, path, true);
            
            String macro_string = parseMacros(args);
            
            if (macro_string != nilptr){
                String macrokey = macro_string + " " + CDEProjectPropInterface.getMacros(curcfg);
                if (bcpp){
                    macrokey = macrokey + " __cplusplus=201402L ";
                }
                _sci.setKeywords(4, macrokey); 
                
                int color = bdark ? 0xff666666 : 0xffaaaaaa;
                
                for (int i = 0; i < 20; i++){
                   _sci.sendEditor(QScintilla.SCI_STYLESETFORE, i + 0x40,color);
                }
            }
            
        }
    }
};