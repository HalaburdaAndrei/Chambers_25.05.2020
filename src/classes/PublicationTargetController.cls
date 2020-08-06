public with sharing class PublicationTargetController {

    @AuraEnabled
    public static List<Publication__c> getPublications (List<Publication__c> listPublications){
        List<Publication__c> publications = new List<Publication__c>();
        if(listPublications != null) {
            Set<Id> pubIds = new Set<Id>();
            for(Publication__c pub : listPublications){
                pubIds.add(pub.Id);
            }
            publications = [
                    SELECT Id, Name, Directory_Allocated_Target__c, Directory_Budget__c, Allocated_Target__c,
                            Directory_Management_Target__c, Insights_Allocated_Target__c, Insights_Budget__c, Budget__c, Management_Target__c,
                            Insights_Management_Target__c, Year_Issue_RE__c
                    FROM Publication__c
                    WHERE Allocated_Target__c > 0 OR Budget__c > 0 OR Management_Target__c > 0 OR Id IN: pubIds
            ];
        }else{
            publications = [
                    SELECT Id, Name, Directory_Allocated_Target__c, Directory_Budget__c, Allocated_Target__c,
                            Directory_Management_Target__c, Insights_Allocated_Target__c, Insights_Budget__c, Budget__c, Management_Target__c,
                            Insights_Management_Target__c, Year_Issue_RE__c
                    FROM Publication__c
                    WHERE Allocated_Target__c > 0 OR Budget__c > 0 OR Management_Target__c > 0
            ];
        }

        return publications;
    }

    @AuraEnabled
    public static void saveTarget(List<Publication__c> pubTarget){
        update pubTarget;
    }

}