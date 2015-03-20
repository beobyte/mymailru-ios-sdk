// MMRUtils.m
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


#import "MMRUtils.h"
#import <CommonCrypto/CommonDigest.h>

@implementation MMRUtils

+ (NSString *)URLEncodedStringFromParams:(NSDictionary *)params {
    NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in [params allKeys]) {
        NSString *escapedValue = (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL,
                (__bridge CFStringRef) params[key],
                NULL,
                (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                kCFStringEncodingUTF8);
        
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
	}
	return [pairs componentsJoinedByString:@"&"];;

}

+ (NSDictionary *)queryParametersFromURL:(NSURL *)url {
    NSString *query = [url fragment];
    if (!query) [url query];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary * kvPairs = [NSMutableDictionary dictionary];
    for (NSString * pair in pairs) {
        NSArray * bits = [pair componentsSeparatedByString:@"="];
        NSString * key = [bits[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString * value = [bits[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        kvPairs[key] = value;
    }
    return kvPairs;
}

+ (NSString *)signatureForParams:(NSDictionary *)params userID:(NSString *)userId andPrivateKey:(NSString *)privateKey {
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableString *signatureString = [NSMutableString stringWithString:userId];
	for (NSUInteger i = 0; i < sortedKeys.count; i++){
		NSString *key = sortedKeys[i];
		[signatureString appendString:[NSString stringWithFormat:@"%@=%@", key, [params valueForKey:key]]];
	}
    
    [signatureString appendString:privateKey];
    
	return [[MMRUtils md5FromString:signatureString] lowercaseString];

}

+ (NSString *)md5FromString:(NSString *)string {
    const char *cStr = [string UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
    
	CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    
	return [[NSString
             stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0],  result[1],
             result[2],  result[3],
             result[4],  result[5],
             result[6],  result[7],
             result[8],  result[9],
             result[10], result[11],
             result[12], result[13],
             result[14], result[15]
             ] lowercaseString];
}


@end
