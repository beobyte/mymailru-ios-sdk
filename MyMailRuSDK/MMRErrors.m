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
		NSInteger code = [errorInfo[@"error_code"] integerValue];
		return [self errorForCode:code];
	}
    return nil;
}

+ (NSError *)errorForCode:(MMRErrorCodes)errorCode {
    NSDictionary *userInfo = @{};
    switch (errorCode) {
        case MMRErrorUnknown:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Unknown error: Please resubmit the request.", NSLocalizedDescriptionKey, nil];
            break;

        case MMRErrorUnknownMethodCalled:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Unknown method called.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorServiceUnavailable:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Service Unavailable. Please try again later.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorMethodDeprecated:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Method is deprecated.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorUserAuthorizationFailed:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"User authorization failed: the session key or uid is incorrect.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorParameterMissingOrInvalid:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"One of the parameters specified is missing or invalid.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorApplicationLookupFailed:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Application lookup failed: the application id is not correct.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorIncorrectSignature:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Incorrect signature.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorApplicationNotInstalledForUser:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Permission error: the application does not have permission to perform this action.", NSLocalizedDescriptionKey, nil];
            break;
            
        case MMRErrorPermissionError:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"Application is not installed for this user.", NSLocalizedDescriptionKey, nil];
            break;

        case MMRErrorUserCancelOperation:
            userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                        @"User cancel this operation.", NSLocalizedDescriptionKey, nil];
            break;
            
        default:
            break;
    }
    return [NSError errorWithDomain:MMRErrorDomain code:errorCode userInfo:userInfo];
}

@end
