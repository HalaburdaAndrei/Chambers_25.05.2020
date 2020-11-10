({
    doInit: function (component, event, helper) {
        let currYear = new Date().getFullYear();
        let nextYear = currYear + 1;
        var yearList = [
            {'label': `${(currYear - 1).toString()} - ${nextYear.toString()}`, 'value': (currYear - 1).toString()},
            {'label': `${currYear.toString()} - ${nextYear.toString()}`, 'value': currYear.toString()},
            {'label': `${nextYear.toString()} - ${(nextYear + 1).toString()}`, 'value': nextYear.toString()}];

        console.log('start');
        console.log(yearList);
        component.set("v.options", yearList);
        component.set("v.selectedYear", currYear.toString());
        var genDate = component.get("c.generateDates");
        genDate.setParams({selectedYear: 2020});
        genDate.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                // console.log( JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.tableHead", JSON.parse(JSON.stringify(response.getReturnValue())));
                var directInsight = [];
                for (var i = 1; i <= 12; i++) {
                    directInsight.push({direct: 'Direct \n Target', insight: 'Insight \n Target'});
                }
                component.set("v.DirectInsight", directInsight);
                // console.log('>>>>>' + directInsight);
            }
        });
        $A.enqueueAction(genDate);

        var selectedYear = parseInt(component.get("v.selectedYear"));

        var action = component.get("c.generateDataTable");
        action.setParams({selectedYear: selectedYear});
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                console.log(JSON.parse(JSON.stringify(response.getReturnValue().table)));

                component.set("v.tableBody", JSON.parse(JSON.stringify(response.getReturnValue().table)));
            }
        });
        $A.enqueueAction(action);

    },

    selectedYearinOption: function (component, event) {

        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue)

        // var selectedYear = parseInt(component.get("v.selectedYear"));
        //
        // var action = component.get("c.generateDataTable");
        // action.setParams({selectedYear: selectedYear});
        // action.setCallback(this, function (response) {
        //     var state = response.getState();
        //     console.log(state);
        //     if (state === "SUCCESS") {
        //         console.log(JSON.parse(JSON.stringify(response.getReturnValue().table)));
        //
        //         component.set("v.tableBody", JSON.parse(JSON.stringify(response.getReturnValue().table)));
        //         $A.get('e.force:refreshView').fire();
        //     }
        // });
        // $A.enqueueAction(action);

    },

    toggle: function (component, event, helper) {
        var items = component.get("v.tableBody"), index = event.currentTarget.name;
        // console.log('>>>>>>> ' + event.currentTarget.name);

        items[index].expanded = !items[index].expanded;
        component.set("v.tableBody", items);
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
                console.log(result);

                for (var index of addPubforSales) {
                    for (var i = 0; i < result.length; i++) {
                        if (items[index].userId === result[i].userId) {
                            items[index].publications = result[i].publications
                        }
                    }

                }

                component.set("v.tableBody", items);
                component.set("v.selectedLookUpRecords", []);

            }
        });
        $A.enqueueAction(addPubl);

    },

    selectAll: function (component, event, helper) {
        //get the header checkbox value
        var selectedHeaderCheck = event.getSource().get("v.value");
        // get all checkbox on table with "boxPack" aura id (all iterate value have same Id)
        // return the List of all checkboxs element
        var getAllId = component.find("boxPack");
        // If the local ID is unique[in single record case], find() returns the component. not array
        if (!Array.isArray(getAllId)) {
            if (selectedHeaderCheck == true) {
                component.find("boxPack").set("v.value", true);
            } else {
                component.find("boxPack").set("v.value", false);
            }
        } else {
            // check if select all (header checkbox) is true then true all checkboxes on table in a for loop
            // and set the all selected checkbox length in selectedCount attribute.
            // if value is false then make all checkboxes false in else part with play for loop
            // and select count as 0
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

    },

    checkboxSelect: function (component, event, helper) {
        // get the selected checkbox value
        var selectedRec = event.getSource().get("v.value");
        console.log(selectedRec);

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

        var pubcheckBox = [];
        var getAllPubId = component.find("boxPub");
        if (!Array.isArray(getAllPubId)) {
            if (getAllPubId.get("v.value") == true) {
                pubcheckBox.push(getAllPubId.get("v.text"));
            }
        } else {
            for (var i = 0; i < getAllPubId.length; i++) {
                if (getAllPubId[i].get("v.value") == true) {
                    pubcheckBox.push(getAllPubId[i].get("v.text"));
                }
            }
        }
        console.log(addPubforSales);
        console.log(pubcheckBox);
    },

    inlineEditName: function (component, event, helper) {
        // show the name edit field popup
        component.set("v.nameEditMode", true);
        // after the 100 millisecond set focus to input field
        setTimeout(function () {
            // component.find("inputId").focus();
            console.log(component.find("inputId"));
            component.find("inputId");
        }, 100);
    },

    onNameChange: function (component, event, helper) {
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if (event.getSource().get("v.value").trim() != '') {
            component.set("v.showSaveCancelBtn", true);
        }
    },

    closeNameBox: function (component, event, helper) {
        // on focus out, close the input section by setting the 'nameEditMode' att. as false
        component.set("v.nameEditMode", false);
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False
        if (event.getSource().get("v.value").trim() == '') {
            component.set("v.showErrorClass", true);
        } else {
            component.set("v.showErrorClass", false);
        }
    },

})