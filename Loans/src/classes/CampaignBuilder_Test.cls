@isTest
public class CampaignBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            CampaignBuilder builder = CampaignBuilder.getBuilder('Test');
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
        System.assertEquals('Test', builder.getRecord().Name);
    }

    static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            CampaignBuilder builder = CampaignBuilder.getBuilder('Test')
                                                    .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetAccountMethodSetsAccount(){
        Test.startTest();
           CampaignBuilder builder = CampaignBuilder.getBuilder('Test')
                                                    .setAccount(AccountBuilder.getBuilder('Acc').save().getRecord())
                                                    .save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Account__c);
    }
}