public class SecuredLoansIntegrationModels
{
    private SecuredLoansIntegrationModels() { }

    public static Application getAllApplicationData(Id application_id){
        return getAllApplicationData(application_id, true);
    }

    public static Application getAllApplicationData(Id application_id, Boolean use_crs){
        Application__c application_record = [SELECT Id, Name,campaign__r.Name, Loan_Term_months__c, Loan_Amount__c,
                                Loan_Purpose__c, Application_type__c, Broker_Fee__c, CRS_Report_Id__c, Equifax_Score__c
                                    FROM Application__c
                                        WHERE Id=:application_id LIMIT 1];
        Application application = transformApplication(application_record);
        for(Applicant__c applicant:[SELECT Id,Additional_Monthly_Income_Type__c,Additional_Monthly_Income__c,
                                Time_with_Prev_Employer_Years__c, Time_with_Prev_Employer_Months__c,Previous_Employer_Name__c,
                                Time_in_Employment_Years__c,Time_in_Employment_Months__c,Employer_Address__c,Employer_Name__c,
                                Employment_Status__c,Gross_Monthly_Income__c,Marital_Status__c,Employer_Phone_Number__c,
                                Home_Phone__c,Mobile_Phone__c, Email_Address__c,Date_of_Birth__c,Maiden_Name__c,First_name__c,
                                Last_name__c, Title__c, Net_Monthly_Income__c, Current_Bankrupt__c, Current_IVA__c,Total_Gross_Monthly_Income__c,
                                Discharged_Bankrupt__c, Previous_IVA__c, Is_Primary__c, Time_with_Bank_Months__c, Employer_Postcode__c,
                                Total_Net_Monthly_Income__c, Middle_Name__c, Occupation__c, Account_Number__c, Sort_Code__c, Employer_Town__c,
                                Number_Of_Dependants__c
                                FROM Applicant__c WHERE Application__c=:application_id]){

            Applicant newApplicant = transformApplicant(applicant);
            newApplicant.ApplicantIncomes = new List<Applicant_Income>();

            for (Applicant_Income__c applicantincome : [Select id, Time_in_Employment_Years__c,Time_in_Employment_Months__c,Start_Date__c,
                                                    Rolling_Contract__c,Proof_of_Income__c,Pay_Frequency__c,Occupation__c,Net_Monthly_Income__c,
                                                    Net_Annual_Income__c,Income_Type__c,Income_Category__c,Gross_Monthly_Income__c,
                                                    Gross_Annual_Income__c,End_Date__c,Employer_Status__c,Employer_Postcode__c,Employer_Phone_Number__c,
                                                    Employer_Name__c,Employer_Address__c, Employer_Town__c, Contract_Length_Months__c,Company_Type__c,
                                                    Company_Registration_Number__c,Of_Company_Owned__c,Applicant_Income_Index__c,Applicant_Index__c,Benefit_Type__c
                                                    FROM Applicant_Income__c WHERE Applicant__c=:applicant.id]){
                newApplicant.ApplicantIncomes.add(transformApplicantIncome(applicantincome));
            }
         application.Applicants.add(newApplicant);
        }

        for(Property__c property:[SELECT Id,Residential_Status__c, Over_Commercial_Premises__c, BTL_Monthly_Income__c,
                                            House_Name_Number__c, Reason_for_increase__c,Tenure__c, Property_Type__c,
                                            Property_Construction__c,Number_of_Floors__c,Number_of_Bathrooms__c,
                                            Number_of_Bedrooms__c,Garage__c,Length_left_on_Lease__c,Local_Authority_Discount__c,
                                            Confirmed_Valuation__c,Estimated_Value__c,Purchase_Price__c,Purchase_Date__c,
                                            Date_Moved_Out__c, Date_Moved_In__c,Ex_Local_Authority__c, Buy_To_Let__c,
                                            First_Time_Buyer__c,First_Line_of_Address__c, Town__c, County__c, Postcode__c,
                                            Current_Address__c,Security_Address__c,Previous_Property__c, Shared_Ownership_Percentage__c,
                                            Street_Name__c, Monthly_Rental_Amount__c
                                            FROM Property__c WHERE Application__c=:application_id]){
            application.Properties.add(transformProperty(property));
        }
        for(Mortgage__c mortgage:[SELECT Id,Type__c,Term_Months__c,RepaymentType__c,On_Security_Address__c,
                                        Mortgage_Start_Date__c,Mortgage_Company__r.Name,Monthly_Repayment__c,
                                        Current_Arrears_Amount__c,Arrears_in_last_3_Months__c,Arrears_in_last_6_Months__c,
                                        Arrears_in_last_12_Months__c, Arrears_in_last_24_Months__c, Arrears_in_last_36_Months__c,
                                        Balance__c,Confirmed_Balance__c, Confirmed_Current_Arrears_Amount__c,
                                        Confirmed_Arrears_in_last_3_Months__c, Confirmed_Arrears_in_last_6_Months__c,
                                        Confirmed_Arrears_in_last_12_Months__c, Confirmed_Arrears_in_last_24_Months__c,
                                        Confirmed_Arrears_in_last_36_Months__c, Repayment_Profile__c, Current_Status__c,
                                        To_be_consolidated__c, Confirmed_Monthly_Repayment__c FROM Mortgage__c WHERE Application__c=:application_id]){
            application.Mortgages.add(transformMortgage(mortgage));
        }
        for(Debt__c debt: [SELECT Id,To_be_consolidated__c,Monthly_Repayment__c,Date_Account_Opened__c,
                                Amount_Outstanding__c,Creditor__r.Name,Account_Number__c, Repayment_Profile__c,
                                Current_Status__c, Default_Date__c, Account_Type__c
                                    FROM Debt__c WHERE Application__c=:application_id]){
            application.Debts.add(transformDebt(debt));
        }
        for (CCJ__c ccj : [SELECT Id,Value__c,Settled__c,Judgement_Date__c,Creditor_Name__c
                                        FROM CCJ__c WHERE Application__c=:application_id]){
            application.CountyCourtJudgements.add(transformCCJ(ccj));
        }

        setHomeOwnerStatusForApplicants(application);

        return application;
    }

