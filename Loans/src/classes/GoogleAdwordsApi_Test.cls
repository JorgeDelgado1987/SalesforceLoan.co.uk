@isTest
private class GoogleAdwordsApi_Test {

    @isTest static void testWhenNoCredentialsStoredExceptionIsThrown() {
        Boolean has_correct_exception = false;
        Test.startTest();
            try{
                GoogleAdwordsApi.getInstance();
            } catch (GoogleAdwordsApi.GoogleApiException gex) {
                has_correct_exception = true;
            }
        Test.stopTest();
        System.assertEquals(true, has_correct_exception, 'GoogleApi Exceptions should have been thrown as no credentials are stored');
    }

    @isTest static void testWhenNoExceptionIsthrownWhenCredentialsAreSet() {
        GoogleOAuth_Test.getTokens(1);
        Boolean has_exception = false;
        Test.startTest();
            try{
                GoogleAdwordsApi.getInstance();
            } catch (GoogleAdwordsApi.GoogleApiException gex) {
                has_exception = true;
            }
        Test.stopTest();
        System.assertEquals(false, has_exception, 'Exception should not be thrown as OAuthTokens are present and valid');
    }

    @isTest static void testReportConfigForStartAndEndDateSetsTheCorrectStrings(){
        Date start_date = Date.newInstance(2014, 11, 11);
        Date end_date = Date.newInstance(2014, 12, 11);
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(start_date, end_date);
        Test.stopTest();
        System.assertEquals(' CreatedDate  > 2014-11-11T12:00:00z AND CreatedDate < 2014-12-12T12:00:00z', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING 20141111,20141211', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForStartAndEndDateSetsTheCorrectStringsWith0s(){
        Date start_date = Date.newInstance(2014, 2, 2);
        Date end_date = Date.newInstance(2014, 3, 3);
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(start_date, end_date);
        Test.stopTest();
        System.assertEquals(' CreatedDate  > 2014-02-02T12:00:00z AND CreatedDate < 2014-03-04T12:00:00z', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING 20140202,20140303', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForThisWeekDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.THIS_WEEK;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = THIS_WEEK', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING THIS_WEEK_MON_TODAY', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForTodayDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.TODAY;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = TODAY', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING TODAY', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForYesterdayDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.YESTERDAY;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = YESTERDAY', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING YESTERDAY', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForLast7DaysDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.LAST_7_DAYS;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = LAST_N_DAYS:7', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING LAST_7_DAYS', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForLast14DaysDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.LAST_14_DAYS;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = LAST_N_DAYS:14', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING LAST_14_DAYS', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testReportConfigForLast30DaysDateRangeBuildsCorrectStrings(){
        GoogleAdwordsApi.DateRange date_range = GoogleAdwordsApi.DateRange.LAST_30_DAYS;
        Test.startTest();
            GoogleAdwordsApi.ReportConfig config = new GoogleAdwordsApi.ReportConfig(date_range);
        Test.stopTest();
        System.assertEquals(' CreatedDate = LAST_N_DAYS:30', config.getSalesforceQueryString(),'Salesforce query string does not match expected value');
        System.assertEquals(' DURING LAST_30_DAYS', config.getGoogleAPIQueryString(), 'Google Query string does not match expected value');
    }

    @isTest static void testPerformanceReportDataConstructionWithSetWorks(){
        List<String> data_row = new List<String>{'loan','200000','2000','40','200000','Loan-co','exact','11101101101101010'};
        Test.startTest();
            GoogleAdwordsApi.PerformanceReportData report_data = new GoogleAdwordsApi.PerformanceReportData(data_row);
        Test.stopTest();
        System.assertEquals('loan', report_data.KeywordText);
        System.assertEquals(0.20, report_data.Cost);
        System.assertEquals(2000, report_data.Impressions);
        System.assertEquals(40, report_data.Clicks);
        System.assertEquals(0.20, report_data.AverageCpc);
        System.assertEquals('Loan-co', report_data.CampaignName);
        System.assertEquals('exact', report_data.KeywordMatchType);
        System.assertEquals('11101101101101010', report_data.CampaignId);
        System.assertEquals(0.0001, report_data.CostPerImpression);
        System.assertEquals(0, report_data.getCostPerApplication());
        System.assertEquals(0, report_data.getCostPerValidation());
        System.assertEquals(0, report_data.getCostPerPackOut());
        System.assertEquals(0, report_data.getCostPerPaidOut());
        System.assertEquals(0, report_data.getProjectedROI());
        System.assertEquals(-0.20, report_data.getProjectedProfitAndLoss());
        System.assertEquals(-0.20, report_data.getProfitAndLoss());
        System.assertEquals(-0.20, report_data.getProfitAndLoss());
    }

    @isTest static void testPerformanceReportDataCalculatedValuesCalculatedCorrectly(){
        List<String> data_row = new List<String>{'loan','200000','2000','40','200000','Loan-co','exact','11101101101101010'};
        Test.startTest();
            GoogleAdwordsApi.PerformanceReportData report_data = new GoogleAdwordsApi.PerformanceReportData(data_row);
            report_data.ApplicationCount = 10;
            report_data.ValidatedCount = 10;
            report_data.PacksOutCount = 10;
            report_data.PacksOutValue = 100000;
            report_data.PaidOutCount = 10;
            report_data.PaidOutValue = 100000;
        Test.stopTest();
        System.assertEquals('loan', report_data.KeywordText);
        System.assertEquals(0.20, report_data.Cost);
        System.assertEquals(2000, report_data.Impressions);
        System.assertEquals(40, report_data.Clicks);
        System.assertEquals(0.20, report_data.AverageCpc);
        System.assertEquals('Loan-co', report_data.CampaignName);
        System.assertEquals('exact', report_data.KeywordMatchType);
        System.assertEquals('11101101101101010', report_data.CampaignId);
        System.assertEquals(0.02, report_data.getCostPerApplication());
        System.assertEquals(0.02, report_data.getCostPerValidation());
        System.assertEquals(0.02, report_data.getCostPerPackOut());
        System.assertEquals(0.02, report_data.getCostPerPaidOut());
        System.assertEquals(0.0000020000000000000003, report_data.getProjectedROI());
        System.assertEquals(-0.199998, report_data.getProjectedProfitAndLoss());
        System.assertEquals(99999.8, report_data.getProfitAndLoss());
        System.assertEquals(99999.8, report_data.getProfitAndLoss());
    }

    @isTest static void testGetPerformanceReportWithValidMock() {
        GoogleOAuth_Test.getTokens(1);
        HttpMockHandler.addMock(getKeywordReportMock());
        Test.startTest();
                List<GoogleAdwordsApi.PerformanceReportData> performance_report = GoogleAdwordsApi.getInstance().getPerformanceReport(GoogleAdwordsApi.ReportType.KEYWORD, new GoogleAdwordsApi.ReportConfig(GoogleAdwordsApi.DateRange.LAST_7_DAYS));
        Test.stopTest();
        System.assertEquals(2, performance_report.size() , '2 rows of data should be returned');
    }

    @isTest static void testGetPerformanceReportWithValidMockAndSalesforceData() {
        GoogleOAuth_Test.getTokens(1);
        HttpMockHandler.addMock(getKeywordReportMock());
        Application__c application = setupData();
        Test.startTest();
                List<GoogleAdwordsApi.PerformanceReportData> performance_report = GoogleAdwordsApi.getInstance().getPerformanceReport(GoogleAdwordsApi.ReportType.KEYWORD, new GoogleAdwordsApi.ReportConfig(GoogleAdwordsApi.DateRange.LAST_7_DAYS));
        Test.stopTest();
        System.assertEquals(2, performance_report.size() , '2 rows of data should be returned');
    }


    private static String getPerformanceReportCSVBody(){
        return 'loan,200000,2000,40,200000,Loan-co,Exact,11101101101101010,\nloan,200000,2000,20,100000,Loan-co,Phrase,11101101101101010';
    }

    private static HttpHandler.HttpHandlerResponse getKeywordReportMock(){
        HttpResponse response = new HttpResponse();
        response.setBody(getPerformanceReportCSVBody());
        response.setStatusCode(200);
        return new HttpHandler.HttpHandlerResponse(response);
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
                                                            .setKeyword('loan')
                                                            .setMatchType('p')
                                                            .setPPCCampaign('11101101101101010')
                                                            .setApplicationValue(20000)
                                                            .save()
                                                            .getRecord();

        Stage_History__c validated_history = StageHistoryBuilder.getBuilder(application)
                                                                    .setApplicationStage(
                                                                        ApplicationStageBuilder.getBuilder('Underwrite')
                                                                            .save()
                                                                            .getRecord())
                                                                    .save()
                                                                    .getRecord();

        Stage_History__c pack_out_history = StageHistoryBuilder.getBuilder(application)
                                                                    .setApplicationStage(
                                                                        ApplicationStageBuilder.getBuilder('Send Advance Copy Pack')
                                                                            .save()
                                                                            .getRecord())
                                                                    .save()
                                                                    .getRecord();

        Stage_History__c paid_out_history = StageHistoryBuilder.getBuilder(application)
                                                                    .setApplicationStage(
                                                                        ApplicationStageBuilder.getBuilder('Paid Out')
                                                                            .save()
                                                                            .getRecord())
                                                                    .save()
                                                                    .getRecord();
        return application;
    }
}