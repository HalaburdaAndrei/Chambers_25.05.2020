public with sharing class PersonSalesTargetWithPublController {

    private final static Integer startFyMonth = 7;
    private final static Integer cuntMonths = 12;
    private List<Date> tableDate;

    @AuraEnabled
    public static List<Date> generateDates(Integer selectedYear){
        List<Date> datesRange = new List<date>();
        Date startdate = Date.newInstance(selectedYear, startFyMonth, 1);
        datesRange.add(startdate);
        for(Integer i = startFyMonth; i < startFyMonth + cuntMonths - 1; i++) {
            datesRange.add(datesRange[datesRange.size() - 1].addMonths(1));
        }
        System.debug(datesRange);


        return datesRange;
    }

    @AuraEnabled
    public static Map<String,List<String>> generateDataTable (){
        Map<String,List<String>> userTable = new Map<String, List<String>>();

        for(Integer i = 1; i <= 5; i++ ){
            userTable.put('User '+ i, new List<String>() );
            for(Integer k = 1; k <= 24; k++ ){
               userTable.get('User '+ i).add('t' + k);
            }
        }
        System.debug(userTable);
        return userTable;
    }

    public class SalesPerson {
        @AuraEnabled
        String userName {get;set;}
        @AuraEnabled
        String userId {get;set;}
        @AuraEnabled
        List<String> salesTargets {get;set;}
        @AuraEnabled
        List<PublicationTarget> publicTarget {get;set;}
        @AuraEnabled
        Boolean expanded { get; set; }

        SalesPerson(){
            salesTargets = new List<String>();
            publicTarget = new List<PublicationTarget>();
            expanded = true;
        }
    }

    public class PublicationTarget {
        String publicationName {get;set;}
        String publicationId {get;set;}
        List<String> publicTargets {get;set;}
    }
}