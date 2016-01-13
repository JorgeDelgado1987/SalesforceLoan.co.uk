@isTest
public class ApplicantTrigger_Test
{
     public static testMethod void Test_One() 
     {
         account ac = new account();
         ac.name = 'Testf';
         //ac.lastname__c = 'TestL';
         insert ac;
     
         Application__c a = new Application__c();
         a.Account__c = ac.id;
         insert a;
         
         Applicant__c ap = new Applicant__c();
    
         ap.first_name__c = 'TestF';
         ap.Last_Name__c = 'LastF';
         ap.Application__c = a.id;
         insert ap;
         
     }
}