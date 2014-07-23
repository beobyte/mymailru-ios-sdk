// MMRequest.m
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


#import "MMRRequest.h"
#import "MyMailRu.h"
#import "MMRSession.h"
#import "MMRUtils.h"

static NSString* const kMMRAPIBaseURL = @"http://www.appsmail.ru/platform/api";

@interface MMRRequest ()
@property (nonatomic, strong) NSMutableURLRequest *request;
@end

@implementation MMRRequest

+ (MMRRequest *)requestForUsersInfoWithParams:(NSDictionary *)params {
    return [self requestForAPIMethod:@"users.getInfo" params:params HTTPMethod:@"GET"];
}

+ (MMRRequest *)requestForFriendsWithParams:(NSDictionary *)params {
    return [self requestForAPIMethod:@"friends.get" params:params HTTPMethod:@"GET"];
}

+ (MMRRequest *)requestForStreamPostWithParams:(NSDictionary *)params {
    return [self requestForAPIMethod:@"stream.post" params:params HTTPMethod:@"POST"];
}

+ (MMRRequest *)requestForAPIMethod:(NSString *)apiMethod params:(NSDictionary *)params HTTPMethod:(NSString *)httpMethod {
    if (!params) params = @{};
    MMRRequest *r = [[MMRRequest alloc] init];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    request.HTTPMethod = [httpMethod uppercaseString];
    r.request = request;
    
    NSMutableDictionary *requestParams = [NSMutableDictionary dictionary];
    requestParams[@"app_id"] = [MyMailRu appId];
    requestParams[@"session_key"] = [MMRSession currentSession].accessToken;
    requestParams[@"method"] = apiMethod ?: @"";
    requestParams[@"format"] = @"json";
    requestParams[@"secure"] = @"0";

    NSMutableDictionary *paramsForSign = [NSMutableDictionary dictionaryWithDictionary:params];
    [paramsForSign addEntriesFromDictionary:requestParams];
    NSString *signature = [MMRUtils signatureForParams:paramsForSign
                                       withAccessToken:[MMRSession currentSession].accessToken
                                                userID:[MMRSession currentSession].userId
                                         andPrivateKey:[MyMailRu appPrivateKey]];
    requestParams[@"sig"] = signature;
    
    NSString *APIMethod = [apiMethod stringByReplacingOccurrencesOfString:@"." withString:@"/"];
    
    if ([request.HTTPMethod isEqualToString:@"GET"]) {
        [requestParams addEntriesFromDictionary:params];
    } else if ([request.HTTPMethod isEqualToString:@"POST"]) {
        NSString *encodedPOSTParams = [MMRUtils URLEncodedStringFromParams:params];
        request.HTTPBody = [encodedPOSTParams dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?%@", kMMRAPIBaseURL, APIMethod, [MMRUtils URLEncodedStringFromParams:requestParams]];
    request.URL = [NSURL URLWithString:url];
	
    return r;
}

- (void)sendWithCompletionHandler:(MMRRequestHandler)handler {
    [NSURLConnection sendAsynchronousRequest:self.request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError) {
                                   if (handler) handler(nil, connectionError);
                                   return;
                               }
                               
                               NSError *jsonParsingError = nil;
                               id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonParsingError];
                               if (jsonParsingError) {
                                   if (handler) handler(nil, jsonParsingError);
                                   return;
                               }
                               
                               if (handler) handler(result, nil);
                           }];
}
@end
