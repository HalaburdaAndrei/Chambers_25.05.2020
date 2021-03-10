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
                years.add(Date.today().year());
                months.add(Date.today().month());
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

    public void AfterUpdate(Map<Id, Opportunity> oppOldMap, Map<Id, Opportunity> oppNewMap) {
        Set<Id> oppIds = new Set<Id>();
        for (Opportunity opp : oppNewMap.values()) {
            if (oppOldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won') {
                oppIds.add(opp.Id);
            }
        }

        if (!oppIds.isEmpty()) {
            Set<Id> publicationIds = new Set<Id>();
            for (AggregateResult item : [SELECT COUNT(Id), Publication__c FROM OpportunityLineItem WHERE Publication__c != null AND OpportunityId IN: oppIds GROUP BY Publication__c, OpportunityId HAVING Publication__c != null  AND OpportunityId IN: oppIds]) {
                publicationIds.add((String)item.get('Publication__c'));
            }

            List<Publication_Target__c> publicationTargets = new List<Publication_Target__c>();
            for (AggregateResult item : [SELECT SUM(TotalPrice)TotalPrice, Publication_Target__c FROM OpportunityLineItem WHERE Publication_Target__c != null AND Publication__c IN: publicationIds GROUP BY Publication_Target__c, Publication__c HAVING Publication_Target__c != null AND Publication__c IN: publicationIds]) {
                publicationTargets.add(new Publication_Target__c(Id = (String)item.get('Publication_Target__c'), Product_Total_Price__c = (Decimal)item.get('TotalPrice')));
            }
            if (!publicationTargets.isEmpty()) {
                update publicationTargets;
            }

            List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
            Map<String,Sales_Target__c> mapSalesTarget = new Map<String, Sales_Target__c>();
            for (AggregateResult item : [SELECT SUM(TotalPrice)TotalPrice, Publication__c, Product2.Product_Category__c, Sales_Target__c  FROM OpportunityLineItem WHERE Sales_Target__c != null AND Publication__c IN: publicationIds GROUP BY Sales_Target__c, Publication__c, Product2.Product_Category__c ]) {
                if(!mapSalesTarget.containsKey((String)item.get('Sales_Target__c'))){
                    mapSalesTarget.put((String)item.get('Sales_Target__c'), new Sales_Target__c(Id = (String)item.get('Sales_Target__c'), Product_Total_Price__c = 0, Directory_Sales__c = 0, Insights_Sales__c = 0));
                }
                mapSalesTarget.get((String)item.get('Sales_Target__c')).Product_Total_Price__c += (Decimal)item.get('TotalPrice');
                if((String)item.get('Product_Category__c') == 'Unpublished Report'){
                    mapSalesTarget.get((String)item.get('Sales_Target__c')).Insights_Sales__c += (Decimal)item.get('TotalPrice');
                }else{
                    mapSalesTarget.get((String)item.get('Sales_Target__c')).Directory_Sales__c += (Decimal)item.get('TotalPrice');

                }
            }

            if (!mapSalesTarget.isEmpty()) {
                update mapSalesTarget.values();
            }
        }
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
                        Publication__c,
                        Date__c,
                        OwnerId
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
                        Id, Publication__c, Product_Category__c, OwnerId
                FROM Publication_Target__c
                WHERE Product_Category__c IN :categories
                AND Publication__c IN: publicationsId
        ];
    }

    private Map<String, Sales_Target__c> generateSalesTargetsMap(List<Sales_Target__c> salesTargets) {
        Map<String, Sales_Target__c> existSalesTargetsMap = new Map<String, Sales_Target__c>();
        for(Sales_Target__c st : salesTargets){
            String key = st.Sales_Person__c + 'x' +
                    st.Publication__c + 'x' +
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
        Set<Sales_Target__c> setForUpdateStList = new Set<Sales_Target__c>();
        Map<String, Sales_Target__c> newSTmap = new Map<String, Sales_Target__c>();
        for(Id oppId : oppsIdToOppLine.keySet()) {
            for (OpportunityLineItem oli : oppsIdToOppLine.get(oppId)) {
                Opportunity opp = oppNewMap.get(oppId);
                String key = opp.OwnerId + 'x' +
                        oli.Publication__c + 'x' +
                        String.valueOf(Date.today().year()) + '-' +
                        String.valueOf(Date.today().month());
                if (existSalesTargetsMap.containsKey(key)) {
                    existSalesTargetsMap.get(key).OwnerId = opp.OwnerId;
                    stByOppItemList.add(new SalesTargetsByOppItem(
                            oli, existSalesTargetsMap.get(key)
                    ));
                    setForUpdateStList.add(existSalesTargetsMap.get(key));
                } else {
                    Sales_Target__c st = new Sales_Target__c(
                            Sales_Person__c = opp.OwnerId,
                            Publication__c = oli.Publication__c,
                            OwnerId = opp.OwnerId,
                            Target__c = null,
                            Date__c = Date.newInstance(Date.today().year(), Date.today().month(), 1)
                    );
                    existSalesTargetsMap.put(key, st);
                    stByOppItemList.add(new SalesTargetsByOppItem(oli, st));
//					newStList.add(st);
                    setForUpdateStList.add(st);
                }
            }
        }
        newStList.addAll(setForUpdateStList);
        upsert newStList;
        return stByOppItemList;
    }

    private List<PublicationTargetsByOppItem> createPublicationTargetsByOppItems(Map<Id,List<OpportunityLineItem>> oppsIdToOppLine, Map<String, Publication_Target__c> existPublicationTargetsMap, Map<Id, Opportunity> oppNewMap) {
        List<PublicationTargetsByOppItem> ptByOppItemList = new List<PublicationTargetsByOppItem>();
        List<Publication_Target__c> newPtList = new List<Publication_Target__c>();
        Set<Publication_Target__c> setforUpdatePtList = new Set<Publication_Target__c>();
        for(Id oppId : oppsIdToOppLine.keySet()) {
            for (OpportunityLineItem oli : oppsIdToOppLine.get(oppId)) {
                Opportunity opp = oppNewMap.get(oppId);
                String key = oli.Publication__c + '-' + oli.Product2.Product_Category__c;
                if (existPublicationTargetsMap.containsKey(key)) {
                    existPublicationTargetsMap.get(key).OwnerId = opp.OwnerId;
                    ptByOppItemList.add(new PublicationTargetsByOppItem(
                            oli, existPublicationTargetsMap.get(key)
                    ));
                    setforUpdatePtList.add(existPublicationTargetsMap.get(key));
                } else {
                    Publication_Target__c pt = new Publication_Target__c(
                            Publication__c = oli.Publication__c,
                            OwnerId = opp.OwnerId,
                            Product_Category__c = oli.Product2.Product_Category__c
                    );
                    existPublicationTargetsMap.put(key, pt);
                    ptByOppItemList.add(new PublicationTargetsByOppItem(oli, pt));
//					newPtList.add(pt);
                    setforUpdatePtList.add(pt);
                }

            }
        }
        newPtList.addAll(setforUpdatePtList);
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