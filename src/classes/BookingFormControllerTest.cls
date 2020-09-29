
@IsTest
private class BookingFormControllerTest {
    @testSetup
    static void setup() {

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
                StageName = 'Qualified',
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

    }
    @IsTest
    static void testopenUrl() {
        Opportunity opp = [SELECT Id, Signer__r.FirstName FROM Opportunity];
        APXTConga4__Conga_Merge_Query__c query = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Booking Form Query', APXTConga4__Description__c = 'Booking Form Query from Opportunity Line Items and Opportunity records.');
        insert query;
        Pagereference pageRef = Page.GetSessionIdVF;
        Test.setCurrentPage(pageRef);
        test.startTest();
        BookingFormController.openUrl(opp.Id);
        System.assertNotEquals('no', BookingFormController.openUrl(opp.Id));
        test.stopTest();
    }

    @IsTest
    static void testopenUrlFail() {
        Opportunity opp = [SELECT Id, Signer__r.FirstName FROM Opportunity];
        APXTConga4__Conga_Merge_Query__c query = new APXTConga4__Conga_Merge_Query__c(APXTConga4__Name__c = 'Booking Form Query', APXTConga4__Description__c = 'Booking Form Query from Opportunity Line Items and Opportunity records.');
        insert query;
        APXT_CongaSign__Transaction__c transactionSent = new APXT_CongaSign__Transaction__c(
                APXT_CongaSign__Status__c = 'SENT',
                Parent_006__c = opp.Id
        );
        insert transactionSent;
        Pagereference pageRef = Page.GetSessionIdVF;
        Test.setCurrentPage(pageRef);
        test.startTest();
        BookingFormController.openUrl(opp.Id);
        System.assertEquals('no', BookingFormController.openUrl(opp.Id));
        test.stopTest();
    }

    @isTest
    static void testfetchUserSessionId() {
        Pagereference pageRef = Page.GetSessionIdVF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters();

        BookingFormController.fetchUserSessionId();
        System.assertEquals('SESSION_ID_REMOVED', BookingFormController.fetchUserSessionId());

    }
}