//
//  SeverManager.h
//  CSD
//
//  Created by TOxIC on 23/09/2020.
//  Copyright © 2020 RCO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "Settings.h"


#define HOST @"http://www.apitesting.dev/"
#define kUserName @"username"
#define kPassword @"password"
#define kAccess @"access"
#define kSavedAccessToken @"SavedAccessToken"

typedef void (^ServerManagerSuccess)(id responseObject);
typedef void (^ServerManagerFailure)(NSString *failureReason, NSInteger statusCode);

@interface ServerManager : NSObject

@property (nonatomic, strong) AFHTTPSessionManager *networkingManager;


- (void)authenticateWitUsername:(NSString*)username password:(NSString*)password success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure;

- (void)getStudents:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure;

- (void)getCompanies:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure;

- (void)getUsersAndInstructors:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure;



- (void)postStudent:(NSString*)token params:(NSDictionary*) withParams success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure;

- (AFHTTPSessionManager*) getServerManagerWithToken:(NSString*)token;

+ (id)sharedManager;


@end
