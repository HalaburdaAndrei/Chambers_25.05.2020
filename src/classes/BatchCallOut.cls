/**
 * Created by novab on 31.05.2020.
 */

global class BatchCallOut implements Database.Batchable<APXTConga4__Conga_Template__c>, Database.AllowsCallouts{

    List<APXTConga4__Conga_Template__c> listTemplates = [SELECT Id FROM APXTConga4__Conga_Template__c WHERE Id =: 'a0K1t000005SDcr' ];

    global Iterable<APXTConga4__Conga_Template__c> start(database.batchablecontext BC){
        return (listTemplates);
    }

    global void execute(Database.BatchableContext BC, List<APXTConga4__Conga_Template__c> scope){

        String serverURL = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/u/46.0/' + UserInfo.getOrganizationId();
        String templateCover = '&TemplateId=a0K1t000005SDcr';
//        String templateFooter = '&TemplateId=0693X0000084fPZQAY';
        String mainParams = 'https://composer.congamerge.com/composer8/index.html'+
                '?sessionId='+ UserInfo.getSessionId() +
                '&serverUrl='+ EncodingUtil.urlEncode(serverURL, 'UTF-8') +
                '&id=0061l00000JmP6gAAF';
        String endParams = '&SC0=1&SC1=SalesforceFile&FP0=1&DefaultPDF=1&APIMode=1';

        String finalURL = mainParams + templateCover + endParams;

        Http httpFinal = new Http();
        HttpRequest requestFinal = new HttpRequest();
        requestFinal.setEndpoint(finalURL);
        requestFinal.setMethod('GET');
        requestFinal.setTimeout(120000);

        HttpResponse responseFinal = httpFinal.send(requestFinal);

        System.debug(responseFinal.getBody());
        System.debug(responseFinal);
        System.debug(finalURL);
        System.debug(UserInfo.getSessionId());

                }//execute loop
                global void finish(Database.BatchableContext info){
                        }//global void finish loop
                        }//global class loop