trigger AcrRolesTempTrigger on ACR_Roles_Temp__c (before insert, before update, after insert, after update) {
	
	if(Trigger.isAfter){
		AcrRolesTempTriggerHandler.populateRoles(Trigger.new);
	}

}