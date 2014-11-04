#import "NativePageTransitions.h"

@implementation NativePageTransitions

#define IS_RETINA_DISPLAY() [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2.0f
#define DISPLAY_SCALE IS_RETINA_DISPLAY() ? 2.0f : 1.0f

- (CDVPlugin*) initWithWebView:(UIWebView*)theWebView {
  self = [super initWithWebView:theWebView];
  CGRect screenBound = [[UIScreen mainScreen] bounds];
  _width = screenBound.size.width;
  _height = screenBound.size.height;
  // webview height may differ from screen height because of a statusbar
  _nonWebViewHeight = (_height - self.webView.frame.size.height);
  return self;
}

- (void) slide:(CDVInvokedUrlCommand*)command {
  _command = command;
  NSMutableDictionary *args = [command.arguments objectAtIndex:0];
  NSString *direction = [args objectForKey:@"direction"];
  NSTimeInterval duration = [[args objectForKey:@"duration"] doubleValue];
  NSTimeInterval delay = [[args objectForKey:@"iosdelay"] doubleValue];
  NSString *href = [args objectForKey:@"href"];
  NSNumber *slowdownfactor = [args objectForKey:@"slowdownfactor"];
  
  self.viewController.view.backgroundColor = [UIColor blackColor];
  self.webView.layer.shadowOpacity = 0;
  
  // duration/delay is passed in ms, but needs to be in sec here
  duration = duration / 1000;
  delay = delay / 1000;
  CGFloat lowerLayerAlpha = 0.4f; // TODO consider passing in
  
//  CGFloat totalHeight = self.viewController.view.frame.size.height;
  CGFloat width = self.viewController.view.frame.size.width;
  CGFloat height = self.viewController.view.frame.size.height;

  CGFloat transitionToX = 0;
  CGFloat transitionToY = 0;
  CGFloat webviewFromY = _nonWebViewHeight;
  CGFloat webviewToY = _nonWebViewHeight;
  int screenshotSlowdownFactor = 1;
  int webviewSlowdownFactor = 1;

  if ([direction isEqualToString:@"left"]) {
    transitionToX = -width;
    screenshotSlowdownFactor = [slowdownfactor intValue];
  } else if ([direction isEqualToString:@"right"]) {
    transitionToX = width;
    webviewSlowdownFactor = [slowdownfactor intValue];
  } else if ([direction isEqualToString:@"up"]) {
    screenshotSlowdownFactor = [slowdownfactor intValue];
    transitionToY = (-height/screenshotSlowdownFactor)+_nonWebViewHeight;
    webviewToY = _nonWebViewHeight;
    webviewFromY = height/webviewSlowdownFactor;
  } else if ([direction isEqualToString:@"down"]) {
    transitionToY = (height/screenshotSlowdownFactor)+_nonWebViewHeight;
    webviewSlowdownFactor = [slowdownfactor intValue];
    webviewFromY = (-height/webviewSlowdownFactor)+_nonWebViewHeight;
  }
  
  CGSize viewSize = self.viewController.view.bounds.size;
  
  UIGraphicsBeginImageContextWithOptions(viewSize, YES, 0.0);
  [self.viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  // Read the UIImage object
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  _screenShotImageView = [[UIImageView alloc]initWithFrame:[self.viewController.view.window frame]];
  [_screenShotImageView setImage:image];
  
  // in case of a statusbar above the webview, crop off the top
  // TODO this can also be used for not scrolling fixed headers and footers
  if (_nonWebViewHeight > 0 && [direction isEqualToString:@"down"]) {
    CGFloat retinaFactor = DISPLAY_SCALE;
    CGRect rect = CGRectMake(0.0, _nonWebViewHeight*retinaFactor, image.size.width*retinaFactor, (image.size.height-_nonWebViewHeight)*retinaFactor);
    CGRect rect2 = CGRectMake(0.0, _nonWebViewHeight, image.size.width, image.size.height-_nonWebViewHeight);
    CGImageRef tempImage = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:tempImage];
    _screenShotImageView = [[UIImageView alloc]initWithFrame:rect2];
    [_screenShotImageView setImage:newImage];
    CGImageRelease(tempImage);
  }

  if ([direction isEqualToString:@"left"] || [direction isEqualToString:@"up"]) {
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject insertSubview:_screenShotImageView belowSubview:self.webView];
  } else {
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject insertSubview:_screenShotImageView aboveSubview:self.webView];
  }
  
  if ([self loadHrefIfPassed:href]) {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut // TODO: allow passing in?
                     animations:^{
                       [_screenShotImageView setFrame:CGRectMake(transitionToX/screenshotSlowdownFactor, transitionToY, width, height)];
                     }
                     completion:^(BOOL finished) {
                       [_screenShotImageView removeFromSuperview];
                       CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                       [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                     }];
    
    // also, fade out the screenshot a bit to give it some depth
    if ([slowdownfactor intValue] != 1 && ([direction isEqualToString:@"left"] || [direction isEqualToString:@"up"])) {
      [UIView animateWithDuration:duration
                            delay:delay
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         _screenShotImageView.alpha = lowerLayerAlpha;
                       }
                       completion:^(BOOL finished) {
                       }];
    }
    
    [self.webView setFrame:CGRectMake(-transitionToX/webviewSlowdownFactor, webviewFromY, width, height)];
    
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                       [self.webView setFrame:CGRectMake(0, webviewToY, width, height)];
                     }
                     completion:^(BOOL finished) {
                     }];
    
    if ([slowdownfactor intValue] != 1 && ([direction isEqualToString:@"right"] || [direction isEqualToString:@"down"])) {
      self.webView.alpha = lowerLayerAlpha;
      [UIView animateWithDuration:duration
                            delay:delay
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         self.webView.alpha = 1.0;
                       }
                       completion:^(BOOL finished) {
                       }];
    }
  }
}

