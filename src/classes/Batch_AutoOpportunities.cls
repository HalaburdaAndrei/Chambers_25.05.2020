global class Batch_AutoOpportunities implements Database.Batchable<sObject>, Database.Stateful {

    private Integer step;
    global Map<String, List<String>> errorMaps = new Map<String, List<String>>();
    global Map<String, Map<Id, Set<Id>>> step1AcctIds = new Map<String, Map<Id, Set<Id>>>();
    global Map<String, Map<Id, Map<Id, Map<String, Integer>>>> step1AcctRankingCount = new Map<String, Map<Id, Map<Id, Map<String, Integer>>>>();
    global Map<String, Map<Id, Map<Id, Map<String, Integer>>>> step1PrevAcctRankingCount = new Map<String, Map<Id, Map<Id, Map<String, Integer>>>>();
    global Map<String, Map<Id, Map<Id, Datetime>>> step1LatestRankingDates = new Map<String, Map<Id, Map<Id, Datetime>>>();
    global Map<String, Map<Id, Map<Id, Integer>>> step1AcctSubmissionCount = new Map<String, Map<Id, Map<Id, Integer>>>();
    global Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>> step1AcctOppLinesByPub = new Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>>();
    global Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>> step1PrevAcctOppLinesByPub = new Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>>();
    global Map<String, Map<Id, Map<Id, Set<String>>>> step1PracticeAreas = new Map<String, Map<Id, Map<Id, Set<String>>>>();


    global Date thisDate;
    global List<String> guideTypes = new List<String>{
            'Ranking Guides', 'Practice Guides', 'Career Guides', 'Professional Adviser Guides'
    }; //,'Practice Guides','Career Guides'
    global Map<String, String> guideBooks = new Map<String, String>{
            'Ranking Products' => 'Ranking Guides',
            'Practice Products' => 'Practice Guides',
            'Career Products' => 'Career Guides'
    };
    global Map<String, String> guideProducts = new Map<String, String>{
            'Practice Guides' => 'T&Ds',
            'Student Career Guides' => 'Subscriptions||Banner Ads||Expert Focus||Becoming a Lawyer||Display & Sponsoprship',
            'Associate Career Guides' => 'Subscriptions||Banner Ads||Expert Focus||Becoming a Lawyer||Lateral Hub Overview||Display & Sponsoprship'
    };
    global Map<String, Id> priceBooks = new Map<String, Id>();

    global Batch_AutoOpportunities() {
        this.step = 1;
        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
            String type = guideBooks.get(pb.Name);
            if (type != null) priceBooks.put(type, pb.Id);
        }

        thisDate = Date.today();
    }

    global Batch_AutoOpportunities(Date myDate) {
        this.step = 1;

        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
            String type = guideBooks.get(pb.Name);
            if (type != null) priceBooks.put(type, pb.Id);
        }
        if (myDate != null) {
            thisDate = myDate;
        } else {
            thisDate = Date.today();
        }
    }

    global Batch_AutoOpportunities(Integer step,
            Map<String, Map<Id, Set<Id>>> step1AcctIds,
            Map<String, Map<Id, Map<Id, Map<String, Integer>>>> step1AcctRankingCount,
            Map<String, Map<Id, Map<Id, Map<String, Integer>>>> step1PrevAcctRankingCount,
            Map<String, Map<Id, Map<Id, Datetime>>> step1LatestRankingDates,
            Map<String, Map<Id, Map<Id, Integer>>> step1AcctSubmissionCount,
            Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>> step1AcctOppLinesByPub,
            Map<String, Map<Id, Map<Id, Set<OpportunityLineItem>>>> step1PrevAcctOppLinesByPub,
            Map<String, Map<Id, Map<Id, Set<String>>>> step1PracticeAreas) {

        this.step = step;
        this.step1AcctIds = step1AcctIds;
        this.step1AcctRankingCount = step1AcctRankingCount;
        this.step1PrevAcctRankingCount = step1PrevAcctRankingCount;
        this.step1LatestRankingDates = step1LatestRankingDates;
        this.step1AcctSubmissionCount = step1AcctSubmissionCount;
        this.step1AcctOppLinesByPub = step1AcctOppLinesByPub;
        this.step1PrevAcctOppLinesByPub = step1PrevAcctOppLinesByPub;
        this.step1PracticeAreas = step1PracticeAreas;
        for (Pricebook2 pb : [SELECT Id, Name FROM Pricebook2]) {
            String type = guideBooks.get(pb.Name);
            if (type != null) priceBooks.put(type, pb.Id);
        }

        thisDate = Date.today();

    }


    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Name, Id, SalesStartDate_RE__c, CC_Final_Date_RE__c, PreviousEdition__c, CC_PublicationTypeCategory__c, Year_Issue_RE__c FROM Publication__c WHERE (SalesStartDate_RE__c=:thisDate OR CC_Final_Date_RE__c=:thisDate) AND CC_PublicationTypeCategory__c IN :guideTypes';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Publication__c> scope) {
        String publicationIdStep1;
        String publicationIdStep2;
        // LIST OF Opptys TO CREATE
        List<Opportunity> newOpps = new List<Opportunity>();

        // LIST OF PUBLICATION IDS
        // Set<Id> pubIds = new Set<Id>();
        Set<Id> prevPubIds = new Set<Id>();
        Set<Id> curPubIds = new Set<Id>();
        Set<Id> allPubIds = new Set<Id>();
        Set<Id> carPubIds = new Set<Id>();

        // MAP OF PREV PUB IDS TO CURRENT PUB ID
        Map<Id, String> pubMap = new Map<Id, String>();
        Map<Id, Id> prevPubMap = new Map<Id, Id>();

        // MAP OF PUBLICATION NAMES
        Map<Id, String> pubNames = new Map<Id, String>();
        Map<Id, String> pubCats = new Map<Id, String>();
        Map<Id, Boolean> pubStart = new Map<Id, Boolean>();
        Map<Id, Date> pubStartDates = new Map<Id, Date>();

        for (Publication__c s : scope) {

            if (s.CC_PublicationTypeCategory__c == 'Career Guides')
                carPubIds.add(s.PreviousEdition__c);
            allPubIds.add(s.Id);
            curPubIds.add(s.Id);
            Boolean start = (s.SalesStartDate_RE__c == thisDate);
            if (s.PreviousEdition__c != null) {
                if (!prevPubIds.contains(s.PreviousEdition__c)) {
                    prevPubIds.add(s.PreviousEdition__c);
                    prevPubMap.put(s.PreviousEdition__c, s.Id);
                }
                if (!allPubIds.contains(s.PreviousEdition__c)) {
                    allPubIds.add(s.PreviousEdition__c);
                }
            }
            String pubCat = s.CC_PublicationTypeCategory__c == 'Professional Adviser Guides' ? 'Ranking Guides' : s.CC_PublicationTypeCategory__c;
            pubCats.put(s.Id, pubCat);
            pubNames.put(s.Id, s.Name);
            pubStart.put(s.Id, start);
            pubStartDates.put(s.Id, s.SalesStartDate_RE__c);
        }
        try {

            if (step == 1) {

                // LIST OF ACCTS TO PROCESS
                Map<Id, Set<Id>> acctIds = new Map<Id, Set<Id>>();

                // Ranking Data & Sell Profile Data
                Map<Id, Map<Id, Map<String, Integer>>> acctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Map<String, Integer>>> prevAcctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Integer>> acctSubmissionCount = new Map<Id, Map<Id, Integer>>();
                Map<Id, Map<Id, Integer>> prevAcctSubmissionCount = new Map<Id, Map<Id, Integer>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> acctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> prevAcctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<String>>> practiceAreas = new Map<Id, Map<Id, Set<String>>>();
                Map<Id, Map<Id, Datetime>> latestRankingDates = new Map<Id, Map<Id, Datetime>>();

                for (Publication__c pub : [
                        SELECT Id, (SELECT Publication_RE__c, Account_RE__c, RecordType.Name, Practice_Area_RE__c, CreatedDate FROM Rankings__r), (SELECT Organization_RE__c, Publication__c FROM Submissions__r), (SELECT Id, Opportunity.Id, Related_Organization__c, Publication__r.CC_PublicationTypeCategory__c, Publication__c, Opportunity.StageName, Opportunity.Type, Opportunity.AccountId, Product2.Product_Category__c, Opportunity.CloseDate, Practice_Area__r.Name FROM Opportunity_Product__r WHERE Opportunity.StageName = 'Closed Won')
                        FROM Publication__c
                        WHERE Id IN :allPubIds
                ]) {
                    publicationIdStep1 = pub.Id;

                    for (Rankings__c rank : pub.Rankings__r) {
                        Id thisPubId = rank.Publication_RE__c;
                        if (curPubIds.contains(thisPubId)) {
                            if (acctRankingCount.get(rank.Account_RE__c) == null)
                                acctRankingCount.put(rank.Account_RE__c, new Map<Id, Map<String, Integer>>());
                            if (acctRankingCount.get(rank.Account_RE__c).get(thisPubId) == null)
                                acctRankingCount.get(rank.Account_RE__c).put(thisPubId, new Map<String, Integer>());
                            if (acctRankingCount.get(rank.Account_RE__c).get(thisPubId).get(rank.RecordType.Name) == null)
                                acctRankingCount.get(rank.Account_RE__c).get(thisPubId).put(rank.RecordType.Name, 1);

                            // SET THE LATEST RANKING DATE
                            if (latestRankingDates.get(rank.Account_RE__c) == null)
                                latestRankingDates.put(rank.Account_RE__c, new Map<Id, Datetime>());
                            if (latestRankingDates.get(rank.Account_RE__c).get(thisPubId) == null || latestRankingDates.get(rank.Account_RE__c).get(thisPubId) < rank.CreatedDate)
                                latestRankingDates.get(rank.Account_RE__c).put(thisPubId, rank.CreatedDate);

                        } else {
                            thisPubId = prevPubMap.get(rank.Publication_RE__c);
                            if (prevAcctRankingCount.get(rank.Account_RE__c) == null)
                                prevAcctRankingCount.put(rank.Account_RE__c, new Map<Id, Map<String, Integer>>());
                            if (prevAcctRankingCount.get(rank.Account_RE__c).get(thisPubId) == null)
                                prevAcctRankingCount.get(rank.Account_RE__c).put(thisPubId, new Map<String, Integer>());
                            if (prevAcctRankingCount.get(rank.Account_RE__c).get(thisPubId).get(rank.RecordType.Name) == null)
                                prevAcctRankingCount.get(rank.Account_RE__c).get(thisPubId).put(rank.RecordType.Name, 1);
                        }
                        if (acctIds.get(rank.Account_RE__c) == null) acctIds.put(rank.Account_RE__c, new Set<Id>());
                        if (!acctIds.get(rank.Account_RE__c).contains(thisPubId)) acctIds.get(rank.Account_RE__c).add(thisPubId);
                    }
                    for (Submissions__c sub : pub.Submissions__r) {
                        Id thisPubId = sub.Publication__c;
                        if (curPubIds.contains(thisPubId)) {
                            if (acctSubmissionCount.get(sub.Organization_RE__c) == null) acctSubmissionCount.put(sub.Organization_RE__c, new Map<Id, Integer>());
                            acctSubmissionCount.get(sub.Organization_RE__c).put(thisPubId, 1);
                            if (acctIds.get(sub.Organization_RE__c) == null) acctIds.put(sub.Organization_RE__c, new Set<Id>());
                            if (!acctIds.get(sub.Organization_RE__c).contains(thisPubId)) acctIds.get(sub.Organization_RE__c).add(thisPubId);
                        }
                    }
                    for (OpportunityLineItem opp : pub.Opportunity_Product__r) {
                        Id thisPubId = opp.Publication__c;
                        Id thisAcctId = opp.Related_Organization__c != null ? opp.Related_Organization__c : opp.Opportunity.AccountId;
                        if (curPubIds.contains(thisPubId)) {
                            if (acctOppLinesByPub.get(thisAcctId) == null) acctOppLinesByPub.put(thisAcctId, new Map<Id, Set<OpportunityLineItem>>());
                            if (acctOppLinesByPub.get(thisAcctId).get(thisPubId) == null) acctOppLinesByPub.get(thisAcctId).put(thisPubId, new Set<OpportunityLineItem>());
                            acctOppLinesByPub.get(thisAcctId).get(thisPubId).add(opp);
                        } else {
                            thisPubId = prevPubMap.get(opp.Publication__c);
                            if (prevAcctOppLinesByPub.get(thisAcctId) == null) prevAcctOppLinesByPub.put(thisAcctId, new Map<Id, Set<OpportunityLineItem>>());
                            if (prevAcctOppLinesByPub.get(thisAcctId).get(thisPubId) == null) prevAcctOppLinesByPub.get(thisAcctId).put(thisPubId, new Set<OpportunityLineItem>());
                            prevAcctOppLinesByPub.get(thisAcctId).get(thisPubId).add(opp);

                        }
                        if (acctIds.get(thisAcctId) == null) acctIds.put(thisAcctId, new Set<Id>());
                        if (!acctIds.get(thisAcctId).contains(thisPubId)) acctIds.get(thisAcctId).add(thisPubId);
                    }
                    publicationIdStep1 = null;
                }
                for (String Id : curPubIds) {
                    step1AcctIds.put(Id, acctIds);
                    step1AcctRankingCount.put(Id, acctRankingCount);
                    step1PrevAcctRankingCount.put(Id, prevAcctRankingCount);
                    step1LatestRankingDates.put(Id, latestRankingDates);
                    step1AcctSubmissionCount.put(Id, acctSubmissionCount);
                    step1AcctOppLinesByPub.put(Id, acctOppLinesByPub);
                    step1PrevAcctOppLinesByPub.put(Id, prevAcctOppLinesByPub);
                    step1PracticeAreas.put(Id, practiceAreas);
                }

            }
        } catch (Exception e) {
            String pubName = '';
            for (Publication__c pub : [SELECT Name FROM Publication__c WHERE Id =: curPubIds]){
                pubName += pub.Name+'('+pub.Id+'), ';
            }
            String errorString = 'Error ' + (pubName != '' ? ('Publication: '+ pubName + '\n') : '') + e.getMessage() + '\n' + e.getStackTraceString();
            if (!errorMaps.containsKey('Step 1')) {
                errorMaps.put('Step 1', new List<String>());
            }
            errorMaps.get('Step 1').add(errorString);
        }

        try {
            if (step == 2) {
                Map<Id, Set<Id>> acctIds = new Map<Id, Set<Id>>();

                Map<Id, Map<Id, Map<String, Integer>>> acctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Map<String, Integer>>> prevAcctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Integer>> acctSubmissionCount = new Map<Id, Map<Id, Integer>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> acctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> prevAcctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<String>>> practiceAreas = new Map<Id, Map<Id, Set<String>>>();
                Map<Id, Map<Id, Datetime>> latestRankingDates = new Map<Id, Map<Id, Datetime>>();
                for (String Id : curPubIds) {
                    publicationIdStep2 = Id;
                    acctIds = step1AcctIds.get(Id);
                    acctRankingCount = step1AcctRankingCount.get(Id);
                    prevAcctRankingCount = step1PrevAcctRankingCount.get(Id);
                    latestRankingDates = step1LatestRankingDates.get(Id);
                    acctSubmissionCount = step1AcctSubmissionCount.get(Id);
                    acctOppLinesByPub = step1AcctOppLinesByPub.get(Id);
                    prevAcctOppLinesByPub = step1PrevAcctOppLinesByPub.get(Id);
                    practiceAreas = step1PracticeAreas.get(Id);
                }
                // MAP OF OPPORTUNITIES BY PUBLICATION
                Map<Id, Map<Id, Set<Opportunity>>> acctOppsByPub = new Map<Id, Map<Id, Set<Opportunity>>>();
                Map<Id, Map<Id, Set<Opportunity>>> prevAcctOppsByPub = new Map<Id, Map<Id, Set<Opportunity>>>();

                for (Opportunity opp : [SELECT Name, Id, EligibleProducts_RE__c, AccountId, Publication_RE__c, CreatedDate, StageName, Type FROM Opportunity WHERE Publication_RE__c IN :curPubIds AND StageName != 'Closed Lost' AND System_Generated__c = TRUE ORDER BY CreatedDate DESC]) {
                    Id thisPubId = opp.Publication_RE__c;
                    if (acctOppsByPub.get(opp.AccountId) == null) acctOppsByPub.put(opp.AccountId, new Map<Id, Set<Opportunity>>());
                    if (acctOppsByPub.get(opp.AccountId).get(thisPubId) == null) acctOppsByPub.get(opp.AccountId).put(thisPubId, new Set<Opportunity>());
                    acctOppsByPub.get(opp.AccountId).get(thisPubId).add(opp);
                    if (acctIds.get(opp.AccountId) == null) acctIds.put(opp.AccountId, new Set<Id>());
                    if (!acctIds.get(opp.AccountId).contains(thisPubId)) acctIds.get(opp.AccountId).add(thisPubId);
                }

                // MAP OF PREVIOUS OPPORTUNITIES FOR CAREER PUBLICATIONS
                if (!carPubIds.isEmpty())
                    for (Opportunity opp : [SELECT Name, Id, EligibleProducts_RE__c, AccountId, Publication_RE__c, CreatedDate, StageName, Type, System_Generated__c FROM Opportunity WHERE EligibleProducts_RE__c != NULL AND Publication_RE__c IN :carPubIds ORDER BY CreatedDate DESC]) {
                        Id thisPubId = prevPubMap.get(opp.Publication_RE__c);
                        if (prevAcctOppsByPub.get(opp.AccountId) == null) prevAcctOppsByPub.put(opp.AccountId, new Map<Id, Set<Opportunity>>());
                        if (prevAcctOppsByPub.get(opp.AccountId).get(thisPubId) == null) prevAcctOppsByPub.get(opp.AccountId).put(thisPubId, new Set<Opportunity>());
                        prevAcctOppsByPub.get(opp.AccountId).get(thisPubId).add(opp);
                        if (acctIds.get(opp.AccountId) == null) acctIds.put(opp.AccountId, new Set<Id>());
                        if (!acctIds.get(opp.AccountId).contains(thisPubId)) acctIds.get(opp.AccountId).add(thisPubId);
                    }

                // ASSOCIATE Account Rankings/Submissions/Opptys with Parent Accounts
                Map<Id, Map<Id, Map<String, Integer>>> headAcctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Map<String, Integer>>> headPrevAcctRankingCount = new Map<Id, Map<Id, Map<String, Integer>>>();
                Map<Id, Map<Id, Integer>> headAcctSubmissionCount = new Map<Id, Map<Id, Integer>>();
                Map<Id, Map<Id, Integer>> headPrevAcctSubmissionCount = new Map<Id, Map<Id, Integer>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> headAcctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<OpportunityLineItem>>> headPrevAcctOppLinesByPub = new Map<Id, Map<Id, Set<OpportunityLineItem>>>();
                Map<Id, Map<Id, Set<Opportunity>>> headAcctOppsByPub = new Map<Id, Map<Id, Set<Opportunity>>>();
                Map<Id, Map<Id, Set<Opportunity>>> headPrevAcctOppsByPub = new Map<Id, Map<Id, Set<Opportunity>>>();
                Map<Id, Map<Id, Set<String>>> headPracticeAreas = new Map<Id, Map<Id, Set<String>>>();
                Map<Id, Set<Id>> headAccts = new Map<Id, Set<Id>>();
                Map<Id, Map<Id, Datetime>> headLatestRankingDates = new Map<Id, Map<Id, Datetime>>();


                Set<Id> accts = new Set<Id>();
                for (Id aId : acctIds.keySet())
                    accts.add(aId);

                Set<Id> headAcctIds = new Set<Id>();

                // CREATE MAPS OF HEAD ACCOUNT DATA
                Map<Id, Map<String, Object>> allAcctData = new Map<Id, Map<String, Object>>();
                for (Account acct : [SELECT Id, Name, ParentId, Parent.Name, OwnerId, Owner.isActive, Parent.OwnerId, Parent.Owner.isActive, ShippingCountry, Type, Organization_Type_RE__c FROM Account WHERE Id IN :accts AND Type != '']) {

                    Id headId = (acct.ParentId != null ? acct.ParentId : acct.Id);
                    allAcctData.put(headId, new Map<String, Object>{
                            'Name' => acct.ParentId != null ? acct.Parent.Name : acct.Name,
                            'OwnerId' => (acct.ParentId != null && acct.Parent.Owner.isActive) ? acct.Parent.OwnerId : (acct.Owner.isActive ? acct.OwnerId : null),
                            'Country' => acct.ShippingCountry,
                            'Type' => acct.Type
                    });

                    if (headAcctRankingCount.get(headId) == null) headAcctRankingCount.put(headId, new Map<Id, Map<String, Integer>>());
                    if (headPrevAcctRankingCount.get(headId) == null) headPrevAcctRankingCount.put(headId, new Map<Id, Map<String, Integer>>());
                    if (headAcctSubmissionCount.get(headId) == null) headAcctSubmissionCount.put(headId, new Map<Id, Integer>());
                    if (headPrevAcctSubmissionCount.get(headId) == null) headPrevAcctSubmissionCount.put(headId, new Map<Id, Integer>());
                    if (headAcctOppLinesByPub.get(headId) == null) headAcctOppLinesByPub.put(headId, new Map<Id, Set<OpportunityLineItem>>());
                    if (headPrevAcctOppLinesByPub.get(headId) == null) headPrevAcctOppLinesByPub.put(headId, new Map<Id, Set<OpportunityLineItem>>());
                    if (headAcctOppsByPub.get(headId) == null) headAcctOppsByPub.put(headId, new Map<Id, Set<Opportunity>>());
                    if (headPrevAcctOppsByPub.get(headId) == null) headPrevAcctOppsByPub.put(headId, new Map<Id, Set<Opportunity>>());
                    if (headPracticeAreas.get(headId) == null) headPracticeAreas.put(headId, new Map<Id, Set<String>>());
                    if (headAccts.get(headId) == null) headAccts.put(headId, new Set<Id>());
                    if (headLatestRankingDates.get(headId) == null) headLatestRankingDates.put(headId, new Map<Id, Datetime>());

                    if (acctRankingCount.get(acct.Id) != null)
                        if (!headAcctRankingCount.containsKey(headId))
                            headAcctRankingCount.put(headId, prevAcctRankingCount.get(acct.Id)); else
                                for (Id pbId : acctRankingCount.get(acct.Id).keySet())
                                    if (!headAcctRankingCount.get(headId).containsKey(pbId))
                                        headAcctRankingCount.get(headId).put(pbId, acctRankingCount.get(acct.Id).get(pbId)); else
                                            for (String rType : acctRankingCount.get(acct.Id).get(pbId).keySet())
                                                if (!headAcctRankingCount.get(headId).get(pbId).containsKey(rType))
                                                    headAcctRankingCount.get(headId).get(pbId).put(rType, acctRankingCount.get(acct.Id).get(pbId).get(rType));

                    if (prevAcctRankingCount.get(acct.Id) != null)
                        if (!headPrevAcctRankingCount.containsKey(headId))
                            headPrevAcctRankingCount.put(headId, prevAcctRankingCount.get(acct.Id)); else
                                for (Id pbId : prevAcctRankingCount.get(acct.Id).keySet())
                                    if (!headPrevAcctRankingCount.get(headId).containsKey(pbId))
                                        headPrevAcctRankingCount.get(headId).put(pbId, prevAcctRankingCount.get(acct.Id).get(pbId)); else
                                            for (String rType : prevAcctRankingCount.get(acct.Id).get(pbId).keySet())
                                                if (!headPrevAcctRankingCount.get(headId).get(pbId).containsKey(rType))
                                                    headPrevAcctRankingCount.get(headId).get(pbId).put(rType, prevAcctRankingCount.get(acct.Id).get(pbId).get(rType));

                    if (latestRankingDates.get(acct.Id) != null)
                        if (!headLatestRankingDates.containsKey(headId))
                            headLatestRankingDates.put(headId, latestRankingDates.get(acct.Id)); else
                                for (Id pbId : latestRankingDates.get(acct.Id).keySet())
                                    if (!headLatestRankingDates.get(headId).containsKey(pbId) || headLatestRankingDates.get(headId).get(pbId) < latestRankingDates.get(acct.Id).get(pbId))
                                        headLatestRankingDates.get(headId).put(pbId, latestRankingDates.get(acct.Id).get(pbId));

                    if (acctSubmissionCount.get(acct.Id) != null)
                        if (!headAcctSubmissionCount.containsKey(headId))
                            headAcctSubmissionCount.put(headId, acctSubmissionCount.get(acct.Id)); else
                                for (Id pbId : acctSubmissionCount.get(acct.Id).keySet())
                                    if (!headAcctSubmissionCount.get(headId).containsKey(pbId))
                                        headAcctSubmissionCount.get(headId).put(pbId, acctSubmissionCount.get(acct.Id).get(pbId));

                    if (acctOppLinesByPub.get(acct.Id) != null)
                        if (!headAcctOppLinesByPub.containsKey(headId))
                            headAcctOppLinesByPub.put(headId, acctOppLinesByPub.get(acct.Id)); else
                                for (Id pbId : acctOppLinesByPub.get(acct.Id).keySet())
                                    if (!headAcctOppLinesByPub.get(headId).containsKey(pbId))
                                        headAcctOppLinesByPub.get(headId).put(pbId, acctOppLinesByPub.get(acct.Id).get(pbId)); else
                                            for (OpportunityLineItem r : acctOppLinesByPub.get(acct.Id).get(pbId))
                                                if (!headAcctOppLinesByPub.get(headId).get(pbId).contains(r))
                                                    headAcctOppLinesByPub.get(headId).get(pbId).add(r);

                    if (prevAcctOppLinesByPub.get(acct.Id) != null)
                        if (!headPrevAcctOppLinesByPub.containsKey(headId))
                            headPrevAcctOppLinesByPub.put(headId, prevAcctOppLinesByPub.get(acct.Id)); else
                                for (Id pbId : prevAcctOppLinesByPub.get(acct.Id).keySet())
                                    if (!headPrevAcctOppLinesByPub.get(headId).containsKey(pbId))
                                        headPrevAcctOppLinesByPub.get(headId).put(pbId, prevAcctOppLinesByPub.get(acct.Id).get(pbId)); else
                                            for (OpportunityLineItem r : prevAcctOppLinesByPub.get(acct.Id).get(pbId))
                                                if (!headPrevAcctOppLinesByPub.get(headId).get(pbId).contains(r))
                                                    headPrevAcctOppLinesByPub.get(headId).get(pbId).add(r);

                    if (practiceAreas.get(acct.Id) != null)
                        if (!headPracticeAreas.containsKey(headId))
                            headPracticeAreas.put(headId, practiceAreas.get(acct.Id)); else
                                for (Id pbId : practiceAreas.get(acct.Id).keySet())
                                    if (!headPracticeAreas.get(headId).containsKey(pbId))
                                        headPracticeAreas.get(headId).put(pbId, practiceAreas.get(acct.Id).get(pbId)); else
                                            for (String r : practiceAreas.get(acct.Id).get(pbId))
                                                if (!headPracticeAreas.get(headId).get(pbId).contains(r))
                                                    headPracticeAreas.get(headId).get(pbId).add(r);

                    if (acctOppsByPub.get(acct.Id) != null)
                        if (!headAcctOppsByPub.containsKey(headId))
                            headAcctOppsByPub.put(headId, acctOppsByPub.get(acct.Id)); else
                                for (Id pbId : acctOppsByPub.get(acct.Id).keySet())
                                    if (!headAcctOppsByPub.get(headId).containsKey(pbId))
                                        headAcctOppsByPub.get(headId).put(pbId, acctOppsByPub.get(acct.Id).get(pbId)); else
                                            for (Opportunity r : acctOppsByPub.get(acct.Id).get(pbId))
                                                if (!headAcctOppsByPub.get(headId).get(pbId).contains(r))
                                                    headAcctOppsByPub.get(headId).get(pbId).add(r);

                    if (prevAcctOppsByPub.get(acct.Id) != null)
                        if (!headPrevAcctOppsByPub.containsKey(headId))
                            headPrevAcctOppsByPub.put(headId, prevAcctOppsByPub.get(acct.Id)); else
                                for (Id pbId : prevAcctOppsByPub.get(acct.Id).keySet())
                                    if (!headPrevAcctOppsByPub.get(headId).containsKey(pbId))
                                        headPrevAcctOppsByPub.get(headId).put(pbId, prevAcctOppsByPub.get(acct.Id).get(pbId)); else
                                            for (Opportunity r : prevAcctOppsByPub.get(acct.Id).get(pbId))
                                                if (!headPrevAcctOppsByPub.get(headId).get(pbId).contains(r))
                                                    headPrevAcctOppsByPub.get(headId).get(pbId).add(r);

                    for (Id pubId : acctIds.get(acct.Id)) {
                        if (!headAccts.get(headId).contains(pubId))
                            headAccts.get(headId).add(pubId);
                    }

                    if (!headAcctIds.contains(headId)) headAcctIds.add(headId);
                }

                // CREATE MAP OF HEAD ACCOUNT TEAM MEMBERS
                Map<Id, Map<String, Id>> acctTeamMembers = new Map<Id, Map<String, Id>>();
                for (AccountTeamMember tm : [SELECT Id, TeamMemberRole, AccountId, UserId FROM AccountTeamMember WHERE AccountId IN:headAcctIds AND User.isActive = true]) {
                    if (acctTeamMembers.get(tm.AccountId) == null) acctTeamMembers.put(tm.AccountId, new Map<String, Id>());
                    String guide = '';
                    String role = tm.TeamMemberRole != null ? tm.TeamMemberRole.toLowerCase() : '';
                    if (role.contains('ranking')) {
                        guide = 'Ranking Guides';
                    } else if (role.contains('career')) {
                        guide = 'Career Guides';
                    } else if (role.contains('practice')) {
                        guide = 'Practice Guides';
                    }
                    if (guide == null) continue;
                    if (acctTeamMembers.get(tm.AccountId).get(guide) == null) acctTeamMembers.get(tm.AccountId).put(guide, tm.UserId);
                }

                for (Id acctId : headAccts.keySet()) {
                    if (acctId == null)
                        continue;

                    Map<String, Object> acctData = allAcctData.get(acctId);
                    String oppName = (acctData != null && acctData.get('Name') != null) ? (String) acctData.get('Name') : '';
                    Id ownerId = (acctData != null && acctData.get('OwnerId') != null) ? (Id) acctData.get('OwnerId') : null;
                    String country = (acctData != null && acctData.get('Country') != null) ? (String) acctData.get('Country') : '';
                    String type = (acctData != null && acctData.get('Type') != null) ? (String) acctData.get('Type') : '';

                    Map<String, Id> teamMembers = (acctTeamMembers != null && acctTeamMembers.get(acctId) != null) ? acctTeamMembers.get(acctId) : null;

                    Map<Id, Map<String, Integer>> acctRankings = headAcctRankingCount.get(acctId);
                    Map<Id, Map<String, Integer>> acctPrevRankings = headPrevAcctRankingCount.get(acctId);
                    Map<Id, Integer> acctSubs = headAcctSubmissionCount.get(acctId);
                    Map<Id, Set<OpportunityLineItem>> acctOppsLines = headAcctOppLinesByPub.get(acctId);
                    Map<Id, Set<OpportunityLineItem>> acctPrevOppsLines = headPrevAcctOppLinesByPub.get(acctId);
                    Map<Id, Set<Opportunity>> acctOpps = headAcctOppsByPub.get(acctId);
                    Map<Id, Set<Opportunity>> prevAcctOpps = headPrevAcctOppsByPub.get(acctId);
                    Map<Id, Set<String>> acctPAs = headPracticeAreas.get(acctId);
                    Map<Id, Datetime> acctLateRankDates = headLatestRankingDates.get(acctId);

                    for (Id pubId : headAccts.get(acctId)) {
                        publicationIdStep2 = pubId;
                        Boolean start = pubStart.get(pubId);
                        String pubName = (pubNames != null ? pubNames.get(pubId) : '');
                        String pubOppName = oppName + ' - ' + pubName;
                        Boolean wasRanked = (acctRankings != null && acctRankings.get(pubId) != null);
                        Boolean wasPrevRanked = (acctPrevRankings != null && acctPrevRankings.get(pubId) != null);
                        Boolean hasSubs = (acctSubs != null && acctSubs.get(pubId) != null);
                        String pubCat = (pubCats != null && pubCats.get(pubId) != null) ? pubCats.get(pubId) : 'Ranking Guides';
                        Id priceBook = priceBooks.get(pubCat);
                        ownerId = (teamMembers != null && teamMembers.get(pubCat) != null) ? teamMembers.get(pubCat) : ownerId;

                        Set<Opportunity> pubOpps = acctOpps != null ? acctOpps.get(pubId) : null;
                        Set<Opportunity> prevPubOpps = prevAcctOpps != null ? prevAcctOpps.get(pubId) : null;

                        Set<OpportunityLineItem> boughtProducts = acctOppsLines.get(pubId);
                        Boolean bought = (boughtProducts != null && !boughtProducts.isEmpty());

                        Set<OpportunityLineItem> prevBoughtProducts = acctPrevOppsLines.get(pubId);
                        Boolean prevBought = (prevBoughtProducts != null && !prevBoughtProducts.isEmpty());
                        Boolean prevNotBought = (prevPubOpps != null && !prevPubOpps.isEmpty());

                        String elgProds = '';
                        Map<String, Integer> pubRankings = acctRankings != null ? acctRankings.get(pubId) : null;
                        Integer pubSubs = acctSubs != null ? acctSubs.get(pubId) : null;
                        Map<String, Integer> prevPubRankings = acctPrevRankings != null ? acctPrevRankings.get(pubId) : null;
                        Set<String> pubPAs = acctPAs != null ? acctPAs.get(pubId) : null;

                        Datetime latestRankingDate = acctLateRankDates.get(pubId);

                        Boolean doNew = false;
                        if (pubCat == 'Ranking Guides') {
                            // IF ORG RANKINGS Add Firm Profiles & Firm Plaques
                            doNew = true;
                            if ((pubRankings != null &&
                                    pubRankings.get('Organization Ranking') != null &&
                                    pubRankings.get('Organization Ranking') > 0) ||
                                    (prevPubRankings != null &&
                                            prevPubRankings.get('Organization Ranking') != null &&
                                            prevPubRankings.get('Organization Ranking') > 0) ||
                                    prevBought)
                                elgProds += (elgProds != '' ? '||' : '') + 'Firm Profiles';
                            if ((pubRankings != null &&
                                    pubRankings.get('Organization Ranking') != null &&
                                    pubRankings.get('Organization Ranking') > 0) || (prevPubRankings != null &&
                                    prevPubRankings.get('Organization Ranking') != null &&
                                    prevPubRankings.get('Organization Ranking') > 0))
                                elgProds += (elgProds != '' ? '||' : '') + 'Firm Plaques';

                            // IF PERSON RANKINGS for Current and Previous Pub Add Individual Profiles
                            if ((pubRankings != null &&
                                    pubRankings.get('Person Ranking') != null &&
                                    pubRankings.get('Person Ranking') > 0) ||
                                    (prevPubRankings != null &&
                                            prevPubRankings.get('Person Ranking') != null &&
                                            prevPubRankings.get('Person Ranking') > 0))
                                elgProds += (elgProds != '' ? '||' : '') + 'Individual Profiles||Individual Plaques';


                            // IF SUBMISSIONS Add Unpublished Reports
                            if ((pubSubs != null && pubSubs > 0)) // || (prevPubSubs!=null && prevPubSubs>0)
                                elgProds += (elgProds != '' ? '||' : '') + 'Unpublished Reports';
                            // IF RANKINGS Add PFOs
                            if (wasRanked)
                                elgProds += (elgProds != '' ? '||' : '') + 'PFOs';

                        } else if (pubCat == 'Career Guides') {
                            if (type == null || (type != null && type != 'Clients' && type != 'Set'))
                                if ((country == 'US' || country == 'USA' || country == 'UK') && (prevBought || prevNotBought)) {
                                    wasPrevRanked = prevNotBought;
                                    elgProds = (country == 'UK' ? guideProducts.get('Student Career Guides') : guideProducts.get('Associate Career Guides'));
                                    doNew = true;
                                }
                        } else if (pubCat == 'Practice Guides') {
                            // Practice_Area contains Banking & Finance
                            if (prevBought) {
                                elgProds = guideProducts.get('Practice Guides');
                                doNew = true;
                            }
                        }

                        Boolean doAddOn = false;
                        String prevBoughtProds = '';
                        Date latestCloseDate;
                        if (boughtProducts != null)
                            for (OpportunityLineItem oppLine : boughtProducts) {
                                latestCloseDate = (latestCloseDate == null || oppLine.Opportunity.CloseDate > latestCloseDate) ? oppLine.Opportunity.CloseDate : latestCloseDate;
                                prevBoughtProds += (prevBoughtProds != '' ? '||' : '') + oppLine.Product2.Product_Category__c + 's';
                            }

                        for (String elgProd : elgProds.split('\\|\\|'))
                            if (!prevBoughtProds.contains(elgProd))
                                doAddOn = true;

                        if (!doAddOn && latestCloseDate < latestRankingDate)
                            doAddOn = true;

                        Boolean createNew = (pubOpps == null);
                        Boolean addOn = false;

                        Boolean noOpps = (pubOpps == null);
                        Boolean hasAddOn = false;
                        Boolean hasClosed = false;
                        Integer closedOpps = 0;
                        if (pubOpps != null) {
                            for (Opportunity pubOpp : pubOpps) {
                                if (pubOpp.stageName == 'Closed Won') {
                                    hasClosed = true;
                                    closedOpps++;
                                } else {
                                    if (pubOpp.Type == 'Add-on')
                                        hasAddOn = true;
                                    pubOpp.EligibleProducts_RE__c = elgProds;
//                                        System.debug(pubOpp);
                                    newOpps.add(pubOpp);
                                }
                            }
                        }

                        if (hasClosed && !hasAddon && doAddOn) {
                            createNew = true;
                            addOn = true;
                        } else if (hasClosed && pubOpps.size() == closedOpps) {
                            createNew = false;
                        }

                        if (doNew && createNew) {
                            String oppType = 'New';
                            if (wasPrevRanked)
                                oppType = 'Eligible';
                            if (prevBought)
                                oppType = 'Repeat';
                            if (addOn)
                                oppType = 'Add-on';
                            Opportunity thisOpp = new Opportunity();
                            if (ownerId != null)
                                if (Test.isRunningTest()) {
                                    thisOpp.OwnerId = null;
                                } else {
                                    thisOpp.OwnerId = ownerId;
                                }
                            thisOpp.AccountId = acctId;
                            thisOpp.Name = pubOppName.length() > 120 ? pubOppName.substring(0, 120) : pubOppName;
                            thisOpp.Publication_RE__c = pubId;
                            thisOpp.StageName = 'Qualified';
                            thisOpp.CloseDate = pubStartDates.get(pubId) != null ? pubStartDates.get(pubId).addYears(1) : Date.today().addYears(1);
                            thisOpp.Pricebook2Id = priceBook;

                            thisOpp.Type = oppType;
                            thisOpp.System_Generated__c = true;
                            thisOpp.EligibleProducts_RE__c = elgProds;
                            newOpps.add(thisOpp);
                        }
                        publicationIdStep2 = null;
                    }
                }
                upsert newOpps;

            }
        } catch (Exception e) {
            String pubName = '';
            for (Publication__c pub : [SELECT Name FROM Publication__c WHERE Id =: curPubIds]){
                pubName += pub.Name+'('+pub.Id+'), ';
            }
            String errorString = 'Error ' + (pubName != '' ? ('Publication: '+ pubName + '\n') : '') + e.getMessage() + '\n' + e.getStackTraceString();
            if (!errorMaps.containsKey('Step 2')) {
                errorMaps.put('Step 2', new List<String>());
            }
            errorMaps.get('Step 2').add(errorString);

        }

    }

    global void finish(Database.BatchableContext BC) {
        if (step == 1) {

            Database.executeBatch(new Batch_AutoOpportunities(2,
                    step1AcctIds,
                    step1AcctRankingCount,
                    step1PrevAcctRankingCount,
                    step1LatestRankingDates,
                    step1AcctSubmissionCount,
                    step1AcctOppLinesByPub,
                    step1PrevAcctOppLinesByPub,
                    step1PracticeAreas));
        }

        if (!errorMaps.isEmpty()) {

            List<String> emails = new List<String>();
            for (User u : [SELECT Id, Email FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE]) {
                emails.add(u.Email);
            }

            String body = 'Opportunity automation has failed so the publications which had Sales start date of today will not have the opportunities created. \n'
                    + 'There were errors.\n';

            for (String step : errorMaps.keySet()) {
                for (String error : errorMaps.get(step)) {
                    body = body + step + '\n' + errorMaps.get(step) + '\n';
                }
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(emails);
            mail.setSenderDisplayName('Apex error message');
            mail.setSubject('Error from Batch AutoOpportunities : ' + UserInfo.getOrganizationName());
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
        }
    }

}