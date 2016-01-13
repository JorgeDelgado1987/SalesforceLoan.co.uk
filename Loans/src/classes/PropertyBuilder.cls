public class PropertyBuilder {

    private Property__c Record;

    private PropertyBuilder(Application__c application) {
        this.Record = new Property__c();
        Record.Application__c = application.Id;
        Record.Application__r = application;
    }

    public static PropertyBuilder getBuilder(Application__c application){
        return new PropertyBuilder(application);
    }

    public PropertyBuilder save(){
        upsert Record;
        return this;
    }

    public Property__c getRecord(){
        return Record;
    }

    public PropertyBuilder setDateMovedIn(Date date_moved_in){
        Record.Date_Moved_In__c = date_moved_in;
        return this;
    }

    public PropertyBuilder setDateMovedOut(Date date_moved_out){
        Record.Date_Moved_Out__c = date_moved_out;
        return this;
    }

    public PropertyBuilder setPurchaseDate(Date purchase_date){
        Record.Purchase_Date__c = purchase_date;
        return this;
    }

    public PropertyBuilder setSecurityAddress(Boolean security_address){
        record.Security_Address__c = security_address;
        return this;
    }

    public PropertyBuilder setEstimatedValue(Double estimated_value){
        record.Estimated_Value__c = estimated_value;
        return this;
    }

    public PropertyBuilder setCurrentAddress(Boolean current_address){
        record.Current_Address__c = current_address;
        return this;
    }

    public PropertyBuilder setStreetName(String street_name){
        record.Street_Name__c = street_name;
        return this;
    }

    public PropertyBuilder setPostCode(String post_code){
        record.PostCode__c = post_code;
        return this;
    }
}