@RestResource(urlMapping='/sec/application')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   15/09/2014
//
/////////////////////////////////////////////////

// 13/10/2014 - if username sent then create password - Simon Parker
// 17/10/2014 - inclusion of Property_index__c on Mortgage due to data model change - Simon Parker
// 30/10/2014 - removed mobile phone as required on applicant - SRP
// 21/01/2015 - SEC-248 & SEC-286 - changes to include User Profile - SRP
// 15/04/2015 - SEC-418 - GET method added
// 15/04/2015 - SEC-420 - Add Dependants to POST
// 23/04/2015 - SEC-475 - Inclusion of Applicant_Income
// 20/05/2015 - SEC-516 - Applicant Index added to Debts and CCJS - SRP
// 03/06/2015 - SEC-525 - Applicant Income fixed to take Applicant ID on update - SRP
// 04/06/2015 - SEC-529 - Debts and CCJS tidied up on Update - duplicate code removed - SRP
// 29/06/2015 - SEC-541 -  Dependants update fix - SRP

global class SECAPIApplication {

    public static SECAPI_Response_Application response;

    @HttpPost
    global static SECAPI_Response_Application doPost(String action, String applicationID, String userprofileID, Application__c application, List<Applicant__c> applicants,List<Dependants__c> dependants, List<Applicant_Income__c> applicant_incomes, List<Expenditure__c> expenditures, List<Property__c> properties, List<Mortgage__c> mortgages, List<CCJ__c> ccjs, List<Debt__c> debts)  {

        response = new SECAPI_Response_Application();
        response.setStatus('success');
        response.setSuccessMessage('');
        response.setFailureMessage('');
        response.setAppId('');
        response.setPassword('');
        response.setUserNameEmailExists(false);

        if (string.isBlank(action)){
            response.setFailureMessage('action is required');
        }
        if (action != 'create' && action !='update' && !string.isBlank(action)){
            response.setFailureMessage('action can only be Create or Update');
        }
        if (action == 'update' && String.isBlank(applicationID)){
            response.setFailureMessage('Must supply an ApplicationID for an update action');
        }
        if (action == 'create' && !String.isBlank(applicationID)){
            response.setFailureMessage('Must not supply an ApplicationID for a create action');
        }
        /*
        if (action == 'create' && (String.isBlank(userprofileID)) && (String.isBlank(applicants[0].Email_Address__c) || String.isBlank(applicants[0].Mobile_Phone__c))){
            lstErrors.add('Must supply Email and Mobile if creating without existing User Profile ID');
        }
        */
        checkApplicationData(application);
        if(applicants != null){
            for (Applicant__c a : applicants){
                checkApplicantData(a, true);
            }
        }
        if (applicant_incomes != null){
            for (Applicant_Income__c ai: applicant_incomes){
                checkApplicantIncomeData(ai);
            }
        }
        if (expenditures != null){
            for (Expenditure__c exp: expenditures){
                checkExpenditureData(exp);
            }
        }
        if (dependants != null){
            for (Dependants__c d : dependants){
                checkDependantData(d);
            }
        }
        if (properties != null){
            for (Property__c p : properties){
                checkPropertyData(p);
            }
        }
        if (mortgages != null){
            for (Mortgage__c m : mortgages){
                checkMortageData(m);
            }
        }
        if (ccjs != null){
            for (CCJ__c c : ccjs){
                checkCCJData(c);
            }
        }
        if (debts != null){
            for (Debt__c d : debts){
                checkDebtData(d);
            }
        }
        //Data quality or Data Transformation returns 400 response - bad data.
        if(response.failureMessage != ''){
            response.setStatus('failure');
        }
        // No error so process data received
        if ((action == 'create') && (response.failureMessage == '')){
            Savepoint sp = Database.setSavepoint();
            try{
                //Get email address of first applicant and check for existing user profiles
                List<User_Profile__c> existingUP = [Select id from User_Profile__c WHERE username__c = :applicants[0].email_address__c ];
                if (existingUP.size()>0){
                    response.setUserNameEmailExists(true);
                    //usernameexists = true;
                }

                insert application;

                ID applID = application.id;
                if (applicants != null){
                    for (Applicant__c a : applicants){
                        a.Application__c = applID;
                    }
                    insert applicants;

                    // 23/04/2015 - modified to convert Applicant to ApplicantIncome

                    List<Applicant_Income__c> newApplicantIncomes = new List<Applicant_Income__c>();
                    for (Applicant__c a : applicants){
                        Applicant_Income__c newapplicantincome = converApplicanttoNewApplicantIncome(a);
                        newapplicantincome.Applicant__c = a.id;
                        newApplicantIncome.Applicant_Income_Index__c = 99;
                        newApplicantIncome.Applicant_Index__c = a.Applicant_Index__c;
                        newApplicantIncomes.add(newApplicantIncome);
                    }
                    insert newApplicantIncomes;

                }

                if (!response.usernameemailexists){
                    string upid = Login_util.createUserProfile(applID);
                    if (upid != null){
                        application.User_Profile__c = upid;
                        response.setUserProfileId(upid);
                        response.setPassword([Select password__c from User_Profile__c WHERE id=:upid LIMIT 1].password__c);
                    }
                    update application;
                }

                // 15/04/2015 - map Applicant ID to Applicant index
                Map<Integer,ID> mapApplicantIndex  = new Map<Integer,ID>();
                for (Applicant__c theApplicant : applicants){
                    mapApplicantIndex.put(integer.valueOf(theApplicant.Applicant_Index__c), theApplicant.id);
                }
                // 23/04/2015 - Applicant_Income added
                if (applicant_incomes != null){
                    for (Applicant_Income__c ai : applicant_incomes){
                        ai.Applicant__c = mapApplicantIndex.get(integer.valueOf(ai.Applicant_Index__c));
                    }
                    insert applicant_incomes;
                }

                if (expenditures != null){
                    for (Expenditure__c exp : expenditures){
                        exp.Applicant__c = mapApplicantIndex.get(integer.valueOf(exp.Applicant_Index__c));
                    }
                    insert expenditures;
                }

                if (dependants != null){
                    for (Dependants__c d : dependants){
                        d.Applicant__c = mapApplicantIndex.get(integer.valueOf(d.Applicant_Index__c));
                    }
                    insert dependants;
                }


                if(properties != null){
                    for (Property__c p : properties){
                        p.Application__c = applID;
                        if(p.Applicant_Index__c > 0){
                            p.Applicant__c = mapApplicantIndex.get(integer.valueOf(p.Applicant_Index__c));
                        }
                    }
                    insert properties;
                }
                // 17/10/2014 - now map Property Id to Property index
                Map<Integer,ID> mapPropertyIndex = new Map<Integer,ID>();
                for (Property__c theProp : properties){
                    mapPropertyIndex.put(integer.valueof(theProp.Property_index__c), theProp.id);
                }

                if(mortgages !=null){
                    for (Mortgage__c m : mortgages){
                    m.Application__c = applID;
                    //17/10/2014
                    m.Property__c = mapPropertyIndex.get(integer.valueOf(m.Property_index__c));
                    }
                    insert mortgages;
                }
                if(ccjs != null){
                    for (CCJ__c c : ccjs){
                    c.Application__c = applID;
                    c.Applicant__c = mapApplicantIndex.get(integer.valueOf(c.Applicant_Index__c));
                    }
                    insert ccjs;
                }
                if(debts != null){
                    for (Debt__c d : debts){
                    d.Application__c = applID;
                    d.Applicant__c = mapApplicantIndex.get(integer.valueOf(d.Applicant_Index__c));
                    }
                    insert debts;
                }

            }
            catch(Exception ex){
                response.setStatus('error');
                response.setFailureMessage(ex.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@@@ Error message = ' + ex.getMessage());
                Database.rollback(sp);
            }
            response.setAppId(application.id);

        }

        if ((action == 'update') && (response.failureMessage == '')){
             Savepoint sp = Database.setSavepoint();
            try{
                application.id = id.valueOf(applicationID);
                update Application;
                if (applicants != null){
                    Set<Decimal> applicantIndexes = new Set<Decimal>();
                    for (Applicant__c a : applicants){
                        applicantIndexes.add(a.Applicant_Index__c);
                    }
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    List<Applicant__c> existApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID) AND Applicant_Index__c IN : applicantIndexes];
                    for (Applicant__c exa : existApplicants){
                        mapApplicantIndex.put(integer.valueOf(exa.Applicant_Index__c), exa.id);
                    }
                    for (Applicant__c a : applicants){
                        a.id = mapApplicantIndex.get(integer.valueOf(a.Applicant_Index__c));
                        if (a.id == null){
                            a.Application__c = applicationID;
                        }
                    }
                    upsert applicants;
                }
                // 23/04/2015 - Applicant Income added
                if (applicant_incomes != null){
                    Set<Decimal> applicantincomeIndexes = new Set<Decimal>();
                    for (Applicant_Income__c ai : applicant_incomes){
                        applicantincomeIndexes.add(ai.Applicant_Income_Index__c);
                    }
                    List<Applicant__c> theApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID)];
                    Set<ID> theApplicantIDs = new Set<ID>();
                    // 03/06/2015 - SEC-525 fixed map to be applicant index to applicant
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    for (Applicant__c a : theApplicants){
                        theApplicantIDs.add(a.id);
                        mapApplicantIndex.put(Integer.valueOf(a.Applicant_Index__c),a.id);
                    }

                    Map<Decimal,ID> mapApplicantIncomeIndex = new Map<Decimal,ID>();

                    List<Applicant_Income__c> existApplicantIncomes = [Select id, Applicant_Index__c, Applicant__c, Applicant_Income_Index__c from Applicant_Income__c WHERE (Applicant__r.id  IN :theApplicantIDs) AND Applicant_Income_Index__c IN : applicantincomeIndexes];
                    for (Applicant_Income__c exai : existApplicantIncomes){
                        mapApplicantIncomeIndex.put(integer.valueOf(exai.Applicant_Income_Index__c), exai.id);
                    }
                    for (Applicant_Income__c ai : applicant_incomes){
                        ai.id = mapApplicantIncomeIndex.get(Integer.valueOf(ai.Applicant_Income_Index__c));
                         // 03/06/2015 -  SEC-525 fixed map to be applicant index to applicant
                        if (ai.Id == null){
                            ai.Applicant__c = mapApplicantIndex.get(Integer.valueOf(ai.Applicant_Index__c));
                        }
                    }
                    upsert applicant_incomes;
                }

                if (expenditures != null){
                    Set<Decimal> expenditureIndexes = new Set<Decimal>();
                    for (Expenditure__c exp : expenditures){
                        expenditureIndexes.add(exp.Expenditure_Index__c);
                    }
                    List<Applicant__c> theApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID)];
                    Set<ID> theApplicantIDs = new Set<ID>();
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    for (Applicant__c a : theApplicants){
                        theApplicantIDs.add(a.id);
                        mapApplicantIndex.put(Integer.valueOf(a.Applicant_Index__c),a.id);
                    }

                    Map<Decimal,ID> mapExpenditureIndex = new Map<Decimal,ID>();

                    List<Expenditure__c> existExpenditures = [Select id, Applicant_Index__c, Applicant__c, Expenditure_Index__c from Expenditure__c WHERE (Applicant__r.id  IN :theApplicantIDs) AND Expenditure_Index__c IN : expenditureIndexes];
                    for (Expenditure__c exexp : existExpenditures){
                        mapExpenditureIndex.put(integer.valueOf(exexp.Expenditure_Index__c), exexp.id);
                    }
                    for (Expenditure__c exp : expenditures){
                        exp.id = mapExpenditureIndex.get(Integer.valueOf(exp.Expenditure_Index__c));
                        if (exp.Id == null){
                            exp.Applicant__c = mapApplicantIndex.get(Integer.valueOf(exp.Applicant_Index__c));
                        }
                    }
                    upsert expenditures;
                }

                // 15/04/2015 - Dependants added
                if (dependants != null){
                    Set<Decimal> dependantIndexes = new Set<Decimal>();
                    for (Dependants__c d : dependants){
                        dependantIndexes.add(d.Dependant_Index__c);
                    }
                    List<Applicant__c> theApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID)];
                    Set<ID> theApplicantIDs = new Set<ID>();
                    // 29/06/2015 - SEC-541 fixed map dependants
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    for (Applicant__c a : theApplicants){
                        theApplicantIDs.add(a.id);
                        mapApplicantIndex.put(Integer.valueOf(a.Applicant_Index__c),a.id);
                    }

                    Map<Decimal,ID> mapDependantIndex = new Map<Decimal,ID>();
                    List<Dependants__c> existDependants = [Select id, Dependant_Index__c from Dependants__c WHERE (Applicant__r.id  IN :theApplicantIDs) AND Dependant_Index__c IN : dependantIndexes];
                    for (Dependants__c exd : existDependants){
                        mapDependantIndex.put(integer.valueOf(exd.Dependant_Index__c), exd.id);
                    }
                    for (Dependants__c d : dependants){
                        d.id = mapDependantIndex.get(integer.valueOf(d.Dependant_Index__c));
                          // 29/06/2015 - SEC-541 Fix for dependants update
                        if (d.id == null){
                            d.Applicant__c = mapApplicantIndex.get(Integer.valueOf(d.Applicant_Index__c));
                        }
                    }
                    upsert dependants;
                }

                if (debts != null){
                    Set<Decimal> debtIndexes = new Set<Decimal>();
                    for (Debt__c d : debts){
                        debtIndexes.add(d.Debt_Index__c);
                    }
                    Map<Decimal,ID> mapDebtIndex = new Map<Decimal,ID>();
                    List<Debt__c> existDebts = [Select id, Debt_Index__c from Debt__c WHERE (Application__r.id =:applicationID) AND Debt_Index__c IN :debtIndexes];
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    List<Applicant__c> theApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID)];
                    for (Applicant__c a : theApplicants){
                        mapApplicantIndex.put(Integer.valueOf(a.Applicant_Index__c),a.id);
                    }

                    for (Debt__c exd : existDebts){
                        mapDebtIndex.put(integer.valueOf(exd.Debt_Index__c), exd.id);
                    }
                    for (Debt__c d : debts){
                        d.id = mapDebtIndex.get(integer.valueOf(d.Debt_Index__c));
                        if (d.id == null){
                            d.Application__c = applicationID;
                            d.Applicant__c = mapApplicantIndex.get(Integer.valueOf(d.Applicant_Index__c));
                        }
                    }
                    upsert debts;
                }

                if (ccjs != null){
                    Set<Decimal> CCJIndexes = new Set<Decimal>();
                    for (CCJ__c c : ccjs){
                        CCJIndexes.add(c.CCJ_Index__c);
                    }
                    List<Applicant__c> theApplicants = [Select id, Applicant_Index__c from Applicant__c WHERE (Application__r.id =:applicationID)];
                    Set<ID> theApplicantIDs = new Set<ID>();
                    Map<Decimal,ID> mapApplicantIndex = new Map<Decimal,ID>();
                    for (Applicant__c a : theApplicants){
                        theApplicantIDs.add(a.id);
                        mapApplicantIndex.put(Integer.valueOf(a.Applicant_Index__c),a.id);
                    }

                    Map<Decimal,ID> mapCCJIndex = new Map<Decimal,ID>();
                    List<CCJ__c> existCCJs = [Select id, CCJ_Index__c from CCJ__c WHERE (Application__r.id =:applicationID) AND CCJ_Index__c IN : ccjIndexes];
                    for (CCJ__c exccj : existCCJs){
                        mapCCJIndex.put(integer.valueOf(exccj.CCJ_Index__c), exccj.id);
                    }
                    for (CCJ__c c : ccjs){
                        c.id = mapCCJIndex.get(integer.valueOf(c.CCJ_Index__c));
                        if (c.id == null){
                            c.Application__c = applicationID;
                            c.Applicant__c = mapApplicantIndex.get(Integer.valueOf(c.Applicant_Index__c));
                        }
                    }
                    upsert ccjs;
                }


                if (properties != null){
                    Set<Decimal> propertyIndexes = new Set<Decimal>();
                    for (Property__c p : properties){
                        propertyIndexes.add(p.Property_Index__c);
                    }
                    Map<Decimal,ID> mapPropertyIndex = new Map<Decimal,ID>();
                    List<Property__c> existProperties = [Select id, Property_Index__c from Property__c WHERE (Application__r.id =:applicationID) AND Property_Index__c IN : propertyIndexes];
                    for (Property__c exp : existProperties){
                        mapPropertyIndex.put(integer.valueOf(exp.Property_Index__c), exp.id);
                    }
                    for (Property__c p : properties){
                        p.id = mapPropertyIndex.get(integer.valueOf(p.Property_Index__c));
                        if (p.id == null){
                            p.Application__c = applicationID;
                        }
                    }
                    upsert properties;
                }
                if (mortgages != null){
                    Set<Decimal> mortgageIndexes = new Set<Decimal>();
                    for (Mortgage__c m : mortgages){
                        mortgageIndexes.add(m.Mortgage_Index__c);
                    }
                    Map<Decimal,ID> mapMortgageIndex = new Map<Decimal,ID>();
                    List<Mortgage__c> existMortgages = [Select id, Mortgage_Index__c from Mortgage__c WHERE (Application__r.id =:applicationID) AND Mortgage_Index__c IN : mortgageIndexes];
                    for (Mortgage__c exm : existMortgages){
                        mapMortgageIndex.put(integer.valueOf(exm.Mortgage_Index__c), exm.id);
                    }
                    for (Mortgage__c m : mortgages){
                        m.id = mapMortgageIndex.get(integer.valueOf(m.Mortgage_Index__c));
                        if (m.id == null){
                            m.Application__c = applicationID;
                        }
                    }
                    upsert mortgages;
                }

            }
            catch(Exception ex){
                response.setStatus('error');
                response.setFailureMessage(ex.getMessage());
                Database.rollback(sp);
            }
        }
    return response;
    }

    @HTTPGet
    global static SECAPI_Response_Application doGet(){

        response = new SECAPI_Response_Application();
        response.setStatus('success');
        response.setSuccessMessage('');
        response.setFailureMessage('');
        response.setAppId('');
        response.setPassword('');
        response.setUserNameEmailExists(false);
        response.setUserProfileId('');

        RestRequest req = RestContext.request;
        Map<String,String> requestparams = req.params;
        Map<String,String> alllabelsandfields = getAllLabelsandFields();
        Set<String> requestLabels = requestparams.keySet();
        Map<String,String> fieldsandvalues = new Map<String,String>();
        for(String label : requestLabels){
            fieldsandvalues.put(alllabelsandfields.get(label),requestparams.get(label));
        }

        Application__c newApplication = (Application__c) CreateSOjects('Application__c', maptoJSON(getObjectfieldsandvalues('Application__c',fieldsandvalues)));
        Applicant_Income__c newApplicantIncome = (Applicant_Income__c)  CreateSOjects('Applicant_Income__c', maptoJSON(getObjectfieldsandvalues('Applicant_Income__c',fieldsandvalues)));
        Applicant__c newApplicant =  (Applicant__c) CreateSOjects('Applicant__c', maptoJSON(getObjectfieldsandvalues('Applicant__c',fieldsandvalues)));
        Property__c newProperty =  (Property__c) CreateSOjects('Property__c', maptoJSON(getObjectfieldsandvalues('Property__c',fieldsandvalues)));
        Mortgage__c newMortgage =  (Mortgage__c) CreateSOjects('Mortgage__c', maptoJSON(getObjectfieldsandvalues('Mortgage__c',fieldsandvalues)));

        checkApplicationData(newApplication);
        if(newApplicant != null){
            checkApplicantData(newApplicant, false);
        }

        //Data quality or Data Transformation returns 400 response - bad data.
        if(response.failureMessage != ''){
            response.setStatus('failure');
        }
        // No error so process data received
        if (response.failureMessage == ''){
            Savepoint sp = Database.setSavepoint();
            try{
                //Get email address of first applicant and check for existing user profiles
                List<User_Profile__c> existingUP = [Select id from User_Profile__c WHERE username__c = :newApplicant.email_address__c ];
                if (existingUP.size()>0){
                    response.setUserNameEmailExists(true);
                }
                insert newApplication;

                ID applID = newApplication.id;
                if (newApplicant != null){
                    newApplicant.Application__c = applID;
                    newApplicant.Applicant_Index__c = 1;
                    insert newApplicant;
                }

                // 23/04/2015 - modified to convert Applicant to ApplicantIncome

                Applicant_Income__c updatedapplicantincome = convertApplicanttoApplicantIncome(newApplicant, newApplicantIncome);
                updatedapplicantincome.Applicant__c = newApplicant.id;
                updatedapplicantincome.Applicant_Income_Index__c = 1;
                updatedapplicantincome.Applicant_Index__c = newApplicant.Applicant_Index__c;
                insert updatedapplicantincome;

                Applicant__c updatedApplicant = setApplicantFieldstoNull(newApplicant);
                update updatedApplicant;

                if (!response.usernameemailexists){
                    string upid = Login_util.createUserProfile(applID);
                    if (upid != null){
                        newApplication.User_Profile__c = upid;
                        response.setUserProfileId(upid);
                        response.setPassword([Select password__c from User_Profile__c WHERE id=:upid LIMIT 1].password__c);
                    }
                    update newApplication;
                }
                 if(newProperty != null){
                    newProperty.Application__c = applID;
                    insert newProperty;
                }
                if(newMortgage !=null){
                    newMortgage.Application__c = applID;
                    insert newMortgage;
                }
            }
            catch(Exception ex){
                response.setStatus('error');
                response.setFailureMessage(ex.getMessage());
                system.debug('@@@@@ Error message = ' + ex.getMessage());
                Database.rollback(sp);
            }
            response.setAppId(newApplication.id);
        }
        return response;
    }



    private static void checkApplicationData(Application__c application){
            if (String.isBlank(application.Account__c)) {
                response.setFailureMessage('Account is required');
            }
            if (String.isBlank(application.Campaign__c)) {
                response.setFailureMessage('Campaign is required');
            }
            if ((application.Loan_Amount__c == 0)||(application.Loan_Amount__c == null)) {
                response.setFailureMessage('Loan Amount is required');
            }
            if (String.isBlank(application.Application_Type__c)){
                 response.setFailureMessage('Application Type is required');
            }
    }

    private static void checkApplicantData(Applicant__c thisapp, Boolean indexRequired){
            if (String.isBlank(thisapp.First_Name__c)) {
                response.setFailureMessage('First Name is required');
            }
            if (String.isBlank(thisapp.Last_Name__c)) {
                response.setFailureMessage('Last Name is required');
            }
            if (String.isBlank(thisapp.Email_Address__c)) {
                response.setFailureMessage('Email address is required');
            }
            if (indexRequired){
                 if ((thisapp.Applicant_Index__c == 0)||(thisapp.Applicant_Index__c == null)) {
                    response.setFailureMessage('Applicant index is required');
                }
            }
    }

    private static void checkApplicantIncomeData(Applicant_Income__c thisappincome){
            if ((thisappincome.Applicant_Index__c == 0)||(thisappincome.Applicant_Index__c == null)) {
                response.setFailureMessage('Applicant index on Applicant_Income is required');
            }
            if ((thisappincome.Applicant_Income_Index__c ==0)||(thisappincome.Applicant_Income_Index__c == null)){
                response.setFailureMessage('Applicant_Income index on Applicant_Income is required');
            }
    }

    private static void checkExpenditureData(Expenditure__c exp){
            if ((exp.Applicant_Index__c == 0)||(exp.Applicant_Index__c == null)) {
                response.setFailureMessage('Applicant index on Expenditure is required');
            }
            if ((exp.Expenditure_Index__c ==0)||(exp.Expenditure_Index__c == null)){
                response.setFailureMessage('Expenditure index on Expenditure is required');
            }
    }

    private static void checkDependantData(Dependants__c thisdep){
            if ((thisdep.Applicant_Index__c == 0)||(thisdep.Applicant_Index__c == null)) {
                response.setFailureMessage('Dependant Applicant index is required');
            }
            if ((thisdep.Dependant_Index__c == 0)||(thisdep.Dependant_Index__c == null)) {
                response.setFailureMessage('Dependant index is required');
            }
    }

    private static void checkPropertyData(Property__c thisprop){
        if ((thisprop.Property_Index__c == 0)||(thisprop.Property_Index__c == null)) {
                response.setFailureMessage('Property index is required');
            }
    }

    private static void checkMortageData(Mortgage__c thismort){
        if ((thismort.Mortgage_Index__c == 0)||(thismort.Mortgage_Index__c == null)) {
                response.setFailureMessage('Mortgage index is required');
            }
        // 17/10/2014 - added
         if ((thismort.Property_Index__c == 0)||(thismort.Property_Index__c == null)) {
                response.setFailureMessage('Property index on Mortgage is required');
            }
    }

    private static void checkCCJData(ccj__c thisccj){
        if ((thisccj.CCJ_Index__c == 0)||(thisccj.CCJ_Index__c == null)) {
                response.setFailureMessage('CCJ index is required');
            }
    }

    private static void checkDebtData(debt__c thisdebt){
        if ((thisdebt.Debt_Index__c == 0)||(thisdebt.Debt_Index__c == null)) {
            response.setFailureMessage('Debt index is required');
        }
    }

    private static Map<String,String> getAllLabelsandFields(){
        Map<String,String> alllabelsandfields = customFieldsandLabels('Application__c');
        alllabelsandfields.putAll(customFieldsandLabels('Applicant_Income__c'));
        alllabelsandfields.putAll(customFieldsandLabels('Applicant__c'));
        alllabelsandfields.putAll(customFieldsandLabels('Property__c'));
        alllabelsandfields.putAll(customFieldsandLabels('Mortgage__c'));


        return alllabelsandfields;
    }

    private static Map<String,String> getObjectfieldsandvalues(String objectname, Map<String,String> allfieldsandvalues){
        Map<String,String> thisObject = new Map<String,String>();
        Set<String> fullfieldnames = allfieldsandvalues.keySet();
        for (String fieldname : fullfieldnames){
            if (fieldname != null){
                if (fieldname.split('\\.')[0] == objectname){
                    thisObject.put(fieldname.split('\\.')[1],allfieldsandvalues.get(fieldname));
                }
            }

        }
        return thisObject;
    }

    private static String maptoJSON(Map<String,String> objectmap){
        return JSON.serialize(objectmap);
    }

    private static SObject CreateSOjects(String sObjectApiName, String jSONSObject)
    {
        Map<String, Object> fieldMap = (Map<String, Object>)JSON.deserializeUntyped(jSONSObject);
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectApiName);
        SObject newSobject = targetType.newSObject();
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        for (String key : fieldMap.keySet())
        {
            Object value = fieldMap.get(key);
            Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
            if (value instanceof String && valueType != Schema.DisplayType.String)
            {
                String svalue = (String)value;
                if (valueType == Schema.DisplayType.Date)
                    newSobject.put(key, Date.valueOf(svalue));
                else if(valueType == Schema.DisplayType.DateTime)
                    newSobject.put(key, DateTime.valueOfGmt(svalue));
                else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency)
                    newSobject.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Double)
                    newSobject.put(key, svalue == '' ? null : Double.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Integer)
                    newSobject.put(key, Integer.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Base64)
                    newSobject.put(key, Blob.valueOf(svalue));
                else if (valueType == Schema.DisplayType.Boolean){
                    if (svalue == 'true'){
                        newSobject.put(key, true);
                    }
                }
                else
                    newSobject.put(key, svalue);
            }
            else
                newSobject.put(key, value);
        }
        return newSobject;
    }

    private static Map<String,String> customFieldsandLabels(String objectName){

        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String,String> maplabelstofields = new Map<String,String>();
        for (String fieldName: fieldMap.keySet()) {
            if (fieldMap.get(fieldName).getDescribe().isCustom()){
                 maplabelstofields.put(fieldMap.get(fieldName).getDescribe().getLabel().replaceAll( '\\s+', ''),objectName+'.'+fieldName);
            }
        }
        return maplabelstofields;
    }

    // 23/04/2015 Applicant_Income added
    private static Applicant_Income__c convertApplicanttoApplicantIncome(Applicant__c applicant, Applicant_Income__c new_Applicant_Income){
        //go through fields on Applicant and map to new Applicant_Income record - using the builder - and clear from Applicant
        ApplicantIncomeBuilder newApplicantIncome = ApplicantIncomeBuilder.getBuilder(new_Applicant_Income);
        return convertApplicantwithBuilder(applicant, newApplicantIncome);
    }

    private static Applicant_Income__c converApplicanttoNewApplicantIncome(Applicant__c applicant){
        ApplicantIncomeBuilder newApplicantIncome = ApplicantIncomeBuilder.getBuilder(applicant);
        return convertApplicantwithBuilder(applicant, newApplicantIncome);
    }

    private static Applicant_Income__c convertApplicantwithBuilder(Applicant__c applicant, ApplicantIncomeBuilder newApplicantIncome){

        if (applicant.Occupation__c != null)(newApplicantIncome.setOccupation(applicant.Occupation__c));
        if (applicant.Of_Company_Owned__c != null)(newApplicantIncome.setOfCompanyOwned(integer.valueOf(applicant.Of_Company_Owned__c)));
        if (applicant.Company_Registration_Number__c != null)(newApplicantIncome.setCompanyRegNumber(applicant.Company_Registration_Number__c));
        if (applicant.Company_Type__c != null)(newApplicantIncome.setCompanyType(applicant.Company_Type__c));
        if (applicant.Contract_Length_Months__c != null)(newApplicantIncome.setContractLengthMonths(integer.valueOf(applicant.Contract_Length_Months__c)));
        if (applicant.Employer_Address__c != null)(newApplicantIncome.setEmployerAddress(applicant.Employer_Address__c));
        if (applicant.Employer_Town__c != null)(newApplicantIncome.setEmployerTown(applicant.Employer_Town__c));
        if (applicant.Employer_Name__c != null)(newApplicantIncome.setEmployerName(applicant.Employer_Name__c));
        if (applicant.Employer_Phone_Number__c != null)(newApplicantIncome.setEmployerPhoneNumber(applicant.Employer_Phone_Number__c));
        if (applicant.Employer_Postcode__c != null)(newApplicantIncome.setEmployerPostcode(applicant.Employer_Postcode__c));
        if (applicant.Employment_Status__c != null)(newApplicantIncome.setEmployerStatus(applicant.Employment_Status__c));
        if (applicant.Gross_Annual_Income__c != null)(newApplicantIncome.setGrossAnnualIncome(applicant.Gross_Annual_Income__c));
        if (applicant.Gross_Monthly_Income__c != null)(newApplicantIncome.setGrossMonthlyIncome(applicant.Gross_Monthly_Income__c));
        if (applicant.Income_Proof__c != null)(newApplicantIncome.setIncomeProof(applicant.Income_Proof__c));
        if (applicant.Net_Annual_Income__c != null)(newApplicantIncome.setNetAnnualIncome(applicant.Net_Annual_Income__c));
        if (applicant.Net_Monthly_Income__c != null)(newApplicantIncome.setNetMonthlyIncome(applicant.Net_Monthly_Income__c));
        if (applicant.Pay_Frequency__c != null)(newApplicantIncome.setPayFrequency(applicant.Pay_Frequency__c));
        if (applicant.Rolling_Contract__c != null)(newApplicantIncome.setRollingContract(applicant.Rolling_Contract__c));
        if (applicant.Time_in_Employment_Months__c != null)(newApplicantIncome.setTimeInEmploymentMonths(integer.valueOf(applicant.Time_in_Employment_Months__c)));
        if (applicant.Time_in_Employment_Years__c != null)(newApplicantIncome.setTimeInEmploymentYears(integer.valueOf(applicant.Time_in_Employment_Years__c)));

        return newApplicantIncome.getRecord();

    }

    // 23/04/2015 Applicant_Income added
    private static Applicant__c setApplicantFieldstoNull(Applicant__c applicant){
        // sets Applicant fields used on Applicant_Income to null to prevent duplication
        applicant.Occupation__c = null;
        applicant.Of_Company_Owned__c = null;
        applicant.Company_Registration_Number__c = null;
        applicant.Company_Type__c = null;
        applicant.Contract_Length_Months__c = null;
        applicant.Employer_Address__c = null;
        applicant.Employer_Name__c = null;
        applicant.Employer_Phone_Number__c = null;
        applicant.Employer_Postcode__c = null;
        applicant.Employment_Status__c = null;
        applicant.Gross_Annual_Income__c = null;
        applicant.Gross_Monthly_Income__c = null;
        applicant.Income_Proof__c = null;
        applicant.Net_Annual_Income__c = null;
        applicant.Net_Monthly_Income__c = null;
        applicant.Pay_Frequency__c = null;
        applicant.Rolling_Contract__c = false;
        applicant.Time_in_Employment_Months__c = null;
        applicant.Time_in_Employment_Years__c = null;

        return applicant;
    }


    global class SECAPI_Response_Application extends SECAPI_Response {

        public String appId;
        public String password;
        public String userprofileid;
        public Boolean usernameemailexists;

        global SECAPI_Response_Application() {

        }

        public SECAPI_Response_Application setAppId(String inappid){
            appId = inappid;
            return this;
        }

        public SECAPI_Response_Application setPassword(String inpassword){
            password = inpassword;
            return this;
        }

        public SECAPI_Response_Application setUserProfileId(String inuserprofileid){
            userprofileid = inuserprofileid;
            return this;
        }

        public SECAPI_Response_Application setUserNameEmailExists(Boolean inexists){
            usernameemailexists = inexists;
            return this;
        }
    }
}