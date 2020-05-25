public class AcrRolesTempTriggerHandler {

	public static void populateRoles(List<ACR_Roles_Temp__c> newList) {
		System.debug('===IN populateRoles------'+ newList);

        Map<String, Set<String>> ccCntRoleMap = new Map<String, Set<String>>();
        Map<String, Map<String, Set<String>> > ccAcctMap = new Map<String, Map<String, Set<String>> >();

        List<Id> idList = new List<Id>();

        for(ACR_Roles_Temp__c act : newList) {
        	System.debug('===act------'+act);

        	//to be deleted by future method
        	idList.add(act.Id);

            if(act.Roles__c != null && act.CC_Contact_ID__c != null){
            //if(act.CC_Contact_ID__c != null){

            	// no value, initialize contact to roles map
            	if(ccCntRoleMap.get(act.CC_Contact_ID__c) == null) {
                	ccCntRoleMap.put(act.CC_Contact_ID__c, new Set<String>());
            	}
            	//System.debug('===act.Roles-----'+ act.Roles__c);

            	// populate contact to roles map
				ccCntRoleMap.get(act.CC_Contact_ID__c).add(act.Roles__c);
				//System.debug('===ccCntRoleMap-----'+ ccCntRoleMap.get(act.CC_Contact_ID__c));
            }
        }
        System.debug('===ccCntRoleMap------'+ ccCntRoleMap);


		for(ACR_Roles_Temp__c act : newList) {
			for(String cid : ccCntRoleMap.keySet()){

	            if(act.CC_Contact_ID__c == cid){

	            	if(ccAcctMap.get(act.CC_Account_ID__c) == null) {
	            		ccAcctMap.put(act.CC_Account_ID__c, new Map<String, Set<String>>());
	            	}
	            	ccAcctMap.get(act.CC_Account_ID__c).put(cid,ccCntRoleMap.get(cid));
	            }
			}
        }
        System.debug('===ccAcctMap------'+ ccAcctMap);


    	Set<String> cIds = new Set<String>();
    	Set<String> aIds = new Set<String>();
        for(ACR_Roles_Temp__c art : newList){
        	if(art.Roles__c != null){

	    		if (art.CC_Contact_ID__c != null){
	    			cIds.add(art.CC_Contact_ID__c);
	    		}
	    		if (art.CC_Account_ID__c != null){
	    			aIds.add(art.CC_Account_ID__c);
	    		}

        	}
    	}
    	System.debug('===cIds------'+ cIds);
    	System.debug('===aIds------'+ aIds);



		Set<String> roleSet = new Set<String>();
		List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();

		// mindful of updating ACR : need IsDirect=true clause to capture currently relationship since false conditions are previous relationships
		for(AccountContactRelation acr : [SELECT Id, AccountId, ContactId, account.CC_Account_ID_RE__c, contact.CC_Contact_ID__c, Roles
											FROM AccountContactRelation WHERE IsDirect=true AND Account.CC_Account_ID_RE__c IN :aIds AND Contact.CC_Contact_ID__c IN :cIds] ) {

			if(ccAcctMap.containsKey(acr.account.CC_Account_ID_RE__c)){

				//acrToUpdate = acr;

				if(ccAcctMap.get(acr.account.CC_Account_ID_RE__c).containsKey(acr.contact.CC_Contact_ID__c)){

					roleSet = ccAcctMap.get(acr.account.CC_Account_ID_RE__c).get(acr.contact.CC_Contact_ID__c);
					//System.debug('===roleSet-----'+roleSet);
					String allRoles = '';
					for(String role : roleSet) {
						System.debug('--acr.Id--role---'+ acr.Id +'-----'+ role);
						if( role != 'null' && role != null ) {

							// if(acr.Roles == null) {
							// } else if(!acr.Roles.contains(role) ) {
							allRoles += ';'+role;
							// }

						}
					}
					acr.Roles = allRoles;
					acrsToUpdate.add(acr);
				}

			}
		}
		System.debug('===acrToUpdate-----'+acrsToUpdate);

		try {

			update acrsToUpdate;
			deleteACT(idList);

		} catch(Exception e) {
			System.debug('Update failed.'+ e.getMessage()); 
		}

	}

	@future
	public static void deleteACT(List<Id> actId){

		List<ACR_Roles_Temp__c> goneACT = [SELECT Id from ACR_Roles_Temp__c WHERE Id IN : actId];
		delete goneACT;

	}


    

}