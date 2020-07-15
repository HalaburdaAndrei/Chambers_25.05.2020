({
    removeContacts: function (cmp, event, campaignId, contactsId) {
        var buttonName = event.getSource().get("v.name")
        var action = cmp.get('c.removeContacts');
        action.setParams({ campaignId: campaignId, contactsId: contactsId});
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                if (buttonName == 'LWIP') {
                    cmp.set('v.dataLWIP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWIPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWIP', false);
                    }
                }
                if (buttonName == 'LWOIP') {
                    cmp.set('v.dataLWOIP', response.getReturnValue().contacts);
                    cmp.set('v.totalLLWOIPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWOIP', false);
                    }
                }
                if (buttonName == 'LWFP') {
                    cmp.set('v.dataLWFP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWFPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWFP', false);
                    }
                }
                if (buttonName == 'LWOFP') {
                    cmp.set('v.dataLWOFP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWOFPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWOFP', false);
                    }
                }
                if (buttonName == 'RP') {
                    cmp.set('v.dataRP', response.getReturnValue().contacts);
                    cmp.set('v.totalRPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showRP', false);
                    }
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The records have been removed successfully."
                });
                toastEvent.fire();
            } else {
                if (response.getReturnValue()) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Something wrong!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    addContacts: function (cmp, event, campaignId, contactsId) {
        var buttonName = event.getSource().get("v.name")
        var action = cmp.get('c.addToCampaign');
        action.setParams({ campaignId: campaignId, contactsId: contactsId });
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                if (buttonName == 'LWIP') {
                    cmp.set('v.dataLWIP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWIPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWIP', false);
                    }
                }
                if (buttonName == 'LWOIP') {
                    cmp.set('v.dataLWOIP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWOIPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWOIP', false);
                    }
                }
                if (buttonName == 'LWFP') {
                    cmp.set('v.dataLWFP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWFPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWFP', false);
                    }
                }
                if (buttonName == 'LWOFP') {
                    cmp.set('v.dataLWOFP', response.getReturnValue().contacts);
                    cmp.set('v.totalLWOFPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showLWOFP', false);
                    }
                }
                if (buttonName == 'RP') {
                    cmp.set('v.dataRP', response.getReturnValue().contacts);
                    cmp.set('v.totalRPRows', response.getReturnValue().totalRecords);
                    if (!response.getReturnValue().contacts.length) {
                        cmp.set('v.showRP', false);
                    }
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The records have been created successfully."
                });
                toastEvent.fire();
            } else {
                if (response.getReturnValue()) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Something wrong!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    upsertSettings: function (cmp, event, campaignId, publicationId, locationId, name, contactType, practiceArea, band) {
        var action = cmp.get('c.upsertCustomSettings');
        action.setParams({ campaignId: campaignId, publicationId: publicationId, locationId: locationId, name: name, contactType: contactType, practiceArea: practiceArea, band: band});
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                if (name == 'LWIP') {
                    cmp.set('v.showLWIP', false);
                    cmp.set('v.dataLWIPsize', '0');
                }
                if (name == 'LWOIP') {
                    cmp.set('v.showLWOIP', false);
                    cmp.set('v.dataLWOIPsize', '0');
                }
                if (name == 'LWFP') {
                    cmp.set('v.showLWFP', false);
                    cmp.set('v.dataLWFPsize', '0');
                }
                if (name == 'LWOFP') {
                    cmp.set('v.showLWOFP', false);
                    cmp.set('v.dataLWOFPsize', '0');
                }
                if (name == 'RP') {
                    cmp.set('v.showRP', false);
                    cmp.set('v.dataRPsize', '0');
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The records have been created successfully."
                });
                toastEvent.fire();
            } else {
                if (response.getReturnValue()) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getReturnValue().message
                    });
                    toastEvent.fire();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Something wrong!"
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },

    loadStatusClean: function (cmp) {
        var action = cmp.get('c.getSettings');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {

                cmp.set('v.LWIPBatch', response.getReturnValue().jobs['LWIPBatch']);
                cmp.set('v.LWOIPBatch', response.getReturnValue().jobs['LWOIPBatch']);
                cmp.set('v.LWFPBatch', response.getReturnValue().jobs['LWFPBatch']);
                cmp.set('v.LWOFPBatch', response.getReturnValue().jobs['LWOFPBatch']);
                cmp.set('v.RPBatch', response.getReturnValue().jobs['RPBatch']);

                if (!cmp.get('v.LWIPBatch') && !cmp.get('v.LWOIPBatch') &&
                    !cmp.get('v.LWFPBatch') && !cmp.get('v.LWOFPBatch') && !cmp.get('v.RPBatch')) {
                    window.clearInterval(cmp.get("v.win"));
                }
                let data = response.getReturnValue().settings;
                Object.keys(data).forEach(function (key) {
                    if (data[key].type === 'LWIP') {
                        cmp.set('v.dataLWIP', data[key].contacts);
                        cmp.set('v.dataLWIPsize', data[key].contacts.length);
                        cmp.set('v.totalLWIPRows', data[key].totalRecords);
                        if (data[key].contacts.length > 0) {
                            cmp.set('v.showLWIP', true);
                        }
                    }
                    if (data[key].type === 'LWOIP') {
                        cmp.set('v.dataLWOIP', data[key].contacts);
                        cmp.set('v.dataLWOIPsize', data[key].contacts.length);
                        cmp.set('v.totalLWOIPRows', data[key].totalRecords);
                        if (data[key].contacts.length > 0) {
                            cmp.set('v.showLWOIP', true);
                        }
                    }
                    if (data[key].type === 'LWFP') {
                        cmp.set('v.dataLWFP', data[key].contacts);
                        cmp.set('v.dataLWFPsize', data[key].contacts.length);
                        cmp.set('v.totalLWFPRows', data[key].totalRecords);
                        if (data[key].contacts.length > 0) {
                            cmp.set('v.showLWFP', true);
                        }
                    }
                    if (data[key].type === 'LWOFP') {
                        cmp.set('v.dataLWOFP', data[key].contacts);
                        cmp.set('v.dataLWOFPsize', data[key].contacts.length);
                        cmp.set('v.totalLWOFPRows', data[key].totalRecords);
                        if (data[key].contacts.length > 0) {
                            cmp.set('v.showLWOFP', true);
                        }
                    }
                    if (data[key].type === 'RP') {
                        cmp.set('v.dataRP', data[key].contacts);
                        cmp.set('v.dataRPsize', data[key].contacts.length);
                        cmp.set('v.totalRPRows', data[key].totalRecords);
                        if (data[key].contacts.length > 0) {
                            cmp.set('v.showRP', true);
                        }
                    }
                });
            }
        });
        $A.enqueueAction(action);
    },

    checkValue: function(value) {
        let allValues = Array.prototype.slice.call(arguments);
        allValues = allValues.slice(1);
        return !allValues.includes(value);
    },

    loadDataLWIP : function(cmp){
        return new Promise($A.getCallback(function(resolve){
            var limit = cmp.get("v.initialLWIPRows");
            var offset = cmp.get("v.currentLWIPCount");
            var totalRows = cmp.get("v.totaLWIPlRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
            var action = cmp.get("c.loadRecordsLWIP");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = cmp.get("v.currentLWIPCount");
                currentCount += cmp.get("v.initialLWIPRows");
                // set the current count with number of records loaded 
                cmp.set("v.currentLWIPCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    },

    loadDataLWOIP : function(cmp){
        return new Promise($A.getCallback(function(resolve){
            var limit = cmp.get("v.initialLWOIPRows");
            var offset = cmp.get("v.currentLWOIPCount");
            var totalRows = cmp.get("v.totalLWOIPlRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
            var action = cmp.get("c.loadRecordsLWOIP");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = cmp.get("v.currentLWOIPCount");
                currentCount += cmp.get("v.initialLWOIPRows");
                // set the current count with number of records loaded 
                cmp.set("v.currentLWOIPCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    },

    loadDataLWFP : function(cmp){
        return new Promise($A.getCallback(function(resolve){
            var limit = cmp.get("v.initialLWFPRows");
            var offset = cmp.get("v.currentLWFPCount");
            var totalRows = cmp.get("v.totalLWFPRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
            var action = cmp.get("c.loadRecordsLWFP");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = cmp.get("v.currentLWFPCount");
                currentCount += cmp.get("v.initialLWFPRows");
                // set the current count with number of records loaded 
                cmp.set("v.currentLWFPCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    },

    loadDataLWOFP : function(cmp){
        return new Promise($A.getCallback(function(resolve){
            var limit = cmp.get("v.initialLWOFPRows");
            var offset = cmp.get("v.currentLWOFPCount");
            var totalRows = cmp.get("v.totalLWOFPRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
            var action = cmp.get("c.loadRecordsLWOFP");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = cmp.get("v.currentLWOFPCount");
                currentCount += cmp.get("v.initialLWOFPRows");
                // set the current count with number of records loaded 
                cmp.set("v.currentLWOFPCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    },

    loadDataRP : function(cmp){
        return new Promise($A.getCallback(function(resolve){
            var limit = cmp.get("v.initialRPRows");
            var offset = cmp.get("v.currentRPCount");
            var totalRows = cmp.get("v.totaRPlRows");
            if(limit + offset > totalRows){
                limit = totalRows - offset;
            }
            var action = cmp.get("c.loadRecordsRP");
            action.setParams({
                "rowLimit" :  limit,
                "rowOffset" : offset
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                var newData = response.getReturnValue();
                resolve(newData);
                var currentCount = cmp.get("v.currentRPCount");
                currentCount += cmp.get("v.initialRPRows");
                // set the current count with number of records loaded 
                cmp.set("v.currentRPCount",currentCount);
            });
            $A.enqueueAction(action);
        }));
    }

});