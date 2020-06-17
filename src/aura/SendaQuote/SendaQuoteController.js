({
    doInit: function (component, event, helper) {
        console.log('recordIc >>> ' + component.get("v.recordId"));
        // console.log('doInit contact >>> ' + component.get("v.selectedLookUpContact"));
        // console.log('CLOSE WINDOW >>> ' + component.find("Close this window"));

        var action = component.get("c.checkStage");
        action.setParams({recordId: component.get("v.recordId")});
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue().StageName === 'Qualified') {
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Warning!",
                        "message": "Sorry you can't generate a Quota in the Qualified stage!"
                    });
                    toastEvent.fire();
                } else {
                    helper.selectContact(component, event, helper);
                    helper.templateList(component, event, helper);
                    helper.getSubjectAndBody(component, event, helper);
                }
            }

        });
        $A.enqueueAction(action);


    },

    onchangeSelectedTemplate: function (component, event, helper) {
        console.log(component.get("v.selectedTemplate"));
    },

    generated: function (component, event, helper) {
        console.log(component.get("v.selectedTemplate"));

        component.set('v.loaded', !component.get('v.loaded'));

        var creQuote = component.get("c.createQuote");
        creQuote.setParams({recordId: component.get("v.recordId")});
        creQuote.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === 'SUCCESS') {
                console.log(response.getReturnValue());
                component.set("v.quoteId", response.getReturnValue());

                var action = component.get("c.generateQuote");
                action.setParams({
                    templateId: component.get("v.selectedTemplate"),
                    oppId: component.get("v.recordId"),
                    quoteId: component.get("v.quoteId")
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if ((state === 'SUCCESS' || state === 'DRAFT') && component.isValid()) {
                        // get the response
                        var responseValue = response.getReturnValue();
                        // Parse the respose
                        var responseData = JSON.parse(responseValue);
                        if (responseData !== 'error: Failed during the merge process.'
                            && ((responseData.split('').length === 18 || responseData.split('').length === 15)
                                && responseData.slice(0, 3) === '068')) {
                            component.set("v.generatedPDF", responseData);
                            component.set('v.loaded', !component.get('v.loaded'));
                            component.set('v.showSendEmail', true);


                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "The quota was generated successfully!",
                                "type": "success"
                            });
                            toastEvent.fire();
                            console.log(responseData);


                            var filePDF = component.get("c.openPDF");
                            filePDF.setParams({fileId: component.get("v.generatedPDF")});
                            filePDF.setCallback(this, function (response) {
                                var state = response.getState();
                                if (state === 'SUCCESS') {
                                    console.log(response.getReturnValue()[0].ContentDocumentId);
                                    console.log(JSON.stringify(response.getReturnValue()[0].ContentDocumentId));
                                    component.set("v.filePDFOpen", response.getReturnValue()[0].ContentDocumentId);
                                }else {

                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "message": "The File was not generated!",
                                        "type": "error"
                                    });
                                    toastEvent.fire();
                                }
                            });
                            $A.enqueueAction(filePDF);

                        } else {
                            component.set('v.loaded', !component.get('v.loaded'));

                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "The Quota was not generated!",
                                "type": "error"
                            });
                            toastEvent.fire();
                        }
                    } else if (state === 'INCOMPLETE') {
                        console.log("User is offline, device doesn't support drafts.");
                    } else if (state === 'ERROR') {
                        console.log('Problem saving record, error: ' +
                            JSON.stringify(response.getError()));
                    } else {
                        console.log('Unknown problem, state: ' + state +
                            ', error: ' + JSON.stringify(response.getError()));
                    }
                });
// send the action to the server which will call the apex and will return the response
                $A.enqueueAction(action);
            }else {
                component.set('v.loaded', !component.get('v.loaded'));

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "The Quota was not generated!",
                    "type": "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(creQuote);

    },

    openSingleFile: function (component, event, helper) {
        console.log('Contact >>> ' + JSON.stringify(component.get("v.selectedLookUpRecords")));
        var id = component.get("v.filePDFOpen");

        if (id != null) {
            $A.get('e.lightning:openFiles').fire({
                recordIds: [id]
            });
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "message": "The file is not generated!",
                "type": "warning"
            });
            toastEvent.fire();

        }
    },

    handleOpenFiles: function (component, event, helper) {
    },

    sendEmail: function (component, event, helper) {

        var toastEvent = $A.get("e.force:showToast");

        if (component.get("v.selectedLookUpContact").Email != null) {
            if (component.get("v.generatedPDF") != null) {
                var email = component.get("c.sendEmailwithPDF");
                email.setParams({
                    DocId: component.get("v.generatedPDF"),
                    body: component.get("v.body"),
                    subject: component.get("v.subject"),
                    contactEmailTo: component.get("v.selectedLookUpContact"),
                    contactEmailCC: component.get("v.selectedLookUpRecords")
                });
                email.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        console.log(JSON.stringify(response.getReturnValue()));
                        var dismissActionPanel = $A.get("e.force:closeQuickAction");
                        dismissActionPanel.fire();
                        // var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": "The email was sent successfully!",
                            "type": "success"
                        });
                        toastEvent.fire();
                    } else {
                        console.log(JSON.stringify(response.getError()));

                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "The email was not sent!",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(email);
            } else {
                toastEvent.setParams({
                    "title": "Warning!",
                    "message": "The PDF file is not attached to the email, generate a quota!",
                    "type": "warning"
                });
                toastEvent.fire();
            }
        } else {
            toastEvent.setParams({
                "title": "Warning!",
                "message": "This contact( " + component.get("v.selectedLookUpContact").Name + " ) does not have an email address!",
                "type": "warning"
            });
            toastEvent.fire();
        }
    },

    cancel: function (component, event, helper) {

        if ((component.get("v.quoteId") != null || component.get("v.filePDFOpen") != null)) {
            var action = component.get("c.deleteQuote");
            action.setParams({
                quoteId: component.get("v.quoteId"),
                fileId: component.get("v.filePDFOpen")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    console.log('QUOTE DELETE!!!');
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
            });
            $A.enqueueAction(action);
        } else {
            console.log('Quotas were not found, and the component is closed.');
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();
        }

        // var dismissActionPanel = $A.get("e.force:closeQuickAction");
        // dismissActionPanel.fire();
    }

})