public class LocationTriggerHandler {
	public static void PopulateParentLocation(Map<Id,Location__c> newMap) {
        FutureUtil.LocationParentUpdate(newMap.keySet());
	}
}