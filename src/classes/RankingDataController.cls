public with sharing class RankingDataController {

    @AuraEnabled
    public static Map<String, Object> getpublicationType(String recordType, Id recordId) {

        try {
            Map<String, Object> result = new Map<String, Object>();

            String accId, hoAccId;
//            String HOAccount, HOAccountId;
            if (Schema.Account.SObjectType == recordId.getSObjectType()) {
                Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :recordId];
                if (acc.ParentId != null) {
                    hoAccId = acc.ParentId;
                    accId = acc.Id;
                } else {
                    hoAccId = acc.Id;
                    accId = acc.Id;
                }
//                HOAccount = [SELECT Id, Related_HO_Account__c FROM Account WHERE Id = :recordId].Related_HO_Account__c;
//                HOAccountId = '%' + HOAccount.substring(10, 25) + '%';
            }
            if (Schema.Opportunity.SObjectType == recordId.getSObjectType()) {
                Opportunity opp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id = :recordId];
                if (opp.Account.ParentId != null) {
                    hoAccId = opp.Account.ParentId;
                    accId = opp.AccountId;
                } else {
                    hoAccId = opp.AccountId;
                    accId = opp.AccountId;
                }
//                HOAccount = [SELECT Id, AccountId, Account.Related_HO_Account__c FROM Opportunity WHERE Id = :recordId].Account.Related_HO_Account__c;
//                HOAccountId = '%' + HOAccount.substring(10, 25) + '%';
            }

            Set<String> setPublicType = new Set<String>();
            Set<String> setYear = new Set<String>();

            for (Rankings__c r : [
                    SELECT Publication_RE__r.Publication_Type__c, Year_RE__c, Account_RE__r.Related_HO_Account__c
                    FROM Rankings__c
                    WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId = :hoAccId OR Id = :hoAccId OR Id = :accId)
                    AND RecordType.Name = :recordType
                    AND Year_RE__c >= '2010'
                    ORDER BY Publication_RE__r.Publication_Type__c ASC
            ]) {
                setPublicType.add(r.Publication_RE__r.Publication_Type__c);
                setYear.add(r.Year_RE__c);
            }

            List<String> yearSort = new List<String>();
            List<String> yearForColumn = new List<String>();
            for (String y : setYear) {
                yearSort.add(y);
                yearSort.sort();
                System.debug(yearSort);
            }
            for (Integer i = yearSort.size() - 1; i >= 0; i--) {
                yearForColumn.add(yearSort[i]);
                System.debug(yearSort[i]);
            }

            List<WrapperPublication> listWrapperPublications = new List<WrapperPublication>();
            for (String pub : setPublicType) {
                System.debug(setPublicType);
                WrapperPublication wrpPublication = new WrapperPublication();
                wrpPublication.publication = pub;
                wrpPublication.listYear = yearForColumn;
                listWrapperPublications.add(wrpPublication);
            }
            if (listWrapperPublications.size() > 0) {
                result.put('table', listWrapperPublications);
            } else {
                result.put('table', null);
            }

            System.debug(result);
            return result;
        } catch (Exception ex) {
            return new Map<String, Object>{
                    'status' => 'error',
                    'message' => ex.getMessage()
            };
        }

    }

    @AuraEnabled
    public static Map<String, Object> getRankings(String recordType, Id recordId, String pubType, List<String> listYear) {
        // Schema.Account.SObjectType == recordId.getSObjectType()
        try {
            Map<String, Object> result = new Map<String, Object>();

            String accId, hoAccId;
            if (Schema.Account.SObjectType == recordId.getSObjectType()) {
                Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :recordId];
                if (acc.ParentId != null) {
                    hoAccId = acc.ParentId;
                    accId = acc.Id;
                } else {
                    hoAccId = acc.Id;
                    accId = acc.Id;
                }
            }

            if (Schema.Opportunity.SObjectType == recordId.getSObjectType()) {
                Opportunity opp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id = :recordId];
                if (opp.Account.ParentId != null) {
                    hoAccId = opp.Account.ParentId;
                    accId = opp.AccountId;
                } else {
                    hoAccId = opp.AccountId;
                    accId = opp.AccountId;
                }
            }

            List<String> yearSort = new List<String>();
            List<String> yearForColumn = new List<String>();
            for (String y : listYear) {
                yearSort.add(y);
                yearSort.sort();
                System.debug(yearSort);
            }
            for (Integer i = yearSort.size() - 1; i >= 0; i--) {
                yearForColumn.add(yearSort[i]);
                System.debug(yearSort[i]);

            }


            Map<String, List<Rankings__c>> sortByPracticArea = new Map<String, List<Rankings__c>>();
            Map<String, Rankings__c> mapRankings = new Map<String, Rankings__c>();
            for (Rankings__c rank : [
                    SELECT Id, Practice_Area_RE__c, CC_Ranking_Short__c, Account_RE__r.Related_HO_Account__c, Publication_RE__c, Publication_RE__r.Name, Account_RE__r.Name, Account_RE__r.IsParent__c, Person_RE__r.Name, Year_RE__c, Publication_RE__r.Publication_Type__c, Subsection_Type_RE__c, Ranking__c, Location__r.Name, Foreign_Expertise_Location_RE__c, RecordType.Name, RecordTypeId
                    FROM Rankings__c
                    WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId = :hoAccId OR Id = :hoAccId OR Id = :accId)
                    AND RecordType.Name = :recordType
                    AND Publication_RE__r.Publication_Type__c = :pubType
                    AND Year_RE__c >= '2010'
                    ORDER BY Publication_RE__r.Publication_Type__c, Practice_Area_RE__c ASC
            ]) {

                mapRankings.put(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name + '-' + rank.Publication_RE__r, rank);

                if (!sortByPracticArea.containsKey(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name)) {
                    sortByPracticArea.put(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name, new List<Rankings__c>());
                }
                sortByPracticArea.get(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name).add(rank);
            }
            System.debug(sortByPracticArea);

            List<WrapperRankigs> listWrapperRankigs = new List<WrapperRankigs>();

            for (String name : sortByPracticArea.keySet()) {
                System.debug(name);
                List<Rankings__c> rankingsList = sortByPracticArea.get(name);
                System.debug(rankingsList);
                WrapperRankigs wrpRanking = new WrapperRankigs();
                wrpRanking.practiceArea = rankingsList[0].Practice_Area_RE__c;
                wrpRanking.location = rankingsList[0].Location__r.Name;
                wrpRanking.type = rankingsList[0].Subsection_Type_RE__c;
                wrpRanking.locationOfExpertise = rankingsList[0].Foreign_Expertise_Location_RE__c;
                wrpRanking.branch = rankingsList[0].Account_RE__r.Name;
                wrpRanking.person = rankingsList[0].Person_RE__r.Name == null ? ' ' : rankingsList[0].Person_RE__r.Name;
                wrpRanking.year = rankingsList[0].Year_RE__c;
                wrpRanking.headOffice = rankingsList[0].Account_RE__r.IsParent__c;
                listWrapperRankigs.add(wrpRanking);

                List<WrapperRankYear> wryList = new List<WrapperRankYear>();
                for (String y : yearForColumn) {
                    WrapperRankYear wry = new WrapperRankYear();
                    wry.rankingYear = '-';
                    wry.rYears = y;
                    wryList.add(wry);
                }
                for (Rankings__c r : rankingsList) {
                    for (WrapperRankYear wry : wryList) {
                        System.debug(r);
                        if (wry.rYears == r.Year_RE__c) {
                            wry.rankingYear = r.CC_Ranking_Short__c;
//                                break;
                        }
                    }

                }
                wrpRanking.rankYears = wryList;

            }

            if (listWrapperRankigs.size() > 0) {
                result.put('table', listWrapperRankigs);
            } else {
                result.put('table', null);
            }
