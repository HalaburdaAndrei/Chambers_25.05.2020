@IsTest
private class SendaQuoteControllerTest {

    @testSetup
    static void setup() {

        APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c(
                APXTConga4__Name__c = 'template Send Test',
                APXTConga4__Template_Group__c = 'Send a Quote'
        );
        insert template;

        Account acc = new Account(
                Name = 'Test Account',
                BillingCountry = 'testCountry',
                BillingPostalCode = 'testPostalCode',
                BillingStreet = 'testStreet',
                BillingCity = 'testCity',
                BillingState = 'testState'
        );
        insert acc;

        Contact con = new Contact(
                FirstName = 'test',
                LastName = 'contact',
                Email = 'test123@gmail.com',
                AccountId = acc.Id
        );
        insert con;

        Contact con1 = new Contact(
                FirstName = 'test1',
                LastName = 'contact',
                Email = 'test1234@gmail.com',
                AccountId = acc.Id
        );
        insert con1;
        Id pricebookId = Test.getStandardPricebookId();

        Opportunity opp = new Opportunity(
                Name = 'testOpp',
                AccountId = acc.Id,
                Signer__c = con.Id,
                StageName = 'Open',
                CloseDate = Date.today(),
                Pricebook2Id = pricebookId
        );
        insert opp;

        Product2 p1 = new Product2(
                Name = 'TestProduct',
                IsActive = true
        );
        insert p1;


        PricebookEntry pBE1 = new PricebookEntry(
                Product2Id = p1.Id,
                Pricebook2Id = pricebookId,
                UnitPrice = 80,
                IsActive = true
        );
        insert pBE1;

        Publication__c publication = new Publication__c(
                Name = 'testPublication',
                CC_Publication_ID_RE__c = '1234',
                Year_Issue_RE__c = '2019'
        );
        insert publication;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.PricebookEntryId = pBE1.Id;
        oli.OpportunityId = opp.Id;
        oli.UnitPrice = 100;
        oli.Publication__c = publication.Id;
        oli.Quantity = 2;
        insert oli;

        Quote quote = new Quote();
        quote.Name = opp.Name + '-' + Date.today();
        quote.ExpirationDate = Date.today().addMonths(1);
        quote.OpportunityId = opp.Id;
        quote.Pricebook2Id = opp.Pricebook2Id;

        insert quote;

    }

    @IsTest
    static void testtemplates() {
        APXTConga4__Conga_Template__c template = [SELECT Id FROM APXTConga4__Conga_Template__c];
        test.startTest();
        SendaQuoteController.templates();
        System.assertEquals(1, [SELECT COUNT() FROM APXTConga4__Conga_Template__c]);
        test.stopTest();
    }

    @isTest
    static void testConId() {
        Opportunity opp = [SELECT Id, Signer__r.FirstName FROM Opportunity];
        Contact con = [SELECT FirstName FROM Contact WHERE FirstName = 'test'];
        test.startTest();
        SendaQuoteController.ConId(opp.Id);
        SendaQuoteController.checkStage(opp.Id);
        System.assertEquals(con.FirstName, opp.Signer__r.FirstName);
        test.stopTest();

    }

    @isTest
    static void testCreateQuote() {
        Opportunity opp = [SELECT Id FROM Opportunity];
        test.startTest();
        SendaQuoteController.createQuote(opp.Id);
        test.stopTest();
    }

    @isTest
    static void testSendEmailWithAttachment() {
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        List<Contact> con = [SELECT Id, Name, Email FROM Contact];
        test.startTest();
        SendaQuoteController.sendEmailwithPDF(cv.Id, 'subject', 'body', con[0], con);
        test.stopTest();
    }

    @isTest
    static void testOpenPDF() {
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        SendaQuoteController.openPDF(cv.Id);
        System.assertEquals([SELECT ContentDocumentId FROM ContentVersion], SendaQuoteController.openPDF(cv.Id));
    }

    @isTest
    static void testGenerateQuoute() {
        APXTConga4__Conga_Merge_Query__c query = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Send a Quote', APXTConga4__Description__c = 'Send a Quote');
        insert query;
        Pagereference pageRef = Page.GetSessionIdVF;
        Test.setCurrentPage(pageRef);
        Quote quote = [SELECT Id FROM Quote];
        Opportunity opp = [SELECT Id FROM Opportunity];
        APXTConga4__Conga_Template__c template = [SELECT Id FROM APXTConga4__Conga_Template__c];
        SingleRequestMock fakeResponse = new SingleRequestMock(200, 'OK', '0681l000000tsSsAAI', null);
        test.startTest();

        Test.setMock(HttpCalloutMock.class, fakeResponse);
        SendaQuoteController.generateQuote(template.Id, opp.Id, quote.Id);

        test.stopTest();
    }

    @isTest
    static void testfetchUserSessionId() {
        Pagereference pageRef = Page.GetSessionIdVF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters();

        SendaQuoteController.fetchUserSessionId();
        System.assertEquals('SESSION_ID_REMOVED', SendaQuoteController.fetchUserSessionId());

    }

    @isTest
    static void testdeleteQuote() {
        ContentVersion cv = new Contentversion();
        cv.title = 'ABC';
        cv.PathOnClient = 'test';
        Blob b = Blob.valueOf('Unit Test Attachment Body');
        cv.versiondata = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;
        ContentVersion cvId = [SELECT ContentDocumentId FROM ContentVersion];
        Quote quote = [SELECT Id FROM Quote];
        test.startTest();
        SendaQuoteController.deleteQuote(quote.Id, cvId.ContentDocumentId);
        System.assertEquals(0, [SELECT COUNT() FROM Quote]);
        System.assertEquals(0, [SELECT COUNT() FROM ContentDocument]);
        test.stopTest();


    }
}