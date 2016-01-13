global class ChatterFeedItemBatch implements Database.Batchable<sObject> ,Database.AllowsCallouts, Database.Stateful{
   global final String Query;
   global final String Entity;
   global final String Field;
   global final String Value;


   global ChatterFeedItemBatch(String q)
   {
             Query=q;
   }
   global Database.QueryLocator start(Database.BatchableContext BC)
   {
      return Database.getQueryLocator(query);
   }
   global void execute(Database.BatchableContext BC,
                       List<Chatter_Feed_Item__c> scope)
   {        
	  //List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
	   
      for(Chatter_Feed_Item__c s : scope)
      {
          Chatter_Feed_Item__c chatterFeedItem = (Chatter_Feed_Item__c) s;
          
		  	ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
        	messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
     
        	ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        	textSegment.text = chatterFeedItem.Message__c;
        	messageInput.messageSegments.add(textSegment);
     
		  	//Agent to @mention
        	ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
			mentionSegment.id = chatterFeedItem.Agent__c;
			messageInput.messageSegments.add(mentionSegment);

			
			     
        	ConnectApi.FeedItemInput inputdata = new ConnectApi.FeedItemInput();
        	inputdata.body = messageInput;
     		
		  	// Create a savepoint to Rollback on Error
	        Savepoint sp = Database.setSavepoint();
		  	System.debug('debug: Chatter_Feed_Item__c');
		  	try{
				System.debug('debug: ConnectAPI');
				ConnectApi.FeedItem feedItemRep = ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, chatterFeedItem.Application__c, inputdata, null);
				
				//Email the Chatter Post
				//Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
				//email.setToAddresses(new String[] {chatterFeedItem.Agent__r.Email});
				//email.setReplyTo('no-reply@forcesupport.co.uk');
      			//email.setSenderDisplayName('Chatter Support');
				//email.setSubject('New Chatter Post');
				//email.setPlainTextBody(chatterFeedItem.Message__c + chatterFeedItem.Agent__r.FirstName + ' ' + chatterFeedItem.Agent__r.LastName);
				//emails.add(email);				
				
				
				//If the Post is successful we need to delete it								
				try {
					System.debug('debug: delete chatterFeedItemToDelete');
					    delete chatterFeedItem;
					} catch (Exception e) {
					    System.debug('ERROR: Not able to delete Chatter Feed Item: ' + e);
			            // Rollback
			            Database.rollback(sp);
					}
			}
        	
			catch(Exception e)
	        {
				System.debug('ERROR: Not able to Post Feed Item Batch: ' + e);
	            // Rollback
	            Database.rollback(sp);
	        }
      }
	  
	  //Send the batch of emails
	  //Messaging.sendEmail(emails);
   }
   
   //The batch process has completed successfully. Schedule next batch.   
   global void finish(Database.BatchableContext BC)
   {
	   if (!Test.isRunningTest()) {
	    
	        System.debug(LoggingLevel.WARN,'Batch Process 1 Finished');
	        //Build the system time of now + 5 mins to schedule the batch apex.
	        Datetime sysTime = System.now();
	        sysTime = sysTime.addMinutes(5);
	        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
	        system.debug(chron_exp);
	        ChatterFeedItemScheduler chatterFeedItemBatchSched = new ChatterFeedItemScheduler();
	        //Schedule the next job, and give it the system time so name is unique
	        System.schedule('chatterFeedItemBatchJob' + sysTime.getTime(),chron_exp,chatterFeedItemBatchSched);
		}
   }
}