({

    selectContact: function (component, event, helper) {
        var contact = component.get("c.conId");
        contact.setParams({recordId: component.get("v.recordId")});
        contact.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                if (response.getReturnValue() != null) {
                    component.set("v.selectedLookUpContact", response.getReturnValue());
                }
            }
        });
        $A.enqueueAction(contact);
    },

    templateList: function (component, event, helper) {
        var templates = component.get("c.templates");
        templates.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.listTemplates", response.getReturnValue());
                component.set("v.selectedTemplate", response.getReturnValue()[0].Id);
            }
        });
        $A.enqueueAction(templates);
    },

    getSubjectAndBody: function (component, event, helper) {
        var subjectAndBody = component.get("c.getSubjectAndBody");
        subjectAndBody.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.subject", response.getReturnValue().Subject__c);
                component.set("v.body", response.getReturnValue().Body__c);
            }
        });
        $A.enqueueAction(subjectAndBody);
    }
})