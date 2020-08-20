@ISTest
public with sharing class SalesDataByOpportunity_CTRL_tests {
  @IsTest
  static void getData_test(){
    generateData();
    List<Opportunity> oppList = [SELECT Id FROM Opportunity]; 
    List<Publication__c> publicList = [SELECT Id FROM Publication__c]; 
    List<OpportunityLineItem> oppProductsList = [SELECT Id,Quantity,TotalPrice FROM OpportunityLineItem]; 
    SalesDataByOpportunity_CTRL.DataByCatigoryType[] result = 
      SalesDataByOpportunity_CTRL.getData(oppList[0].Id, false, null);
    System.assertEquals(1, result.size());
    result = SalesDataByOpportunity_CTRL.getData(oppList[1].Id, true, null);
    System.assertEquals(1, result.size());
    SalesDataByOpportunity_CTRL.QueryCondition term = 
      new SalesDataByOpportunity_CTRL.QueryCondition();
      term.value = 'est';
      term.filterType = 'like';
      term.fieldName = 'Related_Organization__r.Name';
      term.dataType = 'string';
    List<SalesDataByOpportunity_CTRL.QueryCondition> terms = 
      new List<SalesDataByOpportunity_CTRL.QueryCondition>();
    terms.add(term);
    result = SalesDataByOpportunity_CTRL.getData(oppList[1].Id, true, terms);
    System.assertEquals(1, result.size());
  }

  @IsTest
  static void createNewOppProduct_test(){
    generateData();
    List<Opportunity> oppList = [SELECT Id FROM Opportunity]; 
    List<Publication__c> publicList = [SELECT Id FROM Publication__c]; 
    List<OpportunityLineItem> oppProductsList = [SELECT Id,Quantity,TotalPrice FROM OpportunityLineItem]; 
    
    SalesDataByOpportunity_CTRL.createNewOppProduct(
      (String)oppList[0].Id, 
      (String)publicList[0].Id, 
      oppProductsList);
      
    System.assertEquals(oppProductsList.size() + 1, [SELECT count() FROM OpportunityLineItem]);
  }

	static void generateData() {

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
    
    List<Opportunity> oppList = new List<Opportunity>();
		oppList.add(new Opportunity(
			Name = 'testOpp',
			AccountId = acc.Id,
			Signer__c = con.Id,
			StageName = 'Closed Won',
			CloseDate = Date.today().addYears(-1)
		));
		oppList.add(new Opportunity(
			Name = 'testOpp',
			AccountId = acc.Id,
			Signer__c = con.Id,
			StageName = 'Open',
			CloseDate = Date.today().addYears(-1)
		));
		insert oppList;

		Id pricebookId = Test.getStandardPricebookId();

		List<Product2> productList = new List<Product2>();

		productList.add(new Product2(Name = 'Basic Firm Profile', IsActive = true));
		productList.add(new Product2(Name = 'Basic Firm Profile2', IsActive = true));
		productList.add(new Product2(Name = 'Basic Firm Profile3', IsActive = true));
		insert productList;

		PricebookEntry pbe1 = new PricebookEntry(unitprice = 0.01, Product2Id = productList[0].Id, Pricebook2Id = pricebookId, IsActive = true);
		insert new List<PricebookEntry>{pbe1};

		List<Publication__c> publicList = new List<Publication__c>();
		publicList.add(new Publication__c(CC_Publication_ID_RE__c = '4', Year_Issue_RE__c = '2019', Name = 'PublicationName 1', Publication_Type__c = 'Ranking Guides'));
		publicList.add(new Publication__c(CC_Publication_ID_RE__c = '5', Year_Issue_RE__c = '2020', Name = 'PublicationName 2', Publication_Type__c = 'Practice guides'));
		publicList.add(new Publication__c(CC_Publication_ID_RE__c = '6', Year_Issue_RE__c = '2020', Name = 'PublicationName 3', Publication_Type__c = 'Practice guides'));
		insert publicList;

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[0].Id, Related_Organization__c = acc.Id, Publication__c = publicList[0].Id, Product2Id = productList[0].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[0].Id, Related_Organization__c = acc.Id, Publication__c = publicList[0].Id, Product2Id = productList[0].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[0].Id, Related_Organization__c = acc.Id, Publication__c = publicList[1].Id, Product2Id = productList[1].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[1].Id, Related_Organization__c = acc.Id, Publication__c = publicList[1].Id, Product2Id = productList[1].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[1].Id, Related_Organization__c = acc.Id, Publication__c = publicList[2].Id, Product2Id = productList[2].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = oppList[1].Id, Related_Organization__c = acc.Id, Publication__c = publicList[2].Id, Product2Id = productList[2].Id, PricebookEntryId = pbe1.Id));
    insert opportunityLineItems;
	}
}