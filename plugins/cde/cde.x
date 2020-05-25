void _entry(int moduleId, int xvmVer){
    ProjectPropManager.registryProp("C/C++", new CDEProjectPropInterface());
    PluginManager.registryPlugins(CPPGPlugManager.CPPLangPlugin.getInstance());
    return ;
}
