/* Copyright (c) 2011 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

#if GTM_INCLUDE_OAUTH2 || (!GTL_REQUIRE_SERVICE_INCLUDES && !GDATA_REQUIRE_SERVICE_INCLUDES)

#if !TARGET_OS_IPHONE

#ifdef GTL_TARGET_NAMESPACE
  #import "GTLDefines.h"
#endif

#import "GTMOAuth2WindowController.h"
#import "GTMOAuth2SignIn.h"

@interface GTMOAuth2WindowController ()
@property (nonatomic, retain) GTMOAuth2SignIn *signIn;
@property (nonatomic, copy) NSURLRequest *initialRequest;
@property (nonatomic, retain) GTMCookieStorage *cookieStorage;
@property (nonatomic, retain) NSWindow *sheetModalForWindow;

- (void)signInCommonForWindow:(NSWindow *)parentWindowOrNil;
- (void)destroyWindow;
- (void)handlePrematureWindowClose;
- (BOOL)shouldUseKeychain;
- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request;
- (void)signIn:(GTMOAuth2SignIn *)signIn finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)handleCookiesForResponse:(NSURLResponse *)response;
- (NSURLRequest *)addCookiesToRequest:(NSURLRequest *)request;
@end

const char *kKeychainAccountName = "OAuth";

@implementation GTMOAuth2WindowController

// IBOutlets
@synthesize keychainCheckbox = keychainCheckbox_;
@synthesize webView = webView_;
@synthesize webCloseButton = webCloseButton_;
@synthesize webBackButton = webBackButton_;

// regular ivars
@synthesize signIn = signIn_;
@synthesize initialRequest = initialRequest_;
@synthesize cookieStorage = cookieStorage_;
@synthesize sheetModalForWindow = sheetModalForWindow_;
@synthesize keychainItemName = keychainItemName_;
@synthesize initialHTMLString = initialHTMLString_;
@synthesize shouldPersistUser = shouldPersistUser_;
@synthesize userData = userData_;

- (id)initWithScope:(NSString *)scope
           clientID:(NSString *)clientID
       clientSecret:(NSString *)clientSecret
   keychainItemName:(NSString *)keychainItemName
     resourceBundle:(NSBundle *)bundle {
  // convenient entry point for Google authentication

  GTMOAuth2Authentication *auth;
  auth = [GTMOAuth2SignIn standardGoogleAuthenticationForScope:scope
                                                      clientID:clientID
                                                  clientSecret:clientSecret];
  NSURL *authorizationURL = [GTMOAuth2SignIn googleAuthorizationURL];
  return [self initWithAuthentication:auth
                     authorizationURL:authorizationURL
                     keychainItemName:keychainItemName
                       resourceBundle:bundle];
}

- (id)initWithAuthentication:(GTMOAuth2Authentication *)auth
            authorizationURL:(NSURL *)authorizationURL
            keychainItemName:(NSString *)keychainItemName
              resourceBundle:(NSBundle *)bundle {
  if (bundle == nil) {
    bundle = [NSBundle mainBundle];
  }

  NSString *nibName = [[self class] authNibName];
  NSString *nibPath = [bundle pathForResource:nibName
                                       ofType:@"nib"];
  self = [super initWithWindowNibPath:nibPath
                                owner:self];
  if (self != nil) {
    // use the supplied auth and OAuth endpoint URLs
    self.signIn =  [[[GTMOAuth2SignIn alloc] initWithAuthentication:auth
                                                   authorizationURL:authorizationURL
                                                           delegate:self
                                                 webRequestSelector:@selector(signIn:displayRequest:)
                                                   finishedSelector:@selector(signIn:finishedWithAuth:error:)] autorelease];
    
    self.keychainItemName = keychainItemName;

    // create local, temporary storage for WebKit cookies
    self.cookieStorage = [[[GTMCookieStorage alloc] init] autorelease];
  }
  return self;
}

- (void)dealloc {
  self.keychainItemName = nil;
  self.initialHTMLString = nil;
  self.userData = nil;
  self.signIn = nil;
  self.cookieStorage = nil;
  self.initialRequest = nil;

  [delegate_ release];
#if NS_BLOCKS_AVAILABLE
  [completionBlock_ release];
#endif
  [super dealloc];
}

- (void)awakeFromNib {
  // load the requested initial sign-in page
  [self.webView setResourceLoadDelegate:self];

  // the app may prefer some html other than blank white to be displayed
  // before the sign-in web page loads
  NSString *html = self.initialHTMLString;
  if ([html length] > 0) {
    [[self.webView mainFrame] loadHTMLString:html baseURL:nil];
  }

  // hide the keychain checkbox if we're not supporting keychain
  BOOL hideKeychainCheckbox = ![self shouldUseKeychain];

  const NSTimeInterval kJanuary2011 = 1293840000;
  BOOL isDateValid = ([[NSDate date] timeIntervalSince1970] > kJanuary2011);
  if (isDateValid) {
    // start the asynchronous load of the sign-in web page
    [[self.webView mainFrame] performSelector:@selector(loadRequest:)
                                   withObject:self.initialRequest
                                   afterDelay:0.01];
  } else {
    // clock date is invalid, so signing in would fail with an unhelpful error
    // from the server. Warn the user in an html string showing a watch icon,
    // question mark, and the system date and time. Hopefully this will clue
    // in brighter users, or at least let them make a useful screenshot to show
    // to developers.
    //
    // Even better is for apps to check the system clock and show some more
    // helpful, localized instructions for users; this is really a fallback.
    NSString *htmlTemplate = @"<html><body><div align=center><font size='7'>"
      @"&#x231A; ?<br><i>System Clock Incorrect</i><br>%@"
      @"</font></div></body></html>";
    NSString *errHTML = [NSString stringWithFormat:htmlTemplate, [NSDate date]];

    [[webView_ mainFrame] loadHTMLString:errHTML baseURL:nil];
    hideKeychainCheckbox = YES;
  }

  [keychainCheckbox_ setHidden:hideKeychainCheckbox];
}

+ (NSString *)authNibName {
  // subclasses may override this to specify a custom nib name
  return @"GTMOAuth2Window";
}

#pragma mark -

- (void)signInSheetModalForWindow:(NSWindow *)parentWindowOrNil
                         delegate:(id)delegate
                 finishedSelector:(SEL)finishedSelector {
  // check the selector on debug builds
  GTMAssertSelectorNilOrImplementedWithArgs(delegate, finishedSelector,
    @encode(GTMOAuth2WindowController *), @encode(GTMOAuth2Authentication *),
    @encode(NSError *), 0);

  delegate_ = [delegate retain];
  finishedSelector_ = finishedSelector;

  [self signInCommonForWindow:parentWindowOrNil];
}

#if NS_BLOCKS_AVAILABLE
- (void)signInSheetModalForWindow:(NSWindow *)parentWindowOrNil
                completionHandler:(void (^)(GTMOAuth2Authentication *, NSError *))handler {
  completionBlock_ = [handler copy];

  [self signInCommonForWindow:parentWindowOrNil];
}
#endif

- (void)signInCommonForWindow:(NSWindow *)parentWindowOrNil {
  self.sheetModalForWindow = parentWindowOrNil;
  hasDoneFinalRedirect_ = NO;
  hasCalledFinished_ = NO;

  [self.signIn startSigningIn];
}

- (void)cancelSigningIn {
  // The user has explicitly asked us to cancel signing in
  // (so no further callback is required)
  hasCalledFinished_ = YES;

  [delegate_ autorelease];
  delegate_ = nil;

#if NS_BLOCKS_AVAILABLE
  [completionBlock_ autorelease];
  completionBlock_ = nil;
#endif

  // The signIn object's cancel method will close the window
  [self.signIn cancelSigningIn];
  hasDoneFinalRedirect_ = YES;
}

- (IBAction)closeWindow:(id)sender {
  // dismiss the window/sheet before we call back the client
  [self destroyWindow];
  [self handlePrematureWindowClose];
}

#pragma mark SignIn callbacks

- (void)signIn:(GTMOAuth2SignIn *)signIn displayRequest:(NSURLRequest *)request {
  // this is the signIn object's webRequest method, telling the controller
  // to either display the request in the webview, or close the window
  //
  // All web requests and all window closing goes through this routine

#if DEBUG
  if ((isWindowShown_ && request != nil)
      || (!isWindowShown_ && request == nil)) {
    NSLog(@"Window state unexpected for request %@", [request URL]);
    return;
  }
#endif

  if (request != nil) {
    // display the request
    self.initialRequest = request;

    NSWindow *parentWindow = self.sheetModalForWindow;
    if (parentWindow) {
      NSWindow *sheet = [self window];

      [NSApp beginSheet:sheet
         modalForWindow:parentWindow
          modalDelegate:self
         didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
            contextInfo:nil];
    } else {
      // modeless
      [self showWindow:self];
    }
    isWindowShown_ = YES;
  } else {
    // request was nil
    [self destroyWindow];
  }
}

- (void)destroyWindow {
  // no request; close the window (but not immediately, in case
  // we're called in response to some window event)
  NSWindow *parentWindow = self.sheetModalForWindow;
  if (parentWindow) {
    [NSApp endSheet:[self window]];
  } else {
    [[self window] performSelector:@selector(close)
                        withObject:nil
                        afterDelay:0.1];
  }
  isWindowShown_ = NO;
}

- (void)handlePrematureWindowClose {
  if (!hasDoneFinalRedirect_) {
    // tell the sign-in object to tell the user's finished method
    // that we're done
    [self.signIn windowWasClosed];
    hasDoneFinalRedirect_ = YES;
  }
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
  [sheet orderOut:self];

  self.sheetModalForWindow = nil;
}

- (void)signIn:(GTMOAuth2SignIn *)signIn finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error {
  if (!hasCalledFinished_) {
    hasCalledFinished_ = YES;

    if (error == nil) {
      BOOL shouldUseKeychain = [self shouldUseKeychain];
      if (shouldUseKeychain) {
        BOOL canAuthorize = auth.canAuthorize;
        BOOL isKeychainChecked = ([keychainCheckbox_ state] == NSOnState);

        NSString *keychainItemName = self.keychainItemName;

        if (isKeychainChecked && canAuthorize) {
          // save the auth params in the keychain
          [[self class] saveAuthToKeychainForName:keychainItemName
                                            authentication:auth];
        } else {
          // remove the auth params from the keychain
          [[self class] removeAuthFromKeychainForName:keychainItemName];
        }
      }
    }

    if (delegate_ && finishedSelector_) {
      SEL sel = finishedSelector_;
      NSMethodSignature *sig = [delegate_ methodSignatureForSelector:sel];
      NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
      [invocation setSelector:sel];
      [invocation setTarget:delegate_];
      [invocation setArgument:&self atIndex:2];
      [invocation setArgument:&auth atIndex:3];
      [invocation setArgument:&error atIndex:4];
      [invocation invoke];
    }

    [delegate_ autorelease];
    delegate_ = nil;

#if NS_BLOCKS_AVAILABLE
    if (completionBlock_) {
      completionBlock_(auth, error);

      // release the block here to avoid a retain loop on the controller
      [completionBlock_ autorelease];
      completionBlock_ = nil;
    }
#endif
  }
}

#pragma mark Token Revocation

+ (void)revokeTokenForGoogleAuthentication:(GTMOAuth2Authentication *)auth {
  [GTMOAuth2SignIn revokeTokenForGoogleAuthentication:auth];
}

#pragma mark WebView methods

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource {
  // override WebKit's cookie storage with our own to avoid cookie persistence
  // across sign-ins and interaction with the Safari browser's sign-in state
  [self handleCookiesForResponse:redirectResponse];
  request = [self addCookiesToRequest:request];

  if (!hasDoneFinalRedirect_) {
    hasDoneFinalRedirect_ = [self.signIn requestRedirectedToRequest:request];
    if (hasDoneFinalRedirect_) {
      // signIn has told the window to close
      return nil;
    }
  }
  return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource {
  // override WebKit's cookie storage with our own
  [self handleCookiesForResponse:response];
}

- (void)webView:(WebView *)sender resource:(id)identifier didFinishLoadingFromDataSource:(WebDataSource *)dataSource {
  NSString *title = [sender stringByEvaluatingJavaScriptFromString:@"document.title"];
  if ([title length] > 0) {
    [self.signIn titleChanged:title];
  }
}

- (void)windowWillClose:(NSNotification *)note {
  [self handlePrematureWindowClose];
}

#pragma mark Cookie management

// Rather than let the WebView use Safari's default cookie storage, we intercept
// requests and response to segregate and later discard cookies from signing in.
//
// This allows the application to actually sign out by discarding the auth token
// rather than the user being kept signed in by the cookies.

- (void)handleCookiesForResponse:(NSURLResponse *)response {
  if (self.shouldPersistUser) {
    // we'll let WebKit handle the cookies; they'll persist across apps
    // and across runs of this app
    return;
  }

  if ([response respondsToSelector:@selector(allHeaderFields)]) {
    // grab the cookies from the header as NSHTTPCookies and store them locally
    NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
    if (headers) {
      NSURL *url = [response URL];
      NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:headers
                                                                forURL:url];
      if ([cookies count] > 0) {
        [cookieStorage_ setCookies:cookies];
      }
    }
  }
}

- (NSURLRequest *)addCookiesToRequest:(NSURLRequest *)request {
  if (self.shouldPersistUser) {
    // we'll let WebKit handle the cookies; they'll persist across apps
    // and across runs of this app
    return request;
  }

  // override WebKit's usual automatic storage of cookies
  NSMutableURLRequest *mutableRequest = [[request mutableCopy] autorelease];
  [mutableRequest setHTTPShouldHandleCookies:NO];

  // add our locally-stored cookies for this URL, if any
  NSArray *cookies = [cookieStorage_ cookiesForURL:[request URL]];
  if ([cookies count] > 0) {
    NSDictionary *headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    NSString *cookieHeader = [headers objectForKey:@"Cookie"];
    if (cookieHeader) {
      [mutableRequest setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
    }
  }
  return mutableRequest;
}

#pragma mark Keychain support

+ (NSString *)prefsKeyForName:(NSString *)keychainItemName {
  NSString *result = [@"OAuth2: " stringByAppendingString:keychainItemName];
  return result;
}

+ (BOOL)saveAuthToKeychainForName:(NSString *)keychainItemName
                            authentication:(GTMOAuth2Authentication *)auth {

  [self removeAuthFromKeychainForName:keychainItemName];

  // don't save unless we have a token that can really authorize requests
  if (!auth.canAuthorize) return NO;

  // make a response string containing the values we want to save
  NSString *password = [auth persistenceResponseString];

  SecKeychainRef defaultKeychain = NULL;
  SecKeychainItemRef *dontWantItemRef= NULL;
  const char *utf8ServiceName = [keychainItemName UTF8String];
  const char *utf8Password = [password UTF8String];

  OSStatus err = SecKeychainAddGenericPassword(defaultKeychain,
                               strlen(utf8ServiceName), utf8ServiceName,
                               strlen(kKeychainAccountName), kKeychainAccountName,
                               strlen(utf8Password), utf8Password,
                               dontWantItemRef);
  BOOL didSucceed = (err == noErr);
  if (didSucceed) {
    // write to preferences that we have a keychain item (so we know later
    // that we can read from the keychain without raising a permissions dialog)
    NSString *prefKey = [self prefsKeyForName:keychainItemName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:prefKey];
  }

  return didSucceed;
}

+ (BOOL)removeAuthFromKeychainForName:(NSString *)keychainItemName {

  SecKeychainRef defaultKeychain = NULL;
  SecKeychainItemRef itemRef = NULL;
  const char *utf8ServiceName = [keychainItemName UTF8String];

  // we don't really care about the password here, we just want to
  // get the SecKeychainItemRef so we can delete it.
  OSStatus err = SecKeychainFindGenericPassword (defaultKeychain,
                                       strlen(utf8ServiceName), utf8ServiceName,
                                       strlen(kKeychainAccountName), kKeychainAccountName,
                                       0, NULL, // ignore password
                                       &itemRef);
  if (err != noErr) {
    // failure to find is success
    return YES;
  } else {
    // found something, so delete it
    err = SecKeychainItemDelete(itemRef);
    CFRelease(itemRef);

    // remove our preference key
    NSString *prefKey = [self prefsKeyForName:keychainItemName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:prefKey];

    return (err == noErr);
  }
}

+ (GTMOAuth2Authentication *)authForGoogleFromKeychainForName:(NSString *)keychainItemName
                                                     clientID:(NSString *)clientID
                                                 clientSecret:(NSString *)clientSecret {
  NSURL *tokenURL = [GTMOAuth2SignIn googleTokenURL];
  NSString *redirectURI = [GTMOAuth2SignIn googleRedirectURI];

  GTMOAuth2Authentication *auth;
  auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kGTMOAuth2ServiceProviderGoogle
                                                           tokenURL:tokenURL
                                                        redirectURI:redirectURI
                                                           clientID:clientID
                                                       clientSecret:clientSecret];
  
  [GTMOAuth2WindowController authorizeFromKeychainForName:keychainItemName
                                           authentication:auth];
  return auth;
}

+ (BOOL)authorizeFromKeychainForName:(NSString *)keychainItemName
                      authentication:(GTMOAuth2Authentication *)newAuth {
  [newAuth setAccessToken:nil];

  // before accessing the keychain, check preferences to verify that we've
  // previously saved a token to the keychain (so we don't needlessly raise
  // a keychain access permission dialog)
  NSString *prefKey = [self prefsKeyForName:keychainItemName];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  BOOL flag = [defaults boolForKey:prefKey];
  if (!flag) {
    return NO;
  }

  BOOL didGetTokens = NO;

  SecKeychainRef defaultKeychain = NULL;
  const char *utf8ServiceName = [keychainItemName UTF8String];
  SecKeychainItemRef *dontWantItemRef = NULL;

  void *passwordBuff = NULL;
  UInt32 passwordBuffLength = 0;

  OSStatus err = SecKeychainFindGenericPassword(defaultKeychain,
                                      strlen(utf8ServiceName), utf8ServiceName,
                                      strlen(kKeychainAccountName), kKeychainAccountName,
                                      &passwordBuffLength, &passwordBuff,
                                      dontWantItemRef);
  if (err == noErr && passwordBuff != NULL) {

    NSString *password = [[[NSString alloc] initWithBytes:passwordBuff
                                                   length:passwordBuffLength
                                                 encoding:NSUTF8StringEncoding] autorelease];

    // free the password buffer that was allocated above
    SecKeychainItemFreeContent(NULL, passwordBuff);

    if (password != nil) {
      [newAuth setKeysForResponseString:password];
      didGetTokens = YES;
    }
  }
  return didGetTokens;
}

#pragma mark Accessors

- (GTMOAuth2Authentication *)authentication {
  return self.signIn.authentication; 
}

- (void)setNetworkLossTimeoutInterval:(NSTimeInterval)val {
  self.signIn.networkLossTimeoutInterval = val;
}

- (NSTimeInterval)networkLossTimeoutInterval {
  return self.signIn.networkLossTimeoutInterval;
}

- (BOOL)shouldUseKeychain {
  NSString *name = self.keychainItemName;
  return ([name length] > 0);
}

@end

#endif // #if !TARGET_OS_IPHONE

#endif // #if GTM_INCLUDE_OAUTH2 || (!GTL_REQUIRE_SERVICE_INCLUDES && !GDATA_REQUIRE_SERVICE_INCLUDES)
