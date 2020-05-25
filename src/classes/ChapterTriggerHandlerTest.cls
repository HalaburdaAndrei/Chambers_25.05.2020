@isTest
public class ChapterTriggerHandlerTest {
    
    @isTest
    public static void TestPopulatePublication() {

		Publication__c pub = new Publication__c();
        pub.CC_Publication_ID_RE__c = 'P7878';
        pub.Year_Issue_RE__c = '2019';
        insert pub;
        
        Chapter__c ch = new Chapter__c();
        ch.CC_Publication_ID__c = 'P7878';

		Test.startTest();
        insert ch;
		Test.stopTest();

		ch = [SELECT Publication__c FROM Chapter__c WHERE Id = :ch.Id];
		System.assertEquals(pub.Id, ch.Publication__c);
    }

    @isTest
    public static void TestPopulateLocation(){

    	Location__c loc = new Location__c();
    	loc.CC_Location_ID__c = 'L2222';
    	insert loc;

    	Chapter__c ch = new Chapter__c();
    	ch.CC_Location_ID__c = 'L2222';

    	Test.startTest();
    	insert ch;
    	Test.stopTest();

    	ch = [SELECT Location__c FROM Chapter__c WHERE Id = :ch.Id];
    	System.assertEquals(loc.Id, ch.Location__c);
    }
    
}