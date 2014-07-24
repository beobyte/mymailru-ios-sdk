//
//  ViewController.m
//  MyMailRuSDKExample
//
//  Created by Anton Grachev on 22.07.14.
//  Copyright (c) 2014 Anton Grachev. All rights reserved.
//

#import "ViewController.h"

#import <MyMailRuSDK/MyMailRuSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
#warning Don't forget to change this parameters for ypur app
    [MyMailRu setAppId:@"717574"];
    [MyMailRu setAppPrivateKey:@"4de201eec260ac34ac0d8bac49eb4080"];
    [MMRSession openSessionWithPermissions:[self applicationPermissions]
                             loginBehavior:MMRSessionLoginWithCachedToken
                        completionsHandler:^(MMRSession *session, NSError *error) {
                            if (!error) {
                                NSLog(@"Session silent open successfully");
                            } else {
                                NSLog(@"%@", error);
                            }
                        }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)applicationPermissions {
    return @[@"stream", @"photos"];
}

- (void)showAlertForInvalidSession {
    [[[UIAlertView alloc] initWithTitle:@"Get user info"
                                message:@"Please, login first."
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

- (IBAction)loginInAppWebView:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [MMRSession openSessionWithPermissions:[self applicationPermissions]
                                 loginBehavior:MMRSessionLoginInAppWebView
                            completionsHandler:^(MMRSession *session, NSError *error) {
                                NSString *result = nil;
                                if (error) {
                                    result = [error localizedDescription];
                                } else {
                                    result = @"Success";
                                }
                                NSLog(@"%@", result);
                                [[[UIAlertView alloc] initWithTitle:@"Login"
                                                            message:result
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil] show];
                            }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Login"
                                    message:@"You are already logged in."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)loginInSafari:(id)sender {
    if (![MMRSession currentSession].isValid) {
#warning Don't forget to add URL scheme in main plist (mm<#YOUR APP ID>)
        // Custom URL should provide redirect to custom scheme: mm<#YOUR APP ID>://authorize, for example.
        [MMRSession setRedirectURI:@"http://connect.mail.ru/oauth/success.html"];
        [MMRSession openSessionWithPermissions:[self applicationPermissions]
                                 loginBehavior:MMRSessionLoginInSafari
                            completionsHandler:^(MMRSession *session, NSError *error) {
                                NSString *result = nil;
                                if (error) {
                                    result = [error localizedDescription];
                                } else {
                                    result = @"Success";
                                }
                                NSLog(@"%@", result);
                                [[[UIAlertView alloc] initWithTitle:@"Login"
                                                            message:result
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil] show];
                            }];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Login"
                                    message:@"You are already logged in."
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }
    
}

- (IBAction)getUserInfo:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [self showAlertForInvalidSession];
        return;
    }
    
    MMRRequest *request = [MMRRequest requestForUsersInfoWithParams:@{@"uids" : [MMRSession currentSession].userId}];
    [request sendWithCompletionHandler:^(id json, NSError *error) {
        NSString *result = nil;
        if (error) {
            result = [error localizedDescription];
        } else {
            result = [NSString stringWithFormat:@"%@", json];
        }
        NSLog(@"%@", result);
        [[[UIAlertView alloc] initWithTitle:@"Get user info"
                                    message:result
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }];
}
- (IBAction)getFriends:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [self showAlertForInvalidSession];
        return;
    }
    
    MMRRequest *request = [MMRRequest requestForFriendsWithParams:@{@"ext" : @"1"}];
    [request sendWithCompletionHandler:^(id json, NSError *error) {
        NSString *result = nil;
        if (error) {
            result = [error localizedDescription];
        } else {
            result = [NSString stringWithFormat:@"%@", json];
        }
        NSLog(@"%@", result);
        [[[UIAlertView alloc] initWithTitle:@"Get friends"
                                    message:result
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }];
}

- (IBAction)sendPost:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [self showAlertForInvalidSession];
        return;
    }
    
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
        NSLog(@"%@", result);
        [[[UIAlertView alloc] initWithTitle:@"Send post"
                                    message:result
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }];
}

- (IBAction)getPosts:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [self showAlertForInvalidSession];
        return;
    }
    
    MMRRequest *request = [MMRRequest requestForAPIMethod:@"stream.get"
                                                   params:@{@"limit" : @"5"}
                                               HTTPMethod:@"GET"];
    [request sendWithCompletionHandler:^(id json, NSError *error) {
        NSString *result = nil;
        if (error) {
            result = [error localizedDescription];
        } else {
            result = [NSString stringWithFormat:@"%@", json];
        }
        NSLog(@"%@", result);
        [[[UIAlertView alloc] initWithTitle:@"Get posts"
                                    message:result
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
    }];
    
}

- (IBAction)refreshAccessToken:(id)sender {
    if (![MMRSession currentSession].isValid) {
        [self showAlertForInvalidSession];
        return;
    }
    
    [[MMRSession currentSession] refreshTokenWithCompletionHandler:^(NSError *error) {
        NSString *result = nil;
        if (error) {
            result = [error localizedDescription];
        } else {
            result = @"Success";
        }
        NSLog(@"%@", result);
        [[[UIAlertView alloc] initWithTitle:@"Refresh token"
                                    message:result
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
        
    }];
}

- (IBAction)logout:(id)sender {
    [[MMRSession currentSession] close];
}

- (IBAction)logoutAndDeleteCache:(id)sender {
    [[MMRSession currentSession] closeAndClearTokenInformation];
}

@end
