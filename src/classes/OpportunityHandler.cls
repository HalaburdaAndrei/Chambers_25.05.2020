public with sharing class OpportunityHandler {

    public void BeforeUpdate(Map<Id, Opportunity> oppOldMap, Map<Id, Opportunity> oppNewMap) {
	    Map<Id,List<OpportunityLineItem>> oppsIdToOppLine = new Map<Id,List<OpportunityLineItem>>();
        Set<Id> userIds = new Set<Id>();
        Set<Integer> years = new Set<Integer>();
        Set<Integer> months = new Set<Integer>();


		for (Opportunity opp : oppNewMap.values()) {
			if (oppOldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won') {
                oppsIdToOppLine.put(opp.Id, new List<OpportunityLineItem>());
				userIds.add(opp.OwnerId);
				years.add(opp.CloseDate.year());
				months.add(opp.CloseDate.month());
			}
		}
        oppsIdToOppLine = getOpportunityLineItems(oppsIdToOppLine);

        List<Sales_Target__c> salesTargets = getSalesTargetsByOpportunities(userIds, years, months);
        Map<String, Sales_Target__c> existSalesTargetsMap = generateSalesTargetsMap(salesTargets);
		List<SalesTargetsByOppItem> stByOppItemList = createSalesTargetsByOppItems(oppsIdToOppLine, existSalesTargetsMap, oppNewMap);

		Set<String> categories = getCategories();
        Set<Id> publicationsId = getOpportunityLinePublication(oppsIdToOppLine);
		List<Publication_Target__c> publicationTargets = getPublicationTargets(categories, publicationsId);
		Map<String, Publication_Target__c> existPublicationTargetsMap = generatePublicationTargetsMap(publicationTargets);
		List<PublicationTargetsByOppItem> ptByOppItemList = createPublicationTargetsByOppItems(oppsIdToOppLine, existPublicationTargetsMap, oppNewMap);

		upsertOppItems(stByOppItemList, ptByOppItemList);
    }

	private void upsertOppItems(List<SalesTargetsByOppItem> stByOppItemList, List<PublicationTargetsByOppItem> ptByOppItemList) {
		Map<Id, OpportunityLineItem> oppItemToUpdate = new Map<Id, OpportunityLineItem>();
		for(SalesTargetsByOppItem stByOpp : stByOppItemList) {	
			stByOpp.oppItem.Sales_Target__c = stByOpp.st.Id;
			oppItemToUpdate.put(stByOpp.oppItem.Id, stByOpp.oppItem);
		}
		for(PublicationTargetsByOppItem ptByOpp : ptByOppItemList) {	
			ptByOpp.oppItem.Publication_Target__c = ptByOpp.pt.Id;
			oppItemToUpdate.put(ptByOpp.oppItem.Id, ptByOpp.oppItem);
		}
		update oppItemToUpdate.values();
	}

	private List<Sales_Target__c> getSalesTargetsByOpportunities(Set<Id> userIds, Set<Integer> years, Set<Integer> months) {
		return [
			SELECT
				Id,
				Sales_Person__c,
				Date__c
			FROM Sales_Target__c
			WHERE Sales_Person__c IN :userIds
			AND CALENDAR_YEAR(Date__c) IN :years
			AND CALENDAR_MONTH(Date__c) IN :months
			ORDER BY Sales_Person__c
		];
	}

	private List<Publication_Target__c> getPublicationTargets(Set<String> categories, Set<Id> publicationsId) {
		return [
			SELECT
				Id
			FROM Publication_Target__c
			WHERE Product_Category__c IN :categories
			AND Publication__c IN: publicationsId
		];
	}
    
    private Map<String, Sales_Target__c> generateSalesTargetsMap(List<Sales_Target__c> salesTargets) {
		Map<String, Sales_Target__c> existSalesTargetsMap = new Map<String, Sales_Target__c>();
		for(Sales_Target__c st : salesTargets){
			String key = st.Sales_Person__c + 'x' +
				String.valueOf(st.Date__c.year()) + '-' +
				String.valueOf(st.Date__c.month());
			// key: <SalesTarget Id>x<year>-<month>
			existSalesTargetsMap.put(key, st);
		}
        return existSalesTargetsMap;
	}

	private Map<String, Publication_Target__c> generatePublicationTargetsMap(List<Publication_Target__c> publicationTargets) {
		Map<String, Publication_Target__c> existPublicationTargetsMap = new Map<String, Publication_Target__c>();
		for(Publication_Target__c pt : publicationTargets){
			String key = pt.Publication__c + '-' + pt.Product_Category__c;
			// key: <PublicationTarget Id>-<ProductCategory>
			existPublicationTargetsMap.put(key, pt);
		}
        return existPublicationTargetsMap;
	}

    private Map<Id,List<OpportunityLineItem>> getOpportunityLineItems(Map<Id, List<OpportunityLineItem>> oppsIdToOppLine) {
        Map<Id,List<OpportunityLineItem>> result = new Map<Id,List<OpportunityLineItem>>();
        List<OpportunityLineItem> opportunityLineItems = [SELECT Id, OpportunityId, Publication__c, Product2.Product_Category__c FROM OpportunityLineItem WHERE OpportunityId IN: oppsIdToOppLine.KeySet()];
        for (OpportunityLineItem oli : opportunityLineItems) {
			if (!result.containsKey(oli.OpportunityId)) {
				result.put(oli.OpportunityId, new List<OpportunityLineItem>());
			}
            result.get(oli.OpportunityId).add(oli);
        }
        return result;
    }

    private Set<Id> getOpportunityLinePublication(Map<Id, List<OpportunityLineItem>> oppsIdToOppLine) {
		Set<Id> result = new Set<Id>();
        for (Id olId : oppsIdToOppLine.keySet()) {
			for (OpportunityLineItem oli : oppsIdToOppLine.get(olId)) {
				result.add(oli.Publication__c);
			}
        }
        return result;
	}

	private List<SalesTargetsByOppItem> createSalesTargetsByOppItems(Map<Id,List<OpportunityLineItem>> oppsIdToOppLine, Map<String, Sales_Target__c> existSalesTargetsMap, Map<Id, Opportunity> oppNewMap) {
        List<SalesTargetsByOppItem> stByOppItemList = new List<SalesTargetsByOppItem>();
        List<Sales_Target__c> newStList = new List<Sales_Target__c>();
		for(Id oppId : oppsIdToOppLine.keySet()) {
            for (OpportunityLineItem oli : oppsIdToOppLine.get(oppId)) {
				Opportunity opp = oppNewMap.get(oppId);
                String key = opp.OwnerId + 'x' +
                    String.valueOf(opp.CloseDate.year()) + '-' +
                    String.valueOf(opp.CloseDate.month());
                if (existSalesTargetsMap.containsKey(key)) {
                    stByOppItemList.add(new SalesTargetsByOppItem(
                        oli, existSalesTargetsMap.get(key)
                    ));
                } else {
                    Sales_Target__c st = new Sales_Target__c(
                        Sales_Person__c = opp.OwnerId,
                        Target__c = null,
                        Date__c = Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), 1)
                    );
                    stByOppItemList.add(new SalesTargetsByOppItem(oli, st));
                    newStList.add(st);
                }
            }
		}
		upsert newStList;
		return stByOppItemList;
	}

	private List<PublicationTargetsByOppItem> createPublicationTargetsByOppItems(Map<Id,List<OpportunityLineItem>> oppsIdToOppLine, Map<String, Publication_Target__c> existPublicationTargetsMap, Map<Id, Opportunity> oppNewMap) {
        List<PublicationTargetsByOppItem> ptByOppItemList = new List<PublicationTargetsByOppItem>();
        List<Publication_Target__c> newPtList = new List<Publication_Target__c>();
		for(Id oppId : oppsIdToOppLine.keySet()) {
            for (OpportunityLineItem oli : oppsIdToOppLine.get(oppId)) {
				String key = oli.Publication__c + '-' + oli.Product2.Product_Category__c;
                if (existPublicationTargetsMap.containsKey(key)) {
                    ptByOppItemList.add(new PublicationTargetsByOppItem(
                        oli, existPublicationTargetsMap.get(key)
                    ));
                } else {
                    Publication_Target__c pt = new Publication_Target__c(
                        Publication__c = oli.Publication__c,
                        Product_Category__c = oli.Product2.Product_Category__c
                    );
                    ptByOppItemList.add(new PublicationTargetsByOppItem(oli, pt));
                    newPtList.add(pt);
                }
            }
		}
		upsert newPtList;
		return ptByOppItemList;
	}

	private Set<String> getCategories() {
		Set<String> result = new Set<String>();
		for (AggregateResult item : [SELECT COUNT(Id), Product_Category__c FROM Product2 GROUP BY Product_Category__c]) {
			result.add((String)item.get('Product_Category__c'));
		}
		return result;
	}
    
    public class SalesTargetsByOppItem {
		public OpportunityLineItem oppItem;
		public Sales_Target__c st;
		public Publication_Target__c pt;

		public SalesTargetsByOppItem(OpportunityLineItem oppItem, Sales_Target__c st) {
			this.oppItem = oppItem;
			this.st = st;
		}
	}

    public class PublicationTargetsByOppItem {
		public OpportunityLineItem oppItem;
		public Publication_Target__c pt;

		public PublicationTargetsByOppItem(OpportunityLineItem oppItem, Publication_Target__c pt) {
			this.oppItem = oppItem;
			this.pt = pt;
		}
	}

}