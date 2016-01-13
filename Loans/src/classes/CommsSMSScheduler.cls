global class CommsSMSScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new CommsSMSBatch(), 20);
    }

    global static String scheduleIt() {
        CommsSMSScheduler my_job = new CommsSMSScheduler();
        if (!Test.isRunningTest()) {
            String chron_exp = '0 0 * * * ?';
            return System.schedule('CommsSMSBatchJobFirstRun' + System.now().getTime(), chron_exp, my_job);
        }else{
            return null;
        }
    }
}