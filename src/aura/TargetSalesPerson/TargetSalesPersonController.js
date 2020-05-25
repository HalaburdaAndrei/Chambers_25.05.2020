/**
 * Created by novab on 18.05.2020.
 */
({
    doInit: function (component, event, helper) {
        component.set('v.columns', [
            {label: 'Sales Person', fieldName: 'Sales_Person', type: 'String'},
            {label: 'Target', fieldName: 'Target', type: 'Double', editable: true},
            {label: 'Target Date', fieldName: 'Target_Date', type:'Date'}
        ]);

        var action = component.get("c.targetList");
        // action.setParams({
        //     accountId: component.get("v.recordId"),
        //     fromdate: component.get("v.fromdate"),
        //     todate: component.get("v.todate"),
        //     manufId: manufid
        // });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = JSON.parse(response.getReturnValue());
                var list = [];
                for(var i = 0; i < records.length; i++ ){
                    list.push({Sales_Person: records[i].Sales_Person, Target: records[i].Target, Target_Date: records[i].Target_Date});
                }
console.log('>>>>>> ' + records[0].Sales_Person);
                console.log(list);

                component.set("v.targetSalesPersonList", list);
                // helper.sortData(component, component.get("v.sortedBy"), component.get("v.sortedDirection"));
            }
        });

        $A.enqueueAction(action);
    }
})