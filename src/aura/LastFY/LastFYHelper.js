({
	init: function (cmp) {
		var action = cmp.get('c.getOpportunities');
		action.setParams({ 'opportunityId' : cmp.get('v.recordId')});
		action.setCallback(this, function (response) {
			if(cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status == 'success'){
				cmp.set('v.res', response.getReturnValue().table);
			} else {
				this.showToast(cmp, 'error', response.getReturnValue().message, 'Error!');
			}
			cmp.set('v.showSpinner1', false);
		});
		$A.enqueueAction(action);
	},

	getData: function (cmp, evt) {
		console.log('getDataLastFY');
		// cmp.set('v.showSpinner1', true);
		var params = new Object();
		params.recordId = cmp.get('v.recordId');
		//Filter params
		params.publicationFilter = cmp.get('v.publicationFilter');
		params.oppIdFilter = cmp.get('v.oppIdFilter');
		params.productFilter = cmp.get('v.productFilter');
		params.qtyFilter = cmp.get('v.qtyFilter');
		params.salesPriceFilter = cmp.get('v.salesPriceFilter');
		params.salesPersonFilter = cmp.get('v.salesPersonFilter');
		params.signerFilter = cmp.get('v.signerFilter');
		params.closeDateFilter = cmp.get('v.closeDateFilter');
		params.relatedOrganizationFilter = cmp.get('v.relatedOrganizationFilter');
		params.chapterFilter = cmp.get('v.chapterFilter');
		params.parentAccountFilter = cmp.get('v.parentAccountFilter');
		params.locationFilter = cmp.get('v.locationFilter');
		params.numberOfSubmissionsFilter = cmp.get('v.numberOfSubmissionsFilter');
		console.log(params);
		var action = cmp.get('c.getOpportunitiesSearchLastFY');
		action.setParams({
			'params': params
		});

		action.setCallback(this, function (response) {
			if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status == 'success') {
				cmp.set('v.res', response.getReturnValue().table);
			} else {
				this.showToast(cmp, 'error', response.getReturnValue().message, 'Error!');
			}
			cmp.set('v.showSpinner1', false);
		});
		$A.enqueueAction(action);
	},

	addProduct : function (cmp, evt) {
		var opportunityProductId = evt.target.dataset.opplineitenid;
		var currentOppId = cmp.get('v.recordId');
		console.log('opportunityProductId');
		console.log(opportunityProductId);
		console.log('currentOppId');
		console.log(currentOppId);
		cmp.set('v.showSpinner1', true);
		var action = cmp.get('c.getProduct');
		action.setParams({
			opportunityProductId: opportunityProductId,
			currentOppId : currentOppId
		});
		action.setCallback(this, function (response) {
			if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status == 'success') {
				this.showToast(cmp,'success', 'Product was added','Success');
			} else {
				this.showToast(cmp,'error', response.getReturnValue().message,'Error!');
			}
			cmp.set('v.showSpinner1', false);
		});
		$A.enqueueAction(action);
	},

	showToast: function (component, type, message, title) {
		var toastEvent = undefined;
		try {
			toastEvent = $A.get('e.force:showToast');
		} catch (error) {
			//do nothing, will use UiMessage
		}
		if (toastEvent !== undefined) {
			// LE - use toast
			toastEvent.setParams({
				type: type.toLowerCase(),
				title: title,
				mode: 'sticky',
				message: message,
				duration: 5000
			});
			toastEvent.fire();
		} else {
			// classic VF page - use uimessage
			component.set('v.toastMessage', message);
			component.set("v.toastType", title);
			switch (type.toLowerCase()) {
				case 'error':
					component.set("v.toastStyle", 'slds-notify slds-notify_toast slds-theme_error');
					break;
				case 'success':
					component.set("v.toastStyle", 'slds-notify slds-notify_toast slds-theme_success');
					window.setTimeout(
						$A.getCallback(function () {
							if (component.isValid()) {
								var toastDiv = component.find('toastCmp');
								$A.util.removeClass(toastDiv, "slds-show");
								$A.util.addClass(toastDiv, "slds-hide");
							} else {
							}
						}), 5000
					);
					break;
			}
			component.set('v.isToastOpen', true);
		}
	}
})