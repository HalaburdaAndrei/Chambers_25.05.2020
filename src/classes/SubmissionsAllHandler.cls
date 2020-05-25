public class SubmissionsAllHandler {

    public static void PopulatePublication(List<Submissions__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Submissions__c s : newList) {
            if (s.Publication_ID__c != null) {
                pIds.add(s.Publication_ID__c );
            }
        }
        
        Map<String, Id> pMap = new Map<String, Id>();
        for (Publication__c p : [SELECT Id, CC_Publication_ID_RE__c FROM Publication__c WHERE CC_Publication_ID_RE__c IN :pIds]) {
            pMap.put(p.CC_Publication_ID_RE__c, p.Id);
        }
        
        for (Submissions__c s : newList) {
            if (s.Publication_ID__c != null) {
                
                if (pMap.containsKey(s.Publication_ID__c)) {
                    s.Publication__c = pMap.get(s.Publication_ID__c);                    
                }
            }
        }
    }

    public static void PopulateAccount(List<Submissions__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Submissions__c s : newList) {
            if (s.Organization_ID__c != null) {
                pIds.add(s.Organization_ID__c );
            }
        }
        
        Map<String, Id> pMap = new Map<String, Id>();
        for (Account p : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :pIds]) {
            pMap.put(p.CC_Account_ID_RE__c, p.Id);
        }
        
        for (Submissions__c s : newList) {
            if (s.Organization_ID__c != null) {
                
                if (pMap.containsKey(s.Organization_ID__c)) {
                    s.Organization_RE__c = pMap.get(s.Organization_ID__c);                    
                }
            }
        }
    }

    public static void PopulateParentAccount(List<Submissions__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Submissions__c s : newList) {
            if (s.Organization_Parent_ID__c != null) {
                pIds.add(s.Organization_Parent_ID__c );
            }
        }
        
        Map<String, Id> pMap = new Map<String, Id>();
        for (Account p : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :pIds]) {
            pMap.put(p.CC_Account_ID_RE__c, p.Id);
        }
        
        for (Submissions__c s : newList) {
            if (s.Organization_Parent_ID__c != null) {
                
                if (pMap.containsKey(s.Organization_Parent_ID__c)) {
                    s.Parent_Organization_RE__c = pMap.get(s.Organization_Parent_ID__c);                    
                }
            }
        }
    }


    
    public static void SoftDeleted(List<Submissions__c> newList) {
        
        List<Submissions__c> toDelete = new List<Submissions__c>();
        for (Submissions__c s : newList) {
            if (s.CC_Active_RE__c == false) {
                toDelete.add(new Submissions__c(Id = s.Id));
            }
        }
        
        if (toDelete.size() > 0) {
            delete toDelete;
        }
    }
}