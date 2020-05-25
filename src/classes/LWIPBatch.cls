public with sharing class LWIPBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private String query;

    private Set<Id> contacts;

    private String publicationId;
    private String campaignId;

    private static final String INDIVIDUAL_PROFILE = 'Individual Profile';
    private static final String SETTING_NAME = 'LWIP';

    private static final String DOC_NAME = 'Contacts Id';

    private static final String stage = 'Closed Won';
    private static final String personRanking = 'Person Ranking';
    
    Boolean isValid;

    public LWIPBatch() {
        Campaign_Settings__c customSetting = Campaign_Settings__c.getValues(SETTING_NAME);
        
        isValid = !(customSetting == null || String.isEmpty(customSetting.Publication__c) || String.isEmpty(customSetting.Campaign__c));

        contacts = new Set<Id>();
        if (isValid) {
            publicationId = customSetting.Publication__c;
            campaignId = customSetting.Campaign__c;
        }
        if (isValid) {
            this.query = 'SELECT Id, AccountId, ' +
                '(SELECT Id, Product2.Name, Opportunity.AccountId FROM Opportunity_Product__r WHERE Stage__c =: stage AND Publication__c =: publicationId) ' +
                'FROM Contact ' +
                'WHERE Id IN (SELECT Person_RE__c FROM Rankings__c WHERE Publication_RE__c =: publicationId AND RecordType.Name =: personRanking) ' +
                'AND Id IN (SELECT Related_Individual__c FROM OpportunityLineItem WHERE Publication__c =: publicationId AND Stage__c =: stage)';
        } else {
            this.query = 'SELECT Id FROM Account LIMIT 0'; 
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        // part for lawyers with profile
        if (isValid) {
            for (Contact con : (List<Contact>)scope) {
                for (OpportunityLineItem op : con.Opportunity_Product__r) {
                    if (op.Product2.Name.contains(INDIVIDUAL_PROFILE) && op.Opportunity.AccountId == con.AccountId) { 
                        contacts.add(con.Id);
                    }
                }
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