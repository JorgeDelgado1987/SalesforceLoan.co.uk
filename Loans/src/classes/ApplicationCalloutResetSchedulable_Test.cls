@isTest
public class ApplicationCalloutResetSchedulable_Test {

    static testMethod void testCalloutAttemptsCounterGetsResetAsExpected(){
        Application__c app = getTestApp();
        app.Callout_Attempts_Current_Shift__c = 99;
        update app;
        Test.startTest();
            ApplicationCalloutResetSchedulable schedulable_class = new ApplicationCalloutResetSchedulable();
            schedulable_class.resetCalloutAttemptsCounterForRelevantApplications();
        Test.stopTest();
        app = [SELECT Callout_Attempts_Current_Shift__c FROM Application__c WHERE Id=:app.Id];
        System.assertEquals(0, app.Callout_Attempts_Current_Shift__c, 'Callout_Attempts_Current_Shift__c should be reset to Zero now');
    }

    private static Application__c getTestApp(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar').save().getRecord();
        return app;
    }
}