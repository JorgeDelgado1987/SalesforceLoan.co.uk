@RestResource(urlMapping='/sec/account')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   06/10/2014
//
/////////////////////////////////////////////////

global class SECAPIAccount {
	
	public static Account acc;
    public static list<string> lstErrors;
    public static list<string> lstResponse;

@HttpPost
global static AccountResponse doPost(String action, String accountID, Account account, List<Contact> contacts)  {

	AccountResponse response;
    String status = 'success';
    String errorStr = '';
    String successStr = '';
    ID newAccID;

    acc = account;
    lstErrors = new list<string>();
    if (string.isBlank(action)){
        lstErrors.add('action is required');
    }
    if (action != 'create' && action !='update' && !string.isBlank(action)){
        lstErrors.add('action can only be create or update');
    }
    if (action == 'update' && String.isBlank(accountID)){
        lstErrors.add('Must supply an AccountID for an update action');
    }
    if (action == 'create' && !String.isBlank(accountID)){
        lstErrors.add('Must not supply an AccountID for a create action');
    }

    checkAccountData();

    if(contacts != null){
        for (Contact c : contacts){
            checkContactData(c);
        }
    }


    //Data quality or Data Transformation returns 400 response - bad data.
    if(lstErrors.size() > 0){
        status = 'failure';
        for (String s : lstErrors){
            errorStr = errorStr + s + ' : ';
        }
    }

     // No error so process data received
    if ((action == 'create') && (lstErrors.size() == 0)){
        Savepoint sp = Database.setSavepoint(); 
        try{
            insert acc;
            system.debug('acc id = '+ acc.id);
        }
        catch(Exception ex){
            status = 'error';
            errorStr = ex.getMessage();
            Database.rollback(sp);
        }
        newAccID = account.id;

        if (contacts != null){
                for (Contact c : contacts){
                    c.AccountId = account.id;
                    c.password__c = Utility.generatePassword();
                    c.id = null;
                }
                insert contacts;
            }
    }

    if ((action == 'update') && (lstErrors.size() == 0)){
         Savepoint sp = Database.setSavepoint(); 
        try{
            Account.id = id.valueOf(accountID);
            update Account;

            if (contacts != null){
            	for (Contact c : contacts){
                    c.AccountId = account.id;
                    if (c.id == null){
                        c.password__c = Utility.generatePassword();
                    }
                }
                upsert contacts;
            }
        }
        catch(Exception ex){
            status = 'error';
            errorStr = ex.getMessage();
            Database.rollback(sp);
        }
    }
    Map<String,ID> contactids = new Map<String,ID>();
    if (contacts != null){
    	for (Contact c : contacts){
    		contactids.put(c.firstname + ' ' + c.lastname + ' username :' + c.username__c + ' password :' + c.password__c , c.id);
    	}
    }

    response = new AccountResponse(status, successStr, errorStr, newAccID, contactids);
	return response;
}

public static void checkAccountData(){
        system.debug('*** -- into check account data method -- ***');
        if (String.isBlank(acc.Name)) {
            lstErrors.add('Account Name is required');
        }
        if (String.isBlank(acc.Phone)) {
            lstErrors.add('Account Phone is required');
        }
        system.debug('*** -- end of check account data method -- ****');
}

public static void checkContactData(Contact thiscon){
        system.debug('*** -- into check contact data method -- ***');
        if (String.isBlank(thiscon.firstname)) {
            lstErrors.add('Contact First Name is required');
        }
        if (String.isBlank(thiscon.lastname)) {
            lstErrors.add('Contact Last Name is required');
        }
        if (String.isBlank(thiscon.Email)) {
            lstErrors.add('Contact Email address is required');
        }
        if (String.isBlank(thiscon.Username__c)){
            lstErrors.add('Contact username is required');
        }
        system.debug('*** -- end of check contact data method -- ****');
}





    global class AccountResponse {
        public String status;
        public String successMessage;
        public String errorMessage;
        public String accId;
        public Map<String,ID> contactids;
            global AccountResponse(String status, String successMessage, String errorMessage, String accId, Map<String,ID> contactids) {
                this.status = status;
                this.successMessage = successMessage;
                this.errorMessage = errorMessage;
                this.accId = accId;
                this.contactids = contactids;
            }
    }
}