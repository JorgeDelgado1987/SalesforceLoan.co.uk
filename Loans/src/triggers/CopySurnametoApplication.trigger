trigger CopySurnametoApplication on Applicant__c (after insert) {
    Map<Id, String> m = new Map<Id, String>();
    for (Applicant__c a : Trigger.new) {
        system.debug('Applicant ID is ' + a.id);
        Application__c[] applications = [
                select Lead_Applicant_Name__c 
                from Application__c
                where Id = :a.Application__C
                ];
        if (applications.size() > 0)
        {
          system.debug('Applications found for this applicant');
          Application__c application = applications[0];
          system.debug('Application Lead_Applicant_Name__c is ' + application.Lead_Applicant_Name__c  );
          if ( application.Lead_Applicant_Name__c  != '' &&  application.Lead_Applicant_Name__c  != NULL)
          {
            return;
          }
          else
          {
              system.debug('changing application name to ' + a.Last_Name__c );
              application.Lead_Applicant_Name__c = a.Last_Name__c ;
              update application;
    
          }
          
        }        
        
    }
}