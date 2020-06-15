/**
 * Created by novab on 15.05.2020.
 */
public class testButtonController {

    @AuraEnabled
    public static List<APXTConga4__Conga_Template__c> templates(){
        List<APXTConga4__Conga_Template__c> listTemplates = [SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Template__c];
        return listTemplates;
    }

    public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
    }

    @AuraEnabled
    public static String saveTemplate(){
//        BatchCallOut batchapex = new BatchCallOut();
//        id batchprocessid = Database.executebatch(batchapex,1);
//        system.debug('Process ID: ' + batchprocessid);
//        system.debug( batchapex);


        String sessionId = fetchUserSessionId();
        String serverURL = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/46.0/' + UserInfo.getOrganizationId();
        String templateCover = '&TemplateId=a0K1t000005SDcr';
//        String templateFooter = '&TemplateId=0693X0000084fPZQAY';
        String mainParams = 'https://composer.congamerge.com/composer8/index.html'+
                '?sessionId='+ sessionId +
                '&serverUrl='+ EncodingUtil.urlEncode(serverURL, 'UTF-8') +
                '&id=0061l00000JmP6gAAF';
        String endParams = '&SC0=1&SC1=SalesforceFile&FP0=1&DefaultPDF=1&APIMode=1';

        String finalURL = mainParams + templateCover + endParams;

        Http httpFinal = new Http();
        HttpRequest requestFinal = new HttpRequest();
        requestFinal.setEndpoint(finalURL);
        requestFinal.setMethod('GET');
        requestFinal.setTimeout(120000);

        HttpResponse responseFinal = httpFinal.send(requestFinal);

        System.debug(responseFinal.getBody());
        System.debug(responseFinal);
        System.debug(finalURL);
        System.debug(UserInfo.getSessionId());

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        List<ContentVersion> documents                  = [
                SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                FROM ContentVersion
                WHERE isLatest = true AND Id =: responseFinal.getBody()
        ];

//        documents.addAll([
//                SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
//                FROM ContentVersion
//                WHERE isLatest = true AND Id IN : responseFinal.getBody()
//        ]);

        for (ContentVersion document: documents) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

            attachment.setBody(document.VersionData);
            attachment.setFileName(document.Title);
//            attachment.setContentType(document.FileType);

            attachments.add(attachment);
        }

        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{'eugene.pahuschi@succraft.com'};
//        mail.setWhatId('0061l00000JmP6gAAF');
        mail.setToAddresses(toAddresses);
        mail.setSubject('test subject');
        mail.setPlainTextBody('body');
        mail.setFileAttachments(attachments);
        // Pass this email message to the built-in sendEmail method
        // of the Messaging class
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
//        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
//        system.debug(JSON.serialize(results));


//        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        String[] toAddresses = new String[] {'andrey.goloburda@succraft.com'};
//        mail.setToAddresses(toAddresses);
//        mail.setReplyTo('andrey.goloburda@succraft.com');
//        mail.setSenderDisplayName('Name');
//        mail.setSubject('Testing email through apex');
//        mail.setBccSender(false);
//        mail.setUseSignature(true);
//        mail.setPlainTextBody('test');
//
//
//        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
//        for (ContentVersion document: documents) {
//            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
//
//            attachment.setBody(document.VersionData);
//            attachment.setFileName(document.Title);
//        attachment.setContentType(document.FileType);
//
//            fileAttachments.add(attachment);
//        }
//        mail.setFileAttachments(fileAttachments);
//
//        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });


         return JSON.serialize(responseFinal.getBody());
    }


}