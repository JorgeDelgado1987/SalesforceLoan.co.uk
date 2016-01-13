global class CommsEmailScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		CommsEmailBatch comms_batch = new CommsEmailBatch();
        database.executeBatch(comms_batch, 100);
	}
}