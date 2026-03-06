pragma Singleton
import QtQuick 2.15

QtObject {
    id: factory

    readonly property var typeRegistry: ({
        "Round gauge":      "qrc:/qt/qml/PowerTune/Gauges/RoundGauge.qml",
        "Square gauge":     "qrc:/qt/qml/PowerTune/Gauges/SquareGauge.qml",
        "Bar gauge":        "qrc:/qt/qml/PowerTune/Gauges/VerticalBarGauge.qml",
        "Text label gauge": "qrc:/qt/qml/PowerTune/Gauges/MyTextLabel.qml",
        "gauge image":      "qrc:/qt/qml/PowerTune/Gauges/Picture.qml",
        "State gauge":      "qrc:/qt/qml/PowerTune/Gauges/StatePicture.qml",
        "State GIF":        "qrc:/qt/qml/PowerTune/Gauges/StateGIF.qml",
        "Main gauge":       "qrc:/qt/qml/PowerTune/Gauges/SquareGaugeMain.qml"
    })

    readonly property var _propertyKeys: ({
        "Round gauge": [
            "width", "x", "y", "mainvaluename", "maxvalue", "minvalue",
            "warnvaluehigh", "warnvaluelow", "startangle", "endangle",
            "redareastart", "divider", "tickmarksteps", "minortickmarksteps",
            "setlabelsteps", "decimalpoints", "needleinset", "setlabelinset",
            "setminortickmarkinset", "setmajortickmarkinset",
            "minortickmarkheight", "minortickmarkwidth", "tickmarkheight",
            "tickmarkwidth", "trailhighboarder", "trailmidboarder",
            "traillowboarder", "trailbottomboarder", "labelfontsize",
            "needleTipWidth", "needleLength", "needleBaseWidth",
            "redareainset", "redareawidth", "needlecolor", "needlecolor2",
            "backroundcolor", "warningcolor", "minortickmarkcoloractive",
            "minortickmarkcolorinactive", "majortickmarkcoloractive",
            "majortickmarkcolorinactive", "labelcoloractive",
            "labelcolorinactive", "outerneedlecolortrailsave",
            "middleneedlecortrailsave", "lowerneedlecolortrailsave",
            "innerneedlecolortrailsave", "needlevisible", "ringvisible",
            "needlecentervisisble", "labelfont", "desctextx", "desctexty",
            "desctextfontsize", "desctextfontbold", "desctextfonttype",
            "desctextdisplaytext", "desctextdisplaytextcolor",
            "peakneedlecolor", "peakneedlecolor2", "peakneedlelenght",
            "peakneedlebasewidth", "peakneedletipwidth", "peakneedleoffset",
            "peakneedlevisible"
        ],
        "Square gauge": [
            "width", "height", "x", "y", "maxvalue", "decimalpoints",
            "mainunit", "title", "vertgaugevisible", "horigaugevisible",
            "secvaluevisible", "mainvaluename", "secvaluename",
            "warnvaluehigh", "warnvaluelow", "framecolor",
            "resetbackroundcolor", "resettitlecolor", "titletextcolor",
            "textcolor", "barcolor", "titlefontsize", "mainfontsize",
            "decimalpoints2", "textFonttype", "valueFonttype"
        ],
        "Bar gauge": [
            "width", "height", "x", "y", "minvalue", "maxvalue",
            "decimalpoints", "gaugename", "mainvaluename",
            "warnvaluehigh", "warnvaluelow"
        ],
        "Text label gauge": [
            "x", "y", "displaytext", "fonttype", "fontsize", "textcolor",
            "datasourcename", "fontbold", "decimalpoints",
            "warnvaluehigh", "warnvaluelow"
        ],
        "gauge image": [
            "x", "y", "pictureheight", "picturesource"
        ],
        "State gauge": [
            "x", "y", "pictureheight", "mainvaluename", "triggervalue",
            "statepicturesourceoff", "statepicturesourceon"
        ],
        "State GIF": [
            "x", "y", "pictureheight", "mainvaluename", "triggervalue",
            "statepicturesourceoff", "statepicturesourceon", "triggeroffvalue"
        ]
    })

    property var _componentCache: ({})

    function _getComponent(typeName) {
        if (_componentCache[typeName])
            return _componentCache[typeName];
        var path = typeRegistry[typeName];
        if (!path) {
            console.warn("GaugeFactory: Unknown gauge type:", typeName);
            return null;
        }
        var comp = Qt.createComponent(path);
        if (comp.status === Component.Ready) {
            _componentCache[typeName] = comp;
            return comp;
        }
        if (comp.status === Component.Error) {
            console.error("GaugeFactory: Failed to load", path, comp.errorString());
            return null;
        }
        console.warn("GaugeFactory: Component not ready:", path, comp.status);
        return comp;
    }

    function createGauge(typeName, parent, properties) {
        var component = _getComponent(typeName);
        if (!component)
            return null;
        if (component.status === Component.Ready) {
            var gauge = component.createObject(parent, properties || {});
            if (!gauge)
                console.error("GaugeFactory: Error creating", typeName);
            return gauge;
        }
        console.warn("GaugeFactory: Async component load for", typeName, "not yet supported");
        return null;
    }

    function serializeGauge(gauge) {
        var typeName = gauge.information;
        var keys = _propertyKeys[typeName];
        if (!keys) {
            console.warn("GaugeFactory: Cannot serialize unknown type:", typeName);
            return null;
        }
        var data = { "info": typeName };
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            var val = gauge[key];
            if (val !== undefined)
                data[key] = val;
        }
        if (typeName === "Round gauge") {
            data["height"] = data["width"];
            data["outerneedlecolortrail"] = gauge.outerneedlecolortrailsave;
            data["middleneedlecortrail"] = gauge.middleneedlecortrailsave;
            data["lowerneedlecolortrail"] = gauge.lowerneedlecolortrailsave;
            data["innerneedlecolortrail"] = gauge.innerneedlecolortrailsave;
        }
        if (typeName === "Text label gauge") {
            data["resettextcolor"] = gauge.textcolor;
        }
        return data;
    }

    function deserializeGauge(data, parent) {
        var typeName = data.info;
        if (!typeName) {
            console.warn("GaugeFactory: Deserialization data missing 'info' field");
            return null;
        }
        var props = {};
        var keys = _propertyKeys[typeName];
        if (!keys) {
            console.warn("GaugeFactory: Unknown type in deserialization:", typeName);
            return null;
        }
        for (var i = 0; i < keys.length; i++) {
            var key = keys[i];
            if (data[key] !== undefined)
                props[key] = data[key];
        }
        if (typeName === "Round gauge")
            props["height"] = props["width"];
        if (typeName === "Square gauge") {
            var mainProp = data.valuepropertymain || data.mainvaluename;
            var secProp = data.valuepropertysec || data.secvaluename;
            props["mainvaluename"] = mainProp;
            props["secvaluename"] = secProp;
            if (data.id) {
                props["title"] = data.id;
            }
        }
        if (typeName === "Bar gauge") {
            var barProp = data.valuepropertymain || data.mainvaluename;
            props["mainvaluename"] = barProp;
            if (data.unit)
                props["gaugename"] = data.unit;
        }
        if (typeName === "Text label gauge") {
            props["resettextcolor"] = props["textcolor"];
        }
        return createGauge(typeName, parent, props);
    }

    function serializeGaugeForCSV(gauge) {
        var typeName = gauge.information;
        var parts = [typeName];
        switch (typeName) {
        case "Bar gauge":
            parts.push(gauge.width, gauge.height, gauge.x, gauge.y,
                       gauge.minvalue, gauge.maxvalue, gauge.decimalpoints,
                       gauge.gaugename, gauge.mainvaluename,
                       gauge.warnvaluehigh, gauge.warnvaluelow,
                       gauge.decimalpoints2);
            break;
        case "Square gauge":
            parts.push(gauge.width, gauge.height, gauge.x, gauge.y,
                       gauge.maxvalue, gauge.decimalpoints, gauge.mainunit,
                       gauge.title, gauge.vertgaugevisible,
                       gauge.horigaugevisible, gauge.secvaluevisible,
                       "Dashboard", gauge.mainvaluename, gauge.secvaluename,
                       gauge.warnvaluehigh, gauge.warnvaluelow,
                       gauge.framecolor, gauge.resetbackroundcolor,
                       gauge.resettitlecolor, gauge.titletextcolor,
                       gauge.textcolor, gauge.barcolor, gauge.titlefontsize,
                       gauge.mainfontsize, gauge.decimalpoints2,
                       gauge.textFonttype, gauge.valueFonttype);
            break;
        case "gauge image":
            parts.push(gauge.x, gauge.y, gauge.pictureheight,
                       gauge.picturesource);
            break;
        case "Text label gauge":
            parts.push(gauge.x, gauge.y, gauge.displaytext, gauge.fonttype,
                       gauge.fontsize, gauge.textcolor, gauge.datasourcename,
                       gauge.fontbold, gauge.decimalpoints,
                       gauge.warnvaluehigh, gauge.warnvaluelow);
            break;
        case "Round gauge":
            parts.push(gauge.width, gauge.x, gauge.y,
                       gauge.mainvaluename, gauge.maxvalue, gauge.minvalue,
                       gauge.warnvaluehigh, gauge.warnvaluelow,
                       gauge.startangle, gauge.endangle, gauge.redareastart,
                       gauge.divider, gauge.tickmarksteps,
                       gauge.minortickmarksteps, gauge.setlabelsteps,
                       gauge.decimalpoints, gauge.needleinset,
                       gauge.setlabelinset, gauge.setminortickmarkinset,
                       gauge.setmajortickmarkinset, gauge.minortickmarkheight,
                       gauge.minortickmarkwidth, gauge.tickmarkheight,
                       gauge.tickmarkwidth, gauge.trailhighboarder,
                       gauge.trailmidboarder, gauge.traillowboarder,
                       gauge.trailbottomboarder, gauge.labelfontsize,
                       gauge.needleTipWidth, gauge.needleLength,
                       gauge.needleBaseWidth, gauge.redareainset,
                       gauge.redareawidth, gauge.needlecolor,
                       gauge.needlecolor2, gauge.backroundcolor,
                       gauge.warningcolor, gauge.minortickmarkcoloractive,
                       gauge.minortickmarkcolorinactive,
                       gauge.majortickmarkcoloractive,
                       gauge.majortickmarkcolorinactive,
                       gauge.labelcoloractive, gauge.labelcolorinactive,
                       gauge.outerneedlecolortrailsave,
                       gauge.middleneedlecortrailsave,
                       gauge.lowerneedlecolortrailsave,
                       gauge.innerneedlecolortrailsave,
                       gauge.needlevisible, gauge.ringvisible,
                       gauge.needlecentervisisble, gauge.labelfont,
                       gauge.desctextx, gauge.desctexty,
                       gauge.desctextfontsize, gauge.desctextfontbold,
                       gauge.desctextfonttype, gauge.desctextdisplaytext,
                       gauge.desctextdisplaytextcolor,
                       gauge.peakneedlecolor, gauge.peakneedlecolor2,
                       gauge.peakneedlelenght, gauge.peakneedlebasewidth,
                       gauge.peakneedletipwidth, gauge.peakneedleoffset,
                       gauge.peakneedlevisible);
            break;
        case "State gauge":
            parts.push(gauge.x, gauge.y, gauge.pictureheight,
                       gauge.mainvaluename, gauge.triggervalue,
                       gauge.statepicturesourceoff,
                       gauge.statepicturesourceon);
            break;
        case "State GIF":
            parts.push(gauge.x, gauge.y, gauge.pictureheight,
                       gauge.mainvaluename, gauge.triggervalue,
                       gauge.statepicturesourceoff,
                       gauge.statepicturesourceon, gauge.triggeroffvalue);
            break;
        }
        return parts.join(",");
    }

    function deserializeCSVLine(csvLine, parent) {
        var parts = csvLine.split(",");
        var typeName = parts[0];
        if (!typeRegistry[typeName])
            return null;
        var props = {};
        switch (typeName) {
        case "Bar gauge":
            props = {
                "width": parts[1], "height": parts[2], "x": parts[3], "y": parts[4],
                "minvalue": parts[5], "maxvalue": parts[6], "decimalpoints": parts[7],
                "gaugename": parts[8], "mainvaluename": parts[9],
                "warnvaluehigh": parts[10], "warnvaluelow": parts[11]
            };
            break;
        case "Round gauge":
            props = {
                "width": parts[1], "height": parts[1], "x": parts[2], "y": parts[3],
                "mainvaluename": parts[4], "maxvalue": parts[5], "minvalue": parts[6],
                "warnvaluehigh": parts[7], "warnvaluelow": parts[8],
                "startangle": parts[9], "endangle": parts[10],
                "redareastart": parts[11], "divider": parts[12],
                "tickmarksteps": parts[13], "minortickmarksteps": parts[14],
                "setlabelsteps": parts[15], "decimalpoints": parts[16],
                "needleinset": parts[17], "setlabelinset": parts[18],
                "setminortickmarkinset": parts[19], "setmajortickmarkinset": parts[20],
                "minortickmarkheight": parts[21], "minortickmarkwidth": parts[22],
                "tickmarkheight": parts[23], "tickmarkwidth": parts[24],
                "trailhighboarder": parts[25], "trailmidboarder": parts[26],
                "traillowboarder": parts[27], "trailbottomboarder": parts[28],
                "labelfontsize": parts[29], "needleTipWidth": parts[30],
                "needleLength": parts[31], "needleBaseWidth": parts[32],
                "redareainset": parts[33], "redareawidth": parts[34],
                "needlecolor": parts[35], "needlecolor2": parts[36],
                "backroundcolor": parts[37], "warningcolor": parts[38],
                "minortickmarkcoloractive": parts[39],
                "minortickmarkcolorinactive": parts[40],
                "majortickmarkcoloractive": parts[41],
                "majortickmarkcolorinactive": parts[42],
                "labelcoloractive": parts[43], "labelcolorinactive": parts[44],
                "outerneedlecolortrailsave": parts[45],
                "middleneedlecortrailsave": parts[46],
                "lowerneedlecolortrailsave": parts[47],
                "innerneedlecolortrailsave": parts[48],
                "outerneedlecolortrail": parts[45],
                "middleneedlecortrail": parts[46],
                "lowerneedlecolortrail": parts[47],
                "innerneedlecolortrail": parts[48],
                "needlevisible": (parts[49] && parts[49].toLowerCase() === 'true'),
                "ringvisible": (parts[50] && parts[50].toLowerCase() === 'true'),
                "needlecentervisisble": (parts[51] && parts[51].toLowerCase() === 'true'),
                "labelfont": parts[52], "desctextx": parts[53], "desctexty": parts[54],
                "desctextfontsize": parts[55],
                "desctextfontbold": (parts[56] && parts[56].toLowerCase() === 'true'),
                "desctextfonttype": parts[57], "desctextdisplaytext": parts[58],
                "desctextdisplaytextcolor": parts[59],
                "peakneedlecolor": parts[60], "peakneedlecolor2": parts[61],
                "peakneedlelenght": parts[62], "peakneedlebasewidth": parts[63],
                "peakneedletipwidth": parts[64], "peakneedleoffset": parts[65],
                "peakneedlevisible": (parts[66] && parts[66].toLowerCase() === 'true')
            };
            break;
        case "Square gauge":
            props = {
                "width": parts[1], "height": parts[2], "x": parts[3], "y": parts[4],
                "maxvalue": parts[5], "decimalpoints": parts[6], "mainunit": parts[7],
                "title": parts[8],
                "vertgaugevisible": (parts[9] && parts[9].toLowerCase() === 'true'),
                "horigaugevisible": (parts[10] && parts[10].toLowerCase() === 'true'),
                "secvaluevisible": (parts[11] && parts[11].toLowerCase() === 'true'),
                "mainvaluename": parts[13], "secvaluename": parts[14],
                "warnvaluehigh": parts[15], "warnvaluelow": parts[16],
                "framecolor": parts[17], "resetbackroundcolor": parts[18],
                "resettitlecolor": parts[19], "titletextcolor": parts[20],
                "textcolor": parts[21], "barcolor": parts[22],
                "titlefontsize": parts[23], "mainfontsize": parts[24],
                "decimalpoints2": parts[25], "textFonttype": parts[26],
                "valueFonttype": parts[27]
            };
            break;
        case "gauge image":
            props = {
                "x": parts[1], "y": parts[2],
                "pictureheight": parts[3], "picturesource": parts[4]
            };
            break;
        case "Text label gauge":
            props = {
                "x": parts[1], "y": parts[2], "displaytext": parts[3],
                "fonttype": parts[4], "fontsize": parts[5], "textcolor": parts[6],
                "resettextcolor": parts[6], "datasourcename": parts[7],
                "fontbold": (parts[8] && parts[8].toLowerCase() === 'true'),
                "decimalpoints": parts[9], "warnvaluehigh": parts[10],
                "warnvaluelow": parts[11]
            };
            break;
        case "State gauge":
            props = {
                "x": parts[1], "y": parts[2], "pictureheight": parts[3],
                "mainvaluename": parts[4], "triggervalue": parts[5],
                "statepicturesourceoff": parts[6], "statepicturesourceon": parts[7]
            };
            break;
        case "State GIF":
            props = {
                "x": parts[1], "y": parts[2], "pictureheight": parts[3],
                "mainvaluename": parts[4], "triggervalue": parts[5],
                "statepicturesourceoff": parts[6], "statepicturesourceon": parts[7],
                "triggeroffvalue": parts[8]
            };
            break;
        }
        return createGauge(typeName, parent, props);
    }
}
