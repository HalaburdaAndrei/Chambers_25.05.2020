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
                helper.genDataTable(component,event,helper);

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
                helper.genDataTable(component,event,helper);

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
        // console.log('>>>>>>> ' + event.currentTarget.name);

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
        if(addPubforSales.length > 0) {
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
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": 'To add a publications, select Sales Person.'
            });
            toastEvent.fire();
        }

    },

    delPublication: function (component, event, helper){
        component.set('v.loaded', !component.get('v.loaded'));

        var items = component.get("v.tableBody");
        var selectedYear = parseInt(component.get("v.selectedYear"));
        var action = component.get("c.deletePublication");
        action.setParams({
            selectedYear: selectedYear,
            oldListSalesPerson: JSON.stringify(items)
        });
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           console.log(response.getError());

           if(state === 'SUCCESS'){
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

        var getAllPubId = component.find("boxPub");
        if(getAllPubId != null) {

            // If the local ID is unique[in single record case], find() returns the component. not array
            if (!Array.isArray(getAllPubId)) {
                if (selectedHeaderCheck == true) {
                    component.find("boxPub").set("v.value", true);
                } else {
                    component.find("boxPub").set("v.value", false);
                }
            } else {
                // check if select all (header checkbox) is true then true all checkboxes on table in a for loop
                // and set the all selected checkbox length in selectedCount attribute.
                // if value is false then make all checkboxes false in else part with play for loop
                // and select count as 0
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
        // If the local ID is unique[in single record case], find() returns the component. not array
        if(getAllPubId != null) {
            if (!Array.isArray(getAllPubId)) {
                if (selectedRec == true) {
                    if(event.getSource().get("v.text") === component.find("boxPub").get("labelClass")) {
                        component.find("boxPub").set("v.value", true);
                    }
                } else {
                    if(event.getSource().get("v.text") === component.find("boxPub").get("labelClass")) {
                        component.find("boxPub").set("v.value", false);
                    }
                }
            } else {
                // check if select all (header checkbox) is true then true all checkboxes on table in a for loop
                // and set the all selected checkbox length in selectedCount attribute.
                // if value is false then make all checkboxes false in else part with play for loop
                // and select count as 0
                if (selectedRec == true) {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        if(event.getSource().get("v.text") === getAllPubId[i].get("v.labelClass")) {
                            component.find("boxPub")[i].set("v.value", true);
                        }
                    }
                } else {
                    for (var i = 0; i < getAllPubId.length; i++) {
                        if(event.getSource().get("v.text") === getAllPubId[i].get("v.labelClass")) {
                            component.find("boxPub")[i].set("v.value", false);
                        }
                    }
                }
            }
        }


        var item = component.get("v.tableBody");

        if(selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.text")].publications.length; i++) {
                for(var k = 0; k < item[event.getSource().get("v.text")].publications[i].publicTargets1.length; k++) {
                    item[event.getSource().get("v.text")].publications[i].publicTargets1[k].Publication_Visible__c = false;
                }
            }
        }else{
            for (var i = 0; i < item[event.getSource().get("v.text")].publications.length; i++) {
                for(var k = 0; k < item[event.getSource().get("v.text")].publications[i].publicTargets1.length; k++) {
                    item[event.getSource().get("v.text")].publications[i].publicTargets1[k].Publication_Visible__c = true;
                }
            }
        }
        console.log(item);

    },

    checkboxSelectPublication: function (component, event, helper) {
        // get the selected checkbox value
        // console.log('Start');
        var item = component.get("v.tableBody");
        // console.log(event.getSource().get("v.labelClass"));
        // console.log(event.getSource().get("v.text"));
        var selectedRec = event.getSource().get("v.value");


        if(selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1.length; i++) {
                item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1[i].Publication_Visible__c = false;
            }
        }else{
            for (var i = 0; i < item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1.length; i++) {
                item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1[i].Publication_Visible__c = true;
            }
        }
        // console.log(item[event.getSource().get("v.labelClass")].publications[event.getSource().get("v.text")].publicTargets1);
        // console.log(selectedRec);


    },

    inlineEditDirectory: function (component, event, helper) {
        var item = component.get("v.tableBody");
        // console.log(event.target.dataset.user);
        // console.log(event.target.dataset.pub);
        // console.log(event.target.dataset.datadirectory);

        var element = event.target.id;
        console.log('>>>> ' + event.target.id);
        console.log('>>>> ' + event.currentTarget.id);


        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            // console.log(item);

        }
        // component.set("v.showSaveCancelBtn", true);

        // helper.calculateUserTarget(component,event,helper);

        // setTimeout(function(){
        //     component.find("inputId").focus();
        // }, 100);

    },
    closeDirectoryBox : function (component, event, helper) {
        var element = event.getSource().get("v.labelClass");

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            // console.log(item);

        }
    },
    calcTotal : function (component, event, helper){
      console.log('22222');
        // var element = event.getSource().get("v.labelClass");
        //
        // var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        // for (var i = 0; i < x.length; i++) {
        //
        //     var json_str = x[i].getAttribute('id');
        //     var data = JSON.parse(json_str);
        //     console.log(data.id);
        //
        // }
    },

    inlineEditInsight: function (component, event, helper) {
        var item = component.get("v.tableBody");

        var element = event.target.id;
        console.log('>>>> ' + event.target.id);
        console.log('>>>> ' + event.currentTarget.id);


        // console.log('>>>> ' + event.target.id);
        // console.log(element);
        // console.log(element.toString());

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            // console.log(item);

        }
        component.set("v.showSaveCancelBtn", true);
        // helper.calculateUserTarget(component,event,helper);
        // helper.genDataTable(component,event,helper);

        // component.set("v.showErrorClass", true);
        // console.log(component.get("v.showSaveCancelBtn"));
    },

    closeInsightBox : function (component, event, helper) {
        var element = event.getSource().get("v.labelClass");

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            helper.calculateUserTarget(component,event,helper);

            // console.log(item);

        }
    },

    saveButton: function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var item = component.get("v.tableBody");

        var action = component.get("c.saveSalesTarget");
        action.setParams({salesTarget: JSON.stringify(item)});
        action.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === "SUCCESS"){
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

    cancelButton : function (component, event, helper) {
        component.set("v.showSaveCancelBtn", false);

    }

})