- (void) drawer:(CDVInvokedUrlCommand*)command {
  _command = command;
  NSMutableDictionary *args = [command.arguments objectAtIndex:0];
  NSString *action = [args objectForKey:@"action"];
  NSString *origin = [args objectForKey:@"origin"];
  NSTimeInterval duration = [[args objectForKey:@"duration"] doubleValue];
  NSTimeInterval delay = [[args objectForKey:@"iosdelay"] doubleValue];
  NSString *href = [args objectForKey:@"href"];
  
  // duration/delay is passed in ms, but needs to be in sec here
  duration = duration / 1000;
  delay = delay / 1000;
  
  CGFloat width = self.viewController.view.frame.size.width;
  CGFloat height = self.viewController.view.frame.size.height;
  
  CGFloat transitionToX = 0;
  CGFloat webviewTransitionFromX = 0;
  int screenshotPx = 44;
  
  if ([action isEqualToString:@"open"]) {
    if ([origin isEqualToString:@"right"]) {
      transitionToX = -width+screenshotPx;
    } else {
      transitionToX = width-screenshotPx;
    }
  } else if ([action isEqualToString:@"close"]) {
    if ([origin isEqualToString:@"right"]) {
      transitionToX = screenshotPx;
      webviewTransitionFromX = -width+screenshotPx;
    } else {
      transitionToX = -width+screenshotPx;
      webviewTransitionFromX = width-screenshotPx;
    }
  }
  
  CGSize viewSize = self.viewController.view.bounds.size;
  UIGraphicsBeginImageContextWithOptions(viewSize, YES, 0.0);
  [self.viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  // Read the UIImage object
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  [_screenShotImageView setFrame:CGRectMake(0, 0, width, height)];
  if ([action isEqualToString:@"open"]) {
    _screenShotImageView = [[UIImageView alloc]initWithFrame:[self.viewController.view.window frame]];
    // add a cool shadow
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_screenShotImageView.bounds];
    _screenShotImageView.layer.masksToBounds = NO;
    _screenShotImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _screenShotImageView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    _screenShotImageView.layer.shadowOpacity = 0.5f;
    _screenShotImageView.layer.shadowPath = shadowPath.CGPath;
  }
  [_screenShotImageView setImage:image];
  if ([action isEqualToString:@"open"]) {
    [UIApplication.sharedApplication.keyWindow.subviews.lastObject insertSubview:_screenShotImageView aboveSubview:self.webView];
  } else {
    // add a cool shadow here as well
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.webView.bounds];
    self.webView.layer.masksToBounds = NO;
    self.webView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.webView.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    self.webView.layer.shadowOpacity = 0.5f;
    self.webView.layer.shadowPath = shadowPath.CGPath;
  }
  
  if ([self loadHrefIfPassed:href]) {
    if ([action isEqualToString:@"open"]) {
      [UIView animateWithDuration:duration
                            delay:delay
                          options:UIViewAnimationOptionCurveEaseInOut // TODO: allow passing in?
                       animations:^{
                         [_screenShotImageView setFrame:CGRectMake(transitionToX, 0, width, height)];
                       }
                       completion:^(BOOL finished) {
                         if ([action isEqualToString:@"close"]) {
                           _screenShotImageView = nil;
                           // [_screenShotImageView removeFromSuperview];
                         }
                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                       }];
    }
    
    if ([action isEqualToString:@"close"]) {
      [self.webView setFrame:CGRectMake(webviewTransitionFromX, _nonWebViewHeight, width, height)];
      
      // position thw webview above the screenshot just after the animation kicks in so no flash of the webview occurs
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay+50 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [UIApplication.sharedApplication.keyWindow.subviews.lastObject bringSubviewToFront:self.webView];
      });
      
      [UIView animateWithDuration:duration
                            delay:delay
                          options:UIViewAnimationOptionCurveEaseInOut
                       animations:^{
                         [self.webView setFrame:CGRectMake(0, _nonWebViewHeight, width, height)];
                       }
                       completion:^(BOOL finished) {
                         [_screenShotImageView removeFromSuperview];
                         CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                         [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                       }];
    }
  }
}

