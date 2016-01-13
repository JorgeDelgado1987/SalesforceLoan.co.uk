public class Underwriting_wizard {

/////////////////////////////////////////////////////////
//                                                     //
//  15/10/2014 - Simon Parker ++                       //
//  Submits Application to Decision Engine             //
//  and create Quote                                   //
/////////////////////////////////////////////////////////

// 15/12/2014 - modified to use Lender Plan Rates - SRP
// 02/01/2015 - modified to catch 10+ for Years in Employment - SRP
// 02/01/2015 - modified to get details from credit report service - EON
// 05/01/2015 - Modified to work off LenderPlanRate - SRP
// 09/01/2015  - temp fix for > 1000 failed plans
// 12/01/2015 - SEC 210,212, 213 changed to UI tables and class
// 14/01/2015 - Added additional fields to match with c# models

    public PlanDisplay PassedPlans { get; private set;}
    public PlanDisplay ManualReferralPlans { get; private set; }
    public PlanDisplay FailedPlans { get; private set; }
    public DecisionEngineIntegration.ResultSummary Summary { get; private set; }

    private DecisionEngineResult Decision;
    private Application__c ApplicationRecord;

    public Underwriting_wizard(ApexPages.StandardController standard_controller) {
        this.ApplicationRecord = (Application__c)standard_controller.getRecord();
    }

    public PageReference submitToDecisionEngine(){
        if(dataIsValidForSubmission()){
            Decision = DecisionEngineIntegration.getDecision(ApplicationRecord);
            if(Decision.hasErrors()){
                for(String error_string:Decision.getErrors()){
                    Utility.addErrorMessage(error_string);
                }
            } else {
                PassedPlans = new PlanDisplay(Decision.getPassedPlans(),ApplicationRecord);
                ManualReferralPlans = new PlanDisplay(Decision.getManualReferralPlans(),ApplicationRecord);
                FailedPlans = new PlanDisplay(Decision.getAllFailed(),ApplicationRecord);
                Summary = Decision.getSummary();
            }
        }
        return null;
    }

    private Boolean dataIsValidForSubmission(){
        Boolean is_valid = true;

        if(ApplicationRecord.Loan_Amount__c == null || ApplicationRecord.Loan_Amount__c == 0){
            Utility.addErrorMessage('Unable to Submit to Decision Engine, Loan Amount is 0 or Blank');
            is_valid = false;
        }

        Double confirmed_value = 0;
        Double estimated_value = 0;
        for(Property__c p:[Select Id, Security_Address__c, Confirmed_Valuation__c, Estimated_Value__c from Property__c where Application__c=:ApplicationRecord.Id And Security_Address__c = true ]){
            if(p.Confirmed_Valuation__c != null){
                confirmed_value += p.Confirmed_Valuation__c;
            }
            if(p.Estimated_Value__c != null){
                estimated_value += p.Estimated_Value__c;
            }
        }

        if(confirmed_value == 0 && estimated_value == 0){
            Utility.addErrorMessage('Unable to Submit to Decision Engine, Security Property Value is not Greater than 0');
            is_valid = false;
        }

        return is_valid;
    }

    public Boolean getShowResults(){
        return (Decision != null && Decision.hasErrors() == false);
    }

    public Boolean getHasActiveQuote(){
        return getExistingActiveQuote() != null;
    }

    public Quote__c getExistingActiveQuote(){
        Quote__c active_quote;
        for(Quote__c q:[Select Id, Name, Lender_Fee__r.Is_Integrated__c, Active__c from Quote__c Where Application__c=:ApplicationRecord.Id AND Active__c=true]){
            active_quote = q;
            break;
        }
        return active_quote;
    }

    public PageReference goToCreditSearch(){
        PageReference page_ref = Page.CreditSearch;
        page_ref.getParameters().put('id', ApplicationRecord.Id);
        return page_ref;
    }

    public PageReference goToLenderSubmission(){
        PageReference page_ref = Page.LenderSubmission;
        page_ref.getParameters().put('id', ApplicationRecord.Id);
        return page_ref;
    }

    public class PlanDisplay{
        public String SelectedLender { get; set; }
        public List<PlanRow> Plans {get; private set; }
        public List<SelectOption> LenderOptions {get; private set;}

        private List<DecisionEngineResult.PlanDetail> all_plans;
        private final Application__c APPLICATION;

        private PlanDisplay(List<DecisionEngineResult.PlanDetail> plan_results, Application__c application){
            this.all_plans = plan_results;
            this.APPLICATION = application;
            setPlanRows(all_plans);
            setOptions(all_plans);
        }

        private void setOptions(List<DecisionEngineResult.PlanDetail> plan_results){
            Set<String> already_included_values = new Set<String>();
            LenderOptions = new List<SelectOption>();
            LenderOptions.add(new SelectOption('none','---none---'));
            for(DecisionEngineResult.PlanDetail pr:plan_results){
                if(!already_included_values.contains(pr.getLenderName())){
                    already_included_values.add(pr.getLenderName());
                    LenderOptions.add(new SelectOption(pr.getLenderName(), pr.getLenderName()));
                }
            }
        }

        private void setPlanRows(List<DecisionEngineResult.PlanDetail> plan_results){
            Plans = new List<PlanRow>();
            for(DecisionEngineResult.PlanDetail pd:plan_results){
                Plans.add(new PlanRow(pd, APPLICATION));
            }
        }

        public PageReference filterRows(){
            if(SelectedLender == null || SelectedLender == 'none'){
                setPlanRows(all_plans);
            } else {
                List<DecisionEngineResult.PlanDetail> filtered_plans = new List<DecisionEngineResult.PlanDetail>();
                for(DecisionEngineResult.PlanDetail pd:all_plans){
                    if(pd.getLenderName() == SelectedLender){
                        filtered_plans.add(pd);
                    }
                }
                setPlanRows(filtered_plans);
            }
            return null;
        }

    }

    public class PlanRow{
        public DecisionEngineResult.PlanDetail RowDetail { get; private set; }
        private final Application__c APPLICATION;

        private PlanRow(DecisionEngineResult.PlanDetail plan_detail, Application__c application){
            this.RowDetail = plan_detail;
            this.APPLICATION = application;
        }

        public PageReference createQuote(){
           try{
                Lender_Plan_Rate__c selected_plan_rate = getSelectedLenderPlanRate(RowDetail.getPlanRateId());
                Quote__c quote = QuoteBuilder.getBuilder(APPLICATION)
                                                .setBrokerFee(APPLICATION.Broker_Fee__c)
                                                .setLender(RowDetail.getLenderId())
                                                .setLenderPlan(RowDetail.getPlanId())
                                                .setLenderPlanRate(RowDetail.getPlanRateId())
                                                .setMonthlyRepayment(RowDetail.getMonthlyPaymentEstimate())
                                                //.setCommission(RowDetail.getCommissionAmount())
                                                .setApr(RowDetail.getApr())
                                                .setLenderFee(selected_plan_rate.Lender_Fee__c)
                                                .setTTFee(selected_plan_rate.TT_Fee__c)
                                                .setSolicitorsCosts(selected_plan_rate.Solicitors_Costs__c)
                                                .setTitleInsurance(selected_plan_rate.Title_Insurance__c)
                                                .setInterestRate(selected_plan_rate.Rate__c)
                                                .save()
                                                .getRecord();
            } catch (Exception e) {
                Utility.addErrorMessage('An Error Occurred Inserting Quote: ' + e.getMessage() + '. Stacktrace: ' + e.getStackTraceString());
                return null;
            }
            Utility.addConfirmMessage('New Quote successfully created.');
            return null;
        }

        private Lender_Plan_Rate__c getSelectedLenderPlanRate(Id lender_plan_id){
            if(lender_plan_id != null){
                List<Lender_Plan_Rate__c> lpr = [Select Id, Lender_Fee__c, Lender_Name__c, Rate__c, TT_Fee__c, Title_Insurance__c, Solicitors_Costs__c
                                            From Lender_Plan_Rate__c where Id=:lender_plan_id ];
                if(lpr.size() > 1){
                    throw new UnderWritingException('Multiple Plan Rates found for Lender Plan Rate Id ' + lender_plan_id);
                }

                if(lpr.isEmpty()){
                    throw new UnderWritingException('No Lender Plan Found in Salesforce for Selected Plan Id ' + lender_plan_id);
                }

                return lpr.get(0);
            }else{
                //Should throw something here instead of returning null!
            }
            return null;
        }
    }

    public class UnderWritingException extends Exception{}

 }