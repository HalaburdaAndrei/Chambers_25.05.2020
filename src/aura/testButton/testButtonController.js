/**
 * Created by andrei on 14.04.20.
 */
({
    doInit: function (component, event, helper) {
        var templates = component.get("c.templates");
        templates.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.templates", response.getReturnValue());
            }
        });
        // $A.enqueueAction(templates);
    },
    save : function (component, event, helper) {
        var url = '/apex/APXTConga4__Conga_Composer?SolMgr=1&serverUrl={!API.Partner_Server_URL_370}&Id=0061l00000JmP6gAAF&QueryId=[bfq]a0C1t000005jkh1&TemplateId=a0K1t000005SDbZ&EmailAdditionalTo={!Opportunity.Signer_Email__c}&EmailRelatedToId=0061l00000JmP6gAAF&EmailSubject=Email+Subject&EmailUseSignature=1&AC0=1&DS7=2';
        window.open(url);

    }



})