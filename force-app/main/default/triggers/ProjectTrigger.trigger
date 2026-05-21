trigger ProjectTrigger on Project__c (before insert) {
    ProjectUtil.applyDefaults(Trigger.new);
}