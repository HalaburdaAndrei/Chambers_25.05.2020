trigger LocationTrigger on Location__c (after insert) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            LocationTriggerHandler.PopulateParentLocation(Trigger.newMap);
        }
    }

}