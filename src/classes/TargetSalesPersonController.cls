/**
 * Created by novab on 18.05.2020.
 */

public with sharing class TargetSalesPersonController {
    @AuraEnabled
    public static String targetList (){

        List<wrapperTarget> mutargetList = new List<wrapperTarget>();
        List<User> usersList = [SELECT Name FROM User WHERE Profile.Name = 'Sales Rep' LIMIT 1];
        for (User user : usersList){
            wrapperTarget target = new wrapperTarget();
            target.Sales_Person = user.Name;
            target.Target = 150000;
            target.Target_Date = Date.today();
            mutargetList.add(target);
            System.debug(target);
        }
        System.debug(mutargetList);
        return JSON.serialize(mutargetList);
    }

    public class wrapperTarget {
        public String Sales_Person;
        public Double Target;
        public Date Target_Date;
    }
}