public with sharing class PublicationTriggerHandler {
    List<Publication__c> newRecs;
    
    public PublicationTriggerHandler(List<Publication__c> newTriggerRecs){
        newRecs = newTriggerRecs;
    }

    public void beforeSave(){
        Set<String> pubIds = new Set<String>();
        Set<String> noIds = new Set<String>();
        Integer year = 0;
        for(Publication__c rec : newRecs){
            if(year==0) year = Integer.valueOf(rec.Year_Issue_RE__c);
            if(!pubIds.contains(rec.Publication_Type_ID_RE__c)) pubIds.add(rec.Publication_Type_ID_RE__c);
            if(rec.Id!=null)
                noIds.add(rec.Id);
        }

        Map<String,Publication__c> oldPubs = new Map<String,Publication__c>();
        for(Publication__c pub: [SELECT Id, Name, Publication_Type_ID_RE__c FROM Publication__c WHERE Publication_Type_ID_RE__c IN :pubIds AND Id NOT IN :noIds AND Year_Issue_RE__c = :String.valueOf(year-1)]){
            oldPubs.put(pub.Publication_Type_ID_RE__c,pub);
        }

        for(Publication__c rec : newRecs){
            if(rec.PreviousEdition__c==null){
                Publication__c oldPub = oldPubs.get(rec.Publication_Type_ID_RE__c);
                if(oldPub!=null)
                    rec.PreviousEdition__c = oldPub.Id;
            }
        }

    }
}