({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.getOpportunities');
        action.setParams({ 'opportunityId' : cmp.get('v.recordId')});
        action.setCallback(this, function (response) {
            if(cmp.isValid() && response.getState() == 'SUCCESS'){
                cmp.set('v.res', response.getReturnValue().table);
                console.log(cmp.get('v.res'));
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": "Error in CurrentFY Component"
                });
                toastEvent.fire();
            }
            cmp.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    // toggle: function(cmp, evt) {
    //     var rows = cmp.get("v.rows");
    //     rows[evt.target.dataset.index].expanded = !rows[evt.target.dataset.index].expanded;
    //     cmp.set("v.rows", rows);
    // }

    toggle: function(cmp, evt) {
        console.log('toggle');
        console.log(evt.target.dataset.index);
        var res = cmp.get("v.res");
        res[evt.target.dataset.index].expanded = !res[evt.target.dataset.index].expanded;
        cmp.set("v.res", res);
    }

})