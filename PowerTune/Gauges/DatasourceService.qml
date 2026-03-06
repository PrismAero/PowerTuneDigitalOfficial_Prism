pragma Singleton
import QtQuick 2.15

QtObject {
    id: service

    readonly property ListModel allSources: DatasourcesList {}

    property string searchText: ""
    property string ecuFilter: ""
    readonly property ListModel filteredSources: ListModel {}

    readonly property var _keys: [
        "titlename", "sourcename", "supportedECUs",
        "decimalpoints", "decimalpoints2", "maxvalue",
        "defaultsymbol", "stepsize", "divisor", "supportedECU"
    ]

    onSearchTextChanged: filter()
    onEcuFilterChanged: filter()

    function _safeItem(src) {
        var obj = {};
        for (var k = 0; k < _keys.length; k++) {
            var key = _keys[k];
            var val = src[key];
            obj[key] = (val !== undefined) ? val : "";
        }
        return obj;
    }

    function filter() {
        filteredSources.clear();
        var lowerSearch = searchText.toLowerCase();
        for (var i = 0; i < allSources.count; i++) {
            var item = allSources.get(i);
            var matchesSearch = searchText === ""
                || item.titlename.toLowerCase().indexOf(lowerSearch) >= 0
                || item.sourcename.toLowerCase().indexOf(lowerSearch) >= 0;
            var matchesEcu = ecuFilter === ""
                || (item.supportedECUs !== undefined
                    && item.supportedECUs.indexOf(ecuFilter) >= 0);
            if (matchesSearch && matchesEcu)
                filteredSources.append(_safeItem(item));
        }
    }

    function getBySourceName(name) {
        for (var i = 0; i < allSources.count; i++) {
            if (allSources.get(i).sourcename === name)
                return allSources.get(i);
        }
        return null;
    }

    function getIndexBySourceName(name) {
        for (var i = 0; i < allSources.count; i++) {
            if (allSources.get(i).sourcename === name)
                return i;
        }
        return -1;
    }

    Component.onCompleted: filter()
}
