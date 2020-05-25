trigger PublicationTrigger on Publication__c (before insert, before update) {
    PublicationTriggerHandler triggerHandler = new PublicationTriggerHandler(Trigger.new);
    if(Trigger.isBefore){
        triggerHandler.beforeSave();
    }
}