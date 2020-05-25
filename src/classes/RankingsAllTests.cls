@isTest
public class RankingsAllTests {
    
	@isTest
	public static void TestPopulatePublication(){
		
		// Data setup
		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;
        
        Rankings__c r = new Rankings__c();
        r.CC_Publication_ID_RE__c = 'Test938473';
		
		// Run the code
		Test.startTest();
		insert r;
		Test.stopTest();
		
		// Verify Results
		r = [SELECT Publication_RE__c FROM Rankings__c WHERE Id = :r.Id];
        System.assertEquals(p.Id, r.Publication_RE__c, 'The trigger should set the publication reference based on external id');
	}

	@isTest
	public static void TestPopulateAccount() {

		Account acct = new Account();
		acct.Name = 'Test Account';
		acct.CC_Account_ID_RE__c = 'A4321';
		insert acct;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;		

		Rankings__c r = new Rankings__c();
        r.CC_Organization_ID__c = 'A4321';
        r.CC_Publication_ID_RE__c = 'Test938473';

        Test.startTest();
        insert r;
        Test.stopTest();
	}	
    
	@isTest
	public static void TestPopulateParentAccount() {

		Account acct = new Account();
		acct.Name = 'Test Account';
		acct.CC_Account_ID_RE__c = 'A4321';
		insert acct;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;		

		Rankings__c r = new Rankings__c();
        r.CC_Organization_Parent_ID__c = 'A4321';
        r.CC_Publication_ID_RE__c = 'Test938473';

        Test.startTest();
        insert r;
        Test.stopTest();
	}

	@isTest
	public static void TestPopulateContact() {

		Contact c = new Contact();
		c.LastName = 'Contact';
		c.FirstName = 'Test';
		c.CC_Contact_ID__c = 'C8888';
		insert c;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;		

		Rankings__c r = new Rankings__c();
        r.CC_Person_Organization_ID_RE__c = 'C8888';
        r.CC_Publication_ID_RE__c = 'Test938473';

        Test.startTest();
        insert r;
        Test.stopTest();
	}
    
    @isTest
    public static void TestPopulateLocation() {
        
        Location__c loc = new Location__c();
        loc.CC_Location_ID__c = 'loc55555';
        insert loc;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;
        
        Rankings__c r = new Rankings__c();
        r.Location_ID__c = 'loc55555';
        r.CC_Publication_ID_RE__c = 'Test938473';
        
        Test.startTest();
        insert r;
        Test.stopTest();
    }

    @isTest
	public static void TestSoftDeleted(){
		
		// Data setup
		Publication__c pub = new Publication__c();
		pub.Year_Issue_RE__c = '2019';
        insert pub;
            
        Rankings__c r = new Rankings__c();
        r.Publication_RE__c = pub.Id;
		r.CC_To_Be_Deleted__c = false;
        insert r;
		
		// Run the code
		Test.startTest();
		r.CC_To_Be_Deleted__c = true;
        update r;
		Test.stopTest();
		
		// Verify Results
        System.assertEquals(0, [SELECT COUNT() FROM Rankings__c], 'The ranking should now be deleted');
	}
    
}