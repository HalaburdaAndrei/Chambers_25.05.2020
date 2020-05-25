@isTest
public class RPBatchTest {

	private static final String RANKED_INDIVIDUALS_FOR_GPG = 'RP';

	private static final String DOC_NAME = 'Contacts Id';
	@isTest static void test_contact_batch() {
		Location__c loc = new Location__c(Name = 'test');
		insert loc;

		List<Campaign> campaigns = new List<Campaign>();
		campaigns.add(new Campaign(Name = RANKED_INDIVIDUALS_FOR_GPG));
		insert campaigns;

		List<Publication__c> publications = new List<Publication__c>();
		publications.add(new Publication__c(CC_Publication_ID_RE__c = '5', Year_Issue_RE__c = '2019'));
		insert publications;

		List<Campaign_Settings__c> campaignSettings = new List<Campaign_Settings__c>();
		campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[0].Id, Campaign__c = campaigns[0].Id, Name = RANKED_INDIVIDUALS_FOR_GPG , Practice_Area__c = 'Banking & Finance', Location__c = loc.Id, Band__c = '[1]'));
		insert campaignSettings;

		List<Contact> contacts = new List<Contact>();
		contacts.add(new Contact(LastName = 'Test5', Email = 'email5@mail.ru'));
		insert contacts;

		Id personRankingTypeId = Schema.SObjectType.Rankings__c.getRecordTypeInfosByDeveloperName().get('Person_Ranking').getRecordTypeId();

		List<Rankings__c> rankings = new List<Rankings__c>();
		rankings.add(new Rankings__c(Publication_RE__c = publications[0].Id, RecordTypeId = personRankingTypeId, Ranking__c = '1', Location__c = loc.Id, Person_RE__c = contacts[0].Id, Practice_Area_RE__c ='Banking & Finance'));
		insert rankings;

		Test.startTest();
			RPBatch job = new RPBatch();
			Database.executeBatch(job, 200);
		Test.stopTest();

		List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE Name =: DOC_NAME];
		System.assertEquals(1, atts.size());

		List<String> campaigns5;

		for (Attachment at : atts) {
			if (at.ParentId == campaigns[0].Id) {
                campaigns5 = (List<String>) JSON.deserialize(at.Body.toString(), List<String>.class);
			}
		}

		System.assertEquals(1, campaigns5.size());
		System.assertEquals(contacts[0].Id, campaigns5[0]);
		
	}
}