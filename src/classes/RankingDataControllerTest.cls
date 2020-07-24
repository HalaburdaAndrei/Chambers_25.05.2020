@IsTest
private class RankingDataControllerTest {
    @testSetup
    static void setup() {
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Rankings__c' and Name = 'Organization Ranking'].Id;
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

        Opportunity opp = new Opportunity(
                Name = 'testOpp',
                AccountId = acc.Id,
                Signer__c = con.Id,
                StageName = 'Qualified',
                CloseDate = Date.today()
        );
        insert opp;

        Publication__c publicationAsia = new Publication__c(
                Name = 'testPublicationAsia',
                Publication_Type__c = 'Asia',
                CC_Publication_ID_RE__c = '1234',
                Year_Issue_RE__c = '2019'
        );
        insert publicationAsia;

        Publication__c publicationUSA = new Publication__c(
                Name = 'testPublicationUSA',
                Publication_Type__c = 'USA',
                CC_Publication_ID_RE__c = '122134',
                Year_Issue_RE__c = '2020'
        );
        insert publicationUSA;

        Rankings__c rankingsAsia = new Rankings__c(
                Publication_RE__c = publicationAsia.Id,
                Year_RE__c = '2019',
                Account_RE__c = acc.Id,
                Ranking__c = '3',
                RecordTypeId = strRecordTypeId,
                Practice_Area_RE__c = 'testPactic2019'
        );
        insert rankingsAsia;

        Rankings__c rankingsAsia1 = new Rankings__c(
                Publication_RE__c = publicationAsia.Id,
                Year_RE__c = '2020',
                Account_RE__c = acc.Id,
                Ranking__c = '1',
                RecordTypeId = strRecordTypeId,
                Practice_Area_RE__c = 'testPactic20'
        );
        insert rankingsAsia1;

        Rankings__c rankingsUSA = new Rankings__c(
                Publication_RE__c = publicationAsia.Id,
                Year_RE__c = '2020',
                Account_RE__c = acc.Id,
                Ranking__c = '2',
                RecordTypeId = strRecordTypeId,
                Practice_Area_RE__c = 'testPactic2020'
        );
        insert rankingsUSA;
    }

    @IsTest
    static void testGetpublicationType() {
        Account acc = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        test.startTest();
        RankingDataController.getpublicationType('Organization Ranking', acc.Id);
        RankingDataController.getpublicationType('Person Ranking', opp.Id);
        System.assertEquals(3,[SELECT COUNT() FROM Rankings__c]);
        test.stopTest();
    }

    @IsTest
    static void testGetRankings() {
        Account acc = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Publication__c pub = [SELECT Id,Publication_Type__c FROM Publication__c WHERE Publication_Type__c = 'Asia'];
        List<String> yearList = new List<String>{'2020','2019'};
        test.startTest();
        RankingDataController.getRankings('Organization Ranking', acc.Id, pub.Publication_Type__c, yearList);
        RankingDataController.getRankings('Person Ranking', opp.Id, pub.Publication_Type__c, yearList);
        System.assertEquals(3,[SELECT COUNT() FROM Rankings__c]);
        System.assertEquals('Asia',pub.Publication_Type__c);
        test.stopTest();
    }

    @IsTest
    static void testGetRankingsSearch() {
        Account acc = [SELECT Id FROM Account];
        Opportunity opp = [SELECT Id FROM Opportunity];
        Publication__c pub = [SELECT Id,Publication_Type__c FROM Publication__c WHERE Publication_Type__c = 'Asia'];
        List<String> yearList = new List<String>{'2020','2019'};
        test.startTest();
        RankingDataController.getRankingsSearch('Organization Ranking', acc.Id, pub.Publication_Type__c, yearList,'test','','','','','');
        RankingDataController.getRankingsSearch('Person Ranking', opp.Id, pub.Publication_Type__c, yearList,'','','','','','');
        System.assertEquals(3,[SELECT COUNT() FROM Rankings__c]);
        System.assertEquals('Asia',pub.Publication_Type__c);
        test.stopTest();
    }
}