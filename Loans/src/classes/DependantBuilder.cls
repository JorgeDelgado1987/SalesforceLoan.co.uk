public class DependantBuilder {

	 private Dependants__c Record;

    private DependantBuilder(Applicant__c applicant) {
        this.Record = new Dependants__c();
        Record.Applicant__c = applicant.Id;
        Record.Applicant__r = applicant;
    }

    private DependantBuilder(Dependants__c dependant) {
        this.Record = dependant;
    }

    public static DependantBuilder getBuilder(Applicant__c applicant){
        return new DependantBuilder(applicant);
    }

    public static DependantBuilder getBuilder(Dependants__c dependant){
        return new DependantBuilder(dependant);
    }

    public DependantBuilder save(){
        upsert Record;
        return this;
    }

    public Dependants__c getRecord(){
        return Record;
    }
}