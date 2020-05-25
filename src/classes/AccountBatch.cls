public with sharing class AccountBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private String query;

    private List<String> contactTypes;
    private Set<Id> contacts;
    private Integer step;

    private String publicationId;
    private String campaignId;
    private String locationId;
    private String practiceArea;
    private String band;

    private static final String INDIVIDUAL_PROFILE = 'Individual Profile';
    private static final String FIRM_PROFILE = 'Firm Profile';

    private static final String DOC_NAME = 'Contacts Id';

    private static final String stage = 'Closed Won';
    private static final String organizationRanking = 'Organization Ranking';
    private static final String personRanking = 'Person Ranking';
    
    Boolean isValid;

    public AccountBatch(Integer step) {
        this.step = step;
        String settingName;
        if (step == 1) {
            settingName = 'LWIP';
        } else if (step == 2) {
            settingName = 'LWOIP';
        } else if (step == 3) {
            settingName = 'LWFP';
        } else if (step == 4) {
            settingName = 'LWOFP';
        } else if (step == 5) {
            settingName = 'RP';
        }

        Campaign_Settings__c customSetting = Campaign_Settings__c.getValues(settingName);
        
        isValid = !(customSetting == null || String.isEmpty(customSetting.Publication__c) || String.isEmpty(customSetting.Campaign__c));

        contacts = new Set<Id>();
        if (isValid) {
            contactTypes = getRoles(customSetting.Contact_Type__c);
            publicationId = customSetting.Publication__c;
            campaignId = customSetting.Campaign__c;
            locationId = customSetting.Location__c;
            practiceArea = customSetting.Practice_Area__c;
            band = customSetting.Band__c;
        }
        if (isValid && step == 1) {
            this.query = 'SELECT Id, AccountId, ' +
                '(SELECT Id, Product2.Name, Opportunity.AccountId FROM Opportunity_Product__r WHERE Stage__c =: stage AND Publication__c =: publicationId) ' +
                'FROM Contact ' +
                'WHERE Id IN (SELECT Person_RE__c FROM Rankings__c WHERE Publication_RE__c =: publicationId AND RecordType.Name =: personRanking) ' +
                'AND Id IN (SELECT Related_Individual__c FROM OpportunityLineItem WHERE Publication__c =: publicationId AND Stage__c =: stage)';
        } else if (isValid && step == 2) {
            this.query = 'SELECT Id, AccountId, ' +
                '(SELECT Id, Product2.Name, Opportunity.AccountId FROM Opportunity_Product__r WHERE Stage__c =: stage AND Publication__c =: publicationId) ' +
                'FROM Contact ' +
                'WHERE Id IN (SELECT Person_RE__c FROM Rankings__c WHERE Publication_RE__c =: publicationId AND RecordType.Name =: personRanking)';
        } else if (isValid && step == 3) {
            this.query = 'SELECT Id, ' + 
                '(SELECT Id, Publication_RE__c, RecordType.Name FROM Rankings_as_Parent__r WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId LIMIT 1), ' +
                '(SELECT Id, Stage__c, Product2.Name FROM Opportunity_Product__r WHERE Publication__c =: publicationId) ' +
                'FROM Account ' +
                'WHERE IsParent__c = true AND Id IN (SELECT Parent_Account__c FROM Rankings__c WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId) ' +
                'AND Id IN (SELECT AccountId FROM Opportunity WHERE StageName =: stage and Publication_RE__c =: publicationId)';
        } else if (isValid && step == 4) {
            this.query = 'SELECT Id, ' + 
                '(SELECT Id, Publication_RE__c, RecordType.Name FROM Rankings_as_Parent__r WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId LIMIT 1), ' +
                '(SELECT Id, Stage__c, Product2.Name FROM Opportunity_Product__r WHERE Publication__c =: publicationId) ' +
                'FROM Account ' +
                'WHERE IsParent__c = true AND Id IN (SELECT Parent_Account__c FROM Rankings__c WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId) ';
        } else if (isValid && step == 5) {
            this.query = 'SELECT Id ' + 
                'FROM Contact ' +
                'WHERE Id IN (SELECT Person_RE__c FROM Rankings__c WHERE Practice_Area_RE__c =: practiceArea AND Ranking__c =: band AND RecordType.Name =: personRanking AND Location__c =: locationId)';
        } else {
            this.query = 'SELECT Id FROM Account LIMIT 0'; 
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> accsId = new Set<Id>();

        // part for lawyers with profile
        if (isValid && step == 1) {
            for (Contact con : (List<Contact>)scope) {
                for (OpportunityLineItem op : con.Opportunity_Product__r) {
                    if (op.Product2.Name.contains(INDIVIDUAL_PROFILE) && op.Opportunity.AccountId == con.AccountId) { 
                        contacts.add(con.Id);
                    }
                }
            }
        }

        // part for lawyers without profile
        if (isValid && step == 2) {
            for (Contact con : (List<Contact>)scope) {
                contacts.add(con.Id);
                for (OpportunityLineItem op : con.Opportunity_Product__r) {
                    System.debug(op.Opportunity.AccountId);
                    System.debug(con.AccountId);
                    if (op.Product2.Name.contains(INDIVIDUAL_PROFILE) && op.Opportunity.AccountId == con.AccountId) {
                        contacts.remove(con.Id);
                    }
                }
            }
        }

        // part for lawyers with firm profile
        if (isValid && step == 3) {
            for (Account acc : (List<Account>)scope) {
                for (OpportunityLineItem op : acc.Opportunity_Product__r) {
                    if (op.Product2.Name.contains(FIRM_PROFILE)) {
                        accsId.add(acc.Id);
                    }
                }
            }

            String queryString = 'SELECT Id, ContactId, Roles FROM AccountContactRelation WHERE (Account.ParentId IN: accsId OR AccountId IN: accsId) ';
            if (!contactTypes.isEmpty()) {
                queryString += 'AND Roles INCLUDES (';
                for (String includeValue : contactTypes) {	
                    queryString += includeValue + ',';
                }
                queryString = queryString.removeEnd(',') +')';
            } 
            List<AccountContactRelation> acr = (List<AccountContactRelation>)Database.query(queryString);
            for (AccountContactRelation ac : acr) {
                contacts.add(ac.ContactId);
            }
        }

        // part for lawyers without firm profile
        if (isValid && step == 4) {
            for (Account acc : (List<Account>)scope) {
                accsId.add(acc.Id);
                for (OpportunityLineItem op : acc.Opportunity_Product__r) {
                    if (op.Product2.Name.contains(FIRM_PROFILE) && op.Stage__c == stage) {
                        accsId.remove(acc.Id);
                    }
                }
            }
            String queryString = 'SELECT Id, ContactId, Roles FROM AccountContactRelation WHERE AccountId IN: accsId ';
            if (!contactTypes.isEmpty()) {
                queryString += 'AND Roles INCLUDES (';
                for (String includeValue : contactTypes) {	
                    queryString += includeValue + ',';
                }
                queryString = queryString.removeEnd(',') +')';
            } 
            List<AccountContactRelation> acr = (List<AccountContactRelation>)Database.query(queryString);

            for (AccountContactRelation ac : acr) {
                contacts.add(ac.ContactId);
            }
        }

        if (isValid && step == 5) {
            for (Contact cont : (List<Contact>)scope) {
                contacts.add(cont.Id);
            }
        }

        if (isValid && (step == 1 || step == 2 || step == 3 || step == 4 || step == 5)) {
            List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: campaignId AND Name =: DOC_NAME];
            Attachment attachment = atts.isEmpty() ? new Attachment(ParentId = campaignId) : atts[0];
            attachment.Body = Blob.valueOf(JSON.serialize(contacts));
            attachment.Name = DOC_NAME;
            upsert attachment;
        }
    }
    
    public void finish(Database.BatchableContext BC) {}

    private List<String> getRoles(String contactType) {
        List<String> result = new List<String>();
        Schema.DescribeSObjectResult objSchema = AccountContactRelation.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        List<Schema.Picklistentry> fld = fieldmap.get('Roles').getDescribe().getpicklistValues();
        for (Schema.Picklistentry pl : fld) {
            if (contactType != null && pl.getValue().containsIgnoreCase(contactType)) {
                result.add('\'' + pl.getValue() + '\'');
            }
        }
        return result;
    }
}