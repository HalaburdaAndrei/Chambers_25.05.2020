({
    doInit: function (component, event, helper) {

        var getPicklistCategory = component.get("c.getPicklistProductCategory");
        getPicklistCategory.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
           if(state === 'SUCCESS'){
               console.log(response.getReturnValue());
               var result = response.getReturnValue();
               var items = [];
               for (var i = 0; i < result.length; i++) {
                   var item = {
                       "Id": result[i],
                       "Name": result[i]
                   };
                   items.push(item);
               }
               console.log(items);
               component.set("v.selectedProdCategory", items[0].value);
               component.set("v.options", items);

           }
        });
        $A.enqueueAction(getPicklistCategory);

        var getresultTable = component.get("c.generateDataTable");
        getresultTable.setCallback(this, function (response) {
           var state = response.getState();
           console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue().table;
                console.log('start');
                console.log(response.getReturnValue().table);
                component.set("v.resultTableTarget", result);

                var items = component.get("v.resultTableTarget");

                for(var i = 0; i < items.length; i++){

                    for(var p = 0; p < items[i].productCategaryRows.length; p++){
                        if(items[i].publicationId === items[i].productCategaryRows[p].publicationTargets[0].Publication__c ){
                            items[i].publicationDirectoryAllocatedTarget += items[i].productCategaryRows[p].publicationTargets[0].Directory_Allocated_Target__c;
                        }
                        if(items[i].publicationId === items[i].productCategaryRows[p].publicationTargets[0].Publication__c ){
                            items[i].publicationInsightsAllocatedTarget += items[i].productCategaryRows[p].publicationTargets[0].Insights_Allocated_Target__c;
                        }

                    }
                }
            }
        });
        $A.enqueueAction(getresultTable);



    },

    toggle: function (component, event, helper) {

        var items = component.get("v.resultTableTarget"), index = event.currentTarget.name;
        items[index].expanded = !items[index].expanded;
        component.set("v.resultTableTarget", items);

    },

    // selectedProductcategoryOption : function (component, event, helper){
    //     //
    //     // var selectedOptionValue = event.getParam("value");
    //     // console.log(selectedOptionValue);
    //
    //     const selectedOptions = component.find("jobLocationMS").get("v.selectedOptions");
    //     console.log(selectedOptions);
    //
    //     // var getPicklistCategory = component.get("c.getPicklistProductCategory");
    //     // getPicklistCategory.setCallback(this, function (response) {
    //     //     var state = response.getState();
    //     //     console.log(state);
    //     //     if(state === 'SUCCESS'){
    //     //         console.log(response.getReturnValue());
    //     //         component.set("v.options", response.getReturnValue());
    //     //     }
    //     // });
    //     // $A.enqueueAction(getPicklistCategory);
    //
    //
    // },

    addPublication : function(component,event, helper){
        const selectedOptions = component.find("jobLocationMS").get("v.selectedOptions");
        console.log(selectedOptions);
        var listcategory = [];
        for(var i = 0; i < selectedOptions.length; i++){
            listcategory.push(selectedOptions[i].Id);
        }
        console.log(listcategory);

      var selectedPublication = component.get("v.selectedLookUpRecords");
      var oldResultTable = JSON.stringify(component.get("v.resultTableTarget"));
      var selProdcategory = component.get("v.selectedProdCategory");
      var addPub = component.get("c.addPublicationApex");
      addPub.setParams({listNewPublications : selectedPublication,
                        jsonResultTable : oldResultTable,
                        selectedProductCategory : listcategory});
      addPub.setCallback(this, function (response) {
         var state = response.getState();
         console.log(state);
         if(state === 'SUCCESS'){
             var result = response.getReturnValue();
             var items = component.get("v.resultTableTarget");
             // items.push(response.getReturnValue()[0]);
             // console.log(response.getReturnValue()[0]);
// console.log(items.length);


             component.set("v.resultTableTarget", result);

         }
      });
      $A.enqueueAction(addPub);
    },

    delPublication : function(component, event, helper){
      var items = JSON.stringify(component.get("v.resultTableTarget"));

      var delPub = component.get("c.deletePublication");
      delPub.setParams({jsonResultTable : items});
      delPub.setCallback(this, function (response) {
         var state = response.getState();
         console.log(state);
         if(state === 'SUCCESS'){
             console.log('delete');
             $A.get('e.force:refreshView').fire();

         }
      });
      $A.enqueueAction(delPub);
    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.target.checked;
        console.log(event.target.checked);
        console.log(component.find("checkboxPublication"));

        var getAllId = component.find("checkboxPublication");
        if (!Array.isArray(getAllId)) {
            if (selectedHeaderCheck == true) {
                component.find("checkboxPublication").set("v.checked", true);
            } else {
                component.find("checkboxPublication").set("v.checked", false);
            }
        } else {
            if (selectedHeaderCheck == true) {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("checkboxPublication")[i].set("v.checked", true);

                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("checkboxPublication")[i].set("v.checked", false);
                }
            }
        }

        var getAllIdCategory = component.find("checkboxProductCategary");
        if(getAllIdCategory != null) {
            if (!Array.isArray(getAllIdCategory)) {
                if (selectedHeaderCheck == true) {
                    component.find("checkboxProductCategary").set("v.checked", true);
                } else {
                    component.find("checkboxProductCategary").set("v.checked", false);
                }
            } else {
                if (selectedHeaderCheck == true) {
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        component.find("checkboxProductCategary")[i].set("v.checked", true);

                    }
                } else {
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        component.find("checkboxProductCategary")[i].set("v.checked", false);
                    }
                }
            }
        }
    },

    selectPublicationCheckBox : function(component, event, helper){
        var selectedRec = event.getSource().get("v.checked");
        console.log(selectedRec);

        var getAllIdCategory = component.find("checkboxProductCategary");
        if(getAllIdCategory != null) {
            if (!Array.isArray(getAllIdCategory)) {
                if (selectedRec == true) {
                    if(event.getSource().get("v.id") === component.find("checkboxProductCategary").get("v.name")) {

                        component.find("checkboxProductCategary").set("v.checked", true);
                    }
                } else {
                    if(event.getSource().get("v.id") === component.find("checkboxProductCategary").get("v.name")) {
                        component.find("checkboxProductCategary").set("v.checked", false);
                    }
                }
            } else {
                if (selectedRec == true) {
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        if(event.getSource().get("v.id") === component.find("checkboxProductCategary")[i].get("v.name")) {
                            component.find("checkboxProductCategary")[i].set("v.checked", true);
                        }
                    }
                } else {
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        if(event.getSource().get("v.id") === component.find("checkboxProductCategary")[i].get("v.name")) {
                            component.find("checkboxProductCategary")[i].set("v.checked", false);
                        }
                    }
                }
            }
        }

        var item = component.get("v.resultTableTarget");

        if(selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.id")].productCategaryRows.length; i++) {
                // for(var k = 0; k < item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets.length; k++) {
                    item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets[0].Category_Visible__c = false;
                // }
            }
        }else{
            for (var i = 0; i < item[event.getSource().get("v.id")].productCategaryRows.length; i++) {
                // for(var k = 0; k < item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets.length; k++) {
                    item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets[0].Category_Visible__c = true;
                // }
            }
        }

    },

    selectProductcategoryCheckBox : function(component, event, helper){
        var selectedRec = event.getSource().get("v.checked");
        console.log(selectedRec);
        var item = component.get("v.resultTableTarget");
        if(selectedRec == true) {
                    item[event.getSource().get("v.name")].productCategaryRows[event.getSource().get("v.id")].publicationTargets[0].Category_Visible__c = false;
        }else{
                    item[event.getSource().get("v.name")].productCategaryRows[event.getSource().get("v.id")].publicationTargets[0].Category_Visible__c = true;
        }

    },

    inlineEditDirectoryAllocatedTarget : function (component, event, helper) {
        // var item = component.get("v.resultTableTarget");

        var element = event.target.id;

        // console.log(event.target.dataset.numberrow);

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
            // console.log(item);

        }
        // console.log(component.find("focusIdDirectory"));

        setTimeout(function(){
            component.find("focusIdDirectory")[event.target.dataset.numberrow].focus();
            // console.log(component.find("focusIdDirectory")[event.target.dataset.numberrow]);
        }, 100);
    },

    closeDirectoryBox : function(component, event, helper){
        var element = event.getSource().get("v.labelClass");
        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
            // console.log(item);

        }
    },

    inlineEditInsightsAllocatedTarget : function (component, event, helper) {
        // var item = component.get("v.resultTableTarget");

        var element = event.target.id;
        console.log('>>>> ' + event.target.id);
        console.log('>>>> ' + event.currentTarget.id);
        console.log(component.find("focusIdInsights"));
        console.log(event.target.dataset.numberrow);

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);

        }

        setTimeout(function(){
            component.find("focusIdInsights")[event.target.dataset.numberrow].focus();
        }, 100);
    },

    closeInsightsBox : function(component, event, helper){
        var element = event.getSource().get("v.labelClass");
        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
        }


    },

    saveButton: function (component, event, helper) {
        component.set('v.loaded', !component.get('v.loaded'));

        var item = JSON.stringify(component.get("v.resultTableTarget"));

        var action = component.get("c.savePublicationTarget");
        action.setParams({jsonResultTable: item});
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