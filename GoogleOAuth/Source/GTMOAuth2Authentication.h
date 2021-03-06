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

#if GTM_INCLUDE_OAUTH2 || (!GTL_REQUIRE_SERVICE_INCLUDES && !GDATA_REQUIRE_SERVICE_INCLUDES)

// This class implements the OAuth 2 protocol for authorizing requests.
// http://tools.ietf.org/html/draft-ietf-oauth-v2

#import <Foundation/Foundation.h>

#ifdef GTL_TARGET_NAMESPACE
  #import "GTLDefines.h"
#endif

#import "GTMHTTPFetcher.h"

#undef _EXTERN
#undef _INITIALIZE_AS
#ifdef GTMOAUTH2AUTHENTICATION_DEFINE_GLOBALS
  #define _EXTERN
  #define _INITIALIZE_AS(x) =x
#else
  #if defined(__cplusplus)
    #define _EXTERN extern "C"
  #else
    #define _EXTERN extern
  #endif
  #define _INITIALIZE_AS(x)
#endif

// Service provider name allows stored authorization to be associated with
// the authorizing service
_EXTERN NSString* const kGTMOAuth2ServiceProviderGoogle _INITIALIZE_AS(@"Google");

//
// GTMOAuth2SignIn constants, included here for use by clients
//
_EXTERN NSString* const kGTMOAuth2ErrorDomain  _INITIALIZE_AS(@"com.google.GTMOAuth2");

// Error userInfo keys
_EXTERN NSString* const kGTMOAuth2ErrorMessageKey _INITIALIZE_AS(@"error");
_EXTERN NSString* const kGTMOAuth2ErrorRequestKey _INITIALIZE_AS(@"request");
_EXTERN NSString* const kGTMOAuth2ErrorJSONKey    _INITIALIZE_AS(@"json");

enum {
  // Error code indicating that the window was prematurely closed
  kGTMOAuth2ErrorWindowClosed        = -1000,
  kGTMOAuth2ErrorAuthorizationFailed = -1001,
  kGTMOAuth2ErrorTokenExpired        = -1002,
  kGTMOAuth2ErrorTokenUnavailable    = -1003
};


// Notifications for token fetches
_EXTERN NSString* const kGTMOAuth2FetchStarted        _INITIALIZE_AS(@"kGTMOAuth2FetchStarted");
_EXTERN NSString* const kGTMOAuth2FetchStopped        _INITIALIZE_AS(@"kGTMOAuth2FetchStopped");

_EXTERN NSString* const kGTMOAuth2FetcherKey          _INITIALIZE_AS(@"fetcher");
_EXTERN NSString* const kGTMOAuth2FetchTypeKey        _INITIALIZE_AS(@"FetchType");
_EXTERN NSString* const kGTMOAuth2FetchTypeToken      _INITIALIZE_AS(@"token");
_EXTERN NSString* const kGTMOAuth2FetchTypeRefresh    _INITIALIZE_AS(@"refresh");
_EXTERN NSString* const kGTMOAuth2FetchTypeUserInfo   _INITIALIZE_AS(@"userInfo");

// Token-issuance errors
_EXTERN NSString* const kGTMOAuth2ErrorKey                  _INITIALIZE_AS(@"error");

_EXTERN NSString* const kGTMOAuth2ErrorInvalidRequest       _INITIALIZE_AS(@"invalid_request");
_EXTERN NSString* const kGTMOAuth2ErrorInvalidClient        _INITIALIZE_AS(@"invalid_client");
_EXTERN NSString* const kGTMOAuth2ErrorInvalidGrant         _INITIALIZE_AS(@"invalid_grant");
_EXTERN NSString* const kGTMOAuth2ErrorUnauthorizedClient   _INITIALIZE_AS(@"unauthorized_client");
_EXTERN NSString* const kGTMOAuth2ErrorUnsupportedGrantType _INITIALIZE_AS(@"unsupported_grant_type");
_EXTERN NSString* const kGTMOAuth2ErrorInvalidScope         _INITIALIZE_AS(@"invalid_scope");

// Notification for token changes
_EXTERN NSString* const kGTMOAuth2RefreshTokenChanged _INITIALIZE_AS(@"kGTMOAuth2RefreshTokenChanged");

// Notification for network loss during html sign-in display
_EXTERN NSString* const kGTMOAuth2NetworkLost         _INITIALIZE_AS(@"kGTMOAuthNetworkLost");
_EXTERN NSString* const kGTMOAuth2NetworkFound        _INITIALIZE_AS(@"kGTMOAuthNetworkFound");

@interface GTMOAuth2Authentication : NSObject <GTMFetcherAuthorizationProtocol>  {
 @private
  NSString *clientID_;
  NSString *clientSecret_;
  NSString *redirectURI_;
  NSMutableDictionary *parameters_;

  // authorization parameters
  NSURL *tokenURL_;
  NSDate *expirationDate_;

  // queue of requests for authorization waiting for a valid access token
  GTMHTTPFetcher *refreshFetcher_;
  NSMutableArray *authorizationQueue_;

  Class parserClass_;

  // arbitrary data retained for the user
  id userData_;
  NSMutableDictionary *properties_;
}

// OAuth2 standard protocol parameters

