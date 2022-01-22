//
//  HttpClientOperation.m
//  MobileOffice
//
//  Created by .D. .D. on 10/2/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "HttpClientOperation.h"



@implementation HttpClientOperation

-(instancetype)init {
    self = [super init];
    
    if (self) {
        //AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        //AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        
        [policy setValidatesDomainName:NO];
        [policy setAllowInvalidCertificates:YES];
        
        self.securityPolicy = policy;
    }
    
    return self;
}

-(instancetype)initWithRequest:(NSURLRequest *)urlRequest {
    self = [super initWithRequest:urlRequest];
    if (self) {
        
        //AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        //AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
        AFSecurityPolicy* policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];

        [policy setValidatesDomainName:NO];
        [policy setAllowInvalidCertificates:YES];
        
        self.securityPolicy = policy;
    }
    
    return self;
}

@end
