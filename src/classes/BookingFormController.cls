public with sharing class BookingFormController {

    public static String fetchUserSessionId() {
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent;
        if (Test.isRunningTest()) {
            vfContent = 'Start_Of_Session_IdSESSION_ID_REMOVEDEnd_Of_Session_Id';
        } else {
            vfContent = reportPage.getContent().toString();

        }
        System.debug('vfContent ' + vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP, endP;
        startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
        endP = vfContent.indexOf('End_Of_Session_Id');
//        }
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);

        // Return Session Id
        return sessionId;
    }

    @AuraEnabled
    public static String openUrl(String recordId){
        String finalURL;
        Integer transactionSent = 0;
        List<APXT_CongaSign__Transaction__c> congaTransaction = [SELECT Id, APXT_CongaSign__Status__c FROM APXT_CongaSign__Transaction__c WHERE Parent_006__c =: recordId];
        Opportunity opportunity = [SELECT Id, Name, Signer__c, Signer__r.Name, Publication_RE__c, Book_Expiration_Date__c, Booking_Form_Reminder__c, Publication_RE__r.Name FROM Opportunity WHERE Id = :recordId];
        APXTConga4__Conga_Merge_Query__c mergeQueryId = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c = 'Booking Form Query' AND APXTConga4__Description__c = 'Booking Form Query from Opportunity Line Items and Opportunity records.'];
        String qId = mergeQueryId != null ? mergeQueryId.Id : null;

        if(!congaTransaction.isEmpty()) {
            for (APXT_CongaSign__Transaction__c trans : congaTransaction) {
                if (trans.APXT_CongaSign__Status__c == 'SENT') {
                    transactionSent++;

                }
            }
        }
        if(transactionSent == 0){
            String sessionId = fetchUserSessionId();
            String serverURL = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/46.0/' + UserInfo.getOrganizationId();
            String templateCover = '&TemplateId=a0K1t000005SDbFEAW';
            String query;
            if(qId != null){
                query = '&QueryId=[BookingFormQuery]'+qId;
            }else{
                query = '';
            }
            String mainParams = 'https://composer.congamerge.com/composer8/index.html' +
                    '?sessionId=' + sessionId +
                    '&serverUrl=' + EncodingUtil.urlEncode(serverURL, 'UTF-8') +
                    '&id=' + recordId;
            String endParams = '&LRTF=1&DefaultPDF=1&AC0=1&AC1=Follow+up+' + opportunity.Name + '&AC3=3&LiveEditVisible=0&LiveEditEnable=0&csvisible=1&CSRecipient1=' + opportunity.Signer__c +
                    '&CSEmailSubject=Chambers+' + opportunity.Publication_RE__r.Name + '+Booking+Form+for+signature' +
                    '&csEmailMessage=Hello, ' + opportunity.Signer__r.Name + ', in reference to our conversation a short while ago, please find attached the booking form as detailed. You can you now confirm your inclusion by clicking the Begin Signing button. If you require anything further just let me know and I look forward to hearing back from you.' +
                    '&csExpiration=' + opportunity.Book_Expiration_Date__c + '&csExpirationReminder=' + opportunity.Booking_Form_Reminder__c;

            finalURL = mainParams + query + templateCover + endParams;
//            finalURL = mainParams + query + endParams;
        }else{
            finalURL = 'no';

        }
        return finalURL;
    }

}