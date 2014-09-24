(function (global) {
    var app = global.app = global.app || {};

    document.addEventListener('deviceready', function () {
      
        navigator.splashscreen.hide();

        app.changeSkin = function (e) {
            var mobileSkin = "";

            if (e.sender.element.text() === "Flat") {
                e.sender.element.text("Native");
                mobileSkin = "flat";
            } else {
                e.sender.element.text("Flat");
                mobileSkin = "";
            }

            app.application.skin(mobileSkin);
        };

        var os = kendo.support.mobileOS,
            statusBarStyle = os.ios && os.flatVersion >= 700 ? "black-translucent" : "black";
        app.application = new kendo.mobile.Application(document.body, { layout: "tabstrip-layout", statusBarStyle: statusBarStyle });
    }, false);
})(window);