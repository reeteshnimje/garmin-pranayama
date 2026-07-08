using Toybox.WatchUi;

class BuilderState {
    var editingSession;
    var selected;
    var order;
    var activities;

    function initialize(session) {
        editingSession = session;
        selected = [ false, false, false, false, false ];
        order = [];
        activities = [];

        if (session != null) {
            var existing = session["activities"];
            for (var i = 0; i < existing.size(); i += 1) {
                selected[existing[i]["type"]] = true;
                order.add(existing[i]["type"]);
                activities.add(SessionMath.normalizedActivity(existing[i]["type"], existing[i]["params"]));
            }
        }
    }

    function selectedCount() {
        var count = 0;
        for (var i = 0; i < selected.size(); i += 1) {
            if (selected[i]) {
                count += 1;
            }
        }
        return count;
    }

    function syncOrderFromSelection() {
        var filtered = [];
        for (var i = 0; i < order.size(); i += 1) {
            if (selected[order[i]]) {
                filtered.add(order[i]);
            }
        }
        order = filtered;

        var types = ActivityTypes.all();
        for (var j = 0; j < types.size(); j += 1) {
            if (selected[types[j]] && !containsType(order, types[j])) {
                order.add(types[j]);
            }
        }
    }

    function rebuildActivities() {
        var next = [];
        for (var i = 0; i < order.size(); i += 1) {
            var existing = findActivity(order[i]);
            if (existing == null) {
                next.add(SessionMath.normalizedActivity(order[i], null));
            } else {
                next.add(SessionMath.normalizedActivity(existing["type"], existing["params"]));
            }
        }
        activities = next;
    }

    function findActivity(type) {
        for (var i = 0; i < activities.size(); i += 1) {
            if (activities[i]["type"] == type) {
                return activities[i];
            }
        }

        if (editingSession != null) {
            var existing = editingSession["activities"];
            for (var j = 0; j < existing.size(); j += 1) {
                if (existing[j]["type"] == type) {
                    return existing[j];
                }
            }
        }
        return null;
    }

    function containsType(list, type) {
        for (var i = 0; i < list.size(); i += 1) {
            if (list[i] == type) {
                return true;
            }
        }
        return false;
    }

    function draftDuration() {
        if (activities.size() == 0) {
            return 0;
        }
        return SessionMath.durationForSession({ "id" => "draft", "name" => "Draft", "activities" => activities });
    }

    function save() {
        var session;
        if (editingSession == null) {
            session = SessionStore.newSession([]);
            session["activities"] = activities;
        } else {
            editingSession["activities"] = activities;
            session = editingSession;
        }
        SessionStore.save(session);
    }
}

module BuilderNav {
    function openConfig(state, index, transition) {
        var cfg = new ConfigMenu(state, index);
        WatchUi.switchToView(cfg, new ConfigDelegate(cfg, state), transition);
    }

    function openOrder(state, transition) {
        var orderMenu = new OrderMenu(state);
        WatchUi.switchToView(orderMenu, new OrderDelegate(orderMenu, state), transition);
    }

    function openPick(state, transition) {
        var pick = new ActivityPickMenu(state);
        WatchUi.switchToView(pick, new ActivityPickDelegate(pick, state), transition);
    }
}

class ActivityPickMenu extends WatchUi.Menu2 {
    function initialize(state) {
        Menu2.initialize({ :title => "Activities" });

        var types = ActivityTypes.all();
        for (var i = 0; i < types.size(); i += 1) {
            addItem(new WatchUi.ToggleMenuItem(
                ActivityTypes.name(types[i]),
                null,
                types[i],
                state.selected[types[i]],
                null));
        }

        addItem(new WatchUi.MenuItem("Next", "Order & configure", :next, null));
    }
}

class ActivityPickDelegate extends WatchUi.Menu2InputDelegate {
    var menu;
    var state;

    function initialize(pickMenu, builderState) {
        Menu2InputDelegate.initialize();
        menu = pickMenu;
        state = builderState;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :next) {
            syncSelections();
            if (state.selectedCount() == 0) {
                return;
            }
            state.syncOrderFromSelection();
            state.rebuildActivities();
            if (state.order.size() == 1) {
                BuilderNav.openConfig(state, 0, WatchUi.SLIDE_LEFT);
            } else {
                BuilderNav.openOrder(state, WatchUi.SLIDE_LEFT);
            }
        } else {
            state.selected[id] = (item as WatchUi.ToggleMenuItem).isEnabled();
        }
    }

    function syncSelections() {
        var types = ActivityTypes.all();
        for (var i = 0; i < types.size(); i += 1) {
            state.selected[types[i]] = (menu.getItem(i) as WatchUi.ToggleMenuItem).isEnabled();
        }
    }
}

