trigger SubmissionsAll on Submissions__c (before insert, after insert, before update, after update) {

    if (Trigger.isBefore) {
        SubmissionsAllHandler.PopulatePublication(Trigger.new);
        SubmissionsAllHandler.PopulateAccount(Trigger.new);
        SubmissionsAllHandler.PopulateParentAccount(Trigger.new);   
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            SubmissionsAllHandler.SoftDeleted(Trigger.new);
        }
        if (Trigger.isUpdate) {
            SubmissionsAllHandler.SoftDeleted(Trigger.new);
        }
    }
    
}