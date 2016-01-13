// *******************************************
// Developer:   Eddie Bates
// Name:        UploadAttachmentController
// Created:     12/09/2014
// Description: JIRA SEC-52. This Controller is called by VF page UploadAttachment.
//              It Uploads a PDF/JPG file to both Outstanding_Items__c and Application__c Objects
//              **
//              * Upload process is:
//              * 1. Insert new Outstanding_Item_Attachment__c record with Application__c as parent
//              * 2. Insert new Attachment with the new Outstanding_Item_Attachment__c record as parent
//              * 3. Update the Outstanding_Item_Attachment__c record with the ID of the new Attachment
//              **
// *******************************************
/* +-----------------------------------------------------------------------------------------------------------------------------+
   | Updates                                                                                                                     |
   |-----------------------------------------------------------------------------------------------------------------------------|
   | Developer    Date    Description                                                                                            |
   +-----------------------------------------------------------------------------------------------------------------------------+

   |-----------------------------------------------------------------------------------------------------------------------------|
*/
   
public class UploadAttachmentController {

    //Declare Variables
    public String description {get; set;}
    private Outstanding_Items__c outstandingItem {get; set;}
    public String fileName {get; set;}
    public Blob fileBody {get; set;}
    public Outstanding_Items__c oOutstandingItems {get; set;}
    
    //Constructor
    public UploadAttachmentController(ApexPages.StandardController controller) {
        this.outstandingItem = (Outstanding_Items__c)controller.getRecord();
        
        //Get the Application Id from Outstanding_Items__c
        if(outstandingItem.Id != null) {
                try {               
                    oOutstandingItems = [SELECT Application__c
                           FROM Outstanding_Items__c 
                           WHERE Id =: outstandingItem.Id];                                                              
                }
                catch(exception e) {
                    system.debug('*** -- Error getting Outstanding Item details -- ***');
                }                
            }
    }
    
    //Creates a new Outstanding_Item_Attachment__c record
    private Database.SaveResult saveCustomAttachment() {
        Outstanding_Item_Attachment__c obj = new Outstanding_Item_Attachment__c();
        obj.Outstanding_Item__c = outstandingItem.Id;
        obj.Application__c = oOutstandingItems.Application__c;
        obj.description__c = description;
        // fill out cust obj fields
        return Database.insert (obj);
    }
    //Create an actual Attachment record with the Outstanding_Item_Attachment__c as parent
    private Database.SaveResult saveStandardAttachment(Id parentId) {
        Database.SaveResult result;
        Attachment attachment = new Attachment();
        attachment.Body = this.fileBody;
        attachment.Name = this.fileName;
        attachment.ParentId = parentId;
        //Insert the Attahcment
        result = Database.insert (attachment);
        //Reset the file for the view state
        fileBody = Blob.valueOf(' ');
        return result;
    }   

    public PageReference processUpload() {
        try {
            Database.SaveResult customAttachmentResult = saveCustomAttachment();
            if (customAttachmentResult == null ||!customAttachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save attachment.'));
                return null;
            }
            Database.SaveResult attachmentResult = saveStandardAttachment(customAttachmentResult.getId());
            if (attachmentResult == null ||!attachmentResult.isSuccess()) {
                ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Could not save attachment.'));
                return null;
            }
            else {
                // update the custom attachment record with some attachment info
                Outstanding_Item_Attachment__c customAttachment = [select id from Outstanding_Item_Attachment__c where id = :customAttachmentResult.getId()];
                customAttachment.name = this.fileName;
                customAttachment.Attachment__c = attachmentResult.getId();
                update customAttachment;
            }
        }
        catch (Exception e) {
            ApexPages.AddMessages(e);
            return null;
        }
        return new PageReference('/'+ oOutstandingItems.Application__c);
    }
    public PageReference back() {
        return new PageReference('/'+ oOutstandingItems.Application__c);
    }
}