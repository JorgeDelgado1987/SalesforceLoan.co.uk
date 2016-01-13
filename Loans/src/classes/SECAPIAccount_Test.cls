@isTest

// 07/10/2014 - Simon Parker
private class SECAPIAccount_Test {
	
	@isTest static void test_create() {
		
		String action = '';
		String accountID = '';

		Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

		List<Contact> contacts = new List<Contact>();



		SECAPIAccount.AccountResponse myResp = SECAPIAccount.doPost(action,accountID,account,contacts);
        system.assertEquals(myResp.errorMessage,'action is required : ');

        myResp = SECAPIAccount.doPost('ggg','',account,contacts);
        system.assertEquals(myResp.errorMessage,'action can only be create or update : ');

        myResp = SECAPIAccount.doPost('create',account.id,account,contacts);
        system.assertEquals(myResp.errorMessage,'Must not supply an AccountID for a create action : ');

        myResp = SECAPIAccount.doPost('update','',account,contacts);
        system.assertEquals(myResp.errorMessage,'Must supply an AccountID for an update action : ');
	
		Account account2 = new Account();
		myResp = SECAPIAccount.doPost('create','',account2,contacts);
		account2.Name = 'Second';
		myResp = SECAPIAccount.doPost('create','',account2,contacts);
		account2.Phone = '123456788';
        
		myResp = SECAPIAccount.doPost('create','',account2,contacts);

		string newAccountID = myResp.accId;

		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);

		Contact c1 = new Contact();
		contacts.add(c1);
		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);
		c1.firstname = 'One';
		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);
		c1.lastname = 'Contact';
		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);
		c1.email = 'one@contact.com';
		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);

		myResp = SECAPIAccount.doPost('create','',account2,contacts);
		newAccountID = 'a0O0000oo900';
		myResp = SECAPIAccount.doPost('update',newAccountID,account2,contacts);

	}
	
	
	
}