@isTest
public class ApplicationWaterfallReportCont_Test {

    static testMethod void testGetGroupByOptionsReturnsExpectedOptions(){
        getTestApp();
        Test.startTest();
            ApplicationWaterfallReportCont cls = new ApplicationWaterfallReportCont();
            List<SelectOption> options = cls.getGroupByOptions();
        Test.stopTest();
        System.assertEquals(6, options.size());
        System.assertEquals('Account__c', options.get(0).getValue());
        System.assertEquals('Lender__c', options.get(1).getValue());
        System.assertEquals('Case_Manager__c', options.get(2).getValue());
        System.assertEquals('Case_Owner__c', options.get(3).getValue());
        System.assertEquals('Processor__c', options.get(4).getValue());
        System.assertEquals('Business__c', options.get(5).getValue());
    }

    static testMethod void testGetFilterOptionsReturnsExpectedOptions(){
        getTestApp();
        Test.startTest();
            ApplicationWaterfallReportCont cls = new ApplicationWaterfallReportCont();
            cls.SelectedFilterField = 'Lender__c';
            List<SelectOption> options = cls.getFilterOptions();
        Test.stopTest();
        System.assertEquals(1, options.size());
        System.assertEquals('N/A', options.get(0).getLabel());
    }

    static testMethod void testGetTableReturnsNotEmptyString(){
        getTestApp();
        Test.startTest();
            ApplicationWaterfallReportCont cls = new ApplicationWaterfallReportCont();
            cls.SelectedDateField = 'Stage';
            cls.loadApplications();
            String table_string = (String)cls.getTable().value;
        Test.stopTest();
        System.assertNotEquals(0, table_string.length());
    }

    private static Application__c getTestApp(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).save().getRecord();
        Application_Stage__c stage = new Application_Stage__c(Stage__c='My Stage', Stage_Order__c=1);
        insert stage;
        insert new Stage_History__c(Application__c=app.Id, Application_Stage_lkup__c=stage.Id);
        stage = new Application_Stage__c(Stage__c='My Stage 2', Stage_Order__c=2);
        insert stage;
        insert new Stage_History__c(Application__c=app.Id, Application_Stage_lkup__c=stage.Id);
        return app;
    }
}