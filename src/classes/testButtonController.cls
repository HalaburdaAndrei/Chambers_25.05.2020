/**
 * Created by novab on 15.05.2020.
 */

public with sharing class testButtonController {

    @AuraEnabled
    public static List<APXTConga4__Conga_Template__c> templates(){
        List<APXTConga4__Conga_Template__c> listTemplates = [SELECT APXTConga4__Name__c FROM APXTConga4__Conga_Template__c];
        return listTemplates;
    }
}