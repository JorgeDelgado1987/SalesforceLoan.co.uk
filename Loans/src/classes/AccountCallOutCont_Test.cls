@isTest
public class AccountCallOutCont_Test {

    static testMethod void testLockAccountSetsCurrentLockedDate(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            cls.lockAccount();
        Test.stopTest();
        System.assertEquals(System.today(), cls.Account.Locked_Date__c.date());
    }

    static testMethod void testActionLeftVMCreatesNote(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            Id acc_id = cls.Account.Id;
            cls.actionLeftVM();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Account_Notes__c WHERE Note_Category__c = 'Voicemail Left' AND Account__c = :acc_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionNoAnswerCreatesNote(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            Id acc_id = cls.Account.Id;
            cls.actionNoAnswer();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Account_Notes__c WHERE Note_Category__c = 'No Answer' AND Account__c = :acc_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionInvalidNumberCreatesNote(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            Id acc_id = cls.Account.Id;
            cls.actionInvalidNumber();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Account_Notes__c WHERE Note_Category__c = 'Dead Number' AND Account__c = :acc_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionContactCreatesNote(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            Id acc_id = cls.Account.Id;
            cls.CallOutcomeHolder.Call_Outcome__c = 'get lucky';
            cls.actionContact();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Account_Notes__c WHERE Note_Category__c = 'Successful Contact' AND Account__c = :acc_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    static testMethod void testActionRecepCreatesNote(){
        getTestAcc();
        Test.startTest();
            AccountCallOutCont cls = new AccountCallOutCont();
            Id acc_id = cls.Account.Id;
            cls.actionRecep();
        Test.stopTest();
        Integer note_count = [SELECT COUNT() FROM Account_Notes__c WHERE Note_Category__c = 'Receptionist' AND Account__c = :acc_id];
        System.assertEquals(1, note_count, 'there should be one note created');
    }

    private static ApexPages.StandardController getTestAcc(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        return new ApexPages.StandardController(account);
    }
}