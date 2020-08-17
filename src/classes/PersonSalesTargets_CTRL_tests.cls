@IsTest
public with sharing class PersonSalesTargets_CTRL_tests {
  @IsTest
  static void getUserSalesTargets_test(){
    createSalesTargets();
    Map<String, Object> usersWithST = PersonSalesTargets_CTRL.getUserSalesTargets(2020);
    System.debug('--->>> ' + usersWithST);
    for(String userId : usersWithST.keySet()){
      Map<String, Object> salestargets = 
        (Map<String, Object>)usersWithST.get(userId);
      System.assertEquals(13, salestargets.keySet().size());
    }
  }
  @IsTest
  static void upsertSalesTargets_test(){
    List<Sales_Target__c> salesTargets = createSalesTargets();
    for (Sales_Target__c target : salesTargets) {
      target.Target__c = 0;
    }
    PersonSalesTargets_CTRL.upsertSalesTargets(salesTargets);
    for (Sales_Target__c target : salesTargets) {
      System.assertEquals(0, target.Target__c);
    }
  }

  @IsTest
  static void generateDates_test(){
    List<date> dates = PersonSalesTargets_CTRL.generateDates(2020);
    System.assertEquals(dates[0], date.newInstance(2020, 07, 01));   
    System.assertEquals(dates[dates.size() -1 ], date.newInstance(2021, 06, 01));   
  }

/**
 * Helper methods
 */
  static List<Sales_Target__c> createSalesTargets() {
    List<User> users = [
      SELECT 
        Id, 
        Name
      FROM User
      WHERE Profile.Name = 'Sales Rep'
    ];
    List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
    List<Date> dates = new List<Date>();
    dates.add(
      Date.newInstance(2020, 07,01)
    );
    for(Integer i = 7; i < 7 + 11; i++) {
      System.debug('---Dates ' + dates[dates.size() - 1].addMonths(1));
      dates.add(dates[dates.size() - 1].addMonths(1));
    }
    
    for(User u : users) {
      for (Date d : dates) {
        salesTargets.add(new Sales_Target__c(
          Sales_Person__c = u.Id,
          Target__c = Integer.valueof((Math.random() * 10000)),
          Date__c = d
        ));
      }
    }
    insert salesTargets;
    return salesTargets;
  }
}