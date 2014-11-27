MyMailRu SDK for iOS
==========

iOS framework for working with my.mail.ru (мой мир@mail.ru) REST API. You can use it for authentication in this social network and all others API methods. See REST API methods descriptions [here](http://api.mail.ru/docs/) for details.

### Installation

Link your project with the following frameworks:

- UIKit.framework
- CommonCrypto.framework


Drag and drop all sources from MyMailRuSDK directory into your project (MyMailRuSDK.xcodeproj not required).

Another way is to already compiled framework from zip.

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
                    completionsHandler:^(UIViewController *authViewController, MMRSession *session, NSError *error) {
                        if (!error) {
                            NSLog(@"Session silent open successfully");
                        } else {
                            NSLog(@"%@", error);
                        }
                    }];
```

Open session with authorization controller in your application: 

```Objective-C
[MMRSession openSessionWithPermissions:[self applicationPermissions]
                         loginBehavior:MMRSessionLoginWithAuthorizationController
                    completionsHandler:^(UIViewController *authViewController, MMRSession *session, NSError *error) {
                        if (authViewController) {
                            [self presentViewController:authViewController
                                               animated:YES
                                             completion:nil];
                            return;
                        }
                        
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

Open session with username and password: 

```Objective-C
if (![MMRSession currentSession].isValid) {
    [MMRSession  openSessionForUsername:@"john.appleseed@mail.ru"
                               password:@"123qwe456"
                            permissions:@[@"stream"]
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
