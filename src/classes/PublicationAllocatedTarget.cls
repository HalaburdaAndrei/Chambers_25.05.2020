public with sharing class PublicationAllocatedTarget {

    @AuraEnabled
    public static List<String> getPicklistProductCategory() {


        Set<String> uniqProductCategory = new Set<String>();

        for (AggregateResult item : [SELECT COUNT(Id), Product_Category__c FROM Product2 GROUP BY Product_Category__c]) {
            uniqProductCategory.add((String) item.get('Product_Category__c'));
        }
        List<String> listUniqProductCategory = new List<String>(uniqProductCategory);

        return listUniqProductCategory;

    }

    @AuraEnabled
    public static List<String> getPicklistPublucationCategory() {

        Set<String> uniqPublicationCategory = new Set<String>{
                'All Category'
        };

        for (AggregateResult item : [SELECT COUNT(Id), CC_PublicationTypeCategory__c FROM Publication__c GROUP BY CC_PublicationTypeCategory__c]) {
            uniqPublicationCategory.add((String) item.get('CC_PublicationTypeCategory__c'));
        }
        List<String> listUniqOublicationCategory = new List<String>(uniqPublicationCategory);

        return listUniqOublicationCategory;
    }

    @AuraEnabled
    public static Map<String, List<PublicationRow>> generateDataTable(String year) {

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
                AND Publication__r.Year_Issue_RE__c =: year
                ORDER BY Publication__r.Name, Product_Category__c ASC
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
            if (pubTarget.Directory_Allocated_Target__c == null) {
                pubTarget.Directory_Allocated_Target__c = 0;
            }
            if (pubTarget.Insights_Allocated_Target__c == null) {
                pubTarget.Insights_Allocated_Target__c = 0;
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
    public static List<PublicationRow> addPublicationApex(String publicationCategory, String year, String jsonOldResult) {
        List<String> listCategoryforRankingGuides = new List<String>{
                'Firm Profile', 'Individual Profile', 'PFO', 'Unpublished Report'
        };
        List<String> listCategoryforPracticeGuides = new List<String>{
                'Q&A', 'T&D'
        };
        List<Publication_Target__c> upsertPublicationTargets = new List<Publication_Target__c>();

        List<Publication__c> listPublications = new List<Publication__c>();
        if (publicationCategory != 'All Category') {
            listPublications = [
                    SELECT Id, Name, CC_PublicationTypeCategory__c, Year_Issue_RE__c
                    FROM Publication__c
                    WHERE Year_Issue_RE__c = :year
                    AND CC_PublicationTypeCategory__c = :publicationCategory
            ];
        } else {
            listPublications = [
                    SELECT Id, Name, CC_PublicationTypeCategory__c, Year_Issue_RE__c
                    FROM Publication__c
                    WHERE Year_Issue_RE__c = :year
            ];
        }


        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Set<String> setProductCategory = new Set<String>();
        Map<String, Map<String, List<Publication_Target__c>>> mapPublicationTarget = new Map<String, Map<String, List<Publication_Target__c>>>();

        for (Publication__c publication : listPublications) {
            if (!mapPublicationTarget.containsKey(publication.Id)) {
                mapPublicationTarget.put(publication.Id, new Map<String, List<Publication_Target__c>>());
            }
            if (publication.CC_PublicationTypeCategory__c == 'Practice Guides') {
                for (String category : listCategoryforPracticeGuides) {
                    setProductCategory.add(category);
                    if (!mapPublicationTarget.get(publication.Id).containsKey(category)) {
                        mapPublicationTarget.get(publication.Id).put(category, new List<Publication_Target__c>());
                    }
                }
            } else if (publication.CC_PublicationTypeCategory__c == 'Ranking Guides') {
                for (String category : listCategoryforRankingGuides) {
                    setProductCategory.add(category);
                    if (!mapPublicationTarget.get(publication.Id).containsKey(category)) {
                        mapPublicationTarget.get(publication.Id).put(category, new List<Publication_Target__c>());
                    }
                }
            }

            if (!mapPublicationName.containsKey(publication.Id)) {
                mapPublicationName.put(publication.Id, publication.Name);
            }
        }

        List<Publication_Target__c> listPublicationTargets = [
                SELECT Id,
                        Publication__c,
                        Publication__r.Name,
                        Product_Category__c,
                        Directory_Allocated_Target__c,
                        Insights_Allocated_Target__c
                FROM Publication_Target__c
                WHERE Publication__c IN:mapPublicationName.keySet()
//                AND Category_Visible__c = TRUE
//                AND Product_Category__c IN: setProductCategory
                ORDER BY Publication__r.Name, Product_Category__c ASC

        ];

        if (listPublicationTargets.size() > 0) {
            for (Publication_Target__c pubTarget : listPublicationTargets) {
                if (!mapPublicationTarget.containsKey(pubTarget.Publication__c)) {
                    mapPublicationTarget.put(pubTarget.Publication__c, new Map<String, List<Publication_Target__c>>());
                }
                if (!mapPublicationTarget.get(pubTarget.Publication__c).containsKey(pubTarget.Product_Category__c)) {
                    mapPublicationTarget.get(pubTarget.Publication__c).put(pubTarget.Product_Category__c, new List<Publication_Target__c>());
                }
                if (pubTarget.Directory_Allocated_Target__c == null) {
                    pubTarget.Directory_Allocated_Target__c = 0;
                }
                if (pubTarget.Insights_Allocated_Target__c == null) {
                    pubTarget.Insights_Allocated_Target__c = 0;
                }
                mapPublicationTarget.get(pubTarget.Publication__c).get(pubTarget.Product_Category__c).add(pubTarget);
                if (!mapPublicationName.containsKey(pubTarget.Publication__c)) {
                    mapPublicationName.put(pubTarget.Publication__c, pubTarget.Publication__r.Name);
                }
            }
        }


        List<PublicationRow> listPublicationRows = new List<PublicationRow>();
        for (String publId : mapPublicationTarget.keySet()) {
            PublicationRow publicationRow = new PublicationRow();
            publicationRow.publicationName = mapPublicationName.get(publId);
            publicationRow.publicationId = publId;
            publicationRow.expanded = false;
            publicationRow.publicationAllocatedTarget = 0;
            publicationRow.publicationDirectoryAllocatedTarget = 0;
            publicationRow.publicationInsightsAllocatedTarget = 0;

            List<ProductCategoryRow> listProductCategoryRows = new List<ProductCategoryRow>();
            for (String prodCategory : mapPublicationTarget.get(publId).keySet()) {
                ProductCategoryRow productCategoryRow = new ProductCategoryRow();
                if (prodCategory != null) {
                    productCategoryRow.productCategoryName = prodCategory;

                    List<Publication_Target__c> listPublicTargets = new List<Publication_Target__c>();
                    if (mapPublicationTarget.get(publId).get(prodCategory).size() > 0) {
                        for (Publication_Target__c publTarget : mapPublicationTarget.get(publId).get(prodCategory)) {
                            Publication_Target__c publicationTarget = new Publication_Target__c();
                            publicationTarget.Id = publTarget.Id;
                            publicationTarget.Publication__c = publId;
                            publicationTarget.Product_Category__c = prodCategory;
                            publicationTarget.Directory_Allocated_Target__c = publTarget.Directory_Allocated_Target__c == null ? 0 : publTarget.Directory_Allocated_Target__c;
                            publicationTarget.Insights_Allocated_Target__c = publTarget.Insights_Allocated_Target__c == null ? 0 : publTarget.Insights_Allocated_Target__c;
                            publicationTarget.Category_Visible__c = true;
                            listPublicTargets.add(publicationTarget);
                            upsertPublicationTargets.add(publicationTarget);
                        }
                    } else {
                        Publication_Target__c publicationTarget = new Publication_Target__c();
                        publicationTarget.Publication__c = publId;
                        publicationTarget.Product_Category__c = prodCategory;
                        publicationTarget.Directory_Allocated_Target__c = 0;
                        publicationTarget.Insights_Allocated_Target__c = 0;
                        publicationTarget.Category_Visible__c = true;
                        listPublicTargets.add(publicationTarget);
                        upsertPublicationTargets.add(publicationTarget);

                    }
                    productCategoryRow.publicationTargets = listPublicTargets;
                } else {
                    productCategoryRow = null;
                }
                listProductCategoryRows.add(productCategoryRow);
            }
            publicationRow.productCategaryRows = listProductCategoryRows;
            listPublicationRows.add(publicationRow);
        }

        if (upsertPublicationTargets.size() > 0) {
            upsert upsertPublicationTargets;
        }

        return listPublicationRows;

    }

    @AuraEnabled
    public static List<PublicationRow> addProductcategoryApex(String publicationForAddProdCategory, List<String> selectedProductCategory) {

        List<PublicationRow> parsePublicationRows = new List<PublicationRow>();
        if (publicationForAddProdCategory != null) {
            parsePublicationRows = (List<PublicationRow>) JSON.deserialize(publicationForAddProdCategory, List<PublicationRow>.class);
        }

        List<Publication_Target__c> upsertPublicationTargets = new List<Publication_Target__c>();
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Set<String> setProductCategory = new Set<String>();
        Map<String, Map<String, List<Publication_Target__c>>> mapPublicationTarget = new Map<String, Map<String, List<Publication_Target__c>>>();

        if (parsePublicationRows.size() > 0) {
            for (PublicationRow publicationRow : parsePublicationRows) {
                if (!mapPublicationTarget.containsKey(publicationRow.publicationId)) {
                    mapPublicationTarget.put(publicationRow.publicationId, new Map<String, List<Publication_Target__c>>());
                }
                if (!mapPublicationName.containsKey(publicationRow.publicationId)) {
                    mapPublicationName.put(publicationRow.publicationId, publicationRow.publicationName);
                }

                for (ProductCategoryRow productCategoryRow : publicationRow.productCategaryRows) {
                    setProductCategory.add(productCategoryRow.productCategoryName);
                    if (!mapPublicationTarget.get(publicationRow.publicationId).containsKey(productCategoryRow.productCategoryName)) {
                        mapPublicationTarget.get(publicationRow.publicationId).put(productCategoryRow.productCategoryName, new List<Publication_Target__c>());
                    }
                }
                for (String selectProdCategory : selectedProductCategory) {
                    setProductCategory.add(selectProdCategory);
                    if (!mapPublicationTarget.get(publicationRow.publicationId).containsKey(selectProdCategory)) {
                        mapPublicationTarget.get(publicationRow.publicationId).put(selectProdCategory, new List<Publication_Target__c>());
                    }
                }
            }
        }

        List<Publication_Target__c> listPublicationTargets = [
                SELECT Id,
                        Publication__c,
                        Publication__r.Name,
                        Product_Category__c,
                        Directory_Allocated_Target__c,
                        Insights_Allocated_Target__c
                FROM Publication_Target__c
                WHERE Publication__c IN:mapPublicationName.keySet()
                AND Product_Category__c IN:setProductCategory
                ORDER BY Publication__r.Name, Product_Category__c ASC
        ];

        if (listPublicationTargets.size() > 0) {
            for (Publication_Target__c pubTarget : listPublicationTargets) {
                if (!mapPublicationTarget.containsKey(pubTarget.Publication__c)) {
                    mapPublicationTarget.put(pubTarget.Publication__c, new Map<String, List<Publication_Target__c>>());
                }
                if (!mapPublicationTarget.get(pubTarget.Publication__c).containsKey(pubTarget.Product_Category__c)) {
                    mapPublicationTarget.get(pubTarget.Publication__c).put(pubTarget.Product_Category__c, new List<Publication_Target__c>());
                }
                mapPublicationTarget.get(pubTarget.Publication__c).get(pubTarget.Product_Category__c).add(pubTarget);
                if (!mapPublicationName.containsKey(pubTarget.Publication__c)) {
                    mapPublicationName.put(pubTarget.Publication__c, pubTarget.Publication__r.Name);
                }
            }
        }

        List<PublicationRow> listPublicationRows = new List<PublicationRow>();
        for (String publId : mapPublicationTarget.keySet()) {
            PublicationRow publicationRow = new PublicationRow();
            publicationRow.publicationName = mapPublicationName.get(publId);
            publicationRow.publicationId = publId;
            publicationRow.expanded = true;
            publicationRow.publicationAllocatedTarget = 0;
            publicationRow.publicationDirectoryAllocatedTarget = 0;
            publicationRow.publicationInsightsAllocatedTarget = 0;

            List<ProductCategoryRow> listProductCategoryRows = new List<ProductCategoryRow>();
            for (String prodCategory : mapPublicationTarget.get(publId).keySet()) {
                ProductCategoryRow productCategoryRow = new ProductCategoryRow();
                if (prodCategory != null) {
                    productCategoryRow.productCategoryName = prodCategory;

                    List<Publication_Target__c> listPublicTargets = new List<Publication_Target__c>();
                    if (mapPublicationTarget.get(publId).get(prodCategory).size() > 0) {
                        for (Publication_Target__c publTarget : mapPublicationTarget.get(publId).get(prodCategory)) {
                            Publication_Target__c publicationTarget = new Publication_Target__c();
                            publicationTarget.Id = publTarget.Id;
                            publicationTarget.Publication__c = publId;
                            publicationTarget.Product_Category__c = prodCategory;
                            publicationTarget.Directory_Allocated_Target__c = publTarget.Directory_Allocated_Target__c == null ? 0 : publTarget.Directory_Allocated_Target__c;
                            publicationTarget.Insights_Allocated_Target__c = publTarget.Insights_Allocated_Target__c == null ? 0 : publTarget.Insights_Allocated_Target__c;
                            publicationTarget.Category_Visible__c = true;
                            listPublicTargets.add(publicationTarget);
                            upsertPublicationTargets.add(publicationTarget);
                        }
                    } else {
                        Publication_Target__c publicationTarget = new Publication_Target__c();
                        publicationTarget.Publication__c = publId;
                        publicationTarget.Product_Category__c = prodCategory;
                        publicationTarget.Directory_Allocated_Target__c = 0;
                        publicationTarget.Insights_Allocated_Target__c = 0;
                        publicationTarget.Category_Visible__c = true;
                        listPublicTargets.add(publicationTarget);
                        upsertPublicationTargets.add(publicationTarget);
                    }
                    productCategoryRow.publicationTargets = listPublicTargets;
                } else {
                    productCategoryRow = null;
                }
                listProductCategoryRows.add(productCategoryRow);

            }
            publicationRow.productCategaryRows = listProductCategoryRows;
            listPublicationRows.add(publicationRow);
        }

        if (upsertPublicationTargets.size() > 0) {
            upsert upsertPublicationTargets;
        }

        return listPublicationRows;
    }

    @AuraEnabled
    public static List<PublicationRow> deletePublication(String jsonResultTable) {
        List<PublicationRow> parsePublicationRows = new List<PublicationRow>();
        List<String> publicationIds = new List<String>();
        List<Publication_Target__c> listnotDelete = new List<Publication_Target__c>();
        if (jsonResultTable != null) {
            parsePublicationRows = (List<PublicationRow>) JSON.deserialize(jsonResultTable, List<PublicationRow>.class);
        }
        List<Publication_Target__c> updatePublicationTargets = new List<Publication_Target__c>();
        if (parsePublicationRows.size() > 0) {
            for (PublicationRow publicationRow : parsePublicationRows) {
                for (ProductCategoryRow productCategoryRow : publicationRow.productCategaryRows) {
                    for (Publication_Target__c pbTarget : productCategoryRow.publicationTargets) {
                        if (pbTarget.Category_Visible__c == false) {
                            updatePublicationTargets.add(pbTarget);
                            publicationIds.add(pbTarget.Publication__c);
                        } else {
                            listnotDelete.add(pbTarget);
                        }
                    }
                }
            }
        }

        if (updatePublicationTargets.size() > 0) {
            List<Publication__c> updatePub = new List<Publication__c>();
            for(Publication__c pub : [SELECT Id, Directory_Allocated_Target__c, Insights_Allocated_Target__c FROM Publication__c WHERE Id IN: publicationIds]){
                pub.Directory_Allocated_Target__c = 0;
                pub.Insights_Allocated_Target__c = 0;
                updatePub.add(pub);
            }
            update updatePub;
//            update updatePublicationTargets;
            delete updatePublicationTargets;
        }

        List<PublicationRow> listPublicationTarget = showPublicationTargets(listnotDelete);

        return listPublicationTarget;
    }

    @AuraEnabled
    public static List<PublicationRow> savePublicationTarget(String jsonResultTable) {

        List<Publication_Target__c> showListTargets = new List<Publication_Target__c>();
        List<PublicationRow> parsePublicationRows = new List<PublicationRow>();
        if (jsonResultTable != null) {
            parsePublicationRows = (List<PublicationRow>) JSON.deserialize(jsonResultTable, List<PublicationRow>.class);
        }
        Map<String,PublicationRow> updatePublication = new Map<String,PublicationRow>();
        List<Publication_Target__c> updatePublicationTargets = new List<Publication_Target__c>();
        if (parsePublicationRows.size() > 0) {
            for (PublicationRow publicationRow : parsePublicationRows) {
                if(!updatePublication.containsKey(publicationRow.publicationId)) {
                    updatePublication.put(publicationRow.publicationId, publicationRow);
                }
                for (ProductCategoryRow productCategoryRow : publicationRow.productCategaryRows) {
                    for (Publication_Target__c pbTarget : productCategoryRow.publicationTargets) {
                        pbTarget.Category_Visible__c = true;
                        updatePublicationTargets.add(pbTarget);
//                        if (pbTarget.Category_Visible__c != false) {
                            showListTargets.add(pbTarget);
//                        }
                    }
                }
            }
        }

        if (updatePublicationTargets.size() > 0) {
            update updatePublicationTargets;
            updatePublication(updatePublication);
        }

        List<PublicationRow> listPublicationTarget = showPublicationTargets(showListTargets);

        return listPublicationTarget;

    }

    private static List<PublicationRow> showPublicationTargets(List<Publication_Target__c> showListTargets) {
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String, Map<String, List<Publication_Target__c>>> mapPublicationTarget = new Map<String, Map<String, List<Publication_Target__c>>>();

        List<Publication_Target__c> listPublicationTargets = [
                SELECT Id,
                        Publication__c,
                        Publication__r.Name,
                        Product_Category__c,
                        Directory_Allocated_Target__c,
                        Insights_Allocated_Target__c
                FROM Publication_Target__c
                WHERE Id IN:showListTargets
                ORDER BY Publication__r.Name, Product_Category__c ASC
        ];

        if (listPublicationTargets.size() > 0) {
            for (Publication_Target__c pubTarget : listPublicationTargets) {
                if (!mapPublicationTarget.containsKey(pubTarget.Publication__c)) {
                    mapPublicationTarget.put(pubTarget.Publication__c, new Map<String, List<Publication_Target__c>>());
                }
                if (!mapPublicationTarget.get(pubTarget.Publication__c).containsKey(pubTarget.Product_Category__c)) {
                    mapPublicationTarget.get(pubTarget.Publication__c).put(pubTarget.Product_Category__c, new List<Publication_Target__c>());
                }
                mapPublicationTarget.get(pubTarget.Publication__c).get(pubTarget.Product_Category__c).add(pubTarget);
                if (!mapPublicationName.containsKey(pubTarget.Publication__c)) {
                    mapPublicationName.put(pubTarget.Publication__c, pubTarget.Publication__r.Name);
                }
            }
        }

        List<PublicationRow> listPublicationRows = new List<PublicationRow>();
        for (String publId : mapPublicationTarget.keySet()) {
            PublicationRow publicationRow = new PublicationRow();
            publicationRow.publicationName = mapPublicationName.get(publId);
            publicationRow.publicationId = publId;
            publicationRow.expanded = false;
            publicationRow.publicationAllocatedTarget = 0;
            publicationRow.publicationDirectoryAllocatedTarget = 0;
            publicationRow.publicationInsightsAllocatedTarget = 0;

            List<ProductCategoryRow> listProductCategoryRows = new List<ProductCategoryRow>();
            for (String prodCategory : mapPublicationTarget.get(publId).keySet()) {
                ProductCategoryRow productCategoryRow = new ProductCategoryRow();
                if (prodCategory != null) {
                    productCategoryRow.productCategoryName = prodCategory;

                    List<Publication_Target__c> listPublicTargets = new List<Publication_Target__c>();
                    if (mapPublicationTarget.get(publId).get(prodCategory).size() > 0) {
                        for (Publication_Target__c publTarget : mapPublicationTarget.get(publId).get(prodCategory)) {
                            Publication_Target__c publicationTarget = new Publication_Target__c();
                            publicationTarget.Id = publTarget.Id;
                            publicationTarget.Publication__c = publId;
                            publicationTarget.Product_Category__c = prodCategory;
                            publicationTarget.Directory_Allocated_Target__c = publTarget.Directory_Allocated_Target__c == null ? 0 : publTarget.Directory_Allocated_Target__c;
                            publicationTarget.Insights_Allocated_Target__c = publTarget.Insights_Allocated_Target__c == null ? 0 : publTarget.Insights_Allocated_Target__c;
                            publicationTarget.Category_Visible__c = true;
                            listPublicTargets.add(publicationTarget);
                        }
                    } else {
                        Publication_Target__c publicationTarget = new Publication_Target__c();
                        publicationTarget.Publication__c = publId;
                        publicationTarget.Product_Category__c = prodCategory;
                        publicationTarget.Directory_Allocated_Target__c = 0;
                        publicationTarget.Insights_Allocated_Target__c = 0;
                        publicationTarget.Category_Visible__c = true;
                        listPublicTargets.add(publicationTarget);
                    }
                    productCategoryRow.publicationTargets = listPublicTargets;
                } else {
                    productCategoryRow = null;
                }
                listProductCategoryRows.add(productCategoryRow);

            }
            publicationRow.productCategaryRows = listProductCategoryRows;
            listPublicationRows.add(publicationRow);
        }
        return listPublicationRows;
    }

    private static void updatePublication (Map<String,PublicationRow> updatePublication){
        List<Publication__c> listPublications = new List<Publication__c>();
        for(Publication__c publication : [SELECT Id, Directory_Allocated_Target__c, Insights_Allocated_Target__c FROM Publication__c WHERE Id IN: updatePublication.keySet()]){
            publication.Directory_Allocated_Target__c = updatePublication.get(publication.Id).publicationDirectoryAllocatedTarget;
            publication.Insights_Allocated_Target__c = updatePublication.get(publication.Id).publicationInsightsAllocatedTarget;
            listPublications.add(publication);
        }
        if(listPublications.size() > 0){
            update listPublications;
        }
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