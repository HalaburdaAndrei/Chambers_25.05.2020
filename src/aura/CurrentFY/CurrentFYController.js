({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.getOpportunities');
        action.setParams({ 'opportunityId' : cmp.get('v.recordId')});
        action.setCallback(this, function (response) {
            if(cmp.isValid() && response.getState() == 'SUCCESS'){
                cmp.set('v.res', response.getReturnValue().table);

                console.log(response.getReturnValue().table);
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
        var res = cmp.get("v.res");
        res[evt.target.dataset.pricebookindex].wrapperTotalRows[evt.target.dataset.rowindex].expanded = !res[evt.target.dataset.pricebookindex].wrapperTotalRows[evt.target.dataset.rowindex].expanded;
        cmp.set("v.res", res);
    },

    togglePriceBook: function(cmp, evt) {
        var res = cmp.get("v.res");
        res[evt.target.dataset.pricebookindex].expanded = !res[evt.target.dataset.pricebookindex].expanded;
        cmp.set("v.res", res);
    },

    sortBy : function (cmp,evt) {
        var sortDirection = cmp.get("v.sortDirection");
        var fieldname = evt.target.dataset.fieldname;
        let keyValue = (a) => {
            return a[fieldname];
        };
        var sortData = cmp.get("v.res");
        sortData.forEach(priceBook=>{
            priceBook.wrapperTotalRows.forEach(totalRow => {
                totalRow.products.sort((x, y) => {
                    x = keyValue(x) ? keyValue(x) : ''; // handling null values
                    y = keyValue(y) ? keyValue(y) : '';
                    // sorting values based on direction
                    if (sortDirection) {
                        return ((x > y) - (y > x));
                    } else {
                        return ((x > y) - (y > x)) * -1;
                    }
                })
            })
        });
        cmp.set("v.res",sortData);
        cmp.set("v.sortDirection",!sortDirection);
        cmp.set("v.sortByField",fieldname);
    }
})