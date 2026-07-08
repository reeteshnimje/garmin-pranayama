using Toybox.WatchUi;

class HomeMenu extends WatchUi.Menu2 {
    function initialize() {
        Menu2.initialize({ :title => "Pranayama" });
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

        addItem(new WatchUi.MenuItem("New Session", null, :createSession, null));
    }
}

class HomeMenuDelegate extends WatchUi.Menu2InputDelegate {
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
