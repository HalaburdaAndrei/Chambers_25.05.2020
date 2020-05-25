public with sharing class FireOpptyAutomationCtrlr {
    public void runBatchJob() {
        Batch_AutoOpportunities bcn = new Batch_AutoOpportunities();
        Id bcnId = Database.executeBatch(bcn,200);
    }
}