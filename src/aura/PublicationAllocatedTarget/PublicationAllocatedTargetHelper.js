({
    getResultPublicationTarget : function(component, event,helper){
        component.set('v.loaded', !component.get('v.loaded'));

        var getresultTable = component.get("c.generateDataTable");
        getresultTable.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue().table;
                console.log(result);
                component.set("v.resultTableTarget", result);
                helper.calculatePublicationTarget(component,event,helper);
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
        $A.enqueueAction(getresultTable);
    },

    calculatePublicationTarget : function (component, event, helper) {
        var items = component.get("v.resultTableTarget");
        if(items != null) {
            for (var i = 0; i < items.length; i++) {
                items[i].publicationDirectoryAllocatedTarget = 0;
                items[i].publicationInsightsAllocatedTarget = 0;
                for (var p = 0; p < items[i].productCategaryRows.length; p++) {
                    if (items[i].publicationId === items[i].productCategaryRows[p].publicationTargets[0].Publication__c) {
                        items[i].publicationDirectoryAllocatedTarget += items[i].productCategaryRows[p].publicationTargets[0].Directory_Allocated_Target__c;
                    }
                    if (items[i].publicationId === items[i].productCategaryRows[p].publicationTargets[0].Publication__c) {
                        items[i].publicationInsightsAllocatedTarget += items[i].productCategaryRows[p].publicationTargets[0].Insights_Allocated_Target__c;
                    }
                }
            }
        }
    },

    picklistProductcategory : function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var getPicklistCategory = component.get("c.getPicklistProductCategory");
        getPicklistCategory.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                var result = response.getReturnValue();
                var items = [];
                for (var i = 0; i < result.length; i++) {
                    var item = {
                        "Id": result[i],
                        "Name": result[i]
                    };
                    items.push(item);
                }
                component.set("v.selectedProdCategory", items[0].value);
                component.set("v.optionsProductCategory", items);
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
        $A.enqueueAction(getPicklistCategory);
    },

    picklistPublicationCategory : function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var picklistPubCat = component.get("c.getPicklistPublucationCategory");
        picklistPubCat.setCallback(this, function (response) {
           var state = response.getState()
           console.log(state);
           if(state === 'SUCCESS'){
               console.log(response.getReturnValue());
               var result = response.getReturnValue();
               var items = [];
               for (var i = 0; i < result.length; i++) {
                   var item = {
                       "label": result[i],
                       "value": result[i]
                   };
                   items.push(item);
               }

               let currYear = new Date().getFullYear();
               let nextYear = currYear + 1;
               var yearList = [
                   {'label': `${(currYear - 1).toString()}`, 'value': (currYear - 1).toString()},
                   {'label': `${currYear.toString()}`, 'value': currYear.toString()},
                   {'label': `${nextYear.toString()}`, 'value': nextYear.toString()}];

               component.set("v.optionsPublicationCategory", items);
               component.set("v.optionsYears", yearList);
               component.set("v.selectedYear", currYear.toString());
               component.set('v.loaded', !component.get('v.loaded'));
           }
        });
        $A.enqueueAction(picklistPubCat);
    },


})