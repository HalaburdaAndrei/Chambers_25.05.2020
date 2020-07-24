public with sharing class LastFYController {
	private static Opportunity currentOpportunity {get;set;}
	@AuraEnabled
	public static Map<String, Object> getOpportunities(String opportunityId) {
		//Id of HO account for current opportunity
		try {
			Map<String, Object> result = new Map<String, Object>();
			currentOpportunity = [  SELECT Id, AccountId, Account.Related_HO_Account__c, StageName, Pricebook2Id, Publication_RE__r.Id, Publication_RE__r.CC_PublicationTypeCategory__c
			FROM Opportunity
			WHERE Id = :opportunityId];
			String HOAccount = currentOpportunity.Account.Related_HO_Account__c.substring(10, 25);
			String HOAccountId = '%' + HOAccount + '%';

			Date startLastFY;
			Date endLastFY;
			if(Date.today() >= Date.newInstance(Date.today().year(),6,01)){
				startLastFY = Date.newInstance(Date.today().year()-1,6,01);
				endLastFY = Date.newInstance(Date.today().year(),6,01);
			} else {
				startLastFY = Date.newInstance(Date.today().year()-2,6,01);
				endLastFY = Date.newInstance(Date.today().year()-1,6,01);
			}

			List<OpportunityLineItem> allProduct = [
				SELECT Id, Publication__r.CC_PublicationTypeCategory__c, Publication__r.Publication_Type__c, Publication__r.Name,
					OpportunityId, Product2.Name, Quantity, TotalPrice, Opportunity.Owner.Name, Opportunity.Signer_text__c, Opportunity.CloseDate,
					Related_Organization__r.Name, Chapter__r.Name, Opportunity.Account.Name, Location__r.Name, Opportunity.Pricebook2Id,
					Submissions__c, Publication__r.Year_Issue_RE__c,Opportunity.Account.Related_HO_Account__c
				FROM OpportunityLineItem
				WHERE Opportunity.Account.Related_HO_Account__c LIKE : HOAccountId

					AND Opportunity.StageName = 'Closed Won'
					AND Opportunity.Current_FY__c = FALSE
					AND Opportunity.CloseDate < :endLastFY
					AND Opportunity.CloseDate > :startLastFY
				ORDER BY Opportunity.CloseDate DESC
			];

			List<OpportunityLineItem> checkallProduct = new List<OpportunityLineItem>();
			for(OpportunityLineItem pr :allProduct) {
				if (pr.Opportunity.Account.Related_HO_Account__c.contains(HOAccount)) {
					checkallProduct.add(pr);
				}
			}


			List<PublicationTypeCategoryWrapper> table = prepareTable(checkallProduct);
			if (table.size() > 0) {
				result.put('table', table);
			}
			result.put('status', 'success');
			return result;

		} catch (Exception ex) {
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}

	@AuraEnabled
	public static Map<String, Object> getOpportunitiesSearchLastFY (Map<String, String> params) {
		//Id of HO account for current opportunity
		try {
			Map<String, Object> result = new Map<String, Object>();

			String opportunityId = params.get('recordId');
			currentOpportunity =[SELECT Id, AccountId, Account.Related_HO_Account__c, StageName, Pricebook2Id, Publication_RE__r.Id,Publication_RE__r.CC_PublicationTypeCategory__c
			FROM Opportunity
			WHERE Id = :opportunityId];
			String HOAccount = [SELECT Id, AccountId, Account.Related_HO_Account__c FROM Opportunity WHERE Id = :opportunityId].Account.Related_HO_Account__c.substring(10, 25);
			String HOAccountId = '%' + HOAccount + '%';

			Date startLastFY;
			Date endLastFY;
			if(Date.today() >= Date.newInstance(Date.today().year(),6,01)){
				startLastFY = Date.newInstance(Date.today().year()-1,6,01);
				endLastFY = Date.newInstance(Date.today().year(),6,01);
			} else {
				startLastFY = Date.newInstance(Date.today().year()-2,6,01);
				endLastFY = Date.newInstance(Date.today().year()-1,6,01);
			}

			Date closeDate;
			Integer qty;
			String stage = 'Closed Won';


			String queryString =
				'SELECT Id, Publication__r.CC_PublicationTypeCategory__c, Publication__r.Publication_Type__c, Publication__r.Name, OpportunityId, '+
					'Product2.Name, Quantity, TotalPrice, Opportunity.Owner.Name, Opportunity.Signer_text__c, Opportunity.CloseDate, Related_Organization__r.Name, '+
					'Chapter__r.Name, Opportunity.Account.Name, Location__r.Name, Submissions__c, Publication__r.Year_Issue_RE__c, Opportunity.Pricebook2Id, Opportunity.Account.Related_HO_Account__c ' +
					'FROM OpportunityLineItem '+
					'WHERE Opportunity.Account.Related_HO_Account__c LIKE :HOAccountId '+
					'AND Opportunity.StageName = \'Closed Won\' ' +
					'AND Opportunity.Current_FY__c = FALSE ' +
					'AND Opportunity.CloseDate < :endLastFY ' +
					'AND Opportunity.CloseDate > :startLastFY ' ;

//publication+
			if(String.isNotEmpty(params.get('publicationFilter'))){
				queryString = queryString + 'AND Publication__r.Name LIKE \'%' + String.escapeSingleQuotes(params.get('publicationFilter')) + '%\' ';
			}
//oppId
			if(String.isNotEmpty(params.get('oppIdFilter'))){
//				if (params.get('oppIdFilter') instanceOf Id) {
				queryString = queryString + ' AND OpportunityId =\'' + String.escapeSingleQuotes(params.get('oppIdFilter')) + '\'';
//				}
			}
//product
			if(String.isNotEmpty(params.get('productFilter'))){
				queryString = queryString + 'AND Product2.Name LIKE \'%' + String.escapeSingleQuotes(params.get('productFilter')) + '%\' ';
			}
//qty
			if (String.isNotEmpty(params.get('qtyFilter'))){
				queryString = queryString + ' AND Quantity = ' + String.escapeSingleQuotes(params.get('qtyFilter'));
			}
//Sales Price
			if (String.isNotEmpty(params.get('salesPriceFilter'))){
				queryString = queryString + ' AND TotalPrice = ' + String.escapeSingleQuotes(params.get('salesPriceFilter'));
			}
//salesPerson
			if(String.isNotEmpty(params.get('salesPersonFilter'))){
				queryString = queryString + 'AND Opportunity.Owner.Name LIKE \'%' + String.escapeSingleQuotes(params.get('salesPersonFilter')) + '%\' ';
			}
//signerFilter +
			if(String.isNotEmpty(params.get('signerFilter'))){
				queryString = queryString + 'AND Opportunity.Signer_text__c LIKE \'%' + String.escapeSingleQuotes(params.get('signerFilter')) + '%\' ';
			}
//Close Date +
			if(String.isNotEmpty(params.get('closeDateFilter'))){
				closeDate = Date.valueOf(params.get('closeDateFilter'));
				queryString = queryString + 'AND Opportunity.CloseDate = :closeDate ';
			}
//relatedOrganization
			if(String.isNotEmpty(params.get('relatedOrganizationFilter'))){
				queryString = queryString + 'AND Related_Organization__r.Name LIKE \'%' + String.escapeSingleQuotes(params.get('relatedOrganizationFilter')) + '%\' ';
			}
//chapter
			if(String.isNotEmpty(params.get('chapterFilter'))){
				queryString = queryString + 'AND Chapter__r.Name LIKE \'%' + String.escapeSingleQuotes(params.get('chapterFilter')) + '%\' ';
			}
//parentAccount
			if(String.isNotEmpty(params.get('parentAccountFilter'))){
				queryString = queryString + 'AND Opportunity.Account.Name LIKE \'%' + String.escapeSingleQuotes(params.get('parentAccountFilter')) + '%\' ';
			}
//location +
			if(String.isNotEmpty(params.get('locationFilter'))){
				queryString = queryString + ' AND Location__r.Name LIKE \'%' + String.escapeSingleQuotes(params.get('locationFilter')) + '%\' ';
			}
//numberOfSubmissions +
			if(String.isNotEmpty(params.get('numberOfSubmissionsFilter'))){

				queryString = queryString + 'AND Submissions__c = ' + String.escapeSingleQuotes(params.get('numberOfSubmissionsFilter'));
			}

			List <OpportunityLineItem> allProduct = Database.query(queryString);

			List<OpportunityLineItem> checkallProduct = new List<OpportunityLineItem>();
			for(OpportunityLineItem pr :allProduct) {
				if (pr.Opportunity.Account.Related_HO_Account__c.contains(HOAccount)) {
					checkallProduct.add(pr);
				}
			}

			List<PublicationTypeCategoryWrapper> table = prepareTable(checkallProduct);
			if (table.size() > 0) {
				result.put('table', table);
			}
			result.put('status','success');
			return result;

		}  catch (Exception ex) {
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}

	private static List<PublicationTypeCategoryWrapper> prepareTable (List<OpportunityLineItem> allProducts){
		System.debug(allProducts);

		Map<String, List<OpportunityLineItem>> sortByPublicationTypeCategory = new Map<String, List<OpportunityLineItem>>();

		System.debug(sortByPublicationTypeCategory);

		for (OpportunityLineItem prod : allProducts) {
			if (sortByPublicationTypeCategory.containsKey(prod.Publication__r.CC_PublicationTypeCategory__c)) {
				sortByPublicationTypeCategory.get(prod.Publication__r.CC_PublicationTypeCategory__c).add(prod);
			} else {
				sortByPublicationTypeCategory.put(prod.Publication__r.CC_PublicationTypeCategory__c, New List<OpportunityLineItem> {
					prod
				});
			}
		}

		Map<String, PublicationTypeCategoryWrapper> unsortedTable= new Map<String, PublicationTypeCategoryWrapper>();
		List<PublicationTypeCategoryWrapper> table = new List<PublicationTypeCategoryWrapper>();

		for (String publicationTypeCategory : sortByPublicationTypeCategory.keySet()) {
			PublicationTypeCategoryWrapper line = new PublicationTypeCategoryWrapper();
			line.publicationTypeCategory = publicationTypeCategory;
			line.publicationTypes = new List<PublicationTypeWrapper>();

			Map<String,LIst<OpportunityLineItem>> sortByPublicationType= new Map<String, List<OpportunityLineItem>>();

			for (OpportunityLineItem opli : sortByPublicationTypeCategory.get(publicationTypeCategory)){
				if(sortByPublicationType.containsKey(opli.Publication__r.Publication_Type__c)){
					sortByPublicationType.get(opli.Publication__r.Publication_Type__c).add(opli);
				} else {
					sortByPublicationType.put(opli.Publication__r.Publication_Type__c, new List<OpportunityLineItem>{opli});
				}
			}
			for (String publicationType : sortByPublicationType.keySet()){
				PublicationTypeWrapper p = new PublicationTypeWrapper();
				p.publicationType = publicationType;
				p.totalRows = new List<WrapperTotalRow>();
				p.addWrapperPriceBookTable(sortByPublicationType.get(publicationType));
				line.publicationTypes.add(p);
			}
			line.publicationTypes.sort();
			unsortedTable.put(publicationTypeCategory,line);
//			table.add(line);
		}

		if (unsortedTable.containsKey('Ranking Guides')){
			table.add(unsortedTable.get('Ranking Guides'));
			unsortedTable.remove('Ranking Guides');
		}
		if (unsortedTable.containsKey('Practice guides')){
			table.add(unsortedTable.get('Practice guides'));
			unsortedTable.remove('Practice guides');
		}
		if (unsortedTable.containsKey('Career Guides')){
			table.add(unsortedTable.get('Career Guides'));
			unsortedTable.remove('Career Guides');
		}
		if (unsortedTable.containsKey('BI')){
			table.add(unsortedTable.get('BI'));
			unsortedTable.remove('BI');
		}
		if (unsortedTable.containsKey('Events')){
			table.add(unsortedTable.get('Events'));
			unsortedTable.remove('Events');
		}
		for(String publicationTypecategory :unsortedTable.keySet() ){
			table.add(unsortedTable.get(publicationTypecategory));
		}
		return table;
	}

	@AuraEnabled
	public static Map<String, Object> getProduct(String opportunityProductId, String currentOppId){
		try {

			Map<String, SObjectType> sObjects = Schema.getGlobalDescribe();
			Set<String> selectFields = new Set<String>();

			// get all fields of an object
			selectFields = getFields('OpportunityLineItem', sObjects);

			// create SOQL
			String soql = 'SELECT ' + String.join(new List<String>(selectFields), ',') + ' FROM OpportunityLineItem OBJ WHERE Id =: opportunityProductId';
			List<OpportunityLineItem> original = (List<OpportunityLineItem>)Database.query(soql);
			System.debug(original[0]);

			OpportunityLineItem add = original[0].clone();

			add.TotalPrice = null;
			add.OpportunityId = (Id)currentOppId;
			insert add;
			System.debug(add);

			return new Map<String, Object> {
				'status' => 'success'
			};
		} catch (Exception ex) {
			System.debug('error');
			System.debug(ex.getMessage());
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}

	private static Set<String> getFields(String objName, Map<String, SObjectType> sObjects) {
		Set<String> selectFields = new Set<String>();
		Map<String, Schema.SObjectField> sObjectFieldMap = sObjects.get(objName).getDescribe().fields.getMap();
		for (Schema.SObjectField ft : sObjectFieldMap.values()) {
			Schema.DescribeFieldResult fd = ft.getDescribe();
			if (fd.isCreateable()) {
				selectFields.add(fd.getName());
			}
		}
		return selectFields;
	}

	public class PublicationTypeCategoryWrapper {
		@AuraEnabled
		String publicationTypeCategory {get;set;}
		@AuraEnabled
		List<PublicationTypeWrapper> publicationTypes {get;set;}
		@AuraEnabled
		Boolean expanded {get;set;}
		PublicationTypeCategoryWrapper(){
			this.expanded = FALSE;
		}
	}

	public class PublicationTypeWrapper implements Comparable {
		@AuraEnabled
		String publicationType {get;set;}
		@AuraEnabled
		List<WrapperTotalRow> totalRows {get;set;}
		@AuraEnabled
		Boolean expanded {get;set;}
		PublicationTypeWrapper(){
			this.expanded = FALSE;
		}

		public void addWrapperPriceBookTable(List<OpportunityLineItem> oplis){
			Map<String, List<OpportunityLineItem>> sortByPublicationName = new Map<String, List<OpportunityLineItem>>();
			for(OpportunityLineItem opli : oplis){
				if(sortByPublicationName.containsKey(opli.Publication__r.Name)){
					sortByPublicationName.get(opli.Publication__r.Name).add(opli);
				} else {
					sortByPublicationName.put(opli.Publication__r.Name, new List<OpportunityLineItem>{opli});
				}
			}
			for (String publicationName : sortByPublicationName.keySet()){
				WrapperTotalRow wtr = new WrapperTotalRow();
				wtr.publicationNAme = publicationName;
				wtr.expanded = FALSE;
				wtr.year = sortByPublicationName.get(publicationName)[0].Publication__r.Year_Issue_RE__c;
				for(OpportunityLineItem opli : sortByPublicationName.get(publicationName)){
					wtr.addProduct(opli);
				}
				this.totalRows.add(wtr);
			}
			this.totalRows.sort();
		}

		public Integer compareTo(Object param) {
			PublicationTypeWrapper com = (PublicationTypeWrapper)param;
			Integer returnValue = 0;
			if (publicationType > com.publicationType) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (publicationType > com.publicationType) {
				// Set return value to a negative value.
				returnValue = -1;
			}
			return returnValue;
		}
	}

	public class WrapperTotalRow implements Comparable {
		@AuraEnabled
		String publicationName { get; set; }
		@AuraEnabled
		Boolean expanded { get; set; }
		@AuraEnabled
		Decimal totalPrice { get; set; }
		@AuraEnabled
		List <WrapperProductRow> products { get; set; }
		String year {get;set;}
		WrapperTotalRow() {
			this.products = new List <WrapperProductRow>();
			this.totalPrice = 0;
		}

		void addProduct(OpportunityLineItem opli) {
			WrapperProductRow row = new WrapperProductRow();
			row.publication = opli.Publication__r.Name;
			row.oppId = opli.OpportunityId;
			row.product = opli.Product2.Name;
			row.quantity = opli.Quantity;
			row.totalPrice = opli.TotalPrice;
			row.salesPerson = opli.Opportunity.Owner.Name;
			row.signer = opli.Opportunity.Signer_text__c;
			row.closeDate = opli.Opportunity.CloseDate;
			row.relatedOrganization = opli.Related_Organization__r.Name;
			row.chapter = opli.Chapter__r.Name;
			row.parentAccount = opli.Opportunity.Account.Name;
			row.location = opli.Location__r.Name;
			row.numberOfSubmissions = opli.Submissions__c;
			row.addBatton = (currentOpportunity.StageName == 'Open' || currentOpportunity.StageName == 'Qualified') &&
				currentOpportunity.Publication_RE__r.CC_PublicationTypeCategory__c == opli.Publication__r.CC_PublicationTypeCategory__c
				&& currentOpportunity.Pricebook2Id == opli.Opportunity.Pricebook2Id;
//			row.addBatton = TRUE;
			row.oppLineItemId = opli.Id;
			this.products.add(row);
			this.totalPrice += opli.TotalPrice;
		}

		public Integer compareTo (Object compareTo) {
			// Cast argument to WrapperTotalRow
			WrapperTotalRow compareToPublication = (WrapperTotalRow)compareTo;

			// The return value of 0 indicates that both elements are equal.
			Integer returnValue = 0;
			if (year < compareToPublication.year) {
				// Set return value to a positive value.
				returnValue = 1;
			} else if (year > compareToPublication.year) {
				// Set return value to a negative value.
				returnValue = -1;
			}
			return returnValue;
		}
	}

	public class WrapperProductRow {
		@AuraEnabled
		String publication { get; set; }
		@AuraEnabled
		String oppId { get; set; }
		@AuraEnabled
		String product { get; set; }
		@AuraEnabled
		Decimal quantity { get; set; }
		@AuraEnabled
		Decimal totalPrice { get; set; }
		@AuraEnabled
		String salesPerson { get; set; }
		@AuraEnabled
		String signer { get; set; }
		@AuraEnabled
		Date closeDate { get; set; }
		@AuraEnabled
		String relatedOrganization { get; set; }
		@AuraEnabled
		String chapter { get; set; }
		@AuraEnabled
		String parentAccount { get; set; }
		@AuraEnabled
		String location { get; set; }
		@AuraEnabled
		Decimal numberOfSubmissions { get; set; }
		@AuraEnabled
		Boolean addBatton {get;set;}
		@AuraEnabled
		String oppLineItemId {get;set;}
	}
}