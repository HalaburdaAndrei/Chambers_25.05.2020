/**
 * It's a clacc which works with 'PersonSalesTargets' LWC
 */
public with sharing class PersonSalesTargets_CTRL {
  private final static Integer startFyMonth = 7; // TODO: Probably need to make it as custom settings
  private final static Integer cuntMonths = 12; // TODO: Probably need to make it as custom settings
  private final static String userProfileName = 'Sales Rep'; // TODO: Probably need to make it as custom settings
  
  /**
   * Method retrive Users with related Sales_Target__c objects
   * and generate Map
   */
  @AuraEnabled
  public static Map<String, Object> getUserSalesTargets(Integer selectedYear){
    return generateUserMap(
      getUsersWithSalesTargets(selectedYear)
    );
  }

  // Generate list of date for dataTable component
  @AuraEnabled
  public static List<Date> generateDates(Integer selectedYear){
    List<Date> datesRange = new List<date>();
    Date startdate = Date.newInstance(selectedYear, startFyMonth, 1);
    datesRange.add(startdate);
    for(Integer i = startFyMonth; i < startFyMonth + cuntMonths - 1; i++) {
      datesRange.add(datesRange[datesRange.size() - 1].addMonths(1));
    }
    return datesRange;
  }

  @AuraEnabled
  public static void upsertSalesTargets(List<Sales_Target__c> salesTargets){
    Schema.DescribeFieldResult F = Sales_Target__c.Id.getDescribe();
    Schema.sObjectField T = F.getSObjectField();

    Database.UpsertResult[] upsertResult = Database.upsert(salesTargets, T, true);
  }


  /**
   * Helper methods
   */
  // get users with sales targets
  private static List<User> getUsersWithSalesTargets(Integer selectedYear){
    return [
      SELECT 
        Id,
        Name,
        (
          SELECT 
            Sales_Person__c,
            Date__c,  
            Target__c
          FROM Sales_Targets__r
          WHERE Date__c >= :Date.newInstance(selectedYear, startFyMonth, 1) 
            AND Date__c <= :Date.newInstance(selectedYear, startFyMonth + cuntMonths - 1, 1) 
          ORDER BY Date__c
        )
      FROM User
      WHERE Profile.Name = :userProfileName
      ORDER BY Name
    ];
  }

  // Generate Map for frontEnd
  private static Map<String, Object> generateUserMap(List<User> users){
    Map<String, Object> usersMap = new Map<String, Object>();
    for (User u : users) {
      Map<String, Object> salesTargetsMap = new Map<String, Object>();
      for(Sales_Target__c st : u.Sales_Targets__r){
        salesTargetsMap.put(
          String.valueOf(
            Date.newInstance(
              st.Date__c.year(), 
              st.Date__c.month(), 
              1
            )
          ), 
        st);
      }
      salesTargetsMap.put('userName', u.Name);
      usersMap.put(u.Id, salesTargetsMap);
    }
    return usersMap;
  }


  

  /**
   * Helpers for developing
   */
  public static void generateData(){
    List<User> users = [
      SELECT 
        Id, 
        Name
      FROM User
      WHERE Profile.Name = 'Sales Rep'
    ];
    List<Sales_Target__c> salesTargets = new List<Sales_Target__c>();
    List<Date> dates = generateDates(2020);
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
  }
}