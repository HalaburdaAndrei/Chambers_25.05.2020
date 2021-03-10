global class BatchUpdateContactOwner implements Database.Batchable<sObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, Name, AccountId, Account.Name, Account.OwnerId, Account.Owner.IsActive, OwnerId FROM Contact';
        return Database.getQueryLocator(query);

    }

    global void execute(Database.BatchableContext BC, List<Contact> scope) {

        List<Contact> updateContactOwner = new List<Contact>();
        for (Contact con : scope){
            if(con.OwnerId != con.Account.OwnerId && con.Account.Owner.IsActive == true){
                con.OwnerId = con.Account.OwnerId;
                updateContactOwner.add(con);
            }
        }
        if(updateContactOwner.size() > 0){
            update updateContactOwner;
        }
    }

    global void finish(Database.BatchableContext BC) {
    }
}