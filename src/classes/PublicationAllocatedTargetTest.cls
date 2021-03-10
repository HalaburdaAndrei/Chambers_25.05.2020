@IsTest
private class PublicationAllocatedTargetTest {

    @testSetup
    static void setup() {

        Product2 product1 = new Product2(
                Name = 'test1',
                Product_Category__c = 'PFO',
                IsActive = true);
        insert product1;

        Product2 product2 = new Product2(
                Name = 'test1',
                Product_Category__c = 'Individual Profile',
                IsActive = true);
        insert product2;
        Product2 product3 = new Product2(
                Name = 'test1',
                Product_Category__c = 'T&D',
                IsActive = true);
        insert product3;
        Product2 product4 = new Product2(
                Name = 'test1',
                Product_Category__c = 'Q&A',
                IsActive = true);
        insert product4;
        Product2 product5 = new Product2(
                Name = 'test1',
                Product_Category__c = 'Firm Profile',
                IsActive = true);
        insert product5;

        Publication__c pub1 = new Publication__c(
                Name = 'testPublicationAsia',
                Publication_Type__c = 'Asia',
                CC_PublicationTypeCategory__c = 'Ranking Guides',
                CC_Publication_ID_RE__c = '1234',
                Year_Issue_RE__c = '2020'
        );
        insert  pub1;

        Publication__c pub2 = new Publication__c(
                Name = 'testPublicationGuiede',
                Publication_Type__c = 'Alternative Energy & Power 2020',
                CC_PublicationTypeCategory__c = 'Practice Guides',
                CC_Publication_ID_RE__c = '12234',
                Year_Issue_RE__c = '2020'
        );
        insert  pub2;

        Publication_Target__c publicationTarget = new Publication_Target__c(
                Publication__c = pub2.Id,
                Product_Category__c = 'PFO',
                Category_Visible__c = true,
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 10000
        );
        insert publicationTarget;
        Publication_Target__c publicationTarget1 = new Publication_Target__c(
                Publication__c = pub2.Id,
                Product_Category__c = 'Firm Profile',
                Category_Visible__c = true,
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 10000
        );
        insert publicationTarget1;
        Publication_Target__c publicationTarget2 = new Publication_Target__c(
                Publication__c = pub1.Id,
                Product_Category__c = 'T&D',
                Category_Visible__c = true,
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 10000
        );
        insert publicationTarget2;
        Publication_Target__c publicationTarget3 = new Publication_Target__c(
                Publication__c = pub1.Id,
                Product_Category__c = 'Q&A',
                Category_Visible__c = true,
                Directory_Allocated_Target__c = 13000,
                Insights_Allocated_Target__c = 10000
        );
        insert publicationTarget3;
    }
    @IsTest
    static void getPicklistProductCategoryTest() {
        PublicationAllocatedTarget.getPicklistProductCategory();
        System.assertEquals(5, PublicationAllocatedTarget.getPicklistProductCategory().size());
    }

    @IsTest
    static void getPicklistPublucationCategoryTest() {
        PublicationAllocatedTarget.getPicklistPublucationCategory();
        System.assertEquals(3, PublicationAllocatedTarget.getPicklistPublucationCategory().size());
    }

    @IsTest
    static void generateDataTableTest() {
        PublicationAllocatedTarget.generateDataTable('2020');
        System.assertEquals(2, PublicationAllocatedTarget.generateDataTable('2020').get('table').size());

    }

    @IsTest
    static void addPublicationApexTest() {
        String jsonOld = '[{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDbzAAH","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"Q&A","Category_Visible__c":false,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDc0AAH","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000IKybaAAD","publicationInsightsAllocatedTarget":0,"publicationName":"Alternative Energy & Power 2020"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf5AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf6AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000HcSFQAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Energy: Oil & Gas 2019 v2"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf7AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf8AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":18000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":18000,"publicationId":"a021t00000HcSFYAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Merger Control 2019"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf9AAH","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":1500,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDfAAAX","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":35000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":36500,"publicationId":"a021t00000GpzvoAAB","publicationInsightsAllocatedTarget":0,"publicationName":"Zebra Book 2020"}]';

        PublicationAllocatedTarget.addPublicationApex('Practice Guides', '2020', jsonOld);
        System.assertEquals(6, [SELECT Id FROM Publication_Target__c].size());

    }

