@isTest
private class ReportsInfoTest {
	
    private static final String LAWYER_WITH_INDIVIDUAL_PROFILE = 'LWIP';
	private static final String LAWYER_WITHOUT_INDIVIDUAL_PROFILE = 'LWOIP';
	private static final String LAWYER_WITH_FIRM_PROFILE = 'LWFP';
	private static final String LAWYER_WITHOUT_FIRM_PROFILE = 'LWOFP';
    private static final String RANKED_INDIVIDUALS_FOR_GPG = 'RP';

    private static final String DOC_NAME = 'Contacts Id';

    @isTest static void test_init() {
        Map<String, Object> settings = ReportsInfo.getSettings();
        System.assertEquals(settings.size(), 6);
        System.assertEquals(settings.get('status'), 'success');
        Map<String, ReportsInfo.Setting> allReportSettings = (Map<String, ReportsInfo.Setting>)settings.get('settings');
        System.assertEquals(allReportSettings.size(), 0);
        
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
        campaignSettings.add(new Campaign_Settings__c(Publication__c = publications[4].Id, Campaign__c = campaigns[4].Id, Name = RANKED_INDIVIDUALS_FOR_GPG));
        insert campaignSettings;

        settings = ReportsInfo.getSettings();
        System.assertEquals(settings.size(), 6);
        System.assertEquals(settings.get('status'), 'success');
        allReportSettings = (Map<String, ReportsInfo.Setting>)settings.get('settings');
        System.assertEquals(allReportSettings.size(), 5);
		
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(JSON.serialize(new Set<Id>()));
        attachment.Name = DOC_NAME;
        attachment.ParentId = campaigns[0].Id;
        insert attachment;

        settings = ReportsInfo.getSettings();
        System.assertEquals(settings.size(), 6);
        System.assertEquals(settings.get('status'), 'success');
        allReportSettings = (Map<String, ReportsInfo.Setting>)settings.get('settings');
        System.assertEquals(allReportSettings.size(), 5);

        System.assertEquals(allReportSettings.get(campaigns[0].Id).type, LAWYER_WITH_INDIVIDUAL_PROFILE);
        System.assertEquals(allReportSettings.get(campaigns[0].Id).contactType, null);
        System.assertEquals(allReportSettings.get(campaigns[0].Id).publicationId, publications[0].Id);
        
        System.assertEquals(allReportSettings.get(campaigns[1].Id).type, LAWYER_WITHOUT_INDIVIDUAL_PROFILE);
        System.assertEquals(allReportSettings.get(campaigns[1].Id).contactType, null);
        System.assertEquals(allReportSettings.get(campaigns[1].Id).publicationId, publications[1].Id);
              
        System.assertEquals(allReportSettings.get(campaigns[2].Id).type, LAWYER_WITH_FIRM_PROFILE);
        System.assertEquals(allReportSettings.get(campaigns[2].Id).contactType, null);
        System.assertEquals(allReportSettings.get(campaigns[2].Id).publicationId, publications[2].Id);
              
        System.assertEquals(allReportSettings.get(campaigns[3].Id).type, LAWYER_WITHOUT_FIRM_PROFILE);
        System.assertEquals(allReportSettings.get(campaigns[3].Id).contactType, null);
        System.assertEquals(allReportSettings.get(campaigns[3].Id).publicationId, publications[3].Id);

        System.assertEquals(allReportSettings.get(campaigns[4].Id).type, RANKED_INDIVIDUALS_FOR_GPG);
        System.assertEquals(allReportSettings.get(campaigns[4].Id).locationId, null);
        System.assertEquals(allReportSettings.get(campaigns[4].Id).practiceArea, null);
        System.assertEquals(allReportSettings.get(campaigns[4].Id).contactType, null);
        System.assertEquals(allReportSettings.get(campaigns[4].Id).publicationId, publications[4].Id);
    }


    @isTest static void test_start_RPBatch() {
        Map<String, Object> result = ReportsInfo.RPBatch();
        System.assertEquals(result.get('status'), 'success');
    }
    
    @isTest static void test_start_LWOFPBatch() {
        Map<String, Object> result = ReportsInfo.LWOFPBatch();
        System.assertEquals(result.get('status'), 'success');
    }

