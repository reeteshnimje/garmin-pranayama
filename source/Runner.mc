using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.System;

class RunnerView extends WatchUi.View {
    var session;
    var phases;
    var phaseIndex;
    var phaseStartMs;
    var totalDuration;
    var completedDuration;
    var timer;
    var completed;
    var lastPulseSecond;

    function initialize(selectedSession) {
        View.initialize();
        session = selectedSession;
        phases = buildPhases(selectedSession);
        phaseIndex = 0;
        phaseStartMs = null;
        totalDuration = SessionMath.durationForSession(selectedSession);
        completedDuration = 0;
        timer = null;
        completed = false;
        lastPulseSecond = 0;
    }

    function onShow() {
        if (phaseStartMs == null) {
            startPhase();
        }
        if (timer == null && !completed) {
            timer = new Timer.Timer();
            timer.start(method(:onTick), 200, true);
        }
    }

    function onHide() {
        stopTimer();
    }

    function stopTimer() {
        if (timer != null) {
            timer.stop();
            timer = null;
        }
    }

    function cancel() {
        stopTimer();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function startPhase() {
        if (phaseIndex >= phases.size()) {
            finish();
            return;
        }

        var phase = phases[phaseIndex];
        phaseStartMs = System.getTimer();
        lastPulseSecond = 0;

        var newActivity = true;
        if (phaseIndex > 0) {
            newActivity = !phases[phaseIndex - 1]["activity"].equals(phase["activity"]);
        }
        if (newActivity) {
            Vibes.longPulse();
        } else {
            Vibes.shortPulse();
        }

        WatchUi.requestUpdate();
    }

    function onTick() as Void {
        if (completed || phaseIndex >= phases.size()) {
            return;
        }

        var phase = phases[phaseIndex];
        var durMs = phase["duration"] * 1000;
        var elapsed = System.getTimer() - phaseStartMs;

        if (elapsed >= durMs) {
            completedDuration += phase["duration"];
            phaseIndex += 1;
            startPhase();
            return;
        }

        if (phase["kind"] == :pulse) {
            var sec = elapsed / 1000;
            if (sec != lastPulseSecond) {
                lastPulseSecond = sec;
                Vibes.shortPulse();
            }
        }

        WatchUi.requestUpdate();
    }

    function finish() {
        if (completed) {
            return;
        }
        completed = true;
        stopTimer();
        Vibes.longPulse();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;
        var radius = (w / 2) - 10;

        dc.setColor(UiConstants.FG, UiConstants.BG);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        if (completed) {
            drawComplete(dc, w, h, cx, cy, radius);
            return;
        }

        if (phaseIndex >= phases.size()) {
            return;
        }

        var phase = phases[phaseIndex];
        var durMs = phase["duration"] * 1000;
        var elapsed = 0;
        if (phaseStartMs != null) {
            elapsed = System.getTimer() - phaseStartMs;
        }
        if (elapsed > durMs) {
            elapsed = durMs;
        }

        var remainingSecs = (durMs - elapsed + 999) / 1000;
        var color = UiConstants.phaseColor(phase["kind"]);

        dc.setPenWidth(12);
        dc.setColor(UiConstants.RING_BG, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        var remainingFrac = 1.0 - (elapsed.toFloat() / durMs);
        var degrees = (360.0 * remainingFrac).toNumber();
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (degrees >= 360) {
            dc.drawCircle(cx, cy, radius);
        } else if (degrees > 0) {
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, 90 - degrees);
        }

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.15, Graphics.FONT_TINY, phase["activity"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.31, Graphics.FONT_MEDIUM, phase["label"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var countdown;
        if (remainingSecs >= 60) {
            countdown = SessionMath.formatDuration(remainingSecs);
        } else {
            countdown = remainingSecs.toString();
        }
        dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.52, Graphics.FONT_NUMBER_MEDIUM, countdown,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var totalRemaining = totalDuration - completedDuration - (elapsed / 1000);
        if (totalRemaining < 0) {
            totalRemaining = 0;
        }
        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.72, Graphics.FONT_TINY,
            SessionMath.formatDuration(totalRemaining) + " left",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(cx, h * 0.85, Graphics.FONT_XTINY, "BACK to stop",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawComplete(dc, w, h, cx, cy, radius) {
        dc.setPenWidth(12);
        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.34, Graphics.FONT_MEDIUM, "Complete",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.52, Graphics.FONT_NUMBER_MEDIUM, SessionMath.formatDuration(totalDuration),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.70, Graphics.FONT_TINY, session["name"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(cx, h * 0.85, Graphics.FONT_XTINY, "BACK to exit",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function buildPhases(selectedSession) {
        var result = [];
        var activities = selectedSession["activities"];

        for (var i = 0; i < activities.size(); i += 1) {
            var activity = activities[i];
            var type = activity["type"];
            var params = activity["params"];
            var name = ActivityTypes.name(type);

            if (type == ActivityTypes.ANULOM_VILOM) {
                var inhale = params["inhale"];
                var hold = inhale * 4;
                var exhale = inhale * 2;
                var pause = params["pause"];
                for (var rep = 0; rep < params["reps"]; rep += 1) {
                    addRound(result, name, "Inhale L", inhale, hold, "Exhale R", exhale, pause);
                    addRound(result, name, "Inhale R", inhale, hold, "Exhale L", exhale, pause);
                }
            } else if (type == ActivityTypes.BHRAMARI || type == ActivityTypes.BHASTRIKA) {
                for (var rep2 = 0; rep2 < params["reps"]; rep2 += 1) {
                    result.add(phaseEntry(name, "Inhale", :inhale, params["inhale"]));
                    result.add(phaseEntry(name, "Exhale", :exhale, params["inhale"] * 2));
                }
            } else if (type == ActivityTypes.KAPALBHATI) {
                result.add(phaseEntry(name, "Pump", :pulse, params["totalTime"]));
            } else {
                result.add(phaseEntry(name, "Meditate", :meditation, params["duration"]));
            }
        }

        return result;
    }

    function addRound(result, name, inhaleLabel, inhale, hold, exhaleLabel, exhale, pause) {
        result.add(phaseEntry(name, inhaleLabel, :inhale, inhale));
        result.add(phaseEntry(name, "Hold", :hold, hold));
        result.add(phaseEntry(name, exhaleLabel, :exhale, exhale));
        if (pause > 0) {
            result.add(phaseEntry(name, "Pause", :pause, pause));
        }
    }

    function phaseEntry(activityName, label, kind, duration) {
        return {
            "activity" => activityName,
            "label" => label,
            "kind" => kind,
            "duration" => duration
        };
    }
}

class RunnerDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(runnerView) {
        BehaviorDelegate.initialize();
        view = runnerView;
    }

    function onBack() {
        view.cancel();
        return true;
    }
}
