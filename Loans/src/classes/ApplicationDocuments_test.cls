@isTest
private class ApplicationDocuments_test {
	
	@isTest static void testApplicationDocumentswithApplicationId() {
		Application__c application = setupData();
        ApplicationDocuments controller = new ApplicationDocuments(new ApexPages.StandardController(application));
        PageReference current_page = Page.ApplicationDocuments;
        current_page.getParameters().put('id', application.Id);
        controller.accessgranted = false;
        Test.setCurrentPage(current_page);
        Test.startTest();

        Test.stopTest();

        System.assertEquals(false, controller.accessgranted);
        
	}

	@isTest static void testApplicationDocumentswithKey() {
		Application__c application = setupData();
		String securitykey = 'fg345geefg';
		application.DocumentSecurityKey__c = securitykey;
		update application;

		PageReference current_page = Page.ApplicationDocuments;
		Test.setCurrentPage(current_page);
		ApexPages.StandardController sc = new ApexPages.StandardController(application);
		ApexPages.currentPage().getParameters().put('key', securitykey);
        ApplicationDocuments controller = new ApplicationDocuments(sc);
        
        Test.startTest();

        Test.stopTest();

        System.assertEquals(true, controller.accessgranted);
        
	}


	
	 private static Application__c setupData(){
        Account account = AccountBuilder.getBuilder('Test')
                                            .save()
                                            .getRecord();

        Campaign campaign = CampaignBuilder.getBuilder('Campaign 1')
                                            .setAccount(account)
                                            .save()
                                            .getRecord();

        Application__c application  = ApplicationBuilder.getBuilder(account)
                                                            .setCampaign(campaign)
                                                            .setLoanAmount(150000)
                                                            .setApplicationType('Bridging Loan')
                                                            .setLoanTermMonths(60)
                                                            .save()
                                                            .getRecord();

        Applicant__c applicant = ApplicantBuilder.getBuilder(application)
                                                    .setFirstName('Bob')
                                                    .setLastName('Turwillicgar')
                                                    .setEmail('bob@example.com')
                                                    .setMobilePhone('0777775555')
                                                    .setDateOfBirth(Date.newInstance(1981,2,2))
                                                    .setTimeInEmploymentMonths(4)
                                                    .setTimeInEmploymentYears(5)
                                                    .setTimeWithPreviousEmployerMonths(2)
                                                    .setTimeWithPreviousEmployerYears(2)
                                                    .setIsPrimary(true)
                                                    .save()
                                                    .getRecord();
  

        return application;
    }
	
}