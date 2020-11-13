public with sharing class PublicationAllocatedTarget {

    @AuraEnabled
    public static List<String> getPicklistProductCategory() {

        List<String> listUniqProductCategory = new List<String>();
        Set<String> uniqProductCategory = new Set<String>();
        List<Product2> listProducts = [SELECT Id, Product_Category__c FROM Product2 ORDER BY Product_Category__c ASC];

        if (listProducts.size() > 0) {
            for (Product2 prod : listProducts) {
                uniqProductCategory.add(prod.Product_Category__c);
            }
            for (String upd : uniqProductCategory) {
                listUniqProductCategory.add(upd);
            }
        }
        return listUniqProductCategory;

    }

    @AuraEnabled
    public static Map<String, List<PublicationRow>> generateDataTable() {

        Map<String, List<PublicationRow>> resultTable = new Map<String, List<PublicationRow>>();
        List<Publication_Target__c> listPublicationTargets = [
                SELECT
                        Id,
                        Publication__c,
                        Publication__r.Name,
                        Product_Category__c,
                        Category_Visible__c,
                        Directory_Allocated_Target__c,
                        Insights_Allocated_Target__c
                FROM Publication_Target__c
                WHERE Category_Visible__c = TRUE
        ];

        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String, Map<String, List<Publication_Target__c>>> mapPublicationTarget = new Map<String, Map<String, List<Publication_Target__c>>>();
        for (Publication_Target__c pubTarget : listPublicationTargets) {
            if (!mapPublicationTarget.containsKey(pubTarget.Publication__c)) {
                mapPublicationTarget.put(pubTarget.Publication__c, new Map<String, List<Publication_Target__c>>());
            }
            if (!mapPublicationName.containsKey(pubTarget.Publication__c)) {
                mapPublicationName.put(pubTarget.Publication__c, pubTarget.Publication__r.Name);
            }

            if (!mapPublicationTarget.get(pubTarget.Publication__c).containsKey(pubTarget.Product_Category__c)) {
                mapPublicationTarget.get(pubTarget.Publication__c).put(pubTarget.Product_Category__c, new List<Publication_Target__c>());
            }
            mapPublicationTarget.get(pubTarget.Publication__c).get(pubTarget.Product_Category__c).add(pubTarget);
        }

        List<PublicationRow> listPublicationRows = new List<PublicationRow>();
        for (String pubId : mapPublicationTarget.keySet()) {
            PublicationRow publicationRow = new PublicationRow();
            publicationRow.publicationId = pubId;
            publicationRow.publicationName = mapPublicationName.get(pubId);
            publicationRow.expanded = false;
            publicationRow.publicationAllocatedTarget = 0;
            publicationRow.publicationDirectoryAllocatedTarget = 0;
            publicationRow.publicationInsightsAllocatedTarget = 0;

            List<ProductCategoryRow> listCategoryRows = new List<ProductCategoryRow>();
            for (String prodCategory : mapPublicationTarget.get(pubId).keySet()) {
                ProductCategoryRow productCategoryRow = new ProductCategoryRow();
                productCategoryRow.productCategoryName = prodCategory;
                productCategoryRow.publicationTargets = mapPublicationTarget.get(pubId).get(prodCategory);
                listCategoryRows.add(productCategoryRow);
            }
            publicationRow.productCategaryRows = listCategoryRows;
            listPublicationRows.add(publicationRow);
        }

        if (listPublicationRows.size() > 0) {
            resultTable.put('table', listPublicationRows);
        } else {
            resultTable.put('table', null);
        }


        return resultTable;
    }

    @AuraEnabled
    public static List<PublicationRow> addPublicationApex(list<Publication__c> listNewPublications) {
        List<Publication_Target__c> listPublicationTargets = [
                SELECT Id,
                        Publication__c,
                        Product_Category__c,
                        Directory_Allocated_Target__c,
                        Insights_Allocated_Target__c
                FROM Publication_Target__c
                WHERE Publication__c IN: listNewPublications
        ];

        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String, Map<String, List<Publication_Target__c>>> mapPublicationTarget = new Map<String, Map<String, List<Publication_Target__c>>>();
        for (Publication_Target__c pubTarget : listPublicationTargets) {
            if (!mapPublicationTarget.containsKey(pubTarget.Publication__c)) {
                mapPublicationTarget.put(pubTarget.Publication__c, new Map<String, List<Publication_Target__c>>());
            }
            if (!mapPublicationName.containsKey(pubTarget.Publication__c)) {
                mapPublicationName.put(pubTarget.Publication__c, pubTarget.Publication__r.Name);
            }

            if (!mapPublicationTarget.get(pubTarget.Publication__c).containsKey(pubTarget.Product_Category__c)) {
                mapPublicationTarget.get(pubTarget.Publication__c).put(pubTarget.Product_Category__c, new List<Publication_Target__c>());
            }
            mapPublicationTarget.get(pubTarget.Publication__c).get(pubTarget.Product_Category__c).add(pubTarget);
        }

        for(Publication__c publication : listNewPublications){
            if(!mapPublicationTarget.containsKey(publication.Id)){
                mapPublicationTarget.put(publication.Id, new Map<String, List<Publication_Target__c>>());
                if (!mapPublicationName.containsKey(publication.Id)) {
                    mapPublicationName.put(publication.Id, publication.Name);
                }
            }
        }


        List<PublicationRow> listPublicationRows = new List<PublicationRow>();
        for (String pubId : mapPublicationTarget.keySet()) {
            PublicationRow publicationRow = new PublicationRow();
            publicationRow.publicationId = pubId;
            publicationRow.publicationName = mapPublicationName.get(pubId);
            publicationRow.expanded = false;
            publicationRow.publicationAllocatedTarget = 0;
            publicationRow.publicationDirectoryAllocatedTarget = 0;
            publicationRow.publicationInsightsAllocatedTarget = 0;

            List<ProductCategoryRow> listCategoryRows = new List<ProductCategoryRow>();
            for (String prodCategory : mapPublicationTarget.get(pubId).keySet()) {
                ProductCategoryRow productCategoryRow = new ProductCategoryRow();
                productCategoryRow.productCategoryName = prodCategory;
                productCategoryRow.publicationTargets = mapPublicationTarget.get(pubId).get(prodCategory);
                listCategoryRows.add(productCategoryRow);
            }
            publicationRow.productCategaryRows = listCategoryRows;
            listPublicationRows.add(publicationRow);
        }

        return listPublicationRows;

    }

    public class PublicationRow {
        @AuraEnabled
        String publicationName { get; set; }
        @AuraEnabled
        String publicationId { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }
        @AuraEnabled
        Double publicationAllocatedTarget { get; set; }
        @AuraEnabled
        Double publicationDirectoryAllocatedTarget { get; set; }
        @AuraEnabled
        Double publicationInsightsAllocatedTarget { get; set; }
        @AuraEnabled
        List<ProductCategoryRow> productCategaryRows { get; set; }

        PublicationRow() {
            productCategaryRows = new List<ProductCategoryRow>();
        }
    }

    public class ProductCategoryRow {
        @AuraEnabled
        String productCategoryName { get; set; }
        @AuraEnabled
        List<Publication_Target__c> publicationTargets { get; set; }
    }

}