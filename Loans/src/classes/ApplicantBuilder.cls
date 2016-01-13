public class ApplicantBuilder {

    private Applicant__c Record;

	private ApplicantBuilder(Application__c application) {
		this.Record = new Applicant__c();
        Record.Application__c = application.Id;
        Record.Application__r = application;
	}

    public static ApplicantBuilder getBuilder(Application__c application){
        return new ApplicantBuilder(application);
    }

    public ApplicantBuilder save(){
        upsert Record;
        return this;
    }

    public Applicant__c getRecord(){
        return Record;
    }

    public ApplicantBuilder setFirstName(String first_name){
        Record.First_Name__c = first_name;
        return this;
    }

    public ApplicantBuilder setLastName(String last_name){
        Record.Last_Name__c = Last_name;
        return this;
    }

    public ApplicantBuilder setEmail(String email){
        Record.Email_Address__c = email;
        return this;
    }

    public ApplicantBuilder setDateOfBirth(Date date_of_birth){
        Record.Date_Of_Birth__c = date_of_birth;
        return this;
    }

    public ApplicantBuilder setTitle(String title){
        Record.Title__c = title;
        return this;
    }

    public ApplicantBuilder setPostCode(String postcode){
        Record.PostCode__c = postcode;
        return this;
    }

    public ApplicantBuilder setMaidenName(String maiden_name){
        Record.Maiden_Name__c = maiden_name;
        return this;
    }

    public ApplicantBuilder setMobilePhone(String mobile_phone){
        Record.Mobile_Phone__c = mobile_phone;
        return this;
    }

    public ApplicantBuilder setTimeInEmploymentMonths(Integer months){
        if(months != null){
            Record.Time_In_Employment_Months__c = String.valueOf(months);
        }
        return this;
    }

    public ApplicantBuilder setTimeInEmploymentYears(Integer years){
        if(years != null){
            if(years >= 10){
                Record.Time_In_Employment_Years__c = '10+';
            } else {
                Record.Time_In_Employment_Years__c = String.valueOf(years);
            }
        }
        return this;
    }

    public ApplicantBuilder setTimeWithPreviousEmployerMonths(Integer months){
        if(months != null){
            Record.Time_with_Prev_Employer_Months__c = String.valueOf(months);
        }
        return this;
    }

    public ApplicantBuilder setTimeWithPreviousEmployerYears(Integer years){
        if(years != null){
            if(years >= 10){
                Record.Time_with_Prev_Employer_Years__c = '10+';
            } else {
                Record.Time_with_Prev_Employer_Years__c = String.valueOf(years);
            }
        }
        return this;
    }

    public ApplicantBuilder setIsPrimary(Boolean is_primary){
        Record.Is_Primary__c = is_primary;
        return this;
    }

    public ApplicantBuilder setApplicantIndex(Integer applicant_index){
        Record.Applicant_Index__c = applicant_index;
        return this;
    }

}