// Request properties
@property (copy) NSString *clientID;
@property (copy) NSString *clientSecret;
@property (copy) NSString *redirectURI;
@property (copy) NSString *scope;
@property (copy) NSString *tokenType;

// Response properties
@property (retain) NSMutableDictionary *parameters;

@property (retain) NSString *accessToken;
@property (retain) NSString *refreshToken;
@property (retain) NSNumber *expiresIn;
@property (retain) NSString *code;
@property (retain) NSString *errorString;

// URL for obtaining access tokens
@property (copy) NSURL *tokenURL;

// Calculated expiration date (expiresIn seconds added to the
// time the access token was received.)
@property (copy) NSDate *expirationDate;

// Service identifier, like "Google"; not used for authentication
//
// The provider name is just for allowing stored authorization to be associated
// with the authorizing service.
@property (copy) NSString *serviceProvider;

// User email and verified status; not used for authentication
//
// The verified string can be checked with -boolValue. If the result is false,
// then the email address is listed with the account on the server, but the
// address has not been confirmed as belonging to the owner of the account.
@property (retain) NSString *userEmail;
@property (retain) NSString *userEmailIsVerified;

// Property indicating if this auth has a refresh token so is suitable for
// authorizing a request. This does not guarantee that the token is valid.
@property (readonly) BOOL canAuthorize;

// userData is retained for the convenience of the caller
@property (retain) id userData;

// Stored property values are retained for the convenience of the caller
@property (retain) NSDictionary *properties;

// Alternative JSON parsing class; this should implement the
// GTMOAuth2ParserClass informal protocol. If this property is
// not set, the class SBJSON must be available in the runtime.
@property (assign) Class parserClass;

// Convenience method for creating an authentication object
+ (id)authenticationWithServiceProvider:(NSString *)serviceProvider
                               tokenURL:(NSURL *)tokenURL
                            redirectURI:(NSString *)redirectURI
                               clientID:(NSString *)clientID
                           clientSecret:(NSString *)clientSecret;

// Clear out any authentication values, prepare for a new request fetch
- (void)reset;

// Main authorization entry points
//
// These will refresh the access token, if necessary, add the access token to
// the request, then invoke the callback.
//
// The request argument may be nil to just force a refresh of the access token,
// if needed.

// The finish selector should have a signature matching
//   - (void)authentication:(GTMOAuth2Authentication *)auth
//                  request:(NSMutableURLRequest *)request
//        finishedWithError:(NSError *)error;

- (void)authorizeRequest:(NSMutableURLRequest *)request
                delegate:(id)delegate
       didFinishSelector:(SEL)sel;

#if NS_BLOCKS_AVAILABLE
- (void)authorizeRequest:(NSMutableURLRequest *)request
       completionHandler:(void (^)(NSError *error))handler;
#endif

// Synchronous entry point; authorizing this way cannot refresh an expired
// access token
- (BOOL)authorizeRequest:(NSMutableURLRequest *)request;


//////////////////////////////////////////////////////////////////////////////
//
// Internal properties and methods for use by GTMOAuth2SignIn
//

// Pending fetcher to get a new access token, if any
@property (retain) GTMHTTPFetcher *refreshFetcher;

// Check if a request appears to be authorized
- (BOOL)isAuthorizedRequest:(NSURLRequest *)request;

// Stop any pending refresh fetch
- (void)stopAuthorization;

// OAuth fetch user-agent header value
- (NSString *)userAgent;

// Parse and set token and token secret from response data
- (void)setKeysForResponseData:(NSData *)data;
- (void)setKeysForResponseString:(NSString *)str;
- (void)setKeysForResponseDictionary:(NSDictionary *)dict;

// Persistent token string for keychain storage
//
// We'll use the format "refresh_token=foo&serviceProvider=bar" so we can
// easily alter what portions of the auth data are stored
- (NSString *)persistenceResponseString;
- (void)setKeysForPersistenceResponseString:(NSString *)str;

// method to begin fetching an access token, used by the sign-in object
- (GTMHTTPFetcher *)beginTokenFetchWithDelegate:(id)delegate
                              didFinishSelector:(SEL)finishedSel;

// Entry point to post a notification about a fetcher currently used for
// obtaining or refreshing a token; the sign-in object will also use this
// to indicate when the user's email address is being fetched.
//
// Fetch type constants are above under "notifications for token fetches"
- (void)notifyFetchIsRunning:(BOOL)isStarting
                     fetcher:(GTMHTTPFetcher *)fetcher
                        type:(NSString *)fetchType;

// Arbitrary key-value properties retained for the user
- (void)setProperty:(id)obj forKey:(NSString *)key;
- (id)propertyForKey:(NSString *)key;

//
// Utilities
//

+ (NSString *)encodedOAuthValueForString:(NSString *)str;

+ (NSString *)encodedQueryParametersForDictionary:(NSDictionary *)dict;

+ (NSDictionary *)dictionaryWithResponseString:(NSString *)responseStr;

+ (NSString *)scopeWithStrings:(NSString *)firsStr, ... NS_REQUIRES_NIL_TERMINATION;
@end

#endif // GTM_INCLUDE_OAUTH2 || (!GTL_REQUIRE_SERVICE_INCLUDES && !GDATA_REQUIRE_SERVICE_INCLUDES)
