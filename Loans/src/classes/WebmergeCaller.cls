global class WebmergeCaller {

    // 11/02/2015 - Webservice to call Webmerge Generator from SKUID button on Quote
    // 09/03/2015 - modified to call from SECAPIcreateLenderDocs with immediate

    webservice static List<Attachment> callWebmerge(String webmergeMappingId, String salesforceObjectId, String salesforceObjectName, String lenderId, Boolean immediate, Boolean createoutstandingitems, Boolean sendemail){
        
         if (immediate){
            return mergeandprocessnow(webmergeMappingId, salesforceObjectId, salesforceObjectName, lenderId, true, createoutstandingitems, sendemail);
        }
        else{
            mergeandprocessfuture(webmergeMappingId, salesforceObjectId, salesforceObjectName, lenderId, false, createoutstandingitems,sendemail);
            List<Attachment> attachments = new List<Attachment>();
            return attachments;
        }
    }

    public static List<Attachment> mergeandprocessnow(String webmergeMappingId, String salesforceObjectId, String salesforceObjectName, String lenderId, Boolean immediate,Boolean createoutstandingitems, Boolean sendemail){
        return mergeandprocess(webmergeMappingId, salesforceObjectId, salesforceObjectName, lenderId, immediate, createoutstandingitems,sendemail);
    }

    @future(callout=true)
    public static void mergeandprocessfuture(String webmergeMappingId, String salesforceObjectId, String salesforceObjectName, String lenderId, Boolean immediate, Boolean createoutstandingitems, Boolean sendemail){
        mergeandprocess(webmergeMappingId, salesforceObjectId, salesforceObjectName, lenderId, immediate, createoutstandingitems,sendemail );
    }


    public static List<Attachment> mergeandprocess(String webmergeMappingId, String salesforceObjectId, String salesforceObjectName, String lenderId, Boolean immediate, Boolean createoutstandingitems, Boolean sendemail){
        system.debug(webmergeMappingId + ','+salesforceObjectId + ','+salesforceObjectName + ',' + lenderId + ','+ immediate + ','+createoutstandingitems + ','+sendemail);
        List<Attachment> applicationattachments = new List<Attachment>();
        if (Test.isRunningTest()){
            Attachment oAttachment = new Attachment();
            oAttachment.parentID = salesforceObjectId;
            oAttachment.Name = 'test attachment';
            oAttachment.Body = Blob.valueOf('This is the body');
            applicationAttachments.add(oAttachment);
        }
        else{
            try{
                applicationattachments = webm.WebmergeGenerator.generateDocumentGetAttachments(webmergeMappingId, salesforceObjectId, salesforceObjectName);  
                //Boolean docsretuned = webm.WebmergeGenerator.generateDocument(webmergeMappingId, salesforceObjectId, salesforceObjectName);  
            }
            catch(Exception e){
                System.debug('ERROR: No documents returned from Webmerge : ' + e);
                return applicationattachments;
            }
        }
        system.debug ('attachments = '+applicationattachments);
        //get list of all Lender Required Documents
        List<Lender_Required_Documents__c> lenderrequireddocuments = [Select Days_before_Due__c, Days_Before_Requested__c, Item_Name__c, Item_Type__c, Name, Id, Webmerge_Document_Name__c from Lender_Required_Documents__c 
            WHERE Lender__c =: lenderId];
        if (applicationattachments == null){
            System.debug('ERROR: No documents returned from Webmerge');
                return applicationattachments;
            }
            else{
            if(createoutstandingitems){

                //Create an OutstandingItem for each Document
                List<Outstanding_Items__c> newOutstandingItems = new List<Outstanding_Items__c>();
                    for (Lender_Required_Documents__c lrd : lenderrequireddocuments){
                        Outstanding_Items__c newOutstandingItem  = new Outstanding_Items__c();
                        newOutstandingItem.Application__c = salesforceObjectId;
                        newOutstandingItem.Item_Name__c = lrd.Item_Name__c;
                        newOutstandingItem.Item_Type__c = lrd.Item_Type__c;
                        newOutstandingItem.Requested_Date__c = System.now();
                        Date scheduledDate;
                        Date dueDate;
                        //Convert decimals to int
                        //These will be used to calculate the Scheduled and Due Date late
                        if(lrd.Days_Before_Requested__c != null){
                            Decimal decimalDBR = lrd.Days_Before_Requested__c;
                            Integer intDBR = decimalDBR.intValue();
                            //Get Scheduled Date
                            scheduledDate = date.today();
                            scheduledDate = scheduledDate.addDays(intDBR);
                        }
                            
                        if(lrd.Days_before_Due__c != null){ 
                            Decimal decimalDBD = lrd.Days_before_Due__c;
                            Integer intDBD = decimalDBD.intValue();
                            //Get Due Date
                            dueDate = scheduledDate.addDays(intDBD);
                        }
                        newOutstandingItem.Scheduled_Date__c = scheduledDate;
                        newOutstandingItem.Due_Date__c = dueDate;                                            
                        newOutstandingItems.add(newOutstandingItem);
                    }
                // Create a savepoint to Rollback on Error
                Savepoint sp = Database.setSavepoint();
                try{
                    insert newOutstandingItems;
                }
                catch (System.DmlException e){                   
                        System.debug('ERROR: Not able to insert Outstanding Items : ' + e);
                        // Rollback
                        Database.rollback(sp);
                        return applicationAttachments;
                }
            }
            if (sendemail){
                insert applicationAttachments;
                sendEmailtoClient(salesforceObjectId, applicationAttachments[0].id);
            }
            
        }
        return applicationAttachments;
    }

    public static void sendEmailtoClient(String applicationID, String attachmentID){
        Application__c thisApplication = [Select id, DocumentSecurityKey__c from Application__c WHERE id=:applicationID];
        Applicant__c thisApplicant = new Applicant__c();
        List<Applicant__c> theApplicants = [Select id, First_Name__c, Last_Name__c, Email_Address__c, Is_Primary__c from Applicant__c WHERE Application__c=:applicationID];
        if (theApplicants.size()>0){
            thisApplicant = theApplicants[0];
            if (!String.isEmpty(thisApplicant.Email_Address__c)){
                String siteURL = 'dev-loanco.cs10.force.com';
                if (!Utility.isRunninginSandbox()){
                    siteURL = 'loanco.secure.force.com';
                }
                // Send Email
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                //send to calling user
                mail.setTargetObjectId(UserInfo.getUserId());
                //send to Applicant
                //mail.setToAddresses(new String[] {thisApplicant.Email_Address__c});
                mail.setSubject('Your Loan Application Documents');
                    string Content = '<span style="font-family:arial; color:#28476C;font-size:9pt;">'+
                    'Hello '+ thisApplicant.First_Name__c + ' ' + thisApplicant.Last_Name__c+
                    '<br /><br />'+
                    '<br /><br />'+
                    'Your Loan Application documents are now ready for your completion and signature.'+
                    '<br /><br />'+
                    'Please click on the link below to view and download your documents:'+
                    '<br /><br />'+
                    '<a href="https://' + siteURL +'/servlet/servlet.FileDownload?file='+attachmentID+'">https://' + siteURL + '/servlet/servlet.FileDownload?file='+attachmentID+'</a>'+
                    '<br /><br />'; 
                mail.setHtmlBody(Content); 
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
            }

        }
    }

    webservice static Boolean callSimpleWebmerge (String webmergeMappingId, String salesforceObjectId, String salesforceObjectName){
        system.debug(webmergeMappingId + ','+salesforceObjectId + ','+salesforceObjectName);
        
        try{
            return webm.WebmergeGenerator.generateDocument(webmergeMappingId, salesforceObjectId, salesforceObjectName); 
        }
        catch(Exception e){
            System.debug('ERROR: No documents returned from Webmerge : ' + e);
            return false;
        }
     }

}