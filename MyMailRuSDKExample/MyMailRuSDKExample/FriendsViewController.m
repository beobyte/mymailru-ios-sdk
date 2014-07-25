//
//  FriendsViewController.m
//  MyMailRuSDKExample
//
//  Created by Anton Grachev on 25.07.14.
//  Copyright (c) 2014 Anton Grachev. All rights reserved.
//

#import "FriendsViewController.h"
#import <MyMailRuSDK/MyMailRuSDK.h>

@interface FriendsViewController ()
@property (strong, nonatomic) NSMutableArray *friends;
@end

@implementation FriendsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)friends {
    if (!_friends) {
        _friends = [[NSMutableArray alloc] init];
    }
    
    return _friends;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([MMRSession currentSession].isValid) {
        MMRRequest *request = [MMRRequest requestForFriendsWithParams:@{@"ext" : @"1"}];
        [request sendWithCompletionHandler:^(id json, NSError *error) {
            if (error) {
                [self showAlertViewWithErrorMessage:[error localizedDescription]];
            } else {
                [self.friends addObjectsFromArray:(NSArray *)json];
                [self.tableView reloadData];
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

- (void)showAlertViewWithErrorMessage:(NSString *)message {
    [[[UIAlertView alloc] initWithTitle:@"Ooops!"
                                message:message
                               delegate:nil
                      cancelButtonTitle:@"Ok"
                      otherButtonTitles:nil] show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.friends count] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FriendCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
    }
    
    NSDictionary *friend = self.friends[indexPath.row];
    cell.textLabel.text = friend[@"nick"];
    cell.detailTextLabel.text = friend[@"uid"];
    
    return cell;
}

@end
