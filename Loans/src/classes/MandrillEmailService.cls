public class MandrillEmailService extends CommsEmailService{
	public MandrillEmailService() {

	}

    public override SendResult sendEmail(Recipient recipient, Template template){

		MandrillIntegration.EmailRecipient emailRecipient = new MandrillIntegration.EmailRecipient(recipient.getName(), recipient.getEmail());
		emailRecipient.setMergeData(recipient.getMergeData());
		MandrillIntegration mandrill = new MandrillIntegration();
		mandrill.setTemplateName(template.getName());
		if(template.isLocal()){
			mandrill.setSubject(template.getSubject());
			mandrill.setBody(template.getBody());
		}

		CommsEmailService.SendResult emailSendResult = new CommsEmailService.SendResult();

		MandrillIntegration.Response email_response = mandrill.sendEmail(emailRecipient);
		if (email_response.getStatus() != MandrillIntegration.Status.SUCCESS){
			emailSendResult.addError(email_response.getExceptionMessage());
		}
        return emailSendResult;
    }
}