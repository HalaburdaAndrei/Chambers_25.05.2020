public class RankingsAllHandler {

    public static void PopulatePublication(List<Rankings__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Rankings__c r : newList) {
            if (r.CC_Publication_ID_RE__c != null) {
                pIds.add(r.CC_Publication_ID_RE__c);
            }
        }
        
        Map<String, Id> pMap = new Map<String, Id>();
        for (Publication__c p : [SELECT Id, CC_Publication_ID_RE__c FROM Publication__c WHERE CC_Publication_ID_RE__c IN :pIds]) {
            pMap.put(p.CC_Publication_ID_RE__c, p.Id);
        }
        
        for (Rankings__c r : newList) {
            if (r.CC_Publication_ID_RE__c != null) {
                if (pMap.containsKey(r.CC_Publication_ID_RE__c)) {
                    r.Publication_RE__c = pMap.get(r.CC_Publication_ID_RE__c);
                }
            }
        }
    }


    public static void PopulateAccount(List<Rankings__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Rankings__c r : newList) {
            if (r.CC_Organization_ID__c != null) {
                pIds.add(r.CC_Organization_ID__c);
            }
        }
        
        Map<String, Id> aMap = new Map<String, Id>();
        for (Account a : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :pIds]) {
            aMap.put(a.CC_Account_ID_RE__c, a.Id);
        }
        
        for (Rankings__c r : newList) {
            if (r.CC_Organization_ID__c != null) {
                if (aMap.containsKey(r.CC_Organization_ID__c)) {
                    r.Account_RE__c = aMap.get(r.CC_Organization_ID__c);
                }
            }
        }
    }

    public static void PopulateParentAccount(List<Rankings__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Rankings__c r : newList) {
            if (r.CC_Organization_Parent_ID__c != null) {
                pIds.add(r.CC_Organization_Parent_ID__c);
            }
        }
        
        Map<String, Id> aMap = new Map<String, Id>();
        for (Account a : [SELECT Id, CC_Account_ID_RE__c FROM Account WHERE CC_Account_ID_RE__c IN :pIds]) {
            aMap.put(a.CC_Account_ID_RE__c, a.Id);
        }
        
        for (Rankings__c r : newList) {
            if (r.CC_Organization_Parent_ID__c != null) {
                if (aMap.containsKey(r.CC_Organization_Parent_ID__c)) {
                    r.Parent_Account__c = aMap.get(r.CC_Organization_Parent_ID__c);
                }
            }
        }
    }

    public static void PopulateContact(List<Rankings__c> newList) {
        
        Set<String> pIds = new Set<String>();
        for (Rankings__c r : newList) {
            if (r.CC_Person_Organization_ID_RE__c != null) {
                pIds.add(r.CC_Person_Organization_ID_RE__c);
            }
        }
        
        Map<String, Id> cMap = new Map<String, Id>();
        for (Contact c : [SELECT Id, CC_Contact_ID__c FROM Contact WHERE CC_Contact_ID__c IN :pIds]) {
            cMap.put(c.CC_Contact_ID__c, c.Id);
        }
        
        for (Rankings__c r : newList) {
            if (r.CC_Person_Organization_ID_RE__c != null) {
                if (cMap.containsKey(r.CC_Person_Organization_ID_RE__c)) {
                    r.Person_RE__c = cMap.get(r.CC_Person_Organization_ID_RE__c);
                }
            }
        }
    }
    
    public static void PopulateLocation(List<Rankings__c> newList) {
        Set<String> locIds = new Set<String>();
        for (Rankings__c r : newList) {
            if (r.Location_ID__c != null) {
                locIds.add(r.Location_ID__c);
            }
        }
        
        Map<String, Id> lMap = new Map<String, Id>();
        for (Location__c l : [SELECT Id, CC_Location_ID__c FROM Location__c WHERE CC_Location_ID__c IN :locIds]){
            lMap.put(l.CC_Location_ID__c, l.Id);
        }
        
        for (Rankings__c r : newList) {
            if (r.Location_ID__c != null) {
                if (lMap.containsKey(r.Location_ID__c)) {
                    r.Location__c = lMap.get(r.Location_ID__c);
                }
            }
        }
    }

    
    public static void SoftDeleted(List<Rankings__c> newList) {
        
        List<Rankings__c> toDelete = new List<Rankings__c>();
        for (Rankings__c s : newList) {
            if (s.CC_To_Be_Deleted__c == true) {
                toDelete.add(new Rankings__c(Id = s.Id));
            }
        }
        
        if (toDelete.size() > 0) {
            delete toDelete;
        }
    }
}