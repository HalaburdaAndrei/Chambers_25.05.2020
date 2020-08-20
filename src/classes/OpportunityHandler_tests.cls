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
    System.assertEquals(12, salesTargets.size());
    for(Opportunity opp : [SELECT Target__c FROM Opportunity]) {
      System.assert(opp.Target__c != null);
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

    List<Opportunity> opps = new List<Opportunity>();
    for(Integer i = 1; i <= 12; i++) {
      opps.add(new Opportunity(
        Name      = 'Test Opportunity',
        AccountId = acc.Id,
        Type      = 'New',
        StageName = 'Qualified',
        CloseDate = Date.newInstance(2020, i, 1),
        OwnerId   = u.Id
      ));
    }
    insert opps;

    List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
    for(Integer i = 1; i <= 6; i++) {
      salesTargets.add(new Sales_Target__c(
        Target__c = 10000,
        Date__c = Date.newInstance(2020, i, 1),
        Sales_Person__c = u.Id
      ));
    }
    insert salesTargets;
  }
}