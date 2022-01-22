//
//  HTTPClient.h
//  MobileOffice
//
//  Created by .D. .D. on 9/28/15.
//  Copyright (c) 2015 RCO. All rights reserved.
//

#import "AFHTTPSessionManager.h"
//#import "AFHTTPRequestOperation.h"

#define ERROR_KEY @"errorKey"
#define ERROR_STATUS_CODE @"errorStatusCode"

#define ERR_CODE_NO_IC 1111
#define ERR_CODE_TIMEOUT 1112

#define RESPONSE_STR @"responseStr"
#define RESPONSE_OBJ @"responseObj"
#define RESPONSE_LIST @"responseList"
#define RESPONSE_USER_INFO @"responseUserInfo"
#define RESPONSE_FORCED @"responseForced"
#define RESPONSE_CALL @"responseCall"
#define RESPONSE_STATUS_CODE @"responseStatusCode"
#define RESPONSE_EXTRA_INFO_TO_LISTENER @"responseExtraInfoToListener"

#define CALL_STATE @"callState"

#define TIMEOUT_SECONDS 600

@protocol HTTPClientDelegate;

@interface HTTPClient : AFHTTPSessionManager

@property (nonatomic, weak) id<HTTPClientDelegate>delegate;
@property (nonatomic, strong) NSDictionary* userInfo;
@property (nonatomic, readonly) BOOL plainResponse;

- (instancetype)initWithBaseURL:(NSURL *)url plainResponse:(BOOL)plain;
- (instancetype)initWithBaseURL:(NSURL *)url;

- (NSInteger)httpStatusCode;

@end

@protocol HTTPClientDelegate <NSObject>
@optional
-(void)HTTPClientDidFinishedForced:(HTTPClient *)client;
-(void)HTTPClient:(HTTPClient *)client didFinished:(id)resp;
-(void)HTTPClient:(HTTPClient *)client didFailWithError:(NSDictionary *)errorInfoDict;
@end
