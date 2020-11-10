({
    doInit: function (component, event, helper) {

    },
    closeToast: function (cmp) {
        cmp.set('v.isToastOpen', false);
    },

    generated: function (component, event, helper) {
        var action = component.get("c.openUrl");
        action.setParams({recordId:component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                if(response.getReturnValue() !== 'no') {
                    window.open(response.getReturnValue(),'_self');
                }else{
                    // helper.showToast(component,'error', 'Conga Transaction already exists, cancel to send a new one. ','Error!');
                    // var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    // dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "The Conga transaction already exists with the SENT status, cancel it to send a new one.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": response.getError(),
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }

})