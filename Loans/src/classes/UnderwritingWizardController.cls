public class UnderwritingWizardController {
    public DecisionEngineIntegration.ResultSummaryV1 Summary { get; private set; }
    public PlanDisplay PassedPlans { get; private set; }
    public PlanDisplay ManualReferralPlans { get; private set; }
    public PlanDisplay DownSellPlans { get; private set; }
    public PlanDisplay FailedPlans { get; private set; }


    private DecisionEngineIntegration.DecisionResult Decision;
    private Application__c ApplicationRecord;
    private String DecisionApplicationId;
    private RatesDisplay SelectedPlanRates;

    public UnderwritingWizardController(ApexPages.StandardController standard_controller) {
        this.ApplicationRecord = (Application__c)standard_controller.getRecord();
    }

    public PageReference submitToDecisionEngine(){
        if(dataIsValidForSubmission()){
            try{
                Decision = DecisionEngineIntegration.getBaseDecision(ApplicationRecord);
                System.debug(LoggingLevel.ERROR, 'Decision = ' + Decision);
                if(Decision.hasErrors()){
                    for(String error_string:Decision.Errors){
                        Utility.addErrorMessage(error_string);
                    }
                } else {
                    PassedPlans = new PlanDisplay(Decision.PassedPlans, true);
                    ManualReferralPlans = new PlanDisplay(Decision.ManualReferralPlans);
                    DownSellPlans = new PlanDisplay(Decision.DownSellPlans);
                    FailedPlans = new PlanDisplay(Decision.FailedPlans);
                    Summary = Decision.Summary;
                    DecisionApplicationId = Decision.Id;
                }
            } catch (Exception e) {
                Utility.addErrorMessage('Something\'s gone wrong... ' + e.getMessage());
            }
        }
        return null;
    }

    private Boolean dataIsValidForSubmission(){
        if(ApplicationRecord.Loan_Amount__c == null || ApplicationRecord.Loan_Amount__c == 0){
            Utility.addErrorMessage('Unable to Submit to Decision Engine, Loan Amount is 0 or Blank');
            return false;
        }

        if(ApplicationRecord.Loan_Term_Months__c == null || ApplicationRecord.Loan_Term_Months__c == 0){
            Utility.addErrorMessage('Unable to Submit to Decision Engine, Loan Term is 0 or Blank');
            return false;
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
            return false;
        }
        return true;
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

    public RatesDisplay getRates(){
        String selected_plan = ApexPages.CurrentPage().getParameters().get('selected_plan');
        System.debug(selected_plan);
        try{
            if(selected_plan != null){
                List<DecisionEngineIntegration.PlanRateDetail> rate_details = DecisionEngineIntegration.getRates(DecisionApplicationId, selected_plan);
                SelectedPlanRates = new RatesDisplay(getSelectedPlan(selected_plan), rate_details);
            }
        }catch (Exception e) {
            Utility.addErrorMessage('Somethings gone Wrong... ' + e.getMessage());
        }
        return SelectedPlanRates;
    }

    private PlanRow getSelectedPlan(String plan_id){
        for(PlanRow row:PassedPlans.Plans){
            if(row.getPlanId() == plan_id){
                return row;
            }
        }
        for(PlanRow row:ManualReferralPlans.Plans){
            if(row.getPlanId() == plan_id){
                return row;
            }
        }
        for(PlanRow row:DownSellPlans.Plans){
            if(row.getPlanId() == plan_id){
                return row;
            }
        }
        return null;
    }

    public PageReference createMultipleQuotes(){
        for(PlanRow plan:PassedPlans.Plans){
            if(plan.IsSelected){
                DecisionEngineIntegration.PlanRateDetail plan_rate_detail = new DecisionEngineIntegration.PlanRateDetail(plan.getPlanRate());
                DecisionEngineIntegration.RepaymentOptionDetail repayment_option_detail = new DecisionEngineIntegration.RepaymentOptionDetail(plan.getRepaymentOption());
                createSingleQuote(new RateRow(plan, plan_rate_detail, repayment_option_detail));
            }
        }
        return null;
    }

    public PageReference createQuote(){
        return createSingleQuote(SelectedPlanRates.getSelectedRateRow());
    }

    private PageReference createSingleQuote(RateRow selected_row){
       try{
            Lender_Plan_Rate__c selected_plan_rate = getSelectedLenderPlanRate(selected_row.getPlanRateId());
            //FOR TESTING!!!
            //Lender_Plan_Rate__c selected_plan_rate = getSelectedLenderPlanRate('a0gJ0000004fYlK');

            Quote__c quote = QuoteBuilder.getBuilder(ApplicationRecord)
                                            .setBrokerFee(ApplicationRecord.Broker_Fee__c)
                                            .setLender(selected_row.getLenderId())
                                            .setLenderPlan(selected_row.getPlanId())
                                            .setLenderPlanRate(selected_row.getPlanRateId())
                                            //FOR TESTING!!!
                                            //.setLender('a0GJ000000G3U70')
                                            //.setLenderPlan('a0FJ0000005g5a1')
                                            //.setLenderPlanRate('a0gJ0000004fYlK')

                                            .setLenderFee(selected_plan_rate.Lender_Fee__c)
                                            .setTTFee(selected_plan_rate.TT_Fee__c)
                                            .setSolicitorsCosts(selected_plan_rate.Solicitors_Costs__c)
                                            .setTitleInsurance(selected_plan_rate.Title_Insurance__c)
                                            .setInterestRate(selected_plan_rate.Rate__c)
                                            //.setCommission(RowDetail.getCommissionAmount())
                                            .setMaxLtv(selected_row.getMaxLtv())
                                            .setLtv(selected_row.getLtv())
                                            .setMonthlyRate(selected_row.getMonthlyRate())
                                            .setAnnualEquivalentRate(selected_row.getAnnualEquivalentRate())
                                            .setDailyRate(selected_row.getDailyRate())
                                            .setRepaymentType(selected_row.getPaymentType())
                                            .setMonthlyRepayment(selected_row.getMonthlyPaymentEstimate())
                                            .setDti(selected_row.getDti())
                                            .setApr(selected_row.getApr())
                                            .setOneFourthRedemption(selected_row.getOneFourthRedemption())
                                            .setTwoFourthRedemption(selected_row.getTwoFourthRedemption())
                                            .setThreeFourthRedemption(selected_row.getThreeFourthRedemption())
                                            .setTotalRepayable(selected_row.getTotalRepayable())
                                            .setTotalInterest(selected_row.getTotalInterest())
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
        }
        throw new UnderWritingException('No Lender Plan Provided');
        return null;
    }

    public class PlanDisplay{
        public String SelectedLender {get; set;}
        public List<PlanRow> Plans {get; private set;}
        public List<SelectOption> LenderOptions {get; private set;}
        public Boolean DisplayBestPlanOnly {get; set;}

        private List<DecisionEngineIntegration.BasePlan> all_plans;
        private final String NONE_SELECTED = 'none';

        @TestVisible
        private PlanDisplay(List<DecisionEngineIntegration.BasePlan> plans){
            this(plans, false);
        }

        @TestVisible
        private PlanDisplay(List<DecisionEngineIntegration.BasePlan> plans, Boolean display_best_plan_only){
            this.all_plans = plans;
            DisplayBestPlanOnly = display_best_plan_only;
            setPlanRows(all_plans);
            LenderOptions = getLenderOptions(all_plans);
        }

        private List<SelectOption> getLenderOptions(List<DecisionEngineIntegration.BasePlan> plan_results){
            Set<String> already_included_values = new Set<String>();
            List<SelectOption> lender_options = new List<SelectOption>();
            lender_options.add(new SelectOption(NONE_SELECTED,'---none---'));
            for(DecisionEngineIntegration.BasePlan plan:plan_results){
                if(!already_included_values.contains(plan.LenderName)){
                    already_included_values.add(plan.LenderName);
                    lender_options.add(new SelectOption(plan.LenderName, plan.LenderName));
                }
            }
            return lender_options;
        }

        private void setPlanRows(List<DecisionEngineIntegration.BasePlan> plan_results){
            Plans = new List<PlanRow>();
            if(DisplayBestPlanOnly){
                Plans.addAll(getBestPlanForEveryLender(plan_results));
            }else{
                for(DecisionEngineIntegration.BasePlan plan:plan_results){
                    Plans.add(new PlanRow(plan));
                }
            }
        }

        @TestVisible
        private List<PlanRow> getBestPlanForEveryLender(List<DecisionEngineIntegration.BasePlan> plan_results){
            Map<Id, PlanRow> best_plans_by_lender = new Map<Id, PlanRow>();
            for(DecisionEngineIntegration.BasePlan plan:plan_results){
                PlanRow current_plan = new PlanRow(plan);
                if(best_plans_by_lender.containsKey(current_plan.getLenderId())){
                    PlanRow plan_from_map = best_plans_by_lender.get(current_plan.getLenderId());
                    if(current_plan.getRate() < plan_from_map.getRate()){
                        best_plans_by_lender.put(current_plan.getLenderId(), current_plan);
                    }
                }else{
                    best_plans_by_lender.put(current_plan.getLenderId(), current_plan);
                }
            }
            return best_plans_by_lender.values();
        }

        public PageReference filterRows(){
            if(SelectedLender == null || SelectedLender == NONE_SELECTED){
                setPlanRows(all_plans);
            } else {
                List<DecisionEngineIntegration.BasePlan> filtered_plans = new List<DecisionEngineIntegration.BasePlan>();
                for(DecisionEngineIntegration.BasePlan plan:all_plans){
                    if(plan.LenderName == SelectedLender){
                        filtered_plans.add(plan);
                    }
                }
                setPlanRows(filtered_plans);
            }
            return null;
        }

    }

    public class PlanRow{
        private final DecisionEngineIntegration.BasePlan PLAN;
        private final Boolean IS_FAILED_PLAN;
        public Boolean IsSelected {get; set;}

        @TestVisible
        private PlanRow(DecisionEngineIntegration.BasePlan plan){
            this.PLAN = plan;
            this.IS_FAILED_PLAN = PLAN instanceOf DecisionEngineIntegration.FailedPlan;
        }

        public Id getLenderId(){
            if(PLAN.SfLenderId != null){
                return PLAN.SfLenderId;
            }
            return null;
        }

        public Id getPlanId(){
            if(PLAN.SfPlanId != null){
                return PLAN.SfPlanId;
            }
            return null;
        }

        public String getLenderName(){
            if(PLAN.LenderName != null){
                return PLAN.LenderName;
            }
            return 'Unknown Lender';
        }

        public String getPlanName(){
            if(PLAN.PlanName != null){
                return PLAN.PlanName;
            }
            return 'Plan Name Not Provided';
        }

       public Double getPlanCommission(){
            if(!IS_FAILED_PLAN){
                DecisionEngineIntegration.Plan this_plan = (DecisionEngineIntegration.Plan)PLAN;
                if(this_plan.PlanCommission != null){
                    return this_plan.PlanCommission;
                }
            }
            return 0;
        }

        private Boolean hasPlanRate(){
            return getPlanRate() != null;
        }

        private DecisionEngineIntegration.PlanRate getPlanRate(){
            if(!IS_FAILED_PLAN){
                DecisionEngineIntegration.Plan this_plan = (DecisionEngineIntegration.Plan)PLAN;
                if(this_plan.BestRate != null){
                    return this_plan.BestRate;
                }
            }
            return null;
        }

        public Id getPlanRateId(){
            if(hasPlanRate()){
                if(getPlanRate().SfPlanRateId != null){
                    return getPlanRate().SfPlanRateId;
                }
            }
            return null;
        }

        public Double getRate(){
            if(hasPlanRate()){
                if(getPlanRate().Rate != null){
                    return getPlanRate().Rate;
                }
            }
            return 0;
        }

        public String getRateType(){
            if(hasPlanRate()){
                if(getPlanRate().RateType != null){
                    return getPlanRate().RateType;
                }
            }
            return 'Not Provided';
        }

        public Double getLenderFee(){
            if(hasPlanRate()){
                if(getPlanRate().LenderFee != null){
                    return getPlanRate().LenderFee;
                }
            }
            return 0;
        }

        public Double getMaxLtv(){
            if(hasPlanRate()){
                if(getPlanRate().MaxLtv != null){
                    return getPlanRate().MaxLtv;
                }
            }
            return 0;
       }

        public Double getLtv(){
            if(hasPlanRate()){
                if(getPlanRate().Ltv != null){
                    return getPlanRate().Ltv;
                }
            }
            return 0;
        }

        public Double getMonthlyRate(){
            if(hasPlanRate()){
                if(getPlanRate().MonthlyRate != null){
                    return getPlanRate().MonthlyRate;
                }
            }
            return 0;
        }

        public Double getAnnualEquivalentRate(){
            if(hasPlanRate()){
                if(getPlanRate().AnnualEquivalentRate != null){
                    return getPlanRate().AnnualEquivalentRate;
                }
            }
            return 0;
        }

        public Double getDailyRate(){
            if(hasPlanRate()){
                if(getPlanRate().DailyRate != null){
                    return getPlanRate().DailyRate;
                }
            }
            return 0;
        }

        private boolean hasRepaymentOption(){
            return hasPlanRate() && getPlanRate().BestRepaymentOption != null;
        }

        private DecisionEngineIntegration.RepaymentOption getRepaymentOption(){
            if(hasRepaymentOption()){
                return getPlanRate().BestRepaymentOption;
            }
            return null;
        }


        public String getPaymentType(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().RepaymentType != null){
                    return getRepaymentOption().RepaymentType;
                }
            }
            return 'Not Provided';
        }

        public Double getMonthlyPaymentEstimate(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().MonthlyPaymentEstimate != null){
                    return getRepaymentOption().MonthlyPaymentEstimate;
                }
            }
            return 0;
        }

        public Double getDti(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().Dti != null){
                    return getRepaymentOption().Dti;
                }
            }
            return 0;
        }

        public Double getApr(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().Apr != null){
                    return getRepaymentOption().Apr;
                }
            }
            return 0;
        }

        public Double getOneFourthRedemption(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().OneFourthRedemption != null){
                    return getRepaymentOption().OneFourthRedemption;
                }
            }
            return 0;
        }

        public Double getTwoFourthRedemption(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().TwoFourthRedemption != null){
                    return getRepaymentOption().TwoFourthRedemption;
                }
            }
            return 0;
        }

        public Double getThreeFourthRedemption(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().ThreeFourthRedemption != null){
                    return getRepaymentOption().ThreeFourthRedemption;
                }
            }
            return 0;
        }

        public Double getTotalRepayable(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().TotalRepayable != null){
                    return getRepaymentOption().TotalRepayable;
                }
            }
            return 0;
        }

        public Double getTotalInterest(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().TotalInterest != null){
                    return getRepaymentOption().TotalInterest;
                }
            }
            return 0;
        }

        public Double getMaxAvailableLoanAmount(){
            if(hasRepaymentOption()){
                if(getRepaymentOption().MaxAvailableLoanAmount != null){
                    return getRepaymentOption().MaxAvailableLoanAmount;
                }
            }
            return 0;
        }

        public String getFormattedFailures(){
            Map<String,Set<String>> all_reasons = new Map<String,Set<String>>();
            if(PLAN.Reasons != null){
                all_reasons = DecisionEngine_Utility.mergeReasonsMap(PLAN.Reasons, all_reasons);
            }
            if(hasPlanRate() && getPlanRate().Reasons != null){
                all_reasons = DecisionEngine_Utility.mergeReasonsMap(getPlanRate().Reasons, all_reasons);
            }
            if(hasRepaymentOption() && getRepaymentOption().Reasons != null){
                all_reasons = DecisionEngine_Utility.mergeReasonsMap(getRepaymentOption().Reasons, all_reasons);
            }
            return DecisionEngine_Utility.formatReasonsToHtml(all_reasons);
        }

        public PageReference selectPlan(){
            ApexPages.CurrentPage().getParameters().put('selected_plan', getPlanId());
            return null;
        }

    }

    public class RatesDisplay{
        public List<RateRow> Rows { get { return id_to_rate_rows.values();} }
        public String PlanName { get; private set;}
        public String LenderName { get; private set;}

        private Map<Id,RateRow> id_to_rate_rows;

        public RatesDisplay(PlanRow plan, List<DecisionEngineIntegration.PlanRateDetail> rates){
            LenderName = plan.getLenderName();
            PlanName = plan.getPlanName();
            id_to_rate_rows = new Map<Id,RateRow>();
            for(DecisionEngineIntegration.PlanRateDetail plan_rate_detail:rates){
                if(plan_rate_detail.RepaymentOptions != null && plan_rate_detail.RepaymentOptions.size() > 0){
                    for(DecisionEngineIntegration.RepaymentOptionDetail repayment_option_detail:plan_rate_detail.RepaymentOptions){
                        id_to_rate_rows.put(plan_rate_detail.SfPlanRateId, new RateRow(plan, plan_rate_detail, repayment_option_detail));
                    }
                } else {
                    id_to_rate_rows.put(plan_rate_detail.SfPlanRateId, new RateRow(plan, plan_rate_detail));
                }
            }

        }

        private RateRow getSelectedRateRow(){
            for(RateRow row:id_to_rate_rows.values()){
                if(row.Selected){
                    return row;
                }
            }
            throw new UnderWritingException('No Selected Rate Found');
            return null;
        }

        public Boolean getHasRows(){
            return id_to_rate_rows != null && id_to_rate_rows.size() > 0;
        }

    }

    public class RateRow{
        private final PlanRow PLAN;
        private final DecisionEngineIntegration.PlanRateDetail PLAN_RATE;
        private final DecisionEngineIntegration.RepaymentOptionDetail REPAYMENT_OPTION;

        private Boolean has_repayment_option = true;

        public Boolean Selected { get; private set;}

        public RateRow(PlanRow plan, DecisionEngineIntegration.PlanRateDetail plan_rate_detail, DecisionEngineIntegration.RepaymentOptionDetail repayment_option_detail){
            if(repayment_option_detail == null){
                has_repayment_option = false;
            } else {
                this.REPAYMENT_OPTION = repayment_option_detail;
            }
            this.PLAN = plan;
            this.PLAN_RATE = plan_rate_detail;
            this.Selected = false;
        }



        public RateRow(PlanRow plan, DecisionEngineIntegration.PlanRateDetail plan_rate_detail){
            this(plan,plan_rate_detail,null);
        }

        public PageReference selectRate(){
            this.Selected = true;
            return null;
        }

        public String getRateStatus(){
            if(PLAN_RATE.Failed == true){
                return 'Failed';
            }
            if(PLAN_RATE.DownSale == true){
                return 'Down Sale';
            }
            if(PLAN_RATE.ManualReferral == true){
                return 'Manual Referral';
            }
            return 'Success';
        }

        public Boolean getIsFaied(){
            return PLAN_RATE.Failed;
        }

        public Boolean getIsManualReferral(){
            return PLAN_RATE.ManualReferral;
        }

        public Boolean getIsDownSale(){
            return PLAN_RATE.DownSale;
        }

        public Boolean getIsSuccess(){
            return !getIsFaied() && !getIsDownSale() && !getIsManualReferral();
        }

        public Id getLenderId(){
            return PLAN.getLenderId();
        }

        public Id getPlanId(){
            return PLAN.getPlanId();
        }

        public String getLenderName(){
            return PLAN.getLenderName();
        }

        public String getPlanName(){
            return PLAN.getPlanName();
        }

       public Double getPlanCommission(){
            return PLAN.getPlanCommission();
        }

        public Id getPlanRateId(){
            if(PLAN_RATE.SfPlanRateId != null){
                return PLAN_RATE.SfPlanRateId;
            }
            return null;
        }

        public Double getRate(){
            if(PLAN_RATE.Rate != null){
                return PLAN_RATE.Rate;
            }
            return 0;
        }

        public String getRateType(){
            if(PLAN_RATE.RateType != null){
                return PLAN_RATE.RateType;
            }
            return 'Not Provided';
        }

        public Double getLenderFee(){
            if(PLAN_RATE.LenderFee != null){
                return PLAN_RATE.LenderFee;
            }
            return 0;
        }

        public Double getMaxLtv(){
            if(PLAN_RATE.MaxLtv != null){
                return PLAN_RATE.MaxLtv;
            }
            return 0;
       }

        public Double getLtv(){
            if(PLAN_RATE.Ltv != null){
                return PLAN_RATE.Ltv;
            }
            return 0;
        }

        public Double getMonthlyRate(){
            if(PLAN_RATE.MonthlyRate != null){
                return PLAN_RATE.MonthlyRate;
            }
            return 0;
        }

        public Double getAnnualEquivalentRate(){
            if(PLAN_RATE.AnnualEquivalentRate != null){
                return PLAN_RATE.AnnualEquivalentRate;
            }
            return 0;
        }

        public Double getDailyRate(){
            if(PLAN_RATE.DailyRate != null){
                return PLAN_RATE.DailyRate;
            }
            return 0;
        }

        public String getPaymentType(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.RepaymentType != null){
                return REPAYMENT_OPTION.RepaymentType;
            }
            return 'Not Provided';
        }

        public Double getMonthlyPaymentEstimate(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.MonthlyPaymentEstimate != null){
                return REPAYMENT_OPTION.MonthlyPaymentEstimate;
            }
            return 0;
        }

        public Double getDti(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.Dti != null){
                return REPAYMENT_OPTION.Dti;
            }
            return 0;
        }

        public Double getApr(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.Apr != null){
                return REPAYMENT_OPTION.Apr;
            }
            return 0;
        }

        public Double getOneFourthRedemption(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.OneFourthRedemption != null){
                return REPAYMENT_OPTION.OneFourthRedemption;
            }
            return 0;
        }

        public Double getTwoFourthRedemption(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.TwoFourthRedemption != null){
                return REPAYMENT_OPTION.TwoFourthRedemption;
            }
            return 0;
        }

        public Double getThreeFourthRedemption(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.ThreeFourthRedemption != null){
                return REPAYMENT_OPTION.ThreeFourthRedemption;
            }
            return 0;
        }

        public Double getTotalRepayable(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.TotalRepayable != null){
                return REPAYMENT_OPTION.TotalRepayable;
            }
            return 0;
        }

        public Double getTotalInterest(){
            if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.TotalInterest != null){
                return REPAYMENT_OPTION.TotalInterest;
            }
            return 0;
        }

        public Double getMaxAvailableLoanAmount(){
           if(REPAYMENT_OPTION != null && REPAYMENT_OPTION.MaxAvailableLoanAmount != null){
                return REPAYMENT_OPTION.MaxAvailableLoanAmount;
            }
            return 0;
        }

        public String getFormattedFailures(){
            Map<String,Set<String>> all_reasons = new Map<String,Set<String>>();
            if(REPAYMENT_OPTION.Reasons != null){
                all_reasons = DecisionEngine_Utility.mergeReasonsMap(REPAYMENT_OPTION.Reasons, all_reasons);
            }
            return DecisionEngine_Utility.formatReasonsToHtml(all_reasons);
        }

    }

    public class UnderWritingException extends Exception{}

 }