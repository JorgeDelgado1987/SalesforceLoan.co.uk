@isTest
public class ApplicationBuilder_Test {

    static testMethod void testGetBuilderInstantiatesApplicationRecord(){
        Test.startTest();
            ApplicationBuilder builder = ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testSaveInsertsRecord(){
        Test.startTest();
            ApplicationBuilder builder = ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetCRSReportId(){
        String report_id = 'aebaebebe-aebeeb-ebaeb-ebebeb-ebabebe';
        Test.startTest();
            ApplicationBuilder builder = ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .setCRSReportId(report_id)
                                                            .save();
        Test.stopTest();
        System.assertEquals(report_id, builder.getRecord().CRS_Report_Id__c);
    }
}