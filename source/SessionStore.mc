using Toybox.Application.Storage;

class SessionStore {
    static function ensureSeedData() {
        if (Storage.getValue(StorageKeys.SESSIONS) == null) {
            Storage.setValue(StorageKeys.SESSIONS, []);
        }
        if (Storage.getValue(StorageKeys.NEXT_ID) == null) {
            Storage.setValue(StorageKeys.NEXT_ID, 1);
        }
    }

    static function all() {
        ensureSeedData();
        var sessions = Storage.getValue(StorageKeys.SESSIONS);
        if (sessions == null) {
            return [];
        }
        return sessions;
    }

    static function find(sessionId) {
        var sessions = all();
        for (var i = 0; i < sessions.size(); i += 1) {
            if (sessions[i]["id"].equals(sessionId)) {
                return sessions[i];
            }
        }
        return null;
    }

    static function setLastSession(sessionId) {
        Storage.setValue(StorageKeys.LAST_SESSION, sessionId);
    }

    static function lastSessionId() {
        return Storage.getValue(StorageKeys.LAST_SESSION);
    }

    // Seed two starter practices on first launch so the app is never an
    // empty list. Skipped if the user has ever created or deleted sessions.
    static function seedPresets() {
        ensureSeedData();
        if (all().size() > 0 || Storage.getValue(StorageKeys.NEXT_ID) != 1) {
            return;
        }

        var morning = newSession([]);
        morning["name"] = "Morning Calm";
        morning["activities"] = [
            SessionMath.normalizedActivity(ActivityTypes.ANULOM_VILOM,
                { "inhale" => 4, "pause" => 0, "reps" => 6 }),
            SessionMath.normalizedActivity(ActivityTypes.MEDITATION,
                { "duration" => 300 })
        ];
        save(morning);

        var reset = newSession([]);
        reset["name"] = "Quick Reset";
        reset["activities"] = [
            SessionMath.normalizedActivity(ActivityTypes.BHRAMARI,
                { "inhale" => 4, "reps" => 10 })
        ];
        save(reset);

        setLastSession(morning["id"]);
    }

    static function save(session) {
        ensureSeedData();
        var sessions = all();
        var normalized = normalizeSession(session);
        var found = false;

        for (var i = 0; i < sessions.size(); i += 1) {
            if (sessions[i]["id"].equals(normalized["id"])) {
                sessions[i] = normalized;
                found = true;
            }
        }

        if (!found) {
            sessions.add(normalized);
            Storage.setValue(StorageKeys.NEXT_ID, Storage.getValue(StorageKeys.NEXT_ID) + 1);
        }

        Storage.setValue(StorageKeys.SESSIONS, sessions);
    }

    static function remove(sessionId) {
        ensureSeedData();
        var sessions = all();
        var kept = [];

        for (var i = 0; i < sessions.size(); i += 1) {
            if (!sessions[i]["id"].equals(sessionId)) {
                kept.add(sessions[i]);
            }
        }

        Storage.setValue(StorageKeys.SESSIONS, kept);
    }

    static function newSession(activityTypes) {
        ensureSeedData();
        var idNumber = Storage.getValue(StorageKeys.NEXT_ID);
        var activities = [];

        for (var i = 0; i < activityTypes.size(); i += 1) {
            var type = activityTypes[i];
            activities.add(SessionMath.normalizedActivity(type, SessionMath.defaultParams(type)));
        }

        return {
            "id" => "session-" + idNumber,
            "name" => "Practice " + idNumber,
            "activities" => activities
        };
    }

    static function normalizeSession(session) {
        var activities = session["activities"];
        var cleanActivities = [];

        for (var i = 0; i < activities.size(); i += 1) {
            var activity = activities[i];
            cleanActivities.add(SessionMath.normalizedActivity(activity["type"], activity["params"]));
        }

        return {
            "id" => session["id"],
            "name" => session["name"],
            "activities" => cleanActivities
        };
    }
}
