using Toybox.Application;

class PranayamaApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        SessionStore.ensureSeedData();
        SessionStore.seedPresets();
    }

    function onStop(state) {
    }

    function getInitialView() {
        var view = new HomeCardView();
        return [ view, new HomeCardDelegate(view) ];
    }
}
