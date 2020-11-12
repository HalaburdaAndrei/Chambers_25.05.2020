({
    genDataTable : function(component,event,helper){
        component.set('v.loaded', !component.get('v.loaded'));

        var selectedYear = parseInt(component.get("v.selectedYear"));

        var action = component.get("c.generateDataTable");
        action.setParams({selectedYear: selectedYear});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue().table)));

                component.set("v.tableBody", JSON.parse(JSON.stringify(response.getReturnValue().table)));
                helper.calculateUserTarget(component,event,helper);
                component.set('v.loaded', !component.get('v.loaded'));

            }
            if (state === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                component.set('v.loaded', !component.get('v.loaded'));

            }
        });
        $A.enqueueAction(action);
    },

    calculateUserTarget : function (component,event,helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var items = component.get("v.tableBody");
        // items.forEach(user => user.usTargets.forEach(target => target.directTarget = 0, target.insightTarget = 0));

        for(var u = 0; u < items.length; u++){

            for(var p = 0; p < items[u].publications.length; p++){

                for(var t = 0; t < items[u].publications[p].publicTargets1.length; t++) {
                    if (items[u].publications[p].publicTargets1[t].Directory_Target__c != null) {
                        if (items[u].usTargets[t].dateTarget === items[u].publications[p].publicTargets1[t].Date__c) {
                            // console.log(numberDirect);
                            items[u].usTargets[t].directTarget += items[u].publications[p].publicTargets1[t].Directory_Target__c;
                            // console.log(items[u].usTargets[t].directTarget);
                        }
                    }
                        if (items[u].publications[p].publicTargets1[t].Insights_Target__c != null) {
                            if (items[u].usTargets[t].dateTarget === items[u].publications[p].publicTargets1[t].Date__c) {
                                items[u].usTargets[t].insightTarget += items[u].publications[p].publicTargets1[t].Insights_Target__c;
                                // console.log(items[u].usTargets[t].directTarget);
                            }
                        }

                }
            }
        }
        component.set('v.loaded', !component.get('v.loaded'));

        console.log(items);
    },
});