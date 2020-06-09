/**
 * Created by andrei on 08.06.20.
 */
({
    doInit: function (component, event, helper) {
console.log('recordIc >>> ' + component.get("v.recordId"));
        var contact = component.get("c.conId");
        contact.setParams({recordId : component.get("v.recordId")});
        contact.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                component.set("v.selectedLookUpContact", response.getReturnValue());
            }
        });
        $A.enqueueAction(contact);

        var templates = component.get("c.templates");
        templates.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(JSON.stringify(response.getReturnValue()));
                component.set("v.listTemplates", response.getReturnValue());
            }
        });
        $A.enqueueAction(templates);
    },

    onchangeSelectedTemplate : function (component, event, helper) {
        console.log(component.get("v.selectedTemplate"));
        // var templates = component.get("c.templates");
        // templates.setCallback(this, function (response) {
        //     var state = response.getState();
        //     console.log(state);
        //     if (state === "SUCCESS") {
        //         console.log(JSON.stringify(response.getReturnValue()));
        //         component.set("v.listTemplates", response.getReturnValue());
        //     }
        // });
        // $A.enqueueAction(templates);
    },

    generated : function (component, event, helper) {
        console.log(component.get("v.selectedTemplate"));

        component.set('v.loaded', !component.get('v.loaded'));


        var action = component.get("c.generateQuote");
        action.setParams({templateId: component.get("v.selectedTemplate")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
// get the response
                var responseValue = response.getReturnValue();
// Parse the respose
                var responseData = JSON.parse(responseValue);
                component.set("v.generatedPDF", responseData);

                component.set('v.loaded', !component.get('v.loaded'));

                alert(responseData);
//alert(responseData.totalSize);
                console.log(responseData);
                var filePDF = component.get("c.openPDF");
                filePDF.setParams({fileId : component.get("v.generatedPDF")});
                filePDF.setCallback(this, function (response) {
                    var state = response.getState();
                    if(state === 'SUCCESS'){
                        console.log(response.getReturnValue()[0].ContentDocumentId);
                        console.log(JSON.stringify(response.getReturnValue()[0].ContentDocumentId));
                        component.set("v.filePDFOpen", response.getReturnValue()[0].ContentDocumentId);
                    }
                });
                $A.enqueueAction(filePDF);
            } else if( state === 'INCOMPLETE'){
                console.log("User is offline, device doesn't support drafts.");
            } else if( state === 'ERROR'){
                console.log('Problem saving record, error: ' +
                    JSON.stringify(response.getError()));
            } else{
                console.log('Unknown problem, state: ' + state +
                    ', error: ' + JSON.stringify(response.getError()));
            }
        });
// send the action to the server which will call the apex and will return the response
        $A.enqueueAction(action);

    },

    openSingleFile: function(component, event, helper) {
        console.log('Contact >>> ' + JSON.stringify(component.get("v.selectedLookUpRecords")));
        var id = component.get("v.filePDFOpen");

        $A.get('e.lightning:openFiles').fire({
            recordIds: [id]
        });
    },

    handleOpenFiles: function(component, event, helper) {
        // alert('Opening files: ' + event.getParam('recordIds').join(', ')
        //     + ', selected file is ' + event.getParam('selectedRecordId'));
    },

    sendEmail: function(component, event, helper){
console.log('123');
        var email = component.get("c.sendEmailwithPDF");
        email.setParams({
            DocId : component.get("v.generatedPDF"),
            body : component.get("v.body"),
            subject : component.get("v.subject"),
            contactsList : component.get("v.selectedLookUpRecords")
        });
        email.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === "SUCCESS"){
               console.log(JSON.stringify(response.getReturnValue()));
           }
        });
        $A.enqueueAction(email);
    },

})