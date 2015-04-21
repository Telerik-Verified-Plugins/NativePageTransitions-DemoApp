(function (global) {
  var DemoViewModel,
      app = global.app = global.app || {};
  
  DemoViewModel = kendo.data.ObservableObject.extend({

    // slide
    slideLeft: function () {
      this.slide("left");
    },

    slideRight: function () {
      this.slide("right");
    },

    slideUp: function () {
      this.slide("up");
    },

    slideDown: function () {
      this.slide("down");
    },

    slide: function (direction) {
      var highspeed = $("#slide-highspeed-switch").data("kendoMobileSwitch");
      var overlap = $("#slide-overlap-switch").data("kendoMobileSwitch");

      if (!this.checkSimulator()) {        
        var options = {
          "direction" : direction,
          "duration"  : highspeed.check() ? 400 : 3000,
          "slowdownfactor" : overlap.check() ? 4 : 1,
          "iosdelay"     : 0,
          "androiddelay" : 0,
          "winphonedelay": 0,
          "href" : null,
          "fixedPixelsTop": 0,
          "fixedPixelsBottom": 60
        };
        window.plugins.nativepagetransitions.slide(
          options,
          function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
          function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },


    // drawer
    openDrawer: function () {
      this.drawer("open");
    },

    closeDrawer: function () {
      this.drawer("close");
    },

    drawer: function (action) {
      var highspeed = $("#drawer-highspeed-switch").data("kendoMobileSwitch");
      var originright = $("#drawer-originright-switch").data("kendoMobileSwitch");

      if (!this.checkSimulator()) {        
        var options = {
          "action" : action,
          "origin" : originright.check() ? "right" : "left",
          "duration"  : highspeed.check() ? 300 : 3000,
          "iosdelay"     : 0,
          "androiddelay" : 0,
          "winphonedelay": 0,
          "href" : null
        };
        window.plugins.nativepagetransitions.drawer(
          options,
          function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
          function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },
    

    // flip
    flipLeft: function () {
      this.flip("left");
    },

    flipRight: function () {
      this.flip("right");
    },

    flipUp: function () {
      this.flip("up");
    },

    flipDown: function () {
      this.flip("down");
    },

    flip: function (direction) {
      var highspeed = $("#flip-highspeed-switch").data("kendoMobileSwitch");

      if (!this.checkSimulator()) {        
        var options = {
          "direction" : direction,
          "duration"  : highspeed.check() ? 500 : 3000,
          "iosdelay"     : 0,
          "androiddelay" : 0,
          "winphonedelay": 0,
          "href" : null
        };
        window.plugins.nativepagetransitions.flip(
          options,
          function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
          function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },
      
    // curl
    curlUp: function () {
      this.curl("up");
    },
      
    curlDown: function () {
      this.curl("down");
    },

    curl: function (direction) {
      var highspeed = $("#curl-highspeed-switch").data("kendoMobileSwitch");
      if (!this.checkSimulator()) {
        var options = {
            "direction" : direction,
            "duration"  : highspeed.check() ? 500 : 3000,
            "iosdelay"     : 0,
            "href" : null
        };
        window.plugins.nativepagetransitions.curl(
            options,
            function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
            function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },

    // fade
    fade: function () {
      var highspeed = $("#fade-highspeed-switch").data("kendoMobileSwitch");
      if (!this.checkSimulator()) {
        var options = {
            "duration"  : highspeed.check() ? 500 : 3000,
            "androiddelay" : 0,
            "iosdelay"  : 0,
            "href" : null
        };
        window.plugins.nativepagetransitions.fade(
            options,
            function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
            function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },

    checkSimulator: function() {
      if (window.navigator.simulator === true) {
        alert('This plugin is not available in the simulator.');
        return true;
      } else if (window.plugins.nativepagetransitions === undefined) {
        alert('Plugin not found. Maybe you are running in AppBuilder Companion app which currently does not support this plugin.');
        return true;
      } else {
        return false;
      }
    }
  });

  app.demoService = {
    viewModel: new DemoViewModel()
  };
})(window);