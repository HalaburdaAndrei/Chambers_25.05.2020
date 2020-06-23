({
    sortBy: function (component, event, field) {
        var sortAsc = component.get("v.sortAsc"),
            sortField = component.get("v.sortField"),
            records = component.get("v.items");
        var index = component.get("v.sortindex");
        console.log(event.target.dataset.index);
        sortAsc = sortField != field || !sortAsc;
        // records.sort(function (a, b) {
        //     var t1 = a[field] == b[field],
        //         t2 = (!a[field] && b[field]) || (a[field] < b[field]);
        //     return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
        // });

        records[index].rankings.sort(function (a, b) {
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);
        });
        component.set("v.sortAsc", sortAsc);
        component.set("v.sortField", field);
        component.set("v.items", records);
    },
})