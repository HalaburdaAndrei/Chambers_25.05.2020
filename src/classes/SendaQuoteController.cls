public class SendaQuoteController {

    @AuraEnabled
    public static Opportunity checkStage(String recordId) {
        Opportunity oppStage = [SELECT StageName FROM Opportunity WHERE Id = :recordId];
        return oppStage;
    }

    @AuraEnabled
    public static List<APXTConga4__Conga_Template__c> templates() {
        List<APXTConga4__Conga_Template__c> listTemplates = [SELECT Id, APXTConga4__Name__c FROM APXTConga4__Conga_Template__c WHERE APXTConga4__Template_Group__c = 'Quotation'];
        return listTemplates;
    }

    @AuraEnabled
    public static List<ContentVersion> openPDF(String fileId) {
        List<ContentVersion> filePDF = [
                SELECT ContentDocumentId
                FROM ContentVersion
                WHERE isLatest = true AND Id = :fileId
                LIMIT 1
        ];
        return filePDF;
    }

    @AuraEnabled
    public static Contact conId(String recordId) {

        try {
            Contact con = [
                    SELECT Id, Name, Email
                    FROM Contact
                    WHERE Id IN (SELECT Signer__c FROM Opportunity WHERE Id = :recordId)
                    LIMIT 1
            ];
            return con;

        } catch (Exception e) {
            return null;
        }
    }

    @AuraEnabled
    public static Template_Subject_and_Body__mdt getSubjectAndBody() {
        Template_Subject_and_Body__mdt subjectAndBody = [SELECT Body__c, Subject__c FROM Template_Subject_and_Body__mdt WHERE Label = 'subject and body'];
        return subjectAndBody;
    }

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
    public static String generateQuote(String templateId, String oppId, String quoteId) {

        APXTConga4__Conga_Merge_Query__c mergeQueryId = [SELECT Id FROM APXTConga4__Conga_Merge_Query__c WHERE APXTConga4__Name__c = 'Send a Quote' AND APXTConga4__Description__c = 'Send a Quote'];
        String qId = mergeQueryId.Id;
        String sessionId;
        sessionId = fetchUserSessionId();

        String serverURL = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/46.0/' + UserInfo.getOrganizationId();
        String templateCover = '&TemplateId=' + templateId;
        String queryId = '&QueryId=[send]'+ qId +'?pv0=' + oppId + '~pv1=' + quoteId;
        String mainParams = 'https://composer.congamerge.com/composer8/index.html' +
                '?sessionId=' + sessionId +
                '&serverUrl=' + EncodingUtil.urlEncode(serverURL, 'UTF-8') +
                '&id=' + oppId;
        String endParams = '&SC0=1&SC1=SalesforceFile&FP0=1&DefaultPDF=1&APIMode=1';

        String finalURL = mainParams + templateCover + queryId + endParams;

        Http httpFinal = new Http();
        HttpRequest requestFinal = new HttpRequest();
        requestFinal.setEndpoint(finalURL);
        requestFinal.setMethod('GET');
        requestFinal.setTimeout(120000);

        HttpResponse responseFinal = httpFinal.send(requestFinal);
        return JSON.serialize(responseFinal.getBody());
    }

    @AuraEnabled
    public static String sendEmailwithPDF(String DocId, String subject, String body, Contact contactEmailTo, List<Contact> contactEmailCC, String quoteId) {
        String a = 'Ok, email send.';

        String[] toAddresses = new String[]{
        };
        toAddresses.add(contactEmailTo.Email);

        String[] ccAddresses = new String[]{
        };
        if (contactEmailCC != null) {
            for (Contact con : contactEmailCC) {
                if (con.Email != null) {
                    ccAddresses.add(con.Email);
                }
            }
        }

        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>{
        };
        List<ContentVersion> documents = [
                SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId
                FROM ContentVersion
                WHERE isLatest = true AND Id = :docId
        ];

        for (ContentVersion document : documents) {
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();

            attachment.setBody(document.VersionData);
            attachment.setFileName(document.Title);

            attachments.add(attachment);
        }

        // Create an email message object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        if (ccAddresses != null) {
            mail.setCcAddresses(ccAddresses);
        }
        mail.setSubject(subject);
        mail.setPlainTextBody(body == null ? 'hello' : body);
        mail.setFileAttachments(attachments);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });

        if (quoteId != null) {
            Quote quote = [SELECT Id, Status FROM Quote WHERE Id = :quoteId];
            quote.Status = 'Sent';
            update quote;
        }

        return a;
    }

    @AuraEnabled
    public static String createQuote(String recordId) {

        List<QuoteLineItem> quoteLineItemsList = new List<QuoteLineItem>();

        Opportunity opportunity = [SELECT Id, Name, Pricebook2Id FROM Opportunity WHERE Id = :recordId];
        List<OpportunityLineItem> oliList = [SELECT Id, Product2Id, PriceBookEntry.Product2Id, Quantity, Description, Custom_Product_Details_RE__c, UnitPrice, PricebookEntryId, Discount FROM OpportunityLineItem WHERE OpportunityId = :opportunity.Id];

        Quote quote = new Quote();
        quote.Name = opportunity.Name + '- Quote';
        quote.ExpirationDate = Date.today().addMonths(1);
        quote.OpportunityId = opportunity.Id;
        quote.Pricebook2Id = opportunity.Pricebook2Id;

        insert quote;
        if (oliList != null) {
            for (OpportunityLineItem oli : oliList) {
                QuoteLineItem quoteLineItem = new QuoteLineItem();
                quoteLineItem.QuoteId = quote.Id;
                quoteLineItem.Description = oli.Description;
                quoteLineItem.Custom_Product_Details_RE__c = oli.Custom_Product_Details_RE__c;
                quoteLineItem.UnitPrice = oli.UnitPrice;
                quoteLineItem.Product2Id = oli.PriceBookEntry.Product2Id;
                quoteLineItem.Quantity = oli.Quantity;
                quoteLineItem.PricebookEntryId = oli.PricebookEntryId;
                quoteLineItem.Discount = oli.Discount;
                quoteLineItemsList.add(quoteLineItem);
            }
            insert quoteLineItemsList;
        }

        return quote.Id;
    }

    @AuraEnabled
    public static void deleteQuote(String quoteId, String fileId) {
        if (fileId != null) {
            ContentDocument filePDF = [SELECT Id FROM ContentDocument WHERE Id = :fileId];
            delete filePDF;
        }
        if (quoteId != null) {
            Quote quote = [SELECT Id FROM Quote WHERE Id = :quoteId];
            delete quote;
        }

    }

}