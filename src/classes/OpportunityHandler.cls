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
    // key: userId, value: Map<date code, Sales_Target__c>
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




/*
  // Assigns Sales_Target__c to opportunity when opportunity 'closed Won'
  public static void assignSalesTarget(Map<Id, Opportunity> oppOldMap, List<Opportunity> newOpps) {
    Set<Id> userIds = new Set<Id>();
    Set<Integer> years = new Set<Integer>();
    Set<Integer> months = new Set<Integer>();

    for(Opportunity opp : newOpps) {
      if (oppOldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won') {
        userIds.add(opp.OwnerId);
        years.add(opp.CloseDate.year());
        months.add(opp.CloseDate.month());
      }
    }

    List<Sales_Target__c> salesTargets = getSalesTargetsByOpportunities(userIds, years, months);
    Map<String, Map<String, Sales_Target__c>> existSalesTargetsMap = generateSalesTargetsMap(salesTargets);
    Set<Integer> oppsIndexes = assignSalesTargetsToOpp(oppOldMap, newOpps, existSalesTargetsMap);

    Set<String> test2 = new Set<String>();
    // Assign new Sales_Target__c to Opportunity
    for(Integer i : oppsIndexes){
      String key = String.valueOf(newOpps[i].CloseDate.year()) + '-' + String.valueOf(newOpps[i].CloseDate.month());
      newOpps[i].Target__c = existSalesTargetsMap.get(newOpps[i].OwnerId).get(key).Id;
    }
  }
*/
  /**
   * Helper Methods fo opportunity trigger
   */
/*
  private static List<Sales_Target__c> getSalesTargetsByOpportunities(Set<Id> userIds, Set<Integer> years, Set<Integer> months) {
    return [
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

  private static Map<String, Map<String, Sales_Target__c>> generateSalesTargetsMap(List<Sales_Target__c> salesTargets) {
    // key: userId, value: Map<date code, Sales_Target__c>
    Map<String, Map<String, Sales_Target__c>> salesTargetsMap = new Map<String, Map<String, Sales_Target__c>>();
    for(Sales_Target__c st : salesTargets){
      String key = String.valueOf(st.Date__c.year()) + '-' + String.valueOf(st.Date__c.month());

      if(salesTargetsMap.containsKey(st.Sales_Person__c)) {
        // key: date code, value: Sales_Target__c
        Map<String, Sales_Target__c> stMap = salesTargetsMap.get(st.Sales_Person__c);
        stMap.put(key, st);
      } else {
        // key: date code, value: Sales_Target__c
        Map<String, Sales_Target__c> stMap = new Map<String, Sales_Target__c>();
        stMap.put(key, st);
        salesTargetsMap.put(st.Sales_Person__c, stMap);
      }
    }
    return salesTargetsMap;
  }
  
  // Assign Sales_Target__c to Opportunity
  private static Set<Integer> assignSalesTargetsToOpp(Map<Id, Opportunity> oppOldMap, List<Opportunity> newOpps, Map<String, Map<String, Sales_Target__c>> existSalesTargetsMap){
    List<Sales_Target__c> newSalesTargetsList = new List<Sales_Target__c>();
    Integer oppIndex = 0;
    Set<Integer> oppIndexes = new Set<Integer>();
    for(Opportunity opp : newOpps) {
      if (oppOldMap.get(opp.Id).StageName != opp.StageName && opp.StageName == 'Closed Won') {
        String key = String.valueOf(opp.CloseDate.year()) + '-' + String.valueOf(opp.CloseDate.month());
        if (existSalesTargetsMap.containsKey(opp.OwnerId) && 
            existSalesTargetsMap.get(opp.OwnerId).containsKey(key) &&
            existSalesTargetsMap.get(opp.OwnerId).get(key).Id != null
          ) {
            opp.Target__c = existSalesTargetsMap.get(opp.OwnerId).get(key).Id;
        } 
        else if (existSalesTargetsMap.containsKey(opp.OwnerId) && 
          existSalesTargetsMap.get(opp.OwnerId).containsKey(key) &&
          existSalesTargetsMap.get(opp.OwnerId).get(key).Id == null
          ) {
            oppIndexes.add(oppIndex);
        } 
        else if (existSalesTargetsMap.containsKey(opp.OwnerId) && 
          existSalesTargetsMap.get(opp.OwnerId).containsKey(key) == false
        ) {
          Sales_Target__c newSt = new Sales_Target__c(
            Sales_Person__c = opp.OwnerId,
            Target__c = null,
            Date__c = Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), 1)
          );

          Map<String, Sales_Target__c> stMap = existSalesTargetsMap.get(opp.OwnerId);
          stMap.put(key, newSt);
          newSalesTargetsList.add(newSt);
          oppIndexes.add(oppIndex);
        } 
        else if (existSalesTargetsMap.containsKey(opp.OwnerId) == false) {
          Sales_Target__c newSt = new Sales_Target__c(
            Sales_Person__c = opp.OwnerId,
            Target__c = null,
            Date__c = Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), 1)
          );
          Map<String, Sales_Target__c> stMap = new Map<String, Sales_Target__c>();
          stMap.put(key, newSt);
          existSalesTargetsMap.put(opp.OwnerId, stMap);
          newSalesTargetsList.add(newSt);
          oppIndexes.add(oppIndex);
        }
        oppIndex++;
      }
    }
    Database.SaveResult[] insertResult = Database.insert(newSalesTargetsList);
    return oppIndexes;
  }

*/

}