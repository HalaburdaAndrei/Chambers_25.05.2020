public with sharing class CurrentFYController {
    @AuraEnabled
    public static Map<String, Object> getOpportunities(String opportunityId) {
        //Id of HO account for current opportunity
        Map<String, Object> result = new Map<String, Object>();
        String HOAccountId = [SELECT Id, AccountId, Account.Related_HO_Account__c FROM Opportunity WHERE Id = :opportunityId].Account.Related_HO_Account__c.substring(10, 25);
        HOAccountId = '%' + HOAccountId + '%';
        List <Opportunity> allOpportunitiesForHOAccaunt = [
                SELECT Id, Publication__c, CC_Publication_Name__c, Publication_RE__r.Id, Current_FY__c, Name, Signer_text__c, CloseDate, Pricebook2Id, Pricebook2.Name, Num_of_Submissions__c,
                    (SELECT Product2.Complete_Product_Name__c, Product2.Name, Quantity, UnitPrice, TotalPrice, Related_Organization__r.Name, Chapter__r.Name, Product2.Family FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Account.Related_HO_Account__c LIKE :HOAccountId
                ORDER BY Id
        ];


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
            WrapperPriceBookTable priceBook = new WrapperPriceBookTable();
//            priceBook.wrapperTotalRows = new List<CurrentFYController.WrapperTotalRow>();
            priceBook.PriceBokName = sortByPrice.get(PriceBookId)[0].Pricebook2.Name;

            Map<Id, List<Opportunity>> sortedByPublication = new Map<Id, List<Opportunity>>();

            for (Opportunity opp : sortByPrice.get(PriceBookId)) {
                if (sortedByPublication.containsKey(opp.Publication_RE__r.Id)) {
                    sortedByPublication.get(opp.Publication_RE__r.Id).add(opp);
                } else {
                    sortedByPublication.put(opp.Publication_RE__r.Id, New List<Opportunity>{
                            opp
                    });
                }
            }

            for (Id id : sortedByPublication.keyset()) {
                List <Opportunity> oppList = sortedByPublication.get(id);

                WrapperTotalRow totalRow = new WrapperTotalRow();


                totalRow.publication = oppList[0].Publication__c;

                List <WrapperProductRow> productRows = new List<WrapperProductRow>();
                for (Opportunity opp : oppList) {
                    for (OpportunityLineItem l : opp.OpportunityLineItems) {
                        WrapperProductRow line = new WrapperProductRow();
                        totalRow.totalPrice = totalRow.totalPrice + l.TotalPrice;
                        line.product = l.Product2.Name;
                        line.oppId = opp.Id;
                        line.quantity = l.Quantity;
                        line.totalPrice = l.TotalPrice;
                        line.signer = opp.Signer_text__c;
                        line.closeDate = opp.CloseDate;
                        line.relatedOrganization = l.Related_Organization__r.Name;
                        line.chapter = l.Chapter__r.Name;
                        line.productFamily = l.Product2.Family;
                        line.numberOfSubmissions = opp.Num_of_Submissions__c;
                        productRows.add(line);
                    }
                    totalRow.products = productRows;
                }
                priceBook.wrapperTotalRows.add(totalRow);
            }

            table.add(priceBook);
        }


        result.put('table', table);
        return result;
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
            expanded = false;
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
        WrapperTotalRow() {
            expanded = true;
            products = new List <WrapperProductRow>();
            totalPrice = 0;
        }
    }

    public class WrapperProductRow {
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
        String productFamily { get; set; }
        @AuraEnabled
        Decimal numberOfSubmissions { get; set; }
    }
}