//        }
            return result;
        } catch (Exception ex) {
            return new Map<String, Object>{
                    'status' => 'error',
                    'message' => ex.getMessage()
            };
        }
    }

    @AuraEnabled
    public static Map<String, Object> getRankingsSearch(String recordType, Id recordId, String pubType, List<String> listYear, String filterPracticeArea, String filterPerson, String filterLocationOfExpertise, String filterLocation, String filterBranch, String filterType) {
        // Schema.Account.SObjectType == recordId.getSObjectType()
        try {
            Map<String, Object> result = new Map<String, Object>();

            String startYear = '2010';
            String accId, hoAccId;

            if (Schema.Account.SObjectType == recordId.getSObjectType()) {
                Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :recordId];
                if (acc.ParentId != null) {
                    hoAccId = acc.ParentId;
                    accId = acc.Id;
                } else {
                    hoAccId = acc.Id;
                    accId = acc.Id;
                }

            }
            if (Schema.Opportunity.SObjectType == recordId.getSObjectType()) {
                Opportunity opp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id = :recordId];
                if (opp.Account.ParentId != null) {
                    hoAccId = opp.Account.ParentId;
                    accId = opp.AccountId;
                } else {
                    hoAccId = opp.AccountId;
                    accId = opp.AccountId;
                }

            }

            String query = 'SELECT Id, Practice_Area_RE__c, CC_Ranking_Short__c, Account_RE__r.Related_HO_Account__c, Publication_RE__c, Publication_RE__r.Name, Account_RE__r.Name, Account_RE__r.IsParent__c, Person_RE__r.Name, Year_RE__c, Publication_RE__r.Publication_Type__c, Subsection_Type_RE__c, Ranking__c, Location__r.Name, Foreign_Expertise_Location_RE__c, RecordType.Name, RecordTypeId' +
                    +' FROM Rankings__c' +
                    +' WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId = :hoAccId OR Id = :hoAccId OR Id = :accId)' +
                    +' AND Year_RE__c >= :startYear '+
                    +' AND RecordType.Name =: recordType' +
                    +' AND Publication_RE__r.Publication_Type__c =: pubType';

            if (String.isNotEmpty(filterPracticeArea)) {
                query = query + ' AND Practice_Area_RE__c LIKE  \'%' + filterPracticeArea + '%\'';
            }

            if (recordType == 'Person Ranking') {
                query = query + ' AND Person_RE__r.Name LIKE \'%' + filterPerson + '%\'';
            }
            if (String.isNotEmpty(filterLocationOfExpertise)) {
                query = query + ' AND Foreign_Expertise_Location_RE__c LIKE \'%' + filterLocationOfExpertise + '%\'';
            }
            if (String.isNotEmpty(filterLocation)) {
                query = query + ' AND Location__r.Name LIKE  \'%' + filterLocation + '%\'';
            }
            if (String.isNotEmpty(filterBranch)) {
                query = query + ' AND Account_RE__r.Name LIKE \'%' + filterBranch + '%\'';
            }
            if (String.isNotEmpty(filterType)) {
                query = query + ' AND Subsection_Type_RE__c LIKE \'%' + filterType + '%\'';
            }
            query = query + ' ORDER BY Publication_RE__r.Publication_Type__c,  Practice_Area_RE__c ASC';

            List<Rankings__c> listAllRankings = Database.query(query);
            System.debug(query);
            List<String> yearSort = new List<String>();
            List<String> yearForColumn = new List<String>();
            for (String y : listYear) {
                yearSort.add(y);
                yearSort.sort();
                System.debug(yearSort);
            }
            for (Integer i = yearSort.size() - 1; i >= 0; i--) {
                yearForColumn.add(yearSort[i]);
                System.debug(yearSort[i]);

            }


            Map<String, List<Rankings__c>> sortByPracticArea = new Map<String, List<Rankings__c>>();

            for (Rankings__c rank : listAllRankings) {

                if (!sortByPracticArea.containsKey(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name)) {
                    sortByPracticArea.put(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name, new List<Rankings__c>());
                }
                sortByPracticArea.get(rank.Practice_Area_RE__c + '-' + rank.RecordTypeId + '-' + rank.Location__r.Name + '-' + rank.Publication_RE__r.Publication_Type__c + '-' + rank.Person_RE__r.Name).add(rank);
            }

            List<WrapperRankigs> listWrapperRankigs = new List<WrapperRankigs>();

            for (String name : sortByPracticArea.keySet()) {

                List<Rankings__c> rankingsList = sortByPracticArea.get(name);

                WrapperRankigs wrpRanking = new WrapperRankigs();
                wrpRanking.practiceArea = rankingsList[0].Practice_Area_RE__c;
                wrpRanking.location = rankingsList[0].Location__r.Name;
                wrpRanking.type = rankingsList[0].Subsection_Type_RE__c;
                wrpRanking.locationOfExpertise = rankingsList[0].Foreign_Expertise_Location_RE__c;
                wrpRanking.branch = rankingsList[0].Account_RE__r.Name;
                wrpRanking.person = rankingsList[0].Person_RE__r.Name == null ? ' ' : rankingsList[0].Person_RE__r.Name;
                wrpRanking.year = rankingsList[0].Year_RE__c;
                wrpRanking.headOffice = rankingsList[0].Account_RE__r.IsParent__c;
                listWrapperRankigs.add(wrpRanking);

                List<WrapperRankYear> wryList = new List<WrapperRankYear>();
                for (String y : yearForColumn) {
                    WrapperRankYear wry = new WrapperRankYear();
                    wry.rankingYear = '-';
                    wry.rYears = y;
                    wryList.add(wry);
                }
                for (Rankings__c r : rankingsList) {
                    for (WrapperRankYear wry : wryList) {
                        if (wry.rYears == r.Year_RE__c) {
                            wry.rankingYear = r.CC_Ranking_Short__c;
                                break;
                        }
                    }

                }
                wrpRanking.rankYears = wryList;

            }

            if (listWrapperRankigs.size() > 0) {
                result.put('table', listWrapperRankigs);
            } else {
                result.put('table', null);
            }
