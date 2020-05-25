trigger ChapterTrigger on Chapter__c (before insert, before update) {

	if (Trigger.isBefore) {
		ChapterTriggerHandler.PopulatePublication(Trigger.new);
		ChapterTriggerHandler.PopulateLocation(Trigger.new);
	}

}