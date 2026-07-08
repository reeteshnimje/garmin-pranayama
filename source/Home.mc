using Toybox.WatchUi;
using Toybox.Graphics;

// Quick-start carousel. UP/DOWN moves between practice cards; the final card
// is "Manage" (create / edit / delete). START acts on the current card.
// The FR265 has no MENU button, so everything is reachable with UP/DOWN/START.
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

    // Total cards = every session plus one trailing "Manage" card.
    function cardCount() {
        return sessions.size() + 1;
    }

    function onManageCard() {
        return index >= sessions.size();
    }

    function cycle(delta) {
        var count = cardCount();
        index = (index + delta + count) % count;
        if (!onManageCard()) {
            SessionStore.setLastSession(sessions[index]["id"]);
        }
        WatchUi.requestUpdate();
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

        dc.setColor(UiConstants.FG, UiConstants.BG);
        dc.clear();

        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }

        if (onManageCard()) {
            drawManageCard(dc, w, h, cx);
        } else {
            drawSessionCard(dc, w, h, cx, sessions[index]);
        }

        drawDots(dc, w, h, cx);
    }

    function drawSessionCard(dc, w, h, cx, session) {
        dc.setColor(UiConstants.FG, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.34, Graphics.FONT_MEDIUM, session["name"],
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.52, Graphics.FONT_NUMBER_MEDIUM,
            SessionMath.formatDuration(SessionMath.durationForSession(session)),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.68, Graphics.FONT_XTINY, "START to begin",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawManageCard(dc, w, h, cx) {
        var hasSessions = sessions.size() > 0;

        dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.40, Graphics.FONT_MEDIUM,
            hasSessions ? "Manage" : "Create",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        dc.setColor(UiConstants.MUTED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(cx, h * 0.56, Graphics.FONT_XTINY,
            hasSessions ? "Edit or add practices" : "Add your first practice",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Pagination dots at the wide center-bottom, so nothing clips the bezel.
    function drawDots(dc, w, h, cx) {
        var count = cardCount();
        if (count <= 1 || count > 8) {
            return;
        }

        var spacing = 16;
        var startX = cx - ((count - 1) * spacing) / 2;
        var y = h * 0.80;

        for (var i = 0; i < count; i += 1) {
            if (i == index) {
                dc.setColor(UiConstants.ACCENT, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(startX + (i * spacing), y, 4);
            } else {
                dc.setColor(UiConstants.RING_BG, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(startX + (i * spacing), y, 3);
            }
        }
    }
}

class HomeCardDelegate extends WatchUi.BehaviorDelegate {
    var view;

    function initialize(homeView) {
        BehaviorDelegate.initialize();
        view = homeView;
    }

    function onSelect() {
        if (view.onManageCard()) {
            openManage();
        } else {
            var runner = new RunnerView(view.current());
            WatchUi.pushView(runner, new RunnerDelegate(runner), WatchUi.SLIDE_UP);
        }
        return true;
    }

    function openManage() {
        if (view.sessions.size() == 0) {
            var state = new BuilderState(null);
            var pick = new ActivityPickMenu(state);
            WatchUi.pushView(pick, new ActivityPickDelegate(pick, state), WatchUi.SLIDE_UP);
        } else {
            WatchUi.pushView(new ManageMenu(), new ManageMenuDelegate(), WatchUi.SLIDE_UP);
        }
    }

    // Long-press UP also opens management on hardware that supports it.
    function onMenu() {
        openManage();
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