    @isTest static void test_start_LWFPBatch() {
        Map<String, Object> result = ReportsInfo.LWFPBatch();
        System.assertEquals(result.get('status'), 'success');
    }
    
    @isTest static void test_start_LWOIPBatch() {
        Map<String, Object> result = ReportsInfo.LWOIPBatch();
        System.assertEquals(result.get('status'), 'success');
    }
    
    @isTest static void test_start_LWIPBatch() {
        Map<String, Object> result = ReportsInfo.LWIPBatch();
        System.assertEquals(result.get('status'), 'success');
    }

    @isTest static void test_add_campaign() {
        Map<String, Object> result = ReportsInfo.addToCampaign(null, new List<Id>());
        System.assertEquals(result.size(), 2);
        System.assertEquals(result.get('status'), 'error');
        System.assertEquals(result.get('message'), 'The Campaign was not found.');
        
        Contact cont = new Contact(LastName = 'LastName');
        insert cont;

        Campaign camp = new Campaign(Name = LAWYER_WITH_INDIVIDUAL_PROFILE);
        insert camp;

        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(JSON.serialize(new Set<Id>{cont.Id}));
        attachment.Name = DOC_NAME;
        attachment.ParentId = camp.Id;
        insert attachment;

        result = ReportsInfo.addToCampaign(camp.Id, new List<Id>{cont.Id});
        System.assertEquals(3, result.size());
        System.assertEquals(result.get('status'), 'success');
        
        List<Contact> contacts = (List<Contact>)result.get('contacts');
        System.assertEquals(contacts.size(), 0);
    }

    @isTest static void test_upsert_custom_settings() {
        Map<String, Object> settings = ReportsInfo.upsertCustomSettings(null, null, null, null, null, null, null);
        System.assertEquals(settings.size(), 2);
        System.assertEquals(settings.get('status'), 'error');
        String message = (String)settings.get('message');
        System.assert(message.contains('REQUIRED_FIELD_MISSING'));

        Contact cont = new Contact(LastName = 'LastName');
        insert cont;

        Campaign camp = new Campaign(Name = LAWYER_WITH_INDIVIDUAL_PROFILE);
        insert camp;

        Publication__c publ = new Publication__c(CC_Publication_ID_RE__c = '1', Year_Issue_RE__c = '2019');
        insert publ;

        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(JSON.serialize(new Set<Id>{cont.Id}));
        attachment.Name = DOC_NAME;
        attachment.ParentId = camp.Id;
        insert attachment;

        settings = ReportsInfo.upsertCustomSettings(cont.Id, publ.Id, null, null, null, null, LAWYER_WITH_INDIVIDUAL_PROFILE);
        System.assertEquals(settings.size(), 1);
        System.assertEquals(settings.get('status'), 'success');

        settings = ReportsInfo.upsertCustomSettings(cont.Id, publ.Id, null, null, null, null, LAWYER_WITH_INDIVIDUAL_PROFILE);
        System.assertEquals(settings.size(), 1);
        System.assertEquals(settings.get('status'), 'success');
    }

    @isTest static void test_remove_contacts() {
        Map<String, Object> settings = ReportsInfo.removeContacts(null, new List<Id>());
        System.assertEquals(2, settings.size());
        System.assertEquals(settings.get('status'), 'error');
        String message = (String)settings.get('message');
        System.assert(message.contains('List index out of bounds'));

        Contact cont = new Contact(LastName = 'LastName');
        insert cont;

        Campaign camp = new Campaign(Name = LAWYER_WITH_INDIVIDUAL_PROFILE);
        insert camp;

        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf(JSON.serialize(new Set<Id>{cont.Id}));
        attachment.Name = DOC_NAME;
        attachment.ParentId = camp.Id;
        insert attachment;

        settings = ReportsInfo.removeContacts(camp.Id, new List<Id>{cont.Id});
        System.assertEquals(3, settings.size());
        System.assertEquals(settings.get('status'), 'success');
        List<Contact> contacts = (List<Contact>)settings.get('contacts');
        System.assertEquals(contacts.size(), 0);
    }
    
}