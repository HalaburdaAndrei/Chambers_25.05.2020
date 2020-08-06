({
    saveEdition: function (cmp, draftValues) {
        var self = this;
        console.log(self);
        var action = cmp.get("c.saveTarget");
        action.setParams({pubTarget : draftValues});
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === 'SUCCESS'){
               var toastEvent = $A.get("e.force:showToast");
               toastEvent.setParams({
                   "title": "Success!",
                   "type": "success",
                   "message": "The publications has been saved successfully."
               });
               toastEvent.fire();
               $A.get('e.force:refreshView').fire();
               // window.location.reload()

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