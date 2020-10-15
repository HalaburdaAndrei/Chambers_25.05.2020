({
    doInit: function (component, event, helper) {
        console.log('Start');
        component.set('v.columns', [{
            label: 'Guide Annual Target',
            fieldName: 'Name',
            type: 'text',
            editable: false,
            sortable: true,
            wrapText: true,
            initialWidth: 220,
            title: true,
            typeAttributes: {
                required: true
            }
        },
            {
                label: 'Allocated Target',
                fieldName: 'Allocated_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: false,
                cellAttributes: {
                    class: {
                        fieldName: "showClass"
                    }
                }
            },
            {
                label: 'Directory Allocated Target',
                fieldName: 'Directory_Allocated_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            },
            {
                label: 'Insights Allocated Target',
                fieldName: 'Insights_Allocated_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            },
            {
                label: 'Budget',
                fieldName: 'Budget__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: false,
                cellAttributes: {
                    class: {
                        fieldName: "showClass"
                    }
                }
            },
            {
                label: 'Directory Budget',
                fieldName: 'Directory_Budget__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            },
            {
                label: 'Insights Budget',
                fieldName: 'Insights_Budget__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            },
            {
                label: 'Management Target',
                fieldName: 'Management_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: false,
                cellAttributes: {
                    class: {
                        fieldName: "showClass"
                    }
                }
            },
            {
                label: 'Directory Management Target',
                fieldName: 'Directory_Management_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            },
            {
                label: 'Insights Management Target',
                fieldName: 'Insights_Management_Target__c',
                type: 'currency',
                sortable: true,
                hideDefaultActions: "true",
                editable: true
            }
        ]);

        helper.datatable(component, event, helper);
    },

    handleSaveEdition: function (cmp, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log(draftValues);
        helper.saveEdition(cmp, event, draftValues);
    },

    handleSort: function (cmp, event, helper) {
        helper.handleSort(cmp, event);
    },

    addPublication: function (cmp, event, helper) {
        var selectedLookUpRecords = cmp.get("v.selectedLookUpRecords");
        if (selectedLookUpRecords.length > 0) {
            cmp.set('v.loaded', !cmp.get('v.loaded'));
            var action = cmp.get("c.getPublications");
            action.setParams({
                listPublications: selectedLookUpRecords
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === 'SUCCESS') {
                    var records = response.getReturnValue();
                    records.forEach(function (record) {
                        if (typeof record.Id != 'undefined') {
                            record.showClass = 'graycolor';
                        }
                    });
                    cmp.set('v.loaded', !cmp.get('v.loaded'));
                    cmp.set("v.data", records);
                    console.log(cmp.get("v.data"));

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "The publications has been updated successfully."
                    });
                    toastEvent.fire();
                }
                if (state === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getError()
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": "Select a publication to add!"
            });
            toastEvent.fire();

            helper.datatable(cmp, event, helper);
            // var action = cmp.get("c.getPublications");
            // action.setCallback(this, function (response) {
            //
            //     var state = response.getState();
            //     if (state === "SUCCESS") {
            //         var records = response.getReturnValue();
            //         records.forEach(function(record){
            //             if(typeof record.Id != 'undefined'){
            //                 record.showClass = 'graycolor';
            //             }
            //         });
            //         cmp.set("v.data", records);
            //     }
            //     if(state === 'ERROR'){
            //         var toastEvent = $A.get("e.force:showToast");
            //         toastEvent.setParams({
            //             "title": "Error!",
            //             "type": "error",
            //             "message": response.getError()
            //         });
            //         toastEvent.fire();
            //     }
            // });
            // $A.enqueueAction(action);
        }

    }
})