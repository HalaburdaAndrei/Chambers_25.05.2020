/**
 * Created by andrei on 14.04.20.
 */
({
    doInit: function (component, event, helper) {
        var templates = component.get("c.templates");
        templates.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.templates", response.getReturnValue());
            }
        });
        $A.enqueueAction(templates);
    },
    save : function (component, event, helper) {
        // var url = '/apex/APXTConga4__Conga_Composer?SolMgr=1\n' +
        //     '&serverUrl={!API.Partner_Server_URL_370}\n' +
        //     '&Id=0061l00000JmP6gAAF\n' +
        //     '\n' +
        //     '&QueryId=[BookingFormQuery]a0C1t000005jkh1\n' +
        //     '\n' +
        //     '&TemplateId=a0K1t000005SDcr\n' +
        //     '\n' +
        //     '&DefaultPDF=1\n' +
        //     '&DS7=1\n' +
        //     '&SC0=1\n' +
        //     '&SC1=SalesforceFile';
        // window.open(url);


        var action = component.get("c.saveTemplate");
        action.setCallback(this, function(response){
            var state = response.getState();
            if( (state === 'SUCCESS' || state ==='DRAFT') && component.isValid()){
// get the response
                var responseValue = response.getReturnValue();
// Parse the respose
                var responseData = JSON.parse(responseValue);
                alert(responseData);
//alert(responseData.totalSize);
                console.log(responseData);
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


        // $A.enqueueAction(url);
    },

    openSingleFile: function(cmp, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: ['0691l000000tLhLAAU']
        });
    },
    openMultipleFiles: function(cmp, event, helper) {
        $A.get('e.lightning:openFiles').fire({
            recordIds: ['fileid0', 'fileid1', 'fileid2'],
            selectedRecordId: 'fileid1'
        });
    },
    handleOpenFiles: function(cmp, event, helper) {
        // alert('Opening files: ' + event.getParam('recordIds').join(', ')
        //     + ', selected file is ' + event.getParam('selectedRecordId'));
    }



})