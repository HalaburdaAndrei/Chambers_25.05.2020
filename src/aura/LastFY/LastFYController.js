({
    init: function (cmp, event, helper) {
    	helper.init(cmp);
    },

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
    },

	filterby : function (cmp, evt, helper) {
		var timer = cmp.get('v.timer');
		clearTimeout(timer);
		var timer = setTimeout(function(){

			helper.getData(cmp, evt);
			clearTimeout(timer);

			cmp.set('v.timer', null);
		}, 300);
		cmp.set('v.timer', timer);
	},

	addProduct : function (cmp, evt, helper) {
		helper.addProduct(cmp, evt);
	}
})