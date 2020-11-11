public with sharing class PersonSalesTargetWithPublController {

    private final static Integer startFyMonth = 7;
    private final static Integer cuntMonths = 12;
    private final static Set<String> userProfileName = new Set<String>();
    private List<Date> tableDate;

    @AuraEnabled
    public static List<Date> generateDates(Integer selectedYear) {
        List<Date> datesRange = new List<date>();
        Date startdate = Date.newInstance(selectedYear, startFyMonth, 1);
        datesRange.add(startdate);
        for (Integer i = startFyMonth; i < startFyMonth + cuntMonths - 1; i++) {
            datesRange.add(datesRange[datesRange.size() - 1].addMonths(1));
        }
        System.debug(datesRange);


        return datesRange;
    }

    @AuraEnabled
    public static Map<String, Object> generateDataTable(Integer selectedYear) {
        Map<String, Object> resultTable = new Map<String, Object>();
        List<Date> years = generateDates(selectedYear);
        userProfileName.add('Sales Rep');
        userProfileName.add('Sales Management');
        Date startDate = Date.newInstance(selectedYear, startFyMonth, 1);
        Date endDate = Date.newInstance(selectedYear, startFyMonth + cuntMonths - 1, 1);

        Map<Id, String> mapUserName = new Map<Id, String>();
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String, Map<String, List<Sales_Target__c>>> userTable = new Map<String, Map<String, List<Sales_Target__c>>>();
//        List<Sales_Target__c> listSalesTargets = [
//                SELECT Id, Sales_Person__c, Sales_Person__r.Name, Date__c, Target__c, Publication__c, Publication__r.Name, Publication_Visible__c, Directory_Target__c, Insights_Target__c
//                FROM Sales_Target__c
//                WHERE Publication_Visible__c = TRUE
//        ];

        List<User> listUsers = [
                SELECT
                        Id,
                        Name, (
                        SELECT
                                Id,
                                Sales_Person__c,
                                Sales_Person__r.Name,
                                Date__c, Target__c,
                                Publication__c,
                                Publication__r.Name,
                                Publication_Visible__c,
                                Directory_Target__c,
                                Insights_Target__c
                        FROM Sales_Targets__r
                        WHERE CALENDAR_YEAR(Date__c) >= :startDate.year()
                        AND CALENDAR_YEAR(Date__c) <= :endDate.year()
                        AND Publication_Visible__c = TRUE
                        ORDER BY Date__c
                )
                FROM User
                WHERE Profile.Name IN :userProfileName
                AND IsActive = TRUE
                ORDER BY Name
        ];

        for (User us : listUsers) {
            if (!userTable.containsKey(us.Id)) {
                userTable.put(us.Id, new Map<String, List<Sales_Target__c>>());
            }
            if(!mapUserName.containsKey(us.Id)){
                mapUserName.put(us.Id,us.Name);
            }
            for (Sales_Target__c st : us.Sales_Targets__r) {
                if (!userTable.get(st.Sales_Person__c).containsKey(st.Publication__c)) {
                    userTable.get(st.Sales_Person__c).put(st.Publication__c, new List<Sales_Target__c>());
                }
                if(!mapPublicationName.containsKey(st.Publication__c)){
                    mapPublicationName.put(st.Publication__c, st.Publication__r.Name);
                }
                userTable.get(st.Sales_Person__c).get(st.Publication__c).add(st);
            }
        }

        List<SalesPerson> listSalesPerson = new List<SalesPerson>();

        for (String userId : userTable.keySet()) {
            SalesPerson slPerson = new SalesPerson();
            slPerson.expanded = false;
            slPerson.userName = mapUserName.get(userId);
            slPerson.userId = userId;
            List<UserTarget> listUserTarget = new List<UserTarget>();
            for (Date dateYear : years) {
                UserTarget target = new UserTarget();
                target.dateTarget = dateYear;
                target.directTarget = 0;
                target.insightTarget = 0;
                listUserTarget.add(target);
            }
            slPerson.usTargets = listUserTarget;

            List<PublicationRow> listPublicationNames = new List<PublicationRow>();
            for (String pubId : userTable.get(userId).keySet()) {
                List<Sales_Target__c> lstSalesTargets = userTable.get(userId).get(pubId);

                PublicationRow pubName = new PublicationRow();
                pubName.publnName = mapPublicationName.get(pubId);
                pubName.publicationId = pubId;

                List<Sales_Target__c> listTarget = new List<Sales_Target__c>();
                for (Date dateYear : years) {
                    Sales_Target__c target = new Sales_Target__c();
                    target.Date__c = dateYear;
                    target.Sales_Person__c = userId;
                    target.Publication__c = pubId;
                    target.Directory_Target__c = null;
                    target.Insights_Target__c = null;
                    target.Publication_Visible__c = true;
                    listTarget.add(target);
                }
                for (Sales_Target__c target : listTarget) {
                    for (Sales_Target__c sTarget : lstSalesTargets) {
                        if (target.Date__c == sTarget.Date__c) {
                            target.Id = sTarget.Id;
                            target.Sales_Person__c = sTarget.Sales_Person__c;
                            target.Publication__c = sTarget.Publication__c;
                            target.Publication_Visible__c = sTarget.Publication_Visible__c;
                            target.Directory_Target__c = sTarget.Directory_Target__c;
                            target.Insights_Target__c = sTarget.Insights_Target__c;
                        }
                    }
                }
//                pubName.publicTargets = listTarget;
                pubName.publicTargets1 = listTarget;
                listPublicationNames.add(pubName);

            }
            slPerson.publications = listPublicationNames;
            listSalesPerson.add(slPerson);

        }

        if (listSalesPerson.size() > 0) {
            resultTable.put('table', listSalesPerson);
        }

        System.debug(resultTable);
        return resultTable;
    }

    @AuraEnabled
    public static List<SalesPerson> addPublicationList (List<Publication__c> newlistPubl, Integer selectedYear, List<String> listUser, String oldListSalesPerson) {
        List<Date> years = generateDates(selectedYear);
        Date startDate = Date.newInstance(selectedYear, startFyMonth, 1);
        Date endDate = Date.newInstance(selectedYear, startFyMonth + cuntMonths - 1, 1);
        List<Sales_Target__c> checkTarget = [
                SELECT Id,
                        Name,
                        Sales_Person__c,
                        Sales_Person__r.Name,
                        Publication__c,
                        Publication__r.Name,
                        Directory_Target__c,
                        Insights_Target__c,
                        Publication_Visible__c,
                        Date__c
                FROM Sales_Target__c
                WHERE Sales_Person__c IN: listUser
                AND CALENDAR_YEAR(Date__c) >= :startDate.year()
                AND CALENDAR_YEAR(Date__c) <= :endDate.year()

        ];

        List<SalesPerson> parsSalesPerson = (List<SalesPerson>)JSON.deserialize(oldListSalesPerson, List<SalesPerson>.class);
        System.debug(parsSalesPerson);

        Map<Id, String> mapUserName = new Map<Id, String>();
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String,Map<String,List<Sales_Target__c>>> mapUserPublicationTarget = new Map<String,Map<String,List<Sales_Target__c>>>();

        for(SalesPerson salesper : parsSalesPerson){
            if(!mapUserPublicationTarget.containsKey(salesper.userId)) {
                mapUserPublicationTarget.put(salesper.userId, new Map<String, List<Sales_Target__c>>());
            }
            if(!mapUserName.containsKey(salesper.userId)){
                mapUserName.put(salesper.userId,salesper.userName);
            }
            for(PublicationRow pubRow : salesper.publications){
                if(!mapUserPublicationTarget.get(salesper.userId).containsKey(pubRow.publicationId)) {
                    mapUserPublicationTarget.get(salesper.userId).put(pubRow.publicationId, new List<Sales_Target__c>());
                }
                if(!mapPublicationName.containsKey(pubRow.publicationId)){
                    mapPublicationName.put(pubRow.publicationId, pubRow.publnName);
                }

            }
        }

        for(User user : [SELECT Id, Name FROM User WHERE Id IN: listUser]){
            if(!mapUserPublicationTarget.containsKey(user.Id)){
                mapUserPublicationTarget.put(user.Id, new Map<String, List<Sales_Target__c>>());

            }
            for(Publication__c pub : newlistPubl){
                if(!mapUserPublicationTarget.get(user.Id).containsKey(pub.Id)) {
                    mapUserPublicationTarget.get(user.Id).put(pub.Id, new List<Sales_Target__c>());
                }
                if(!mapPublicationName.containsKey(pub.Id)){
                    mapPublicationName.put(pub.Id, pub.Name);
                }
            }
            if(!mapUserName.containsKey(user.Id)){
                mapUserName.put(user.Id,user.Name);
            }


        }

        for(Sales_Target__c st : checkTarget){
            if(st.Publication__c != null) {
                if (!mapUserPublicationTarget.containsKey(st.Sales_Person__c)) {
                    mapUserPublicationTarget.put(st.Sales_Person__c, new Map<String, List<Sales_Target__c>>());
                }
                if (!mapUserPublicationTarget.get(st.Sales_Person__c).containsKey(st.Publication__c)) {
                    mapUserPublicationTarget.get(st.Sales_Person__c).put(st.Publication__c, new List<Sales_Target__c>());

                }
                if (!mapPublicationName.containsKey(st.Publication__c)) {
                    mapPublicationName.put(st.Publication__c, st.Publication__r.Name);
                }
                if (!mapUserName.containsKey(st.Sales_Person__c)) {
                    mapUserName.put(st.Sales_Person__c, st.Sales_Person__r.Name);
                }
                mapUserPublicationTarget.get(st.Sales_Person__c).get(st.Publication__c).add(st);
            }
        }
        List<Sales_Target__c> upsertSalesTarget = new List<Sales_Target__c>();
        List<SalesPerson> listSalesPerson = new List<SalesPerson>();

        for (String userId : mapUserPublicationTarget.keySet()) {
            SalesPerson slPerson = new SalesPerson();
            slPerson.expanded = false;
            slPerson.userName = mapUserName.get(userId);
            slPerson.userId = userId;


            List<PublicationRow> listPublicationNames = new List<PublicationRow>();
            for (String pubId : mapUserPublicationTarget.get(userId).keySet()) {
                List<Sales_Target__c> lstSalesTargets = mapUserPublicationTarget.get(userId).get(pubId);

                PublicationRow pubName = new PublicationRow();
                pubName.publnName = mapPublicationName.get(pubId);
                pubName.publicationId = pubId;

                List<Sales_Target__c> listTarget = new List<Sales_Target__c>();
                for (Date dateYear : years) {
                    Sales_Target__c target = new Sales_Target__c();
                    target.Date__c = dateYear;
                    target.Sales_Person__c = userId;
                    target.Publication__c = pubId;
                    target.Directory_Target__c = null;
                    target.Insights_Target__c = null;
                    target.Publication_Visible__c = true;
                    listTarget.add(target);
                    upsertSalesTarget.add(target);
                }
                for (Sales_Target__c target : listTarget) {
                    for (Sales_Target__c sTarget : lstSalesTargets) {
                        if (target.Date__c == sTarget.Date__c) {
                            target.Id = sTarget.Id;
                            target.Sales_Person__c = sTarget.Sales_Person__c;
                            target.Publication__c = sTarget.Publication__c;
                            target.Publication_Visible__c = true;
                            target.Directory_Target__c = sTarget.Directory_Target__c;
                            target.Insights_Target__c = sTarget.Insights_Target__c;

                        }
                    }
                }
//                pubName.publicTargets = listTarget;
//                pubName.publicTargets = listTarget;
                pubName.publicTargets1 = listTarget;
                listPublicationNames.add(pubName);

            }
            slPerson.publications = listPublicationNames;
            listSalesPerson.add(slPerson);

        }

        upsert(upsertSalesTarget);

        return listSalesPerson;
    }

    @AuraEnabled
    public static void deletePublication (Integer selectedYear, String oldListSalesPerson){
        List<SalesPerson> parsSalesPerson = (List<SalesPerson>)JSON.deserialize(oldListSalesPerson, List<SalesPerson>.class);
        System.debug(parsSalesPerson);

        Map<Id, String> mapUserName = new Map<Id, String>();
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String,Map<String,List<Sales_Target__c>>> mapUserPublicationTarget = new Map<String,Map<String,List<Sales_Target__c>>>();

        List<Sales_Target__c> updateSalesTarget = new List<Sales_Target__c>();

        for(SalesPerson salesper : parsSalesPerson){
            if(!mapUserPublicationTarget.containsKey(salesper.userId)) {
                mapUserPublicationTarget.put(salesper.userId, new Map<String, List<Sales_Target__c>>());
            }
            if(!mapUserName.containsKey(salesper.userId)){
                mapUserName.put(salesper.userId,salesper.userName);
            }
            for(PublicationRow pubRow : salesper.publications){
                if(!mapUserPublicationTarget.get(salesper.userId).containsKey(pubRow.publicationId)) {
                    mapUserPublicationTarget.get(salesper.userId).put(pubRow.publicationId, new List<Sales_Target__c>());
                }
                if(!mapPublicationName.containsKey(pubRow.publicationId)){
                    mapPublicationName.put(pubRow.publicationId, pubRow.publnName);
                }
            for(Sales_Target__c st : pubRow.publicTargets1){
                System.debug(st);
                if(st.Publication_Visible__c == true){
                    mapUserPublicationTarget.get(salesper.userId).get(pubRow.publicationId).add(st);
                }
                if(st.Publication_Visible__c == false){
                    updateSalesTarget.add(st);
                }

            }
            }
        }

        update updateSalesTarget;

//        return null;
    }

    @AuraEnabled
    public static void saveSalesTarget ( String salesTarget){
        List<SalesPerson> parsSalesPerson = (List<SalesPerson>)JSON.deserialize(salesTarget, List<SalesPerson>.class);
        System.debug(parsSalesPerson);

        Map<Id, String> mapUserName = new Map<Id, String>();
        Map<Id, String> mapPublicationName = new Map<Id, String>();
        Map<String,Map<String,List<Sales_Target__c>>> mapUserPublicationTarget = new Map<String,Map<String,List<Sales_Target__c>>>();

        List<Sales_Target__c> updateSalesTarget = new List<Sales_Target__c>();

        for(SalesPerson salesper : parsSalesPerson){
            if(!mapUserPublicationTarget.containsKey(salesper.userId)) {
                mapUserPublicationTarget.put(salesper.userId, new Map<String, List<Sales_Target__c>>());
            }
            if(!mapUserName.containsKey(salesper.userId)){
                mapUserName.put(salesper.userId,salesper.userName);
            }
            for(PublicationRow pubRow : salesper.publications){
                if(!mapUserPublicationTarget.get(salesper.userId).containsKey(pubRow.publicationId)) {
                    mapUserPublicationTarget.get(salesper.userId).put(pubRow.publicationId, new List<Sales_Target__c>());
                }
                if(!mapPublicationName.containsKey(pubRow.publicationId)){
                    mapPublicationName.put(pubRow.publicationId, pubRow.publnName);
                }
                for(Sales_Target__c st : pubRow.publicTargets1){
                    System.debug(st);
                        updateSalesTarget.add(st);


                }
            }
        }

        update updateSalesTarget;
    }

    public class SalesPerson {
        @AuraEnabled
        String userName { get; set; }
        @AuraEnabled
        String userId { get; set; }
        @AuraEnabled
        List<UserTarget> usTargets { get; set; }
        @AuraEnabled
        List<PublicationRow> publications { get; set; }
        @AuraEnabled
        Boolean expanded { get; set; }

        SalesPerson() {
            usTargets = new List<UserTarget>();

            publications = new List<PublicationRow>();
            expanded = true;
        }
    }

    public class PublicationRow {
        @AuraEnabled
        String publnName { get; set; }
        @AuraEnabled
        String publicationId { get; set; }

        @AuraEnabled
        List<Sales_Target__c> publicTargets1 { get; set; }

        PublicationRow() {
            publicTargets1 = new List<Sales_Target__c>();
        }
    }

    public class UserTarget {
        @AuraEnabled
        Date dateTarget { get; set; }
        @AuraEnabled
        Double directTarget { get; set; }
        @AuraEnabled
        Double insightTarget { get; set; }
    }
}