@isTest
public class AccountTriggerHandlerTest {

	@isTest
	public static void TestParentAccount() {

		Account pa = new Account();
		pa.Name = 'Parent Test Account';
		pa.CC_Parent_Account_ID_RE__c = 'A9999';
		pa.CC_Account_ID_RE__c = 'A9999';
		insert pa;

		Account a = new Account();
		a.Name = 'Test Account';
		a.CC_Parent_Account_ID_RE__c = 'A9999';
		a.CC_Account_ID_RE__c = 'A7777';

		Test.startTest();
		insert a;
		Test.stopTest();

		a = [SELECT ParentId FROM Account WHERE Id = :a.Id];
		System.assertEquals(pa.Id, a.ParentId);
	}

	@isTest
	public static void TestDeleteReparent() {

		List<Account> cons = new List<Account>();
		cons.add(new Account(
			Name = 'First Account',
			CC_Account_ID_RE__c = 'A9999'
		));
		cons.add(new Account(
			Name = 'Second Account',
			CC_Account_ID_RE__c = 'A1111'
		));
		insert cons;

		Contact con1 = new Contact(
            AccountId = cons[0].Id,
            FirstName = 'Test',
            LastName = 'Contact1',
            Email = 'email@test.com'
        );
        insert con1;

		// AccountContactRelation acr = new AccountContactRelation(
		// 	AccountId = cons[0].Id,
		// 	ContactId = con1.Id
		// );
		// insert acr;

		Location__c pLoc = new Location__c(
			CC_Location_ID__c = 'Loc90210',
			Account__c = cons[0].Id
		);
		insert pLoc;

		Publication__c p = new Publication__c();
        p.CC_Publication_ID_RE__c = 'Test938473';
        p.Year_Issue_RE__c = '2019';
        insert p;

        Rankings__c r = new Rankings__c(
        	CC_Publication_ID_RE__c = 'Test938473',
			Publication_RE__c = p.Id,
			Account_RE__c = cons[0].Id
		);
		insert r;

		cons[0].CC_To_Be_Deleted__c = true;
		cons[0].CC_New_Account_ID__c = 'A1111';

		Test.startTest();
		update cons[0];
		Test.stopTest();

		Account c = [SELECT Id, (SELECT Id FROM Locations__r), (SELECT Id FROM Rankings__r) FROM Account WHERE Id = :cons[1].Id LIMIT 1];
		System.debug('Account ---------->'+c);
		System.debug('Locations ---------->'+c.Locations__r);
		System.debug('Rankings ---------->'+c.Rankings__r);
		System.debug('Opportunities ---------->'+c.Opportunities);
		System.assert(!c.Locations__r.isEmpty());
		System.assert(!c.Rankings__r.isEmpty());

		List<Account> delAcc = [SELECT Id FROM Account WHERE Id = :cons[0].Id LIMIT 1];
		System.debug('Deleted Account ---------->'+delAcc);
		System.assert(delAcc.isEmpty());
	}
    
}