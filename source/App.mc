using Toybox.Application;

class PranayamaApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        SessionStore.ensureSeedData();
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new HomeMenu(), new HomeMenuDelegate() ];
    }
}
