public with sharing class GoogleAdwordsApi {
    public enum ReportType {KEYWORD, AD_GROUP}
    public enum DateRange {TODAY, YESTERDAY, LAST_7_DAYS, LAST_WEEK, THIS_MONTH, LAST_MONTH, ALL_TIME, CUSTOM_DATE, LAST_14_DAYS, LAST_30_DAYS, THIS_WEEK}
    private final Map<String,String> match_type_translation = new Map<String, String>{'p' => 'Phrase', 'e' => 'Exact', 'b' => 'Broad', 'BMM' => 'Broad'};
    private final String DEVELOPER_TOKEN = 'jXfSr2Sw07PfpNzYrHva6w';
    private final String CUSTOMER_ID = '868-531-6223';
    private final String VALIDATED_STATUS = 'Underwrite';
    private final String PACK_OUT_STATUS = 'Send Advance Copy Pack';
    private final String FUNDED_STATUS = 'Paid Out';
    private String access_token;
    private static GoogleAdwordsApi instance;

    public static GoogleAdwordsApi getInstance(){
        if(instance == null){
            instance = new GoogleAdwordsApi();
        }
        return instance;
    }

    private GoogleAdwordsApi() {
        GoogleOAuth gauth = GoogleOAuth.getInstance();
        if(gauth.isAuthenticated()){
            access_token = gauth.getAccessToken();
        } else {
            throw new GoogleApiException('No authentication token found you must authenticate before using this api');
        }
    }

    public List<PerformanceReportData> getPerformanceReport(ReportType type, ReportConfig config){
        String report = sendReportRequestAndGetReportData(getQueryString(type,config));
        List<List<String>> data = Utility.parseCSV(report,false);
        List<PerformanceReportData> report_data = new List<PerformanceReportData>();
        for(List<String> row:data){
            report_data.add(new PerformanceReportData(row));
        }
        report_data = addapplicantdatatoPerformanceReport(report_data, config);
        return report_data;
    }

    private String sendReportRequestAndGetReportData(String query){
        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + access_token);
        request.setHeader('developerToken', DEVELOPER_TOKEN);
        request.setHeader('clientCustomerId', CUSTOMER_ID);
        request.setHeader('skipReportHeader', 'true');
        request.setHeader('skipColumnHeader', 'true');
        request.setHeader('skipReportSummary', 'true');
        request.setHeader('content-type', 'application/x-www-form-urlencoded');
        request.setMethod('POST');
        request.setEndpoint('https://adwords.google.com/api/adwords/reportdownload/v201502');
        request.setBody('__rdquery=' + EncodingUtil.urlEncode(query, 'utf-8') + '&__fmt=CSV');
        IHandleHttpRequests handler = HttpHandler.getHandler();
        HttpHandler.HttpHandlerResponse resp = handler.send(request);
        if(resp.IsSuccess() || resp.getHttpResponse().getStatusCode() == 200){
            return resp.getHttpResponse().getBody();
        } else {
            throw new GoogleApiException('Something went wrong sending request to google');
        }
        return null;
    }

    private String getQueryString(ReportType type, ReportConfig config){
        return 'select KeywordText, Cost, Impressions, Clicks, AverageCpc, CampaignName, KeywordMatchType, CampaignId FROM KEYWORDS_PERFORMANCE_REPORT WHERE Clicks > 0' + config.getGoogleAPIQueryString();
    }

    private List<PerformanceReportData> addapplicantdatatoPerformanceReport(List<PerformanceReportData> existing_data, ReportConfig config){
        Map<String,PerformanceReportData> data_map = new Map<String,PerformanceReportData>();
        for(PerformanceReportData d:existing_data){
            data_map.put(d.KeywordText + d.CampaignId + d.KeywordMatchType,d);
            System.debug('map key ' + d.KeywordText + d.CampaignId + d.KeywordMatchType);
        }
        List<Application__c> applications = (List<Application__c>)Database.query('Select id, Keyword__c, Match_Type__c, PPC_Campaign__c, Loan_Amount__c, Application_Value__c, (Select Stage_Name__c from Stage_Histories__r) from Application__c Where ' + config.getSalesforceQueryString());
        for(Application__c a:applications){
            String key_string = a.Keyword__c + a.PPC_Campaign__c + cleanMatchType(a.Match_Type__c);
            System.debug('key_string ' + key_string);
            if(data_map.containsKey(key_string)){
                data_map.get(key_string).ApplicationCount++;
                Set<String> completed_stages = new Set<String>();
                for(Stage_History__c sh:a.Stage_Histories__r){
                    if(!completed_stages.contains(sh.Stage_Name__c)){
                        completed_stages.add(sh.Stage_Name__c);
                    }
                }
                if(completed_stages.contains(VALIDATED_STATUS)) data_map.get(key_string).ValidatedCount++;
                if(completed_stages.contains(PACK_OUT_STATUS)){
                    data_map.get(key_string).PacksOutCount++;
                    data_map.get(key_string).PacksOutValue += a.Application_Value__c;
                }
                if(completed_stages.contains(FUNDED_STATUS)){
                    data_map.get(key_string).PaidOutCount++;
                    data_map.get(key_string).PaidOutValue += a.Application_Value__c;
                }
            }
        }
        return data_map.values();
    }

    private String cleanMatchType(String match_type){
        if(match_type_translation.containsKey(match_type)){
            return match_type_translation.get(match_type);
        } else {
            return match_type;
        }
    }

    public class ReportConfig{
        private DateRange range;
        private Date start_date;
        private Date end_date;

        public ReportConfig(DateRange range){
            this.range = range;
        }

        public Reportconfig(Date start_date, Date end_date){
            this.start_date = start_date;
            this.end_date = end_date;
        }

        public String getSalesforceQueryString(){
            String query_string = ' CreatedDate ';
            if(range == null){
                query_string += ' > ';
                query_string += Utility.getDateAsDateTime(start_date).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
                query_string += ' AND ';
                query_string += 'CreatedDate < ';
                query_string += Utility.getDateAsDateTime(end_date.addDays(1)).format('yyyy-MM-dd\'T\'hh:mm:ss\'z\'');
            } else {
                query_string += '= ';
                if(range == DateRange.TODAY || range == DateRange.YESTERDAY ||  range == DateRange.LAST_WEEK || range == DateRange.THIS_MONTH ||
                    range == DateRange.THIS_MONTH || range == DateRange.LAST_MONTH || range == DateRange.THIS_MONTH || range == DateRange.THIS_WEEK){
                    query_string += range.Name();
                } else if(range == DateRange.LAST_7_DAYS){
                    query_string += 'LAST_N_DAYS:7';
                } else if(range == DateRange.LAST_14_DAYS){
                    query_string += 'LAST_N_DAYS:14';
                } else if(range == DateRange.LAST_30_DAYS){
                    query_string += 'LAST_N_DAYS:30';
                } else {
                    throw new GoogleApiException('Invalid Date Range supplied');
                }
            }
            return query_string;
        }

        public String getGoogleAPIQueryString(){
            String query_string = ' DURING ';
            if(range == null){
                query_string += String.valueOf(start_date.year()) + getNormalizedMonthOrDayValue(start_date.month()) + getNormalizedMonthOrDayValue(start_date.day());
                query_string += ',';
                query_string += String.valueOf(end_date.year()) + getNormalizedMonthOrDayValue(end_date.month()) + getNormalizedMonthOrDayValue(end_date.day());
            } else {
                if(range == DateRange.THIS_WEEK){
                    query_string += 'THIS_WEEK_MON_TODAY';
                } else {
                    query_string += range.name();
                }
            }
            return query_string;
        }

        private String getNormalizedMonthOrDayValue(Integer value){
            if(value <= 9){
                return '0' + String.valueOf(value);
            } else {
                return String.valueOf(value);
            }
        }
    }

    public class PerformanceReportData{
        public String KeywordText {get; set;}
        public Double Cost {get; set;}
        public Long Impressions {get; set;}
        public Long Clicks {get; set;}
        public Double AverageCpc {get; set;}
        public Double CostPerImpression { get; set;}
        public Long ApplicationCount {get; set;}
        public Long ValidatedCount {get; set;}
        public Long PacksOutCount {get; set;}
        public Long PaidOutCount {get; set;}
        public Double PaidOutValue {get; set;}
        public Double PacksOutValue {get; set;}
        public String CampaignName {get; set;}
        public String KeywordMatchType {get; set;}
        public String CampaignId {get; set;}

        public PerformanceReportData(List<String> row){
            this.KeywordText = row.get(0);
            this.Cost = normalizeMoneyColumn(row.get(1));
            this.Impressions = Long.valueOf(row.get(2));
            this.Clicks = Long.valueOf(row.get(3));
            this.AverageCpc = normalizeMoneyColumn(row.get(4));
            this.CampaignName = row.get(5);
            this.KeywordMatchType = row.get(6);
            this.CampaignId = row.get(7);
            this.CostPerImpression = caclulateCostPerImpression(this.Cost, this.Impressions);
            this.ApplicationCount = 0;
            this.ValidatedCount = 0;
            this.PacksOutCount = 0;
            this.PaidOutCount = 0;
            this.PaidOutValue = 0;
            this.PacksOutValue = 0;
        }

        public Double getCostPerApplication(){
            return getCleanCostPer(ApplicationCount);
        }

        public Double getCostPerValidation(){
            return getCleanCostPer(ValidatedCount);
        }

        public Double getCostPerPackOut(){
            return getCleanCostPer(PacksOutCount);
        }

        public Double getCostPerPaidOut(){
            return getCleanCostPer(PaidOutCount);
        }

        public Double getProjectedROI(){
            return getCostPerPackOut() * CostPerImpression;
        }

        public Double getProjectedProfitAndLoss(){
            return getProjectedROI() - Cost;
        }

        public Double getProfitAndLoss(){
            return PaidOutValue - Cost;
        }

        private Double getCleanCostPer(Long count){
            if(count == 0){
                return 0;
            }
            return Cost / count;
        }

        private Double normalizeMoneyColumn(String column_value){
            Double return_value = 0;
            if(String.isBlank(column_value)){
                return return_value;
            }
            try{
                return_value = Double.valueOf(column_value);
            } catch (Exception e){
                return 0;
            }
            return return_value / 1000000;
        }

        private Double caclulateCostPerImpression(Double cost, Long impressions){
            if(cost != 0 && impressions != 0){
                return cost / impressions;
            } else {
                return cost;
            }
        }

    }

    public class GoogleApiException extends Exception{}
}