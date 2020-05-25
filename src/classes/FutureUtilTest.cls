@isTest
private class FutureUtilTest {
    @isTest static void test1() {

        List<Location__c> locs = new List<Location__c>();
        locs.add(new Location__c(
            CC_Location_ID__c = '100'
        ));

        locs.add(new Location__c(
            CC_Location_ID__c = '101',
            CC_Location_Parent_ID__c = '100'
        ));
        insert locs;

        Set<Id> locIds = new Set<Id>();
        for(Location__c loc: locs)
            locIds.add(loc.Id);

        Test.startTest();
        FutureUtil.LocationParentUpdate(locIds);
        Test.stopTest();
    }
}