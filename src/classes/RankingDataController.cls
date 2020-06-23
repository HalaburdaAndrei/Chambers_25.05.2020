public with sharing class RankingDataController {

    @AuraEnabled
    public static Map<String,Object> getRankings(String recordType, Id recordId) {
    // Schema.Account.SObjectType == recordId.getSObjectType()


        Map<String,Object> result = new Map<String, Object>();
//        (SELECT Id FROM Account WHERE ParentId = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cmAAD')
//        Account acc = [SELECT Id, ParentId FROM Account WHERE Id = '0011l00000UM1cHAAT'];
        String accId, hoAccId;
        if(Schema.Account.SObjectType == recordId.getSObjectType()) {
            Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :recordId];
            if (acc.ParentId != null) {
                hoAccId = acc.ParentId;
                accId = acc.Id;
            } else {
                hoAccId = acc.Id;
                accId = acc.Id;
            }
        }
        if(Schema.Opportunity.SObjectType == recordId.getSObjectType()) {
            Opportunity opp = [SELECT AccountId, Account.ParentId FROM Opportunity WHERE Id =: recordId];
            if (opp.Account.ParentId != null) {
                hoAccId = opp.Account.ParentId;
                accId = opp.AccountId;
            } else {
                hoAccId = opp.AccountId;
                accId = opp.AccountId;
            }
        }

        List<Rankings__c> listAllRankings;
        if(recordType == 'Organization Ranking') {
            listAllRankings = [
                    SELECT Id, Practice_Area_RE__c, Publication_RE__c, Publication_RE__r.Name, Account_RE__r.Name, Account_RE__r.IsParent__c, Person_RE__r.Name, Year_RE__c, Publication_RE__r.Publication_Type__c, Subsection_Type_RE__c, Ranking__c, Location__r.Name, Foreign_Expertise_Location_RE__c, RecordType.Name, RecordTypeId
                    FROM Rankings__c
                    WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId = :hoAccId OR Id = :hoAccId OR Id = :accId)
                    AND RecordType.Name = :recordType
                    AND Year_RE__c >= '2010'
                    ORDER BY Publication_RE__r.Publication_Type__c, Practice_Area_RE__c ASC
            ];
        }
        if(recordType == 'Person Ranking'){
            listAllRankings = [
                    SELECT Id, Practice_Area_RE__c, Publication_RE__c, Publication_RE__r.Name, Account_RE__r.Name, Account_RE__r.IsParent__c, Person_RE__r.Name, Year_RE__c, Publication_RE__r.Publication_Type__c, Subsection_Type_RE__c, Ranking__c, Location__r.Name, Foreign_Expertise_Location_RE__c, RecordType.Name, RecordTypeId
                    FROM Rankings__c
                    WHERE Account_RE__c IN (SELECT Id FROM Account WHERE ParentId =: hoAccId OR Id =: hoAccId OR Id =: accId)
                    AND RecordType.Name =: recordType
                    AND Year_RE__c >= '2010'
                    ORDER BY Publication_RE__r.Publication_Type__c,  Person_RE__r.Name ASC
            ];
        }

        Set<String> setYear = new Set<String>();
        for(Rankings__c rank : listAllRankings){
            setYear.add(rank.Year_RE__c);
        }

        List<String> yearSort = new List<String>();
        List<String> yearForColumn = new List<String>();
        for (String y : setYear){
            yearSort.add(y);
            yearSort.sort();
            System.debug(yearSort);
        }
        for (Integer i = yearSort.size()-1; i>= 0; i-- ) {
            yearForColumn.add(yearSort[i]);
            System.debug(yearSort[i]);
        }


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




