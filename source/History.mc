using Toybox.Application.Storage;
using Toybox.Lang;
using Toybox.Time;

class History {
    static const MAX_ENTRIES = 90;
    static const DAY_SECONDS = 86400;

    static function entries() {
        var stored = Storage.getValue(StorageKeys.HISTORY);
        if (stored == null) {
            return [];
        }
        return stored as Lang.Array;
    }

    static function record(practicedSeconds) {
        var list = entries();
        list.add({ "day" => Time.today().value(), "secs" => practicedSeconds });
        while (list.size() > MAX_ENTRIES) {
            list = list.slice(1, null);
        }
        Storage.setValue(StorageKeys.HISTORY, list);
    }

    static function streak() {
        var list = entries();
        if (list.size() == 0) {
            return 0;
        }

        var days = {};
        for (var i = 0; i < list.size(); i += 1) {
            var entry = list[i] as Lang.Dictionary;
            days[entry["day"]] = true;
        }

        var today = Time.today().value();
        var anchor;
        if (days.hasKey(today)) {
            anchor = today;
        } else if (days.hasKey(today - DAY_SECONDS)) {
            anchor = today - DAY_SECONDS;
        } else {
            return 0;
        }

        var count = 0;
        while (days.hasKey(anchor - (count * DAY_SECONDS))) {
            count += 1;
        }
        return count;
    }

    static function streakText() {
        var s = streak();
        if (s <= 0) {
            return "Begin your streak";
        }
        if (s == 1) {
            return "1-day streak";
        }
        return s + "-day streak";
    }
}
