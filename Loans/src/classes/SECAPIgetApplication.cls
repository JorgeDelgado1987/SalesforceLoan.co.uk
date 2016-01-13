@RestResource(urlMapping='/sec/getApplication')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   07/10/2014
//
/////////////////////////////////////////////////

// 04/11/2014 - Application_stage__c added SRP
// 14/11/2014 - Customer_estimated_credit_rating__c added to Applicant__c SRP
// 16/12/2014 - additional fields added as per SEC-170 - SRP
// 20/01/2015 - additional fields added as per SEC-245 - SRP
// 21/01/2015 - return Outstanding Item object as per SEC-249 - SRP
// 05/02/2015 - Net_annual_income__c added to Applicant__c = SEC-304 SRP
// 18/02/2015 - Residential_status__c added to Property__c - SEC-315 SRP
// 23/02/2015 - SEC=317 - 21 fields added to Application, SEC-321 - 11 fields added to Applicant__c
// 23/02/2015 - 7 fields added to Property__c - SEC-322 - SRP
// 27/04/2015 - Applicant_Income added SEC-473 - SRP
// 05/06/2015 - SEC-529 - additonal fields returned for Debts - SRP
// 24/06/2015 - SEC-538 - Lender name added to Quotes - SRP

// Takes a POST with a Parameter to determine which set of data to return for the Application
// Returns relevant dataset for applicant.

