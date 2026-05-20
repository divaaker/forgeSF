trigger EventTriggerAccount on AccountChangeEvent (after insert) {
    set<Id> sIds = new set<Id>();
    for(AccountChangeEvent oAcc : trigger.new){
        sIds.add(oAcc.Id);
        system.debug(sIds);
    }
}