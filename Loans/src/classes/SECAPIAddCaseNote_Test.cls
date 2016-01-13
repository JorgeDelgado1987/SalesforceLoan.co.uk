@isTest
private class SECAPIAddCaseNote_Test {
	
	@isTest static void CreateCaseNotedoPostSuccess() {
	
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        List<String> visibletos = new List<String>();
        visibletos.add('Customer');
        visibletos.add('Introducer');

        string newJSON = generateJSON(myApp.ID, 'A case note', 'General Note',visibletos );
		Blob reqBodyBlob = blob.valueOf(newJSON);
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIAddCaseNote.CaseNoteResponse response = SECAPIAddCaseNote.doPost();

        Test.stopTest();

        System.assertEquals('New note created OK',response.successMessage,'New note created from JSON');

    }

    @isTest static void CreateCaseNotedoPostnoAppID() {
	
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        List<String> visibletos = new List<String>();
        visibletos.add('Customer');
        visibletos.add('Introducer');

        string newJSON = generateJSON('', 'A case note', 'General Note',visibletos );
		Blob reqBodyBlob = blob.valueOf(newJSON);
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIAddCaseNote.CaseNoteResponse response = SECAPIAddCaseNote.doPost();

        Test.stopTest();

        System.assertEquals('appID is required : appID is not a valid Application ID. : ',response.errorMessage,'Problem with no App ID');

    }

 @isTest static void CreateCaseNotedoPostnoNote() {
	
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        List<String> visibletos = new List<String>();
        visibletos.add('Customer');
        visibletos.add('Introducer');

        string newJSON = generateJSON(myApp.id, '', 'General Note',visibletos );
		Blob reqBodyBlob = blob.valueOf(newJSON);
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIAddCaseNote.CaseNoteResponse response = SECAPIAddCaseNote.doPost();

        Test.stopTest();

        System.assertEquals('note is required : ',response.errorMessage,'Problem with no Note');

    }

    @isTest static void CreateCaseNotedoPostnoType() {
	
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        List<String> visibletos = new List<String>();
        visibletos.add('Customer');
        visibletos.add('Introducer');

        string newJSON = generateJSON(myApp.id, 'A case note', '',visibletos );
		Blob reqBodyBlob = blob.valueOf(newJSON);
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIAddCaseNote.CaseNoteResponse response = SECAPIAddCaseNote.doPost();

        Test.stopTest();

        System.assertEquals('type is required : type is not a valid Case Note type. : ',response.errorMessage,'Problem with no Type');

    }

 	@isTest static void CreateCaseNotedoPostnoVisibleTos() {
	
		RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        Account account = new Account();
		account.Name = 'First';
		account.Phone = '123456788';
        insert account;

        Application__c myApp = new Application__c();
        myApp.Account__c = account.id;
        insert myApp;

        List<String> visibletos = new List<String>();
        

        string newJSON = generateJSON(myApp.id, 'A case note', 'General Note',visibletos );
		Blob reqBodyBlob = blob.valueOf(newJSON);
        string url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();

        SECAPIAddCaseNote.CaseNoteResponse response = SECAPIAddCaseNote.doPost();

        

        System.assertEquals('one or more visibleto is required : one or more visibleto is required : ',response.errorMessage,'Problem with no VisibleTos');


        visibletos.add('Dangermouse');

        newJSON = generateJSON(myApp.id, 'A case note', 'General Note',visibletos );
		reqBodyBlob = blob.valueOf(newJSON);
        url = System.URL.getSalesforceBaseUrl().toExternalForm() +'/services/apexrest/sec/addcasenote.json';
        req.httpMethod = 'POST';
        req.requestBody = reqBodyBlob;
        RestContext.request = req;
        RestContext.response = res;

        

        response = SECAPIAddCaseNote.doPost();

        Test.stopTest();

        System.assertEquals('Dangermouse is not a valid Case Note visibleto type. : ',response.errorMessage,'Problem with no VisibleTos');

    }


     private static string generateJSON (String appID, String note, String type, List<string> visibletos){
     	JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        if (appID != ''){gen.writeStringField('appID', appID);}
        if (note != ''){gen.writeStringField('note', note);}
        if (type != ''){gen.writeStringField('type', type);}
     gen.writeFieldName('visibletos');
        gen.writeStartArray();
        for (String vt : visibletos){
        	gen.writeStartObject();
        	gen.writeStringField('visibleto', vt);
        	gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String pretty = gen.getAsString();
        return pretty;
     }
}