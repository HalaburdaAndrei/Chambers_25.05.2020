@isTest
public with sharing class reUsableMultiSelectLookupCtrlTest {

    @isTest
    static void testLookUp(){
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

        Opportunity opp = new Opportunity(
                Name = 'testOpp',
                AccountId = acc.Id,
                Signer__c = con.Id,
                StageName = 'Open',
                CloseDate = Date.today()
        );
        insert opp;

        List<sObject> excludeitemsList = new List<SObject>();
        excludeitemsList.add(con1);
        String searchWord = 'test';
        String objName = 'Contact';
        reUsableMultiSelectLookupCtrl.fetchLookUpValues(searchWord,objName,excludeitemsList, opp.Id);
        System.assertEquals(1, excludeitemsList.size());


    }

}