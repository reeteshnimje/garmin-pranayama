class SessionMath {
    static function defaultParams(type) {
        if (type == ActivityTypes.ANULOM_VILOM) {
            return {
                "inhale" => 4,
                "pause" => 0,
                "reps" => 5
            };
        } else if (type == ActivityTypes.BHRAMARI || type == ActivityTypes.BHASTRIKA) {
            return {
                "inhale" => 4,
                "reps" => 7
            };
        } else if (type == ActivityTypes.KAPALBHATI) {
            return {
                "totalTime" => 60
            };
        }
        return {
            "duration" => 300
        };
    }

    static function fieldsForType(type) {
        if (type == ActivityTypes.ANULOM_VILOM) {
            return [ "inhale", "pause", "reps" ];
        } else if (type == ActivityTypes.BHRAMARI || type == ActivityTypes.BHASTRIKA) {
            return [ "inhale", "reps" ];
        } else if (type == ActivityTypes.KAPALBHATI) {
            return [ "totalTime" ];
        }
        return [ "duration" ];
    }

    static function fieldSpec(field) {
        if (field.equals("inhale")) {
            return { "label" => "Inhale", "unit" => "seconds", "min" => 1, "max" => 20, "step" => 1, "time" => false };
        } else if (field.equals("pause")) {
            return { "label" => "Pause", "unit" => "seconds", "min" => 0, "max" => 30, "step" => 1, "time" => false };
        } else if (field.equals("reps")) {
            return { "label" => "Repetitions", "unit" => "reps", "min" => 1, "max" => 50, "step" => 1, "time" => false };
        } else if (field.equals("totalTime")) {
            return { "label" => "Duration", "unit" => "", "min" => 10, "max" => 600, "step" => 10, "time" => true };
        }
        return { "label" => "Duration", "unit" => "", "min" => 60, "max" => 3600, "step" => 30, "time" => true };
    }

    static function durationForActivity(activity) {
        var type = activity["type"];
        var params = activity["params"];

        if (type == ActivityTypes.ANULOM_VILOM) {
            var inhale = clampMin(params["inhale"], 1);
            var pause = clampMin(params["pause"], 0);
            var reps = clampMin(params["reps"], 1);
            var hold = inhale * 4;
            var exhale = inhale * 2;
            return reps * 2 * (inhale + hold + exhale + pause);
        } else if (type == ActivityTypes.BHRAMARI || type == ActivityTypes.BHASTRIKA) {
            var inhale2 = clampMin(params["inhale"], 1);
            var reps2 = clampMin(params["reps"], 1);
            return reps2 * (inhale2 + (inhale2 * 2));
        } else if (type == ActivityTypes.KAPALBHATI) {
            return clampMin(params["totalTime"], 1);
        }

        return clampMin(params["duration"], 1);
    }

    static function durationForSession(session) {
        var total = 0;
        var activities = session["activities"];
        for (var i = 0; i < activities.size(); i += 1) {
            total += durationForActivity(activities[i]);
        }
        return total;
    }

    static function formatDuration(seconds) {
        var mins = seconds / 60;
        var secs = seconds % 60;
        if (mins >= 60) {
            var hours = mins / 60;
            var remMins = mins % 60;
            return hours + "h " + remMins + "m";
        }
        return mins + ":" + secs.format("%02d");
    }

    static function clampMin(value, minValue) {
        if (value == null || value < minValue) {
            return minValue;
        }
        return value;
    }

    static function normalizedActivity(type, params) {
        return {
            "type" => type,
            "params" => normalizeParams(type, params)
        };
    }

    static function normalizeParams(type, params) {
        var defaults = defaultParams(type);
        if (params == null) {
            return defaults;
        }

        if (type == ActivityTypes.ANULOM_VILOM) {
            return {
                "inhale" => clampMin(params["inhale"], 1),
                "pause" => clampMin(params["pause"], 0),
                "reps" => clampMin(params["reps"], 1)
            };
        } else if (type == ActivityTypes.BHRAMARI || type == ActivityTypes.BHASTRIKA) {
            return {
                "inhale" => clampMin(params["inhale"], 1),
                "reps" => clampMin(params["reps"], 1)
            };
        } else if (type == ActivityTypes.KAPALBHATI) {
            return {
                "totalTime" => clampMin(params["totalTime"], 1)
            };
        }

        return {
            "duration" => clampMin(params["duration"], 1)
        };
    }
}
