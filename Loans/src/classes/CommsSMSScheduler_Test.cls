@isTest
private class CommsSMSScheduler_Test {
    
    @isTest static void testScheduleMethodSchedulesCorrectClass() {
        Id job_id;
        String cron_exp = '0 0 * * * ?';
        Test.startTest();
            job_id = System.schedule('SMS Batch', cron_exp, new CommsSMSScheduler());
        Test.stopTest();
        CronTrigger job = [Select Id, CronExpression, CronJobDetail.Name, NextFireTime from CronTrigger where Id=:job_id];
        System.assertEquals(cron_exp, job.CronExpression, 'Cron expression should match the one submitted');
        System.assertEquals('SMS Batch', job.CronJobDetail.Name, 'name should match that submitted');

    }

    @isTest static void testScheduleIt() {
        CommsSMSScheduler.scheduleIt();
    }
    
}