public class ChapterTriggerHandler {
    
    public static void PopulatePublication(List<Chapter__c> newList) {

        Set<String> pIds = new Set<String>();
        for (Chapter__c ch : newList) {
            if (ch.CC_Publication_ID__c != null) {
                pIds.add(ch.CC_Publication_ID__c );
            }
        }

        Map<String, Id> pMap = new Map<String, Id>();
        for (Publication__c p : [SELECT Id, CC_Publication_ID_RE__c FROM Publication__c WHERE CC_Publication_ID_RE__c IN :pIds]) {
            pMap.put(p.CC_Publication_ID_RE__c, p.Id);
        }


        for (Chapter__c ch : newList) {
            if (ch.CC_Publication_ID__c != null) {
                
                if (pMap.containsKey(ch.CC_Publication_ID__c)) {
                    ch.Publication__c = pMap.get(ch.CC_Publication_ID__c);
                }
            }
        }   
    }

    public static void PopulateLocation(List<Chapter__c> newList) {

        Set<String> pIds = new Set<String>();
        for (Chapter__c ch : newList) {
            if (ch.CC_Location_ID__c != null) {
                pIds.add(ch.CC_Location_ID__c );
            }
        }

        Map<String, Id> lMap = new Map<String, Id>();
        for (Location__c loc : [SELECT Id, CC_Location_ID__c FROM Location__c WHERE CC_Location_ID__c IN :pIds]) {
            lMap.put(loc.CC_Location_ID__c, loc.Id);
        }

        for (Chapter__c ch : newList) {
            if (ch.CC_Location_ID__c != null) {

                if (lMap.containsKey(ch.CC_Location_ID__c)) {
                    ch.Location__c = lMap.get(ch.CC_Location_ID__c);
                }
            }
        }
    }

}