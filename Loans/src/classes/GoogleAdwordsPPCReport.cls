public with sharing class GoogleAdwordsPPCReport {
    private final String DEFAULT_DATE_RANGE = GoogleAdwordsApi.DateRange.LAST_7_DAYS.name();
    private List<GoogleAdwordsApi.PerformanceReportData> report_data;
    public String SelectedDateRange { get; set; }  { SelectedDateRange = DEFAULT_DATE_RANGE; }
    public Date StartDate { get; set; }
    public Date EndDate { get; set; }

    public GoogleAdwordsPPCReport() {}

    public List<GoogleAdwordsApi.PerformanceReportData> getReport(){
        if(report_data == null){
            report_data = GoogleAdwordsApi.getInstance().getPerformanceReport(GoogleAdwordsApi.ReportType.KEYWORD, getConfig());
        }
        return report_data;
    }

    public String getReportDetailString(){
        if(SelectedDateRange == GoogleAdwordsApi.DateRange.CUSTOM_DATE.name()){
            return 'Keyword Peformance Report from ' + StartDate.format() + ' to ' + EndDate.format();
        } else {
            return 'Keyword Peformance Report for ' + SelectedDateRange.replaceAll('_', ' ').toLowerCase();
        }
    }

    public PageReference runReport(){
        if(getSelectedDateRange() == GoogleAdwordsApi.DateRange.CUSTOM_DATE){
            if(StartDate == null || EndDate == null){
                Utility.addErrorMessage('Start Date and End Date Required for Custom Date Ranges');
                return null;
            }
        }
        try{
            report_data = GoogleAdwordsApi.getInstance().getPerformanceReport(GoogleAdwordsApi.ReportType.KEYWORD, getConfig());
        } catch (exception e) {
            Utility.addErrorMessage(e.getMessage() + ' ' + e.getStackTraceString());
        }
        return null;
    }

    private GoogleAdwordsApi.ReportConfig getConfig(){
        GoogleAdwordsApi.ReportConfig config;
        if(getSelectedDateRange() == GoogleAdwordsApi.DateRange.CUSTOM_DATE){
            if(StartDate == null || EndDate == null){
                Utility.addErrorMessage('Start Date and End Date Required for Custom Date Ranges');
            } else {
                config = new GoogleAdwordsApi.Reportconfig(StartDate,EndDate);
            }
        } else {
            config = new GoogleAdwordsApi.ReportConfig(getSelectedDateRange());
        }
        return config;
    }

    public PageReference isAuthenticatedWithAdwords(){
        if(GoogleOAuth.getInstance().isAuthenticated()){
            return null;
        } else {
            return GoogleOAuth.getInstance().getAuthURL(System.URL.getCurrentRequestUrl().toExternalForm());
        }
    }

    private GoogleAdwordsApi.DateRange getSelectedDateRange(){
        return convertToDateRange(SelectedDateRange);
    }

    private GoogleAdwordsApi.DateRange convertToDateRange(String date_range_name){
        for (GoogleAdwordsApi.DateRange dr: GoogleAdwordsApi.DateRange.values()){
            if (dr.name() == date_range_name){
                return dr;
            }
        }
        return null;
    }

    public List<SelectOption> getRangeOptions() {
        List<SelectOption> options = new List<SelectOption>();
        //options.add(new SelectOption(GoogleAdwordsApi.DateRange.ALL_TIME.name(),'All Time'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.CUSTOM_DATE.name(),'Custom'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.TODAY.name(),'Today'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.YESTERDAY.name(),'Yesterday'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.LAST_WEEK.name(),'Last Week'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.LAST_7_DAYS.name(),'Last 7 Days'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.LAST_14_DAYS.name(),'Last 14 Days'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.LAST_30_DAYS.name(),'Last 30 Days'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.LAST_MONTH.name(),'Last Month'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.THIS_WEEK.name(),'This Week'));
        options.add(new SelectOption(GoogleAdwordsApi.DateRange.THIS_MONTH.name(),'This Month'));
        return options;
    }
}