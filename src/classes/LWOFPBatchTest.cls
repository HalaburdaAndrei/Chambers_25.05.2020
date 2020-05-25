@isTest
public class LWOFPBatchTest {

	private static final String LAWYER_WITHOUT_FIRM_PROFILE = 'LWOFP';

	private static final String DOC_NAME = 'Contacts Id';


	@isTest static void test_contact_batch() {
		List<Campaign> campaigns = new List<Campaign>();
		campaigns.add(new Campaign(Name = LAWYER_WITHOUT_FIRM_PROFILE));
		insert campaigns;

		List<Publication__c> publications = new List<Publication__c>();
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '4', Year_Issue_RE__c = '2019'));
		insert publications;

		List<Campaign_Settings__c> campaignSettings = new List<Campaign_Settings__c>();
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[0].Id, Campaign__c = campaigns[0].Id, Name = LAWYER_WITHOUT_FIRM_PROFILE));
		insert campaignSettings;

		Id firmTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Firm').getRecordTypeId();

		List<Account> accounts = new List<Account>();
		accounts.add(new Account(Name = 'Test3', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet', RecordTypeId = firmTypeId));
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(LastName = 'Test3', Email = 'email3@mail.ru', AccountId = accounts[0].Id));
		insert contacts;

		Id personRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Person_Ranking').getRecordTypeId();
		Id organizationRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Organization_Ranking').getRecordTypeId();

		List<Rankings__c> rankings = new List<Rankings__c>();
		rankings.add(new Rankings__c(Publication_RE__c = publications[0].Id, Parent_Account__c = accounts[0].Id, RecordTypeId = organizationRankingTypeId));
		insert rankings;

		Id pricebookId = Test.getStandardPricebookId();

		List<Opportunity> opps2 = new List<Opportunity>();
		opps2.add(new Opportunity(AccountId = accounts[0].Id, Signer__c = contacts[0].Id, Name = 'oppName', Publication_RE__c = publications[0].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		insert opps2;

		Product2 prodFirm = new Product2(Name = 'Basic Firm Profile', IsActive = true);
		insert new List<Product2>{prodFirm};

		PricebookEntry pbe1 = new PricebookEntry(unitprice = 0.01, Product2Id = prodFirm.Id, Pricebook2Id = pricebookId, IsActive = true);
		insert new List<PricebookEntry>{pbe1};

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps2[0].Id, Related_Organization__c = accounts[0].Id, Publication__c = publications[0].Id, Product2Id = prodFirm.Id, PricebookEntryId = pbe1.Id));
		insert opportunityLineItems;
		
		Test.startTest();
			LWOFPBatch job = new LWOFPBatch();
			Database.executeBatch(job, 200);
		Test.stopTest();

		List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Name =: DOC_NAME];
		System.assertEquals(1, atts.size());
		
		List<String> campaigns4;

		for (Attachment at : atts) {
			if (at.ParentId == campaigns[0].Id) {
                campaigns4 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
		}

		System.assertEquals(1, campaigns4.size());
		System.assertEquals(contacts[0].Id, campaigns4[0]);
		
	}
}