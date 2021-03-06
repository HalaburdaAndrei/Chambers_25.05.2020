trigger Opportunity on Opportunity (before update, after update) {
    if (Trigger.isBefore && Trigger.isUpdate) {
        // Assigns Sales_Target__c to opportunity when opportunity 'closed Won'
        // OpportunityHandler.assignSalesTarget(Trigger.oldMap, Trigger.new);
        new OpportunityHandler().BeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate) {
        new OpportunityHandler().AfterUpdate(Trigger.oldMap, Trigger.newMap);
    }
}