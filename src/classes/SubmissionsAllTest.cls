@isTest
public class SubmissionsAllTest {

    @isTest
	public static void TestSoftDeleted(){
		
		// Data setup
		Publication__c pub = new Publication__c();
		pub.Year_Issue_RE__c = '2019';
        insert pub;
            
        Submissions__c sub = new Submissions__c();
        sub.Publication__c = pub.Id;
		sub.CC_Active_RE__c = true;
        insert sub;
		
		// Run the code
		Test.startTest();
		sub.CC_Active_RE__c = false;
        update sub;
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(0, [SELECT COUNT() FROM Submissions__c], 'The Submission should now be deleted');
	}

    @isTest
	public static void TestPopulatePublication(){
		
		// Data setup
		Publication__c pub = new Publication__c();
        pub.CC_Publication_ID_RE__c = 'T8728';
        pub.Year_Issue_RE__c = '2019';
        insert pub;
            
        Submissions__c sub = new Submissions__c();
        sub.Publication_ID__c = 'T8728';
		sub.CC_Active_RE__c = true;
		
		// Run the code
		Test.startTest();
        insert sub;
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(pub.Id, [SELECT Publication__c FROM Submissions__c WHERE Id = :sub.Id].Publication__c, 'The trigger should have set the Publication__c by Publication_ID__c');
	}

	@isTest
	public static void TestPopulateAccount() {

		Account acct = new Account();
		acct.Name = 'Test Account';
		acct.CC_Account_ID_RE__c = 'A4321';
		insert acct;

		Publication__c pub = new Publication__c();
        pub.CC_Publication_ID_RE__c = '1234';
        pub.Year_Issue_RE__c = '2019';
        insert pub;

        Submissions__c sub = new Submissions__c();
        sub.Publication_ID__c = '1234';
        sub.Organization_ID__c = 'A4321';

        Test.startTest();
        insert sub;
        Test.stopTest();

        // need to correct assert line
        //
	}

	@isTest
	public static void TestPopulateParentAccount() {

		Account acct = new Account();
		acct.Name = 'Test Account';
		acct.CC_Account_ID_RE__c = 'A4321';
		insert acct;

		Publication__c pub = new Publication__c();
        pub.CC_Publication_ID_RE__c = '1234';
        pub.Year_Issue_RE__c = '2019';
        insert pub;

        Submissions__c sub = new Submissions__c();
        sub.Publication_ID__c = '1234';
        sub.Organization_Parent_ID__c = 'A4321';

        Test.startTest();
        insert sub;
        Test.stopTest();

        // need to correct assert line
        //
	}
    
}