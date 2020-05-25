public class ContactTriggerHandler {
    
    public static void DeleteIfNecessary(List<Contact> recs) {

        Map<String,Id> ccContIdMap = new Map<String,Id>();
        Set<Id> delIds = new Set<Id>();
        for(Contact rec: recs)
            if(rec.CC_To_Be_Deleted__c && rec.CC_New_Contact_ID__c!=null){
                delIds.add(rec.Id);
                ccContIdMap.put(rec.CC_New_Contact_ID__c,rec.Id);
            }
        
        Map<Id,Id> newRecIdMap = new Map<Id,Id>();
        for(Contact cont: [SELECT Id, CC_Contact_ID__c FROM Contact WHERE CC_Contact_ID__c IN :ccContIdMap.keySet()]){
            Id oldContId = ccContIdMap.get(cont.CC_Contact_ID__c);
            if(oldContId!=null)
                newRecIdMap.put(oldContId,cont.Id);
        }

        if(!delIds.isEmpty()){

            RecordUtil.ReparentChildRecords('Contact', newRecIdMap, delIds);

            // System.debug('recordsToUpdate ------------>'+recordsToUpdate);
            // update recordsToUpdate;
            FutureUtil.DeleteCCToBeDeletedRecords(delIds, 'Contact');
        }
    }

    public static void AssociateAccount(List<Contact> newList) {
        
        Set<String> aIds = new Set<String>();
        for(Contact c : newList){
        	if (c.CC_Account_ID__c != null){
        		aIds.add(c.CC_Account_ID__c);
        	}
        }

        Map<String, Id> aMap = new Map<String, Id>();
        for (Account a : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :aIds]) {
            aMap.put(a.CC_Account_ID_RE__c, a.Id);
        }

        for(Contact c : newList){
        	if (c.CC_Account_ID__c != null){

        		if (aMap.containsKey(c.CC_Account_ID__c)){
        			c.AccountId = aMap.get(c.CC_Account_ID__c);
        		}
        		
        	}
        }
        
    }

}