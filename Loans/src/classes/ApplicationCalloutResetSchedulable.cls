global class ApplicationCalloutResetSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        resetCalloutAttemptsCounterForRelevantApplications();
    }

    @TestVisible
    private void resetCalloutAttemptsCounterForRelevantApplications(){
        List<Application__c> applications_to_reset = [SELECT Callout_Attempts_Current_Shift__c FROM Application__c
            WHERE (Last_Call_Out_Date__c < :ApplicationCallOutCont.getCurrentShiftStartTime() OR Last_Call_Out_Date__c = null)
            AND (Locked_Date__c < :System.now().addMinutes(-30) OR Locked_Date__c = null)
            AND Stage__c = 'Call for full app'
            AND Branch__c != 'Southend'];
        for(Application__c app:applications_to_reset){
            app.Callout_Attempts_Current_Shift__c = 0;
        }
        update applications_to_reset;
    }

    global static String scheduleIt() {
        if (!Test.isRunningTest()) {
            //Note: User timezone MUST match London timezone
            String chron_exp = '0 0 8,12,18 * * ?';
            return System.schedule('Reset callout attempts counter', chron_exp, new ApplicationCalloutResetSchedulable());
        }else{
            return null;
        }
    }
}