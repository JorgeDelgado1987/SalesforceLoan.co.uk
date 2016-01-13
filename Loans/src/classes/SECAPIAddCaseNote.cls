@RestResource(urlMapping='/sec/addcasenote')
global without sharing class SECAPIAddCaseNote {

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   13/01/2015
//
/////////////////////////////////////////////////

    public static List<string> lstErrors;
    public static List<string> lstResponse;
    public static String appID;
    public static String note;
    public static String type ;
    public static List<String> lstvisibleTos;
    public static String errorStr;

	@HttpPost

	global static CaseNoteResponse doPost() {

		Map<String, Object> requestParams = ParseRequest();
                                                
        CaseNoteResponse response;
        String status = 'success';
        errorStr = '';
        String successStr = '';
        lstErrors = new list<string>();

        if (validateRequest(requestParams)){
            status = 'failed';
             if(lstErrors.size() > 0){
                for (String s : lstErrors){
                    errorStr = errorStr + s + ' : ';
                }
            }
        }

        else {
            if (createNote()){
                successStr = 'New note created OK';
            }
            else{
                status = 'failed';
            }
        }

		response = new CaseNoteResponse(status, successStr, errorStr);

        return response;

	}

private static Map<String, Object> ParseRequest() {
        Map<String, Object> retVal = new Map<String, Object>();
        RestRequest req = RestContext.request;
        
        if (RestContext.request.requestBody != null && RestContext.request.requestBody.ToString() != '') {
            retVal = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.ToString());
        }
        else {
            retVal = RestContext.request.params;
        }
        
        System.debug(retVal);
        
        return retVal;
    }

private static Boolean validateRequest(Map<String, Object> sentParams) {

    boolean hasErrors = false;
    appID =  (string)sentParams.get('appID');
    note = (string)sentParams.get('note');
    type = (string)sentParams.get('type');
    List<object> visibletos = (List<object>)sentParams.get('visibletos');

    if (appID == null){
         lstErrors.add('appID is required');
         hasErrors = TRUE;
    }

    if (note == null){
         lstErrors.add('note is required');
         hasErrors = TRUE;
    }

    if (type == null){
         lstErrors.add('type is required');
         hasErrors = TRUE;
    }

    if (visibletos.size() == 0){
         lstErrors.add('one or more visibleto is required');
         hasErrors = TRUE;
    }

    //check record exists for appID
    List<Application__c> theapps = [Select id from Application__c WHERE id=:appID];
    if (theapps.size()==0){
         lstErrors.add('appID is not a valid Application ID.');
         hasErrors = TRUE;
    }

    //check for types
    List<String> typeValues = getPicklistValues('Case_Note__c', 'Type__c');
    Set<String> setTypeValues = new Set<String>();
    setTypeValues.addAll(typeValues);

    if (setTypeValues.contains(type) == false){
        lstErrors.add('type is not a valid Case Note type.');
         hasErrors = TRUE;
    }

    //check for visibletos
    List<String> visibleToValues = getPicklistValues('Case_Note__c', 'Visible_To__c');
    Set<String> setVisibleToValues = new Set<String>();
    setVisibleToValues.addAll(visibleToValues);

    lstvisibleTos = new List<String>();

    For (Object visto : visibletos){
        Map<String, Object> mapVisibleTos = new Map<String, Object>();
        mapVisibleTos = (Map<String, Object>)visto;
        lstvisibleTos.add(string.valueOf(mapVisibleTos.get('visibleto')));
    }

    system.debug('lstvisibleTos = '+lstvisibleTos);

    if (lstvisibleTos.size() == 0){
        lstErrors.add('one or more visibleto is required');
         hasErrors = TRUE;
    }
    else {
        for (String vt : lstvisibleTos){
            if (setVisibleToValues.contains(vt) == false){
                lstErrors.add(vt + ' is not a valid Case Note visibleto type.');
                hasErrors = TRUE;
            }
        }
    }
    return hasErrors;
}

private static Boolean createNote (){

    Boolean notecreatedOK = false;
    Case_Note__c newNote = new Case_Note__c();
    newNote.Application__c = appID;
    newNote.Note__c = note;
    newNote.Type__c = type;
    string visibleTosString = '';
    for (String vt : lstvisibleTos){
        visibleTosString = visibleTosString + vt + ';';
    }
    visibleTosString = visibleTosString.substring(0,visibleTosString.length()-1);

    newNote.Visible_To__c = visibleTosString;

    try{
        insert newNote;
        notecreatedOK = true;
    }
    catch (Exception e){
        errorStr = e.getMessage();
    }

    return notecreatedOK;
}

private static List<String> getPicklistValues(String ObjectApi_name,String Field_name){ 

  List<String> lstPickvals=new List<String>();
  Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
  Sobject Object_name = targetType.newSObject();
  Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
  Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
  Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
  List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
  for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
      lstPickvals.add(a.getValue());//add the value  to our final list
   }

  return lstPickvals;
}

global class CaseNoteResponse {

        public String status;
        public String successMessage;
        public String errorMessage;

            global CaseNoteResponse(String status, String successMessage, String errorMessage) {
                this.status = status;
                this.successMessage = successMessage;
                this.errorMessage = errorMessage;
            }
    }
}