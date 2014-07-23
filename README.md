MyMailRu SDK for iOS
==========

iOS library for working with my.mail.ru REST API. You can use it for authentication in this social network and all others API methods. See REST API methods descriptions [here](http://api.mail.ru/docs/) for details.

### Installation

Drag and drop all sources from MyMailRuSDK directory into your project (MyMailRuSDK.xcodeproj not required).

Link your project with the following frameworks:

- UIKit.framework
- CommonCrypto.framework

Another way is to open MyMailRuSDK.xcodeproj and built a framework with 'MyMailRuSDK Framework' target. Framework will be created in root directory of repo.

MyMailRu SDK requires iOS 5+ and built with ARC.

### Code Snippets

Configuration on application start:

```Objective-C
[MyMailRu setAppId:@"123456"];
[MyMailRu setAppPrivateKey:@"1q2345ereygennvfe"];
```

Open session without user interaction (with cached tokens):

```Objective-C
[MMRSession openSessionWithPermissions:@[@"stream"] // or any others permissions that your app need
                             loginBehavior:MMRSessionLoginWithCachedToken
                        completionsHandler:^(MMRSession *session, NSError *error) {
                            if (error) {
                                result = [error localizedDescription];
                            } else {
                                result = @"Session open successfully";
                            }
                             NSLog(@"%@", result);
                        }];
```

Open session with login view in your application: 

```Objective-C
if (![MMRSession currentSession].isValid) {
        [MMRSession openSessionWithPermissions:[self applicationPermissions]
                                 loginBehavior:MMRSessionLoginInApp
                            completionsHandler:^(MMRSession *session, NSError *error) {
                                NSString *result = nil;
                                if (error) {
                                    result = [error localizedDescription];
                                } else {
                                    result = @"Success";
                                }
                                NSLog(@"%@", result);
        }];
}
```

Get current user info:

```Objective-C
MMRRequest *request = [MMRRequest requestForUsersInfoWithParams:@{@"uids" : [MMRSession currentSession].userId}];
[request sendWithCompletionHandler:^(id json, NSError *error) {
    NSString *result = nil;
    if (error) {
        result = [error localizedDescription];
    } else {
        result = [NSString stringWithFormat:@"%@", json];
    }
    NSLog(@"%@", result);
}];
```

Send post to user's stream:

```Objective-C
NSMutableDictionary *params = [NSMutableDictionary dictionary];
params[@"user_text"] = [NSString stringWithFormat:@"We are testing MyMailRu SDK for iOS now :)"];
params[@"link1_text"] = @"kittens";
params[@"link1_href"] = @"http://placekitten.com/200/300";
params[@"img_url"] = @"http://placekitten.com/200/300";
params[@"text"] = @"Here goes some kittens";
params[@"title"] = @"Post from MyMailRu SDK";
    
MMRRequest *request = [MMRRequest requestForStreamPostWithParams:params];
[request sendWithCompletionHandler:^(id json, NSError *error) {
    NSString *result = nil;
    if (error) {
        result = [error localizedDescription];
    } else {
        result = [NSString stringWithFormat:@"%@", json];
    }
];
```

## License

MyMailRuSDK for iOS is available under the MIT license. See the `LICENSE` file for more info.
