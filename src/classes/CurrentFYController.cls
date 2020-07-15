global with sharing class CurrentFYController {
	@AuraEnabled
	public static Map<String, Object> getOpportunities(String opportunityId) {
		try {
			Map<String, Object> result = new Map<String, Object>();

			String HOAccount = [SELECT Id, AccountId, Account.Related_HO_Account__c FROM Opportunity WHERE Id = :opportunityId].Account.Related_HO_Account__c;
			String HOAccountId = '%' + HOAccount.substring(10, 25) + '%';
			result.put('HOAccount', HOAccount);

			List <Opportunity> allOpportunitiesForHOAccaunt = [
					SELECT Id, Publication__c, CC_Publication_Name__c, Publication_RE__r.Id, Current_FY__c, Name, Signer_text__c, CloseDate, Pricebook2Id,
						Pricebook2.Name, Num_of_Submissions__c, CC_User_Name_Sales__c, Owner.Name, Account.Name, Publication_RE__r.CC_PublicationTypeCategory__c,
						(SELECT Product2.Complete_Product_Name__c, Product2.Name, Quantity, UnitPrice, TotalPrice, Related_Organization__r.Name,
							Chapter__r.Name, Product2.Family,Publication__r.Name, Location__r.Name
						FROM OpportunityLineItems)
					FROM Opportunity
					WHERE Account.Related_HO_Account__c LIKE :HOAccountId
						AND StageName = 'Closed Won' AND Id != :opportunityId AND Current_FY__c = TRUE
					ORDER BY Id
				];
			List<PublicationTypeCategoryWrapper> table = prepareTable((allOpportunitiesForHOAccaunt));

			result.put('table', table);
			return result;
		} catch (Exception ex) {
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}
	@AuraEnabled
	public static Map<String, Object> getOpportunitiesSearch (Map<String, String> params) {
		//Id of HO account for current opportunity
		try {
			System.debug('getOpportunitiesSearch');
			String stage = 'Closed Won';
			String opportunityId = params.get('recordId');

			String publicationFilter = '%'+params.get('publicationFilter')+'%';
			Date closeDate;

			Map<String, Object> result = new Map<String, Object>();

			String HOAccount = [SELECT Id, AccountId, Account.Related_HO_Account__c FROM Opportunity WHERE Id = :opportunityId].Account.Related_HO_Account__c;
			String HOAccountId = '%' + HOAccount.substring(10, 25) + '%';
			result.put('HOAccount', HOAccount);

			String queryString = 'SELECT Id, Publication__c, CC_Publication_Name__c, Publication_RE__r.Id, Current_FY__c, Name, Signer_text__c, CloseDate, Pricebook2Id, '+
										'Pricebook2.Name, Num_of_Submissions__c, CC_User_Name_Sales__c, Owner.Name, Account.Name, '+
										'('+
											'SELECT Product2.Complete_Product_Name__c, Product2.Name, Quantity, UnitPrice, TotalPrice, Related_Organization__r.Name, '+
											'Chapter__r.Name, Product2.Family,Publication__r.Name, Location__r.Name '+
											'FROM OpportunityLineItems ' +
											'WHERE  Publication__r.Name LIKE :publicationFilter ';

			if(String.isNotEmpty(params.get('productFilter'))){
				queryString = queryString + 'AND Product2.Name LIKE \'%'+params.get('productFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('relatedOrganizationFilter'))){
				queryString = queryString + 'AND Related_Organization__r.Name LIKE \'%'+params.get('relatedOrganizationFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('chapterFilter'))){
				queryString = queryString + 'AND Chapter__r.Name LIKE \'%'+params.get('chapterFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('locationFilter'))){
				queryString = queryString + 'AND Location__r.Name LIKE \'%'+params.get('locationFilter')+'%\' ';
			}
			if (String.isNotEmpty(params.get('qtyFilter'))){
				queryString = queryString + ' AND Quantity = ' +params.get('qtyFilter');
			}
			if (String.isNotEmpty(params.get('salesPriceFilter'))){
				queryString = queryString + ' AND TotalPrice = '+params.get('salesPriceFilter');
			}
			queryString = queryString +
					' ORDER BY Publication__r.Name ASC) '+
				'FROM Opportunity '+
				'WHERE Account.Related_HO_Account__c LIKE :HOAccountId '+
				'AND StageName = :stage ' +
				'AND Id != :opportunityId AND Current_FY__c = TRUE ';

			if(String.isNotEmpty(params.get('salesPersonFilter'))){
				queryString = queryString + 'AND Owner.Name LIKE \'%'+params.get('salesPersonFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('signerFilter'))){
				queryString = queryString + 'AND Signer_text__c LIKE \'%'+params.get('signerFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('parentAccountFilter'))){
				queryString = queryString + 'AND Account.Name LIKE LIKE \'%'+params.get('parentAccountFilter')+'%\' ';
			}

			if(String.isNotEmpty(params.get('closeDateFilter'))){
				closeDate = Date.valueOf(params.get('closeDateFilter'));
				queryString = queryString + 'AND CloseDate = :closeDate ';
			}
			if(String.isNotEmpty(params.get('numberOfSubmissionsFilter'))){
				queryString = queryString + 'AND Num_of_Submissions__c = ' +params.get('numberOfSubmissionsFilter');
			}
			if(String.isNotEmpty(params.get('oppIdFilter'))){
//				if (params.get('oppIdFilter') instanceOf Id) {
					queryString = queryString + 'AND Id =\'' + params.get('oppIdFilter') + '\'';
//				}
			}

			queryString = queryString + ' ORDER BY CloseDate';

			List <Opportunity> allOpportunitiesForHOAccaunt = Database.query(queryString);

			List<PublicationTypeCategoryWrapper> table = prepareTable(allOpportunitiesForHOAccaunt);

			result.put('table', table);
			result.put('status','success');
			System.debug(table);
			return result;

		}  catch (Exception ex) {
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}

//	private static List<WrapperPriceBookTable> prepareTable (List <Opportunity> allOpportunitiesForHOAccaunt){
//		Map<Id, List<Opportunity>> sortByPrice = new Map<Id, List<Opportunity>>();
//		for (Opportunity opp : allOpportunitiesForHOAccaunt) {
//			if (sortByPrice.containsKey(opp.Pricebook2Id)) {
//				sortByPrice.get(opp.Pricebook2Id).add(opp);
//			} else {
//				sortByPrice.put(opp.Pricebook2Id, New List<Opportunity>{
//					opp
//				});
//			}
//		}
//		List<WrapperPriceBookTable> table = new List<WrapperPriceBookTable>();
//
//		for (Id PriceBookId : sortByPrice.keySet()) {
//			WrapperPriceBookTable priceBook = new WrapperPriceBookTable();
//			priceBook.PriceBokName = sortByPrice.get(PriceBookId)[0].Pricebook2.Name;
//
//			Map<Id, List<Opportunity>> sortedByPublication = new Map<Id, List<Opportunity>>();
//
//			for (Opportunity opp : sortByPrice.get(PriceBookId)) {
//				if (sortedByPublication.containsKey(opp.Publication_RE__r.Id)) {
//					sortedByPublication.get(opp.Publication_RE__r.Id).add(opp);
//				} else {
//					sortedByPublication.put(opp.Publication_RE__r.Id, New List<Opportunity>{
//						opp
//					});
//				}
//			}
//
//			for (Id id : sortedByPublication.keyset()) {
//				List <Opportunity> oppList = sortedByPublication.get(id);
//				WrapperTotalRow totalRow = new WrapperTotalRow();
//				totalRow.publication = oppList[0].Publication__c;
//
//				List <WrapperProductRow> productRows = new List<WrapperProductRow>();
//				for (Opportunity opp : oppList) {
//					for (OpportunityLineItem l : opp.OpportunityLineItems) {
//						WrapperProductRow line = new WrapperProductRow();
//						totalRow.totalPrice = totalRow.totalPrice + l.TotalPrice;
//						line.publication = l.Publication__r.Name;
//						line.oppId = opp.Id;
//						line.product = l.Product2.Name;
//						line.quantity = l.Quantity;
//						line.totalPrice = l.TotalPrice;
//						line.salesPerson = opp.Owner.Name;
//						line.signer = opp.Signer_text__c;
//						line.closeDate = opp.CloseDate;
//						line.relatedOrganization = l.Related_Organization__r.Name;
//						line.chapter = l.Chapter__r.Name;
//						line.parentAccount = opp.Account.Name;
//						line.location = l.Location__r.Name;
//						line.numberOfSubmissions = opp.Num_of_Submissions__c;
//						productRows.add(line);
//					}
//					totalRow.products = productRows;
//				}
//				if(totalRow.products.size()>0) {
//					priceBook.wrapperTotalRows.add(totalRow);
//				}
//			}
//			if(priceBook.wrapperTotalRows.size()>0) {
//				table.add(priceBook);
//			}
//		}
//		return table;
//	}

	private static List<PublicationTypeCategoryWrapper> prepareTable (List <Opportunity> allOpportunitiesForHOAccaunt) {

		Map<String, List<Opportunity>> sortBypPublicationTypeCategory = new Map<String, List<Opportunity>>();
		for (Opportunity opp : allOpportunitiesForHOAccaunt) {
			if (sortBypPublicationTypeCategory.containsKey(opp.Publication_RE__r.CC_PublicationTypeCategory__c)) {
				sortBypPublicationTypeCategory.get(opp.Publication_RE__r.CC_PublicationTypeCategory__c).add(opp);
			} else {
				sortBypPublicationTypeCategory.put(opp.Publication_RE__r.CC_PublicationTypeCategory__c, New List<Opportunity> {
					opp
				});
			}
		}
		List<PublicationTypeCategoryWrapper> table = new List<PublicationTypeCategoryWrapper>();
		for (String publicationTypeCategory : sortBypPublicationTypeCategory.keySet()) {
			PublicationTypeCategoryWrapper line = new PublicationTypeCategoryWrapper();
			line.publicationTypeCategory = publicationTypeCategory;
			table.add(line);

		}
		return table;
	}

//	private static List<PublicationTypeCategoryWrapper> prepareTable (List <Opportunity> allOpportunitiesForHOAccaunt){
//		System.debug('prepareTable2');
//		Map<String, List<Opportunity>> sortByPrice = new Map<String, List<Opportunity>>();
//		for (Opportunity opp : allOpportunitiesForHOAccaunt) {
//			if (sortByPrice.containsKey(opp.Publication_RE__r.CC_PublicationTypeCategory__c)) {
//				sortByPrice.get(opp.Publication_RE__r.CC_PublicationTypeCategory__c).add(opp);
//			} else {
//				sortByPrice.put(opp.Publication_RE__r.CC_PublicationTypeCategory__c, New List<Opportunity>{
//					opp
//				});
//			}
//		}
//
//		List<WrapperPriceBookTable> table = new List<WrapperPriceBookTable>();
//		for (Id PriceBookId : sortByPrice.keySet()) {
//			Map<Id, WrapperTotalRow> sortByPublication = new Map<Id, WrapperTotalRow>();
//
//			List<Opportunity> opportunitiesOnePriseBook =  sortByPrice.get(PriceBookId);
//			for (Opportunity opp : opportunitiesOnePriseBook){
//
//				for(OpportunityLineItem opli: opp.OpportunityLineItems){
//					WrapperProductRow line = new WrapperProductRow();
//					line.publication = opli.Publication__r.Name;
//					line.product = opli.Product2.Name;
//					line.oppId = opp.Id;
//					line.quantity = opli.Quantity;
//					line.totalPrice = opli.TotalPrice;
//					line.salesPerson = opp.Owner.Name;
//					line.signer = opp.Signer_text__c;
//					line.closeDate = opp.CloseDate;
//					line.relatedOrganization = opli.Related_Organization__r.Name;
//					line.chapter = opli.Chapter__r.Name;
//					line.parentAccount = opp.Account.Name;
//					line.location = opli.Location__r.Name;
//					line.numberOfSubmissions = opp.Num_of_Submissions__c;
//					if( sortByPublication.containsKey(opli.Publication__c)){
//						sortByPublication.get(opli.Publication__c).addProduct(line,opli.TotalPrice);
//					} else {
//						sortByPublication.put(opli.Publication__c, new WrapperTotalRow(opli.Publication__r.Name, opli.TotalPrice, new List<WrapperProductRow>{line}));
//					}
//				}
//			}
//			WrapperPriceBookTable a = new WrapperPriceBookTable();
//
//			a.PriceBokName = opportunitiesOnePriseBook[0].Publication_RE__r.CC_PublicationTypeCategory__c;
//			a.wrapperTotalRows = sortByPublication.values();
//			table.add(a);
//		}
//		return table;
//	}

	public class PublicationTypeCategoryWrapper {
		@AuraEnabled
		String publicationTypeCategory {get;set;}
	}



    public class WrapperPriceBookTable {
        @AuraEnabled
        List <WrapperTotalRow> wrapperTotalRows { get; set; }
        @AuraEnabled
        String PriceBokName { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }
        WrapperPriceBookTable(){
            wrapperTotalRows = new List<WrapperTotalRow>();
            expanded = true;
        }
    }

    public class WrapperTotalRow {
        @AuraEnabled
        String publication { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }
        @AuraEnabled
        Decimal totalPrice { get; set; }
        @AuraEnabled
        List <WrapperProductRow> products { get; set; }
	    WrapperTotalRow(String publicationName, Decimal totalPrice, List<WrapperProductRow> rows) {
		    this.totalPrice = totalPrice;
		    this.publication = publicationName;
		    this.expanded = TRUE;
		    this.products = rows;
	    }

	    void addProduct(WrapperProductRow pr, Decimal price){
		    this.totalPrice = this.totalPrice + price;
		    products.add(pr);
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
    }
}