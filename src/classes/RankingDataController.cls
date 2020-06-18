public with sharing class RankingDataController {

    @AuraEnabled
    public static Map<String,Object> getRankings() {

        List<String> listYear = new List<String>{'2017','2018','2019','2020'};

        Map<String,Object> result = new Map<String, Object>();
        List<Rankings__c> listAllRankings = [
                SELECT Id, Practice_Area_RE__c, Publication_RE__r.Name, Account_RE__r.Name, Person_RE__r.Name, Year_RE__c, Publication_RE__r.Publication_Type__c, Subsection_Type_RE__c, Ranking__c, Location__r.Name, Foreign_Expertise_Location_RE__c, RecordType.Name, RecordTypeId
                FROM Rankings__c
                WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cmAAD')
                ORDER BY Practice_Area_RE__c ASC
        ];

//        Map<String,List<Rankings__c>> sortByPublication = new Map<String, List<Rankings__c>>();
//        for(Rankings__c rank : listAllRankings){
//            if(sortByPublication.containsKey(rank.Publication_RE__r.Publication_Type__c)){
//                sortByPublication.get(rank.Publication_RE__r.Publication_Type__c).add(rank);
//            }else{
//                sortByPublication.put(rank.Publication_RE__r.Publication_Type__c,new List<Rankings__c>{rank});
//            }
//        }
//
//        List<WrapperPublication> listWrapperPublications = new List<WrapperPublication>();
//        for(String id : sortByPublication.keySet()){
//            List<Rankings__c> rankingsList = sortByPublication.get(id);
//            WrapperPublication wrpPublication = new WrapperPublication();
//            wrpPublication.publication = rankingsList[0].Publication_RE__r.Publication_Type__c;
//            wrpPublication.listYear = listYear;
//            List<WrapperRankigs> listWrapperRankigs = new List<WrapperRankigs>();
//            for(Rankings__c rank : rankingsList){
//                WrapperRankigs wrpRanking = new WrapperRankigs();
//                wrpRanking.practiceArea = rank.Practice_Area_RE__c;
//                wrpRanking.location = rank.Location__r.Name;
//                wrpRanking.type = rank.Subsection_Type_RE__c;
//                wrpRanking.locationOfExpertise = rank.Foreign_Expertise_Location_RE__c;
//                wrpRanking.branch = rank.Account_RE__r.Name;
//                wrpRanking.rank = rank.Ranking__c;
//                wrpRanking.year = rank.Year_RE__c;
//                wrpRanking.recordType = rank.RecordType.Name;
//                wrpRanking.contactName = rank.Person_RE__r.Name;
//                listWrapperRankigs.add(wrpRanking);
//            }
//            wrpPublication.rankings = listWrapperRankigs;
//            listWrapperPublications.add(wrpPublication);
//        }

        Map<String,List<Rankings__c>> sortByPublication = new Map<String, List<Rankings__c>>();
        for(Rankings__c rank : listAllRankings){
            if(sortByPublication.containsKey(rank.Publication_RE__r.Publication_Type__c)){

                sortByPublication.get(rank.Publication_RE__r.Publication_Type__c).add(rank);
            }else{
                sortByPublication.put(rank.Publication_RE__r.Publication_Type__c,new List<Rankings__c>{rank});
            }
        }

        List<WrapperPublication> listWrapperPublications = new List<WrapperPublication>();
        for(String id : sortByPublication.keySet()){
            List<Rankings__c> rankingsList = sortByPublication.get(id);
            WrapperPublication wrpPublication = new WrapperPublication();
            wrpPublication.publication = rankingsList[0].Publication_RE__r.Publication_Type__c;
            wrpPublication.listYear = listYear;
            List<WrapperRankigs> listWrapperRankigs = new List<WrapperRankigs>();
            for(Rankings__c rank : rankingsList){
                List<WrapperRankYear> wryList = new List<WrapperRankYear>();
                WrapperRankigs wrpRanking = new WrapperRankigs();
                wrpRanking.practiceArea = rank.Practice_Area_RE__c;
                wrpRanking.location = rank.Location__r.Name;
                wrpRanking.type = rank.Subsection_Type_RE__c;
                wrpRanking.locationOfExpertise = rank.Foreign_Expertise_Location_RE__c;
                wrpRanking.branch = rank.Account_RE__r.Name;
                wrpRanking.rank = rank.Ranking__c;
                wrpRanking.year = rank.Year_RE__c;
                wrpRanking.recordType = rank.RecordType.Name;
                wrpRanking.contactName = rank.Person_RE__r.Name;
                for(Rankings__c rankYear : rankingsList){
                    if(rankYear.Practice_Area_RE__c == rank.Practice_Area_RE__c && rankYear.Location__r.Name == rank.Location__r.Name && rankYear.RecordTypeId == rank.RecordTypeId) {
                        WrapperRankYear wry = new WrapperRankYear();
                        wry.rankingYear = rankYear.Ranking__c;
                        wryList.add(wry);
                    }
                }
                wrpRanking.rankYears = wryList;
                listWrapperRankigs.add(wrpRanking);
            }
            wrpPublication.rankings = listWrapperRankigs;
            listWrapperPublications.add(wrpPublication);
        }

        result.put('table', listWrapperPublications);

        return result;
    }

    public class WrapperPublication {
        @AuraEnabled
        String publication {get;set;}
        @AuraEnabled
        List<String> listYear {get; set;}
        @AuraEnabled
        Boolean expanded {get;set;}
        @AuraEnabled
        List <WrapperRankigs> rankings {get;set;}
        WrapperPublication () {
            expanded = false;
            rankings = new List <WrapperRankigs>();
            listYear = new List<String>();
        }
    }

    public class WrapperRankigs{
        @AuraEnabled
        String practiceArea {get;set;}
        @AuraEnabled
        String location {get;set;}
        @AuraEnabled
        String type {get;set;}
        @AuraEnabled
        String locationOfExpertise {get;set;}
        @AuraEnabled
        String branch {get;set;}
        @AuraEnabled
        String headOffice {get;set;}
        @AuraEnabled
        String rank {get;set;}
        @AuraEnabled
        String year {get;set;}
        @AuraEnabled
        String recordType {get;set;}
        @AuraEnabled
        String contactName {get;set;}
        @AuraEnabled
        List<WrapperRankYear> rankYears {get;set;}
        WrapperRankigs () {
            rankYears = new List<WrapperRankYear>();
        }

    }

    public class WrapperRankYear {
        @AuraEnabled
        String rankingYear {get;set;}
    }
}