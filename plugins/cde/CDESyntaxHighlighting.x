//xlang Source, Name:CDESyntaxHighlighting.x 
//Date: Sun May 12:52:41 2020 

class CDESyntaxHighlighting : SyntaxHighlighting{

	/** 编辑器默认背景色*/
	int getDefaultBackColor()override{
		return 0xffffffff;
    }
    
    /** 编辑器默认字体颜色*/
    int getDefaultForeColor()override{
		return 0xff424847;
    }
    
    /** 选中字体背景颜色*/
    int getSelectedBackColor()override{
		return 0xffc8c8c8;
    }
    
    /** 选中字体颜色*/
    int getSelectedForeColor()override{
		return 0;
    }
    
    /** 能否设置断点*/
    bool canSetBreakPoint()override{
		return true;
    }
    
    /** 断点背景色*/
    int getBreakPointBackColor()override{
		return 0xff0000ff;
    }
    
    /** 断点前景色*/
    int getBreakPointForeColor()override{
		return 0xffffffff;
    }
    
    /** 能否设置标记*/
    bool canSetMarkPoint()override{
		return true;
    }
    
    /** 标记背景色*/
    int getMarkPointBackColor()override{
		return 0xffcee7ce;
    }
    
    /** 标记前景色*/
    int getMarkPointForeColor()override{
		return 0xff7f7f00;
    }
    
    /** 修改标记背景色*/
    int getModifiedMarkBackColor()override{
		return 0xff00d8ff;
    }
    
    /** 修改标记前景色*/
    int getModifiedMarkForeColor()override{
		return 0xff00d8ff;
    }
    
    /** 保存标记背景色*/
    int getSavedMarkBackColor()override{
		return 0xff00d8ff;
    }
    
    /** 保存标记前景色*/
    int getSavedMarkForeColor()override{
		return 0xff00d8ff;
    }
    
    /** 缩进线颜色*/
    int getIndentGuideColor()override{
		return 0xff464849;
    }
    
    /** 行号背景色*/
    int getLineNumberBackColor()override{
		return 0xffefefef;
    }
    
    /** 行号前景色*/
    int getLineNumberForeColor()override{
		return 0xff999999;
    }
    
    /** 括号匹配背景色*/
    int getMatchedBraceBackColor()override{
		return 0xff00ffff;
    }
    
    /** 括号匹配前景色*/
    int getMatchedBraceForeColor()override{
		return 0xffff00ff;
    }
    
    /** 注释文档前景色*/
    int getDocCommentKeyForeColor()override{
		return 0xffA06030;
    }
    
    /** 注释文档错误字前景色*/
    int getDocCommentErrForeForeColor()override{
		return 0xff204080;
    }
    
    /** 全局类前景色*/
    int getGlobalClassForeColor()override{
		return 0xff0099dd;
    }
    
    /** 操作符字体色*/
    int getOperatorForeColor()override{
		return 0xff970201;
    }
    
    /** 字符串错误色*/
    int getStringEOLColor()override{
		return 0xffE0C0E0;
    }
    
    /** 关键字颜色*/
    int getWordForeColor()override{
		return 0xffaf912b;
    }
    
    /** 关键字背景颜色*/
    int getWordBackColor()override{
		return 0;
    }
    
    /** 动态关键字背景色*/
    int getWord2BackColor()override{
		return 0xff6f3d11;
    }
    
    /** 动态关键字色*/
    int getWord2ForeColor()override{
		return 0xff2ae27f;
    }
    
    /** 字符串颜色*/
    int getStringForeColor()override{
		return 0xff1515a3;
    }
    
    /** 数字颜色*/
    int getNumberForeColor()override{
		return 0xffff1b8a;
    }
    
    /** 字符颜色*/
    int getCharForeColor()override{
		return 0xffff1b8a;
    }
    
    /** 预处理器颜色*/
    int getPreprocessorForeColor()override{
		return 0x00808080;
    }
    
    /** 注释颜色*/
    int getCommentForeColor()override{
		return 0xff117f26;
    }
    
    /** 行注释眼色*/
    int getCommentLineForeColor()override{
		return 0xff117f26;
    }
    
    /** 文档注释颜色*/
    int getDocCommentForeColor()override{
		return 0x00008000;
    }
    
    /** 提示信息字体色*/
    int getCallTipsForeColor()override{
		return 0xffefefef;
    }
    
    /** 提示信息背景色*/
    int getCallTipsBackColor()override{
		return 0xff454242;
    }
    
    /** 光标颜色*/
    int getCaretColor()override{
		return 0xff000000;
    }
    
    /** 光标所在行背景色*/
    int getCaretLineBackColor()override{
		return 0xffefefef;
    }
    
    /** 折叠边栏颜色*/
    int getFoldMarginColor()override{
		return 0xffefefef;
    }
    
    /** 折叠边高亮色*/
    int getFoldMarginHIColor()override{
		return 0xffffffff;
    }
    
    /** 折叠标记背景颜色*/
    int getFolderBackColor()override{
		return 0xff9c9c9c;
    }
    
    /** 折叠标记颜色*/
    int getFolderForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(未折叠状态)颜色*/
    int getFolderOpenBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderOpenForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(end状态)颜色*/
    int getFolderEndBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderEndForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(中段状态)颜色*/
    int getFolderMidBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderMidForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(中段末尾状态)颜色*/
    int getFolderMidTailBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderMidTailForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(子段)颜色*/
    int getFolderSubBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderSubForeColor()override{
		return 0xffefefef;
    }
    
    /** 折叠标记(尾部)颜色*/
    int getFolderTailBackColor()override{
		return 0xff9c9c9c;
    }
    int getFolderTailForeColor()override{
		return 0xffefefef;
    }
    
    /** 待输入标记前景色*/
    int getIndicForeColor()override{
		return 0xff00ffff;
    }
    
    /** 待输入标记背景色*/
    int getIndicBackColor()override{
		return 0x7f00ffff;
    }
};