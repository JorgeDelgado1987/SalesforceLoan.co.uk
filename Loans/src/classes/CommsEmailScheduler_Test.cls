@isTest
private class CommsEmailScheduler_Test {
    
    @isTest static void testScheduleMethodSchedulesCorrectClass() {
        Id job_id;
        String cron_exp = '0 0 * * * ?';
        Test.startTest();
            job_id = System.schedule('Email Batch', cron_exp, new CommsEmailScheduler());
        Test.stopTest();
        CronTrigger job = [Select Id, CronExpression, CronJobDetail.Name, NextFireTime from CronTrigger where Id=:job_id];
        System.assertEquals(cron_exp, job.CronExpression, 'Cron expression should match the one submitted');
        System.assertEquals('Email Batch', job.CronJobDetail.Name, 'name should match that submitted');

    }
    
}