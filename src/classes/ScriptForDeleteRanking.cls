
public with sharing class ScriptForDeleteRanking {

    public void delOrg() {
        List<Rankings__c> delRankingsOrg = new List<Rankings__c>();

        for (Rankings__c rank : [SELECT Id FROM Rankings__c WHERE RecordType.Name = 'Organization Ranking' AND LastModifiedDate < 2021-03-02T00:00:00.000+0000 LIMIT 10000]) {
            delRankingsOrg.add(rank);
        }
        if(delRankingsOrg.size() > 0){
            System.debug(delRankingsOrg.size());
            delete delRankingsOrg;
        }
    }

    public void delPerson() {
        List<Rankings__c> delRankingsPerson = new List<Rankings__c>();

        for (Rankings__c rank : [SELECT Id FROM Rankings__c WHERE RecordType.Name = 'Person Ranking' AND LastModifiedDate < 2021-03-02T00:00:00.000+0000 LIMIT 10000]) {
            delRankingsPerson.add(rank);
        }
        if(delRankingsPerson.size() > 0){
            System.debug(delRankingsPerson.size());
            delete delRankingsPerson;
        }
    }
}