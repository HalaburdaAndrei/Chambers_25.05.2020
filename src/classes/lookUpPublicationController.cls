public with sharing class lookUpPublicationController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList) {
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();

        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }

        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5 and exclude already selected records
        String sQuery =  'select Id, Name, CC_PublicationTypeCategory__c, Directory_Allocated_Target__c, Directory_Budget__c, Allocated_Target__c, Directory_Management_Target__c, Insights_Allocated_Target__c, Insights_Budget__c, Budget__c, Management_Target__c, Insights_Management_Target__c, Year_Issue_RE__c from ' +ObjectName + ' where Name LIKE: searchKey AND Id NOT IN : lstExcludeitems order by createdDate DESC limit 10';
        List < sObject > lstOfRecords = Database.query(sQuery);

        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
}