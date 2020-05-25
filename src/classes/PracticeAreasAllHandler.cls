public class PracticeAreasAllHandler {

	public static void PopulateParentPracticeArea(Map<Id,Practice_Area__c> newMap) {
        
        List<Practice_Area__c> practiceAreasToUpdate = new List<Practice_Area__c>();
        Set<String> pIds = new Set<String>();
        for (Practice_Area__c pa : newMap.values()) {
            if (pa.Parent_Practice_Area__c  == null && pa.CC_Parent_Practice_Area_Id__c != null) {
                pIds.add(pa.CC_Parent_Practice_Area_Id__c);
            }
        }
         
        Map<String, Id> pMap = new Map<String, Id>();
        for (Practice_Area__c pa : [SELECT Id, CC_Practice_Area_Id__c FROM Practice_Area__c WHERE CC_Practice_Area_Id__c IN :pIds]) {
            pMap.put(pa.CC_Practice_Area_Id__c, pa.Id);
        }
        for(Practice_Area__c pa: newMap.values() ){
            pMap.put(pa.CC_Practice_Area_Id__c, pa.Id);            
        }
        
        for (Practice_Area__c pa : newMap.values()) {
            if (pa.Parent_Practice_Area__c == null && pa.CC_Parent_Practice_Area_Id__c != null && pa.CC_Parent_Practice_Area_Id__c != pa.CC_Practice_Area_Id__c ) {
                if (pMap.containsKey(pa.CC_Parent_Practice_Area_Id__c)) {
                    Practice_Area__c paUpdate = new Practice_Area__c (Id =pa.Id); 
                    paUpdate.Parent_Practice_Area__c = pMap.get(pa.CC_Parent_Practice_Area_Id__c);
                    practiceAreasToUpdate.add(paUpdate);
                }
            }
        }
        update practiceAreasToUpdate;
    }    
    
}