    private static void setHomeOwnerStatusForApplicants(Application app){
        Property current_property;
        for(Property prop:app.Properties){
            if(prop.CurrentAddress){
                current_property = prop;
                break;
            }
        }
        if(current_property != null){
            for(Applicant applicant:app.Applicants){
                applicant.HomeOwnerStatus = current_property.ResidentialStatus;
            }
        }
    }

    private static CRSIntegration.Report getCreditReport(Application__c application_record){
        CRSIntegration.Report credit_report;
        if(String.isBlank(application_record.CRS_Report_Id__c)){
            credit_report = CRSIntegration.getCreditReport(application_record);
            if(credit_report.hasError()){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, credit_report.Error));
            }
        }
        return credit_report;
    }

    private static void appendCreditReportDataToApplication(CRSIntegration.Report credit_report, Application application){
        List<CCJ__c> reported_ccjs = getCCJs(credit_report, application.RecordId);
        for(CCJ__c ccj_record:reported_ccjs){
            application.CountyCourtJudgements.add(transformCCJ(ccj_record));
        }
        insertSObjectsInFuture(JSON.serialize(reported_ccjs));

        List<Mortgage__c> reported_mortgages = getMortgages(credit_report, application.RecordId);
        for(Mortgage__c mortgage_record:reported_mortgages){
            application.Mortgages.add(transformMortgage(mortgage_record));
        }
        insertSObjectsInFuture(JSON.serialize(reported_mortgages));

        List<Debt__c> reported_debts = getDebts(credit_report, application.RecordId);
        for(Debt__c debt_record:reported_debts){
            application.Debts.add(transformDebt(debt_record));
        }
        insertSObjectsInFuture(JSON.serialize(reported_debts));
    }

    private static List<CCJ__c> getCCJs(CRSIntegration.Report credit_report, String application_id){
        List<CCJ__c> ccj_list = new List<CCJ__c>();
        if(credit_report.Judgements != null){
            for(CRSIntegration.Judgement reported_ccj:credit_report.Judgements){
                if(!isIgnoredCCJ(reported_ccj)){
                    CCJ__c new_ccj_record = new CCJ__c(Application__c = application_id);
                    new_ccj_record.Settled__c = (reported_ccj.statusField == 'SS');
                    if(reported_ccj.judgmentdateFieldSpecified)
                        new_ccj_record.Judgement_Date__c = reported_ccj.judgmentdateField.date();
                    new_ccj_record.Value__c = reported_ccj.amountField;
                    ccj_list.add(new_ccj_record);
                }
            }
        }
        return ccj_list;
    }

    private static List<Mortgage__c> getMortgages(CRSIntegration.Report credit_report, String application_id){
        List<Mortgage__c> mortgage_list = new List<Mortgage__c>();
        if(credit_report.Accounts != null){
            for(CRSIntegration.Account reported_account:credit_report.Accounts){
                if(reported_account.isMortgage() && !isIgnoredAccount(reported_account)){
                    Mortgage__c new_mortgage_record = new Mortgage__c(Application__c = application_id);
                    new_mortgage_record.Arrears_in_Last_3_Months__c = reported_account.getArrearsInMonths(3);
                    new_mortgage_record.Arrears_in_Last_6_Months__c = reported_account.getArrearsInMonths(6);
                    new_mortgage_record.Arrears_in_Last_12_Months__c = reported_account.getArrearsInMonths(12);
                    new_mortgage_record.Arrears_in_Last_24_Months__c = reported_account.getArrearsInMonths(24);
                    new_mortgage_record.Arrears_in_Last_36_Months__c = reported_account.getArrearsInMonths(36);
                    new_mortgage_record.Repayment_Profile__c = reported_account.getRepaymentProfile();
                    new_mortgage_record.Current_Status__c = reported_account.getStatus();
                    new_mortgage_record.Balance__c = reported_account.accdetailsField.balanceField;
                    mortgage_list.add(new_mortgage_record);
                }
            }
        }
        return mortgage_list;
    }

    private static List<Debt__c> getDebts(CRSIntegration.Report credit_report, String application_id){
        List<Debt__c> debt_list = new List<Debt__c>();
        if(credit_report.Accounts != null){
            for(CRSIntegration.Account reported_account:credit_report.Accounts){
                if(!reported_account.isMortgage() && !isIgnoredAccount(reported_account)){
                    Debt__c new_debt_record = new Debt__c(Application__c = application_id);
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
                    debt_list.add(new_debt_record);
                }
            }
        }
        return debt_list;
    }

    private static Boolean isIgnoredAccount(CRSIntegration.Account reported_account){
        String acc_status = reported_account.getStatus();
        Boolean is_settled_or_satisfied = (acc_status == 'Settled' || acc_status == 'Satisfied');
        Boolean is_settled_date_more_than_12_months_ago = (System.now() > reported_account.accdetailsField.accenddateField.addMonths(12));
        Boolean is_default = (acc_status == 'Default');
        Boolean is_older_than_36_months = (System.now() > reported_account.accdetailsField.accstartdateField.addMonths(36));
        return (is_settled_or_satisfied && is_settled_date_more_than_12_months_ago
               || is_default && is_older_than_36_months);
    }

    private static Boolean isIgnoredCCJ(CRSIntegration.Judgement reported_ccj){
        return (System.now() > reported_ccj.judgmentdateField.addMonths(36));
    }

    @future
    private static void insertSObjectsInFuture(String serialized_sobject_list){
        List<sObject> list_to_insert = (List<SObject>)JSON.deserialize(serialized_sobject_list, List<SObject>.class);
        insert list_to_insert;
    }

    @future
    private static void updateApplicationWithCRSIds(Id app_id, String report_id, String originating_report_id){
        Application__c app = new Application__c(Id = app_id);
        app.CRS_Report_Id__c = report_id;
        app.CRS_Originating_Report_Id__c = originating_report_id;
        update app;
    }

    public static Application transformApplication(Application__c record){
        Application application = new Application();
        application.RecordId = record.Id;
        application.BrokerFee = record.Broker_Fee__c;
        if(record.Campaign__r != null){
            application.Campaign = record.Campaign__r.Name;
        }
        application.LoanPurpose = record.Loan_Purpose__c;
        application.LoanAmount = (record.Loan_Amount__c == null) ? 0 : record.Loan_Amount__c;
        application.LoanTerm = (record.Loan_Term_Months__c == null) ? 0 : record.Loan_Term_Months__c.intValue();
        application.EquifaxScore = record.Equifax_Score__c;
        return application;
    }

    public static Applicant transformApplicant(Applicant__c record){
        Applicant applicant = new Applicant();
        applicant.RecordId = record.Id;
        applicant.Title = record.Title__c;
        applicant.FirstName = record.First_Name__c;
        applicant.MiddleName = record.Middle_Name__c;
        applicant.LastName = record.Last_Name__c;
        applicant.MaidenName = record.Maiden_Name__c;
        applicant.DateOfBirth = Utility.getDateAsDateTime(record.Date_of_Birth__c);
        applicant.Email = record.Email_Address__c;
        applicant.PhoneMobile = record.Mobile_Phone__c;
        applicant.PhoneHome = record.Home_Phone__c;
        applicant.PhoneWork = record.Employer_Phone_Number__c;
        applicant.MaritalStatus = record.Marital_Status__c;
        applicant.GrossMonthlyIncome = record.Total_Gross_Monthly_Income__c;
        applicant.NetMonthlyIncome = record.Total_Net_Monthly_Income__c;
        applicant.EmploymentStatus = record.Employment_Status__c;
        applicant.EmployerName = record.Employer_Name__c;
        applicant.EmployerAddress = record.Employer_Address__c;
        applicant.EmployerTown = record.Employer_Town__c;
        applicant.MonthsInEmployment = Utility.getTimeInMonthFromYearAndMonthStrings(record.Time_in_Employment_Years__c, record.Time_in_Employment_Months__c);
        applicant.PreviousEmployerName = record.Previous_Employer_Name__c;
        applicant.TimeWithPreviousEmployer = Utility.getTimeInMonthFromYearAndMonthStrings(record.Time_with_Prev_Employer_Years__c, record.Time_with_Prev_Employer_Months__c);
        applicant.AdditionalMonthlyIncome = record.Additional_Monthly_Income__c;
        applicant.AdditionalMonthlyIncomeType = record.Additional_Monthly_Income_Type__c;
        applicant.BankAccountNumber = record.Account_Number__c;
        applicant.BankSortCode = record.Sort_Code__c;
        applicant.CurrentBankrupt = record.Current_Bankrupt__c;
        applicant.CurrentIVA = record.Current_IVA__c;
        applicant.DischargedBankrupt = record.Discharged_Bankrupt__c;
        applicant.PreviousIVA = record.Previous_IVA__c;
        applicant.IsPrimary = record.Is_Primary__c;
        if(record.Time_with_Bank_Months__c != null){
            applicant.TimeAtBankMM = record.Time_with_Bank_Months__c.intValue();
        }
        applicant.EmployerPostCode = record.Employer_Postcode__c;
        applicant.Occupation = record.Occupation__c;
        if(record.Number_Of_Dependants__c != null){
            applicant.NumberOfDependants  = record.Number_Of_Dependants__c.intvalue();
        }
        return applicant;
    }

    public static Applicant_Income transformApplicantIncome(Applicant_Income__c record){
        Applicant_Income applicantincome = new Applicant_Income();
        applicantincome.RecordId = record.Id;
        applicantincome.GrossMonthlyIncome = record.Gross_Monthly_Income__c;
        applicantincome.NetMonthlyIncome = record.Net_Monthly_Income__c;
        applicantincome.EmploymentStatus = record.Employer_Status__c;
        applicantincome.EmployerName = record.Employer_Name__c;
        applicantincome.EmployerAddress = record.Employer_Address__c;
        applicantincome.EmployerTown = record.Employer_Town__c;
        applicantincome.EmployerPostCode = record.Employer_Postcode__c;
        applicantincome.EmployerPhoneNumber = record.Employer_Phone_Number__c;
        applicantincome.BenefitType = record.Benefit_Type__c;
        if (record.Of_Company_Owned__c != null){
            applicantincome.PercentageofCompanyOwned = record.Of_Company_Owned__c.intValue();
        }
        applicantincome.CompanyRegistrationNumber = record.Company_Registration_Number__c;
        applicantincome.CompanyType = record.Company_Type__c;
        if (record.Contract_Length_Months__c != null){
            applicantincome.ContractLengthMonths = record.Contract_Length_Months__c.intValue();
        }
        applicantincome.IncomeCategory = record.Income_Category__c;
        applicantincome.IncomeType = record.Income_Type__c;
        applicantincome.Occupation = record.Occupation__c;
        applicantincome.PayFrequency = record.Pay_Frequency__c;
        applicantincome.ProofofIncome = record.Proof_of_Income__c;
        applicantincome.MonthsInEmployment = Utility.getTimeInMonthFromYearAndMonthStrings(record.Time_in_Employment_Years__c, record.Time_in_Employment_Months__c);
        applicantincome.RollingContract = record.Rolling_Contract__c;

        return applicantincome;
    }

    public static Property transformProperty(Property__c record){
        Property property = new Property();
        property.RecordId = record.Id;
        property.CurrentAddress = record.Current_Address__c;
        property.SecurityAddress = record.Security_Address__c;
        property.PropertyAddress = new Address();
            property.PropertyAddress.HouseNumber = record.House_Name_Number__c;
            property.PropertyAddress.Address1 = record.Street_Name__c;
            property.PropertyAddress.Town = record.Town__c;
            property.PropertyAddress.County = record.County__c;
            property.PropertyAddress.PostCode = record.PostCode__c;
        property.FirstTimeBuyer = record.First_Time_Buyer__c;
        property.BuyToLet = record.Buy_To_Let__c;
        property.ExLocalAuthority = record.Ex_Local_Authority__c;
        property.DateMovedIn = Utility.getDateAsDateTime(record.Date_Moved_In__c);
        property.DateMovedOut = Utility.getDateAsDateTime(record.Date_Moved_Out__c);
        property.PurchaseDate = Utility.getDateAsDateTime(record.Purchase_Date__c);
        property.PurchasePrice = record.Purchase_Price__c;
        property.EstimatedValue = record.Estimated_Value__c;
        property.ConfirmedValue = record.Confirmed_Valuation__c;
        property.LocalAuthorityDiscount = record.Local_Authority_Discount__c;
        if(record.Length_left_on_Lease__c != null){
            property.MonthsLeftOnLease = record.Length_left_on_Lease__c.intValue();
        }
        property.Garage = record.Garage__c;
        if(record.Number_of_Bedrooms__c != null){
            property.NumberBedrooms = record.Number_of_Bedrooms__c.intValue();
        }
        if(record.Number_of_Bathrooms__c != null){
            property.NumberBathrooms = record.Number_of_Bathrooms__c.intValue();
        }
        if(record.Number_of_Floors__c != null){
            property.NumberFloors = record.Number_of_Floors__c.intValue();
        }
        property.PreviousProperty = record.Previous_Property__c;
        property.PropertyConstruction = record.Property_Construction__c;
        property.PropertyType = record.Property_Type__c;
        property.Tenure = record.Tenure__c;
        property.ReasonForIncrease = record.Reason_for_increase__c;
        property.BtlMonthlyIncome = record.BTL_Monthly_Income__c;
        property.OverComercialPremisies = record.Over_Commercial_Premises__c;
        property.ResidentialStatus = record.Residential_Status__c;
        property.SharedOwnershipPercentage = record.Shared_Ownership_Percentage__c;
        property.MonthlyRentalAmount = record.Monthly_Rental_Amount__c;
        return property;
    }

    public static Mortgage transformMortgage(Mortgage__c record){
        Mortgage mortgage = new Mortgage();
        mortgage.RecordId = record.Id;
        mortgage.Balance = record.Balance__c;
        mortgage.ConfirmedBalance = record.Confirmed_Balance__c;
        if(record.Arrears_in_last_36_Months__c != null){
            mortgage.Arrears36Month = record.Arrears_in_last_36_Months__c.intValue();
        }
        if(record.Arrears_in_last_24_Months__c != null){
            mortgage.Arrears24Month = record.Arrears_in_last_24_Months__c.intValue();
        }
        if(record.Arrears_in_last_12_Months__c != null){
            mortgage.Arrears12Month = record.Arrears_in_last_12_Months__c.intValue();
        }
        if(record.Arrears_in_last_6_Months__c != null){
            mortgage.Arrears6Month = record.Arrears_in_last_6_Months__c.intValue();
        }
        if(record.Arrears_in_last_3_Months__c != null){
            mortgage.Arrears3Month = record.Arrears_in_last_3_Months__c.intValue();
        }
        if(record.Current_Arrears_Amount__c != null){
            mortgage.ArrearsCurrent = record.Current_Arrears_Amount__c.intValue();
        }
        if(record.Confirmed_Arrears_in_last_36_Months__c != null){
            mortgage.ConfirmedArrears36Month = record.Confirmed_Arrears_in_last_36_Months__c.intValue();
        }
        if(record.Confirmed_Arrears_in_last_24_Months__c != null){
            mortgage.ConfirmedArrears24Month = record.Confirmed_Arrears_in_last_24_Months__c.intValue();
        }
        if(record.Confirmed_Arrears_in_last_12_Months__c != null){
            mortgage.ConfirmedArrears12Month = record.Confirmed_Arrears_in_last_12_Months__c.intValue();
        }
        if(record.Confirmed_Arrears_in_last_6_Months__c != null){
            mortgage.ConfirmedArrears6Month = record.Confirmed_Arrears_in_last_6_Months__c.intValue();
        }
        if(record.Confirmed_Arrears_in_last_3_Months__c != null){
            mortgage.ConfirmedArrears3Month = record.Confirmed_Arrears_in_last_3_Months__c.intValue();
        }
        if(record.Confirmed_Current_Arrears_Amount__c != null){
            mortgage.ConfirmedArrearsCurrent = record.Confirmed_Current_Arrears_Amount__c.intValue();
        }
        mortgage.ConfirmedMonthlyRepayment = record.Confirmed_Monthly_Repayment__c;
        mortgage.MonthlyRepayment = record.Monthly_Repayment__c;
        if(record.Mortgage_Company__r != null){
            mortgage.MortgageCompany = record.Mortgage_Company__r.Name;
        }
        mortgage.MortgageStartDate = Utility.getDateAsDateTime(record.Mortgage_Start_Date__c);
        mortgage.OnSecurityAddress = record.On_Security_Address__c;
        mortgage.CurrentStatus = record.Current_Status__c;
        mortgage.RepaymentProfile = record.Repayment_Profile__c;
        mortgage.RepaymentType = record.RepaymentType__c;
        if(record.Term_Months__c != null){
            mortgage.TermMonths = record.Term_Months__c.intValue();
        }
        mortgage.ToBeConsolidated = record.To_be_consolidated__c;
        mortgage.MortgageType = record.Type__c;
        return mortgage;
    }

    public static Debt transformDebt(Debt__c record){
        Debt debt = new Debt();
        debt.RecordId = record.Id;
        debt.AccountNumber = record.Account_Number__c;
        if(record.Creditor__r != null){
            debt.Creditor = record.Creditor__r.Name;
        }
        debt.CurrentBalance = record.Amount_Outstanding__c;
        debt.DateAccountOpened = Utility.getDateAsDateTime(record.Date_Account_Opened__c);
        debt.MonthlyRepayment = record.Monthly_Repayment__c;
        debt.ToBeConsolidated = record.To_be_consolidated__c;
        debt.CurrentStatus = record.Current_Status__c;
        debt.RepaymentProfile = record.Repayment_Profile__c;
        debt.DefaultDate = record.Default_Date__c;
        debt.AccountType = record.Account_Type__c;
        return debt;
    }

    public static CCJ transformCCJ(CCJ__c record){
        CCJ ccj = new CCJ();
        ccj.RecordId = record.Id;
        ccj.CreditorName = record.Creditor_Name__c;
        ccj.JudgementDate = Utility.getDateAsDateTime(record.Judgement_Date__c);
        ccj.Settled = record.Settled__c;
        ccj.Value = record.Value__c;
        return ccj;
    }

    public class Address
    {
        public String HouseNumber { get; set; }
        public String Address1 { get; set; }
        public String Address2 { get; set; }
        public String Town { get; set; }
        public String County { get; set; }
        public String PostCode { get; set; }
    }

    public class Applicant
    {
        public String RecordId {get; set; }
        public String Title { get; set; }
        public String FirstName { get; set; }
        public String MiddleName { get; set; }
        public String LastName { get; set; }
        public String MaidenName { get; set; }

        public DateTime DateOfBirth { get; set; }
        public String Email { get; set; }
        public String PhoneMobile { get; set; }
        public String PhoneHome { get; set; }
        public String PhoneWork { get; set; }

        public String MaritalStatus { get; set; }
        public Double GrossMonthlyIncome { get; set; }
        public Double NetMonthlyIncome { get; set; }
        public String EmploymentStatus { get; set; }
        public String EmployerName { get; set; }
        public String EmployerAddress { get; set; }
        public String EmployerTown { get; set; }
        public String EmployerPostCode  { get; set; }
        public Integer MonthsInEmployment { get; set; }
        public String PreviousEmployerName { get; set; }
        public Integer TimeWithPreviousEmployer { get; set; }
        public Double AdditionalMonthlyIncome { get; set; }
        public String AdditionalMonthlyIncomeType { get; set; }
        public Integer TimeAtBankMM { get; set; }

        public String BankAccountNumber { get; set; }
        public String BankSortCode { get; set; }
        public String HomeOwnerStatus { get; set; }

        public Boolean CurrentBankrupt { get; set; }
        public Boolean CurrentIVA { get; set; }
        public Boolean DischargedBankrupt { get; set; }
        public Boolean PreviousIVA { get; set; }
        public Boolean IsPrimary { get; set; }

        public String Occupation { get; set; }
        public Integer NumberOfDependants { get; set; }

        public List<Applicant_Income> ApplicantIncomes {get;set;}
    }

    public class Applicant_Income
    {
        public String RecordId {get; set; }
        public Double GrossMonthlyIncome { get; set; }
        public Double NetMonthlyIncome { get; set; }
        public String EmploymentStatus { get; set; }
        public String EmployerName { get; set; }
        public String EmployerAddress { get; set; }
        public String EmployerTown { get; set; }
        public String EmployerPostCode  { get; set; }
        public String EmployerPhoneNumber {get;set;}
        public String BenefitType {get;set;}
        public Integer PercentageofCompanyOwned {get;set;}
        public String CompanyRegistrationNumber {get;set;}
        public String CompanyType {get;set;}
        public Integer ContractLengthMonths {get;set;}
        public String IncomeCategory {get;set;}
        public String IncomeType {get;set;}
        public String Occupation {get;set;}
        public String PayFrequency {get;set;}
        public String ProofofIncome {get;set;}
        public Integer MonthsInEmployment { get; set; }
        public Boolean RollingContract { get;set;}

    }

    public class Property
    {
        public String RecordId {get; set; }
        public Boolean CurrentAddress { get; set; }
        public Address PropertyAddress { get; set; }
        public Boolean SecurityAddress { get; set; }

        public Boolean FirstTimeBuyer { get; set; }
        public Boolean BuyToLet { get; set; }
        public Boolean ExLocalAuthority { get; set; }

        public DateTime DateMovedIn { get; set; }
        public DateTime DateMovedOut { get; set; }

        public DateTime PurchaseDate { get; set; }
        public Double PurchasePrice { get; set; }
        public Double EstimatedValue { get; set; }
        public Double ConfirmedValue { get; set; }
        public Double LocalAuthorityDiscount { get; set; }
        public Integer MonthsLeftOnLease { get; set; }

        public String Garage { get; set; }
        public Integer NumberBedrooms { get; set; }
        public Integer NumberBathrooms { get; set; }
        public Integer NumberFloors { get; set; }

        public Boolean PreviousProperty { get; set; }
        public String PropertyConstruction { get; set; }
        public String PropertyType { get; set; }
        public String Tenure { get; set; }
        public String ReasonForIncrease { get; set; }
        public Double BtlMonthlyIncome { get; set; }
        public Boolean OverComercialPremisies { get; set; }
        public String ResidentialStatus { get; set; }
        public Double SharedOwnershipPercentage { get; set; }
        public Double MonthlyRentalAmount { get; set; }
    }

    public class Mortgage
    {
        public String RecordId {get; set; }
        public Double Balance { get; set; }
        public Double ConfirmedBalance { get; set; }

        public Integer Arrears36Month { get; set; }
        public Integer Arrears24Month { get; set; }
        public Integer Arrears12Month { get; set; }
        public Integer Arrears6Month { get; set; }
        public Integer Arrears3Month { get; set; }
        public Integer ArrearsCurrent { get; set; }

        public Integer ConfirmedArrears3Month { get; set; }
        public Integer ConfirmedArrears6Month { get; set; }
        public Integer ConfirmedArrears12Month { get; set; }
        public Integer ConfirmedArrears24Month { get; set; }
        public Integer ConfirmedArrears36Month { get; set; }
        public Integer ConfirmedArrearsCurrent { get; set; }
        public Double ConfirmedMonthlyRepayment { get; set; }

        public Double MonthlyRepayment { get; set; }
        public String MortgageCompany { get; set; }
        public DateTime MortgageStartDate { get; set; }
        public Boolean OnSecurityAddress { get; set; }

        public String CurrentStatus { get; set; }
        public String RepaymentProfile { get; set; }
        public String RepaymentType { get; set; }
        public Integer TermMonths { get; set; }
        public Boolean ToBeConsolidated { get; set; }

        public String MortgageType { get; set; }
    }

    public class CCJ
    {
        public String RecordId {get; set; }
        public String CreditorName { get; set; }
        public DateTime JudgementDate { get; set; }
        public Boolean Settled { get; set; }
        public Decimal Value { get; set; }
    }

    public class Debt
    {
        public String RecordId {get; set; }
        public String AccountNumber { get; set; }
        public String Creditor { get; set; }
        public Double CurrentBalance { get; set; }
        public DateTime DateAccountOpened { get; set; }
        public Double MonthlyRepayment { get; set; }
        public Boolean ToBeConsolidated { get; set; }
        public String RepaymentProfile { get; set; }
        public String CurrentStatus { get; set; }
        public Date DefaultDate {get; set; }
        public String AccountType {get; set; }
    }

    public class Application
    {
        public String RecordId {get; set; }
        public Double BrokerFee { get; set; }
        public String Campaign { get; set; }
        public Double LoanAmount { get; set; }
        public Integer LoanTerm { get; set; }
        public String LoanPurpose { get; set; }

        public List<Applicant> Applicants { get; set; }
        public List<Property> Properties { get; set; }
        public List<Mortgage> Mortgages { get; set; }
        public List<CCJ> CountyCourtJudgements { get; set; }
        public List<Debt> Debts { get; set; }
        public Double EquifaxScore { get; set; }

        public Application(){
            Applicants = new List<Applicant>();
            Properties = new List<Property>();
            Mortgages = new List<Mortgage>();
            CountyCourtJudgements = new List<CCJ>();
            Debts = new List<Debt>();
        }
    }
}