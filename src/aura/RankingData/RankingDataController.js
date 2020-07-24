({
    doInit: function (component, event, helper) {
        // component.set('v.recordId', component.get("v.pageReference").state.C__id);

        component.set('v.loaded', !component.get('v.loaded'));

        var action = component.get("c.getpublicationType");
        action.setParams({
            recordType: "Organization Ranking",
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var Responsedata = response.getReturnValue();
                if (response.getReturnValue().table != null) {
                    component.set("v.items", response.getReturnValue().table);
                    component.set("v.listYearForColumn", response.getReturnValue().table[0].listYear);
                } else {
                    component.set("v.items", null);
                }
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
        $A.enqueueAction(action);
    },

    toggle: function (component, event, helper) {

        var map = new Map();
        var yearlist = component.get("v.listYearForColumn");
        for(var year of yearlist){
            map.set(year, '');
        }
        component.set("v.yearRank", map);
        console.log(map);

        var items = component.get("v.items"), index = event.currentTarget.name;

        for (var i = 0; i < items.length; i++) {
            if (index == i) {
                items[index].expanded = !items[index].expanded;
                component.set("v.items", items);
            } else {
                items[i].expanded = false;
                component.set("v.items", items);
            }
        }

        if (items[index].expanded == true) {
            if (component.get("v.selTabId") === 'Organization Ranking') {

                component.set('v.loaded', !component.get('v.loaded'));
                component.set("v.filterType", '');
                component.set("v.filterBranch", '');
                component.set("v.filterLocation", '');
                component.set("v.filterLocationOfExpertise", '');
                component.set("v.filterPerson", '');
                component.set("v.filterPracticeArea", '');

                var action = component.get("c.getRankings");
                action.setParams({
                    recordType: component.get("v.selTabId"),
                    recordId: component.get("v.recordId"),
                    pubType: items[index].publication,
                    listYear: items[index].listYear
                    // initialRows : component.get("v.initialRows") //how many rows to load during initialization
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        var Responsedata = response.getReturnValue();
                        if (response.getReturnValue().table != null) {
                            component.set("v.items1", response.getReturnValue().table);
                            // component.set("v.items2", response.getReturnValue().table);
                            component.set("v.UnfilteredData", response.getReturnValue().table);
                            component.set("v.expended", true);
                            component.set("v.selectIndex", index);
                            // component.set("v.totalRows",response.getReturnValue().table[0].totalRecords);
                            // console.log(response.getReturnValue().table[0].totalRecords);
                            // component.set("v.listYearForColumn", response.getReturnValue().table[0].listYear);
                        } else {
                            component.set("v.items1", null);
                        }
                        component.set('v.loaded', !component.get('v.loaded'));
                    }
                });
                $A.enqueueAction(action);
            }

            if (component.get("v.selTabId") === 'Person Ranking') {

                component.set('v.loaded', !component.get('v.loaded'));
                component.set("v.filterType", '');
                component.set("v.filterBranch", '');
                component.set("v.filterLocation", '');
                component.set("v.filterLocationOfExpertise", '');
                component.set("v.filterPerson", '');
                component.set("v.filterPracticeArea", '');

                var action = component.get("c.getRankings");
                action.setParams({
                    recordType: component.get("v.selTabId"),
                    recordId: component.get("v.recordId"),
                    pubType: items[index].publication,
                    listYear: items[index].listYear
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        var Responsedata = response.getReturnValue();
                        if (response.getReturnValue().table != null) {
                            component.set("v.items1", response.getReturnValue().table);
                            // component.set("v.items2", response.getReturnValue().table);
                            component.set("v.UnfilteredData", response.getReturnValue().table);
                            component.set("v.expended", true);
                            component.set("v.selectIndex", index);
                        } else {
                            component.set("v.items1", null);
                        }
                        component.set('v.loaded', !component.get('v.loaded'));
                    }
                });
                $A.enqueueAction(action);
            }

        } else {
            component.set("v.items1", null);
            component.set("v.expended", false);
        }

        // var items = component.get("v.items"), index = event.currentTarget.name;
        // console.log('index', index);
        //
        // items[index].expanded = !items[index].expanded;
        // component.set("v.items", items);


    },

    handleSelect: function (component, event, helper) {
        if (event.getParam('id') === 'Organization Ranking') {

            component.set("v.filterType", '');
            component.set("v.filterBranch", '');
            component.set("v.filterLocation", '');
            component.set("v.filterLocationOfExpertise", '');
            component.set("v.filterPerson", '');
            component.set("v.filterPracticeArea", '');
            component.set("v.expended", false);
            component.set('v.loaded', !component.get('v.loaded'));

            var action = component.get("c.getpublicationType");
            action.setParams({
                recordType: component.get("v.selTabId"),
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var Responsedata = response.getReturnValue();
                    if (response.getReturnValue().table != null) {
                        component.set("v.items", response.getReturnValue().table);
                        component.set("v.listYearForColumn", response.getReturnValue().table[0].listYear);
                    }
                    component.set('v.loaded', !component.get('v.loaded'));
                }
            });
            $A.enqueueAction(action);
        }

        if (event.getParam('id') === 'Person Ranking') {

            component.set("v.filterType", '');
            component.set("v.filterBranch", '');
            component.set("v.filterLocation", '');
            component.set("v.filterLocationOfExpertise", '');
            component.set("v.filterPerson", '');
            component.set("v.filterPracticeArea", '');
            component.set("v.expended", false);
            component.set('v.loaded', !component.get('v.loaded'));

            var action = component.get("c.getpublicationType");
            action.setParams({
                recordType: component.get("v.selTabId"),
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var Responsedata = response.getReturnValue();
                    if (response.getReturnValue().table != null) {
                        component.set("v.items", response.getReturnValue().table);
                        component.set("v.listYearForColumn", response.getReturnValue().table[0].listYear);
                    }
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
    sortByYear: function (component, event, helper) {
        component.set('v.targetYear', event.currentTarget.dataset.year);
        helper.sortByYear(component, event, "rankingYear");
    },

    filterby : function (component, event, helper) {

        var timer = component.get('v.timer');
        clearTimeout(timer);

        var timer = setTimeout(function(){
            helper.getData(component, event);
            clearTimeout(timer);
            component.set('v.timer', null);
        }, 500);

        component.set('v.timer', timer);
    },

    yearFilter: function (component, event, helper) {

        var r = component.get("v.yearRank");
        r.delete(event.target.id);
        r[event.target.id] = event.target.value;
        component.set("v.yearRank", r);
        helper.FilterRecords(component,event);
    },

})