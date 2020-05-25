({
    init: function (cmp, event, helper) {
        var action = cmp.get('c.getSettings');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set("v.publications", response.getReturnValue().publications);
                cmp.set("v.campaigns", response.getReturnValue().campaigns);
                cmp.set("v.locations", response.getReturnValue().locations);

                let data = response.getReturnValue().settings;
                Object.keys(data).forEach(function (key) {
                    if (data[key].type === 'LWIP') {
                        cmp.set('v.dataLWIP', data[key].contacts);
                        cmp.set('v.campaignIdLWIP', data[key].campaignId);
                        cmp.set('v.dataLWIPsize', data[key].contacts.length);
                        cmp.set('v.publicationLWIP', data[key].publicationId);
                    }
                    if (data[key].type === 'LWOIP') {
                        cmp.set('v.dataLWOIP', data[key].contacts);
                        cmp.set('v.campaignIdLWOIP', data[key].campaignId);
                        cmp.set('v.dataLWOIPsize', data[key].contacts.length);
                        cmp.set('v.publicationLWOIP', data[key].publicationId);
                    }
                    if (data[key].type === 'LWFP') {
                        cmp.set('v.dataLWFP', data[key].contacts);
                        cmp.set('v.campaignIdLWFP', data[key].campaignId);
                        cmp.set('v.dataLWFPsize', data[key].contacts.length);
                        cmp.set('v.publicationLWFP', data[key].publicationId);
                        cmp.set('v.contactTypeLWFP', data[key].contactType);
                    }
                    if (data[key].type === 'LWOFP') {
                        cmp.set('v.dataLWOFP', data[key].contacts);
                        cmp.set('v.campaignIdLWOFP', data[key].campaignId);
                        cmp.set('v.dataLWOFPsize', data[key].contacts.length);
                        cmp.set('v.publicationLWOFP', data[key].publicationId);
                        cmp.set('v.contactTypeLWOFP', data[key].contactType);
                    }
                    if (data[key].type === 'RP') {
                        cmp.set('v.dataRP', data[key].contacts);
                        cmp.set('v.campaignIdRP', data[key].campaignId);
                        cmp.set('v.dataRPsize', data[key].contacts.length);
                        cmp.set('v.publicationRP', data[key].publicationId);
                        cmp.set('v.locationIdRP', data[key].locationId);
                        cmp.set('v.practiceAreaRP', data[key].practiceArea);
                        cmp.set('v.bandRP', JSON.parse(data[key].band));
                    }
                });

                let lwip = cmp.get('v.dataLWIP');
                if (lwip && Array.isArray(lwip) && JSON.stringify(lwip) != '[]') {
                    cmp.set('v.showLWIP', true);
                } else {
                    cmp.set('v.showLWIP', false);
                    cmp.set('v.dataLWIPsize', '0');
                }

                let lwoip = cmp.get('v.dataLWOIP');
                if (lwoip && Array.isArray(lwoip) && JSON.stringify(lwoip) != '[]') {
                    cmp.set('v.showLWOIP', true);
                } else {
                    cmp.set('v.showLWOIP', false);
                    cmp.set('v.dataLWOIPsize', '0');
                }

                let lwfp = cmp.get('v.dataLWFP');
                if (lwfp && Array.isArray(lwfp) && JSON.stringify(lwfp) != '[]') {
                    cmp.set('v.showLWFP', true);
                } else {
                    cmp.set('v.showLWFP', false);
                    cmp.set('v.dataLWFPsize', '0');
                }

                let lwofp = cmp.get('v.dataLWOFP');
                if (lwofp && Array.isArray(lwofp) && JSON.stringify(lwofp) != '[]') {
                    cmp.set('v.showLWOFP', true);
                } else {
                    cmp.set('v.showLWOFP', false);
                    cmp.set('v.dataLWOFPsize', '0');
                }

                let rp = cmp.get('v.dataRP');
                if (rp && Array.isArray(rp) && JSON.stringify(rp) != '[]') {
                    cmp.set('v.showRP', true);
                } else {
                    cmp.set('v.showRP', false);
                    cmp.set('v.dataRPsize', '0');
                }

                cmp.set('v.LWIPBatch', response.getReturnValue().jobs['LWIPBatch']);
                cmp.set('v.LWOIPBatch', response.getReturnValue().jobs['LWOIPBatch']);
                cmp.set('v.LWFPBatch', response.getReturnValue().jobs['LWFPBatch']);
                cmp.set('v.LWOFPBatch', response.getReturnValue().jobs['LWOFPBatch']);
                cmp.set('v.RPBatch', response.getReturnValue().jobs['RPBatch']);

                if (cmp.get('v.LWIPBatch') || cmp.get('v.LWOIPBatch') ||
                    cmp.get('v.LWFPBatch') || cmp.get('v.LWOFPBatch') || cmp.get('v.RPBatch')) {
                        var interval = window.setInterval(
                            $A.getCallback(function () {
                                helper.loadStatusClean(cmp);
                            }), 5000
                        );
                        cmp.set("v.win", interval);                    
                }

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
            cmp.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);

    },

    handleClickRemoveLWIP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWIP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWIP');
        if (campaignId) {
            helper.removeContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWIP', []);
        }
    },

    handleClickRemoveLWOIP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWOIP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWOIP');
        if (campaignId) {
            helper.removeContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWOIP', []);
        }
    },

    handleClickRemoveLWFP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWFP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWFP');
        if (campaignId) {
            helper.removeContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWFP', []);
        }
    },

    handleClickRemoveLWOFP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWOFP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWOFP');
        if (campaignId) {
            helper.removeContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWOFP', []);
        }
    },

    handleClickRemoveRP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableRP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdRP');
        if (campaignId) {
            helper.removeContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsRP', []);
        }
    },

    handleClickLWIP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWIP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWIP');
        if (campaignId) {
            helper.addContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWIP', []);
        }
    },

    handleClickLWOIP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWOIP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWOIP');
        if (campaignId) {
            helper.addContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWOIP', []);
        }
    },

    handleClickLWFP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWFP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWFP');
        if (campaignId) {
            helper.addContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWFP', []);
        }
    },

    handleClickLWOFP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableLWOFP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdLWOFP');
        if (campaignId) {
            helper.addContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsLWOFP', []);
        }
    },

    handleClickRP: function (cmp, event, helper) {
        let listId = [];
        let lines = cmp.find('tableRP').getSelectedRows();
        lines.forEach(function (element) {
            listId.push(element.Id);
        });

        let campaignId = cmp.get('v.campaignIdRP');
        if (campaignId) {
            helper.addContacts(cmp, event, campaignId, listId);
            cmp.set('v.selectedRowsRP', []);
        }
    },

    handleClickSaveLWIP: function (cmp, event, helper) {
        let campaignId = cmp.get('v.campaignIdLWIP');
        let publicationId = cmp.get('v.publicationLWIP');
        let campaignIdLWOIP = cmp.get('v.campaignIdLWOIP');
        let campaignIdLWFP = cmp.get('v.campaignIdLWFP');
        let campaignIdLWOFP = cmp.get('v.campaignIdLWOFP');
        let campaignIdRP = cmp.get('v.campaignIdRP');
        if (campaignId) {
            let isValid = helper.checkValue(campaignId, campaignIdLWOIP, campaignIdLWFP, campaignIdLWOFP, campaignIdRP);
            if (isValid) {
                helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWIP', null, null, null);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "This campaign is already in use."
                });
                toastEvent.fire();
            }
        } else {
            helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWIP', null, null, null);
        }
    },

    handleClickSaveLWOIP: function (cmp, event, helper) {
        let campaignId = cmp.get('v.campaignIdLWOIP');
        let publicationId = cmp.get('v.publicationLWOIP');
        let campaignIdLWIP = cmp.get('v.campaignIdLWIP');
        let campaignIdLWFP = cmp.get('v.campaignIdLWFP');
        let campaignIdLWOFP = cmp.get('v.campaignIdLWOFP');
        let campaignIdRP = cmp.get('v.campaignIdRP');
        if (campaignId) {
            let isValid = helper.checkValue(campaignId, campaignIdLWIP, campaignIdLWFP, campaignIdLWOFP, campaignIdRP);
            if (isValid) {
                helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWOIP', null, null, null);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "This campaign is already in use."
                });
                toastEvent.fire();
            }
        } else {
            helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWOIP', null, null, null);
        }
    },

    handleClickSaveLWFP: function (cmp, event, helper) {
        let campaignId = cmp.get('v.campaignIdLWFP');
        let publicationId = cmp.get('v.publicationLWFP');
        let contactTypeLWFP = cmp.get('v.contactTypeLWFP');
        let campaignIdLWIP = cmp.get('v.campaignIdLWIP');
        let campaignIdLWOIP = cmp.get('v.campaignIdLWOIP');
        let campaignIdLWOFP = cmp.get('v.campaignIdLWOFP');
        let campaignIdRP = cmp.get('v.campaignIdRP');
        if (campaignId) {
            let isValid = helper.checkValue(campaignId, campaignIdLWIP, campaignIdLWOIP, campaignIdLWOFP, campaignIdRP);
            if (isValid) {
                helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWFP', contactTypeLWFP, null, null);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "This campaign is already in use."
                });
                toastEvent.fire();
            }
        } else {
            helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWFP', contactTypeLWFP, null, null);
        }
    },

    handleClickSaveLWOFP: function (cmp, event, helper) {
        let campaignId = cmp.get('v.campaignIdLWOFP');
        let publicationId = cmp.get('v.publicationLWOFP');
        let contactTypeLWOFP = cmp.get('v.contactTypeLWOFP');
        let campaignIdLWIP = cmp.get('v.campaignIdLWIP');
        let campaignIdLWOIP = cmp.get('v.campaignIdLWOIP');
        let campaignIdLWFP = cmp.get('v.campaignIdLWFP');
        let campaignIdRP = cmp.get('v.campaignIdRP');
        if (campaignId) {
            let isValid = helper.checkValue(campaignId, campaignIdLWIP, campaignIdLWOIP, campaignIdLWFP, campaignIdRP);
            if (isValid) {
                helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWOFP', contactTypeLWOFP, null, null);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "This campaign is already in use."
                });
                toastEvent.fire();
            }
        } else {
            helper.upsertSettings(cmp, event, campaignId, publicationId, null, 'LWOFP', contactTypeLWOFP, null, null);
        }
    },

    handleClickSaveRP: function (cmp, event, helper) {
        let campaignId = cmp.get('v.campaignIdRP');
        let publicationId = cmp.get('v.publicationRP');
        let locationId = cmp.get('v.locationIdRP');
        let practiceArea = cmp.get('v.practiceAreaRP');
        let band = JSON.stringify(cmp.get('v.bandRP'));
        let campaignIdLWIP = cmp.get('v.campaignIdLWIP');
        let campaignIdLWOIP = cmp.get('v.campaignIdLWOIP');
        let campaignIdLWFP = cmp.get('v.campaignIdLWFP');
        let campaignIdLWOFP = cmp.get('v.campaignIdLWOFP');
        if (campaignId) {
            let isValid = helper.checkValue(campaignId, campaignIdLWIP, campaignIdLWOIP, campaignIdLWFP, campaignIdLWOFP);
            if (isValid) {
                helper.upsertSettings(cmp, event, campaignId, publicationId, locationId, 'RP', null, practiceArea, band);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type": "warning",
                    "message": "This campaign is already in use."
                });
                toastEvent.fire();
            }
        } else {
            helper.upsertSettings(cmp, event, campaignId, publicationId, locationId, 'RP', null, practiceArea, band);
        }
    },

    runLWIPBatch: function (cmp, event, helper) {
        var action = cmp.get('c.LWIPBatch');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set('v.LWIPBatch', true);
                var interval = window.setInterval(
                    $A.getCallback(function () {
                        helper.loadStatusClean(cmp);
                    }), 5000
                );
                cmp.set("v.win", interval);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Batch launched successfully."
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

    runLWOIPBatch: function (cmp, event, helper) {
        var action = cmp.get('c.LWOIPBatch');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set('v.LWOIPBatch', true);
                var interval = window.setInterval(
                    $A.getCallback(function () {
                        helper.loadStatusClean(cmp);
                    }), 5000
                );
                cmp.set("v.win", interval);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Batch launched successfully."
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

    runLWFPBatch: function (cmp, event, helper) {
        var action = cmp.get('c.LWFPBatch');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set('v.LWFPBatch', true);
                var interval = window.setInterval(
                    $A.getCallback(function () {
                        helper.loadStatusClean(cmp);
                    }), 5000
                );
                cmp.set("v.win", interval);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Batch launched successfully."
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

    runLWOFPBatch: function (cmp, event, helper) {
        var action = cmp.get('c.LWOFPBatch');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set('v.LWOFPBatch', true);
                var interval = window.setInterval(
                    $A.getCallback(function () {
                        helper.loadStatusClean(cmp);
                    }), 5000
                );
                cmp.set("v.win", interval);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Batch launched successfully."
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

    runRPBatch: function (cmp, event, helper) {
        var action = cmp.get('c.RPBatch');
        action.setCallback(this, function (response) {
            if (cmp.isValid() && response.getState() == 'SUCCESS' && response.getReturnValue().status != 'error') {
                cmp.set('v.RPBatch', true);
                var interval = window.setInterval(
                    $A.getCallback(function () {
                        helper.loadStatusClean(cmp);
                    }), 5000
                );
                cmp.set("v.win", interval);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Batch launched successfully."
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

    clearInterval: function (cmp, event) {
        window.clearInterval(cmp.get("v.win"));
    }

});