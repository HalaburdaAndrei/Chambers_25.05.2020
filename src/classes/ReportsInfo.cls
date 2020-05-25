public with sharing class ReportsInfo {

    private static final String LAWYER_WITH_INDIVIDUAL_PROFILE = 'LWIP';
    private static final String LAWYER_WITHOUT_INDIVIDUAL_PROFILE = 'LWOIP';
    private static final String LAWYER_WITH_FIRM_PROFILE = 'LWFP';
    private static final String LAWYER_WITHOUT_FIRM_PROFILE = 'LWOFP';
    private static final String RANKED_INDIVIDUALS_FOR_GPG = 'RP';
    
    private static final List<String> STATUS = new List<String>{'Holding', 'Queued', 'Preparing', 'Processing'};

    public static Map<String, Boolean> jobs = new Map<String, Boolean>{
        'LWIPBatch' => false,
        'LWOIPBatch' => false,
        'LWFPBatch' => false,
        'LWOFPBatch' => false,
        'RPBatch' => false
    };
    
    @AuraEnabled
    public static Map<String, Object> getSettings() {
        try {
            Map<String, Setting> allObj = new Map<String, Setting>();
            Map<String, Campaign_Settings__c> allCampaignSettings = Campaign_Settings__c.getAll();
            for (Campaign_Settings__c cs : allCampaignSettings.values()) {
                if (cs.Name.contains(LAWYER_WITH_INDIVIDUAL_PROFILE)) {
                    allObj.put(cs.Campaign__c, new Setting(cs.Publication__c, cs.Campaign__c, cs.Location__c, cs.Contact_Type__c, cs.Practice_Area__c, LAWYER_WITH_INDIVIDUAL_PROFILE, cs.Band__c));
                }
                if (cs.Name.contains(LAWYER_WITHOUT_INDIVIDUAL_PROFILE)) {
                    allObj.put(cs.Campaign__c, new Setting(cs.Publication__c, cs.Campaign__c, cs.Location__c, cs.Contact_Type__c, cs.Practice_Area__c, LAWYER_WITHOUT_INDIVIDUAL_PROFILE, cs.Band__c));
                }
                if (cs.Name.contains(LAWYER_WITH_FIRM_PROFILE)) {
                    allObj.put(cs.Campaign__c, new Setting(cs.Publication__c, cs.Campaign__c, cs.Location__c, cs.Contact_Type__c, cs.Practice_Area__c, LAWYER_WITH_FIRM_PROFILE, cs.Band__c));
                }
                if (cs.Name.contains(LAWYER_WITHOUT_FIRM_PROFILE)) {
                    allObj.put(cs.Campaign__c, new Setting(cs.Publication__c, cs.Campaign__c, cs.Location__c, cs.Contact_Type__c, cs.Practice_Area__c, LAWYER_WITHOUT_FIRM_PROFILE, cs.Band__c));
                }
                if (cs.Name.contains(RANKED_INDIVIDUALS_FOR_GPG)) {
                    allObj.put(cs.Campaign__c, new Setting(cs.Publication__c, cs.Campaign__c, cs.Location__c, cs.Contact_Type__c, cs.Practice_Area__c, RANKED_INDIVIDUALS_FOR_GPG, cs.Band__c));
                }
            }
            List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId IN: allObj.keySet() AND Name =: 'Contacts Id'];
            for (Attachment att : atts) {
                // only for 5 setting
                List<String> contsId = (List<String>) JSON.deserialize(att.Body.toString(), List<String>.class);
                List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN: contsId ORDER BY Name];

                allObj.get(att.ParentId).contacts.addAll(contacts);
            }

            for (AsyncApexJob aaj : [SELECT Id, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name IN: jobs.keySet() AND Status IN: STATUS]) {
                if (jobs.containsKey(String.valueOf(aaj.ApexClass.Name))) {
                    jobs.put(String.valueOf(aaj.ApexClass.Name), true);
                } 
            }

            List<Item> publications = new List<Item>();
            for (Publication__c pub : [SELECT Id, Name FROM Publication__c ORDER BY Name]) {
                publications.add(new Item(pub.Name, pub.Id));
            }

            List<Item> campaigns = new List<Item>();
            for (Campaign cam : [SELECT Id, Name FROM Campaign ORDER BY Name]) {
                campaigns.add(new Item(cam.Name, cam.Id));
            }

            List<Item> locations = new List<Item>();
            for (Location__c loc : [SELECT Id, Name FROM Location__c ORDER BY Name]) {
                locations.add(new Item(loc.Name, loc.Id));
            }
            
            return new Map<String, Object>{
                'status' => 'success',
                'settings' => allObj,
                'publications' => publications,
                'campaigns' => campaigns,
                'locations' => locations,
                'jobs' => jobs
            };
        } catch (Exception ex) {
            return new Map<String, Object>{
                'status' => 'error',
                'message' => ex.getMessage(),
                'jobs' => jobs
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> addToCampaign(Id campaignId, List<Id> contactsId) {
        try {
            List<CampaignMember> campaignMembers = new List<CampaignMember>();
            List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: campaignId AND Name =: 'Contacts Id'];
            if (atts.isEmpty()) {
                return new Map<String, Object>{
                    'status' => 'error',
                    'message' => 'The Campaign was not found.'
                };
            }
            List<String> contsId = (List<String>) JSON.deserialize(atts[0].Body.toString(), List<String>.class);

            Set<Id> contactsSet = new Set<Id>();
            contactsSet.addAll(contactsId);
            for (Integer i = contsId.size() - 1; i >= 0; i--) {
                if (contactsSet.contains(contsId[i])) {
                    campaignMembers.add(new CampaignMember(CampaignId = campaignId, ContactId = contsId[i]));
                    String result = contsId.remove(i);
                }
            }

            if (!campaignMembers.isEmpty()) {
                Database.SaveResult[] srList = Database.insert(campaignMembers, false);
                for (Integer i = 0; i < srList.size(); i++) {
                    Database.SaveResult sr = srList[i];
                    if (!sr.isSuccess()) {
                        for (Database.Error err : sr.getErrors()) {
                            if (String.valueOf(err.getStatusCode()) != 'DUPLICATE_VALUE') {
                                DmlException exc = new DmlException();
                                exc.setMessage(err.getStatusCode() + ': ' + err.getMessage() + ' Record Id: ' + campaignMembers[i].ContactId);
                                throw exc;
                            }
                        }
                    }
                }
            }

            atts[0].Body = Blob.valueOf(JSON.serialize(contsId));
            update atts[0];
            List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN: contsId ORDER BY Name];

            return new Map<String, Object>{
                'status' => 'success',
                'contacts' => contacts
            };
        } catch (Exception ex) {
            return new Map<String, Object>{
                'status' => 'error',
                'message' => ex.getMessage()
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> upsertCustomSettings(String campaignId, String publicationId, String locationId, String contactType, String practiceArea, String band, String name) {
        try {
            List<Campaign_Settings__c> setting = [SELECT Id, Name, Publication__c, Campaign__c, Contact_Type__c FROM Campaign_Settings__c WHERE Name =: name];
            String oldCampaignId = setting.isEmpty() ? null : setting[0].Campaign__c;
            
            Campaign_Settings__c item = setting.isEmpty() ? new Campaign_Settings__c() : setting[0];     
            item.Publication__c = publicationId;
            item.Campaign__c = campaignId;
            item.Location__c = locationId;
            item.Practice_Area__c = practiceArea;
            item.Contact_Type__c = contactType;
            item.Band__c = band;
            item.Name = name;
            upsert item;

            if (oldCampaignId != null) {
                List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: campaignId AND Name =: 'Contacts Id'];
                if(!atts.isEmpty()) {
                    atts[0].Body = Blob.valueOf(JSON.serialize(new Set<Id>()));
                    update atts[0];
                }
            }
            return new Map<String, Object>{
                'status' => 'success'
            };
        } catch (Exception ex) {
            return new Map<String, Object>{
                'status' => 'error',
                'message' => ex.getMessage()
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> removeContacts(Id campaignId, List<Id> contactsId) {
        try {
            List<Attachment> atts = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE ParentId =: campaignId AND Name =: 'Contacts Id'];
            List<String> contsId = (List<String>) JSON.deserialize(atts[0].Body.toString(), List<String>.class);
            Set<Id> contactsSet = new Set<Id>();
            contactsSet.addAll(contactsId);
            for (Integer i = contsId.size() - 1; i >= 0; i--) {
                if (contactsSet.contains(contsId[i])) {
                    String result = contsId.remove(i);
                }
            }

            atts[0].Body = Blob.valueOf(JSON.serialize(contsId));
            update atts[0];
            List<Contact> contacts = [SELECT Id, Name, Email FROM Contact WHERE Id IN: contsId ORDER BY Name];

            return new Map<String, Object>{
                'status' => 'success',
                'contacts' => contacts
            };
        } catch (Exception ex) {
            return new Map<String, Object>{
                'status' => 'error',
                'message' => ex.getMessage()
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> LWIPBatch() {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClassId, ApexClass.Name
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('LWIPBatch')
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];
            if (jobs.isEmpty()) {
                LWIPBatch job = new LWIPBatch();
                Database.executeBatch(job, 200);
                return new Map<String, Object>{
                    'status' => 'success'
                };
            }
            return new Map<String, Object>{ 'status' => 'error', 'message' => 'The Batch is already running.'};
        } catch (Exception ex) {
            return new Map<String, Object>{ 'status' => 'error', 'message' => ex.getMessage() };
        }
    }

    @AuraEnabled
    public static Map<String, Object> LWOIPBatch() {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClassId, ApexClass.Name
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('LWOIPBatch')
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];
            if (jobs.isEmpty()) {
                LWOIPBatch job = new LWOIPBatch();
                Database.executeBatch(job, 200);
                return new Map<String, Object>{
                    'status' => 'success'
                };
            }
            return new Map<String, Object>{ 'status' => 'error', 'message' => 'The Batch is already running.' };
        } catch (Exception ex) {
            return new Map<String, Object>{ 'status' => 'error', 'message' => ex.getMessage() };
        }
    }
    @AuraEnabled
    public static Map<String, Object> LWFPBatch() {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClassId, ApexClass.Name
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('LWFPBatch')
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];
            if (jobs.isEmpty()) {
                LWFPBatch job = new LWFPBatch();
                Database.executeBatch(job, 200);
                return new Map<String, Object>{
                    'status' => 'success'
                };
            }
            return new Map<String, Object>{ 'status' => 'error', 'message' => 'The Batch is already running.' };
        } catch (Exception ex) {
            return new Map<String, Object>{ 'status' => 'error', 'message' => ex.getMessage() };
        }
    }

    @AuraEnabled
    public static Map<String, Object> LWOFPBatch() {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClassId, ApexClass.Name
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('LWOFPBatch')
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];
            if (jobs.isEmpty()) {
                LWOFPBatch job = new LWOFPBatch();
                Database.executeBatch(job, 200);
                return new Map<String, Object>{
                    'status' => 'success'
                };
            }
            return new Map<String, Object>{ 'status' => 'error', 'message' => 'The Batch is already running.'};
        } catch (Exception ex) {
            return new Map<String, Object>{ 'status' => 'error', 'message' => ex.getMessage() };
        }
    }

    @AuraEnabled
    public static Map<String, Object> RPBatch() {
        try {
            List<AsyncApexJob> jobs = [
                SELECT Id, Status, ApexClassId, ApexClass.Name
                FROM AsyncApexJob
                WHERE ApexClass.Name IN ('RPBatch')
                AND Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
            ];
            if (jobs.isEmpty()) {
                RPBatch job = new RPBatch();
                Database.executeBatch(job, 200);
                return new Map<String, Object>{
                    'status' => 'success'
                };
            }
            return new Map<String, Object>{ 'status' => 'error', 'message' => 'The Batch is already running.' };
        } catch (Exception ex) {
            return new Map<String, Object>{ 'status' => 'error', 'message' => ex.getMessage() };
        }
    }

    public class Setting {
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String band {get; set;}
        @AuraEnabled
        public String contactType {get; set;}
        @AuraEnabled
        public String practiceArea {get; set;}
        @AuraEnabled
        public Id campaignId {get; set;}
        @AuraEnabled
        public Id publicationId {get; set;}
        @AuraEnabled
        public Id locationId {get; set;}
        @AuraEnabled
        public Set<Contact> contacts {get; set;}

        public Setting(Id publicationId, Id campaignId, Id locationId, String contactType, String practiceArea, String type, String band) {
            this.campaignId = campaignId;
            this.publicationId = publicationId;
            this.locationId = locationId;
            this.practiceArea = practiceArea;
            this.type = type;
            this.band = band;
            this.contactType = contactType;
            this.contacts = new Set<Contact>();
        }
    }

    public class Item {
        @AuraEnabled
        public String label {get; set;}
        @AuraEnabled
        public String value {get; set;}

        public Item(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

}