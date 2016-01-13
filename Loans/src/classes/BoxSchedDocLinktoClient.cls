global class BoxSchedDocLinktoClient implements Schedulable {

	//job runs every 15 minutes
	public static String CRON_EXP1 = '0 0 * * * ?';
	public static String CRON_EXP2 = '0 15 * * * ?';
	public static String CRON_EXP3 = '0 30 * * * ?';
	public static String CRON_EXP4 = '0 45 * * * ?';
	//for testing = run job as soon as - set second number to minutes of the hour
	//public static String CRON_EXP = '0 58 * * * ? *';


	 global static String scheduleIt() {
        BoxSchedDocLinktoClient myJob = new BoxSchedDocLinktoClient();
        //if test then don't try and resched
        if (!Test.isRunningTest()) {
        	System.schedule('Box Link to Client 0', CRON_EXP1, myJob);
        	System.schedule('Box Link to Client 15', CRON_EXP2, myJob);
        	System.schedule('Box Link to Client 30', CRON_EXP3, myJob);
        return System.schedule('Box Link to Client 45', CRON_EXP4, myJob);
    }
    else
    {return null;}
    }
	global void execute(SchedulableContext sc) {
		//MyBatchClass b = new MyBatchClass();
		//database.executebatch(b);
		Set<Id> ids = new Set<Id>();
		List<Application__c> applicaitons = [Select id, docs_created__c from Application__c WHERE docs_created__c = true AND docs_created_at__c < :Datetime.now().addMinutes(-5)];
		if (applicaitons.size()>0){
			for (Application__c thisapplication : applicaitons){
				//WebmergeCaller.sendEmailtoClientBox(thisapplication.id);
				thisapplication.docs_created__c = false;
			}
			update applicaitons;
		}
	}
}