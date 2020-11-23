({
    doInit: function (component, event, helper) {

        component.set('v.loaded', !component.get('v.loaded'));

        let currYear = new Date().getFullYear();
        let nextYear = currYear + 1;
        var yearList = [
            {'label': `${(currYear - 1).toString()} - ${currYear.toString()}`, 'value': (currYear - 1).toString()},
            {'label': `${currYear.toString()} - ${nextYear.toString()}`, 'value': currYear.toString()},
            {'label': `${nextYear.toString()} - ${(nextYear + 1).toString()}`, 'value': nextYear.toString()}];

        var directInsight = [];
        for (var i = 1; i <= 12; i++) {
            directInsight.push({direct: 'Direct \n Target', insight: 'Insight \n Target'});
        }
        component.set("v.DirectInsight", directInsight);
        console.log('start');
        console.log(yearList);
        component.set("v.options", yearList);
        component.set("v.selectedYear", currYear.toString());
        var genDate = component.get("c.generateDates");
        genDate.setParams({selectedYear: parseInt(component.get("v.selectedYear"))});
        genDate.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                helper.genDataTable(component, event, helper);

                // console.log( JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.tableHead", JSON.parse(JSON.stringify(response.getReturnValue())));

                // console.log('>>>>>' + directInsight);
                component.set('v.loaded', !component.get('v.loaded'));

            }
            if (state === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                // component.set('v.loaded', !component.get('v.loaded'));

            }
        });
        $A.enqueueAction(genDate);

        // helper.genDataTable(component,event,helper);

    },

    selectedYearinOption: function (component, event, helper) {

        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue);
        component.set("v.selectedYear", selectedOptionValue);
        // helper.genDataTable(component,event,helper);
        component.set('v.loaded', !component.get('v.loaded'));

        var genDate = component.get("c.generateDates");
        genDate.setParams({selectedYear: parseInt(component.get("v.selectedYear"))});
        genDate.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                helper.genDataTable(component, event, helper);

                // console.log( JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.tableHead", JSON.parse(JSON.stringify(response.getReturnValue())));

                // console.log('>>>>>' + directInsight);
                component.set('v.loaded', !component.get('v.loaded'));

            }
            if (state === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                // component.set('v.loaded', !component.get('v.loaded'));

            }
        });
        $A.enqueueAction(genDate);
    },

    toggle: function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));
        var items = component.get("v.tableBody"), index = event.currentTarget.name;

        items[index].expanded = !items[index].expanded;
        component.set("v.tableBody", items);
        component.set('v.loaded', !component.get('v.loaded'));


    },

    addPublication: function (component, event, helper) {

        var items = component.get("v.tableBody")
        var selectedYear = parseInt(component.get("v.selectedYear"));
        var selectedPublication = component.get("v.selectedLookUpRecords");

        var addPubforSales = [];

        var getAllId = component.find("boxPack");
        if (!Array.isArray(getAllId)) {
            if (getAllId.get("v.value") == true) {
                addPubforSales.push(getAllId.get("v.text"));
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    addPubforSales.push(getAllId[i].get("v.text"));
                }
            }
        }
        console.log(addPubforSales);
        if (addPubforSales.length > 0) {
            component.set('v.loaded', !component.get('v.loaded'));

            var userId = [];
            var oldSalesPerson = [];
            for (var number of addPubforSales) {
                console.log(items[number]);
                userId.push(items[number].userId);
                oldSalesPerson.push(items[number]);
            }
            console.log('oldSalesPerson >> ' + JSON.stringify(oldSalesPerson));

            var addPubl = component.get("c.addPublicationList");
            addPubl.setParams({
                newlistPubl: selectedPublication,
                selectedYear: selectedYear,
                listUser: userId,
                oldListSalesPerson: JSON.stringify(oldSalesPerson)
            });
            addPubl.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getError());
                if (state === 'SUCCESS') {
                    var result = response.getReturnValue();
                    // console.log(result);

                    for (var index of addPubforSales) {
                        for (var i = 0; i < result.length; i++) {
                            if (items[index].userId === result[i].userId) {
                                items[index].publications = result[i].publications
                            }
                        }

                    }
                    // helper.calculateUserTarget(component,event,helper);
                    $A.get('e.force:refreshView').fire();

                    component.set('v.loaded', !component.get('v.loaded'));

                    component.set("v.tableBody", items);
                    component.set("v.selectedLookUpRecords", []);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "The publications has been added successfully."
                    });
                    toastEvent.fire();
                }
                if (state === 'ERROR') {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getError()
                    });
                    toastEvent.fire();
                    component.set('v.loaded', !component.get('v.loaded'));
                }
            });
            $A.enqueueAction(addPubl);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": 'To add a publications, select Sales Person.'
            });
            toastEvent.fire();
        }

    },

    delPublication: function (component, event, helper) {

        var items = component.get("v.tableBody");
        var selectedYear = parseInt(component.get("v.selectedYear"));

        var addPubforSales = [];
        var delPub = [];

        var getAllId = component.find("boxPack");
        if (!Array.isArray(getAllId)) {
            if (getAllId.get("v.value") == true) {
                addPubforSales.push(getAllId.get("v.text"));
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.value") == true) {
                    addPubforSales.push(getAllId[i].get("v.text"));
                }
            }
        }
        var getAllPubId = component.find("boxPub");
        if (getAllPubId != null) {
            if (!Array.isArray(getAllPubId)) {
                if (getAllPubId.get("v.value") == true) {
                    delPub.push(getAllPubId.get("v.text"));
                }
            } else {
                for (var i = 0; i < getAllPubId.length; i++) {
                    if (getAllPubId[i].get("v.value") == true) {
                        delPub.push(getAllPubId[i].get("v.text"));
                    }
                }
            }
        }
        console.log(addPubforSales);
        console.log(delPub);
        if (addPubforSales.length > 0 || delPub.length > 0 ) {
            component.set('v.loaded', !component.get('v.loaded'));

        var action = component.get("c.deletePublication");
        action.setParams({
            selectedYear: selectedYear,
            oldListSalesPerson: JSON.stringify(items)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getError());

            if (state === 'SUCCESS') {
                $A.get('e.force:refreshView').fire();
                // helper.calculateUserTarget(component,event,helper);
                component.set('v.loaded', !component.get('v.loaded'));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The publications has been deleted successfully."
                });
                toastEvent.fire();
            }
            if (state === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
        $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": 'To delete a publications, select Sales Person or Publication.'
            });
            toastEvent.fire();
        }

    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var getAllId = component.find("boxPack");
        if (!Array.isArray(getAllId)) {
            if (selectedHeaderCheck == true) {
                component.find("boxPack").set("v.value", true);
            } else {
                component.find("boxPack").set("v.value", false);
            }
        } else {
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", true);
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("boxPack")[i].set("v.value", false);
                }
            }
        }

        var getAllPubId = component.find("boxPub");
        if (getAllPubId != null) {

            if (!Array.isArray(getAllPubId)) {
                if (selectedHeaderCheck == true) {
                    component.find("boxPub").set("v.value", true);
                } else {
                    component.find("boxPub").set("v.value", false);
                }
            } else {
                if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        component.find("boxPub")[i].set("v.value", true);
                    }
                } else {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        component.find("boxPub")[i].set("v.value", false);
                    }
                }
            }
        }

    },

    checkboxSelectUser: function (component, event, helper) {
        var selectedRec = event.getSource().get("v.value");
        console.log(selectedRec);
        console.log(event.getSource().get("v.text"));
        var getAllPubId = component.find("boxPub");
        if (getAllPubId != null) {
            if (!Array.isArray(getAllPubId)) {
                if (selectedRec == true) {
                    if (event.getSource().get("v.text") === component.find("boxPub").get("labelClass")) {
                        component.find("boxPub").set("v.value", true);
                    }
                } else {
                    if (event.getSource().get("v.text") === component.find("boxPub").get("labelClass")) {
                        component.find("boxPub").set("v.value", false);
                    }
                }
            } else {
                if (selectedRec == true) {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        if (event.getSource().get("v.text") === getAllPubId[i].get("v.labelClass")) {
                            component.find("boxPub")[i].set("v.value", true);
                        }
                    }
                } else {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        if (event.getSource().get("v.text") === getAllPubId[i].get("v.labelClass")) {
                            component.find("boxPub")[i].set("v.value", false);
                        }
                    }
                }
            }
        }


        var item = component.get("v.tableBody");

        if (selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.text")].publications.length; i++) {
                for (var k = 0; k < item[event.getSource().get("v.text")].publications[i].publicTargets1.length; k++) {
                    item[event.getSource().get("v.text")].publications[i].publicTargets1[k].Publication_Visible__c = false;
                }
            }
        } else {
            for (var i = 0; i < item[event.getSource().get("v.text")].publications.length; i++) {
                for (var k = 0; k < item[event.getSource().get("v.text")].publications[i].publicTargets1.length; k++) {
                    item[event.getSource().get("v.text")].publications[i].publicTargets1[k].Publication_Visible__c = true;
                }
            }
        }
        console.log(item);

    },

    checkboxSelectPublication: function (component, event, helper) {
        var item = component.get("v.tableBody");
        var selectedRec = event.getSource().get("v.value");


        if (selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1.length; i++) {
                item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1[i].Publication_Visible__c = false;
            }
        } else {
            for (var i = 0; i < item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1.length; i++) {
                item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1[i].Publication_Visible__c = true;
            }
        }
    },

    inlineEditDirectory: function (component, event, helper) {
        var item = component.get("v.tableBody");

        var element = event.target.id;
        console.log('>>>> ' + event.target.id);
        console.log('>>>> ' + event.currentTarget.id);


        var x = document.querySelectorAll('div[id="' + element + '"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
        }
        // component.set("v.showSaveCancelBtn", true);

        // setTimeout(function(){
        //     component.find("inputId").focus();
        // }, 100);

    },
    closeDirectoryBox: function (component, event, helper) {
        var element = event.getSource().get("v.labelClass");

        var x = document.querySelectorAll('div[id="' + element + '"]');
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);

            var items = component.get("v.tableBody");

            for (var k = 0; k < items[event.getSource().get("v.placeholder")].usTargets.length; k++) {
                items[event.getSource().get("v.placeholder")].usTargets[k].directTarget = 0;
                items[event.getSource().get("v.placeholder")].usTargets[k].insightTarget = 0;
            }

            for (var p = 0; p < items[event.getSource().get("v.placeholder")].publications.length; p++) {
                items[event.getSource().get("v.placeholder")].publications[p].totalpubl = 0;

                for (var t = 0; t < items[event.getSource().get("v.placeholder")].publications[p].publicTargets1.length; t++) {
                    if (items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Directory_Target__c != null) {
                        if (items[event.getSource().get("v.placeholder")].usTargets[t].dateTarget === items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Date__c) {
                            items[event.getSource().get("v.placeholder")].usTargets[t].directTarget += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Directory_Target__c;
                        }
                    }
                    if (items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Insights_Target__c != null) {
                        if (items[event.getSource().get("v.placeholder")].usTargets[t].dateTarget === items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Date__c) {
                            items[event.getSource().get("v.placeholder")].usTargets[t].insightTarget += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Insights_Target__c;
                        }
                    }
                }
            }
            for (var k = 0; k < items[event.getSource().get("v.placeholder")].usTargets.length; k++) {
                items[event.getSource().get("v.placeholder")].totalUser += items[event.getSource().get("v.placeholder")].usTargets[k].directTarget + items[event.getSource().get("v.placeholder")].usTargets[k].insightTarget;
            }

            component.set("v.tableBody", items);
        }
    },

    inlineEditInsight: function (component, event, helper) {
        var item = component.get("v.tableBody");

        var element = event.target.id;
        console.log('>>>> ' + event.target.id);
        console.log('>>>> ' + event.currentTarget.id);

        var x = document.querySelectorAll('div[id="' + element + '"]');

        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";

        }

    },

    closeInsightBox: function (component, event, helper) {
        var element = event.getSource().get("v.labelClass");

        var x = document.querySelectorAll('div[id="' + element + '"]');
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
            var items = component.get("v.tableBody");

            for (var k = 0; k < items[event.getSource().get("v.placeholder")].usTargets.length; k++) {
                items[event.getSource().get("v.placeholder")].usTargets[k].directTarget = 0;
                items[event.getSource().get("v.placeholder")].usTargets[k].insightTarget = 0;
            }

            for (var p = 0; p < items[event.getSource().get("v.placeholder")].publications.length; p++) {
                items[event.getSource().get("v.placeholder")].publications[p].totalpubl = 0;

                for (var t = 0; t < items[event.getSource().get("v.placeholder")].publications[p].publicTargets1.length; t++) {
                    if (items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Directory_Target__c != null) {
                        if (items[event.getSource().get("v.placeholder")].usTargets[t].dateTarget === items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Date__c) {
                            items[event.getSource().get("v.placeholder")].usTargets[t].directTarget += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Directory_Target__c;
                            items[event.getSource().get("v.placeholder")].publications[p].totalpubl += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Directory_Target__c;
                        }
                    }
                    if (items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Insights_Target__c != null) {
                        if (items[event.getSource().get("v.placeholder")].usTargets[t].dateTarget === items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Date__c) {
                            items[event.getSource().get("v.placeholder")].usTargets[t].insightTarget += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Insights_Target__c;
                            items[event.getSource().get("v.placeholder")].publications[p].totalpubl += items[event.getSource().get("v.placeholder")].publications[p].publicTargets1[t].Insights_Target__c;
                        }
                    }
                }
            }
            for (var k = 0; k < items[event.getSource().get("v.placeholder")].usTargets.length; k++) {
                items[event.getSource().get("v.placeholder")].totalUser += items[event.getSource().get("v.placeholder")].usTargets[k].directTarget + items[event.getSource().get("v.placeholder")].usTargets[k].insightTarget;
            }
            component.set("v.tableBody", items);
        }
    },

    saveButton: function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var item = JSON.stringify(component.get("v.tableBody"));

        var action = component.get("c.saveSalesTarget");
        action.setParams({salesTarget: item});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            console.log(response.getError());
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                component.set("v.showSaveCancelBtn", false);

                component.set('v.loaded', !component.get('v.loaded'));
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Data has been saved successfully."
                });
                toastEvent.fire();
            }
            if (state === 'ERROR') {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "error",
                    "message": response.getError()
                });
                toastEvent.fire();
                component.set('v.loaded', !component.get('v.loaded'));
            }
        });
        $A.enqueueAction(action);
    },

    cancelButton: function (component, event, helper) {
        component.set("v.showSaveCancelBtn", false);

    }

})