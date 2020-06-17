
public with sharing class RankingDataController {

    @AuraEnabled
    public static List <Account> getAccounts() {

        return [ SELECT Id, Name FROM Account WHERE ParentId = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cHAAT' OR Id = '0011l00000UM1cHAAT'];
    }
}