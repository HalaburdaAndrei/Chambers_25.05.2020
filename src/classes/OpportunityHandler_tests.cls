@IsTest
public with sharing class OpportunityHandler_tests {

    @IsTest
    static void assignSalesTarget_test(){
        generateTestData();
        List<Opportunity> opps = [SELECT StageName FROM Opportunity];
        System.assertEquals(6, [SELECT count() FROM Sales_Target__c]);
        System.assertEquals(12, opps.size());
        for(Opportunity opp : opps) {
            opp.StageName = 'Closed Won';
        }
        update opps;

        List<Sales_Target__c> salesTargets = [
                SELECT
                        Date__c,
                        Sales_Person__c
                FROM Sales_Target__c
        ];
        System.assertEquals(7, salesTargets.size());
//    for(Opportunity opp : [SELECT Target__c FROM Opportunity]) {
        for(OpportunityLineItem opp : [SELECT Sales_Target__c FROM OpportunityLineItem WHERE OpportunityId IN: opps]) {
            System.assert(opp.Sales_Target__c != null);
        }

    }

    /**
     * Helper methods
     */
    static void generateTestData() {
        User u = [SELECT Id, Name FROM User LIMIT 1];

        Account acc = new Account(
                Name = 'Test Account',
                OwnerId = u.Id,
                ShippingStreet = 'test street',
                ShippingCity = 'test city',
                ShippingCountry = 'test country',
                ShippingPostalCode = '202020',
                BillingStreet = 'test street',
                BillingCity = 'test city',
                BillingCountry = 'test country',
                BillingPostalCode = '202020'
        );
        insert acc;

        Contact con1 = new Contact(
                AccountId = acc.Id,
                FirstName = 'Test',
                LastName = 'Contact1',
                Email = 'email@test.com'
        );
        insert con1;

        Publication__c pub = new Publication__c(
                Name = 'testPublicationGuiede',
                Publication_Type__c = 'Alternative Energy & Power 2020',
                CC_PublicationTypeCategory__c = 'Practice Guides',
                CC_Publication_ID_RE__c = '12234',
                Year_Issue_RE__c = '2020'
        );
        insert  pub;

        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;
        PricebookEntry pbe=new PricebookEntry(unitprice=0.01,Product2Id=prod.Id, Pricebook2Id=Test.getStandardPricebookId(), IsActive= true);
        insert pbe;

        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 1; i <= 12; i++) {
            opps.add(new Opportunity(
                    Name      = 'Test Opportunity',
                    AccountId = acc.Id,
                    Signer__c = con1.Id,
                    Type      = 'New',
                    StageName = 'Qualified',
                    System_Generated__c = true,
                    Pricebook2Id = Test.getStandardPricebookId(),
                    CloseDate = Date.newInstance(2022, i, 1),
                    OwnerId   = u.Id
            ));
        }
        insert opps;

        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        for(Integer i = 1; i < opps.size(); i++){
            opportunityLineItems.add(new OpportunityLineItem(
                    OpportunityId = opps[i].Id,
                    Related_Organization__c = acc.Id,
                    Publication__c = pub.Id,
                    PricebookEntryId = pbe.Id,
                    Quantity = 1,
                    TotalPrice = 1
            ));
        }
        insert opportunityLineItems;

        update opps;
        List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
        for(Integer i = 1; i <= 6; i++) {
            salesTargets.add(new Sales_Target__c(
                    Target__c = 10000,
                    Directory_Target__c = 12000,
                    Insights_Target__c = 11000,
                    Date__c = Date.newInstance(2021, i, 1),
                    Sales_Person__c = u.Id
            ));
        }
        insert salesTargets;
    }


}