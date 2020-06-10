/**
 * Created by andrei on 08.06.20.
 */

public with sharing class reUsableMultiSelectLookupCtrl {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList, String recordId) {

        Opportunity opportunityId = [SELECT AccountId FROM Opportunity WHERE Id =: recordId];
        String accId = opportunityId.AccountId;

        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();

        List<string> lstExcludeitems = new List<string>();
        if(ExcludeitemsList != null) {
            for (sObject item : ExcludeitemsList) {
                lstExcludeitems.add(item.id);
            }
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
        String sQuery =  'select id, Name, Email from ' +ObjectName + ' where AccountId =: accId AND Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}