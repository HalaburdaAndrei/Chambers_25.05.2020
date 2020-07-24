({

	init: function (cmp, event, helper) {
		helper.init(cmp);
	},

	toggle: function(cmp, evt) {
		var res = cmp.get("v.res");
		res[evt.target.dataset.pricebookindex].wrapperTotalRows[evt.target.dataset.rowindex].expanded = !res[evt.target.dataset.pricebookindex].wrapperTotalRows[evt.target.dataset.rowindex].expanded;
		cmp.set("v.res", res);
	},

	togglePublicationTypeCategory: function(cmp, evt) {
		console.log('togglePublicationTypeCategory');
		console.log(evt.target.dataset.publicationtypecategoryindex);

		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].expanded = !res[evt.target.dataset.publicationtypecategoryindex].expanded;
		cmp.set("v.res", res);
	},

	togglePublicationType: function(cmp, evt) {
		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].expanded = !res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].expanded;
		cmp.set("v.res", res);
	},

	toggleTotalRow: function(cmp, evt) {
		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].expanded
			= !res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].expanded;
		cmp.set("v.res", res);
	},
	filterby : function (cmp, evt, helper) {
		var timer = cmp.get('v.timer');
		clearTimeout(timer);
		var timer = setTimeout(function(){
			helper.getData(cmp, evt);
			clearTimeout(timer);
			cmp.set("v.showSpinner", true);
			cmp.set('v.timer', null);
		}, 300);
		cmp.set('v.timer', timer);
	},



	sortBy : function (cmp,evt) {
		console.log('sort by');

		var sortDirection = cmp.get("v.sortDirection");
		console.log(sortDirection);
		var fieldname = evt.target.dataset.fieldname;
		console.log(fieldname);

		let keyValue = (a) => {
			return a[fieldname];
		};
		var sortData = cmp.get("v.res");

		sortData.forEach( PublicationTypeCategory => {
			PublicationTypeCategory.publicationTypes.forEach(publicationType => {
				publicationType.totalRows.forEach(totalRow => {
					totalRow.products.sort((x, y) => {
						x = keyValue(x) ? keyValue(x) : '';
		y = keyValue(y) ? keyValue(y) : '';
		// sorting values based on direction
		if (sortDirection) {
			return ((x > y) - (y > x));
		} else {
			return ((x > y) - (y > x)) * -1;
		}
	})
	})
	})
	});
		cmp.set("v.res",sortData);
		cmp.set("v.sortDirection",!sortDirection);
		cmp.set("v.sortByField",fieldname);
	},
	closeToast : function (cmp) {
		cmp.set('v.isToastOpen', false);
	}
})