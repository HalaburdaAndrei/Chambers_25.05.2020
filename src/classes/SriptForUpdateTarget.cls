
public with sharing class SriptForUpdateTarget {

    public void UpdateTarget() {
//// 1 script
        Map<String,String> mapPublTarget1 = new Map<String, String>();
        for(Publication_Target__c pubTar : [SELECT Id, Publication__c, Product_Category__c FROM Publication_Target__c]){
            if(!mapPublTarget1.containsKey(pubTar.Publication__c+'-'+pubTar.Product_Category__c)){
                mapPublTarget1.put(pubTar.Publication__c+'-'+pubTar.Product_Category__c, pubTar.Id);
            }
        }

        List<Publication_Target__c> publicationTargets = new List<Publication_Target__c>();
        for (AggregateResult item : [SELECT SUM(TotalPrice)TotalPrice, Publication__c, Product2.Product_Category__c
        FROM OpportunityLineItem
        WHERE Opportunity.StageName = 'Closed Won'
        AND Opportunity.CloseDate >= 2019-01-01
        AND Publication__c != null
        AND (Publication__r.Year_Issue_RE__c = '2020'
        OR Publication__r.Year_Issue_RE__c = '2021'
        OR Publication__r.Year_Issue_RE__c = '2022'
        OR Publication__r.Year_Issue_RE__c = '2023'
        OR Publication__r.Year_Issue_RE__c = '2024'
        OR Publication__r.Year_Issue_RE__c = '2025')
        GROUP BY Publication__c, Product2.Product_Category__c]) {

//            if(item.get('Publication_Target__c') == null){
            if(!mapPublTarget1.containsKey((String) item.get('Publication__c')+'-'+(String) item.get('Product_Category__c'))){
                publicationTargets.add(new Publication_Target__c(
                        Product_Total_Price__c = (Decimal) item.get('TotalPrice'),
                        Publication__c = (String) item.get('Publication__c'),
                        Product_Category__c = (String) item.get('Product_Category__c')
                ));
            }else {
                publicationTargets.add(new Publication_Target__c(Id = mapPublTarget1.get((String) item.get('Publication__c')+'-'+(String) item.get('Product_Category__c')),
                        Product_Total_Price__c = (Decimal) item.get('TotalPrice'),
                        Publication__c = (String) item.get('Publication__c'),
                        Product_Category__c = (String) item.get('Product_Category__c')
                ));
            }
        }
        if (!publicationTargets.isEmpty()) {
            upsert publicationTargets;
        }



////////// 2 script запускать несколько раз
        Map<String,String> mapPublTarget = new Map<String, String>();
        for(Publication_Target__c pubTar : [SELECT Id, Publication__c, Product_Category__c FROM Publication_Target__c]){
            if(!mapPublTarget.containsKey(pubTar.Publication__c+'-'+pubTar.Product_Category__c)){
                mapPublTarget.put(pubTar.Publication__c+'-'+pubTar.Product_Category__c, pubTar.Id);
            }
        }

        List<OpportunityLineItem> listUpdateOppProd = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppProd : [SELECT Publication__c, Product2.Product_Category__c, Publication_Target__c
        FROM OpportunityLineItem
        WHERE Opportunity.StageName = 'Closed Won'
        AND Opportunity.CloseDate >= 2019-01-01
        AND Opportunity.CloseDate >= 2021-01-01
        AND Publication__c != null
        AND (Publication__r.Year_Issue_RE__c = '2020'
        OR Publication__r.Year_Issue_RE__c = '2021'
        OR Publication__r.Year_Issue_RE__c = '2022'
        OR Publication__r.Year_Issue_RE__c = '2023'
        OR Publication__r.Year_Issue_RE__c = '2024'
        OR Publication__r.Year_Issue_RE__c = '2025')]){

            if(mapPublTarget.containsKey(oppProd.Publication__c+'-'+oppProd.Product2.Product_Category__c)){
                oppProd.Publication_Target__c = mapPublTarget.get(oppProd.Publication__c+'-'+oppProd.Product2.Product_Category__c);
                listUpdateOppProd.add(oppProd);
            }
        }

        update listUpdateOppProd;

///// это для Sales Target запускать по несколько месяцев
/////   add Prod Category

        List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
        Map<String, Sales_Target__c> mapSalesTarget = new Map<String, Sales_Target__c>();
        for (AggregateResult item : [
                SELECT SUM(TotalPrice)TotalPrice, Publication__c, Opportunity.OwnerId, Sales_Target__c, Product2.Product_Category__c, CALENDAR_MONTH(Opportunity.CloseDate)month, CALENDAR_YEAR(Opportunity.CloseDate)year
                FROM OpportunityLineItem
                WHERE Opportunity.StageName = 'Closed Won'
                AND Opportunity.CloseDate >= 2019-01-01
                AND Opportunity.CloseDate <= 2019-05-01
                AND Publication__c != null
                GROUP BY Publication__c, Opportunity.OwnerId, Sales_Target__c, Product2.Product_Category__c, CALENDAR_MONTH(Opportunity.CloseDate), CALENDAR_YEAR(Opportunity.CloseDate)
        ]) {

            if (!mapSalesTarget.containsKey((String) item.get('Publication__c')+'-'+(String) item.get('OwnerId')+'-'+Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1))) {
                mapSalesTarget.put((String) item.get('Publication__c')+'-'+(String) item.get('OwnerId')+'-'+Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1), new Sales_Target__c(Date__c = Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1), Sales_Person__c = (String) item.get('OwnerId'), Publication__c = (String) item.get('Publication__c'), Product_Total_Price__c = 0, Directory_Sales__c = 0, Insights_Sales__c = 0));
            }
            mapSalesTarget.get((String) item.get('Publication__c')+'-'+(String) item.get('OwnerId')+'-'+Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1)).Product_Total_Price__c += (Decimal) item.get('TotalPrice');
            if ((String) item.get('Product_Category__c') == 'Unpublished Report') {
                mapSalesTarget.get((String) item.get('Publication__c')+'-'+(String) item.get('OwnerId')+'-'+Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1)).Insights_Sales__c += (Decimal) item.get('TotalPrice');
            } else {
                mapSalesTarget.get((String) item.get('Publication__c')+'-'+(String) item.get('OwnerId')+'-'+Date.newInstance((Integer)item.get('year'), (Integer)item.get('month'), 1)).Directory_Sales__c += (Decimal) item.get('TotalPrice');

            }
        }

        for(Sales_Target__c st : [SELECT Id, Sales_Person__c, Publication__c, Date__c FROM Sales_Target__c]){
            if(mapSalesTarget.containsKey(st.Publication__c+'-'+st.Sales_Person__c+'-'+st.Date__c)){
                mapSalesTarget.get(st.Publication__c+'-'+st.Sales_Person__c+'-'+st.Date__c).Id = st.Id;
                System.debug(mapSalesTarget.get(st.Publication__c+'-'+st.Sales_Person__c+'-'+st.Date__c));
            }
        }

        if (!mapSalesTarget.isEmpty()) {
            upsert mapSalesTarget.values();
        }

        List<OpportunityLineItem> listUpdateOppProd1 = new List<OpportunityLineItem>();
        for(OpportunityLineItem oppProd : [SELECT Publication__c, Opportunity.OwnerId, Opportunity.CloseDate, Sales_Target__c
        FROM OpportunityLineItem
        WHERE Opportunity.StageName = 'Closed Won'
        AND Opportunity.CloseDate >= 2019-01-01
        AND Opportunity.CloseDate <= 2019-05-01
        AND Publication__c != null
        AND (Publication__r.Year_Issue_RE__c = '20219'
        OR Publication__r.Year_Issue_RE__c = '2020'
        OR Publication__r.Year_Issue_RE__c = '2021'
        OR Publication__r.Year_Issue_RE__c = '2022'
        OR Publication__r.Year_Issue_RE__c = '2023'
        OR Publication__r.Year_Issue_RE__c = '2024'
        OR Publication__r.Year_Issue_RE__c = '2025')]){

            if(mapSalesTarget.containsKey(oppProd.Publication__c+'-'+oppProd.Opportunity.OwnerId+'-'+Date.newInstance(oppProd.Opportunity.CloseDate.year(), oppProd.Opportunity.CloseDate.month(), 1))){
                oppProd.Sales_Target__c = mapSalesTarget.get(oppProd.Publication__c+'-'+oppProd.Opportunity.OwnerId+'-'+Date.newInstance(oppProd.Opportunity.CloseDate.year(), oppProd.Opportunity.CloseDate.month(), 1)).Id;
                listUpdateOppProd1.add(oppProd);
                System.debug(oppProd);
            }
        }

        if(listUpdateOppProd1.size() > 0){
            update listUpdateOppProd1;
        }



        ///////////////////////////////////////////
//        List<Opportunity> listOpportunities = [SELECT Id, StageName, Owner.Name, CloseDate FROM Opportunity WHERE StageName = 'Closed Won' AND CloseDate >= 2020-01-01];
//
//        List<OpportunityLineItem> listOpportunityLineItems = [SELECT Id FROM OpportunityLineItem WHERE OpportunityId IN: listOpportunities];
//        System.debug(listOpportunityLineItems.size());

        List<Sales_Target__c> st = new List<Sales_Target__c>();
        for(Sales_Target__c s : [SELECT Id, OwnerId, Owner.IsActive, Sales_Person__c, Sales_Person__r.IsActive FROM Sales_Target__c]){
            if(s.Sales_Person__c != s.OwnerId && s.Sales_Person__r.IsActive == TRUE ){
                s.OwnerId = s.Sales_Person__c;
                st.add(s);
            }
        }
        if(st.size() > 0){
            update st;
        }

        //////////////////////////////////////////////////
    }
}