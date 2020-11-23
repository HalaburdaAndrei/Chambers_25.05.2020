({
    doInit: function (component, event, helper) {

        helper.picklistProductcategory(component, event, helper);
        helper.picklistPublicationCategory(component, event, helper);
        helper.getResultPublicationTarget(component, event, helper);

    },

    toggle: function (component, event, helper) {

        var items = component.get("v.resultTableTarget"), index = event.currentTarget.name;
        items[index].expanded = !items[index].expanded;

        let keyValue = (a) => {
            return a["productCategoryName"];
        };

        items[index].productCategaryRows.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            return ((x > y) - (y > x));

        });
        component.set("v.resultTableTarget", items);

    },

    addPublication : function(component,event, helper){

        const selectedOptions = component.find("jobLocationMS").get("v.selectedOptions");
        console.log(selectedOptions);
        var listcategory = [];
        for(var i = 0; i < selectedOptions.length; i++){
            listcategory.push(selectedOptions[i].Id);
        }
        console.log(listcategory);
        console.log(JSON.stringify(component.get("v.resultTableTarget")));

      var selectedPublicationCategory = component.get("v.selectedPublicationCategory");
      if(selectedPublicationCategory != null) {
          component.set('v.loaded', !component.get('v.loaded'));

          var selectedYear = component.get("v.selectedYear");
          var oldResultTable = JSON.stringify(component.get("v.resultTableTarget"));
          var selProdcategory = component.get("v.selectedProdCategory");
          var addPub = component.get("c.addPublicationApex");
          // addPub.setParams({listNewPublications : selectedPublication,
          //                   jsonResultTable : oldResultTable,
          //                   selectedProductCategory : listcategory});
          addPub.setParams({
              publicationCategory: selectedPublicationCategory,
              year: selectedYear,
              jsonOldResult: oldResultTable
          });
          addPub.setCallback(this, function (response) {
              var state = response.getState();
              console.log(state);
              if (state === 'SUCCESS') {
                  var result = response.getReturnValue();
                  var items = component.get("v.resultTableTarget");

                  let keyValue = (a) => {
                      return a["publicationName"];
                  };

                  result.sort((x, y) => {
                      x = keyValue(x) ? keyValue(x) : '';
                      y = keyValue(y) ? keyValue(y) : '';
                      return ((x > y) - (y > x));
                  });

                  component.set("v.resultTableTarget", result);
                  component.set("v.selectedLookUpRecords", []);
                  helper.calculatePublicationTarget(component, event, helper);

                  component.set('v.loaded', !component.get('v.loaded'));
                  var toastEvent = $A.get("e.force:showToast");
                  toastEvent.setParams({
                      "title": "Success!",
                      "type": "success",
                      "message": "Publications has been added successfully."
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
          $A.enqueueAction(addPub);
      }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": "Select a Publication Category"
            });
            toastEvent.fire();
        }
    },

    addProductCategoryButton : function(component,helper,event){

        const selectedOptions = component.find("jobLocationMS").get("v.selectedOptions");
        console.log(selectedOptions);
        var listcategory = [];
        for(var i = 0; i < selectedOptions.length; i++){
            listcategory.push(selectedOptions[i].Id);
        }

        console.log(listcategory);
        console.log(component.get("v.listPublicationForProdCategory"));

        if(component.get("v.listPublicationForProdCategory").length > 0) {
            component.set('v.loaded', !component.get('v.loaded'));
            var addProdCat = component.get("c.addProductcategoryApex");
            addProdCat.setParams({
                publicationForAddProdCategory: JSON.stringify(component.get("v.listPublicationForProdCategory")),
                selectedProductCategory: listcategory
            });
            addProdCat.setCallback(this, function (response) {
                var state = response.getState();
                console.log(state);
                console.log(response.getError());
                if (state === 'SUCCESS') {
                    console.log(response.getReturnValue());
                    var result = response.getReturnValue();
                    var items = component.get("v.resultTableTarget");

                    for (var i = 0; i < items.length; i++) {
                        for (var p = 0; p < result.length; p++) {
                            if (items[i].publicationName === result[p].publicationName) {
                                items[i] = result[p];
                                let keyValue = (a) => {
                                    return a["productCategoryName"];
                                };

                                items[i].productCategaryRows.sort((x, y) => {
                                    x = keyValue(x) ? keyValue(x) : '';
                                    y = keyValue(y) ? keyValue(y) : '';
                                    return ((x > y) - (y > x));
                                });
                            }
                        }
                    }
                    component.find("jobLocationMS").set("v.selectedOptions", []);
                    component.find("jobLocationMS").set("v.selectedLabel", "Select a value..");
                    component.find("jobLocationMS").set("v.msoptions", component.get("v.optionsProductCategory"));
                    console.log('11111>>> ' + component.find("jobLocationMS").get("v.selectedOptions"));
                    component.set("v.listPublicationForProdCategory", []);
                    component.set("v.resultTableTarget", items);
                    component.set('v.loaded', !component.get('v.loaded'));

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Product category has been added successfully."
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
            $A.enqueueAction(addProdCat);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": "Select a Product Category and Publication"
            });
            toastEvent.fire();
        }
    },

    delPublication : function(component, event, helper){

        var items = JSON.stringify(component.get("v.resultTableTarget"));

        var delPublic = [];
        var delProdCateg = [];

        var getAllId = component.find("checkboxPublication");
        if (!Array.isArray(getAllId)) {
            if (getAllId.get("v.checked") == true) {
                delPublic.push(getAllId);
            }
        } else {
            for (var i = 0; i < getAllId.length; i++) {
                if (getAllId[i].get("v.checked") == true) {
                    delPublic.push(getAllId[i]);
                }
            }
        }

        var getAllPubId = component.find("checkboxProductCategary");
        if (getAllPubId != null) {
            if (!Array.isArray(getAllPubId)) {
                if (getAllPubId.get("v.checked") == true) {
                    delProdCateg.push(getAllPubId);
                }
            } else {
                for (var i = 0; i < getAllPubId.length; i++) {
                    if (getAllPubId[i].get("v.checked") == true) {
                        delProdCateg.push(getAllPubId[i]);
                    }
                }
            }
        }
        if (delPublic.length > 0 || delProdCateg.length > 0 ) {
            component.set('v.loaded', !component.get('v.loaded'));

      var delPub = component.get("c.deletePublication");
      delPub.setParams({jsonResultTable : items});
      delPub.setCallback(this, function (response) {
         var state = response.getState();
         console.log(state);
         if(state === 'SUCCESS'){
             console.log('delete');
             $A.get('e.force:refreshView').fire();
             helper.calculatePublicationTarget(component,event,helper);
             component.set('v.loaded', !component.get('v.loaded'));
             var toastEvent = $A.get("e.force:showToast");
             toastEvent.setParams({
                 "title": "Success!",
                 "type": "success",
                 "message": "Data has been deleted successfully."
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
      $A.enqueueAction(delPub);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type": "warning",
                "message": 'To delete a Product Category, select Publication or Product Category.'
            });
            toastEvent.fire();
        }
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

        var item = component.get("v.resultTableTarget");
        var listPubForProd = [];
        var checkProdCategoryDelete = [];
        if(selectedHeaderCheck == true) {
            for (var i = 0; i < item.length; i++) {
                for(var k = 0; k < item[i].productCategaryRows.length; k++) {
                item[i].productCategaryRows[k].publicationTargets[0].Category_Visible__c = false;
                    checkProdCategoryDelete.push(item[i].productCategaryRows[k]);
                }
                listPubForProd.push(item[i]);
            }
        }else{
            for (var i = 0; i < item.length; i++) {
                for(var k = 0; k < item[i].productCategaryRows.length; k++) {
                item[i].productCategaryRows[k].publicationTargets[0].Category_Visible__c = true;
                }
            }
            listPubForProd = [];
            checkProdCategoryDelete = [];
        }
        component.set("v.listPublicationForProdCategory", listPubForProd);
        component.set("v.checkProdCategoryForDelete", checkProdCategoryDelete);
        console.log(item);
        console.log(listPubForProd);
        console.log(checkProdCategoryDelete);
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
        var listPubForProd = component.get("v.listPublicationForProdCategory");

        if(selectedRec == true) {
            for (var i = 0; i < item[event.getSource().get("v.id")].productCategaryRows.length; i++) {
                // for(var k = 0; k < item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets.length; k++) {
                    item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets[0].Category_Visible__c = false;
                // }
            }
            listPubForProd.push(item[event.getSource().get("v.id")]);

        }else{
            for (var i = 0; i < item[event.getSource().get("v.id")].productCategaryRows.length; i++) {
                // for(var k = 0; k < item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets.length; k++) {
                    item[event.getSource().get("v.id")].productCategaryRows[i].publicationTargets[0].Category_Visible__c = true;
                // }
            }
            for( var i = 0; i < listPubForProd.length; i++){
                if ( listPubForProd[i].publicationName === item[event.getSource().get("v.id")].publicationName) {
                    listPubForProd.splice(i, 1);
                    i--;
                }
            }
        }

        console.log(listPubForProd);
    },

    selectProductcategoryCheckBox : function(component, event, helper){
        var selectedRec = event.getSource().get("v.checked");
        console.log(selectedRec);
        var item = component.get("v.resultTableTarget");
        var checkProdCategoryDelete = [];

        if(selectedRec == true) {
                    item[event.getSource().get("v.name")].productCategaryRows[event.getSource().get("v.id")].publicationTargets[0].Category_Visible__c = false;
            checkProdCategoryDelete.push(item[event.getSource().get("v.name")].productCategaryRows[event.getSource().get("v.id")])
        }else{
                    item[event.getSource().get("v.name")].productCategaryRows[event.getSource().get("v.id")].publicationTargets[0].Category_Visible__c = true;
        }

        console.log(checkProdCategoryDelete);
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

        console.log(event.getSource().get("v.placeholder"));

        var element = event.getSource().get("v.labelClass");
        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
            var item = component.get("v.resultTableTarget");
            var getAllIdCategory = component.find("focusIdDirectory");
            if(getAllIdCategory != null) {
                item[event.getSource().get("v.placeholder")].publicationDirectoryAllocatedTarget = 0;
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        if(event.getSource().get("v.placeholder") === component.find("focusIdDirectory")[i].get("v.placeholder")) {
                            item[event.getSource().get("v.placeholder")].publicationDirectoryAllocatedTarget += component.find("focusIdDirectory")[i].get("v.value");
                        }
                    }
            }
            component.set("v.resultTableTarget", item);

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
            var getAllIdCategory = component.find("focusIdInsights");
            console.log(getAllIdCategory);
            if (Array.isArray(getAllIdCategory)) {
                for (var i = 0; i < getAllIdCategory.length; i++) {

                    if (event.target.dataset.id === component.find("focusIdInsights")[i].get("v.labelClass")) {

                        component.find("focusIdInsights")[event.target.dataset.numberrow].focus();
                    }
                }
            }else {
                component.find("focusIdInsights").focus();
            }
        }, 100);
    },

    closeInsightsBox : function(component, event, helper){
        console.log(event.getSource().get("v.placeholder"));
        var element = event.getSource().get("v.labelClass");
        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            component.set("v.showSaveCancelBtn", true);
            var item = component.get("v.resultTableTarget");
            var getAllIdCategory = component.find("focusIdInsights");
            if(getAllIdCategory != null) {
                item[event.getSource().get("v.placeholder")].publicationInsightsAllocatedTarget = 0;
                if (!Array.isArray(getAllIdCategory)) {
                    if (event.getSource().get("v.placeholder") === component.find("focusIdInsights").get("v.placeholder")) {
                        item[event.getSource().get("v.placeholder")].publicationInsightsAllocatedTarget = component.find("focusIdInsights").get("v.value");
                    }
                }else {
                    for (var i = 0; i < getAllIdCategory.length; i++) {
                        if (event.getSource().get("v.placeholder") === component.find("focusIdInsights")[i].get("v.placeholder")) {
                            item[event.getSource().get("v.placeholder")].publicationInsightsAllocatedTarget = component.find("focusIdInsights")[i].get("v.value");
                        }
                    }
                }
            }
            component.set("v.resultTableTarget", item);
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

    },

    selectedYearOption: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue);
        component.set("v.selectedYear", selectedOptionValue);
    },

    selectedPublicationCategoryOption: function (component, event, helper) {
        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue);
        component.set("v.selectedPublicationCategory", selectedOptionValue);
    },


})