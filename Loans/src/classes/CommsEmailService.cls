global abstract class CommsEmailService {

    global abstract SendResult sendEmail(Recipient recipient, Template template);

    public static SendResult sendEmailNow(Recipient recipient, Template template){
        return new MandrillEmailService().sendEmail(recipient, template);
    }

    public static SendResult sendEmailLater(Recipient recipient, Template template, Schedule schedule){
        SendResult result = new SendResult();
        if(recipient.getApplicant() != null){
            CustomerCommsQueueItemBuilder.getBuilder(CustomerCommsQueueItemBuilder.ItemType.EMAIL, recipient.getApplicant())
                                            .setRemoteTemplateName(template.getName())
                                            .setSendDateTime(schedule.getDateTime())
                                            .save();
        } else {
            result.addError('ERROR: Send Later can only be done for applicants');
        }
        return result;
    }

    global class Recipient{
        private String name;
        private String email;
        private Map<String,Object> merge_data = new Map<String,Object>();
        private Applicant__c applicant;

        public Recipient(String email){
            this.email = email;
        }

        public Recipient(Applicant__c applicant){
            this.applicant = applicant;
            this.email = applicant.Email_Address__c;
            this.name = applicant.First_Name__c + ' ' + applicant.Last_Name__c;
        }

        public Recipient setName(String name){
            this.name = name;
            return this;
        }

        public Recipient setMergeData(String merge_name, Object merge_value){
             merge_data.put(merge_name,merge_value);
            return this;
        }

        public String getName(){
            return this.name;
        }

        public String getEmail(){
            return this.email;
        }

        public Map<String,Object> getMergeData(){
            return this.merge_data;
        }

        public Applicant__c getApplicant(){
            return this.applicant;
        }

    }

    global class Template{
        @Testvisible private Boolean isLocal;
        @Testvisible private String name;
        @Testvisible private String subject;
        @Testvisible private String body;

        public Template(String name, Boolean is_local){
            this.isLocal = is_local;
            this.name = name;
        }

        public Template setSubject(string subject){
            this.subject = subject;
            return this;
        }

        public Template setBody(string body){
            this.body = body;
            return this;
        }

        public String getName(){
            return this.name;
        }

        public String getSubject(){
            return this.subject;
        }

        public String getBody(){
            return this.body;
        }

        public Boolean isLocal(){
            return isLocal;
        }
    }

    global class SendResult{
        @TestVisible private List<String> errors = new List<String>();

        public SendResult(){}

        public Boolean IsSuccess(){
            return errors == null || errors.isEmpty();
        }

        public SendResult addError(String error){
            if(errors == null) errors = new List<String>();
            errors.add(error);
            return this;
        }

        public List<String> getErrors(){
            return errors;
        }
    }

    public class Schedule{
        private DateTime sendDateTime;

        public Schedule(DateTime future_date){
            sendDateTime = future_date;
        }

        public DateTime getDateTime(){
            return sendDateTime;
        }
    }
}