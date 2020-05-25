public with sharing class LWFPBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	private String query;

	private List<String> contactTypes;
	private Set<Id> contacts;

	private String publicationId;
	private String campaignId;

	private static final String FIRM_PROFILE = 'Firm Profile';
	private static final String SETTING_NAME = 'LWFP';

	private static final String DOC_NAME = 'Contacts Id';

	private static final String stage = 'Closed Won';
	private static final String organizationRanking = 'Organization Ranking';
	
	Boolean isValid;

	public LWFPBatch() {
		Campaign_Settings__c customSetting = Campaign_Settings__c.getValues(SETTING_NAME);
		
		isValid = !(customSetting == null || String.isEmpty(customSetting.Publication__c) || String.isEmpty(customSetting.Campaign__c));

		contacts = new Set<Id>();
		if (isValid) {
			contactTypes = getRoles(customSetting.Contact_Type__c);
			publicationId = customSetting.Publication__c;
			campaignId = customSetting.Campaign__c;
		}
		if (isValid) {
			this.query = 'SELECT Id, ' + 
				'(SELECT Id, Publication_RE__c, RecordType.Name FROM Rankings_as_Parent__r WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId LIMIT 1), ' +
				'(SELECT Id, Stage__c, Product2.Name FROM Opportunity_Product__r WHERE Publication__c =: publicationId) ' +
				'FROM Account ' +
				'WHERE IsParent__c = true AND Id IN (SELECT Parent_Account__c FROM Rankings__c WHERE RecordType.Name =: organizationRanking AND Publication_RE__c =: publicationId) ' +
				'AND Id IN (SELECT AccountId FROM Opportunity WHERE StageName =: stage and Publication_RE__c =: publicationId)';
		} else {
			this.query = 'SELECT Id FROM Account LIMIT 0'; 
		}
	}
	
	public Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}
	
	public void execute(Database.BatchableContext BC, List<sObject> scope) {
		Set<Id> accsId = new Set<Id>();

		// part for lawyers with firm profile
		if (isValid) {
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

		if (isValid) {
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