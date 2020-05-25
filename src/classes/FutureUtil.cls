global class FutureUtil{
    @future
    public static void LocationParentUpdate(Set<ID> recordIds){   
        List<Location__c> locsToUpdate = new List<Location__c>();
        Map<String, List<Id>> paLocMap = new Map<String, List<Id>>();

        for (Location__c loc : [SELECT Id, CC_Location_Parent_ID__c FROM Location__c WHERE Id IN :recordIds AND CC_Location_Parent_ID__c!=NULL AND Parent_Location__c=NULL]) {
            if(paLocMap.get(loc.CC_Location_Parent_ID__c) == null)
                paLocMap.put(loc.CC_Location_Parent_ID__c, new List<Id>());
            paLocMap.get(loc.CC_Location_Parent_ID__c).add(loc.Id);
        }

        for (Location__c loc : [SELECT Id, CC_Location_ID__c FROM Location__c WHERE CC_Location_ID__c IN :paLocMap.keySet()])
            for(Id LocId : paLocMap.get(loc.CC_Location_ID__c))
            	locsToUpdate.add(new Location__c(
                    Id = LocId, 
                    Parent_Location__c = loc.Id
                ));
        
        try {
        	update locsToUpdate;
        } catch(DmlException e){
        	System.debug('Could not update Locations: ' + e.getMessage());
        }
    }

    @future
    public static void DeleteCCToBeDeletedRecords(Set<ID> recordIds, String objectName){
        delete Database.query('SELECT Id FROM '+objectName+' WHERE Id IN :recordIds');
    }
}