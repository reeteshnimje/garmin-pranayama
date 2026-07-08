using Toybox.WatchUi;
using Toybox.Graphics;

// Quick-start card: the last-used practice is one START press away.
// UP/DOWN cycles saved sessions, MENU opens management.
class HomeCardView extends WatchUi.View {
    var sessions;
    var index;

    function initialize() {
        View.initialize();
        sessions = [];
        index = 0;
    }

    function onShow() {
        refresh();
    }

    function refresh() {
        sessions = SessionStore.all();
        index = 0;

        var lastId = SessionStore.lastSessionId();
        if (lastId != null) {
            for (var i = 0; i < sessions.size(); i += 1) {
                if (sessions[i]["id"].equals(lastId)) {
                    index = i;
                    break;
                }
            }
        }
        WatchUi.requestUpdate();
    }

    function cycle(delta) {
        if (sessions.size() > 1) {
            index = (index + delta + sessions.size()) % sessions.size();
            SessionStore.setLastSession(sessions[index]["id"]);
            WatchUi.requestUpdate();
        }
    }

    function current() {
        if (index < sessions.size()) {
            return sessions[index];
        }
        return null;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var cy = h / 2;

        dc.setColor(UiConstants.FG, UiConstants.BG);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        dc.setPenWidth(4);
        dc.setColor(UiConstants.RING_BG, Graphics.COLOR_TRANSPARENT);
        dc.drawCircle(cx, cy, (w / 2) - 4);

        var session = current();
        if (session == null) {
            dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 0.36, Graphics.FONT_MEDIUM, "No practices",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(cx, h * 0.52, Graphics.FONT_TINY, "Create your first one",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(cx, h * 0.84, Graphics.FONT_XTINY, "START to create",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            return;
        }

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.16, Graphics.FONT_TINY, History.streakText(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.33, Graphics.FONT_MEDIUM, session["name"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.50, Graphics.FONT_NUMBER_MEDIUM,
            SessionMath.formatDuration(SessionMath.durationForSession(session)),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.66, Graphics.FONT_TINY, activitySummary(session),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.drawText(cx, h * 0.84, Graphics.FONT_XTINY, "START begin - MENU manage",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function activitySummary(session) {
        var activities = session["activities"];
        var text = "";
        for (var i = 0; i < activities.size(); i += 1) {
            if (i > 0) {
                text += " - ";
            }
            text += ActivityTypes.shortName(activities[i]["type"]);
        }
        return text;
    }
}

class HomeCardDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(homeView) {
        BehaviorDelegate.initialize();
        view = homeView;
    }

    function onSelect() {
        var session = view.current();
        if (session == null) {
            var state = new BuilderState(null);
            var pick = new ActivityPickMenu(state);
            WatchUi.pushView(pick, new ActivityPickDelegate(pick, state), WatchUi.SLIDE_UP);
        } else {
            var runner = new RunnerView(session);
            WatchUi.pushView(runner, new RunnerDelegate(runner), WatchUi.SLIDE_UP);
        }
        return true;
    }

    function onMenu() {
        WatchUi.pushView(new ManageMenu(), new ManageMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onNextPage() {
        view.cycle(1);
        return true;
    }

    function onPreviousPage() {
        view.cycle(-1);
        return true;
    }
}

class ManageMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Practices" });
    }

    function onShow() {
        rebuild();
    }

    function rebuild() {
        while (deleteItem(0) == true) { }

        var sessions = SessionStore.all();
        for (var i = 0; i < sessions.size(); i += 1) {
            var session = sessions[i];
            addItem(new WatchUi.MenuItem(
                session["name"],
                SessionMath.formatDuration(SessionMath.durationForSession(session)),
                session["id"],
                null));
        }

        addItem(new WatchUi.MenuItem("New Practice", null, :createSession, null));
    }
}

class ManageMenuDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :createSession) {
            var state = new BuilderState(null);
            var pick = new ActivityPickMenu(state);
            WatchUi.pushView(pick, new ActivityPickDelegate(pick, state), WatchUi.SLIDE_UP);
            return;
        }

        var session = SessionStore.find(id);
        if (session != null) {
            var actions = new SessionActionMenu(session["id"]);
            WatchUi.pushView(actions, new SessionActionDelegate(actions), WatchUi.SLIDE_UP);
        }
    }
}
