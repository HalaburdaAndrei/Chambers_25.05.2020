({
	doInit : function(component, event, helper) {
		var opp = component.get("v.record");
        if(opp.EligibleProducts_RE__c!=null && opp.EligibleProducts_RE__c.indexOf("||")>0){
            var values = opp.EligibleProducts_RE__c.split("||");
        } else {
            var values = opp.EligibleProducts_RE__c;
        }
        component.set("v.values",values);
	}
})