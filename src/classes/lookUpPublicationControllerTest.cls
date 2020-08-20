@IsTest
private class lookUpPublicationControllerTest {
    @IsTest
    static void testLookUp() {
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

        List<sObject> excludeitemsList = new List<SObject>();
        excludeitemsList.add(pub1);
        String searchWord = 'test';
        String objName = 'Publication__c';
        lookUpPublicationController.fetchLookUpValues(searchWord,objName,excludeitemsList);
        System.assertEquals(1, excludeitemsList.size());
    }
}