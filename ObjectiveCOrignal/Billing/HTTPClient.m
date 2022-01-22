//
//  HTTPClient.m
//  MobileOffice
//
//  Created by .D. .D. on 9/28/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HTTPClient.h"

@implementation HTTPClient

- (instancetype)initWithBaseURL:(NSURL *)url {
    return [self initWithBaseURL:url plainResponse:NO];
}

- (instancetype)initWithBaseURL:(NSURL *)url plainResponse:(BOOL)plain
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        if (plain) {
            self.responseSerializer = [AFHTTPResponseSerializer serializer];
            self.requestSerializer = [AFJSONRequestSerializer serializer];
        } else {
            self.responseSerializer = [AFJSONResponseSerializer serializer];
            self.requestSerializer = [AFJSONRequestSerializer serializer];
        }
        
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        securityPolicy.allowInvalidCertificates = YES;

        //self.securityPolicy = securityPolicy;
    }
    
    return self;
}

/*

-(instancetype)initWithRequest:(NSURLRequest * __nonnull)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        //self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}
 */

-(NSInteger)httpStatusCode {
    
    NSNumber *httpErrorCode = [self.userInfo objectForKey:ERROR_STATUS_CODE];
    return [httpErrorCode integerValue];
}
@end
