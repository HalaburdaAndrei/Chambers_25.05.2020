public with sharing class OpportunityHandler {
  private static Set<Id>                      userIds = new Set<Id>();
  private static Set<Integer>                 years = new Set<Integer>();
  private static Set<Integer>                 months = new Set<Integer>();
  private static List<Opportunity>            oppsList = new List<Opportunity>();
  private static List<Sales_Target__c>        salesTargets;
  private static Map<String, Sales_Target__c> existSalesTargetsMap;
  private static List<Sales_Target__c>        newStList = new List<Sales_Target__c>();
  private static List<SalesTargetsByOpp>      stByOppList = new List<SalesTargetsByOpp>();

  public class SalesTargetsByOpp {
    public Opportunity opp;
    public Sales_Target__c st;

    public SalesTargetsByOpp(Opportunity opp, Sales_Target__c st){
      this.opp = opp;
      this.st = st;
    }

    public void assignSalesTarget(){
      this.opp.Target__c = this.st.Id;
    }
  }

  public static void assignSalesTarget(Map<Id, Opportunity> oppOldMap, List<Opportunity> newOpps) {
    for(Opportunity opp : newOpps) {
      if (oppOldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won') {
        userIds.add(opp.OwnerId);
        years.add(opp.CloseDate.year());
        months.add(opp.CloseDate.month());
        oppsList.add(opp);
      }
    }

    getSalesTargetsByOpportunities();
    generateSalesTargetsMap();
    createSalesTargetsByOpp();

    for(SalesTargetsByOpp stByOpp : stByOppList) {
      stByOpp.assignSalesTarget();
    }
  }

  private static void getSalesTargetsByOpportunities() {
    salesTargets = [
      SELECT
        Id,
        Sales_Person__c,
        Date__c
      FROM Sales_Target__c
      WHERE Sales_Person__c IN :userIds
        AND CALENDAR_YEAR(Date__c) IN :years
        AND CALENDAR_MONTH(Date__c) IN :months
      Order BY Sales_Person__c
    ];
  }

  private static void generateSalesTargetsMap() {
    existSalesTargetsMap = new Map<String, Sales_Target__c>();
    for(Sales_Target__c st : salesTargets){
      String key = st.Sales_Person__c + 'x' + 
        String.valueOf(st.Date__c.year()) + '-' + 
        String.valueOf(st.Date__c.month());
      // key: <SalesTarget Id>x<year>-<month>
      existSalesTargetsMap.put(key, st);
    }
  }

  private static void createSalesTargetsByOpp() {
    for(Opportunity opp : oppsList){
      String key = opp.OwnerId + 'x' + 
        String.valueOf(opp.CloseDate.year()) + '-' + 
        String.valueOf(opp.CloseDate.month());
      if (existSalesTargetsMap.containsKey(key)) {
        stByOppList.add(new SalesTargetsByOpp(
          opp, existSalesTargetsMap.get(key)
        ));
      } else {
        Sales_Target__c st = new Sales_Target__c(
          Sales_Person__c = opp.OwnerId,
          Target__c = null,
          Date__c = Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), 1)
        ); 
        stByOppList.add(new SalesTargetsByOpp(opp, st));
        newStList.add(st);
      }
    }
    Database.UpsertResult[] upsertResult = Database.upsert(newStList);
  }
}