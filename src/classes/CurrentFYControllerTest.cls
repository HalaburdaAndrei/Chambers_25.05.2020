@isTest
public with sharing class CurrentFYControllerTest {
	@testSetup
	static void setup() {
		String strRecordTypeId = [
			Select Id
			From RecordType
			Where SobjectType = 'Rankings__c'
				and Name = 'Organization Ranking'
		].Id;
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
			StageName = 'Closed Won',
			CloseDate = Date.today()
		);
		insert opp;

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
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opp.Id, Related_Organization__c = acc.Id, Publication__c = publicList[0].Id, Product2Id = productList[0].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opp.Id, Related_Organization__c = acc.Id, Publication__c = publicList[1].Id, Product2Id = productList[1].Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opp.Id, Related_Organization__c = acc.Id, Publication__c = publicList[2].Id, Product2Id = productList[2].Id, PricebookEntryId = pbe1.Id));
		insert opportunityLineItems;
	}

	@isTest
	static void getOpportunitiesTest(){
		Opportunity currentOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

		Map<String, Object> res = CurrentFYController.getOpportunities('wrong ID');
		System.assertEquals('error' ,res.get('status'));

		res = CurrentFYController.getOpportunities(currentOpportunity.Id);
		System.assertNotEquals(res, NULL);
		System.assertEquals(res.get('status'), 'success');

		List<CurrentFYController.PublicationTypeCategoryWrapper> table = (List<CurrentFYController.PublicationTypeCategoryWrapper>) res.get('table');
		System.debug(table.size());
		System.assertEquals(table.size(), 1);
	}

	@isTest
	static void getOpportunitiesSearchTest(){
		Map<String, String> params = new Map<String, String>();
		Map<String, Object> res = new Map<String, Object>();
		Opportunity currentOpportunity = [SELECT Id FROM Opportunity LIMIT 1];
		params.put('','');
		res = CurrentFYController.getOpportunitiesSearch(params);
		System.assertEquals('error' ,res.get('status'));

		params.put('recordId',currentOpportunity.Id);
		res = CurrentFYController.getOpportunitiesSearch(params);
		System.assertEquals('success', res.get('status'));
	}
}