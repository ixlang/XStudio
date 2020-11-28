//xlang Source, Name:ContextMenu.x 
//Date: Thu Nov 22:31:19 2020 

class ContextMenu{
    QMenu contextMenu = new QMenu();
    public QAction [] actions;

    public void create(@NotNilptr QWidget parent,String [] acts,@NotNilptr  onEventListener listener, ActionIdent[] ais)
    {
        if (contextMenu.create(parent)) {
            int actlen = 0;
            int baselen = 0;
            
            if (acts != nilptr){
                actlen = baselen = acts.length;
            }
            
            if (ais != nilptr){
                actlen += ais.length;
            }
            actions = new QAction[actlen];
            
            if (acts != nilptr){
                for (int i = 0; i < acts.length; i ++) {
                    QAction action = new QAction();
                    if (action.create(contextMenu)) {

                        if (acts[i].equals("-")) {
                            action.setSeparator(true);
                        } else {
                            action.setEnable(false);
                            action.setText(acts[i]);
                            action.setOnEventListener(listener);
                        }
                    }
                    actions[i] = action;
                }
            }
            if (ais != nilptr){
                for (int i = 0; i < ais.length; i++){
                    QAction action = new QAction();
                    if (action.create(contextMenu)) {

                        if (ais[i].name.equals("-")) {
                            action.setSeparator(true);
                        } else {
                            action.setEnable(ais[i].enabled);
                            action.setText(ais[i].name);
                            action.setOnEventListener(ais[i]._el);
                        }
                        ais[i].setAction(action);
                    }
                    actions[i + baselen] = action;
                }
            }
            
            parent.setContextMenuPolicy(Constant.ActionsContextMenu);
            parent.addActions(actions);
        }
    }
    
    public void enableAction(@NotNilptr int []indexs, bool b){
        for (int i = 0; i < indexs.length; i++){
            if (indexs[i] >= 0 && indexs[i] < actions.length){
                actions[indexs[i]].setEnable(b);
            }
        }
    }
    
    public void setEnable(int n, bool be){
        if (n >= 0 && n < actions.length){
            actions[n].setEnable(be);
        }
    }
    
    public void enableAll(bool be){
        int id = 0;
        for (; id < actions.length; id++){
            actions[id].setEnable(be);	
        }
    }
};