class OrderMenu extends WatchUi.Menu2 {
    var state;

    function initialize(builderState) {
        Menu2.initialize({ :title => "Order" });
        state = builderState;

        for (var i = 0; i < state.order.size(); i += 1) {
            addItem(new WatchUi.MenuItem(labelFor(i), "Select to move down", i, null));
        }

        addItem(new WatchUi.MenuItem("Configure", null, :configure, null));
    }

    function labelFor(i) {
        return (i + 1) + ". " + ActivityTypes.name(state.order[i]);
    }

    function relabel() {
        for (var i = 0; i < state.order.size(); i += 1) {
            getItem(i).setLabel(labelFor(i));
        }
    }
}

class OrderDelegate extends WatchUi.Menu2InputDelegate {
    var menu;
    var state;

    function initialize(orderMenu, builderState) {
        Menu2InputDelegate.initialize();
        menu = orderMenu;
        state = builderState;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :configure) {
            state.rebuildActivities();
            BuilderNav.openConfig(state, 0, WatchUi.SLIDE_LEFT);
        } else {
            var index = id as Toybox.Lang.Number;
            var next = (index + 1) % state.order.size();
            var tmp = state.order[index];
            state.order[index] = state.order[next];
            state.order[next] = tmp;
            menu.relabel();
            WatchUi.requestUpdate();
        }
    }

    function onBack() {
        BuilderNav.openPick(state, WatchUi.SLIDE_RIGHT);
    }
}

class ConfigMenu extends WatchUi.Menu2 {
    var state;
    var index;

    function initialize(builderState, activityIndex) {
        state = builderState;
        index = activityIndex;

        var activity = state.activities[index];
        Menu2.initialize({ :title => ActivityTypes.name(activity["type"]) });

        var fields = SessionMath.fieldsForType(activity["type"]);
        for (var i = 0; i < fields.size(); i += 1) {
            var spec = SessionMath.fieldSpec(fields[i]);
            addItem(new WatchUi.MenuItem(spec["label"], valueText(fields[i]), fields[i], null));
        }

        var doneLabel = "Next Activity";
        if (index == state.activities.size() - 1) {
            doneLabel = "Save Session";
        }
        addItem(new WatchUi.MenuItem(doneLabel, totalText(), :done, null));
    }

    function valueText(field) {
        var value = state.activities[index]["params"][field];
        var spec = SessionMath.fieldSpec(field);
        if (spec["time"]) {
            return SessionMath.formatDuration(value);
        }
        return value.toString();
    }

    function totalText() {
        return "Total " + SessionMath.formatDuration(state.draftDuration());
    }

    function onShow() {
        var activity = state.activities[index];
        var fields = SessionMath.fieldsForType(activity["type"]);
        for (var i = 0; i < fields.size(); i += 1) {
            getItem(i).setSubLabel(valueText(fields[i]));
        }
        getItem(fields.size()).setSubLabel(totalText());
    }
}

class ConfigDelegate extends WatchUi.Menu2InputDelegate {
    var menu;
    var state;

    function initialize(configMenu, builderState) {
        Menu2InputDelegate.initialize();
        menu = configMenu;
        state = builderState;
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :done) {
            if (menu.index >= state.activities.size() - 1) {
                state.save();
                WatchUi.popView(WatchUi.SLIDE_DOWN);
            } else {
                BuilderNav.openConfig(state, menu.index + 1, WatchUi.SLIDE_LEFT);
            }
        } else {
            var params = state.activities[menu.index]["params"];
            var picker = new NumberPickerView(params, id);
            WatchUi.pushView(picker, new NumberPickerDelegate(picker), WatchUi.SLIDE_UP);
        }
    }

    function onBack() {
        if (menu.index > 0) {
            BuilderNav.openConfig(state, menu.index - 1, WatchUi.SLIDE_RIGHT);
        } else if (state.order.size() > 1) {
            BuilderNav.openOrder(state, WatchUi.SLIDE_RIGHT);
        } else {
            BuilderNav.openPick(state, WatchUi.SLIDE_RIGHT);
        }
    }
}
