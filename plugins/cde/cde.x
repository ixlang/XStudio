
using {
    Qt;
};

void _entry(int moduleId, int xvmVer){
    ProjectPropManager.registryProp("C/C++", CDEProjectPropInterface.getInstance());
    PluginManager.registryPlugins(CPPGPlugManager.CPPLangPlugin.getInstance());
    return ;
}
