@RestResource(urlMapping='/sec/createlenderdocs')

//////////////////////////////////////////////////
//
//   Created by Simon Parker
//   09/03/2015
//
/////////////////////////////////////////////////

// Takes a Quote ID, creates Lender Docs through Webmerge and returns list of URLS to access Lender docs as attachements

global class SECAPIcreateLenderDocs {
	public static List<String> ErrorsList;

    private static Quote__c thisquote;

    @HttpPost 
	global static DocsResponse createDocs(){
		RestRequest req = RestContext.request;      
        Map<String,Object> tempmapparamdata = RestContext.request.params;
        Map<String,Object> mapparamdata = new Map<String,Object>(); 
        
        for(String mkey : tempmapparamdata.keyset()){
            mapparamdata.put(mkey.toUpperCase(), tempmapparamdata.get(mkey));
        }
        ErrorsList = new List<String>();

        string quoteid = getValuefromParameters(mapparamdata,'QUOTEID');

        if(quoteid ==''){
            ErrorsList.add('No valid input parameter data sent');            
            DocsResponse failedresponse = new DocsResponse('Error', ErrorsList);
            String JSONRes = JSON.serialize(failedresponse);
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody = Blob.valueOf(JSONRes);
            return failedresponse;  
        }

        DocsResponse docsresponse = new DocsResponse();
        docsresponse.status = 'Success';

        thisquote = getRequestedQuote(quoteid);

        if (thisquote == null){
            docsresponse.status = 'Rejected';
            docsresponse.detail.add('No such Quote record.');
            RestContext.response.statusCode = 400;
        }

        if(docsresponse.status == 'Success'){
            if (thisquote.Lender_Fee__r.Webmerge_Document_Batch__c == null){
                 docsresponse.status = 'Rejected';
                docsresponse.detail.add('There is no document merge mapping defined for this Lender.');
                RestContext.response.statusCode = 400;
            }
        }

        if(docsresponse.status == 'Success'){

        	List<Attachment> newdocs = creategetLenderDocs(thisquote);
        	List<String> newdoclinks = new List<String>();
        	

        	if (newdocs.isEmpty()){
        		docsresponse.Status = 'Rejected';
            	docsresponse.Detail.add('Error creating lender documents.');
                docsresponse.Detail.add(quoteid);
            	RestContext.response.statusCode = 400;
        	}
        	else{
        		insert newdocs;
                RestContext.response.statusCode = 201;
        		String siteURL = 'dev-loanco.cs10.force.com';
                if (!Utility.isRunninginSandbox()){
                    siteURL = 'loanco.secure.force.com';
                }

        		for (Attachment attachment : newdocs){
        			newdoclinks.add('https://' + siteURL + '/servlet/servlet.FileDownload?file='+attachment.id);
        		}  
			}
			docsresponse.LenderDocLinks = newdoclinks;
        }


        String JSONRes = JSON.serialize(docsresponse);
        
        RestContext.response.responseBody = Blob.valueOf(JSONRes);
        
        return docsresponse;

	}

	private static String getValuefromParameters(Map<String,Object> map_parameters , String required_key){
        if(map_parameters.containsKey(required_key) && map_parameters.get(required_key) != null && map_parameters.get(required_key) != ''){
            return String.ValueOf(map_parameters.get(required_key));
        }
        return '';
    }

    private static Quote__c getRequestedQuote(String quote_ID){
        List <Quote__c> matchquotes = [Select id,Application__r.id,Lender_Fee__r.Webmerge_Document_Batch__c, Lender_Fee__r.Webmerge_Document_Batch2__c,Lender_Fee__r.Webmerge_Document_Batch__r.Id,Lender_Fee__r.Webmerge_Document_Batch2__r.Id,Lender_Fee__r.Id from Quote__c WHERE id = :quote_ID ];
    
     
        if (matchquotes.size() == 1){
            return matchquotes[0];
        }
        return null;
    }

    private static List<Attachment> creategetLenderDocs(Quote__c quote){
        List<Attachment> newdocs = new List<Attachment>();
        List<Attachment> seconddocs  = new List<Attachment>();
        if (quote.Lender_Fee__r.Webmerge_Document_Batch2__r.Id != null){
            newdocs = WebmergeCaller.callWebmerge(quote.Lender_Fee__r.Webmerge_Document_Batch__r.Id, quote.Application__r.id, 'Application__c', quote.Lender_Fee__r.Id, true, false, false);
        }
        else{
            newdocs = WebmergeCaller.callWebmerge(quote.Lender_Fee__r.Webmerge_Document_Batch__r.Id, quote.Application__r.id, 'Application__c', quote.Lender_Fee__r.Id, true, true, false);
       
        }
    
        if (quote.Lender_Fee__r.Webmerge_Document_Batch2__r.Id != null){
            seconddocs = WebmergeCaller.callWebmerge(quote.Lender_Fee__r.Webmerge_Document_Batch2__r.Id, quote.Application__r.id, 'Application__c', quote.Lender_Fee__r.Id, true, true, false);
            if (seconddocs != null){
                newdocs.addAll(seconddocs);
            }
        }
        
        return newdocs;

    }


	global class DocsResponse{
        
        global DocsResponse(){
            Detail = new List<String>();
        }
        
        global DocsResponse(String inStatus, List<String> inDetail){
            this.status = inStatus;
            this.Detail = inDetail;
        }

        public String Status;
        public List<String> Detail;
        public List<String> LenderDocLinks;
        
    }
}