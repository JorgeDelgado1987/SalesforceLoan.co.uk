@isTest
public class ApplicationCallOutCont_Test {

    static testMethod void testLockApplicationSetsCurrentLockedDate(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            cls.lockApplication();
        Test.stopTest();
        System.assertEquals(System.today(), cls.Application.Locked_Date__c.date());
    }

    static testMethod void testActionLeftVMCreatesCaseNote(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            Id app_id = cls.Application.Id;
            cls.actionLeftVM();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Case_Note__c WHERE Type__c = 'Left Message' AND Application__c = :app_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionNoAnswerCreatesCaseNote(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            Id app_id = cls.Application.Id;
            cls.actionNoAnswer();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Case_Note__c WHERE Type__c = 'No Answer' AND Application__c = :app_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionInvalidNumberCreatesCaseNote(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            Id app_id = cls.Application.Id;
            cls.actionInvalidNumber();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Case_Note__c WHERE Type__c = 'Invalid Number' AND Application__c = :app_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionSetCallBackCreatesCaseNote(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            Id app_id = cls.Application.Id;
            cls.actionSetCallBack();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Case_Note__c WHERE Type__c = 'Call Back' AND Application__c = :app_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionCancelApplicationCreatesCaseNote(){
        getTestApp();
        Test.startTest();
            ApplicationCallOutCont cls = new ApplicationCallOutCont();
            cls.Application.Cancellation_Reason__c = 'test';
            Id app_id = cls.Application.Id;
            cls.actionCancelApplication();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Case_Note__c WHERE Type__c = 'Call' AND Application__c = :app_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    private static ApexPages.StandardController getTestApp(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar').save().getRecord();
        return new ApexPages.StandardController(app);
    }
}