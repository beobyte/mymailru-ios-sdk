// MMRErrors.m
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


#import "MMRErrors.h"

@implementation MMRErrors

static NSString* const MMRErrorDomain = @"MyMailRuErrorDomain";

+ (NSError *)errorFromJSON:(id)json {
    if (json == nil) return [self errorForCode:MMRErrorUnknown];
    if (![json isKindOfClass:[NSDictionary class]]) return nil;
    
    NSDictionary *errorInfo = json[@"error"];
	if(errorInfo) {
        if ([errorInfo isKindOfClass:[NSDictionary class]]) {
            NSInteger code = [errorInfo[@"error_code"] integerValue];
            return [self errorForCode:(MMRErrorCodes) code];
        } else {
            return [NSError errorWithDomain:MMRErrorDomain
                                       code:MMRErrorUnknown
                                   userInfo:@{NSLocalizedDescriptionKey : errorInfo}];
        }
	}
    return nil;
}

+ (NSError *)errorForCode:(MMRErrorCodes)errorCode {
    NSDictionary *userInfo;
    switch (errorCode) {
        case MMRErrorUnknown:
            userInfo = @{NSLocalizedDescriptionKey : @"Unknown error: Please resubmit the request."};
            break;

        case MMRErrorUnknownMethodCalled:
            userInfo = @{NSLocalizedDescriptionKey : @"Unknown method called."};
            break;
            
        case MMRErrorServiceUnavailable:
            userInfo = @{NSLocalizedDescriptionKey : @"Service Unavailable. Please try again later."};
            break;
            
        case MMRErrorMethodDeprecated:
            userInfo = @{NSLocalizedDescriptionKey : @"Method is deprecated."};
            break;
            
        case MMRErrorUserAuthorizationFailed:
            userInfo = @{NSLocalizedDescriptionKey : @"User authorization failed: the session key or uid is incorrect."};
            break;
            
        case MMRErrorParameterMissingOrInvalid:
            userInfo = @{NSLocalizedDescriptionKey : @"One of the parameters specified is missing or invalid."};
            break;
            
        case MMRErrorApplicationLookupFailed:
            userInfo = @{NSLocalizedDescriptionKey : @"Application lookup failed: the application id is not correct."};
            break;
            
        case MMRErrorIncorrectSignature:
            userInfo = @{NSLocalizedDescriptionKey : @"Incorrect signature."};
            break;
            
        case MMRErrorApplicationNotInstalledForUser:
            userInfo = @{NSLocalizedDescriptionKey : @"Permission error: the application does not have permission to perform this action."};
            break;
            
        case MMRErrorPermissionError:
            userInfo = @{NSLocalizedDescriptionKey : @"Application is not installed for this user."};
            break;

        case MMRErrorUserCancelOperation:
            userInfo = @{NSLocalizedDescriptionKey : @"User cancel this operation."};
            break;
            
        default:
            userInfo = @{};
            break;
    }
    return [NSError errorWithDomain:MMRErrorDomain code:errorCode userInfo:userInfo];
}

@end
