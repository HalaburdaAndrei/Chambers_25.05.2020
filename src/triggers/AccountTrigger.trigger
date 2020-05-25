trigger AccountTrigger on Account (before insert, before update, after update) {

    if (Trigger.isBefore) {
    	AccountTriggerHandler.AssociateParentAccount(Trigger.new);
    }

    if (Trigger.isAfter) {
    	AccountTriggerHandler.DeleteIfNecessary(Trigger.new);
    }
    
}