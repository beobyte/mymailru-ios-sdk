//
//  ViewController.m
//  MyMailRuSDKExample
//
//  Created by Anton Grachev on 25.07.14.
//  Copyright (c) 2014 Anton Grachev. All rights reserved.
//

#import "ViewController.h"
#import <MyMailRuSDK/MyMailRuSDK.h>

@interface ViewController ()

@end

@implementation ViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
#warning Don't forget to change this parameters for your app
    [MyMailRu setAppId:@"717574"];
    [MyMailRu setAppPrivateKey:@"4de201eec260ac34ac0d8bac49eb4080"];
    [MMRSession openSessionWithPermissions:[self applicationPermissions]
                             loginBehavior:MMRSessionLoginWithCachedToken
                        completionsHandler:^(UIViewController *authViewController, MMRSession *session, NSError *error) {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self loginWithAuthController];
            break;
            
        case 1:
            [self loginInSafari];
            break;
            
        case 2:
            [self performSegueWithIdentifier:@"userInfoSegue" sender:tableView];
            break;
            
        case 3:
            [self performSegueWithIdentifier:@"friendsSegue" sender:tableView];
            break;
            
        case 4:
            [self sendTestPost];
            break;
            
        case 5:
            [self performSegueWithIdentifier:@"postsSegue" sender:tableView];
            break;
            
        case 6:
            [self refreshAccessToken];
            break;
            
        case 7:
            [self logout];
            break;
            
        case 8:
            [self logoutAndDeleteCache];
            break;
            
        default:
            break;
    }
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

- (void)loginWithAuthController {
    if (![MMRSession currentSession].isValid) {
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

- (IBAction)loginInSafari {
    if (![MMRSession currentSession].isValid) {
#warning Don't forget to add URL scheme in main plist (mm<#YOUR APP ID>)
        // Custom URL should provide redirect to custom scheme: mm<#YOUR APP ID>://authorize, for example.
        [MMRSession setRedirectURI:@"http://connect.mail.ru/oauth/success.html"];
        [MMRSession openSessionWithPermissions:[self applicationPermissions]
                                 loginBehavior:MMRSessionLoginInSafari
                            completionsHandler:^(UIViewController *authViewController, MMRSession *session, NSError *error) {
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

- (IBAction)sendTestPost {
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

- (IBAction)refreshAccessToken {
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

- (IBAction)logout {
    [[MMRSession currentSession] close];
}

- (IBAction)logoutAndDeleteCache {
    [[MMRSession currentSession] closeAndClearTokenInformation];
}

@end
