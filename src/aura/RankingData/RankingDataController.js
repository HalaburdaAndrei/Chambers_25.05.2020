({
    doInit : function(component, event, helper) {
        var currentOrderId = component.get("v.recordId");
        var action = component.get("c.getRankings");

        action.setParams({ recordType : "Organization Ranking",
                            recordId : component.get("v.recordId")});

        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var Responsedata = response.getReturnValue();
                //alert('Responsedata--'+JSON.stringify(Responsedata));
                console.log(Responsedata.table);
                component.set("v.items", response.getReturnValue().table);
                component.set("v.items1", response.getReturnValue().table[0].listYear);

            }
        });

        $A.enqueueAction(action);
    },

    toggle: function(component, event, helper) {
        var items = component.get("v.items"), index = event.target.dataset.index;
        items[index].expanded = !items[index].expanded;
        component.set("v.items", items);
        component.set("v.sortindex", index);
        console.log(event.target.dataset.index);

    },

    handleSelect: function (component, event, helper) {
            if (event.getParam('id') === 'Organization') {
                component.set('v.loaded', !component.get('v.loaded'));
                var action = component.get("c.getRankings");

                action.setParams({ recordType : "Organization Ranking",
                                     recordId : component.get("v.recordId")});

                action.setCallback(this, function(response) {
                    var state = response.getState();
                    //alert(state);
                    if (state === "SUCCESS") {
                        var Responsedata = response.getReturnValue();
                        //alert('Responsedata--'+JSON.stringify(Responsedata));
                        console.log(Responsedata.table);
                        component.set("v.items", response.getReturnValue().table);
                        component.set("v.items1", response.getReturnValue().table[0].listYear);
                        component.set('v.loaded', !component.get('v.loaded'));


                    }
                });

                $A.enqueueAction(action);
            }
        if (event.getParam('id') === 'Employees') {
            component.set('v.loaded', !component.get('v.loaded'));
            var action = component.get("c.getRankings");

            action.setParams({ recordType : "Person Ranking" ,
                                recordId : component.get("v.recordId")});

            action.setCallback(this, function(response) {
                var state = response.getState();
                //alert(state);
                if (state === "SUCCESS") {

                    var Responsedata = response.getReturnValue();
                    //alert('Responsedata--'+JSON.stringify(Responsedata));
                    console.log(Responsedata.table);
                    component.set("v.items", response.getReturnValue().table);
                    component.set("v.items1", response.getReturnValue().table[0].listYear);
                    component.set('v.loaded', !component.get('v.loaded'));


                }
            });

            $A.enqueueAction(action);
        }
    },

    sortByPracticeArea: function (component, event, helper) {
        helper.sortBy(component, event, "practiceArea");
    },

    sortByLocation: function (component, event, helper) {
        helper.sortBy(component, event, "location");
    },

    sortByType: function (component, event, helper) {
        helper.sortBy(component, event, "type");
    },

    sortByLocationOfExpertise: function (component, event, helper) {
        helper.sortBy(component, event, "locationOfExpertise");
    },

    sortByBranch: function (component, event, helper) {
        helper.sortBy(component, event, "branch");
    },

    sortByHeadOffice: function (component, event, helper) {
        helper.sortBy(component, event, "headOffice");
    },

    sortByPerson: function (component, event, helper) {
        helper.sortBy(component, event, "person");
    },

})