public class AccountTriggerHandler {
    
    public static void DeleteIfNecessary(List<Account> recs) {
        Map<String,Id> ccAcctIdMap = new Map<String,Id>();
        
        Set<Id> delIds = new Set<Id>();
        for(Account rec: recs)
            if(rec.CC_To_Be_Deleted__c && rec.CC_New_Account_ID__c!=null){
                delIds.add(rec.Id);
                ccAcctIdMap.put(rec.CC_New_Account_ID__c,rec.Id);
            }
        
        Map<Id,Id> newRecIdMap = new Map<Id,Id>();
        for(Account acct: [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :ccAcctIdMap.keySet()]){
            Id oldAcctId = ccAcctIdMap.get(acct.CC_Account_ID_RE__c);
            if(oldAcctId!=null)
                newRecIdMap.put(oldAcctId,acct.Id);
        }

        if(!delIds.isEmpty()){
            
            RecordUtil.ReparentChildRecords('Account', newRecIdMap, delIds);

            // System.debug('recordsToUpdate ------------>'+recordsToUpdate);
            // update recordsToUpdate;
            FutureUtil.DeleteCCToBeDeletedRecords(delIds, 'Account');
        }
    }

    public static void AssociateParentAccount(List<Account> newList) {

        Set<String> paIds = new Set<String>();
        for(Account a : newList){
        	if (a.ParentId == null && a.CC_Parent_Account_ID_RE__c != null){
        		paIds.add(a.CC_Parent_Account_ID_RE__c);
        	}
        }
        //System.debug('===paIds------'+ paIds);

        Map<String, Id> aMap = new Map<String, Id>();
        for (Account a : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :paIds]) {
            aMap.put(a.CC_Account_ID_RE__c, a.Id);
        }
        //System.debug('===aMap----'+ aMap);

        for(Account a : newList){

        	if (a.CC_Parent_Account_ID_RE__c != null && a.CC_Parent_Account_ID_RE__c != a.CC_Account_ID_RE__c){

        		if (aMap.containsKey(a.CC_Parent_Account_ID_RE__c)){
                    String strParentId = aMap.get(a.CC_Parent_Account_ID_RE__c);

                    if( a.Id !=  strParentId )
        			     a.ParentId = strParentId;
        		}
        	
        	}
        }
        
    }

}