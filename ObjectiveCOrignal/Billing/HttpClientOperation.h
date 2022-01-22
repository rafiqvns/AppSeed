//
//  HttpClientOperation.h
//  MobileOffice
//
//  Created by .D. .D. on 10/2/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "AFHTTPRequestOperation.h"

@protocol HTTPClientOperationDelegate;


@interface HttpClientOperation : AFHTTPRequestOperation {
    
}
@property (nonatomic, weak) id<HTTPClientOperationDelegate>delegate;

@end

@protocol HTTPClientOperationDelegate <NSObject>
@optional
- (void)HTTPClientOperationDidFinishedForced:(HttpClientOperation *)client;
- (void)HTTPClientOperation:(HttpClientOperation *)client didFinished:(id)resp;
- (void)HTTPClientOperation:(HttpClientOperation *)client didFailWithError:(NSDictionary *)errorInfoDict;
- (void)request:(id )request didReceiveBytes:(long long)bytes;
- (void)request:(id )request didReceivedBytes:(NSDictionary*)bytesInfo;
@end

