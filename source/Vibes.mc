using Toybox.Attention;

class Vibes {
    static function shortPulse() {
        vibrate(VibrationConstants.SHORT_MS);
    }

    static function longPulse() {
        vibrate(VibrationConstants.LONG_MS);
    }

    static function vibrate(lengthMs) {
        if (Attention has :vibrate) {
            Attention.vibrate([
                new Attention.VibeProfile(VibrationConstants.DUTY_CYCLE, lengthMs)
            ]);
        }
    }
}
