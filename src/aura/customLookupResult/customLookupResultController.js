
({
    selectRecord : function (component,event,helper) {
        var getSelectedRecord = component.get("v.oRecord");
        console.log('customLookUpResult >>> ' + getSelectedRecord);

        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({"recordByEvent": getSelectedRecord});
        compEvent.fire();
    },
})