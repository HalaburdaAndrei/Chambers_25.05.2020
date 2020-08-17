trigger Opportunity on Opportunity (before update) {
  if (Trigger.isBefore && Trigger.isUpdate) {
    // Assigns Sales_Target__c to opportunity when opportunity 'closed Won'
    OpportunityHandler.assignSalesTarget(Trigger.oldMap, Trigger.new);
  }
}