public with sharing class DecisionEngineResult {
    private final DecisionEngineIntegration.Response DE_RESPONSE;
    private final Integer MAX_LIST_SIZE = 1000;

    private DecisionEngineResult(DecisionEngineIntegration.Response response){
        this.DE_RESPONSE = response;
    }

    public static DecisionEngineResult getResult(DecisionEngineIntegration.Response response){
        return new DecisionEngineResult(response);
    }

    public List<PlanDetail> getPassedPlans(){
        return flatten(DE_RESPONSE.Passed);
    }

    public List<PlanDetail> getManualReferralPlans(){
        return flatten(DE_RESPONSE.ManualReferral);
    }

    public List<PlanDetail> getFailedPlans(){
        return flatten(DE_RESPONSE.PlanLevelFailed);
    }

    public List<PlanDetail> getFailedRates(){
        return flatten(DE_RESPONSE.RateLevelFailed);
    }

    public List<PlanDetail> getFailedRepaymentOptions(){
        return flatten(DE_RESPONSE.RepaymentOptionLevelFailed);
    }

    public List<PlanDetail> getAllFailed(){
        List<PlanDetail> all_failed = new List<PlanDetail>();
        all_failed.addAll(flatten(DE_RESPONSE.RepaymentOptionLevelFailed));
        all_failed.addAll(flatten(DE_RESPONSE.RateLevelFailed));
        all_failed.addAll(flatten(DE_RESPONSE.PlanLevelFailed));
        if(all_failed.size() <= MAX_LIST_SIZE){
            return all_failed;
        } else {
            List<PlanDetail> limited_list = new List<PlanDetail>();
            Integer i = 0;
            for(PlanDetail pd:all_failed){
                limited_list.add(pd);
                i++;
                if(i == MAX_LIST_SIZE) break;
            }
            return limited_list;
        }
    }

    public List<String> getErrors(){
        return DE_RESPONSE.Errors;
    }

    public Boolean hasErrors(){
        return getErrors() != null && getErrors().size() > 0;
    }

    public DecisionEngineIntegration.ResultSummary getSummary(){
        return DE_RESPONSE.Summary;
    }

    private List<PlanDetail> flatten(List<DecisionEngineIntegration.PlanEvaluationResponse> plans){
        List<PlanDetail> plan_details = new List<PlanDetail>();
        for(DecisionEngineIntegration.PlanEvaluationResponse plan_response:plans){
            if(plan_response.PlanRateEvaluationResponses != null){
                for(DecisionEngineIntegration.PlanRateEvaluationResponse rate_response:plan_response.PlanRateEvaluationResponses){
                    if(rate_response.RepaymentOptionEvaluationResponses != null){
                        for(DecisionEngineIntegration.RepaymentOptionEvaluationResponse repayment_response:rate_response.RepaymentOptionEvaluationResponses){
                            if(plan_details.size() < MAX_LIST_SIZE){
                                plan_details.add(new PlanDetail(plan_response, rate_response, repayment_response));
                            }
                        }
                    } else {
                        if(plan_details.size() < MAX_LIST_SIZE){
                            plan_details.add(new PlanDetail(plan_response, rate_response, null));
                        }
                    }
                }
            } else {
                if(plan_details.size() < MAX_LIST_SIZE){
                    plan_details.add(new PlanDetail(plan_response, null, null));
                }
            }
        }
        return plan_details;
    }

    public class PlanDetail{
        private final DecisionEngineIntegration.PlanEvaluationResponse PLAN_RESULT;
        private final DecisionEngineIntegration.PlanRateEvaluationResponse RATE_RESULT;
        private final DecisionEngineIntegration.RepaymentOptionEvaluationResponse REPAYMENT_RESULT;
        private String Failuretype;

        private PlanDetail(DecisionEngineIntegration.PlanEvaluationResponse plan_result, DecisionEngineIntegration.PlanRateEvaluationResponse rate_result, DecisionEngineIntegration.RepaymentOptionEvaluationResponse repayment_result){
            this.PLAN_RESULT = plan_result;
            this.RATE_RESULT = rate_result;
            this.REPAYMENT_RESULT = repayment_result;
        }

        public Id getLenderId(){
            if(PLAN_RESULT.SfLenderId != null){
                return PLAN_RESULT.SfLenderId;
            }
            return null;
        }

        public Id getPlanId(){
            if(PLAN_RESULT.SfPlanId != null){
                return PLAN_RESULT.SfPlanId;
            }
            return null;
        }

        public String getLenderName(){
            if(PLAN_RESULT.LenderName != null){
                return PLAN_RESULT.LenderName;
            }
            return 'Unknown Lender';
        }

        public String getPlanName(){
            if(PLAN_RESULT.PlanName != null){
                return PLAN_RESULT.PlanName;
            }
            return 'Plan Name Not Provided';
        }

        public Double getPlanCommission(){
            if(PLAN_RESULT.PlanCommission != null){
                return PLAN_RESULT.PlanCommission;
            }
            return 0;
        }

        public Id getPlanRateId(){
            if(RATE_RESULT != null && RATE_RESULT.SfPlanRateId != null){
                return RATE_RESULT.SfPlanRateId;
            }
            return null;
        }

        public Double getRate(){
            if(RATE_RESULT != null && RATE_RESULT.Rate != null){
                return RATE_RESULT.Rate;
            }
            return 0;
        }

        public String getRateType(){
            if(RATE_RESULT != null && RATE_RESULT.RateType != null){
                return RATE_RESULT.RateType;
            }
            return 'Not Provided';
        }

        public Double getLenderFee(){
            if(RATE_RESULT != null && RATE_RESULT.LenderFee != null){
                return RATE_RESULT.LenderFee;
            }
            return 0;
        }

        public Double getMaxLtv(){
            if(RATE_RESULT != null && RATE_RESULT.MaxLtv != null){
                return RATE_RESULT.MaxLtv;
            }
            return 0;
       }

        public Double getLtv(){
            if(RATE_RESULT != null && RATE_RESULT.Ltv != null){
                return RATE_RESULT.Ltv;
            }
            return 0;
        }

        public Double getMonthlyRate(){
            if(RATE_RESULT != null && RATE_RESULT.MonthlyRate != null){
                return RATE_RESULT.MonthlyRate;
            }
            return 0;
        }

        public Double getAnnualEquivalentRate(){
            if(RATE_RESULT != null && RATE_RESULT.AnnualEquivalentRate != null){
                return RATE_RESULT.AnnualEquivalentRate;
            }
            return 0;
        }

        public Double getDailyRate(){
            if(RATE_RESULT != null && RATE_RESULT.DailyRate != null){
                return RATE_RESULT.DailyRate;
            }
            return 0;
        }

        public String getPaymentType(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.RepaymentType != null){
                return REPAYMENT_RESULT.RepaymentType;
            }
            return 'Not Provided';
        }

        public Double getMonthlyPaymentEstimate(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.MonthlyPaymentEstimate != null){
                return REPAYMENT_RESULT.MonthlyPaymentEstimate;
            }
            return 0;
        }

        public Double getDti(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.Dti != null){
                return REPAYMENT_RESULT.Dti;
            }
            return 0;
        }

        public Double getApr(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.Apr != null){
                return REPAYMENT_RESULT.Apr;
            }
            return 0;
        }

        public Double getOneFourthRedemption(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.OneFourthRedemption != null){
                return REPAYMENT_RESULT.OneFourthRedemption;
            }
            return 0;
        }

        public Double getTwoFourthRedemption(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.TwoFourthRedemption != null){
                return REPAYMENT_RESULT.TwoFourthRedemption;
            }
            return 0;
        }

        public Double getThreeFourthRedemption(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.ThreeFourthRedemption != null){
                return REPAYMENT_RESULT.ThreeFourthRedemption;
            }
            return 0;
        }

        public Double getTotalRepayable(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.TotalRepayable != null){
                return REPAYMENT_RESULT.TotalRepayable;
            }
            return 0;
        }

        public Double getTotalInterest(){
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.TotalInterest != null){
                return REPAYMENT_RESULT.TotalInterest;
            }
            return 0;
        }

        public Double getMinAvailableLoanAmount(){
           if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.LimitForAdjustables != null && REPAYMENT_RESULT.LimitForAdjustables.MinAvailableLoanAmount != null){
                return REPAYMENT_RESULT.LimitForAdjustables.MinAvailableLoanAmount;
            }
            return 0;
        }

        public Double getMaxAvailableLoanAmount(){
           if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.LimitForAdjustables != null && REPAYMENT_RESULT.LimitForAdjustables.MaxAvailableLoanAmount != null){
                return REPAYMENT_RESULT.LimitForAdjustables.MaxAvailableLoanAmount;
            }
            return 0;
        }

        public List<String> getFailureReasons(){
            List<String> all_failed_reasons = new List<String>();
            if(PLAN_RESULT.FailureReasons != null){
                all_failed_reasons.addAll(PLAN_RESULT.FailureReasons);
            }
            if(RATE_RESULT != null && RATE_RESULT.FailureReasons != null){
                all_failed_reasons.addAll(RATE_RESULT.FailureReasons);
            }
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.FailureReasons != null){
                all_failed_reasons.addAll(REPAYMENT_RESULT.FailureReasons);
            }
            return all_failed_reasons;
        }

        public String getFailureType(){
            if(PLAN_RESULT.FailureReasons != null){
                FailureType = 'Plan Failed';
            }
            if(RATE_RESULT != null && RATE_RESULT.FailureReasons != null){
                Failuretype = 'Rate Failed';
            }
            if(REPAYMENT_RESULT != null && REPAYMENT_RESULT.FailureReasons != null){
                Failuretype = 'Repayment Option Failed';
            }
            return Failuretype;
        }
    }
}