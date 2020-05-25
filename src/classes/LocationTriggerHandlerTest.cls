@isTest
public class LocationTriggerHandlerTest {

	@isTest
	public static void TestPopulateParentLocation(){

		Location__c pLoc = new Location__c();
		pLoc.CC_Location_ID__c = 'Loc90210';
		insert pLoc;

		Location__c loc = new Location__c();
		loc.CC_Location_Parent_ID__c = 'Loc90210';

		Test.startTest();
		insert loc;
		Test.stopTest();

		loc = [SELECT Parent_Location__c FROM Location__c WHERE Id = :loc.Id];
		System.assertEquals(pLoc.Id, loc.Parent_Location__c);
	}    

}