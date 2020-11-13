({
    doInit: function (component, event, helper) {

        var getPicklistCategory = component.get("c.getPicklistProductCategory");
        getPicklistCategory.setCallback(this, function (response) {
           var state = response.getReturnValue();
           console.log(state);
           if(state === 'SUCCESS'){
               console.log(response.getReturnValue());
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
            }
        });
        $A.enqueueAction(getresultTable);

    },

    toggle: function (component, event, helper) {

        var items = component.get("v.resultTableTarget"), index = event.currentTarget.name;
        items[index].expanded = !items[index].expanded;
        component.set("v.resultTableTarget", items);

    },

    addPublication : function(component,event, helper){
      var selectedPublication = component.get("v.selectedLookUpRecords");
      var addPub = component.get("c.addPublicationApex");
      addPub.setParams({listNewPublications : selectedPublication});
      addPub.setCallback(this, function (response) {
         var state = response.getState();
         console.log(state);
         if(state === 'SUCCESS'){
             var items = component.get("v.resultTableTarget");
             items.push(response.getReturnValue()[0]);
             console.log(response.getReturnValue()[0]);
             component.set("v.resultTableTarget", items);
         }
      });
      $A.enqueueAction(addPub);
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
                    console.log(component.find("checkboxPublication")[i]);
                    console.log(component.find("checkboxPublication")[i].set("v.checked", true));
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find("checkboxPublication")[i].set("v.checked", false);
                }
            }
        }
    },

    inlineEditDirectoryAllocatedTarget : function (component, event, helper) {
        // var item = component.get("v.resultTableTarget");

        var element = event.target.id;

        console.log(event.target.dataset.numberrow);

        var x = document.querySelectorAll('div[id="'+element+'"]');
        // console.log(x);
        if (x[0].style.display === "none") {
            x[0].style.display = "block";
        } else {
            x[0].style.display = "none";
            // console.log(item);

        }

        setTimeout(function(){
            component.find("focusIdDirectory")[event.target.dataset.numberrow].focus();
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
            // console.log(item);

        }
    },

    })