public with sharing class AccountCalloutCont {
    public Account Account {get; private set;}
    public Account_Notes__c CallOutcomeHolder {get; private set;}
    public Boolean IsAccessSecured {get; private set;}
    public Integer TimesIQueriedTheSameAcc {get; private set;}
    public String AdditionalNoteDetail {get; set;}
    private Id LatestAccId;

    public AccountCalloutCont(){
        CallOutcomeHolder = new Account_Notes__c();
        getNextAccount();
    }

    private void getNextAccount(){
        List<Account> accs = [SELECT Name, CreatedDate, Locked_Date__c, Locked_to__c, Status__c, Network__c, Business_Type__c,
            AccountSource, Phone, Fax, Website, OwnerId, Owner.Name, Company_Registration_Number__c, FCA_Number__c, BillingStreet, BillingCity, BillingPostalCode,
           (SELECT Name, MobilePhone, HomePhone, Email FROM Contacts),
           (SELECT CreatedById, CreatedDate, Note__c, Note_Category__c, Call_Outcome__c FROM Account_Notes__r ORDER BY CreatedDate DESC)
            FROM Account
            WHERE Status__c = 'Prospect'
            AND (Locked_Date__c < :System.now().addMinutes(-30) OR Locked_Date__c = null OR Locked_to__c = :UserInfo.getUserId())
            ORDER BY Last_Contact_Attempt_Date__c ASC,
                     CreatedDate DESC LIMIT 1];
        Account = accs.isEmpty() ? null : accs.get(0);
        updateTimesIQueriedTheSameAccCounter(Account);
    }

    private void updateTimesIQueriedTheSameAccCounter(Account acc){
        Id current_acc_id = acc == null ? null : acc.Id;
        if(TimesIQueriedTheSameAcc == null || LatestAccId != current_acc_id){
            TimesIQueriedTheSameAcc = 1;
        }else{
            TimesIQueriedTheSameAcc++;
        }
        LatestAccId = current_acc_id;
        IsAccessSecured = TimesIQueriedTheSameAcc >= 3;
    }

    public void lockAccount(){
        if(!IsAccessSecured){
            getNextAccount();
        }
        Account.Locked_Date__c = System.now();
        Account.Locked_to__c = UserInfo.getUserId();
        AccountCallOutContHelper.updateAccount(Account);
    }

    private void unlockAccount(){
        Account.Locked_Date__c = null;
        Account.Locked_to__c = null;
        TimesIQueriedTheSameAcc = 0;
        AccountCallOutContHelper.updateAccount(Account);
    }

    public void actionNoAnswer(){
        createNote('No Answer', 'No Answer');
        unlockAccount();
        getNextAccount();
    }

    public void actionInvalidNumber(){
        createNote('Dead Number', 'Dead Number');
        if(AlreadyNotedInvalidNumberThreeTimes()){
            Account.Status__c = 'Dormant';
            AccountCallOutContHelper.updateAccount(Account);
        }
        unlockAccount();
        getNextAccount();
    }

    public void actionLeftVM(){
        createNote('Voicemail Left', 'Voicemail Left');
        unlockAccount();
        getNextAccount();
    }

    public void actionContact(){
        createNote('Successful Contact', '');
        unlockAccount();
        getNextAccount();
    }

    public void actionRecep(){
        createNote('Receptionist', '');
        unlockAccount();
        getNextAccount();
    }

    private void createNote(String note_category, String note_text){
        Account_Notes__c note = new Account_Notes__c(Account__c = Account.Id);
        note.Note_Category__c = note_category;
        note.Note__c = note_text;
        if(!String.isBlank(AdditionalNoteDetail)){
            if(!String.isBlank(note.Note__c)){
                note.Note__c += '\n';
            }
            note.Note__c += AdditionalNoteDetail;
            AdditionalNoteDetail = null;
        }
        note.Call_Outcome__c = CallOutcomeHolder.Call_Outcome__c;
        CallOutcomeHolder.Call_Outcome__c = null;
        insert note;
    }

    private Boolean AlreadyNotedInvalidNumberThreeTimes(){
        Integer notes_limit = 3;
        Integer invalid_notes_count = 1; //starting with 1 because related list will not include the note we have just inserted;
        for(Account_Notes__c note:Account.Account_Notes__r){
            if(note.Note_Category__c == 'Invalid Number'){
                invalid_notes_count++;
                if(invalid_notes_count >= notes_limit){
                    break;
                }
            }
        }
        return invalid_notes_count >= notes_limit;
    }
}