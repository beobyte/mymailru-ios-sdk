// MMRTokenCache.m
//
// Copyright (c) 2016 Anton Grachev
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


#import "MMRTokenCache.h"

static NSString *const MMRTokenKey = @"ru.mail.my.sdk:TokenKey";

NSString *const kMMRAccessToken = @"my_mail_ru_access_token";
NSString *const kMMRRefreshToken = @"my_mail_ru_refresh_token";
NSString *const kMMRPermissions = @"my_mail_ru_permissions";
NSString *const kMMRExpirationDate = @"my_mail_ru_expiration_date";
NSString *const kMMRUserId = @"my_mail_ru_user_id";

@implementation MMRTokenCache

+ (void)cacheTokenInformation:(NSDictionary *)tokenInfo {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:tokenInfo forKey:MMRTokenKey];
	[defaults synchronize];
}

+ (NSDictionary *)getTokenInformation {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults objectForKey:MMRTokenKey];
}

+ (void)clearTokenInformation {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removeObjectForKey:MMRTokenKey];
	[defaults synchronize];
}

@end
