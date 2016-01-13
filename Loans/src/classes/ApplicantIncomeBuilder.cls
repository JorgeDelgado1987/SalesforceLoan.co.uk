public class ApplicantIncomeBuilder {

    private Applicant_Income__c Record;

    private ApplicantIncomeBuilder(Applicant__c applicant) {
        this.Record = new Applicant_Income__c();
        Record.Applicant__c = applicant.Id;
        Record.Applicant__r = applicant;
    }

    private ApplicantIncomeBuilder(Applicant_Income__c applicant_income) {
        this.Record = applicant_income;
    }

    public static ApplicantIncomeBuilder getBuilder(Applicant__c applicant){
        return new ApplicantIncomeBuilder(applicant);
    }

    public static ApplicantIncomeBuilder getBuilder(Applicant_Income__c applicant_income){
        return new ApplicantIncomeBuilder(applicant_income);
    }

    public ApplicantIncomeBuilder save(){
        upsert Record;
        return this;
    }

    public Applicant_Income__c getRecord(){
        return Record;
    }

    public ApplicantIncomeBuilder setOccupation(String occupation){
        Record.Occupation__c = occupation;
        return this;
    }

    public ApplicantIncomeBuilder setIncomeType(String income_type){
        Record.Income_Type__c = income_type;
        return this;
    }

    public ApplicantIncomeBuilder setIncomeCategory(String income_category){
        Record.Income_Category__c = income_category;
        return this;
    }

    public ApplicantIncomeBuilder setBenefitType(String benefit_type){
        Record.Benefit_Type__c = benefit_type;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerName(String employer_name){
        Record.Employer_Name__c = employer_name;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerStatus(String employer_status){
        Record.Employer_Status__c = employer_status;
        return this;
    }

    public ApplicantIncomeBuilder setNetMonthlyIncome(Decimal net_monthly_income){
        Record.Net_Monthly_Income__c = net_monthly_income;
        return this;
    }

    public ApplicantIncomeBuilder setGrossMonthlyIncome(Decimal gross_monthly_income){
        Record.Gross_Monthly_Income__c = gross_monthly_income;
        return this;
    }



    public ApplicantIncomeBuilder setTimeInEmploymentMonths(Integer months){
        if(months != null){
            Record.Time_In_Employment_Months__c = String.valueOf(months);
        }
        return this;
    }

    public ApplicantIncomeBuilder setTimeInEmploymentYears(Integer years){
        if(years != null){
            if(years >= 10){
                Record.Time_In_Employment_Years__c = '10+';
            } else {
                Record.Time_In_Employment_Years__c = String.valueOf(years);
            }
        }
        return this;
    }

    public ApplicantIncomeBuilder setOfCompanyOwned(Integer percent_owned){
        Record.Of_Company_Owned__c = percent_owned;
        return this;
    }

     public ApplicantIncomeBuilder setCompanyRegNumber(String company_reg_number){
        Record.Company_Registration_Number__c = company_reg_number;
        return this;
    }

    public ApplicantIncomeBuilder setCompanyType(String company_type){
        Record.Company_Type__c = company_type;
        return this;
    }

    public ApplicantIncomeBuilder setContractLengthMonths(Integer contract_length){
        Record.Contract_Length_Months__c = contract_length;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerAddress(String employer_address){
        Record.Employer_Address__c = employer_address;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerTown(String employer_town){
        Record.Employer_Town__c = employer_town;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerPhoneNumber(String employer_phone){
        Record.Employer_Phone_Number__c = employer_phone;
        return this;
    }

    public ApplicantIncomeBuilder setEmployerPostcode(String employer_postcode){
        Record.Employer_Postcode__c = employer_postcode;
        return this;
    }

    public ApplicantIncomeBuilder setNetAnnualIncome(Decimal net_annual_income){
        Record.Net_Annual_Income__c = net_annual_income;
        return this;
    }

    public ApplicantIncomeBuilder setGrossAnnualIncome(Decimal gross_annual_income){
        Record.Gross_Annual_Income__c = gross_annual_income;
        return this;
    }

    public ApplicantIncomeBuilder setIncomeProof(String income_proof){
        Record.Proof_of_Income__c = income_proof;
        return this;
    }

    public ApplicantIncomeBuilder setPayFrequency(String pay_frequency){
        Record.Pay_Frequency__c = pay_frequency;
        return this;
    }

    public ApplicantIncomeBuilder setRollingContract(Boolean rolling_contract){
        Record.Rolling_Contract__c = rolling_contract;
        return this;
    }

    public ApplicantIncomeBuilder setApplicantIndex(Integer applicant_index){
        Record.Applicant_Index__c = applicant_index;
        return this;
    }

    public ApplicantIncomeBuilder setApplicantIncomeIndex(Integer applicant_income_index){
        Record.Applicant_Income_Index__c = applicant_income_index;
        return this;
    }



}