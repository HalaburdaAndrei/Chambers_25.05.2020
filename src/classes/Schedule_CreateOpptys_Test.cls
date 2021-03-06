@isTest
private class Schedule_CreateOpptys_Test {

    @testSetup
    static void setup() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Management'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standardus@testorg.com');
        insert u;

        Publication__c pub1 = new Publication__c(
                Name = 'Test Pub1',
                CC_PublicationTypeCategory__c = 'Professional Adviser Guides',
                SalesStartDate_RE__c = Date.today().addMonths(-1),
                CC_Final_Date_RE__c = Date.today().addMonths(-10),
                Year_Issue_RE__c = '2019',
                Publication_Type_ID_RE__c = '999'
        );
        insert pub1;

        Publication__c pub3 = new Publication__c(
                Name = 'Test Pub3',
                CC_PublicationTypeCategory__c = 'Ranking Guides',
                SalesStartDate_RE__c = Date.today().addMonths(-6),
                CC_Final_Date_RE__c = Date.today(),
                Year_Issue_RE__c = '2020',
                PreviousEdition__c = pub1.Id,
                Publication_Type_ID_RE__c = '999'
        );
        insert pub3;

        Publication__c pub2 = new Publication__c(
                Name = 'Test Pub2',
                CC_PublicationTypeCategory__c = 'Career Guides',
                SalesStartDate_RE__c = Date.today().addDays(-1),
                CC_Final_Date_RE__c = Date.today().addMonths(4),
                Year_Issue_RE__c = '2021',
                PreviousEdition__c = pub3.Id,
                Publication_Type_ID_RE__c = '999'
        );
        insert pub2;

        Id accRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Firm').getRecordTypeId();
        Account acct1 = new Account(
                Name = 'Test Account1',
                BillingStreet = '123 Some St.',
                BillingCity = 'Some City',
                BillingState = 'OR',
                BillingPostalCode = '97701',
                BillingCountry = 'US',
                RecordTypeId = accRecordId,
                Type = 'Firm'
        );
        insert acct1;

        Account acct2 = new Account(
                Name = 'Test Account2',
                BillingStreet = '123 Some St.',
                BillingCity = 'Some City',
                BillingState = 'OR',
                BillingPostalCode = '97701',
                BillingCountry = 'US',
                RecordTypeId = accRecordId,
                Type = 'Firm',
                ParentId = acct1.Id
        );
        insert acct2;

        AccountTeamMember accTeam = new AccountTeamMember(
                TeamMemberRole = 'Career Guides',
                AccountId = acct1.Id,
                UserId = u.Id
        );
        insert accTeam;

        AccountTeamMember accTeam1 = new AccountTeamMember(
                TeamMemberRole = 'Practice Guides',
                AccountId = acct1.Id,
                UserId = u.Id
        );
        insert accTeam1;

        Contact con1 = new Contact(
                AccountId = acct1.Id,
                FirstName = 'Test',
                LastName = 'Contact1',
                Email = 'email@test.com'
        );
        insert con1;

        Id personRTId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByName().get('Person Ranking').getRecordTypeId();
        Id orgRTId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByName().get('Organization Ranking').getRecordTypeId();

        List<Rankings__c> ranks = new List<Rankings__c>();
        ranks.add(new Rankings__c(
                Publication_RE__c = pub1.Id,
                Account_RE__c = acct1.Id,
                RecordTypeId = personRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub1.Id,
                Account_RE__c = acct2.Id,
                RecordTypeId = personRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub1.Id,
                Account_RE__c = acct2.Id,
                RecordTypeId = orgRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub1.Id,
                Account_RE__c = acct1.Id,
                RecordTypeId = orgRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub2.Id,
                Account_RE__c = acct2.Id,
                RecordTypeId = personRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub2.Id,
                Account_RE__c = acct1.Id,
                RecordTypeId = orgRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub3.Id,
                Account_RE__c = acct1.Id,
                RecordTypeId = personRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub3.Id,
                Account_RE__c = acct2.Id,
                RecordTypeId = orgRTId
        ));
        ranks.add(new Rankings__c(
                Publication_RE__c = pub3.Id,
                Account_RE__c = acct1.Id,
                RecordTypeId = orgRTId
        ));
        insert ranks;

        List<Submissions__c> subs = new List<Submissions__c>();
        subs.add(new Submissions__c(
                Organization_RE__c = acct1.Id,
                Publication__c = pub2.Id,
                Year_Issue__c = '2019',
                Location__c = 'Canada'
        ));
        subs.add(new Submissions__c(
                Organization_RE__c = acct2.Id,
                Publication__c = pub3.Id,
                Year_Issue__c = '2020',
                Location__c = 'Canada'
        ));
        subs.add(new Submissions__c(
                Organization_RE__c = acct2.Id,
                Publication__c = pub1.Id,
                Year_Issue__c = '2020',
                Location__c = 'Canada'
        ));
        subs.add(new Submissions__c(
                Organization_RE__c = acct1.Id,
                Publication__c = pub2.Id,
                Year_Issue__c = '2020',
                Location__c = 'Canada'
        ));
        subs.add(new Submissions__c(
                Organization_RE__c = acct1.Id,
                Publication__c = pub3.Id,
                Year_Issue__c = '2020',
                Location__c = 'Canada'
        ));
        insert subs;

        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe=new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true);
        insert pbe;

        List<Opportunity> opps = new List<Opportunity>();
        opps.add(new Opportunity(
                Name = 'Test Oppty1',
                AccountId = acct1.Id,
                Publication_RE__c = pub1.Id,
                // EligibleProducts_RE__c = 'TEST PRODUCT',
                CloseDate = Date.today().addDays(90),
                StageName = 'Qualified',
                System_Generated__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Signer__c = con1.Id
        ));
        opps.add(new Opportunity(
                Name = 'Test Oppty3',
                AccountId = acct1.Id,
                Publication_RE__c = pub3.Id,
                EligibleProducts_RE__c = 'TEST PRODUCT',
                CloseDate = Date.today().addDays(90),
                StageName = 'Qualified',
                System_Generated__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Signer__c = con1.Id
        ));
        opps.add(new Opportunity(
                Name = 'Test Oppty31',
                AccountId = acct1.Id,
                Publication_RE__c = pub3.Id,
                // EligibleProducts_RE__c = 'TEST PRODUCT',
                CloseDate = Date.today().addDays(90),
                StageName = 'Qualified',
                System_Generated__c = false,
                Pricebook2Id = Test.getStandardPricebookId(),
                Signer__c = con1.Id
        ));
        opps.add(new Opportunity(
                Name = 'Test Oppty2',
                AccountId = acct1.Id,
                Publication_RE__c = pub3.Id,
                EligibleProducts_RE__c = 'TEST PRODUCT',
                CloseDate = Date.today().addDays(90),
                StageName = 'Qualified',
                Type = 'Eligible',
                System_Generated__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Signer__c = con1.Id
        ));
        opps.add(new Opportunity(
                Name = 'Test Oppty22',
                AccountId = acct1.Id,
                Publication_RE__c = pub2.Id,
                // EligibleProducts_RE__c = 'TEST PRODUCT',
                CloseDate = Date.today().addDays(90),
                StageName = 'Qualified',
                System_Generated__c = true,
                Pricebook2Id = Test.getStandardPricebookId(),
                Signer__c = con1.Id
        ));
        insert opps;

        List<OpportunityLineItem> lines = new List<OpportunityLineItem>();
        lines.add(new OpportunityLineItem(
                OpportunityId = opps[0].Id,
                Related_Organization__c = acct1.Id,
                Publication__c = pub2.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 1
        ));
        lines.add(new OpportunityLineItem(
                OpportunityId = opps[2].Id,
                Related_Organization__c = acct2.Id,
                Publication__c = pub3.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 1
        ));
        lines.add(new OpportunityLineItem(
                OpportunityId = opps[1].Id,
                Related_Organization__c = acct1.Id,
                Publication__c = pub3.Id,
                PricebookEntryId = pbe.Id,
                Quantity = 1,
                TotalPrice = 1
        ));

        insert lines;

        opps[0].StageName = 'Closed Won';
        update opps[0];
        opps[1].StageName = 'Closed Won';
        update opps[1];


    }

    @IsTest
    static void testCareerGuides() {
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('Schedule_CreateOpptysTest', CRON_EXP, new Schedule_CreateOpptys());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

    @IsTest
    static void testCareerGuidesMyDate() {
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('Schedule_CreateOpptysTest', CRON_EXP, new Schedule_CreateOpptys());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        Batch_AutoOpportunities bcn = new Batch_AutoOpportunities(Date.today().addDays(-1));
        Id bcnId = Database.executeBatch(bcn,1);
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    }

    @IsTest
    static void testRankingGuides() {

        Publication__c pub = [SELECT Id, CC_PublicationTypeCategory__c FROM Publication__c WHERE Name = 'Test Pub2' LIMIT 1];
        pub.CC_PublicationTypeCategory__c = 'Ranking Guides';
        update pub;
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('Schedule_CreateOpptysTest', CRON_EXP, new Schedule_CreateOpptys());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }

    @IsTest
    static void testPracticeGuides() {

        Publication__c pub = [SELECT Id, CC_PublicationTypeCategory__c FROM Publication__c WHERE Name = 'Test Pub2' LIMIT 1];
        pub.CC_PublicationTypeCategory__c = 'Practice Guides';
        update pub;
        Test.startTest();

        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('Schedule_CreateOpptysTest', CRON_EXP, new Schedule_CreateOpptys());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(0, ct.TimesTriggered);
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));

        Test.stopTest();
    }
}