global class Schedule_CreateOpptys implements Schedulable{
    global void execute(SchedulableContext SC) {
        Batch_AutoOpportunities bcn = new Batch_AutoOpportunities();
        Id bcnId = Database.executeBatch(bcn,1);
    }
}