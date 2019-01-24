# XStudio
xlang 语言的集成开发环境, 此项目使用 xlang 开发
该项目是为xlang的官方开发环境，支持各种平台(windows, linux, mac)
底层使用QT， C++部分源码在xlibrary仓库

该项目支持任何形式的修改与分发.




编译环境下载: http://xlang.vsylab.com 无需安装，解压即用.

## windows 下运行图

![](https://github.com/ixlang/XStudio/blob/master/case382.png)


## Linux(ubuntu) 下运行图

![](https://github.com/ixlang/XStudio/blob/master/case263.png)


## Mac OSX 下运行图

![](https://github.com/ixlang/XStudio/blob/master/case148.png)


# 编译步骤
到 http://xlang.vsylab.com 下载你的操作系统对应的xlang开发包, 解压后运行 XStudio 打开此项目中的 XStudio.xprj;

 F7 即可；

# 运行环境

该项目中未包含运行环境，可以在菜单[项目]->[属性]->[项目属性]中将[输出位置]改为 xlang开发包解压后的路径 (与解压后的XStudio文件同一位置)；

F5 即可运行;

# 语言插件与二次开发

## 语言支持 


添加一个继承自 ProjectPropInterface 的类， 并实现其接口

```java
interface ProjectPropInterface{
    //用于处理项目属性页的各项值
    bool setValue(Project object, Configure configure, String key, String value);
    String getValue(Project object, Configure configure,  String key);
    
    // 构建时的动作
    void build(IBuilder builder, Project object, Configure configure, Object param);
    
    // 清理时的动作
    void cleanup(IBuilder builder, Project object, Configure configure);
    
    // 调试运行的动作
    void debugRun(IBuilder builder, Project proj, Configure conf);
    
    // 运行的动作
    void Run(IBuilder builder, Project proj, Configure conf); 
    
    // 结束运行的动作
	void stopRun();
 
   //使用向导新建项目的动作
	bool create(WizardLoader loader, String projectName, String projectDir, String uuid, Project object, bool isAddToProject, String userType);
};
```

在ProjectPropManager.xcsm中添加一个语言处理接口



```java
    static bool registryAllProp(){
        _props.put("xlang", new XlangProjectProp());
        // 在这里添加一个新的对象参照上面代码
        return true;
    }
```

## 代码高亮

未整理接口， 请自行修改或者添加 XSourceEditor.xcsm 中的 syntaxForXlangDark(深色主题) 或者 syntaxForXlang(浅色主题)方法。

## 智能提示

参考 XIntelliSense.xcs 

## 其他内容再待补充

# 开发者交流

xlang & XStudio语言开发交流QQ群

[![xlang & XStudio语言开发交流群](https://pub.idqqimg.com/wpa/images/group.png)](https://shang.qq.com/wpa/qunwpa?idkey=d942b64d32f7fd1e537b8f49284b33dbb6e9268bb57586be89895737cbae0bb7)
