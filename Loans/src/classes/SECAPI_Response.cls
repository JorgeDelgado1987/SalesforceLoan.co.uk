public virtual class SECAPI_Response {

	public String status {get; private set;}
	public String successmessage {get; private set;}
	public String failuremessage {get; private set;}
	

	public SECAPI_Response() {
	}


	public SECAPI_Response setStatus(String inStatus) {
		status = inStatus;
		return this;
	}

	public SECAPI_Response setSuccessMessage(String inMessage) {
		if(successmessage == null || String.isEmpty(successmessage)) {
			successmessage = inMessage;
		}
		else {
			if (inMessage != null){
				successmessage = successmessage + ' : ' + inMessage;
			}
		}
		return this;
	}

	public SECAPI_Response setFailureMessage(String inMessage) {
		if(failuremessage == null || String.isEmpty(failuremessage)) {
			failuremessage = inMessage;
		}
		else {
			if (inMessage != null){
				failuremessage = failuremessage + ' : ' + inMessage;
			}
		}
		return this;
	}




}