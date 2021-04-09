# XStudio
XStudio 是 xlang 语言的御用集成开发环境, 此项目使用 xlang 开发, 支持各种平台(windows, linux, mac), 并且具有高度扩展和可定制性, 另外已经支持用作 C/C++ 项目的开发, 未来将会支持更多其他语言和类型的开发.

该项目支持任何形式的修改与分发.

## 功能模块

    代码编辑
    代码高亮
    智能提示
    转到定义等
    查找、替换，全局查找、替换

    调试功能
    支持常规断点
    支持远程调试

    项目结构、大纲显示


    窗口视图
    类视图、项目大纲、运行时GC监控、运行时对象浏览器、查找结果、logcat视图、线程\堆栈、Output（输出）、自动（Auto）、Watch、信息、断点

![image](https://raw.githubusercontent.com/ixlang/XStudio/master/IDE.jpg)
编译环境下载: http://xlang.link/ 无需安装，解压即用.
![](https://xlang.link/ide.png)
![](https://xlang.link/ide1.png)
# 编译步骤
到 http://xlang.link/download.html 下载你的操作系统对应的xlang开发包, 解压后运行 XStudio 打开此项目中的 XStudio.xprj;

 F7 即可；

# 运行环境

该项目中未包含运行环境，可以在菜单[项目]->[属性]->[项目属性]中将[输出位置]改为 xlang开发包解压后的路径 (与解压后的XStudio文件同一位置)；

F5 即可运行;

# 语言插件与二次开发

## 扩展支持 

请参见 XStudio 新建项目向导中的 'XStudio 扩展'模板, 另可参考 cde 扩展组件源码

## 支持自定义扩展的功能与组件:
 菜单项
 新建项目向导中的类型与模板
 项目属性中的项
 代码高亮
 代码编辑器中的自动补全和提示功能
 工作区面板与自定义UI
 编译构建流程
 生成makefile
 通过调试协议自定义调试器(参考文档https://xlang.link/pdf/XStudio%E8%B0%83%E8%AF%95%E5%99%A8%E5%8D%8F%E8%AE%AE%E6%96%87%E6%A1%A3.pdf)
 其他非标准扩展接口的自定义项

## 已支持的其他语言类型的开发

### CDE (C/C++ Develop Extends)：多平台的 C/C++ 项目开发支持(扩展组件下载地址:http://release.xlang.link/extensions/xstudio/cde.xsp)
### CDE 扩展已支持的细节:
 从新建项目向导中建立C/C++项目
 代码高亮
 通过第三方lsp支持的代码编辑时的自动补全和提示(linux x86 和 macosx 未支持)
 使用 GCC/G++/MINGW 构建项目
 使用 GDB 进行可视化的源码级调试
 可视化的项目属性设置
 生成项目的Makefile 以及通过makefile构建和管理项目

### 安装方法: 下载cde.xsp , 并通过 XStudio [帮助] 菜单中的 [安装XStudio扩展] 进行安装
### 使用细节参考请关注xlang 博文 (https://blog.xlang.link/article.html?id=11)
### 参考图示
![](http://blog.xlang.link/images/iexsa1.gif)
...

# 开发者交流

xlang & XStudio语言开发交流QQ群

[![xlang & XStudio语言开发交流群](https://pub.idqqimg.com/wpa/images/group.png)](https://shang.qq.com/wpa/qunwpa?idkey=d942b64d32f7fd1e537b8f49284b33dbb6e9268bb57586be89895737cbae0bb7)