//        }
            return result;
        } catch (Exception ex) {
            return new Map<String, Object>{
                    'status' => 'error',
                    'message' => ex.getMessage()
            };
        }
    }

    public class WrapperPublication {
        @AuraEnabled
        String publication { get; set; }
        @AuraEnabled
        List<String> listYear { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }
        @AuraEnabled
        List <WrapperRankigs> rankings { get; set; }
        WrapperPublication() {
            expanded = false;
            rankings = new List <WrapperRankigs>();
            listYear = new List<String>();
        }
    }

    public class WrapperRankigs {
        @AuraEnabled
        String practiceArea { get; set; }
        @AuraEnabled
        String location { get; set; }
        @AuraEnabled
        String type { get; set; }
        @AuraEnabled
        String locationOfExpertise { get; set; }
        @AuraEnabled
        String branch { get; set; }
        @AuraEnabled
        Boolean headOffice { get; set; }
        @AuraEnabled
        String year { get; set; }
        @AuraEnabled
        String person { get; set; }
        @AuraEnabled
        List<WrapperRankYear> rankYears { get; set; }
        WrapperRankigs() {
            rankYears = new List<WrapperRankYear>();
        }

    }

    public class WrapperRankYear {
        @AuraEnabled
        String rankingYear { get; set; }
        @AuraEnabled
        String rYears { get; set; }

    }
}