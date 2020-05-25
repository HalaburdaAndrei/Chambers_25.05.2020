@isTest
public class ContactTriggerHandlerTest {

	@isTest
	public static void TestAssociateAccount() {

		Account a = new Account();
		a.Name = 'Test Account';
		a.CC_Account_ID_RE__c = 'A9999';
		insert a;

		Contact c = new Contact();
		c.LastName = 'TestLastName';
		c.CC_Account_ID__c = 'A9999';

		Test.startTest();
		insert c;
		Test.stopTest();

		c = [SELECT AccountId FROM Contact WHERE Id = :c.Id];
		System.assertEquals(a.Id, c.AccountId);
	}

	@isTest
	public static void TestDeleteReparent() {

		List<Contact> cons = new List<Contact>();
		cons.add(new Contact(
			LastName = 'TestLastName',
			CC_Contact_ID__c = 'A9999'
		));
		cons.add(new Contact(
			LastName = 'TestLastName2',
			CC_Contact_ID__c = 'A1111'
		));
		insert cons;

		Location__c pLoc = new Location__c(
			CC_Location_ID__c = 'Loc90210',
			Contact__c = cons[0].Id
		);
		insert pLoc;

		Location__c pLoc2 = new Location__c(
			CC_Location_ID__c = 'Loc90211',
			Contact__c = cons[0].Id
		);
		insert pLoc2;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;

        Rankings__c r = new Rankings__c(
        	CC_Publication_ID_RE__c = 'Test938473',
			Publication_RE__c = p.Id,
			Person_RE__c = cons[0].Id
		);
		insert r;

		cons[0].CC_To_Be_Deleted__c = true;
		cons[0].CC_New_Contact_ID__c = 'A1111';
		
		Test.startTest();
		update cons[0];
		Test.stopTest();

		Contact c = [SELECT Id, (SELECT Id FROM Locations__r), (SELECT Id FROM Rankings__r) FROM Contact WHERE Id = :cons[1].Id LIMIT 1];
		System.debug('New Contact ---------->'+c);
		System.debug('New Contact ---------->'+c.Locations__r);
		System.debug('New Contact ---------->'+c.Rankings__r);
		System.assert(!c.Locations__r.isEmpty());
		System.assert(!c.Rankings__r.isEmpty());

		List<Contact> delAcc = [SELECT Id FROM Contact WHERE Id = :cons[0].Id LIMIT 1];
		System.debug('Deleted Account ---------->'+delAcc);
		System.assert(delAcc.isEmpty());
	}

}