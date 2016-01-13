global class LeadCreateRelatedRecords {

    private static Id DefaultAccountId;
    private static Boolean IsDefaultAccountIdQueried = false;
    private static Id DefaultCampaignId;
    private static Boolean IsDefaultCampaignIdQueried = false;

    webservice static void execute(Id lead_id){
        Lead lead = [SELECT Id, LastName, FirstName, Salutation, Name, Title, Company, Street, City, State, PostalCode, Country,
            Latitude, Longitude, Phone, MobilePhone, Email, Website, PhotoUrl, Description, LeadSource, Status, Industry,
            Rating, AnnualRevenue, NumberOfEmployees, OwnerId, IsConverted, ConvertedDate, ConvertedAccountId, ConvertedContactId,
            EmailBouncedReason, EmailBouncedDate, Application_Loan_Amount__c, Application_Term__c, Application_Loan_Purpose__c,
            Application_Keyword__c, Application_Match_Type__c, Application_Creative__c, Auto_convert_Leads__c, Property_Estimated_Value__c,
            Mortgage_Estimated_Balance__c, Property_Residential_Status__c, Mortgage_Current_Arrears__c, Applicant_Employment_Status__c,
            Applicant_Gross_Monthly_Income__c, Application_Account__c, Application_Ad__c, Application_Ad_Group__c, Application_Type__c,
            Application_Browser__c, Application_Browser_Version__c, Application_Business__c, Application_Device__c, Application_Device_Model__c,
            Application_IP_Address__c, Application_Landing_Page__c, Application_PPC_Campaign__c, Applicant_Date_of_Birth__c,
            Application_Campaign__c, Application_Stage__c, Application_Value__c FROM Lead WHERE Id=:lead_id];
        Application__c app = generateApplication(lead);
        insert app;
        List<SObject> additional_records_to_insert = new List<SObject>();
        additional_records_to_insert.add(generateApplicant(lead, app.id));
        additional_records_to_insert.add(generateProperty(lead, app.id));
        additional_records_to_insert.add(generateMortgage(lead, app.id));
        insert additional_records_to_insert;
    }

    webservice static void executeList(List<Lead> leads_list){
        Map<Id, Application__c> lead_id_to_app_map = new Map<Id, Application__c>();
        for(Lead lead:leads_list){
            if(isApplicableLead(lead)){
                lead_id_to_app_map.put(lead.Id, generateApplication(lead));
            }
        }
        insert lead_id_to_app_map.values();
        List<SObject> additional_records_to_insert = new List<SObject>();
        for(Lead lead:leads_list){
            if(isApplicableLead(lead)){
                Id app_id = lead_id_to_app_map.get(lead.Id).Id;
                additional_records_to_insert.add(generateApplicant(lead, app_id));
                additional_records_to_insert.add(generateProperty(lead, app_id));
                additional_records_to_insert.add(generateMortgage(lead, app_id));
            }
        }
        insert additional_records_to_insert;
    }

    private static Boolean isApplicableLead(Lead lead){
        return (lead.Auto_convert_Leads__c || lead.Application_Account__c == null);
    }

    private static Application__c generateApplication(Lead lead){
        Application__c application = new Application__c();
        application.Lead__c = lead.Id;
        application.Account__c = lead.Application_Account__c;
        if(application.Account__c == null){
            application.Account__c = getDefaultAccountId();
        }
        application.Ad__c = lead.Application_Ad__c;
        application.Ad_Group__c = lead.Application_Ad_Group__c;
        application.Browser__c = lead.Application_Browser__c;
        application.Browser_Version__c = lead.Application_Browser_Version__c;
        application.Business__c = lead.Application_Business__c;
        if(application.Business__c == null){
            application.Business__c = 'Loan.co.uk';
        }
        application.Creative__c = lead.Application_Creative__c;
        application.Device__c = lead.Application_Device__c;
        application.Device_Model__c = lead.Application_Device_Model__c;
        application.IP_Address__c = lead.Application_IP_Address__c;
        application.Keyword__c = lead.Application_Keyword__c;
        application.Landing_Page__c = lead.Application_Landing_Page__c;
        application.Loan_Amount__c = lead.Application_Loan_Amount__c;
        application.Loan_Purpose__c = lead.Application_Loan_Purpose__c;
        application.Match_Type__c = lead.Application_Match_Type__c;
        application.PPC_Campaign__c = lead.Application_PPC_Campaign__c;
        application.Loan_Term_Months__c = lead.Application_Term__c;
        if(lead.Application_Type__c == 'Bridging Loan'){
            application.Application_Type__c = 'Bridging Loan';
        }else if(lead.Property_Residential_Status__c == 'Non homeowner'){
            application.Application_Type__c = 'Unsecured Loan';
        }else{
            application.Application_Type__c = 'Secured Loan';
        }
        application.Campaign__c = lead.Application_Campaign__c;
        if(application.Campaign__c == null){
            application.Campaign__c = getDefaultCampaignId();
        }
        return application;
    }

    private static Id getDefaultAccountId(){
        if(DefaultAccountId == null && !IsDefaultAccountIdQueried){
            List<Account> def_accs = [SELECT Id FROM Account WHERE Name = 'Loan.co.uk Ltd'];
            if(!def_accs.isEmpty()){
              DefaultAccountId = def_accs.get(0).Id;
            }
            IsDefaultAccountIdQueried = true;
        }
        return DefaultAccountId;
    }

    private static Id getDefaultCampaignId(){
        if(DefaultCampaignId == null && !IsDefaultCampaignIdQueried){
            List<Campaign> def_campaigns = [SELECT Id FROM Campaign WHERE Name = 'Hubspot'];
            if(!def_campaigns.isEmpty()){
              DefaultCampaignId = def_campaigns.get(0).Id;
            }
            IsDefaultCampaignIdQueried = true;
        }
        return DefaultCampaignId;
    }

    private static Applicant__c generateApplicant(Lead lead, Id app_id){
        Applicant__c applicant = new Applicant__c();
        applicant.Email_Address__c = lead.Email;
        applicant.Employment_Status__c = lead.Applicant_Employment_Status__c;
        applicant.Gross_Monthly_Income__c = lead.Applicant_Gross_Monthly_Income__c;
        applicant.First_Name__c = lead.FirstName;
        applicant.Last_Name__c = lead.LastName;
        applicant.Title__c = lead.Salutation;
        applicant.Home_Phone__c = lead.Phone;
        applicant.Mobile_Phone__c = lead.MobilePhone;
        applicant.Date_of_Birth__c = lead.Applicant_Date_of_Birth__c;
        applicant.Application__c = app_id;
        return applicant;
    }

    private static Property__c generateProperty(Lead lead, Id app_id){
        Property__c property = new Property__c();
        property.Estimated_Value__c = lead.Property_Estimated_Value__c;
        property.Residential_Status__c = lead.Property_Residential_Status__c;
        property.Street_Name__c = lead.Street;
        property.Town__c = lead.City;
        property.County__c = lead.State;
        property.Postcode__c = lead.PostalCode;
        property.Application__c = app_id;
        return property;
    }

    private static Mortgage__c generateMortgage(Lead lead, Id app_id){
        Mortgage__c mortgage = new Mortgage__c();
        mortgage.Current_Arrears_Amount__c = lead.Mortgage_Current_Arrears__c;
        mortgage.Balance__c = lead.Mortgage_Estimated_Balance__c;
        mortgage.Application__c = app_id;
        return mortgage;
    }
}