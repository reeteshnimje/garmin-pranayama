using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Timer;
using Toybox.System;
using Toybox.Activity;
using Toybox.ActivityRecording;

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
    var paused;
    var pauseStartMs;
    var pendingEnd;
    var fitSession;
    var finalStreakText;

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
        paused = false;
        pauseStartMs = null;
        pendingEnd = false;
        fitSession = null;
        finalStreakText = "";
        SessionStore.setLastSession(selectedSession["id"]);
    }

    function onShow() {
        if (pendingEnd) {
            endEarly();
            return;
        }
        if (phaseStartMs == null) {
            startPhase();
        } else if (!paused && pauseStartMs != null) {
            // The view was hidden (e.g. end-session dialog); shift the anchor
            // so hidden time doesn't count against the phase.
            resumeClock();
        }
        if (timer == null && !completed) {
            timer = new Timer.Timer();
            timer.start(method(:onTick), 200, true);
        }
    }

    function onHide() {
        stopTimer();
        if (!completed && !paused && pauseStartMs == null) {
            pauseStartMs = System.getTimer();
        }
    }

    function stopTimer() {
        if (timer != null) {
            timer.stop();
            timer = null;
        }
    }

    function resumeClock() {
        if (pauseStartMs != null) {
            phaseStartMs += System.getTimer() - pauseStartMs;
            pauseStartMs = null;
        }
    }

    function togglePause() {
        if (completed) {
            return;
        }
        if (paused) {
            paused = false;
            resumeClock();
            if (fitSession != null) {
                fitSession.start();
            }
        } else {
            paused = true;
            pauseStartMs = System.getTimer();
            if (fitSession != null) {
                fitSession.stop();
            }
        }
        WatchUi.requestUpdate();
    }

    function currentElapsedMs(phase) {
        if (phaseStartMs == null) {
            return 0;
        }
        var reference = System.getTimer();
        if (pauseStartMs != null) {
            reference = pauseStartMs;
        }
        var elapsed = reference - phaseStartMs;
        var durMs = phase["duration"] * 1000;
        if (elapsed > durMs) {
            elapsed = durMs;
        }
        if (elapsed < 0) {
            elapsed = 0;
        }
        return elapsed;
    }

    function startPhase() {
        if (phaseIndex >= phases.size()) {
            finish();
            return;
        }

        var phase = phases[phaseIndex];
        phaseStartMs = System.getTimer();
        lastPulseSecond = 0;

        if (phase["kind"] != :ready && fitSession == null) {
            startRecording();
        }

        Vibes.cueForPhase(phase["kind"]);
        WatchUi.requestUpdate();
    }

    function onTick() as Void {
        if (completed || paused || pauseStartMs != null || phaseIndex >= phases.size()) {
            return;
        }

        var phase = phases[phaseIndex];
        var durMs = phase["duration"] * 1000;
        var elapsed = System.getTimer() - phaseStartMs;

        if (elapsed >= durMs) {
            if (phase["kind"] != :ready) {
                completedDuration += phase["duration"];
            }
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
        finalizeRecording(true);
        History.record(totalDuration);
        finalStreakText = History.streakText();
        Vibes.completeCue();
        WatchUi.requestUpdate();
    }

    function endEarly() {
        stopTimer();

        var practiced = completedDuration;
        if (!completed && phaseIndex < phases.size()) {
            var phase = phases[phaseIndex];
            if (phase["kind"] != :ready) {
                practiced += currentElapsedMs(phase) / 1000;
            }
        }

        var worthKeeping = practiced >= 60;
        finalizeRecording(worthKeeping);
        if (worthKeeping) {
            History.record(practiced);
        }
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function startRecording() {
        if (!(Toybox has :ActivityRecording)) {
            return;
        }
        // SPORT_BREATHING makes Connect render this as a breathwork activity
        // (duration, heart rate, respiration) instead of "Other" with the
        // distance/speed/ascent metrics a run or walk would show.
        var options = { :name => "Pranayama" };
        if (Activity has :SPORT_BREATHING) {
            options[:sport] = Activity.SPORT_BREATHING;
            if (Activity has :SUB_SPORT_BREATHING) {
                options[:subSport] = Activity.SUB_SPORT_BREATHING;
            }
        } else if (Activity has :SPORT_MEDITATION) {
            options[:sport] = Activity.SPORT_MEDITATION;
        } else {
            options[:sport] = Activity.SPORT_GENERIC;
        }
        fitSession = ActivityRecording.createSession(options);
        fitSession.start();
    }

    function finalizeRecording(keep) {
        if (fitSession == null) {
            return;
        }
        fitSession.stop();
        if (keep) {
            fitSession.save();
        } else {
            fitSession.discard();
        }
        fitSession = null;
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
        var elapsed = currentElapsedMs(phase);
        var kind = phase["kind"];
        var color = UiConstants.phaseColor(kind);
        var remainingSecs = (durMs - elapsed + 999) / 1000;

        dc.setPenWidth(12);
        dc.setColor(UiConstants.RING_BG, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        // The ring breathes with you: fills on inhale, holds full, drains on
        // exhale, stays empty during pauses. Timed activities drain like a
        // countdown.
        var frac = elapsed.toFloat() / durMs;
        var sweep;
        if (kind == :inhale) {
            sweep = frac;
        } else if (kind == :hold) {
            sweep = 1.0;
        } else if (kind == :exhale) {
            sweep = 1.0 - frac;
        } else if (kind == :pause) {
            sweep = 0.0;
        } else {
            sweep = 1.0 - frac;
        }

        var degrees = (360.0 * sweep).toNumber();
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        if (degrees >= 360) {
            dc.drawCircle(cx, cy, radius);
        } else if (degrees > 0) {
            dc.drawArc(cx, cy, radius, Graphics.ARC_CLOCKWISE, 90, 90 - degrees);
        }

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.15, Graphics.FONT_TINY, phase["activity"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var label = phase["label"];
        var labelColor = color;
        if (paused) {
            label = "Paused";
            labelColor = UiConstants.WARNING;
        }
        dc.setColor(labelColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.31, Graphics.FONT_MEDIUM, label,
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

        var totalRemaining = totalDuration - completedDuration;
        if (kind != :ready) {
            totalRemaining -= elapsed / 1000;
        }
        if (totalRemaining < 0) {
            totalRemaining = 0;
        }
        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.72, Graphics.FONT_TINY,
            SessionMath.formatDuration(totalRemaining) + " left",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var hint = "START pauses";
        if (paused) {
            hint = "BACK ends";
        }
        dc.drawText(cx, h * 0.80, Graphics.FONT_XTINY, hint,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawComplete(dc, w, h, cx, cy, radius) {
        dc.setPenWidth(12);
        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, radius);

        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.32, Graphics.FONT_MEDIUM, "Complete",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.50, Graphics.FONT_NUMBER_MEDIUM, SessionMath.formatDuration(totalDuration),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.68, Graphics.FONT_TINY, finalStreakText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(cx, h * 0.80, Graphics.FONT_XTINY, "BACK to exit",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function buildPhases(selectedSession) {
        var result = [];

        result.add(phaseEntry(selectedSession["name"], "Settle in", :ready, 5));

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

    function onSelect() {
        view.togglePause();
        return true;
    }

    function onBack() {
        if (view.completed) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        var dialog = new WatchUi.Confirmation("End session?");
        WatchUi.pushView(dialog, new EndSessionDelegate(view), WatchUi.SLIDE_UP);
        return true;
    }
}

class EndSessionDelegate extends WatchUi.ConfirmationDelegate {
    var view;

    function initialize(runnerView) {
        ConfirmationDelegate.initialize();
        view = runnerView;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            view.pendingEnd = true;
        }
        return true;
    }
}
