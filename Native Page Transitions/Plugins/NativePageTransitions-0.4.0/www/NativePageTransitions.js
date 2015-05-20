function NativePageTransitions() {
}

NativePageTransitions.prototype.globalOptions =  {
  duration: 400,
  iosdelay: 60,
  androiddelay: 70,
  winphonedelay: 200,
  slowdownfactor: 4,
  fixedPixelsTop: 0,    // currently for slide left/right only
  fixedPixelsBottom: 0  // currently for slide left/right only
};

NativePageTransitions.prototype.slide = function (options, onSuccess, onError) {
  var opts = options || {};
  if (!this._validateHref(opts.href, onError)) {
    return;
  }
  opts.direction = opts.direction || "left";
  if (opts.duration == undefined || opts.duration == "null") {
    opts.duration = this.globalOptions.duration;
  }
  if (opts.androiddelay == undefined || opts.androiddelay == "null") {
    opts.androiddelay = this.globalOptions.androiddelay;
  }
  if (opts.iosdelay == undefined || opts.iosdelay == "null") {
    opts.iosdelay = this.globalOptions.iosdelay;
  }
  if (opts.winphonedelay == undefined || opts.winphonedelay == "null") {
    opts.winphonedelay = this.globalOptions.winphonedelay;
  }
  if (opts.fixedPixelsTop == undefined || opts.fixedPixelsTop == "null") {
    opts.fixedPixelsTop = this.globalOptions.fixedPixelsTop;
  }
  if (opts.fixedPixelsBottom == undefined || opts.fixedPixelsBottom == "null") {
    opts.fixedPixelsBottom = this.globalOptions.fixedPixelsBottom;
  }
  // setting slowdownfactor > 1 makes the next page slide less pixels. Use 1 for side-by-side.
  opts.slowdownfactor = opts.slowdownfactor || this.globalOptions.slowdownfactor;
  cordova.exec(onSuccess, onError, "NativePageTransitions", "slide", [opts]);
};

NativePageTransitions.prototype.drawer = function (options, onSuccess, onError) {
  var opts = options || {};
  if (!this._validateHref(opts.href, onError)) {
    return;
  }
  opts.origin = opts.origin || "left";
  opts.action = opts.action || "open";
  if (opts.duration == undefined || opts.duration == "null") {
    opts.duration = this.globalOptions.duration;
  }
  if (opts.androiddelay == undefined || opts.androiddelay == "null") {
    opts.androiddelay = this.globalOptions.androiddelay;
  }
  if (opts.iosdelay == undefined || opts.iosdelay == "null") {
    opts.iosdelay = this.globalOptions.iosdelay;
  }
  if (opts.winphonedelay == undefined || opts.winphonedelay == "null") {
    opts.winphonedelay = this.globalOptions.winphonedelay;
  }
  cordova.exec(onSuccess, onError, "NativePageTransitions", "drawer", [opts]);
};

NativePageTransitions.prototype.flip = function (options, onSuccess, onError) {
  var opts = options || {};
  if (!this._validateHref(opts.href, onError)) {
    return;
  }
  opts.direction = opts.direction || "right";
  if (opts.duration == undefined || opts.duration == "null") {
    opts.duration = this.globalOptions.duration;
  }
  if (opts.androiddelay == undefined || opts.androiddelay == "null") {
    opts.androiddelay = this.globalOptions.androiddelay;
  }
  if (opts.iosdelay == undefined || opts.iosdelay == "null") {
    opts.iosdelay = this.globalOptions.iosdelay;
  }
  if (opts.winphonedelay == undefined || opts.winphonedelay == "null") {
    opts.winphonedelay = this.globalOptions.winphonedelay;
  }
  cordova.exec(onSuccess, onError, "NativePageTransitions", "flip", [opts]);
};

NativePageTransitions.prototype.curl = function (options, onSuccess, onError) {
  var opts = options || {};
  if (!this._validateHref(opts.href, onError)) {
    return;
  }
  opts.direction = opts.direction || "up";
  if (opts.duration == undefined || opts.duration == "null") {
    opts.duration = this.globalOptions.duration;
  }
  if (opts.iosdelay == undefined || opts.iosdelay == "null") {
    opts.iosdelay = this.globalOptions.iosdelay;
  }
  cordova.exec(onSuccess, onError, "NativePageTransitions", "curl", [opts]);
};

NativePageTransitions.prototype.fade = function (options, onSuccess, onError) {
  var opts = options || {};
  if (!this._validateHref(opts.href, onError)) {
    return;
  }
  if (opts.duration == undefined || opts.duration == "null") {
    opts.duration = this.globalOptions.duration;
  }
  if (opts.androiddelay == undefined || opts.androiddelay == "null") {
    opts.androiddelay = this.globalOptions.androiddelay;
  }
  if (opts.iosdelay == undefined || opts.iosdelay == "null") {
    opts.iosdelay = this.globalOptions.iosdelay;
  }
  cordova.exec(onSuccess, onError, "NativePageTransitions", "fade", [opts]);
};

NativePageTransitions.prototype._validateHref = function (href, errCallback) {
  var currentHref = window.location.href.substr(window.location.href.indexOf('www/')+4);
  // if no href was passed the transition should always kick in
  if (href) {
    // if only hash nav, do it in JS for Android
    // (I'm a little reluctant to depend on 'device' only for this: device.platform == "Android")
    if (href.indexOf('#') == 0 && navigator.userAgent.indexOf("Android") > -1) {
      // starts with a #, so check if the current one has a hash with the same value
      if (currentHref.indexOf('#') > -1) {
        var file = currentHref.substr(0, currentHref.indexOf('#'));
        window.location.href = "/android_asset/www/"+file+ href;
      } else {
        // the current page has no #, so simply attach the href to current url
        window.location = window.location.href += href;
      }
    }
  }
  if (currentHref == href) {
    if (errCallback) {
      errCallback("The passed href is the same as the current");
    } else {
      console.log("The passed href is the same as the current");
    }
    return false;
  }
  return true;
};

NativePageTransitions.install = function () {
  if (!window.plugins) {
    window.plugins = {};
  }

  window.plugins.nativepagetransitions = new NativePageTransitions();
  return window.plugins.nativepagetransitions;
};

cordova.addConstructor(NativePageTransitions.install);