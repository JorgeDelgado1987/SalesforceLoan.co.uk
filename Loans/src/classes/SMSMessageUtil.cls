public without sharing class SMSMessageUtil{

    private final static String SMS_ENDPOINT = 'https://secure.itagg.com/smsg/sms.mes';
    //private final static String SMS_API_KEY = '48db65f2dda8fcce6b5dae8a6052d68c6b1664cf';
    private final static String SMS_USERNAME = '0a36a17c';
    private final static String SMS_PASSWORD = '8bd36929';
    private final static String SMS_ROUTE = 'd';
    private final static String SMS_MESSAGE_TYPE = 'text';

    private class SMS {
        //public String ApiKey;
        public String Txt;
        public String To;
        public String Route;
        public String Frm;
        public String Type;
        public String Usr;
        public String Pwd;
        public Integer IndividualErrors;

        //Constructor to set individual errors to off by default (to prevent null)
        private SMS(){
            IndividualErrors = 0; // set default
        }
    }


    public class SMSMessageResponse {
        public Integer success;
        public String To;
        public String submissionReference;
        public String timestampString;
    }

    public static String getSMSMessageText(Customer_Comms_Queue_Item__c queueItem, String sms_message_content) {
        System.debug('getSMSMessageText');
        //To prevent null values causing the JSON generation to fail
        String firstName = queueItem.First_Name__c;
        Decimal loanAmount = queueItem.Loan_Amount__c;

        if(firstName == null || firstName == '') firstName = '.';

        String body = sms_message_content;
        body = body.replace('{!First_Name__c}', firstName);
        body = body.replace('{!Loan_Amount__c}', loanAmount.format());
        body = body.replace('{!User_First_Name__c}', UserInfo.getFirstName());
        body = body.replace('{!User_Company_Name__c}', UserInfo.getOrganizationName());
        body = body.replace('{!Last_Name__c}', queueItem.Applicant__r.Last_Name__c);
        body = body.replace('{!Application.Name}', queueItem.Applicant__r.Application__r.Name);
        body = body.replace('{!Application.Loan_Amount__c}', String.valueOf(queueItem.Applicant__r.Application__r.Loan_Amount__c));

        String case_manager = queueItem.Applicant__r.Application__r.Case_Manager__r.FirstName;
        if(String.isBlank(case_manager))
            case_manager = '';

        body = body.replace('{!Application.Case_Manager__c}', case_manager);
        body = body.replace('?', 'poundsign');

        System.debug('Message to send: ' + body);
        return body;
    }

    public static String formatMobileNumber(Customer_Comms_Queue_Item__c queueItem){
        if (queueItem.Mobile_Number__c != null){
            //  Get and format the mobile phone number
            String phoneNumber = queueItem.Mobile_Number__c;
            String To = phoneNumber.deleteWhitespace();
            To = To.removeStartIgnoreCase('+');
            if (To.startsWith('07')){
                To = To.replaceFirst('07', '447');
            }
            else if (To.startsWith('7')){
                To = To.replaceFirst('7', '447');
            }

            //  Check number starts with 447 and has 12 characters
            if (To.startsWith('447') && To.length() == 12){
                To = EncodingUtil.urlEncode(To, 'UTF-8');
                return To;
            }
        }
        return null;
    }

    public static HttpResponse processSMS(Customer_Comms_Queue_Item__c queueItem, List<SMS_Template__c> sms_templates, String MobileNumber){
        if(queueItem != null){
            for(SMS_Template__c sms_template : sms_templates){
                System.debug('processSMS');
                SMS newSMS = new SMS();
                //newSMS.ApiKey = SMS_API_KEY;
                newSMS.Route = SMS_ROUTE;
                newSMS.Frm = sms_template.Sender_ID__c;
                newSMS.Type = SMS_MESSAGE_TYPE;
                newSMS.Usr = SMS_USERNAME;
                newSMS.Pwd = SMS_PASSWORD;
                newSMS.To = MobileNumber;

                List<SMS> smsMessages = new List<SMS>();

                String messageText = getSMSMessageText(queueItem, sms_template.Message_Content__c);
                newSMS.Txt = messageText;

                //Test Mobile Number
                //newSMS.To = EncodingUtil.urlEncode('447775662958', 'UTF-8');

                //Build the Post String
                String content = 'route='+EncodingUtil.urlEncode(newSMS.Route, 'UTF-8')+
                '&from='+EncodingUtil.urlEncode(newSMS.Frm, 'UTF-8')+
                '&pwd='+EncodingUtil.urlEncode(newSMS.Pwd, 'UTF-8')+
                '&to='+EncodingUtil.urlEncode(newSMS.To, 'UTF-8')+
                '&txt='+EncodingUtil.urlEncode(newSMS.Txt, 'UTF-8')+
                '&type='+EncodingUtil.urlEncode(newSMS.Type, 'UTF-8')+
                '&usr='+EncodingUtil.urlEncode(newSMS.Usr, 'UTF-8');

                //Encode the Pound Sign ?
                content = content.replace('poundsign', '%A3');

                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(SMS_ENDPOINT);
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setMethod('POST');
                request.setBody(content);

                request.setTimeout(30000);
                System.debug('content: '+content);
                HttpResponse response = http.send(request);
                return response;
            }
        }
        return null;
    }
}