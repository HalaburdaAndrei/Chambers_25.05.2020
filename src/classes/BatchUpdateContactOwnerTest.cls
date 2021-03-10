@IsTest
private class BatchUpdateContactOwnerTest {

    @testSetup
    static void setup() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Sales Management'];
        User u1 = new User(Alias = 'standt', Email = 'standarduser1@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingUser1', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardus1@testorg.com');
        insert u1;
        User u2 = new User(Alias = 'standt', Email = 'standarduser2@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'TestingUser2', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p.Id, IsActive = true,
                TimeZoneSidKey = 'America/Los_Angeles', UserName = 'standardus2@testorg.com');
        insert u2;

        Id accRecordId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Firm').getRecordTypeId();
        Account acct1 = new Account(
                Name = 'Test Account1',
                BillingStreet = '123 Some St.',
                BillingCity = 'Some City',
                BillingState = 'OR',
                BillingPostalCode = '97701',
                BillingCountry = 'US',
                RecordTypeId = accRecordId,
                Type = 'Firm',
                OwnerId = u1.Id
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
                OwnerId = u2.Id

        );
        insert acct2;

        List<Contact> newContact = new List<Contact>();

        for(Integer i = 1; i < 10; i++ ){
            newContact.add(new Contact(
                    AccountId = acct2.Id,
                    FirstName = 'Test'+i,
                    LastName = 'Contact1'+i,
                    Email = 'email@test.com',
                    OwnerId = u1.Id
            ));
        }

        for(Integer i = 1; i < 10; i++ ){
            newContact.add(new Contact(
                    AccountId = acct1.Id,
                    FirstName = 'Test'+i,
                    LastName = 'Contact1'+i,
                    Email = 'email@test.com',
                    OwnerId = u2.Id
            ));
        }
        insert newContact;
    }

    @IsTest
    static void contactOwnerTest() {
        Test.startTest();
        BatchUpdateContactOwner bcn = new BatchUpdateContactOwner();
        Id bcnId = Database.executeBatch(bcn, 200);
        Test.stopTest();
    }
}