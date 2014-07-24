// MMRSession.h
//
// Copyright (c) 2014 Anton Grachev
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MMRSessionLoginBehavior) {
    MMRSessionLoginWithCachedToken,
    MMRSessionLoginInAppWebView,
    MMRSessionLoginInAppLoginAndPasswordView,
    MMRSessionLoginInSafari,
};

@class MMRSession;
typedef void (^MMRSessionOpenHandler)(MMRSession *session, NSError *error);
typedef void (^MMRSessionRefreshTokenHandler)(NSError *error);

@interface MMRSession : NSObject

@property (readonly, copy, nonatomic) NSString *accessToken;
@property (readonly, copy, nonatomic) NSString *refreshToken;
@property (readonly, copy, nonatomic) NSDate *expirationDate;
@property (readonly, copy, nonatomic) NSString *userId;
@property (readonly, copy, nonatomic) NSArray *permissions;
@property (readonly, nonatomic) BOOL isValid;

+ (void)openSessionWithPermissions:(NSArray *)permissions
                     loginBehavior:(MMRSessionLoginBehavior)behavior
                completionsHandler:(MMRSessionOpenHandler)handler;

+ (void)openSessionForUsername:(NSString *)username
                      password:(NSString *)password
                   permissions:(NSArray *)permissions
            completionsHandler:(MMRSessionOpenHandler)handler;

+ (void)openSessionWithAccessToken:(NSString *)accessToken
                      refreshToken:(NSString *)refreshToken
                            userId:(NSString *)userId
                       permissions:(NSArray *)permissions
                    expirationDate:(NSDate *)expirationDate
                completionsHandler:(MMRSessionOpenHandler)handler;

+ (MMRSession *)currentSession;

+ (void)setRedirectURI:(NSString *)redirectURI;
+ (NSString *)redirectURI;

- (void)refreshTokenWithCompletionHandler:(MMRSessionRefreshTokenHandler)handler;
- (void)close;
- (void)closeAndClearTokenInformation;

- (BOOL)handleOpenURL:(NSURL *)url;

@end
