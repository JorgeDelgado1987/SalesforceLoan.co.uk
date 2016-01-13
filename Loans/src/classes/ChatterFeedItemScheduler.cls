global class ChatterFeedItemScheduler implements Schedulable
{   
	
	global static String scheduleIt() {
        ChatterFeedItemScheduler myJob = new ChatterFeedItemScheduler();
        
		//If test then don't try and resched
        if (!Test.isRunningTest()) {
	        System.debug('debug: ChatterFeedItemScheduler');
			//Build the system time of now + 20 seconds to schedule the batch apex.
	        Datetime sysTime = System.now();
	        sysTime = sysTime.addSeconds(20);
	        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
	        return System.schedule('chatterFeedItemBatchJobFirstRun' + sysTime.getTime(),chron_exp,myJob);
	    }
    else
    {return null;}
    }
	
	global void execute(SchedulableContext sc)
   {
	    
        ChatterFeedItemBatch chatterFeedBatch = new ChatterFeedItemBatch('Select Id, Agent__c, Message__c, Application__c, Agent__r.Email, Agent__r.FirstName, Agent__r.LastName from Chatter_Feed_Item__c');
        ID batchprocessid = Database.executeBatch(chatterFeedBatch,20);
   }  
}