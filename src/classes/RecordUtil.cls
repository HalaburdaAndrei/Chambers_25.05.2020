public with sharing class RecordUtil {
    public static void ReparentChildRecords(String objName, Map<Id,Id> newRecIdMap, Set<Id> delIds) {
        
        // Map<String,String> insertObjects = new Map<String,String>();
        // Map<String,String> ignoreObjects = new Map<String,String>{'AccountContactRelations'=>'ContactId','Shares'=>'UserOrGroupId,AccountAccessLevel,OpportunityAccessLevel,CaseAccessLevel,ContactAccessLevel,RowCause'};

        // Build a list of Join Query Strings using a Maximum of 20 Child Objects
        Map<Integer,String> queries = new Map<Integer,String>();
        Map<Integer,List<String>> queryObjects = new Map<Integer,List<String>>();
        Map<String,String> childObjectFields = new Map<String,String>();
        Integer ct = 1;
        Integer index = 0;
        String current = '';
        Schema.DescribeSObjectResult sObj = Schema.getGlobalDescribe().get(objName).getDescribe();
        for (Schema.ChildRelationship sObjRel: sObj.getChildRelationships()){
            Schema.DescribeSObjectResult cObj = sObjRel.getChildSObject().getDescribe();
            if(sObjRel.getRelationshipName()!=null && cObj.isQueryable() && cObj.isAccessible()){
                System.debug('OBJECT: '+String.valueOf(sObjRel.getRelationshipName()));
                String childObj = String.valueOf(sObjRel.getRelationshipName());
                // if(ignoreObjects.containsKey(childObj)) continue;
                DescribeFieldResult parField = sObjRel.getField().getDescribe();
                System.debug('Parent FIelds: '+String.valueOf(sObjRel.getField())+' :: '+parField.getName());
                if(!parField.isUpdateable()) continue;
                String parentFld = parField.getName();
                childObjectFields.put(childObj, parentFld);
                if(queryObjects.get(index)==null)
                    queryObjects.put(index, new List<String>());
                queryObjects.get(index).add(childObj);
                // String selFields = (insertObjects.containsKey(childObj) && insertObjects.get(childObj)!='') ? ','+insertObjects.get(childObj) : '' ;
                String thisQuery = '(SELECT Id, '+parentFld+' FROM '+childObj+')';
                System.debug('thisQuery---------->'+thisQuery);
                current+=(current!='' ? ', ' : '')+thisQuery;
                if(Math.mod(ct,20)==0){
                    queries.put(index,current);
                    current = '';
                    index++;
                }
                ct++;
            }
            if(Math.mod((ct-1),20)!=0){
                queries.put(index,current);
            }
        }
        // List of Records to Update
        Map<Id,SObject> recordsToUpdate = new Map<Id,SObject>();
        // List<SObject> recordsToInsert = new List<SObject>();
        // Set<Id> recordsUpdating = new Set<Id>();

        // Loop through list of queries
        for(Integer indx : queries.keySet()){

            // Get Records with Child Records using Dynamically Built Join Queries
            System.debug('delIds ---------------->'+delIds);
            System.debug('SELECT Id, '+queries.get(indx)+' FROM '+objName+' WHERE Id IN :delIds');
            List<SObject> subRecs = Database.query('SELECT Id, '+queries.get(indx)+' FROM '+objName+' WHERE Id IN :delIds');

            // Loop through Parent Records Received
            for(SObject subRec: subRecs){

                // Loop through Child Objects in this Query
                for(String cObjName : queryObjects.get(indx)){

                    // if(ignoreObjects.containsKey(cObjName)) continue;
                    // Get ParentFld for Current Child Object
                    String parentFld = childObjectFields.get(cObjName);
                    if(subRec.getSobjects(cObjName)!=null)
                        System.debug('Current Object ------------------>'+cObjName);
                        // Loop through Child Records in Parent record For Specific Child Object
                        if(subRec!=null && subRec.getSobjects(cObjName)!=null)
                            for(SObject cObj : (List<SObject>)subRec.getSobjects(cObjName)){
                                Id newRecId = newRecIdMap.get((Id)cObj.get(parentFld));
                                if((Id)cObj.get(parentFld)!=newRecId){
                                    SObject upObj = cObj;
                                    if(recordsToUpdate.containsKey(cObj.Id))
                                        upObj = recordsToUpdate.get(cObj.Id);
                                    upObj.put(parentFld, newRecId);
                                    // if(!recordsUpdating.contains(cObj.Id)){
                                    recordsToUpdate.put(upObj.Id,upObj);
                                    // recordsUpdating.add(cObj.Id);
                                    // }
                                    // }
                                }
                            }
                }
            }
        }
        System.debug('recordsToUpdate ------------------>'+recordsToUpdate);
        // System.debug('recordsToInsert ------------------>'+recordsToInsert);
        // Update Child Records
        if(!recordsToUpdate.isEmpty())
            update recordsToUpdate.values();
        // if(!recordsToInsert.isEmpty())
        //     insert recordsToInsert;
    }
}