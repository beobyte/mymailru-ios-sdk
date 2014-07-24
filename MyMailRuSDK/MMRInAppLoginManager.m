//  MMRLoginView.m
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

#import "MMRInAppLoginManager.h"
#import <UIKit/UIKit.h>
#import "MMRSession.h"
#import "MMRUtils.h"

@interface MMRInAppLoginManager () <UIAlertViewDelegate, UIWebViewDelegate>
@property (strong, nonatomic) UIViewController *loginVC;
@end

@implementation MMRInAppLoginManager

#pragma mark - Login web view

- (void)showLoginWebViewWithURL:(NSURL *)url {
    // This method definitely need refactoring :)
    self.loginVC = [[UIViewController alloc] initWithNibName:nil bundle:nil];
    self.loginVC.view.frame = [UIScreen mainScreen].applicationFrame;
    self.loginVC.view.backgroundColor = [UIColor blackColor];
    self.loginVC.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(closeLoginWebView:)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    [navigationItem setRightBarButtonItem:closeButton];
    
    CGRect frame = CGRectMake(0, 0, self.loginVC.view.frame.size.width, self.loginVC.view.frame.size.height);
    UINavigationBar *navigationBar = [[UINavigationBar alloc] init];
    frame.size = [navigationBar sizeThatFits:frame.size];
    // if >= 7.x
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        frame.size.height += 20;
    }
    
    navigationBar.frame = frame;
    navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    navigationBar.items = [NSArray arrayWithObject:navigationItem];
    [self.loginVC.view addSubview:navigationBar];
    
    CGRect webFrame = CGRectMake(0,
                                 frame.size.height + frame.origin.y,
                                 frame.size.width,
                                 self.loginVC.view.frame.size.height - frame.size.height);
    UIWebView *webView = [[UIWebView alloc] initWithFrame:webFrame];
    webView.delegate = self;
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.loginVC.view addSubview:webView];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self.loginVC
                                                                                 animated:YES
                                                                               completion:^{
                                                                                   [webView loadRequest:request];
                                                                               }];
    
}

- (void)closeLoginWebView:(id)sender {
    [self.loginVC dismissViewControllerAnimated:YES
                                     completion:^{
                                         self.loginVC = nil;
                                     }];
    if ([self.delegate respondsToSelector:@selector(userDidCloseLoginView)]) {
        [self.delegate userDidCloseLoginView];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString hasPrefix:[MMRSession redirectURI]]) {
        NSDictionary *params = [MMRUtils queryParametersFromURL:request.URL];
        if ([self.delegate respondsToSelector:@selector(userAuthorizedWithSessionParams:error:)]) {
            [self.delegate userAuthorizedWithSessionParams:params error:nil];
        }
        [self.loginVC dismissViewControllerAnimated:YES
                                         completion:^{
                                             self.loginVC = nil;
                                         }];
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(user)]) {
        [self.delegate userAuthorizedWithSessionParams:nil error:error];
    }
}

#pragma mark - Login and password view

- (void)showLoginAndPasswordView {
    NSString *localeIdentifier = [[NSLocale currentLocale] localeIdentifier];
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:[self titleForLocaleIdentifier:localeIdentifier]
                                                 message:[self messageForLocaleIdentifier:localeIdentifier]
                                                delegate:self
                                       cancelButtonTitle:[self cancelButtonTitleForLocaleIdentifier:localeIdentifier]
                                       otherButtonTitles:@"OK", nil];
    [av setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    [[av textFieldAtIndex:0] setPlaceholder:@"username@mail.ru"];
    [[av textFieldAtIndex:1] setPlaceholder:@"password"];
    [[av textFieldAtIndex:1] setSecureTextEntry:YES];
    [av show];
}

- (NSString *)titleForLocaleIdentifier:(NSString *)localeIdentifier {
    NSString *title = @"my world@mail.ru";
    if ([localeIdentifier hasPrefix:@"ru"]) {
        title = @"мой мир@mail.ru";
    }
    return title;
}

- (NSString *)messageForLocaleIdentifier:(NSString *)localeIdentifier {
    NSString *message = @"Enter your login and password:";
    if ([localeIdentifier hasPrefix:@"ru"]) {
        message = @"Введите ваш логин и пароль:";
    }
    return message;
}

- (NSString *)cancelButtonTitleForLocaleIdentifier:(NSString *)localeIdentifier {
    NSString *buttonTitle = @"Cancel";
    if ([localeIdentifier hasPrefix:@"ru"]) {
        buttonTitle = @"Отмена";
    }
    return buttonTitle;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *username = [[alertView textFieldAtIndex:0] text];
        NSString *password = [[alertView textFieldAtIndex:1] text];
        if ([self.delegate respondsToSelector:@selector(userDidEnterLogin:andPassword:)]) {
            [self.delegate userDidEnterLogin:username andPassword:password];
        }
    } else {
        [self.delegate userDidCloseLoginView];
    }
}


@end
