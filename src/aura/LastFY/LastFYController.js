({
	init: function (cmp, event, helper) {
		helper.init(cmp);
	},

	togglePublicationTypeCategory: function(cmp, evt) {
		console.log('togglePublicationTypeCategory');
		console.log(evt.target.dataset.publicationTypeCategoryIndex);

		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].expanded = !res[evt.target.dataset.publicationtypecategoryindex].expanded;
		cmp.set("v.res", res);
	},

	togglePublicationType: function(cmp, evt) {
		console.log('togglePublicationType');
		console.log(evt.target.dataset.publicationtypecategoryindex);
		console.log(evt.target.dataset.publicationtypeindex);
		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].expanded = !res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].expanded;
		cmp.set("v.res", res);
	},

	toggleTotalRow: function(cmp, evt) {
		console.log('toggleTotalRow');

		console.log(evt.target.dataset);
		console.log(evt.target.dataset.publicationtypecategoryindex);
		console.log(evt.target.dataset.publicationtypeindex);
		console.log(evt.target.dataset.totalrowindex);

		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].expanded
			= !res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].expanded;
		cmp.set("v.res", res);
	},
	toggleTotal: function(cmp, evt) {
		console.log('toggleTotal');

		console.log(evt.target.dataset);
		console.log(evt.target.dataset.publicationtypecategoryindex);
		console.log(evt.target.dataset.publicationtypeindex);
		console.log(evt.target.dataset.totalrowindex);
		console.log(evt.target.dataset.totalindex);

		var res = cmp.get("v.res");
		res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].productTotals[evt.target.dataset.totalindex].expanded
			= !res[evt.target.dataset.publicationtypecategoryindex].publicationTypes[evt.target.dataset.publicationtypeindex].totalRows[evt.target.dataset.totalrowindex].productTotals[evt.target.dataset.totalindex].expanded;
		cmp.set("v.res", res);
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

	filterby : function (cmp, evt, helper) {
		console.log('filterby');
		var timer = cmp.get('v.timer');
		clearTimeout(timer);
		var timer = setTimeout(function(){
			helper.getData(cmp, evt);
			clearTimeout(timer);
			cmp.set("v.showSpinner1", true);
			cmp.set('v.timer', null);
		}, 300);
		cmp.set('v.timer', timer);
	},

	addProduct : function (cmp, evt, helper) {
		helper.addProduct(cmp, evt);
		cmp.set("v.isOpen", false);

	},
	closeToast : function (cmp) {
		cmp.set('v.isToastOpen', false);
	},

	openModel: function(component, event, helper) {
		// for Display Model,set the "isOpen" attribute to "true"
		component.set("v.isOpen", true);
		var opportunityProductId = event.target.dataset.opplineitenid;
		var publicationId = event.target.dataset.publicationid;
		var totalQty = event.target.dataset.totalqty;
		var totalPrice = event.target.dataset.totalprice;
		console.log(publicationId);
		component.set("v.publicationProd", publicationId);
		component.set("v.oppLineId", opportunityProductId);
		component.set("v.oppTotalQty", totalQty);
		component.set("v.oppTotalPrice", totalPrice);
	},

	closeModel: function(component, event, helper) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"
		component.set("v.isOpen", false);
	},
	handleChange : function(component, event, helper) {
		var publicationId = event.getParam("value")[0];
		component.set("v.publicationProd", publicationId);
	},

})