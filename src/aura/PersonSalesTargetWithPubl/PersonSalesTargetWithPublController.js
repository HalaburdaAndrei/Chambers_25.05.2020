({
    doInit: function (component, event, helper) {
        let currYear = new Date().getFullYear();
        let nextYear = currYear + 1;
        var yearList = [
            { 'label': `${(currYear - 1).toString()} - ${nextYear.toString()}`, 'value': (currYear - 1).toString() },
            { 'label': `${currYear.toString()} - ${nextYear.toString()}`, 'value': currYear.toString() },
            { 'label': `${nextYear.toString()} - ${(nextYear + 1).toString()}`, 'value': nextYear.toString() }];

        console.log('start');
        console.log(yearList);
        component.set( "v.options", yearList);
        component.set( "v.selectedYear", currYear.toString());
        var action = component.get("c.generateDates");
        action.setParams({selectedYear : 2020});
        action.setCallback(this, function (response) {
            var status = response.getState();
            console.log(status);
            if(status === "SUCCESS"){
                console.log( JSON.parse(JSON.stringify(response.getReturnValue())));
                component.set("v.tableHead", JSON.parse(JSON.stringify(response.getReturnValue())));
            }
        });
        $A.enqueueAction(action);

        var action1 = component.get("c.generateDataTable");
        // action1.setParams({selectedYear : 2020});
        action1.setCallback(this, function (response) {
            var status = response.getState();
            console.log(status);
            if(status === "SUCCESS"){
                console.log( JSON.parse(JSON.stringify(response.getReturnValue())));
                console.log( response.getReturnValue()['User 1']);
                // component.set("v.tableBody", response.getReturnValue());
                var result = response.getReturnValue();
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                component.set("v.tableBody", arrayMapKeys);
            }
        });
        $A.enqueueAction(action1);
        },

    handleChange: function (component, event) {
        // This will contain the string of the "value" attribute of the selected option
        var selectedOptionValue = event.getParam("value");
        console.log(selectedOptionValue)
        // component.set("v.selectedYear", selectedOptionValue);
        // alert("Option selected with value: '" + selectedOptionValue + "'");
    },


    })