@isTest
public class AccountBatchTest {

	private static final String LAWYER_WITH_INDIVIDUAL_PROFILE = 'LWIP';
	private static final String LAWYER_WITHOUT_INDIVIDUAL_PROFILE = 'LWOIP';
	private static final String LAWYER_WITH_FIRM_PROFILE = 'LWFP';
	private static final String LAWYER_WITHOUT_FIRM_PROFILE = 'LWOFP';
	private static final String RANKED_INDIVIDUALS_FOR_GPG = 'RP';

	private static final String DOC_NAME = 'Contacts Id';
	@isTest static void test_contact_batch() {
		Location__c loc = new Location__c(Name = 'test');
		insert loc;

		List<Campaign> campaigns = new List<Campaign>();
		campaigns.add(new Campaign(Name = LAWYER_WITH_INDIVIDUAL_PROFILE));
		campaigns.add(new Campaign(Name = LAWYER_WITHOUT_INDIVIDUAL_PROFILE));
		campaigns.add(new Campaign(Name = LAWYER_WITH_FIRM_PROFILE));
		campaigns.add(new Campaign(Name = LAWYER_WITHOUT_FIRM_PROFILE));
		campaigns.add(new Campaign(Name = RANKED_INDIVIDUALS_FOR_GPG));
		insert campaigns;

		List<Publication__c> publications = new List<Publication__c>();
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '1', Year_Issue_RE__c = '2019'));
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '2', Year_Issue_RE__c = '2019'));
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '3', Year_Issue_RE__c = '2019'));
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '4', Year_Issue_RE__c = '2019'));
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '5', Year_Issue_RE__c = '2019'));
		insert publications;

		List<Campaign_Settings__c> campaignSettings = new List<Campaign_Settings__c>();
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[0].Id, Campaign__c = campaigns[0].Id, Name = LAWYER_WITH_INDIVIDUAL_PROFILE));
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[1].Id, Campaign__c = campaigns[1].Id, Name = LAWYER_WITHOUT_INDIVIDUAL_PROFILE));
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[2].Id, Campaign__c = campaigns[2].Id, Name = LAWYER_WITH_FIRM_PROFILE));
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[3].Id, Campaign__c = campaigns[3].Id, Name = LAWYER_WITHOUT_FIRM_PROFILE));
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[4].Id, Campaign__c = campaigns[4].Id, Name = RANKED_INDIVIDUALS_FOR_GPG , Practice_Area__c = 'Banking & Finance', Location__c = loc.Id, Band__c = '1'));
		insert campaignSettings;

		Id firmTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Firm').getRecordTypeId();

		List<Account> parents = new List<Account>();
		parents.add(new Account(Name = 'parent1', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		parents.add(new Account(Name = 'parent2', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		insert parents;

		List<Account> accounts = new List<Account>();
		accounts.add(new Account(ParentId = parents[0].Id, Name = 'Test1', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		accounts.add(new Account(ParentId = parents[1].Id, Name = 'Test2', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet'));
		accounts.add(new Account(Name = 'Test3', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet', RecordTypeId = firmTypeId));
		accounts.add(new Account(Name = 'Test4', BillingCity = 'BillingCity', BillingCountry = 'BillingCountry', BillingStreet = 'BillingStreet', RecordTypeId = firmTypeId));
		insert accounts;

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(LastName = 'Test1', Email = 'email@mail.ru', AccountId = accounts[0].Id ));
		contacts.add(new Contact(LastName = 'Test2', Email = 'email2@mail.ru', AccountId = parents[1].Id ));
		contacts.add(new Contact(LastName = 'Test2.1', Email = 'email2-1@mail.ru', AccountId = parents[1].Id ));
		contacts.add(new Contact(LastName = 'Test3', Email = 'email3@mail.ru', AccountId = accounts[2].Id));
		contacts.add(new Contact(LastName = 'Test4', Email = 'email4@mail.ru', AccountId = accounts[3].Id));
		contacts.add(new Contact(LastName = 'Test5', Email = 'email5@mail.ru'));
		insert contacts;

		Id personRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Person_Ranking').getRecordTypeId();
		Id organizationRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Organization_Ranking').getRecordTypeId();

		List<Rankings__c> rankings = new List<Rankings__c>();
		rankings.add(new Rankings__c(Publication_RE__c = publications[0].Id, Person_RE__c = contacts[0].Id, RecordTypeId = personRankingTypeId));
		rankings.add(new Rankings__c(Publication_RE__c = publications[1].Id, Person_RE__c = contacts[1].Id, RecordTypeId = personRankingTypeId));
		rankings.add(new Rankings__c(Publication_RE__c = publications[1].Id, Person_RE__c = contacts[2].Id, RecordTypeId = personRankingTypeId));
		rankings.add(new Rankings__c(Publication_RE__c = publications[2].Id, Parent_Account__c = accounts[2].Id, RecordTypeId = organizationRankingTypeId));
		rankings.add(new Rankings__c(Publication_RE__c = publications[3].Id, Parent_Account__c = accounts[3].Id, RecordTypeId = organizationRankingTypeId));
		rankings.add(new Rankings__c(Publication_RE__c = publications[4].Id, RecordTypeId = personRankingTypeId, Ranking__c = '1', Location__c = loc.Id, Person_RE__c = contacts[5].Id, Practice_Area_RE__c ='Banking & Finance'));
		insert rankings;

		Id pricebookId = Test.getStandardPricebookId();

		List<Opportunity> opps = new List<Opportunity>();
		opps.add(new Opportunity(AccountId = parents[0].Id, Name = 'oppName', Publication_RE__c = publications[0].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		opps.add(new Opportunity(AccountId = parents[1].Id, Name = 'oppName', Publication_RE__c = publications[1].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		opps.add(new Opportunity(AccountId = parents[1].Id, Name = 'oppName', Publication_RE__c = publications[1].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		insert opps;

		List<Opportunity> opps2 = new List<Opportunity>();
		opps2.add(new Opportunity(AccountId = accounts[2].Id, Signer__c = contacts[3].Id, Name = 'oppName', Publication_RE__c = publications[2].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		opps2.add(new Opportunity(AccountId = accounts[3].Id, Signer__c = contacts[4].Id, Name = 'oppName', Publication_RE__c = publications[3].Id, StageName = 'Qualified', Pricebook2Id = pricebookId, Type = 'New', CloseDate = Date.today()));
		insert opps2;

		Product2 prodIndividual = new Product2(Name = 'Standard Individual Profile', IsActive = true);
		Product2 prodFirm = new Product2(Name = 'Basic Firm Profile', IsActive = true);
		insert new List<Product2>{prodIndividual, prodFirm};

		PricebookEntry pbe = new PricebookEntry(unitprice = 0.01, Product2Id = prodIndividual.Id, Pricebook2Id = pricebookId, IsActive = true);
		PricebookEntry pbe1 = new PricebookEntry(unitprice = 0.01, Product2Id = prodFirm.Id, Pricebook2Id = pricebookId, IsActive = true);
		insert new List<PricebookEntry>{pbe, pbe1};

		List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps[0].Id, Related_Individual__c = contacts[0].Id, Related_Organization__c = accounts[0].Id, Publication__c = publications[0].Id, Product2Id = prodIndividual.Id, PricebookEntryId = pbe.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps[1].Id, Related_Individual__c = contacts[2].Id, Related_Organization__c = accounts[1].Id, Publication__c = publications[1].Id, Product2Id = prodIndividual.Id, PricebookEntryId = pbe.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps2[0].Id, Related_Organization__c = accounts[2].Id, Publication__c = publications[2].Id, Product2Id = prodFirm.Id, PricebookEntryId = pbe1.Id));
		opportunityLineItems.add(new OpportunityLineItem(OpportunityId = opps2[1].Id, Related_Organization__c = accounts[3].Id, Publication__c = publications[3].Id, Product2Id = prodFirm.Id, PricebookEntryId = pbe1.Id));
		insert opportunityLineItems;

		opps[0].StageName = 'Closed Won';
		opps[1].StageName = 'Closed Won';
		opps2[0].StageName = 'Closed Won';

		update opps;
		update opps2;
		
		Test.startTest();
			AccountBatch job = new AccountBatch(1);
			Database.executeBatch(job, 200);
		Test.stopTest();

		List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Name =: DOC_NAME];
		System.assertEquals(5, atts.size());
		
		List<String> campaigns1;
		List<String> campaigns2;
		List<String> campaigns3;
		List<String> campaigns4;
		List<String> campaigns5;

		for (Attachment at : atts) {
			if (at.ParentId == campaigns[0].Id) {
                campaigns1 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
			if (at.ParentId == campaigns[1].Id) {
                campaigns2 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
			if (at.ParentId == campaigns[2].Id) {
                campaigns3 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
			if (at.ParentId == campaigns[3].Id) {
                campaigns4 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
			if (at.ParentId == campaigns[4].Id) {
                campaigns5 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
		}

		System.assertEquals(0, campaigns1.size());
		System.assertEquals(1, campaigns2.size());
		System.assertEquals(contacts[1].Id, campaigns2[0]);
		System.assertEquals(1, campaigns3.size());
		System.assertEquals(contacts[3].Id, campaigns3[0]);
		System.assertEquals(1, campaigns4.size());
		System.assertEquals(contacts[4].Id, campaigns4[0]);
		System.assertEquals(1, campaigns5.size());
		System.assertEquals(contacts[5].Id, campaigns5[0]);
		
	}
}