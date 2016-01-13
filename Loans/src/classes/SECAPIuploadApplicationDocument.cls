@RestResource(urlMapping='/sec/uploaddocument')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   11/03/2015
//
/////////////////////////////////////////////////

// Takes an Application ID with document details and body and uploads it to the Application record and returns the Attachment ID

global class SECAPIuploadApplicationDocument {

	public static List<String> ErrorsList;

	private static Application__c thisapplication;

    @HttpPost 
	global static DocsResponse receiveData(){

		DocsResponse docsresponse;
        String status = 'success';
	    String errorStr = '';
	    String successStr = '';
	    String newAttachID;
	    ErrorsList = new List<string>();
        //RestResponse res = new RestResponse();

		customattachment sentattachment = (customattachment) JSON.deserialize(
			RestContext.request.requestBody.toString(),
			customattachment.class
			);

	    String parentid = sentattachment.parentId;
	    String name = sentattachment.filename;
	    Blob body = sentattachment.filebody;

	    if (String.isBlank(parentid) || parentid == null){
        	ErrorsList.add('Must supply an ApplicationID as the parentId.');
    	}

    	if (String.isBlank(name)){
    		ErrorsList.add('Must supply a filename.');
    	}

        thisapplication = getRequestedApplication(parentId);

        if (thisapplication == null){
            ErrorsList.add('No matching Application record');
        }

        if (ErrorsList.size() == 0){
        	Attachment newattachment = new Attachment();
        	newattachment.Name = name;
        	newattachment.ParentId = parentId;
        	newattachment.body = body;

        	try{
        		insert newattachment;
        		newAttachID = newattachment.id;
        	}
        	catch(Exception e){
        		ErrorsList.add('ERROR : Unable to create new attachment.' + e);
        	}	
        }

	 //Data quality or Data Transformation returns 400 response - bad data.
    if(ErrorsList.size() > 0){
        status = 'failure';
        for (String s : ErrorsList){
            errorStr = errorStr + s + ' : ';
        }
        /*system.debug(res);
        res.statusCode = 400;
        RestContext.response = res;
        system.debug(res);
        */
        RestContext.response.statusCode = 400;
    }    

    docsresponse = new DocsResponse(status, successStr, errorStr, newAttachID);
    return docsresponse;
    }

    private static Application__c getRequestedApplication(String requested_ID){
        List <Application__c> matchapplications = [Select id from Application__c WHERE id = :requested_ID ];
        if (matchapplications.size() == 1){
            return matchapplications[0];
        }
        return null;
    }

   
	global class DocsResponse{
		public String status;
        public String successMessage;
        public String errorMessage;
        public String newAttachmentID;
	       
        global DocsResponse(String status, String successMessage, String errorMessage, String newAttachmentID){
            this.status = status;
            this.successMessage = successMessage;
            this.errorMessage = errorMessage;
            this.newAttachmentID = newAttachmentID;
        }       
    }

    private class customattachment{
		String parentId;
		String filename;
		Blob filebody;
	}
}