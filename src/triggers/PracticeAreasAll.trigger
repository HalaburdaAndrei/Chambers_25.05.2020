trigger PracticeAreasAll on Practice_Area__c (after insert) {

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            PracticeAreasAllHandler.PopulateParentPracticeArea(Trigger.newMap);
        }
    }    
    
}