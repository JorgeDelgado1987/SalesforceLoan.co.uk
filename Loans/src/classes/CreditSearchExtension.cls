public class CreditSearchExtension {

    private static final String CCJ_PREFIX = 'ccj';
    private static final String MORTGAGE_PREFIX = 'mor';
    private static final String DEBT_PREFIX = 'deb';
    private Application__c Application;
    @TestVisible private CRSIntegration.Report CreditReport;
    public List<CCJWrapper> ReportedCCJs {get; private set;}
    public List<MortgageWrapper> ReportedMortgages {get; private set;}
    public List<DebtWrapper> ReportedDebts {get; private set;}
    public String SelectedRecordIndex {get; set;}
    private SObjectWrapper SelectedRecord;
    private List<SObjectWrapper> SelectedList;
    public Boolean DisplayCreditSearchResults {get; private set;}
    public Boolean DisplayMergeMessageCCJ {get; private set;}
    public Boolean DisplayMergeMessageMortgage {get; private set;}
    public Boolean DisplayMergeMessageDebt {get; private set;}
    public Boolean DisplayCCJ {get; private set;}
    public Boolean DisplayMortgage {get; private set;}
    public Boolean DisplayDebt {get; private set;}

    public CreditSearchExtension(ApexPages.StandardController cont){
        Application = (Application__c)cont.getRecord();
        DisplayCreditSearchResults = false;
        DisplayMergeMessageCCJ = false;
        DisplayMergeMessageMortgage = false;
        DisplayMergeMessageDebt = false;
        DisplayCCJ = false;
        DisplayMortgage = false;
        DisplayDebt = false;
    }

    public void executeCreditSearch(){
        CreditReport = CRSIntegration.getCreditReport(Application);
        if(CreditReport != null && CreditReport.isSuccess()){
            ReportedCCJs = getCCJs();
            ReportedMortgages = getMortgages();
            ReportedDebts = getDebts();
            updateApplicationWithCRSIds();
            DisplayCreditSearchResults = true;
            DisplayCCJ = !ReportedCCJs.isEmpty();
            DisplayMortgage = !ReportedMortgages.isEmpty();
            DisplayDebt = !ReportedDebts.isEmpty();
        }else if(CreditReport != null && CreditReport.hasError()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, CreditReport.Error));
        }else{
            System.debug(LoggingLevel.ERROR, 'CreditReport = ' + CreditReport);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unexpected error happened while calling CRS service.'));
        }
    }

    private List<CCJWrapper> getCCJs(){
        List<CCJWrapper> ccj_list = new List<CCJWrapper>();
        if(CreditReport.Judgements != null){
            for(CRSIntegration.Judgement reported_ccj:CreditReport.Judgements){
                if(!isIgnoredCCJ(reported_ccj)){
                    CCJ__c new_ccj_record = new CCJ__c(Application__c = Application.Id, CRS_Data__c = true);
                    new_ccj_record.Settled__c = (reported_ccj.statusField == 'SS' || reported_ccj.datesatisfiedFieldSpecified);
                    if(reported_ccj.judgmentdateFieldSpecified)
                        new_ccj_record.Judgement_Date__c = reported_ccj.judgmentdateField.date();
                    new_ccj_record.Value__c = reported_ccj.amountField;
                    ccj_list.add(new CCJWrapper(new_ccj_record, CCJ_PREFIX + ccj_list.size(), true));
                }
            }
        }
        for(CCJ__c ccj:[SELECT Id,Value__c,Settled__c,Judgement_Date__c,Creditor_Name__c,CRS_Data__c FROM CCJ__c WHERE Application__c=:Application.Id]){
            ccj_list.add(new CCJWrapper(ccj, CCJ_PREFIX + ccj_list.size(), false));
        }
        return ccj_list;
    }

    private List<MortgageWrapper> getMortgages(){
        List<MortgageWrapper> mortgage_list = new List<MortgageWrapper>();
        if(CreditReport.Accounts != null){
            for(CRSIntegration.Account reported_account:CreditReport.Accounts){
                if(reported_account.isMortgage() && !isIgnoredAccount(reported_account)){
                    Mortgage__c new_mortgage_record = new Mortgage__c(Application__c = Application.Id, CRS_Data__c = true);
                    new_mortgage_record.Arrears_in_Last_3_Months__c = reported_account.getArrearsInMonths(3);
                    new_mortgage_record.Arrears_in_Last_6_Months__c = reported_account.getArrearsInMonths(6);
                    new_mortgage_record.Arrears_in_Last_12_Months__c = reported_account.getArrearsInMonths(12);
                    new_mortgage_record.Arrears_in_Last_24_Months__c = reported_account.getArrearsInMonths(24);
                    new_mortgage_record.Arrears_in_Last_36_Months__c = reported_account.getArrearsInMonths(36);
                    new_mortgage_record.Repayment_Profile__c = reported_account.getRepaymentProfile();
                    new_mortgage_record.Current_Status__c = reported_account.getStatus();
                    new_mortgage_record.Balance__c = reported_account.accdetailsField.balanceField;
                    mortgage_list.add(new MortgageWrapper(new_mortgage_record, MORTGAGE_PREFIX + mortgage_list.size(), true));
                }
            }
        }
        for(Mortgage__c mortgare:[SELECT Id,Type__c,Term_Months__c,RepaymentType__c,On_Security_Address__c,
                                        Mortgage_Start_Date__c,Mortgage_Company__r.Name,Monthly_Repayment__c,
                                        Current_Arrears_Amount__c,Arrears_in_last_3_Months__c,Arrears_in_last_6_Months__c,
                                        Arrears_in_last_12_Months__c, Arrears_in_last_24_Months__c, Arrears_in_last_36_Months__c,
                                        Balance__c,Confirmed_Balance__c, Confirmed_Current_Arrears_Amount__c,
                                        Confirmed_Arrears_in_last_3_Months__c, Confirmed_Arrears_in_last_6_Months__c,
                                        Confirmed_Arrears_in_last_12_Months__c, Confirmed_Arrears_in_last_24_Months__c,
                                        Confirmed_Arrears_in_last_36_Months__c, Repayment_Profile__c, Current_Status__c,
                                        To_be_consolidated__c, Confirmed_Monthly_Repayment__c, CRS_Data__c
                                  FROM Mortgage__c WHERE Application__c=:Application.Id]){
                                            mortgage_list.add(new MortgageWrapper(mortgare, MORTGAGE_PREFIX + mortgage_list.size(), false));
                                        }
        return mortgage_list;
    }

    private List<DebtWrapper> getDebts(){
        List<DebtWrapper> debt_list = new List<DebtWrapper>();
        if(CreditReport.Accounts != null){
            for(CRSIntegration.Account reported_account:CreditReport.Accounts){
                if(!reported_account.isMortgage() && !isIgnoredAccount(reported_account)){
                    Debt__c new_debt_record = new Debt__c(Application__c = Application.Id, CRS_Data__c = true);
                    new_debt_record.Highest_Arrears_In_12_Months__c = reported_account.getArrearsInMonths(12);
                    new_debt_record.Highest_Arrears_In_24_Months__c = reported_account.getArrearsInMonths(24);
                    new_debt_record.Current_Status__c = reported_account.getStatus();
                    new_debt_record.Amount_Outstanding__c = reported_account.accdetailsField.balanceField;
                    new_debt_record.Account_Type__c = reported_account.accdetailsField.getAccountTypeString();
                    new_debt_record.Monthly_Repayment__c = reported_account.monthlyRepaymentAmount();
                    new_debt_record.Repayment_Profile__c = reported_account.getRepaymentProfile();
                    if(reported_account.defaultField != null && reported_account.defaultField.defdateFieldSpecified){
                        new_debt_record.Default_Date__c = reported_account.defaultField.defdateField.date();
                    }
                    if(reported_account.accdetailsField.dateupdateFieldSpecified == true){
                        new_debt_record.Last_Updated_Date__c = reported_account.accdetailsField.dateupdateField.date();
                    }
                    if(reported_account.accdetailsField.accenddatefieldspecified == true){
                        new_debt_record.Settled_Date__c = reported_account.accdetailsField.accenddateField.date();
                    }
                    debt_list.add(new DebtWrapper(new_debt_record, DEBT_PREFIX + debt_list.size(), true));
                }
            }
        }
        for(Debt__c debt:[SELECT Id,To_be_consolidated__c,Monthly_Repayment__c,Date_Account_Opened__c,
                                Amount_Outstanding__c,Creditor__r.Name,Account_Number__c, Repayment_Profile__c,
                                Current_Status__c, Highest_Arrears_In_12_Months__c, Highest_Arrears_In_24_Months__c,
                                Account_Type__c, Default_Date__c, Last_Updated_Date__c, Settled_Date__c, CRS_Data__c
                          FROM Debt__c WHERE Application__c=:Application.Id]){
                                debt_list.add(new DebtWrapper(debt, DEBT_PREFIX + debt_list.size(), false));
                          }

        return debt_list;
    }

    private static Boolean isIgnoredAccount(CRSIntegration.Account reported_account){
        String acc_status = reported_account.getStatus();
        Boolean is_settled_or_satisfied = (acc_status == 'Settled' || acc_status == 'Satisfied');
        Boolean is_settled_date_more_than_60_months_ago = (System.now() > reported_account.accdetailsField.accenddateField.addMonths(60));
        Boolean is_default = (acc_status == 'Default');
        Boolean is_older_than_60_months = (System.now() > reported_account.accdetailsField.accstartdateField.addMonths(60));
        return (is_settled_or_satisfied && is_settled_date_more_than_60_months_ago || is_default && is_older_than_60_months);
    }

    private static Boolean isIgnoredCCJ(CRSIntegration.Judgement reported_ccj){
        return (System.now() > reported_ccj.judgmentdateField.addMonths(60));
    }

    private void updateApplicationWithCRSIds(){
        Application.CRS_Report_Id__c = CreditReport.Id;
        Application.CRS_Originating_Report_Id__c = CreditReport.OriginatingReportId;
        update Application;
    }

    public void insertSelectedSObject(){
        String prefix = SelectedRecordIndex.substring(0, 3);
        List<SObjectWrapper> list_with_record_to_insert;
        if(prefix == CCJ_PREFIX){
            list_with_record_to_insert = ReportedCCJs;
        }else if(prefix == MORTGAGE_PREFIX){
            list_with_record_to_insert = ReportedMortgages;
        }else if(prefix == DEBT_PREFIX){
            list_with_record_to_insert = ReportedDebts;
        }
        for(SObjectWrapper wrapper:list_with_record_to_insert){
            if(wrapper.UniqueIndex == SelectedRecordIndex){
                wrapper.insertRecord();
                break;
            }
        }
    }

    public void showMergeUIForSelectedSObject(){
        String prefix = SelectedRecordIndex.substring(0, 3);
        if(prefix == CCJ_PREFIX){
            SelectedList = ReportedCCJs;
            DisplayMergeMessageCCJ = true;
        }else if(prefix == MORTGAGE_PREFIX){
            SelectedList = ReportedMortgages;
            DisplayMergeMessageMortgage = true;
        }else if(prefix == DEBT_PREFIX){
            SelectedList = ReportedDebts;
            DisplayMergeMessageDebt = true;
        }
        for(SObjectWrapper wrapper:SelectedList){
            if(wrapper.UniqueIndex == SelectedRecordIndex){
                wrapper.IsMerging = true;
                SelectedRecord = wrapper;
                break;
            }
        }
    }

    public void confirmMerge(){
        SObjectWrapper record_to_ovewrite;
        for(SObjectWrapper wrapper:SelectedList){
            if(wrapper.IsSelectedForMerge){
                record_to_ovewrite = wrapper;
                break;
            }
        }
        if(record_to_ovewrite != null){
            SelectedRecord.Record.Id = record_to_ovewrite.Record.Id;
            update SelectedRecord.Record;
            SelectedRecord.IsMerged = true;
            SelectedRecord.IsMerging = false;
            record_to_ovewrite.IsSelectedForMerge = false;
            record_to_ovewrite.Record = SelectedRecord.Record;
            DisplayMergeMessageCCJ = false;
            DisplayMergeMessageMortgage = false;
            DisplayMergeMessageDebt = false;
        }
    }

    public void cancelMerge(){
        SelectedRecord.IsMerging = false;
        SelectedRecord = null;
        DisplayMergeMessageCCJ = false;
        DisplayMergeMessageMortgage = false;
        DisplayMergeMessageDebt = false;
    }

    public void insertAllSelectedRecords(){
        List<SObject> records_to_insert = new List<SObject>();
        for(CCJWrapper w:ReportedCCJs){
            if(w.IsSelectedForInsertion){
                w.IsSelectedForInsertion = false;
                records_to_insert.add(w.Record);
            }
        }
        for(MortgageWrapper w:ReportedMortgages){
            if(w.IsSelectedForInsertion){
                w.IsSelectedForInsertion = false;
                records_to_insert.add(w.Record);
            }
        }
        for(DebtWrapper w:ReportedDebts){
            if(w.IsSelectedForInsertion){
                w.IsSelectedForInsertion = false;
                records_to_insert.add(w.Record);
            }
        }
        insert records_to_insert;
    }

    private virtual class SObjectWrapper{
        protected SObject Record;
        public String UniqueIndex {get; private set;}
        public Boolean IsCreditSearchData {get; set;}
        public Boolean IsMerged {get; set;}
        public Boolean IsMerging {get; set;}
        public Boolean IsSelectedForMerge {get; set;}
        public Boolean IsSelectedForInsertion {get; set;}

        public SObjectWrapper(SObject record, String index, Boolean is_credit_search_data){
            this.Record = record;
            this.UniqueIndex = index;
            this.IsCreditSearchData = is_credit_search_data;
            this.IsMerged = false;
            this.IsMerging = false;
            this.IsSelectedForMerge = false;
            this.IsSelectedForInsertion = false;
        }

        public void insertRecord(){
            insert Record;
        }
    }

    private class CCJWrapper extends SObjectWrapper{
        public CCJWrapper(SObject record, String index, Boolean is_credit_search_data){
            super(record, index, is_credit_search_data);
        }

        public CCJ__c getRecord(){
            return (CCJ__c) this.Record;
        }
    }

    private class MortgageWrapper extends SObjectWrapper{
        public MortgageWrapper(SObject record, String index, Boolean is_credit_search_data){
            super(record, index, is_credit_search_data);
        }

        public Mortgage__c getRecord(){
            return (Mortgage__c) this.Record;
        }
    }

    private class DebtWrapper extends SObjectWrapper{
        public DebtWrapper(SObject record, String index, Boolean is_credit_search_data){
            super(record, index, is_credit_search_data);
        }

        public Debt__c getRecord(){
            return (Debt__c) this.Record;
        }
    }
}