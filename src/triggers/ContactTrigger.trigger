trigger ContactTrigger on Contact (before insert, before update, after update) {
    
    if (Trigger.isBefore) {
    	ContactTriggerHandler.AssociateAccount(Trigger.new);
    }

    if (Trigger.isAfter) {
    	ContactTriggerHandler.DeleteIfNecessary(Trigger.new);
    }

}