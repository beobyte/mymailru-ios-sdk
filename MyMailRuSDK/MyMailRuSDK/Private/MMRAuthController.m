// MMRAuthController.m
//
// Copyright (c) 2015 Anton Grachev
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

#import "MMRAuthController.h"
#import <UIKit/UIKit.h>
#import "MMRSession.h"
#import "MMRUtils.h"
#import "MMRErrorUtility.h"

#define MMRColor [UIColor colorWithRed:14/255.f green:94/255.f blue:165/255.f alpha:1.f]

@interface MMRAuthController () <UIWebViewDelegate>
@property (nonatomic, weak) id<MMRAuthControllerDelegate> delegate;
@property (nonatomic, copy) NSURL *authURL;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation MMRAuthController

+ (UIViewController *)controllerWithAuthorizationURL:(NSURL *)URL delegate:(id<MMRAuthControllerDelegate>)delegate {
    MMRAuthController *ac = [[MMRAuthController alloc] init];
    ac.authURL = URL;
    ac.delegate = delegate;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:ac];
    
    if ([nc.navigationBar respondsToSelector:@selector(barTintColor)]) {
        nc.navigationBar.barTintColor = MMRColor;
        nc.navigationBar.tintColor = [UIColor whiteColor];
        nc.navigationBar.translucent = YES;
    } else {
        nc.navigationBar.tintColor = MMRColor;
    }
    
    return nc;
}

- (void)dealloc {
    self.webView = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel)];
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    // if we want to logout and login with another account, then we should delete cookie
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([[cookie domain] hasSuffix:@"mail.ru"]) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
        }
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.authURL];
    [self.webView loadRequest:request];
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.absoluteString hasPrefix:[MMRSession redirectURI]]) {
        NSDictionary *params = [MMRUtils queryParametersFromURL:request.URL];
        NSError *error = [MMRErrorUtility errorFromJSON:params];
        
        if ([self.delegate respondsToSelector:@selector(userAuthorizedWithSessionParams:error:)]) {
            [self.delegate userAuthorizedWithSessionParams:params error:error];
        }
        
        [self dismiss];
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(userAuthorizedWithSessionParams:error:)]) {
        [self.delegate userAuthorizedWithSessionParams:nil error:error];
    }
}

#pragma mark - Actions

- (void)cancel {
    if ([self.delegate respondsToSelector:@selector(userDidCloseController)]) {
        [self.delegate userDidCloseController];
    }
    
    [self dismiss];
}

- (void)dismiss {
    if (self.navigationController.isBeingDismissed)
        return;
    
    if (!self.navigationController.isBeingPresented) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^(void) {
            [self dismiss];
        });
    }
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