global class SECAPIgetApplication {

@HttpPost
global static AppResponse AppDetails(){

        Boolean showapplicants = false;
        Boolean showdebts = false;
        Boolean showproperties = false;
        Boolean showmortgages = false;
        Boolean showccjs = false;
        Boolean all = false;
        Boolean showstagehistories = false;
        Boolean showquotes = false;
        Boolean showoutstandings = false;
        Boolean showapplicantincomes = false;
        Boolean showexpenditures = false;
        Boolean showdependants = false;
        Boolean datasent = false;
        String applicationid;
        List<String> ErrorsList;

        RestRequest req = RestContext.request;

        //Builds MAP of URL Parameters
        Map<String,Object> tempmapparamdata = RestContext.request.params;
        Map<String,Object> mapparamdata = new Map<String,Object>();

        //Loops through inbound params and assigns the keys in the map to upper case
        for(String mkey : tempmapparamdata.keyset()){
            mapparamdata.put(mKey.toUpperCase(), tempmapparamdata.get(mkey));
        }

        datasent = false;
        //Assigns MAP Values to variables to be used and checks their formatting
        ErrorsList = new List<String>();

        if(mapparamdata.containsKey('ID') && mapparamdata.get('ID') != null && mapparamdata.get('ID') != ''){
            applicationid = String.ValueOf(mapparamdata.get('ID'));
            datasent = true;
        }
        if(mapparamdata.containsKey('APPLICANTS') && mapparamdata.get('APPLICANTS') == 'Y'){
            showapplicants = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('DEBTS') && mapparamdata.get('DEBTS') == 'Y'){
            showdebts = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('PROPERTIES') && mapparamdata.get('PROPERTIES') == 'Y'){
            showproperties = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('MORTGAGES') && mapparamdata.get('MORTGAGES') == 'Y'){
            showmortgages = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('CCJS') && mapparamdata.get('CCJS') =='Y'){
            showccjs = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('ALL') && mapparamdata.get('ALL') =='Y'){
            all = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('STAGEHISTORIES') && mapparamdata.get('STAGEHISTORIES') =='Y'){
            showstagehistories = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('QUOTES') && mapparamdata.get('QUOTES') =='Y'){
            showquotes = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('OUTSTANDINGITEMS') && mapparamdata.get('OUTSTANDINGITEMS') =='Y'){
            showoutstandings = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('APPLICANTINCOMES') && mapparamdata.get('APPLICANTINCOMES') =='Y'){
            showapplicantincomes = true;
            showapplicants = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('EXPENDITURES') && mapparamdata.get('EXPENDITURES') =='Y'){
            showexpenditures = true;
            showapplicants = true;
            datasent = true;
        }

        if(mapparamdata.containsKey('DEPENDANTS') && mapparamdata.get('DEPENDANTS') =='Y'){
            showdependants = true;
            showapplicants = true;
            datasent = true;
        }



         //check if any parameters send

        if ((showapplicants == false) && (showdebts == false) && (showproperties == false) && (showmortgages == false) && (showccjs == false) && (all == false) && (showquotes == false) && (showstagehistories == false) && (showoutstandings == false) && (showapplicantincomes == false) && (showexpenditures == false) && (showdependants == false)){
                   ErrorsList.add('Data Set parameter required');
                   datasent = false;
        }

        AppResponse appRes = new AppResponse();

        if(!datasent){
            ErrorsList.add('No valid input parameter data sent');
            AppResponse appRes1 = new AppResponse('Error', ErrorsList);
            String JSONRes = JSON.serialize(appRes1);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = blob.valueOf(JSONRes);
            return appRes1;
        }

        List <Application__c> matchApps = [Select id from Application__c WHERE id = :applicationid];
        if (matchApps.size() <1){
            //no such applicant so refuse
            appRes.status = 'Rejected';
            appRes.detail.add('No such applicant record.');
            RestContext.response.statusCode = 400;
        }
        else {
            appRes.status = 'Success';
            RestContext.response.statusCode = 200;
        }

        if (appRes.status == 'Success'){
            // 04/11/2014 - Application_stage__c added SRP
            // 23/02/2015 - SEC=317 - 21 stages added
            string query = 'SELECT createddate, createdbyid, broker_fee__c, cancelled_date__c, case_owner__c, ltv__c, ';
            query += 'lead_applicant_name__c, lender_plan__c, lender__c, sent_to_bank__c, valuation_booked__c, credit_commitment_after_consolidation__c, ';
            query += 'current_credit_outgoings__c, mortgage_balance__c, number_of_ccjs__c, property_value__c, total_debt_repayment_after_consol__c, ';
            query += 'total_unsecured_balance__c, value_of_ccjs__c, business__c, cancellation_reason__c, total_ledger__c, affiliate_commission__c, ';
            query += 'cooling_off_start_date__c, equifax_score__c, total_gross_income__c, loan_to_income_ratio__c, security_mortgage_repayment__c, ';
            query += 'total_expenditure__c, total_debt_repayment_before_consol__c, consolidation_saving__c, monthly_repayment__c, total_lender_fees__c, ';
            query += 'application_value__c, total_mortgage_repayment__c, debt_to_income_ratio__c, total_gross_advance__c, creative__c, landing_page__c, ';
            query += 'match_type__c, ad__c, ad_group__c, ppc_campaign__c, lead__c, device__c, device_model__c, mobile__c, browser__c, browser_version__c, ';
            query += 'ip_address__c, branch__c, lender_commission__c, exit_strategy__c, exit_strategy_details__c, proposed_affiliate_commission__c, id, name, ';
            query += 'Account__c, Campaign__c ,Application_Type__c ,Application_Stage__c,Loan_Amount__c ,Loan_Term_Months__c , Loan_Purpose__c,Keyword__c,';
            query += 'Stage__c, Case_Manager__c, Completed_Date__c,CRS_Originating_Report_Id__c, CRS_Report_Id__c,Most_Recent_Stage_Date__c,Processor__c,ID_Confirmed_For_Search__c,';
            query += 'Sub_Stage__c, Child_Care_Maintenance__c ,Car_Insurance__c, Cigarettes_Tobacco__c, Clothing__c, Council_Tax__c, Food_Household__c, ';
            query += 'Gas_Electricity__c, Ground_Rent_Service_Charge__c, Landline_Internet_Mobile__c, Life_Insurance__c, Medical_Dental_Health_Costs__c, ';
            query += 'MOT_Servicing__c, Number_of_Cars__c, Other_Expenditure__c, Other_Transport__c, Pension_Contributions__c, Petrol__c, School_Meals_Travel__c, ';
            query += 'TV_License_Sky_Subscriptions__c, Water_Rates__c, Best_Time_to_Contact_Day__c, Best_Time_To_Contact__c';
            query += ' FROM Application__c WHERE id=\'' + applicationid + '\'';
            List<Application__c> apps = Database.query(query);
            appRes.application = apps[0];

            // 14/11/2014 - Customer_estimated_credit_rating__c added to Applicant__c SRP
            // 05/02/2015 - Net_annual_income__c added to Applicant__c SRP
            // 23/02/2015 - SEC-321 - 11 fields added to Applicant__c

            if ((showapplicants) || (all)){
                List<Applicant__c> myApplicants = [Select middle_name__c, total_net_monthly_income__c, months_since_iva__c,
                                                id, name, first_name__c,last_name__c,Email_Address__c,Mobile_Phone__c,Applicant_index__c,Maiden_Name__c,Marital_Status__c,Date_of_Birth__c,Home_Phone__c,Employer_Phone_number__c,Gross_Monthly_Income__c,Employment_Status__c,Employer_Name__c,Employer_Address__c,Employer_Postcode__c,Time_in_Employment_Months__c,Time_in_Employment_Years__c,
                                                Account_Number__c,Age__c,Bank_Account_Name__c,Income_proof__c,Bank_Account_Type__c,Bank_Name__c,Gross_Annual_Income__c,Is_Primary__c,Number_of_Dependants__c,Sort_Code__c,Time_with_Bank_Months__c,Total_Gross_Annual_Income__c,Total_Gross_Monthly_Income__c,
                                                Of_Company_Owned__c,Accountants_Verification_Available__c,Benefits_Received__c,Company_Registration_Number__c,Company_Type__c ,Contract_Length_Months__c,Bonus_Amount__c, Number_of_Partners__c,Partnership_Agreement__c,Rolling_Contract__c,Monthly_Overtime_Amount__c,
                                                Previous_Employer_Name__c,Time_with_Prev_Employer_Months__c,Time_with_Prev_Employer_Years__c,Additional_Monthly_Income__c,Additional_Monthly_Income_Type__c, Customer_estimated_credit_rating__c, Current_Bankrupt__c, Current_IVA__c, Discharged_Bankrupt__c, Previous_IVA__c,Title__c,Occupation__c,
                                                Bankruptcy_End_Date__c, Bankruptcy_Start_Date__c, IVA_End_Date__c, IVA_Payments_Up_Date_Date__c, IVA_Start_Date__c, Insolvency_practitioner__c,
                                                Other_Names__c,
                                                Net_Annual_Income__c from Applicant__c WHERE Application__r.id =:applicationid];
                if (myApplicants.size()>0){
                    appRes.Applicants = myApplicants;
                }
            }

            if ((showproperties) || (all)){
                // 18/02/2015 - Residential_status__c added to Property__c - SEC-315 SRP
                // 23/02/2015 - 7 fields added to Property__c - SEC-322 - SRP
                List<Property__c> myprops = [Select Applicant__c, Applicant_Index__c, confirmed_valuation__c, is_security__c, valuation_type__c, valuer__c, previous_valuer_name__c, building_insurance_provider__c, building_insured_amount__c,
                    building_insurance_annual_premium__c, building_insurance_renewal_date__c, shared_ownership__c, title_number__c, shared_ownership_percentage__c, monthly_rental_amount__c, time_at_this_address_years__c,
                    time_at_this_address_months__c, id, name,Buy_To_Let__c,County__c,Date_Moved_In__c,Date_Moved_Out__c,Estimated_Value__c,Ex_Local_Authority__c,Street_Name__c,First_Time_Buyer__c,Garage__c,BTL_Monthly_Income__c,
                    House_Name_Number__c,Length_left_on_Lease__c,Local_Authority_Discount__c,Number_of_Bathrooms__c,Number_of_Bedrooms__c,Number_of_Floors__c,Postcode__c,Previous_Property__c,Over_Commercial_Premises__c,
                    Central_Heating__c,Currently_on_Market__c,Double_Glazed__c,Housing_Association__c  ,Number_of_Reception_Rooms__c,Previous_Valuation_Amount__c,Property_Valued_in_Last_12_Months__c,
                    Property_Construction__c,Property_Type__c,Purchase_Date__c,Purchase_Price__c,Reason_for_increase__c,Tenure__c,Town__c,Current_Address__c,Security_Address__c,Property_index__c, Residential_status__c,
                    Property_Use__c, Commercial_Use__c
                    from Property__c WHERE Application__r.id=:applicationid];
                if (myprops.size()>0){
                    appRes.Properties = myprops;
                }
            }

            if ((showmortgages) || (all)){
                List<Mortgage__c> mymorts = [Select confirmed_balance__c, confirmed_current_arrears_amount__c, confirmed_monthly_repayment__c, current_arrears__c, mortgage_account_number__c, mortgage_address__c, mortgage_postcode__c,
                    mortgage_rate__c, mortgage_company_name__c, id, name,Arrears_in_last_24_Months__c,Arrears_in_Last_36_Months__c,Arrears_in_last_12_Months__c,Arrears_in_Last_3_Months__c,Arrears_in_Last_6_Months__c,Balance__c,Current_Arrears_Amount__c,Monthly_Repayment__c,Interest_Only_Repayment_Vehicle__c,
                    Confirmed_Arrears_in_last_12_Months__c,Confirmed_Arrears_in_last_24_Months__c,Confirmed_Arrears_in_last_36_Months__c,Confirmed_Arrears_in_last_3_Months__c,Confirmed_Arrears_in_last_6_Months__c,Current_Status__c,Repayment_Profile__c,To_be_consolidated__c,
                    Mortgage_Company__c,Mortgage_Start_Date__c,On_Security_Address__c,Property__c,RepaymentType__c,Term_Months__c,Type__c,Mortgage_index__c, Property_index__c from Mortgage__c WHERE Application__r.id=:applicationid];
                if (mymorts.size()>0){
                    appRes.Mortgages = mymorts;
                }
            }

            if ((showccjs) || (all)){
                List<CCJ__c> myccjs = [Select id, name, Applicant_Index__c, Creditor_Name__c,Applicant__c,Judgement_Date__c,Settled__c,Value__c,Ccj_index__c from CCJ__c WHERE Application__r.id=:applicationid];
                if (myccjs.size()>0){
                    appRes.ccjs = myccjs;
                }
            }
            // 05/06/2015 - SEC-529 - additonal fields returned for Debts - SRP
            if ((showdebts) || (all)){
                List<Debt__c> mydebts = [Select id, name, Applicant_Index__c, Debt_Index__c,Creditor__c, Creditor__r.Name, Amount_Outstanding__c,Monthly_Repayment__c,
                    Account_Type__c, Calculated_Repayment__c, Current_Status__c, Highest_Arrears_In_12_Months__c, Highest_Arrears_In_24_Months__c,
                    Interest_Rate__c, Repayment_Profile__c, Date_Account_Opened__c, To_be_consolidated__c
                     from Debt__c WHERE Application__r.id=:applicationid];
                if (mydebts.size()>0){
                    appRes.debts = mydebts;
                }
            }

            if ((showquotes) || (all)){
            // 24/06/2015 - SEC-538 - Lender Name added to Quotes - SRP
                List<Quote__c> myquotes = [Select id, name, Active__c, APR__c, Blown_Out__c, Blown_Out_By__c, Blow_Out_Detail__c, Blow_Out_User__c, Broker_Fee__c, Estimated_Monthly_Repayment__c, Lender_Fee__c, Lender_Name__c, Lender_Plan__c, Lender_Plan_Rate__c, Lender_Reference__c, Override_Rate__c, Quoted_By__c, Selected_Item__c, Total_Amount_Payable__c, Use_Override_Rate__c from Quote__c WHERE Application__r.id=:applicationid];
                if (myquotes.size()>0){
                    appRes.quotes = myquotes;
                }
            }

            if ((showstagehistories) || (all)){
                List<Stage_History__c> mystagehistories = [Select id, name, Application_Stage_lkup__c, Completed__c, Completed_By__c, Completed_By_Name__c, Completed_Date_Time__c, Stage_Name__c, Stage_Order__c, Stage_Outcome_lkup__c, Stage_Outcome_name__c, Started_Date_Time__c, Time_in_Stage__c, Time_in_Stage_full__c from Stage_History__c WHERE Application__r.id=:applicationid];
                if (mystagehistories.size()>0){
                    appRes.stagehistories = mystagehistories;
                }
            }

            if ((showoutstandings) || (all)){
                List<Outstanding_Items__c> myoustandings = [Select id, name, Date_Received__c, Due_Date__c, Item_Name__c, Item_Note__c, Item_Type__c, Number_of_Days_Overdue__c, Overdue__c, Received__c, Requested_Date__c, Scheduled_Date__c from Outstanding_Items__c WHERE Application__r.id=:applicationid ];
                if (myoustandings.size()>0){
                    appRes.OutstandingItems = myoustandings;
                }
            }

            if ((showapplicantincomes) || (all)){
                List<Applicant_Income__c> myapplicantincomes = [Select employer_town__c, id, Time_in_Employment_Years__c,Time_in_Employment_Months__c,Start_Date__c,Rolling_Contract__c,Proof_of_Income__c,Pay_Frequency__c,Occupation__c,Net_Monthly_Income__c,Net_Annual_Income__c,Income_Type__c,Income_Category__c,Gross_Monthly_Income__c,Gross_Annual_Income__c,End_Date__c,Employer_Status__c,Employer_Postcode__c,
                    Employer_Phone_Number__c,Employer_Name__c,Employer_Address__c, Contract_Length_Months__c,Company_Type__c,Company_Registration_Number__c,Of_Company_Owned__c,Applicant_Income_Index__c,Applicant_Index__c,
                    Accountants_Address__c, Accountants_Name__c, Accountants_Postcode__c, Hourly_Rate__c, Weekly_Hours__c,
                    Benefit_Type__c from Applicant_Income__c WHERE Applicant__c IN:appRes.Applicants];
                if (myapplicantincomes.size()>0){
                    appRes.ApplicantIncomes = myapplicantincomes;
                }
            }

            if ((showexpenditures) || (all)){
                List<Expenditure__c> myexpenditures = [Select Id, Amount__c, Applicant__c, Type__c, Applicant_Index__c, Expenditure_Index__c from Expenditure__c WHERE Applicant__c IN:appRes.Applicants];
                if (myexpenditures.size()>0){
                    appRes.Expenditures = myexpenditures;
                }
            }

            if ((showdependants) || (all)){
                List<Dependants__c> mydependants = [Select id, Age__c, Applicant__c, Applicant_Index__c, Dependant_Index__c, First_Name__c, Last_Name__c from Dependants__c WHERE Applicant__c IN : appRes.Applicants];
                if (mydependants.size()>0){
                    appRes.Dependants = mydependants;
                }
            }
        }
        String JSONRes = JSON.serialize(appRes);

        RestContext.response.responseBody = blob.valueOf(JSONRes);
        return appRes;
    }

    global class APPResponse{
        public String Status;
        public List<String> Detail;
        public Application__c Application;
        public List<Applicant__c> Applicants;
        public List<Property__c> Properties;
        public List<Mortgage__c> Mortgages;
        public List<CCJ__c> CCJs;
        public List<Debt__c> Debts;
        public List<Quote__c> Quotes;
        public List<Stage_History__c> StageHistories;
        public List<Outstanding_Items__c> OutstandingItems;
        public List<Applicant_Income__c> ApplicantIncomes;
        public List<Expenditure__c> Expenditures;
        public List<Dependants__c> Dependants;

        global AppResponse(string in_Status, List<String> in_Detail){
                this.Status = in_Status;
                this.Detail = in_Detail;
        }
        global AppResponse(){
            Detail = new List<String>();
        }
    }
}