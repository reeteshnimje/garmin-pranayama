using Toybox.WatchUi;

class SessionActionMenu extends WatchUi.Menu2 {
    var sessionId;

    function initialize(id) {
        Menu2.initialize({ :title => "Session" });
        sessionId = id;
        addItem(new WatchUi.MenuItem("Start", null, :start, null));
        addItem(new WatchUi.MenuItem("Edit", null, :edit, null));
        addItem(new WatchUi.MenuItem("Delete", null, :remove, null));
    }

    function onShow() {
        var session = SessionStore.find(sessionId);
        if (session == null) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return;
        }
        setTitle(session["name"]);
        getItem(0).setSubLabel(SessionMath.formatDuration(SessionMath.durationForSession(session)));
    }
}

class SessionActionDelegate extends WatchUi.Menu2InputDelegate {
    var menu;

    function initialize(actionMenu) {
        Menu2InputDelegate.initialize();
        menu = actionMenu;
    }

    function onSelect(item) {
        var session = SessionStore.find(menu.sessionId);
        if (session == null) {
            return;
        }

        var id = item.getId();
        if (id == :start) {
            var runner = new RunnerView(session);
            WatchUi.pushView(runner, new RunnerDelegate(runner), WatchUi.SLIDE_UP);
        } else if (id == :edit) {
            var state = new BuilderState(session);
            var pick = new ActivityPickMenu(state);
            WatchUi.pushView(pick, new ActivityPickDelegate(pick, state), WatchUi.SLIDE_UP);
        } else {
            var dialog = new WatchUi.Confirmation("Delete " + session["name"] + "?");
            WatchUi.pushView(dialog, new DeleteConfirmDelegate(menu.sessionId), WatchUi.SLIDE_UP);
        }
    }
}

class DeleteConfirmDelegate extends WatchUi.ConfirmationDelegate {
    var sessionId;

    function initialize(id) {
        ConfirmationDelegate.initialize();
        sessionId = id;
    }

    function onResponse(response) {
        if (response == WatchUi.CONFIRM_YES) {
            SessionStore.remove(sessionId);
        }
        return true;
    }
}
