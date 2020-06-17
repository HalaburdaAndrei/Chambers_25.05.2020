
({
    doInit : function(component, event, helper) {
        var currentOrderId = component.get("v.recordId");
        var action = component.get("c.getAccounts");

        //action.setParams({ ADSRecId : "a0o4F000000QwVUQA0" });

        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {

                var Responsedata = response.getReturnValue();
                //alert('Responsedata--'+JSON.stringify(Responsedata));
                component.set("v.items", response.getReturnValue());

            }
        });

        $A.enqueueAction(action);
    },

    toggle: function(component, event, helper) {
        var items = component.get("v.items"), index = event.getSource().get("v.value");
        items[index].expanded = !items[index].expanded;
        component.set("v.items", items);
    }
})