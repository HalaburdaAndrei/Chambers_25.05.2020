/**
 * Created by andrei on 09.06.20.
 */
({
    selectRecord : function (component,event,helper) {
        var getSelectedRecord = component.get("v.oRecord");

        var compEvent = component.getEvent("oSelectedRecordEvent");
        compEvent.setParams({"recordByEvent": getSelectedRecord});
        compEvent.fire();
    },
})