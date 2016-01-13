@isTest
public class CreditSearchExtension_Test {

    static testMethod void testExecuteCreditSearchgetSuccessfulMockReport(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
        Test.stopTest();
        System.assertEquals(true, cls.CreditReport.isSuccess(), 'Successful credit report expected');
    }

    static testMethod void testInsertSelectedSObjectPopulatesRecordIdAsTheResultOfInsertion(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
            cls.SelectedRecordIndex = cls.ReportedCCJs.get(0).UniqueIndex;
            cls.insertSelectedSObject();
        Test.stopTest();
        System.assertNotEquals(null, cls.ReportedCCJs.get(0).getRecord().Id, 'Id should be populated for inserted record');
    }

    static testMethod void testShowMergeUIForSelectedSObjectSetsIsMergingFlag(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
            cls.SelectedRecordIndex = cls.ReportedCCJs.get(0).UniqueIndex;
            cls.showMergeUIForSelectedSObject();
        Test.stopTest();
        System.assertEquals(true, cls.ReportedCCJs.get(0).IsMerging, 'Selected record should have IsMerging flag');
    }

    static testMethod void testCancelMergeRemovesIsMergingFlag(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
            cls.SelectedRecordIndex = cls.ReportedCCJs.get(0).UniqueIndex;
            cls.showMergeUIForSelectedSObject();
            cls.cancelMerge();
        Test.stopTest();
        System.assertEquals(false, cls.ReportedCCJs.get(0).IsMerging, 'Selected record should NOT have IsMerging flag after merging is cancelled');
    }

    static testMethod void testConfirmMergePopulatesSelectedRecordId(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
            cls.SelectedRecordIndex = cls.ReportedCCJs.get(0).UniqueIndex;
            cls.showMergeUIForSelectedSObject();
            cls.ReportedCCJs.get(cls.ReportedCCJs.size() - 1).IsSelectedForMerge = true;
            cls.confirmMerge();
        Test.stopTest();
        System.assertNotEquals(null, cls.ReportedCCJs.get(0).getRecord().Id, 'Id should be populated for inserted record');
        System.assertEquals(cls.ReportedCCJs.get(cls.ReportedCCJs.size() - 1).getRecord().Id, cls.ReportedCCJs.get(0).getRecord().Id, 'Id should match to merged record Id');
    }

    static testMethod void testInsertAllSelectedRecordsPopulatesRecordIdsAsTheResultOfInsertion(){
        HttpMockHandler.addMock(CRSIntegration_Test.getMockResponse());
        Test.startTest();
            CreditSearchExtension cls = new CreditSearchExtension(getTestApp());
            cls.executeCreditSearch();
            cls.ReportedCCJs.get(0).IsSelectedForInsertion = true;
            cls.ReportedMortgages.get(0).IsSelectedForInsertion = true;
            cls.ReportedDebts.get(0).IsSelectedForInsertion = true;
            cls.insertAllSelectedRecords();
        Test.stopTest();
        System.assertNotEquals(null, cls.ReportedCCJs.get(0).getRecord().Id, 'Id should be populated for inserted record');
        System.assertNotEquals(null, cls.ReportedMortgages.get(0).getRecord().Id, 'Id should be populated for inserted record');
        System.assertNotEquals(null, cls.ReportedDebts.get(0).getRecord().Id, 'Id should be populated for inserted record');
    }

    private static ApexPages.StandardController getTestApp(){
        Account account = AccountBuilder.getBuilder('Test Acc').save().getRecord();
        Application__c app = ApplicationBuilder.getBuilder(account).save().getRecord();
        Applicant__c applicant = ApplicantBuilder.getBuilder(app).setFirstName('Bob').setLastName('Turwilligar').save().getRecord();
        Property__c property = PropertyBuilder.getBuilder(app)
                                                .setCurrentAddress(true)
                                                .setPostCode('2AB 3CD')
                                                .setStreetName('Fake St')
                                                .save()
                                                .getRecord();
        CCJBuilder.getBuilder(app).save();
        return new ApexPages.StandardController(app);
    }
}