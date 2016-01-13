@isTest
private class ApplicantIncomeBuilder_Test {
	
	static testMethod void testGetBuilderInstantiatesRecordAndNameIsSet(){
        Test.startTest();
            ApplicantIncomeBuilder builder = ApplicantIncomeBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
            													.save()
            													.getRecord());



        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord());
    }

    static testMethod void testGetBuilderInstantiatesRecordAndNameIsSetforExistingRecord(){
        Test.startTest();
            ApplicantIncomeBuilder builder = ApplicantIncomeBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save()
                                                                .getRecord());

            ApplicantIncomeBuilder updatedBuilder = ApplicantIncomeBuilder.getBuilder(builder.getRecord());


        Test.stopTest();
        System.assertNotEquals(null, updatedBuilder.getRecord());
    }

     static testMethod void testSaveMethodSavesRecord(){
        Test.startTest();
            ApplicantIncomeBuilder builder = ApplicantIncomeBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            		AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
                                                                .save()
                                                                .getRecord())
            														.save();
        Test.stopTest();
        System.assertNotEquals(null, builder.getRecord().Id);
    }

    static testMethod void testSetMethodsSetAppropriateValues(){
        String occupation = 'docker';
        String income_type = 'Pension';
        String income_category = 'Primary';
        String benefit_type = 'Child Benefit';
        String employer_name = 'The Man';
        String employer_status = 'Full Time Employment';
        Integer time_in_employment_months = 2;
        Integer time_in_employment_years = 2;
        Decimal net_monthly_income = 1515.15;
        Decimal gross_monthly_income = 2323.23;
        Integer percent_owned = 30;
        String company_reg_number = 'F2345678i';
        String company_type = 'Partnership';
        Integer contract_length = 24;
        String employer_address = '12 Any Street';
        String employer_phone = '0123456789';
        String employer_postcode = 'AB123CD';
        Decimal net_annual_income = 1515.15;
        Decimal gross_annual_income = 2323.23;
        String income_proof = 'Payslip';
        String pay_frequency = 'Monthly';
        Boolean rolling_contract  = true;
        Integer applicant_index = 1;
        Integer applicant_income_index =2;
        Test.startTest();
            ApplicantIncomeBuilder builder = ApplicantIncomeBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                            	AccountBuilder.getBuilder('Test')
                                                        .save()
                                                        .getRecord())
                                                            .save()
                                                            .getRecord())
            													.save()
                                                            	.getRecord())
	                                                                .setOccupation(occupation)
	                                                                .setIncomeType(income_type)
	                                                                .setIncomeCategory(income_category)
	                                                                .setBenefitType(benefit_type)
	                                                                .setEmployerName(employer_name)
	                                                                .setEmployerStatus(employer_status)
	                                                                .setTimeInEmploymentMonths(time_in_employment_months)
	                                                                .setTimeInEmploymentYears(time_in_employment_years)
	                                                                .setNetMonthlyIncome(net_monthly_income)
	                                                                .setGrossMonthlyIncome(gross_monthly_income)
	                                                                .setOfCompanyOwned(percent_owned)
	                                                                .setCompanyRegNumber(company_reg_number)
	                                                                .setCompanyType(company_type)
	                                                                .setContractLengthMonths(contract_length)
	                                                                .setEmployerAddress(employer_address)
	                                                                .setEmployerPhoneNumber(employer_phone)
	                                                                .setEmployerPostcode(employer_postcode)
	                                                                .setNetAnnualIncome(net_annual_income)
	                                                                .setGrossAnnualIncome(gross_annual_income)
	                                                                .setIncomeProof(income_proof)
	                                                                .setPayFrequency(pay_frequency)
	                                                                .setRollingContract(rolling_contract)
                                                                    .setApplicantIndex(applicant_index)
                                                                    .setApplicantIncomeIndex(applicant_income_index)
	                                                                .save();
        Test.stopTest();
        System.assertEquals(occupation,builder.getRecord().Occupation__c);
        System.assertEquals(income_type ,builder.getRecord().Income_Type__c);
        System.assertEquals(income_category ,builder.getRecord().Income_Category__c);
        System.assertEquals(benefit_type ,builder.getRecord().Benefit_Type__c);
        System.assertEquals(employer_name ,builder.getRecord().Employer_Name__c);
        System.assertEquals(employer_status ,builder.getRecord().Employer_Status__c);
        System.assertEquals('2' ,builder.getRecord().Time_In_Employment_Months__c);
        System.assertEquals('2', builder.getRecord().Time_In_Employment_Years__c);
        System.assertEquals(net_monthly_income, builder.getRecord().Net_Monthly_Income__c);
        System.assertEquals(gross_monthly_income, builder.getRecord().Gross_Monthly_Income__c);
        System.assertEquals(percent_owned, builder.getRecord().Of_Company_Owned__c);
        System.assertEquals(company_reg_number, builder.getRecord().Company_Registration_Number__c);
        System.assertEquals(company_type, builder.getRecord().Company_Type__c);
        System.assertEquals(contract_length, builder.getRecord().Contract_Length_Months__c);
        System.assertEquals(employer_address, builder.getRecord().Employer_Address__c);
        System.assertEquals(employer_phone, builder.getRecord().Employer_Phone_Number__c);
        System.assertEquals(employer_postcode, builder.getRecord().Employer_Postcode__c);
        System.assertEquals(net_annual_income, builder.getRecord().Net_Annual_Income__c);
        System.assertEquals(gross_annual_income, builder.getRecord().Gross_Annual_Income__c);
        System.assertEquals(income_proof, builder.getRecord().Proof_of_Income__c);
        System.assertEquals(pay_frequency, builder.getRecord().Pay_Frequency__c);
        System.assertEquals(rolling_contract, builder.getRecord().Rolling_Contract__c);
        System.assertEquals(applicant_index, builder.getRecord().Applicant_index__C);
        System.assertEquals(applicant_income_index, builder.getRecord().Applicant_Income_Index__c);





        
    }

     static testMethod void testsetTimeInEmploymentYearsSetsValueforGreaterthan10Years(){
        Integer time_in_employment_years = 11;
        Test.startTest();
            ApplicantIncomeBuilder builder = ApplicantIncomeBuilder.getBuilder(ApplicantBuilder.getBuilder(ApplicationBuilder.getBuilder(
                                        		AccountBuilder.getBuilder('Test')
                                                    .save()
                                                    .getRecord())
                                                        .save()
                                                        .getRecord())
            												.save()
                                                        	.getRecord())
	                                                            .setTimeInEmploymentYears(time_in_employment_years)
	                                                            .save();
        Test.stopTest();
        System.assertEquals('10+',builder.getRecord().Time_In_Employment_Years__c);
    }

	
	
	
}