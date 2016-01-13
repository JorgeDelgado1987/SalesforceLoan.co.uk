@isTest
public class ApplicantBuilder_Test {

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            ApplicantBuilder builder = ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
            ApplicantBuilder builder = ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
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
        String first_name = 'bob';
        String last_name = 'Turwilligar';
        String email = 'bob@example.com';
        Date dob = Date.newInstance(1989, 2, 12);
        String title = 'Mr';
        String postcode = '1AB 2CC';
        String maiden_name = 'n/a';
        String mobile_phone = '2312123123';
        Integer time_in_employment_months = 2;
        Integer time_in_employment_years = 2;
        Integer time_with_previous_employer_months = 2;
        Integer time_with_previous_employer_years = 4;
        Integer applicant_index =1;
        Boolean is_primary = true;
        Test.startTest();
            ApplicantBuilder builder = ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .setFirstName(first_name)
                                                                .setLastName(last_name)
                                                                .setEmail(email)
                                                                .setDateOfBirth(dob)
                                                                .setTitle(title)
                                                                .setPostCode(postcode)
                                                                .setMaidenName(maiden_name)
                                                                .setMobilePhone(mobile_phone)
                                                                .setTimeInEmploymentMonths(time_in_employment_months)
                                                                .setTimeInEmploymentYears(time_in_employment_years)
                                                                .setTimeWithPreviousEmployerMonths(time_with_previous_employer_months)
                                                                .setTimeWithPreviousEmployerYears(time_with_previous_employer_years)
                                                                .setApplicantIndex(applicant_index)
                                                                .setIsPrimary(is_primary)
                                                                .save();
        Test.stopTest();
        System.assertEquals(first_name,builder.getRecord().First_name__c);
        System.assertEquals(last_name ,builder.getRecord().Last_Name__c);
        System.assertEquals(email ,builder.getRecord().Email_Address__c);
        System.assertEquals(dob ,builder.getRecord().Date_Of_Birth__c);
        System.assertEquals(title ,builder.getRecord().Title__c);
        System.assertEquals(postcode ,builder.getRecord().PostCode__c);
        System.assertEquals(maiden_name ,builder.getRecord().Maiden_Name__c);
        System.assertEquals('2' ,builder.getRecord().Time_In_Employment_Months__c);
        System.assertEquals('2', builder.getRecord().Time_In_Employment_Years__c);
        System.assertEquals('2', builder.getRecord().Time_with_Prev_Employer_Months__c);
        System.assertEquals('4', builder.getRecord().Time_with_Prev_Employer_Years__c);
        System.assertEquals(applicant_index, builder.getRecord().Applicant_Index__c);
        System.assertEquals(is_primary, builder.getRecord().Is_Primary__c);
    }

    static testMethod void testsetTimeInEmploymentYearsSetsValueforGreaterthan10Years(){
        Integer time_in_employment_years = 11;
        Test.startTest();
            ApplicantBuilder builder = ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                        AccountBuilder.getBuilder('Test')
                                                    .save()
                                                    .getRecord())
                                                        .save()
                                                        .getRecord())
                                                            .setTimeInEmploymentYears(time_in_employment_years)
                                                            .save();
        Test.stopTest();
        System.assertEquals('10+',builder.getRecord().Time_In_Employment_Years__c);
    }

    static testMethod void testsetTimeWithPreviousEmployerSetsValueforGreaterthan10Years(){
        Integer time_with_previous_employer_years = 11;
        Test.startTest();
            ApplicantBuilder builder = ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                        AccountBuilder.getBuilder('Test')
                                                    .save()
                                                    .getRecord())
                                                        .save()
                                                        .getRecord())
                                                            .setTimeWithPreviousEmployerYears(time_with_previous_employer_years)
                                                            .save();
        Test.stopTest();
        System.assertEquals('10+',builder.getRecord().Time_with_Prev_Employer_Years__c);
    }
}