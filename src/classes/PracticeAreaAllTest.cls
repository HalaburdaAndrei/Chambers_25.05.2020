@isTest
public class PracticeAreaAllTest {

    @isTest
    public static void TestPopulateParentPracticeArea(){
		
		// Data setup
		Practice_Area__c paParent = new Practice_Area__c();
        paParent.CC_Practice_Area_Id__c = 'Test293862';
        insert paParent;
        
        Practice_Area__c paChild = new Practice_Area__c();
        paChild.CC_Parent_Practice_Area_Id__c = 'Test293862';
		
		// Run the code
		Test.startTest();
		insert paChild;
		Test.stopTest();
		
		// Verify Results
		paChild = [SELECT Parent_Practice_Area__c FROM Practice_Area__c WHERE Id = :paChild.Id];
        System.assertEquals(paParent.Id, paChild.Parent_Practice_Area__c, 'The trigger sets the Parent_Practice_Area__c based on CC_Parent_Practice_Area_Id__c');
	}

}