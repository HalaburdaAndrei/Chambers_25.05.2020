({
    doInit : function(component, event, helper) {
        var currentOrderId = component.get("v.recordId");
        var action = component.get("c.getRankings");

        //action.setParams({ ADSRecId : "a0o4F000000QwVUQA0" });

        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
var test = "2017, 2018, 2019, 2020";
                var Responsedata = response.getReturnValue();
                //alert('Responsedata--'+JSON.stringify(Responsedata));
                console.log(Responsedata.table[0]);
                component.set("v.items", response.getReturnValue().table);
                component.set("v.items1", response.getReturnValue().table[0].listYear);

            }
        });

        $A.enqueueAction(action);
    },

    toggle: function(component, event, helper) {
        var items = component.get("v.items"), index = event.target.dataset.index;
        items[index].expanded = !items[index].expanded;
        component.set("v.items", items);
    }
})