using Toybox.WatchUi;
using Toybox.Graphics;

class NumberPickerView extends WatchUi.View {
    var params;
    var field;
    var spec;
    var value;

    function initialize(activityParams, fieldName) {
        View.initialize();
        params = activityParams;
        field = fieldName;
        spec = SessionMath.fieldSpec(fieldName);
        value = params[fieldName];
    }

    function change(delta) {
        var next = value + (delta * spec["step"]);
        if (next < spec["min"]) {
            next = spec["min"];
        }
        if (next > spec["max"]) {
            next = spec["max"];
        }
        value = next;
        WatchUi.requestUpdate();
    }

    function commit() {
        params[field] = value;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(UiConstants.FG, UiConstants.BG);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.16, Graphics.FONT_SMALL, spec["label"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var text;
        if (spec["time"]) {
            text = SessionMath.formatDuration(value);
        } else {
            text = value.toString();
        }
        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.48, Graphics.FONT_NUMBER_MEDIUM, text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (!spec["unit"].equals("")) {
            dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 0.65, Graphics.FONT_TINY, spec["unit"],
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.78, Graphics.FONT_XTINY, "UP/DOWN  START saves",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class NumberPickerDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(pickerView) {
        BehaviorDelegate.initialize();
        view = pickerView;
    }

    function onPreviousPage() {
        view.change(1);
        return true;
    }

    function onNextPage() {
        view.change(-1);
        return true;
    }

    function onSelect() {
        view.commit();
        return true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
