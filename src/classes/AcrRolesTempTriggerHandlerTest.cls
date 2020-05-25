@isTest
public class AcrRolesTempTriggerHandlerTest {

	@isTest
	public static void populateRolesTest () {

		Account acct = new Account();
		acct.CC_Account_ID_RE__c = 'A1212';
		acct.Name = 'Test Account';
		insert acct;

		Contact con = new Contact();
		con.LastName = 'Test Contact';
		con.CC_Contact_ID__c = 'C5555';
		con.AccountId = acct.Id;
		insert con;

		List<Contact> cons = new List<Contact>();
        for(Integer i=0; i<100; i++){
            cons.add(new Contact(
                LastName = 'Test Contact'+i,
            	CC_Contact_ID__c = 'C5555'+i,
            	AccountId = acct.Id
            ));
        }
        insert cons;
        
        List<ACR_Roles_Temp__c> arts = new List<ACR_Roles_Temp__c>();
        for(Integer i=0; i<100; i++){
            String conId = 'C5555'+i;
            arts.add(new ACR_Roles_Temp__c(
                CC_Account_ID__c = 'A1212',
            	CC_Contact_ID__c = conId,
            	External_ID__c = 'A1212' + '_' + conId + '_' + 'Employee',
            	Roles__c = 'Employee'+i
            ));
        }

		Test.startTest();
		insert arts;
		Test.stopTest();

	}

}