@isTest
public class PropertyBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            PropertyBuilder builder = PropertyBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord());
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            PropertyBuilder builder = PropertyBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetMethodsSetAppropriateValues(){
        Date date_moved_in = Date.newInstance(2011, 2, 2);
        Date date_moved_out = Date.newInstance(2014, 2, 3);
        Date purchase_date = Date.newInstance(2011, 1, 1);
        Boolean security_address = true;
        Double estimated_value = 200000;
        Test.startTest();
            PropertyBuilder builder = PropertyBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .setDateMovedIn(date_moved_in)
                                                                .setDateMovedOut(date_moved_out)
                                                                .setPurchaseDate(purchase_date)
                                                                .setSecurityAddress(security_address)
                                                                .setEstimatedValue(estimated_value)
                                                                .save();
        Test.stopTest();
        System.assertEquals(date_moved_in,builder.getRecord().Date_Moved_In__c);
        System.assertEquals(date_moved_out ,builder.getRecord().Date_Moved_Out__c);
        System.assertEquals(purchase_date ,builder.getRecord().Purchase_Date__c);
        System.assertEquals(security_address, builder.getRecord().Security_Address__c);
        System.assertEquals(estimated_value, builder.getRecord().Estimated_Value__c);

    }

}