@RestResource(urlMapping='/sec/getAccount')
//////////////////////////////////////////////////
//
//   Created by Pavel Kashko
//   11/01/2016
//
//////////////////////////////////////////////////
global class SECAPIgetAccount {

    private static List<String> ErrorsList = new List<String>();
    private static Boolean HasRequiredParams = false;
    private static Boolean ShowContacts = false;
    private static Boolean ShowAllData = false;
    private static String AccountId;

    @HttpPost
    global static AccountResponse getAccountDetails(){
        readInputParameters();
        if(!HasRequiredParams){
            return getAccountResponseWithError('No valid input parameter data sent');
        }
        AccountResponse acc_response = new AccountResponse();
        if ([SELECT COUNT() FROM Account WHERE Id=:AccountId] < 1){
            RestContext.response.statusCode = 400;
            acc_response.Status = 'Rejected';
            acc_response.Detail.add('No such applicant record.');
        }else{
            RestContext.response.statusCode = 200;
            acc_response.Status = 'Success';
            acc_response.Account = getAccount();
            acc_response.Contacts = getContacts();
        }
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(acc_response));
        return acc_response;
    }

    private static void readInputParameters(){
        Map<String, String> parameters_map = new Map<String, String>();
        for(String key:RestContext.request.params.keyset()){
            parameters_map.put(key.toUpperCase(), RestContext.request.params.get(key));
        }
        if(String.isNotBlank(parameters_map.get('ID'))){
            AccountId = parameters_map.get('ID');
            HasRequiredParams = true;
        }
        if(parameters_map.get('CONTACTS') == 'Y'){
            ShowContacts = true;
            HasRequiredParams = true;
        }
        if(parameters_map.get('ALL') == 'Y'){
            ShowAllData = true;
            HasRequiredParams = true;
        }
        if (!ShowContacts && !ShowAllData){
            ErrorsList.add('Data Set parameter required');
            HasRequiredParams = false;
        }
    }

    private static AccountResponse getAccountResponseWithError(String error_text){
        ErrorsList.add(error_text);
        AccountResponse acc_response = new AccountResponse('Error', ErrorsList);
        RestContext.response.statusCode = 400;
        RestContext.response.responseBody = blob.valueOf(JSON.serialize(acc_response));
        return acc_response;
    }

    private static Account getAccount(){
        return [SELECT Id, Name, CreatedDate FROM Account WHERE Id=:AccountId];
    }

    private static List<Contact> getContacts(){
        return [SELECT Id, Name, CreatedDate FROM Contact WHERE AccountId=:AccountId];
    }

    global class AccountResponse{
        public String Status;
        public List<String> Detail;
        public Account Account;
        public List<Contact> Contacts;

        global AccountResponse(string status, List<String> detail){
            this.Status = status;
            this.Detail = detail;
        }

        global AccountResponse(){
            this.Detail = new List<String>();
        }
    }
}