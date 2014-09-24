(function (global) {
  var DemoViewModel,
      app = global.app = global.app || {};
  
  DemoViewModel = kendo.data.ObservableObject.extend({

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
          "duration"  : highspeed.check() ? 400 : 1000,
          "slowdownfactor" : overlap.check() ? 3 : 1
        };
        window.plugins.nativepagetransitions.slide(
          options,
          function (msg) {console.log("SUCCESS: " + JSON.stringify(msg))},
          function (msg) {alert("ERROR: "   + JSON.stringify(msg))}
        );
      }
    },

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
          "duration"  : highspeed.check() ? 400 : 1000
        };
        window.plugins.nativepagetransitions.flip(
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