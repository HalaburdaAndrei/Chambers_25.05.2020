({
    sortBy: function (component, event, field) {
        var sortAsc = component.get("v.sortAsc"),
            records = component.get("v.items1");

        // sortAsc = sortField != field || !sortAsc;
        //
        // records[index].rankings.sort(function (a, b) {
        //     var t1 = a[field] == b[field],
        //         t2 = (!a[field] && b[field]) || (a[field] < b[field]);
        //     return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
        // });

        let keyValue = (a) => {
            return a[field];
        };
        records.sort((x, y) => {
                x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        if (sortAsc) {
            return ((x > y) - (y > x));
                    } else {
                        return ((x > y) - (y > x)) * -1;
                    }
        });

        component.set("v.sortAsc", !sortAsc);
        component.set("v.sortField", field);
        component.set("v.items1", records);
    },

    getData: function (component, event) {
        var items = component.get("v.items"), index = component.get("v.selectIndex");
        component.set('v.loaded', !component.get('v.loaded'));

        console.log(component.get("v.selTabId"));
        var action = component.get('c.getRankingsSearch');
    action.setParams({
        recordType: component.get("v.selTabId"),
        recordId: component.get("v.recordId"),
        pubType: items[index].publication,
        listYear: items[index].listYear,
        filterPracticeArea: component.get("v.filterPracticeArea"),
        filterPerson: component.get("v.filterPerson"),
        filterLocationOfExpertise: component.get("v.filterLocationOfExpertise"),
        filterLocation: component.get("v.filterLocation"),
        filterBranch: component.get("v.filterBranch"),
        filterType: component.get("v.filterType")
    });
    action.setCallback(this, function (response) {
        if (component.isValid() && response.getState() == 'SUCCESS') {
            component.set('v.items1', response.getReturnValue().table);
            console.log(response.getReturnValue().table);
            console.log(component.get('v.items1'));
        }
        else {
            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                'title': 'Error!',
                'type': 'error',
                'message': response.getReturnValue().message
            });
            toastEvent.fire();
        }
        component.set('v.loaded', !component.get('v.loaded'));
    });
    // $A.enqueueAction(action);
        $A.getCallback(function() {
            $A.enqueueAction(action);
        })();
    }

})