public with sharing class RPBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private String query;

    private List<String> contactTypes;
    private Set<Id> contacts;

    private String publicationId;
    private String campaignId;
    private String locationId;
    private String practiceArea;
    private List<String> band;

    private static final String SETTING_NAME = 'RP';

    private static final String DOC_NAME = 'Contacts Id';

    private static final String personRanking = 'Person Ranking';
    
    Boolean isValid;

    public RPBatch() {
        Campaign_Settings__c customSetting = Campaign_Settings__c.getValues(SETTING_NAME);
        
        isValid = !(customSetting == null || String.isEmpty(customSetting.Publication__c) || String.isEmpty(customSetting.Campaign__c));

        contacts = new Set<Id>();
        if (isValid) {
            publicationId = customSetting.Publication__c;
            campaignId = customSetting.Campaign__c;
            locationId = customSetting.Location__c;
            practiceArea = customSetting.Practice_Area__c;
            band = String.isNotEmpty(customSetting.Band__c) ? (List<String>)JSON.deserialize(customSetting.Band__c, List<String>.class) : new List<String>();
        }
        if (isValid) {
            this.query = 'SELECT Id ' + 
                'FROM Contact ' +
                'WHERE Id IN (SELECT Person_RE__c FROM Rankings__c WHERE Practice_Area_RE__c =: practiceArea AND Ranking__c =: band AND RecordType.Name =: personRanking AND Location__c =: locationId AND Publication_RE__c =: publicationId)';
        } else {
            this.query = 'SELECT Id FROM Account LIMIT 0'; 
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (isValid) {
            for (Contact cont : (List<Contact>)scope) {
                contacts.add(cont.Id);
            }
        }

        if (isValid) {
            List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: campaignId AND Name =: DOC_NAME];
            Attachment attachment = atts.isEmpty() ? new Attachment(ParentId = campaignId) : atts[0];
            attachment.Body = Blob.valueOf(JSON.serialize(contacts));
            attachment.Name = DOC_NAME;
            upsert attachment;
        }
    }
    
    public void finish(Database.BatchableContext BC) {}

}