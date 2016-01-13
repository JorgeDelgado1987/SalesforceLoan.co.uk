public with sharing class ApplicationCallOutCont {
    private final Integer MAX_CALLS_PER_SHIFT = 2;
    private enum Action {CALLBACK, LEFTMESSAGE, NOANSWER, INVALIDNUMBER, SKIP}

    public Application__c Application {get; private set;}
    public Application__c DateHolderApp {get; private set;}
    public Boolean IsApplicationAccessSecured {get; private set;}
    public Integer TimesIQueriedTheSameApp {get; private set;}
    public String AdditionalNoteDetail {get; set;}
    private Id LatestAppId;

    public ApplicationCallOutCont(){
        DateHolderApp = new Application__c();
        getNewestApplication();
    }

    private void getNewestApplication(){
        DateHolderApp.Do_Not_Call_Out_Until_Date__c = System.now().addMinutes(15);
        List<Application__c> apps = [SELECT Name, Loan_Amount__c, Loan_Purpose__c, CreatedDate, Account__c, Cancellation_Reason__c,
                                     Last_Call_Out_Date__c, Do_Not_Call_Out_Until_Date__c, Locked_Date__c, Cancelled_Date__c,
                                     Callout_Attempts_Current_Shift__c, Application_Type__c, LTV__c, Locked_to__c,
                      (SELECT First_Name__c, Last_Name__c, Mobile_Phone__c, Home_Phone__c FROM Applicants__r),
                      (SELECT CreatedById, CreatedDate, Note__c, Type__c FROM Case_Notes__r ORDER BY CreatedDate DESC)
                       FROM Application__c
                       WHERE (Last_Call_Out_Date__c < :getCurrentShiftStartTime() OR Last_Call_Out_Date__c = null
                              OR Callout_Attempts_Current_Shift__c < :MAX_CALLS_PER_SHIFT OR Callout_Attempts_Current_Shift__c = null
                              OR Do_Not_Call_Out_Until_Date__c < :System.now())
                       AND (Locked_Date__c < :System.now().addMinutes(-30) OR Locked_Date__c = null OR Locked_to__c = :UserInfo.getUserId())
                       AND Stage__c = 'Call for full app'
                       AND Branch__c != 'Southend' // 14/05/15 - by Sam's request
                       ORDER BY Do_Not_Call_Out_Until_Date__c ASC NULLS LAST,
                                Callout_Attempts_Current_Shift__c ASC,
                                Application_Type__c ASC,
                                Last_Call_Out_Date__c ASC,
                                CreatedDate DESC LIMIT 1];
        Application = apps.isEmpty() ? null : apps.get(0);
        updateTimesIQueriedTheSameAppCounter(Application);
    }

    private void updateTimesIQueriedTheSameAppCounter(Application__c app){
        Id current_app_id = app == null ? null : app.Id;
        if(TimesIQueriedTheSameApp == null || LatestAppId != current_app_id){
            TimesIQueriedTheSameApp = 1;
        }else{
            TimesIQueriedTheSameApp++;
        }
        LatestAppId = current_app_id;
        IsApplicationAccessSecured = TimesIQueriedTheSameApp >= 3;
    }

    public void lockApplication(){
        if(!IsApplicationAccessSecured){
            getNewestApplication();
        }
        Application.Locked_Date__c = System.now();
        Application.Locked_to__c = UserInfo.getUserId();
        ApplicationCallOutContHelper.updateApplication(Application);
    }

    private void unlockApplication(Action action_completed){
        if(Application.Last_Call_Out_Date__c < getCurrentShiftStartTime() || Application.Last_Call_Out_Date__c == null || Application.Callout_Attempts_Current_Shift__c == null){
            Application.Callout_Attempts_Current_Shift__c = 1;
        }else{
            Application.Callout_Attempts_Current_Shift__c += 1;
        }
        if(action_completed != Action.CALLBACK){
            Application.Do_Not_Call_Out_Until_Date__c = null;
        }
        Application.Last_Call_Out_Date__c = System.now();
        Application.Locked_Date__c = null;
        Application.Locked_to__c = null;
        TimesIQueriedTheSameApp = 0;
        ApplicationCallOutContHelper.updateApplication(Application);
    }

    public static Datetime getCurrentShiftStartTime(){
        Integer london_time_offset_hours = TimeZone.getTimeZone('Europe/London').getOffset(System.now())/3600000;
        Integer hour = System.now().hourGMT() + london_time_offset_hours;// Adding London time zone offset to GMT time to convert to London time.
        if(hour < 8){
            // Subtracting London time zone offset off hardcoded shift start time to get correct time in GMT
            return Datetime.newInstanceGMT(System.now().dateGMT().addDays(-1), Time.newInstance(18 - london_time_offset_hours, 0, 0, 0));
        } else if(hour >= 8 && hour < 12){
            return Datetime.newInstanceGMT(System.now().dateGMT(), Time.newInstance(8 - london_time_offset_hours, 0, 0, 0));
        }else if(hour >= 12 && hour < 18){
            return Datetime.newInstanceGMT(System.now().dateGMT(), Time.newInstance(12 - london_time_offset_hours, 0, 0, 0));
        }else{
            return Datetime.newInstanceGMT(System.now().dateGMT(), Time.newInstance(18 - london_time_offset_hours, 0, 0, 0));
        }
    }

    public void actionSkip(){
        unlockApplication(Action.SKIP);
        getNewestApplication();
    }

    public void actionLeftVM(){
        createCaseNote('Left Message', 'Left Message');
        unlockApplication(Action.LEFTMESSAGE);
        getNewestApplication();
    }

    public void actionNoAnswer(){
        createCaseNote('No Answer', 'No Answer');
        unlockApplication(Action.NOANSWER);
        getNewestApplication();
    }

    public void actionInvalidNumber(){
        createCaseNote('Invalid Number', 'No Answer - Invalid Number');
        if(AlreadyNotedInvalidNumberThreeTimes()){
            Application.Cancellation_Reason__c = 'Invalid Number';
            actionCancelApplication();
        }else{
            unlockApplication(Action.INVALIDNUMBER);
        }
        getNewestApplication();
    }

    public void actionSetCallBack(){
        if(DateHolderApp.Do_Not_Call_Out_Until_Date__c != null){
            createCaseNote('Call Back', 'Call Back set for: ' + DateHolderApp.Do_Not_Call_Out_Until_Date__c.format());
            Application.Do_Not_Call_Out_Until_Date__c = DateHolderApp.Do_Not_Call_Out_Until_Date__c;
            unlockApplication(Action.CALLBACK);
            getNewestApplication();
        }else{
            DateHolderApp.Do_Not_Call_Out_Until_Date__c.addError('Invalid Date and Time');
        }
    }

    public void actionCancelApplication(){
        String reason = Application.Cancellation_Reason__c != null ? Application.Cancellation_Reason__c : 'no reason given';
        createCaseNote('Call', 'Application cancelled due to: ' + reason);
        Application.Cancelled_Date__c = System.today();
        ApplicationMovetoStage.runFlow(Application.Id, 30, Application.Application_Type__c); //30 - Cancelled stage
        ApplicationCallOutContHelper.updateApplication(Application);
        getNewestApplication();
    }

    private void createCaseNote(String note_type, String note_text){
        Case_Note__c note = new Case_Note__c(Application__c = Application.Id);
        note.Type__c = note_type;
        note.Note__c = note_text;
        if(!String.isBlank(AdditionalNoteDetail)){
            note.Note__c += '\n' + AdditionalNoteDetail;
            AdditionalNoteDetail = null;
        }
        insert note;
    }

    private Boolean AlreadyNotedInvalidNumberThreeTimes(){
        Integer notes_limit = 3;
        Integer invalid_notes_count = 1; //starting with 1 because related list will not include the note we have just inserted;
        for(Case_Note__c note:Application.Case_Notes__r){
            if(note.Type__c == 'Invalid Number'){
                invalid_notes_count++;
                if(invalid_notes_count >= notes_limit){
                    break;
                }
            }
        }
        return invalid_notes_count >= notes_limit;
    }

    public String getLastUpdated(){
        return System.now().format('dd/MM/yyyy HH:mm:ss');
    }

    public Integer getTotalNumberOfApps(){
        return [SELECT COUNT() FROM Application__c WHERE Stage__c = 'Call for full app' AND Branch__c != 'Southend'];
    }

    public Integer getNumberOfAppsWithOneCallout(){
        return getNumberOfAppsWithSpecifiedNumberOfCalloutAttempts(1);
    }

    public Integer getNumberOfAppsWithTwoCallouts(){
        return getNumberOfAppsWithSpecifiedNumberOfCalloutAttempts(2);
    }

    private Integer getNumberOfAppsWithSpecifiedNumberOfCalloutAttempts(Integer number_of_callout_attempts){
        return [SELECT COUNT() FROM Application__c WHERE Stage__c = 'Call for full app'
                AND Branch__c != 'Southend'
                AND Last_Call_Out_Date__c >= :getCurrentShiftStartTime()
                AND Callout_Attempts_Current_Shift__c >= :number_of_callout_attempts];
    }
}