    @IsTest
    static void addProductcategoryApexTest() {
        String jsonOld = '[{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDbzAAH","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"Q&A","Category_Visible__c":false,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDc0AAH","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000IKybaAAD","publicationInsightsAllocatedTarget":0,"publicationName":"Alternative Energy & Power 2020"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf5AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf6AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000HcSFQAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Energy: Oil & Gas 2019 v2"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf7AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf8AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":18000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":18000,"publicationId":"a021t00000HcSFYAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Merger Control 2019"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf9AAH","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":1500,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDfAAAX","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":35000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":36500,"publicationId":"a021t00000GpzvoAAB","publicationInsightsAllocatedTarget":0,"publicationName":"Zebra Book 2020"}]';

        List<String> prodCategorys = new List<String>{'Q&A', 'T&D', 'Firm Profile', 'Unpublished Report'};
        System.assertEquals(4, prodCategorys.size());
        PublicationAllocatedTarget.addProductcategoryApex(jsonOld, prodCategorys);
        System.assertEquals(20, [SELECT Id FROM Publication_Target__c].size());

    }

    @IsTest
    static void savePublicationTargetTest() {
        List<Publication_Target__c> pt = [SELECT Id FROM Publication_Target__c];
        String jsonOld = '[{"expanded":false,"productCategaryRows":[{"productCategoryName":"T&D","publicationTargets":[{"Id":"'+pt[1].Id+'","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"T&D","Category_Visible__c":false,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000IKybaAAD","publicationInsightsAllocatedTarget":0,"publicationName":"Alternative Energy & Power 2020"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"'+pt[2].Id+'","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":1500,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"'+pt[3].Id+'","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":35000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":36500,"publicationId":"a021t00000GpzvoAAB","publicationInsightsAllocatedTarget":0,"publicationName":"Zebra Book 2020"}]';
        PublicationAllocatedTarget.savePublicationTarget( jsonOld);
        System.assertEquals(4, [SELECT Id FROM Publication_Target__c].size());
    }

    @IsTest
    static void deletePublicationTest() {
        List<Publication_Target__c> pt = [SELECT Id FROM Publication_Target__c];

        String jsonOld = '[{"expanded":false,"productCategaryRows":[{"productCategoryName":"T&D","publicationTargets":[{"Id":"'+pt[0].Id+'","Publication__c":"a021t00000IKybaAAD","Product_Category__c":"T&D","Category_Visible__c":false,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Alternative Energy & Power 2020","Id":"a021t00000IKybaAAD"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000IKybaAAD","publicationInsightsAllocatedTarget":0,"publicationName":"Alternative Energy & Power 2020"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf5AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf6AAH","Publication__c":"a021t00000HcSFQAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Energy: Oil & Gas 2019 v2","Id":"a021t00000HcSFQAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":0,"publicationId":"a021t00000HcSFQAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Energy: Oil & Gas 2019 v2"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"a111l00000AEDf7AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":0,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDf8AAH","Publication__c":"a021t00000HcSFYAA3","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":18000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Merger Control 2019","Id":"a021t00000HcSFYAA3"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":18000,"publicationId":"a021t00000HcSFYAA3","publicationInsightsAllocatedTarget":0,"publicationName":"Merger Control 2019"},{"expanded":false,"productCategaryRows":[{"productCategoryName":"Q&A","publicationTargets":[{"Id":"'+pt[0].Id+'","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"Q&A","Category_Visible__c":true,"Directory_Allocated_Target__c":1500,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]},{"productCategoryName":"T&D","publicationTargets":[{"Id":"a111l00000AEDfAAAX","Publication__c":"a021t00000GpzvoAAB","Product_Category__c":"T&D","Category_Visible__c":true,"Directory_Allocated_Target__c":35000,"Insights_Allocated_Target__c":0,"Publication__r":{"Name":"Zebra Book 2020","Id":"a021t00000GpzvoAAB"}}]}],"publicationAllocatedTarget":0,"publicationDirectoryAllocatedTarget":36500,"publicationId":"a021t00000GpzvoAAB","publicationInsightsAllocatedTarget":0,"publicationName":"Zebra Book 2020"}]';

        PublicationAllocatedTarget.deletePublication( jsonOld);
        System.assertEquals(0, [SELECT Id FROM Publication_Target__c WHERE Category_Visible__c = false].size());
    }

}