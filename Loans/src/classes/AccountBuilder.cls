public class AccountBuilder {
    //hello!!!
    private Account Record;

    private AccountBuilder(String name) {
		Record = new Account();
        Record.Name = name;
	}

    public static AccountBuilder getBuilder(String account_name){
        return new AccountBuilder(account_name);
    }

    public AccountBuilder save(){
        upsert Record;
        return this;
    }

    public Account getRecord(){
        return Record;
    }
}