- (void) flip:(CDVInvokedUrlCommand*)command {
  _command = command;
  NSMutableDictionary *args = [command.arguments objectAtIndex:0];
  NSString *direction = [args objectForKey:@"direction"];
  NSTimeInterval duration = [[args objectForKey:@"duration"] doubleValue];
  NSTimeInterval delay = [[args objectForKey:@"iosdelay"] doubleValue];
  NSString *href = [args objectForKey:@"href"];
  
  // duration is passed in ms, but needs to be in sec here
  duration = duration / 1000;
  
  // overlay the webview with a screenshot to prevent the user from seeing changes in the webview before the flip kicks in
  CGSize viewSize = self.viewController.view.bounds.size;
  
  UIGraphicsBeginImageContextWithOptions(viewSize, YES, 0.0);
  [self.viewController.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  
  // Read the UIImage object
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  CGFloat width = self.viewController.view.frame.size.width;
  CGFloat height = self.viewController.view.frame.size.height;
  [_screenShotImageView setFrame:CGRectMake(0, 0, width, height)];
  
  _screenShotImageView = [[UIImageView alloc]initWithFrame:[self.viewController.view.window frame]];
  [_screenShotImageView setImage:image];
  [UIApplication.sharedApplication.keyWindow.subviews.lastObject insertSubview:_screenShotImageView aboveSubview:self.webView];
  
  UIViewAnimationOptions animationOptions;
  if ([direction isEqualToString:@"right"]) {
    animationOptions = UIViewAnimationOptionTransitionFlipFromLeft;
  } else if ([direction isEqualToString:@"left"]) {
    animationOptions = UIViewAnimationOptionTransitionFlipFromRight;
  } else if ([direction isEqualToString:@"up"]) {
    animationOptions = UIViewAnimationOptionTransitionFlipFromTop;
  } else if ([direction isEqualToString:@"down"]) {
    animationOptions = UIViewAnimationOptionTransitionFlipFromBottom;
  } else {
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"direction should be one of up|down|left|right"];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    return;
  }
  
  if ([self loadHrefIfPassed:href]) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
      // remove the screenshot halfway during the transition
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (duration/2) * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        [_screenShotImageView removeFromSuperview];
      });
      [UIView transitionWithView:self.viewController.view
                        duration:duration
                         options:animationOptions | UIViewAnimationOptionAllowAnimatedContent
                      animations:^{}
                      completion:^(BOOL finished) {
                        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
                      }];
    });
  }
}

- (BOOL) loadHrefIfPassed:(NSString*) href {
  if (href != [NSNull null]) {
    if (![href hasPrefix:@"#"] && [href rangeOfString:@".html"].location != NSNotFound) {
      // strip any params when looking for the file on the filesystem
      NSString *bareFileName = href;
      NSString *urlParams = nil;
      
      if (![bareFileName hasSuffix:@".html"]) {
        NSRange range = [href rangeOfString:@".html"];
        bareFileName = [href substringToIndex:range.location+5];
        urlParams = [href substringFromIndex:range.location+5];
      }
      NSString *filePath = [self.commandDelegate pathForResource:bareFileName];
      if (filePath == nil) {
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"file not found"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
        return NO;
      }
      
      NSURL *url = [NSURL fileURLWithPath: filePath];
      // re-attach the params when loading the url
      if (urlParams != nil) {
        NSString *absoluteURLString = [url absoluteString];
        NSString *absoluteURLWithParams = [absoluteURLString stringByAppendingString: urlParams];
        url = [NSURL URLWithString:absoluteURLWithParams];
      }
      
      [self.webView loadRequest: [NSURLRequest requestWithURL:url]];
    } else if (![href hasPrefix:@"#"]) {
      CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"href must be null, a .html file or a #navigationhash"];
      [self.commandDelegate sendPluginResult:pluginResult callbackId:_command.callbackId];
      return NO;
    } else {
      // it's a hash, so load the url without any possible current hash
      NSString *url = self.webView.request.URL.absoluteString;
      // attach the hash
      url = [url stringByAppendingString:href];
      // and load it
      [self.webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    }
  }
  return YES;
}
@end
