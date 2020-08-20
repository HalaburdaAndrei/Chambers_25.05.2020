({
    datatable : function(component, event, helper){
        component.set('v.loaded', !component.get('v.loaded'));
        var action = component.get("c.getPublications");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record){
                    if(typeof record.Id != 'undefined'){
                        record.showClass = 'graycolor';
                    }
                });
                component.set('v.loaded', !component.get('v.loaded'));
                component.set("v.data", records);
            }
            if(state === 'ERROR'){
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
    },

    saveEdition: function (cmp, event, draftValues) {

        cmp.set('v.loaded', !cmp.get('v.loaded'));
        var action = cmp.get("c.saveTarget");
        action.setParams({pubTarget : draftValues});
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === 'SUCCESS'){
               if(response.getReturnValue() == 'ok') {
                   cmp.set('v.loaded', !cmp.get('v.loaded'));
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "type": "success",
                       "message": "The publications has been saved successfully."
                   });
                   toastEvent.fire();
                   cmp.set('v.errors', []);
                   cmp.set('v.draftValues', []);
                   this.datatable(cmp);
                   // $A.get('e.force:refreshView').fire();
               }else{
                   var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Error!",
                       "type": "error",
                       "message": response.getReturnValue()
                   });
                   toastEvent.fire();
               }
               // window.location.reload()

           }
            if(state === 'ERROR'){
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
    },

    sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                return primer(x[field]);
            }
            : function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = cmp.get("v.data");
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));

        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    }
})