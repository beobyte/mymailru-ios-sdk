//
//  PostsViewController.m
//  MyMailRuSDKExample
//
//  Created by Anton Grachev on 25.07.14.
//  Copyright (c) 2014 Anton Grachev. All rights reserved.
//

#import "PostsViewController.h"
#import <MyMailRuSDK/MyMailRuSDK.h>

@interface PostsViewController ()
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@end

@implementation PostsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSMutableArray *)posts {
    if (!_posts) {
        _posts = [[NSMutableArray alloc] init];
    }
    
    return _posts;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _dateFormatter;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([MMRSession currentSession].isValid) {
        MMRRequest *request = [MMRRequest requestForAPIMethod:@"stream.get"
                                                       params:@{@"limit" : @"5"}
                                                   HTTPMethod:@"GET"];
        [request sendWithCompletionHandler:^(id json, NSError *error) {
            if (error) {
                [self showAlertViewWithErrorMessage:[error localizedDescription]];
            } else {
                [self.posts addObjectsFromArray:(NSArray *)json];
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
    return [self.posts count] > 0 ? 1 : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PostCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
    }
    
    NSDictionary *post = self.posts[indexPath.row];
    cell.textLabel.text = [post[@"title"] length] > 0 ? post[@"title"] : @"No title";
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[post[@"time"] doubleValue]];
    NSString *theDate = [self.dateFormatter stringFromDate:date];
    
    cell.detailTextLabel.text = theDate;
    
    return cell;
}


@end
