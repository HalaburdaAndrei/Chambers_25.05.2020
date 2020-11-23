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

        for(var u = 0; u < items.length; u++){
            for(var k = 0; k < items[u].usTargets.length; k++){
                items[u].usTargets[k].directTarget = 0;
                items[u].usTargets[k].insightTarget = 0;
            }

            for(var p = 0; p < items[u].publications.length; p++){
                    items[u].publications[p].totalpubl = 0;
                for(var t = 0; t < items[u].publications[p].publicTargets1.length; t++) {
                    if (items[u].publications[p].publicTargets1[t].Directory_Target__c != null) {
                        if (items[u].usTargets[t].dateTarget === items[u].publications[p].publicTargets1[t].Date__c) {
                            items[u].usTargets[t].directTarget += items[u].publications[p].publicTargets1[t].Directory_Target__c;
                            items[u].publications[p].totalpubl += items[u].publications[p].publicTargets1[t].Directory_Target__c;
                        }
                    }
                    if (items[u].publications[p].publicTargets1[t].Insights_Target__c != null) {
                        if (items[u].usTargets[t].dateTarget === items[u].publications[p].publicTargets1[t].Date__c) {
                            items[u].usTargets[t].insightTarget += items[u].publications[p].publicTargets1[t].Insights_Target__c;
                            items[u].publications[p].totalpubl += items[u].publications[p].publicTargets1[t].Insights_Target__c;
                        }
                    }

                }
            }
        }
        for(var u = 0; u < items.length; u++) {
            for (var k = 0; k < items[u].usTargets.length; k++) {
                items[u].totalUser += items[u].usTargets[k].directTarget + items[u].usTargets[k].insightTarget;
            }
        }
        component.set('v.loaded', !component.get('v.loaded'));

        console.log(items);
    },
});