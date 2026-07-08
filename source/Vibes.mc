using Toybox.Attention;

// Haptic language for eyes-closed practice:
//   inhale  = one short pulse
//   hold    = two quick pulses
//   exhale  = one long pulse
//   pause   = silence
//   done    = two long pulses
class Vibes {
    static function inhaleCue() {
        play([ on(VibrationConstants.SHORT_MS) ]);
    }

    static function holdCue() {
        play([ on(150), off(120), on(150) ]);
    }

    static function exhaleCue() {
        play([ on(VibrationConstants.LONG_MS) ]);
    }

    static function completeCue() {
        play([ on(500), off(250), on(500) ]);
    }

    static function shortPulse() {
        play([ on(VibrationConstants.SHORT_MS) ]);
    }

    static function longPulse() {
        play([ on(VibrationConstants.LONG_MS) ]);
    }

    static function cueForPhase(kind) {
        if (kind == :inhale) {
            inhaleCue();
        } else if (kind == :hold) {
            holdCue();
        } else if (kind == :exhale) {
            exhaleCue();
        } else if (kind == :pulse) {
            shortPulse();
        } else if (kind == :meditation) {
            longPulse();
        }
        // :pause and :ready are silent by design
    }

    static function on(lengthMs) {
        return new Attention.VibeProfile(VibrationConstants.DUTY_CYCLE, lengthMs);
    }

    static function off(lengthMs) {
        return new Attention.VibeProfile(0, lengthMs);
    }

    static function play(profiles) {
        if (Attention has :vibrate) {
            Attention.vibrate(profiles);
        }
    }
}
