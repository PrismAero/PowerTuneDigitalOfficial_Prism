pragma Singleton
import QtQuick 2.15

Item {
    id: service
    visible: false
    width: 0
    height: 0

    DatasourcesList { id: _rawSources }
    ListModel { id: _allSources }
    ListModel { id: _filteredSources }

    readonly property alias allSources: _allSources
    readonly property alias filteredSources: _filteredSources

    property string searchText: ""
    property string ecuFilter: ""

    readonly property var _keys: [
        "titlename", "sourcename", "supportedECUs",
        "decimalpoints", "decimalpoints2", "maxvalue",
        "defaultsymbol", "stepsize", "divisor", "supportedECU"
    ]

    onSearchTextChanged: filter()
    onEcuFilterChanged: filter()

    function _defaultFor(key) {
        switch (key) {
        case "decimalpoints":
        case "decimalpoints2":
        case "maxvalue":
        case "stepsize":
        case "divisor":
            return 0;
        default:
            return "";
        }
    }

    function _safeItem(src) {
        var obj = {};
        for (var k = 0; k < _keys.length; k++) {
            var key = _keys[k];
            var val = src[key];
            obj[key] = (val !== undefined && val !== null) ? val : _defaultFor(key);
        }
        return obj;
    }

    function normalizeSources() {
        _allSources.clear();
        for (var i = 0; i < _rawSources.count; i++)
            _allSources.append(_safeItem(_rawSources.get(i)));
    }

    function filter() {
        _filteredSources.clear();
        var lowerSearch = searchText.toLowerCase();
        for (var i = 0; i < _allSources.count; i++) {
            var item = _allSources.get(i);
            var matchesSearch = searchText === ""
                || item.titlename.toLowerCase().indexOf(lowerSearch) >= 0
                || item.sourcename.toLowerCase().indexOf(lowerSearch) >= 0;
            var matchesEcu = ecuFilter === ""
                || (item.supportedECUs !== undefined
                    && item.supportedECUs.indexOf(ecuFilter) >= 0);
            if (matchesSearch && matchesEcu)
                _filteredSources.append(_safeItem(item));
        }
    }

    function getBySourceName(name) {
        for (var i = 0; i < _allSources.count; i++) {
            if (_allSources.get(i).sourcename === name)
                return _allSources.get(i);
        }
        return null;
    }

    function getIndexBySourceName(name) {
        for (var i = 0; i < _allSources.count; i++) {
            if (_allSources.get(i).sourcename === name)
                return i;
        }
        return -1;
    }

    Component.onCompleted: {
        normalizeSources();
        filter();
    }
}
