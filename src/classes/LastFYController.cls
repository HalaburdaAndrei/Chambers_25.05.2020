public with sharing class LastFYController {
    @AuraEnabled
    public static Map<String, Object> getOpportunities(String opportunityId) {
        //Id of HO account for current opportunity
        try {
            Map<String, Object> result = new Map<String, Object>();
	        Opportunity currentOpportunity = [SELECT Id, AccountId, Account.Related_HO_Account__c, StageName, Pricebook2Id, Publication_RE__r.Id FROM Opportunity WHERE Id = :opportunityId];
            String HOAccountId = currentOpportunity.Account.Related_HO_Account__c.substring(10, 25);
            HOAccountId = '%' + HOAccountId + '%';

            Date startLastFY;
            Date endLastFY;
            if(Date.today() >= Date.newInstance(Date.today().year(),6,01)){
                startLastFY = Date.newInstance(Date.today().year()-1,6,01);
                endLastFY = Date.newInstance(Date.today().year(),6,01);
            } else {
                startLastFY = Date.newInstance(Date.today().year()-2,6,01);
                endLastFY = Date.newInstance(Date.today().year()-1,6,01);
            }

            List <Opportunity> allOpportunitiesForHOAccaunt = [
                    SELECT Id, Publication__c, CC_Publication_Name__c, Publication_RE__r.Id, Current_FY__c, Name, Signer_text__c, CloseDate, Pricebook2Id, Pricebook2.Name, Num_of_Submissions__c, Account.Name, Owner.Name,
                    (SELECT Id, Product2.Complete_Product_Name__c, Product2.Name, Quantity, UnitPrice, TotalPrice, Related_Organization__r.Name, Chapter__r.Name, Product2.Family, Publication__r.Name, Location__r.Name
                    FROM OpportunityLineItems)
                    FROM Opportunity
                    WHERE Account.Related_HO_Account__c LIKE :HOAccountId AND StageName = 'Closed Won'
                        AND Id != :opportunityId AND Current_FY__c = FALSE
                        AND CloseDate < :endLastFY AND CloseDate > :startLastFY
                    ORDER BY Id
            ];

	        List<WrapperPriceBookTable> table = prepareTable(allOpportunitiesForHOAccaunt, currentOpportunity);
            result.put('table', table);
	        result.put('status','success');
            return result;
        }  catch (Exception ex) {
            return new Map<String, Object> {
                    'status' => 'error',
                    'message' => ex.getMessage()};
        }
    }

	@AuraEnabled
	public static Map<String, Object> getOpportunitiesSearch (Map<String, String> params) {
		//Id of HO account for current opportunity
		try {
			String opportunityId = params.get('recordId');
			Opportunity currentOpportunity = [SELECT Id, AccountId, Account.Related_HO_Account__c, StageName, Pricebook2Id, Publication_RE__r.Id FROM Opportunity WHERE Id = :opportunityId];
			Date today = Date.today();
			Date startLastFY;
			Date endLastFY;
			if(Date.today() >= Date.newInstance(Date.today().year(),6,01)){
				startLastFY = Date.newInstance(Date.today().year()-1,6,01);
				endLastFY = Date.newInstance(Date.today().year(),6,01);
			} else {
				startLastFY = Date.newInstance(Date.today().year()-2,6,01);
				endLastFY = Date.newInstance(Date.today().year()-1,6,01);
			}

			String stage = 'Closed Won';


			String publicationFilter = '%'+params.get('publicationFilter')+'%';

			Date closeDate;
			Integer qty;

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
				' ) '+
				'FROM Opportunity '+
				'WHERE Account.Related_HO_Account__c LIKE :HOAccountId '+
				'AND StageName = :stage ' +
				'AND Id != :opportunityId AND CloseDate < :endLastFY AND CloseDate > :startLastFY ';

			if(String.isNotEmpty(params.get('salesPersonFilter'))){
				queryString = queryString + 'AND Owner.Name LIKE \'%'+params.get('salesPersonFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('signerFilter'))){
				queryString = queryString + 'AND Signer_text__c LIKE \'%'+params.get('signerFilter')+'%\' ';
			}
			if(String.isNotEmpty(params.get('parentAccountFilter'))){
				queryString = queryString + 'AND Account.Name LIKE \'%'+params.get('parentAccountFilter')+'%\' ';
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

			List<WrapperPriceBookTable> table = prepareTable(allOpportunitiesForHOAccaunt, currentOpportunity);

			result.put('table', table);
			result.put('status','success');
			return result;
		}  catch (Exception ex) {
			return new Map<String, Object> {
				'status' => 'error',
				'message' => ex.getMessage()};
		}
	}

	private static List<WrapperPriceBookTable> prepareTable (List <Opportunity> allOpportunitiesForHOAccaunt, Opportunity currentOpportunity){
		System.debug('prepareTable2');
		Map<Id, List<Opportunity>> sortByPrice = new Map<Id, List<Opportunity>>();
		for (Opportunity opp : allOpportunitiesForHOAccaunt) {
			if (sortByPrice.containsKey(opp.Pricebook2Id)) {
				sortByPrice.get(opp.Pricebook2Id).add(opp);
			} else {
				sortByPrice.put(opp.Pricebook2Id, New List<Opportunity>{
					opp
				});
			}
		}
		List<WrapperPriceBookTable> table = new List<WrapperPriceBookTable>();
		for (Id PriceBookId : sortByPrice.keySet()) {
			Map<Id, WrapperTotalRow> sortByPublication = new Map<Id, WrapperTotalRow>();
			List<Opportunity> opportunitiesOnePriseBook =  sortByPrice.get(PriceBookId);
			for (Opportunity opp : opportunitiesOnePriseBook){
				for(OpportunityLineItem opli: opp.OpportunityLineItems){
					WrapperProductRow line = new WrapperProductRow();
					line.publication = opli.Publication__r.Name;
					line.product = opli.Product2.Name;
					line.oppId = opp.Id;
					line.quantity = opli.Quantity;
					line.totalPrice = opli.TotalPrice;
					line.salesPerson = opp.Owner.Name;
					line.signer = opp.Signer_text__c;
					line.closeDate = opp.CloseDate;
					line.relatedOrganization = opli.Related_Organization__r.Name;
					line.chapter = opli.Chapter__r.Name;
					line.parentAccount = opp.Account.Name;
					line.location = opli.Location__r.Name;
					line.numberOfSubmissions = opp.Num_of_Submissions__c;
					line.addBatton = ((currentOpportunity.StageName == 'Open' || currentOpportunity.StageName == 'Qualified') && currentOpportunity.Pricebook2Id == opp.Pricebook2Id && currentOpportunity.Publication_RE__r.Id == opp.Publication_RE__r.Id);
					line.lineItems = opli.Id;
					if( sortByPublication.containsKey(opli.Publication__c)){
						sortByPublication.get(opli.Publication__c).addProduct(line,opli.TotalPrice);
					} else {
						sortByPublication.put(opli.Publication__c, new WrapperTotalRow(opli.Publication__r.Name, opli.TotalPrice, new List<WrapperProductRow>{line}));
					}
				}
			}
			WrapperPriceBookTable a = new WrapperPriceBookTable();
			a.PriceBokName = opportunitiesOnePriseBook[0].Pricebook2.Name;
			a.wrapperTotalRows = sortByPublication.values();
			table.add(a);
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

    public class WrapperPriceBookTable {
        @AuraEnabled
        List <WrapperTotalRow> wrapperTotalRows { get; set; }
        @AuraEnabled
        String PriceBokName { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }
        WrapperPriceBookTable(){
            wrapperTotalRows = new List<WrapperTotalRow>();
            expanded = TRUE;
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
	        this.expanded = FALSE;
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
        String product { get; set; }
        @AuraEnabled
        String oppId { get; set; }
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
        Decimal numberOfSubmissions { get; set; }
        @AuraEnabled
        Boolean addBatton {get;set;}
	    @AuraEnabled
	    String lineItems {get;set;}
    }
}