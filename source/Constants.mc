module ActivityTypes {
    const ANULOM_VILOM = 0;
    const BHRAMARI = 1;
    const BHASTRIKA = 2;
    const KAPALBHATI = 3;
    const MEDITATION = 4;

    function all() {
        return [
            ANULOM_VILOM,
            BHRAMARI,
            BHASTRIKA,
            KAPALBHATI,
            MEDITATION
        ];
    }

    function name(type) {
        if (type == ANULOM_VILOM) {
            return "Anulom Vilom";
        } else if (type == BHRAMARI) {
            return "Bhramari";
        } else if (type == BHASTRIKA) {
            return "Bhastrika";
        } else if (type == KAPALBHATI) {
            return "Kapalbhati";
        }
        return "Meditation";
    }

    function shortName(type) {
        if (type == ANULOM_VILOM) {
            return "Anulom";
        } else if (type == BHRAMARI) {
            return "Bhramari";
        } else if (type == BHASTRIKA) {
            return "Bhastrika";
        } else if (type == KAPALBHATI) {
            return "Kapalbhati";
        }
        return "Sit";
    }
}

module StorageKeys {
    const SESSIONS = "sessions";
    const NEXT_ID = "nextSessionId";
    const LAST_SESSION = "lastSessionId";
    const HISTORY = "history";
}

module VibrationConstants {
    const DUTY_CYCLE = 100;
    const SHORT_MS = 180;
    const LONG_MS = 700;
}

module UiConstants {
    const BG = 0x000000;
    const FG = 0xFFFFFF;
    const MUTED = 0x888888;
    const ACCENT = 0x45D6B5;
    const WARNING = 0xFFB84D;
    const RING_BG = 0x2A2A2A;

    const COLOR_INHALE = 0x45D6B5;
    const COLOR_HOLD = 0xFFB84D;
    const COLOR_EXHALE = 0x4D9BFF;
    const COLOR_PAUSE = 0x888888;
    const COLOR_PULSE = 0xFF7A5C;
    const COLOR_MEDITATE = 0xB48CFF;

    function phaseColor(kind) {
        if (kind == :inhale) {
            return COLOR_INHALE;
        } else if (kind == :hold) {
            return COLOR_HOLD;
        } else if (kind == :exhale) {
            return COLOR_EXHALE;
        } else if (kind == :pulse) {
            return COLOR_PULSE;
        } else if (kind == :meditation) {
            return COLOR_MEDITATE;
        }
        return COLOR_PAUSE;
    }
}
