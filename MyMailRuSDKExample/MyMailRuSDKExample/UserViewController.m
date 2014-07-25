//
//  UserViewController.m
//  MyMailRuSDKExample
//
//  Created by Anton Grachev on 25.07.14.
//  Copyright (c) 2014 Anton Grachev. All rights reserved.
//

#import "UserViewController.h"
#import <MyMailRuSDK/MyMailRuSDK.h>

@interface UserViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdateLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@end

@implementation UserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([MMRSession currentSession].isValid) {
        MMRRequest *request = [MMRRequest requestForUsersInfoWithParams:@{@"uids" : [MMRSession currentSession].userId}];
        [request sendWithCompletionHandler:^(id json, NSError *error) {
            if (error) {
                [self showAlertViewWithErrorMessage:[error localizedDescription]];
            } else {
                NSDictionary *user = json[0];
                self.usernameLabel.text = [NSString stringWithFormat:@"%@ %@", user[@"first_name"], user[@"last_name"]];
                self.birthdateLabel.text = user[@"birthday"];
                self.genderLabel.text = ([user[@"sex"] integerValue] == 0) ? @"male" : @"female";
                if ([user[@"has_pic"] boolValue]) {
                    [self loadAvatarWithURL:user[@"pic_128"]];
                }
            }
        }];
    } else {
        [self showAlertViewWithErrorMessage:@"You should login first."];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAvatarWithURL:(NSString *)avatarUrl {
    NSURL *url = [NSURL URLWithString:avatarUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   [self showAlertViewWithErrorMessage:@"Can't load player avatar"];
                                   return;
                               }
                               
                               UIImage *avatar = [UIImage imageWithData:data];
                               self.avatarImageView.image = avatar;
                           }];
}

- (void)showAlertViewWithErrorMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"Ooops!"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

@end