//        Map<String,List<Rankings__c>> sortByPublication = new Map<String, List<Rankings__c>>();
//        for(Rankings__c rank : listAllRankings){
//            if(sortByPublication.containsKey(rank.Publication_RE__r.Publication_Type__c)){
//
//                sortByPublication.get(rank.Publication_RE__r.Publication_Type__c).add(rank);
//            }else{
//                sortByPublication.put(rank.Publication_RE__r.Publication_Type__c,new List<Rankings__c>{rank});
//            }
//        }

        Map<String,Map<String,List<Rankings__c>>> sortByPracticArea = new Map<String,Map<String, List<Rankings__c>>>();
        for(Rankings__c rank : listAllRankings){
            if(!sortByPracticArea.containsKey(rank.Publication_RE__r.Publication_Type__c)){
                sortByPracticArea.put(rank.Publication_RE__r.Publication_Type__c, new Map<String,List<Rankings__c>>());
            }
            if(!sortByPracticArea.get(rank.Publication_RE__r.Publication_Type__c).containsKey(rank.Practice_Area_RE__c+'-'+rank.RecordTypeId+'-'+rank.Location__r.Name+'-'+rank.Publication_RE__r.Publication_Type__c+'-'+rank.Person_RE__r.Name+'-'+rank.Publication_RE__c)){
                sortByPracticArea.get(rank.Publication_RE__r.Publication_Type__c).put(rank.Practice_Area_RE__c+'-'+rank.RecordTypeId+'-'+rank.Location__r.Name+'-'+rank.Publication_RE__r.Publication_Type__c+'-'+rank.Person_RE__r.Name+'-'+rank.Publication_RE__c, new List<Rankings__c>());
            }
            sortByPracticArea.get(rank.Publication_RE__r.Publication_Type__c).get(rank.Practice_Area_RE__c+'-'+rank.RecordTypeId+'-'+rank.Location__r.Name+'-'+rank.Publication_RE__r.Publication_Type__c+'-'+rank.Person_RE__r.Name+'-'+rank.Publication_RE__c).add(rank);
        }
        System.debug(sortByPracticArea);



        List<WrapperPublication> listWrapperPublications = new List<WrapperPublication>();
        for(String publicTyp : sortByPracticArea.keySet()){
            WrapperPublication wrpPublication = new WrapperPublication();
            wrpPublication.publication = publicTyp;
            wrpPublication.listYear = yearForColumn;
            List<WrapperRankigs> listWrapperRankigs = new List<WrapperRankigs>();

            for(String name : sortByPracticArea.get(publicTyp).keySet()){
                System.debug(name);
                List<Rankings__c> rankingsList = sortByPracticArea.get(publicTyp).get(name);
                System.debug(rankingsList);
                WrapperRankigs wrpRanking = new WrapperRankigs();
                wrpRanking.practiceArea = rankingsList[0].Practice_Area_RE__c;
                wrpRanking.location = rankingsList[0].Location__r.Name;
                wrpRanking.type = rankingsList[0].Subsection_Type_RE__c;
                wrpRanking.locationOfExpertise = rankingsList[0].Foreign_Expertise_Location_RE__c;
                wrpRanking.branch = rankingsList[0].Account_RE__r.Name;
                wrpRanking.person = rankingsList[0].Person_RE__r.Name;
                wrpRanking.year = rankingsList[0].Year_RE__c;
                wrpRanking.headOffice = rankingsList[0].Account_RE__r.IsParent__c;
                listWrapperRankigs.add(wrpRanking);
                List<WrapperRankYear> wryList = new List<WrapperRankYear>();
                for(String y : yearForColumn){
                    WrapperRankYear wry = new WrapperRankYear();
                    wry.rankingYear = '-';
                    wry.rYears = y;
                    wryList.add(wry);
                }
                for(Rankings__c r : rankingsList){
                    for(WrapperRankYear wry : wryList) {
                        System.debug(r);
                        if(wry.rYears == r.Year_RE__c) {
//                    WrapperRankYear wry = new WrapperRankYear();
                            wry.rankingYear = r.Ranking__c;
//                        wry.rYears = r.Year_RE__c;
//                    wryList.add(wry);
                        }
                    }
//                        for(Integer i = 0; yearForColumn.size() > i; i++) {
//                            if(yearForColumn[i] == r.Year_RE__c) {
//                                if(wryList.size() > i) {
//                                    wryList.add(i, wry);
//                                }
//                            }else{
//
//                            }
//                        }

//                    WrapperRankigs wrpRanking = new WrapperRankigs();
//                    wrpRanking.practiceArea = r.Practice_Area_RE__c;
//                    wrpRanking.location = r.Location__r.Name;
//                    wrpRanking.type = r.Subsection_Type_RE__c;
//                    wrpRanking.locationOfExpertise = r.Foreign_Expertise_Location_RE__c;
//                    wrpRanking.branch = r.Account_RE__r.Name;
//                    wrpRanking.person = r.Person_RE__r.Name;
//                    wrpRanking.year = r.Year_RE__c;
//                    wrpRanking.rankYears = wryList;
//
//                    listWrapperRankigs.add(wrpRanking);


                }
                wrpRanking.rankYears = wryList;

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
        Boolean headOffice {get;set;}
        @AuraEnabled
        String rank {get;set;}
        @AuraEnabled
        String year {get;set;}
        @AuraEnabled
        String recordType {get;set;}
        @AuraEnabled
        String person {get;set;}
        @AuraEnabled
        List<WrapperRankYear> rankYears {get;set;}
        WrapperRankigs () {
            rankYears = new List<WrapperRankYear>();
        }

    }

    public class WrapperRankYear {
        @AuraEnabled
        String rankingYear {get;set;}
        @AuraEnabled
        String rYears {get;set;}

    }
}