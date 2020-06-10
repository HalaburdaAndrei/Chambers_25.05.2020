/**
 * Created by andrei on 08.06.20.
 */

public with sharing class SendaQuoteController {

    @AuraEnabled
    public static List<APXTConga4__Conga_Template__c> templates(){
        List<APXTConga4__Conga_Template__c> listTemplates = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c];
        return listTemplates;
    }

    @AuraEnabled
    public static List<ContentVersion> openPDF (String fileId){
        List<ContentVersion> filePDF = [SELECT ContentDocumentId
        FROM ContentVersion
        WHERE isLatest = true AND Id =: fileId LIMIT 1];
        return filePDF;
    }

    @AuraEnabled
    public static Contact conId (String recordId){
        Opportunity opportunityId = [SELECT Signer__c FROM Opportunity WHERE Id =: recordId LIMIT 1];
        Contact con = [SELECT Id, Name, Email
        FROM Contact
        WHERE Id =: opportunityId.Signer__c LIMIT 1];
        return con;
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
    public static String generateQuote(String templateId, String oppId, String quoteId){

        String sessionId = fetchUserSessionId();
        String serverURL = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/46.0/' + UserInfo.getOrganizationId();
        String templateCover = '&TemplateId='+templateId;
        String queryId = '&QueryId=[send]a0C1l00000bt6b8?pv0='+oppId+'~pv1='+quoteId;
        String mainParams = 'https://composer.congamerge.com/composer8/index.html'+
                '?sessionId='+ sessionId +
                '&serverUrl='+ EncodingUtil.urlEncode(serverURL, 'UTF-8') +
                '&id='+oppId;
        String endParams = '&SC0=1&SC1=SalesforceFile&FP0=1&DefaultPDF=1&APIMode=1';

        String finalURL = mainParams + templateCover + queryId + endParams;
//        String finalURL = mainParams + templateCover + endParams;

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

        return JSON.serialize(responseFinal.getBody());
    }

    @AuraEnabled
    public static String sendEmailwithPDF( String DocId, String subject, String body, Contact contactEmailTo, List<Contact> contactEmailCC){
String a = 'by';
        System.debug('contact >> ' + contactEmailTo);
        System.debug('body >> ' + body);
        String[] toAddresses = new String[]{};
        toAddresses.add(contactEmailTo.Email);

        String[] ccAddresses = new String[]{};
        if(contactEmailCC != null) {
            for (Contact con : contactEmailCC) {
                ccAddresses.add(con.Email);
            }
        }

                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{};
        List<ContentVersion> documents                  = [
                SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                FROM ContentVersion
                WHERE isLatest = true AND Id =: docId
        ];

        for (ContentVersion document: documents) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

            attachment.setBody(document.VersionData);
            attachment.setFileName(document.Title);

            attachments.add(attachment);
        }

        // Create an email message object
//        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        String[] toAddresses = new String[]{'andrey.goloburda@succraft.com'};
        mail.setToAddresses(toAddresses);
        if(ccAddresses != null){
            mail.setCcAddresses(ccAddresses);
        }
        mail.setSubject(subject);
        mail.setPlainTextBody(body == null?'hello': body);
        mail.setFileAttachments(attachments);
        // Pass this email message to the built-in sendEmail method
        // of the Messaging class
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});

//        allmsg.add(mail);
//        try {
//            Messaging.SendEmailResult[] resSend = Messaging.sendEmail(allmsg, false);
//            for (Messaging.SendEmailResult r : resSend) {
//                System.debug('***Mail Error:' + r.getErrors());
//                System.debug('***isSuccess:' + r.isSuccess());
//            }
//                        return json.serialize(resSend);
//        } catch (Exception e) {
//            System.debug(e.getMessage());
//                        return 'Failure: '+ e.getMessage();
//        }


        return a;
    }

    @AuraEnabled
    public static String createQuote( String recordId){
//        QuoteLineItem quoteLineItem = new QuoteLineItem();
        List<QuoteLineItem> quoteLineItemsList = new List<QuoteLineItem>();

        Opportunity opportunity = [SELECT Id, Name, Pricebook2Id FROM Opportunity WHERE Id =: recordId];
        List<OpportunityLineItem> oliList = [SELECT Id, Product2Id, PriceBookEntry.Product2Id, Quantity, Description, UnitPrice, PricebookEntryId, Discount FROM OpportunityLineItem WHERE OpportunityId =: opportunity.Id];

        Quote quote = new Quote();
        quote.Name = opportunity.Name + '-' + Date.today();
        quote.ExpirationDate = Date.today().addMonths(1);
        quote.OpportunityId = opportunity.Id;
        quote.Pricebook2Id = opportunity.Pricebook2Id;

        insert quote;

        for (OpportunityLineItem oli : oliList){
            QuoteLineItem quoteLineItem = new QuoteLineItem();
            quoteLineItem.QuoteId = quote.Id;
            quoteLineItem.Description = oli.Description;
            quoteLineItem.UnitPrice = oli.UnitPrice;
            quoteLineItem.Product2Id = oli.PriceBookEntry.Product2Id;
            quoteLineItem.Quantity = oli.Quantity;
            quoteLineItem.PricebookEntryId = oli.PricebookEntryId;
            quoteLineItem.Discount = oli.Discount;
            quoteLineItemsList.add(quoteLineItem);
        }
        insert quoteLineItemsList;

        return quote.Id;
    }

}