public with sharing class ApplicationDocuments {

	private final Application__c myApplication;
    public String primaryApplicantName {get;set;}
    public Attachment applicationDocuments {get;set;}
    public List<Outstanding_Item_Attachment__c> applicationAttachments {get;set;}
    public Boolean accessgranted{get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ApplicationDocuments(ApexPages.StandardController stdController) {
        this.myApplication = (Application__c)stdController.getRecord();
        Id recordid = this.myApplication.id;
        String applicationSecurityKey = [Select DocumentSecurityKey__c from Application__c WHERE id=:recordid].DocumentSecurityKey__c;

        String suppliedSecurityKey = ApexPages.currentPage().getParameters().get('key');
        accessgranted = false;
        if(suppliedSecurityKey != null && suppliedSecurityKey==applicationSecurityKey){
            accessgranted = true;
            Applicant__c primaryApplicant = [Select First_Name__c, Last_Name__c from Applicant__c WHERE Application__c=:recordid AND Is_Primary__c = TRUE LIMIT 1];
            primaryApplicantName = primaryApplicant.First_Name__c + ' ' + primaryApplicant.Last_Name__c;
            applicationAttachments = [Select id, Description__c, View__c from Outstanding_Item_Attachment__c WHERE Application__c=:recordid ];
        }
    }  
}