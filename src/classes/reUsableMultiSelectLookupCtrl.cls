public with sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, String recordId) {

        Opportunity opportunityId = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id =: recordId];
        String accId = opportunityId.AccountId;
        String accParentId;
        if(opportunityId.Account.ParentId != null){
            accParentId = opportunityId.Account.ParentId;
        }else{
            accParentId = opportunityId.AccountId;
        }

        List<Account> accList = [SELECT Id FROM Account WHERE ParentId =: accParentId OR Id =: accId OR Id =: accParentId];

        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();

        List<string> lstExcludeitems = new List<string>();
        if(ExcludeitemsList != null) {
            for (sObject item : ExcludeitemsList) {
                lstExcludeitems.add(item.id);
            }
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
        String sQuery =  'select id, Name, Email, Account.Name from ' +ObjectName + ' where AccountId IN : accList AND Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}