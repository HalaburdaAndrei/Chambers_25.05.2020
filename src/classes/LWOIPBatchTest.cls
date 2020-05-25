@isTest
public class LWOIPBatchTest {

	private static final String LAWYER_WITHOUT_INDIVIDUAL_PROFILE = 'LWOIP';

	private static final String DOC_NAME = 'Contacts Id';

	@isTest static void test_contact_batch() {
		List<Campaign> campaigns = new List<Campaign>();
		campaigns.add(new Campaign(Name = LAWYER_WITHOUT_INDIVIDUAL_PROFILE));
		insert campaigns;

		List<Publication__c> publications = new List<Publication__c>();
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '2', Year_Issue_RE__c = '2019'));
		insert publications;

		List<Campaign_Settings__c> campaignSettings = new List<Campaign_Settings__c>();
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[0].Id, Campaign__c = campaigns[0].Id, Name = LAWYER_WITHOUT_INDIVIDUAL_PROFILE));
		insert campaignSettings;

		List<Account> parents = new List<Account>();
        parents.add(new Account(Name = 'parent1', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		parents.add(new Account(Name = 'parent2', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		insert parents;

    	List<Account> accounts = new List<Account>();
		accounts.add(new Account(ParentId = parents[0].Id, Name = 'Test2', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(LastName = 'Test2', Email = 'email2@mail.ru', AccountId = parents[0].Id ));
		insert contacts;

		Id personRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Person_Ranking').getRecordTypeId();
		Id organizationRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Organization_Ranking').getRecordTypeId();

		List<Rankings__c> rankings = new List<Rankings__c>();
		rankings.add(new Rankings__c(Publication_RE__c = publications[0].Id, Person_RE__c = contacts[0].Id, RecordTypeId = personRankingTypeId));
		insert rankings;

		Id pricebookId = Test.getStandardPricebookId();

		List<Opportunity> opps = new List<Opportunity>();
		opps.add(new Opportunity(AccountId = parents[0].Id, Name = 'oppName', Publication_RE__c = publications[0].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		insert opps;

		Product2 prodIndividual = new Product2(Name = 'Standard Individual Profile', IsActive = true);
		insert new List<Product2>{prodIndividual};

		PricebookEntry pbe = new PricebookEntry(unitprice = 0.01, Product2Id = prodIndividual.Id, Pricebook2Id = pricebookId, IsActive = true);
		insert new List<PricebookEntry>{pbe};

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps[0].Id, Related_Individual__c = contacts[0].Id, Related_Organization__c = accounts[0].Id, Publication__c = publications[0].Id, Product2Id = prodIndividual.Id, PricebookEntryId = pbe.Id));
		insert opportunityLineItems;

		opps[0].StageName = 'Closed Won';

		update opps;
		
		Test.startTest();
			LWOIPBatch job = new LWOIPBatch();
			Database.executeBatch(job, 200);
		Test.stopTest();

		List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Name =: DOC_NAME];
		System.assertEquals(1, atts.size());
		
		List<String> campaigns2;

		for (Attachment at : atts) {
			if (at.ParentId == campaigns[0].Id) {
                campaigns2 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
		}

		System.assertEquals(0, campaigns2.size());
	}
}