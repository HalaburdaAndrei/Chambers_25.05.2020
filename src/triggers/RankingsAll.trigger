trigger RankingsAll on Rankings__c (before insert, after insert, before update, after update) {

    if (Trigger.isBefore) {
        RankingsAllHandler.PopulatePublication(Trigger.new);
        RankingsAllHandler.PopulateAccount(Trigger.new);
        RankingsAllHandler.PopulateParentAccount(Trigger.new);
        RankingsAllHandler.PopulateContact(Trigger.new);
        RankingsAllHandler.PopulateLocation(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            RankingsAllHandler.SoftDeleted(Trigger.new);
        }
        if (Trigger.isUpdate) {
            RankingsAllHandler.SoftDeleted(Trigger.new);
        }
    }
    
}