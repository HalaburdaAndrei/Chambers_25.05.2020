({
    doInit: function (component, event, helper) {
        console.log('Start');
        component.set('v.columns', [
            {label: 'Guide Annual Target', fieldName: 'Name', type: 'text', editable: false, sortable: true, initialWidth: 200, title: true, typeAttributes: { required: true }},
            {label: 'Allocated Target', fieldName: 'Allocated_Target__c', type: 'currency', sortable: true, editable: false },
            {label: 'Directory Allocated Target', fieldName: 'Directory_Allocated_Target__c', type: 'currency', sortable: true, editable: true },
            {label: 'Insights Allocated Target', fieldName: 'Insights_Allocated_Target__c', type: 'currency', sortable: true, editable: true },
            {label: 'Budget', fieldName: 'Budget__c', type: 'currency', sortable: true, editable: false },
            {label: 'Directory Budget', fieldName: 'Directory_Budget__c', type: 'currency', sortable: true, editable: true },
            {label: 'Insights Budget', fieldName: 'Insights_Budget__c', type: 'currency', sortable: true, editable: true},
            {label: 'Management Target', fieldName: 'Management_Target__c', type: 'currency', sortable: true, editable: false },
            {label: 'Directory Management Target', fieldName: 'Directory_Management_Target__c', type: 'currency', sortable: true, editable: true },
            {label: 'Insights Management Target', fieldName: 'Insights_Management_Target__c', type: 'currency', sortable: true, editable: true }
        ]);
        console.log(component.get("v.columns"));
        var action = component.get("c.getPublications");
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === 'SUCCESS'){
               component.set("v.data", response.getReturnValue());
           }
        });
        $A.enqueueAction(action);
    },

    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        helper.saveEdition(cmp, draftValues);
    },

    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    },

    addPublication: function (cmp, event, helper) {

        var action = cmp.get("c.getPublications");
        action.setParams({listPublications: cmp.get("v.selectedLookUpRecords")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                cmp.set("v.data", response.getReturnValue());
                console.log(cmp.get("v.data"));

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The publications has been updated successfully."
                });
                toastEvent.fire();

            }
        });
        $A.enqueueAction(action);

    }
})