@isTest
private class PublicationTargetControllerTest {

    @testSetup
    static void setup() {
        Publication__c pub1 = new Publication__c(
                Name = 'testPublicationAsia',
                Publication_Type__c = 'Asia',
                CC_Publication_ID_RE__c = '1234',
                Year_Issue_RE__c = '2019',
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 5000
        );
        insert  pub1;

        Publication__c pub2 = new Publication__c(
                Name = 'testPublicationGuiede',
                Publication_Type__c = 'UK Guide',
                CC_Publication_ID_RE__c = '12234',
                Year_Issue_RE__c = '2020',
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 15000
        );
        insert  pub2;

    }

    @IsTest
    static void publicationTest (){

        List<Publication__c> listPub = [SELECT Id, Name FROM Publication__c];

        test.startTest();
        PublicationTargetController.getPublications(listPub);
        System.assertEquals(2, PublicationTargetController.getPublications(listPub).size());
        PublicationTargetController.getPublications(null);
        System.assertEquals(2, PublicationTargetController.getPublications(listPub).size());
        test.stopTest();


    }

    @IsTest
    static void updatePublicationTest (){

        List<Publication__c> listPub = [SELECT Id, Name, Directory_Allocated_Target__c FROM Publication__c];

        test.startTest();
        listPub[0].Directory_Allocated_Target__c = 7000;
        listPub[1].Directory_Allocated_Target__c = 17000;

        PublicationTargetController.saveTarget(listPub);
        System.assertEquals(2, PublicationTargetController.getPublications(listPub).size());

        test.stopTest();


    }


}