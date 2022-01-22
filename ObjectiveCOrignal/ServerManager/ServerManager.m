//
//  SeverManager.m
//  CSD
//
//  Created by TOxIC on 23/09/2020.
//  Copyright © 2020 RCO. All rights reserved.
//
#import "ServerManager.h"


@interface ServerManager()

@end

@implementation ServerManager

#pragma mark -
#pragma mark Constructors

static ServerManager *sharedManager = nil;

+ (ServerManager*)sharedManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^
                  {
        sharedManager = [[ServerManager alloc] init];
    });
    return sharedManager;
}

- (id)init {
    if ((self = [super init])) {
    }
    return self;
}

- (AFHTTPSessionManager*) getServerManagerWithToken:(NSString*)token {
    
    
    if (self.networkingManager == nil) {
        
        
        self.networkingManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:CSD_SERVER]];
        
        
        
        
        self.networkingManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.networkingManager.responseSerializer.acceptableContentTypes = [self.networkingManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"application/json"]];
        
        
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
        
        
        
        self.networkingManager.securityPolicy = [self getSecurityPolicy];
    }
    
    if (token.length > 0) {
        
        
        
        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
        
        NSLog(@"Token %@", headerToken);
        
        
        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
        
        
    }
    
    
    
    
    
    return self.networkingManager;
}

- (void)authenticateWitUsername:(NSString*)username password:(NSString*)password success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    if (username != nil && [username length] > 0 && password != nil && [password length] > 0) {
        
        
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:username forKey:@"username"];
        [params setObject:password forKey:@"password"];
        
        [[self getServerManagerWithToken:nil] POST:@"admin/login/token/" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            
            
            if (success != nil) {
                success(responseObject);
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            
            
            
            
            NSString *errorMessage = [self getError:error];
            if (failure != nil) {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                
                NSInteger statusCode = response.statusCode;
                failure(errorMessage, statusCode);
            }
        }];
        
    } else {
        if (failure != nil) {
            failure(@"Username and Password Required", -1);
        }
    }
}


- (void)getCompanies:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    if (token != nil && [token length] > 0) {
        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    }
    
    
    [[self getServerManagerWithToken:token] GET:@"companies/" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        
        if (success != nil) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
    }];
}


- (void)getUsersAndInstructors:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    //    if (token != nil && [token length] > 0) {
    //        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
    //        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
    //        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    //    }
    
    
    [[self getServerManagerWithToken:token] GET:@"users/" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        
        if (success != nil) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
    }];
}


- (void)getUsersWithType:(NSString*)token withType: (NSString *) withType success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    [[self getServerManagerWithToken:token] GET:withType parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
        
    }];
    
    
    
}



- (void)getUsersDetails:(NSString*)token withType: (NSString *) withType withId: (NSString *) withId success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@", withType, withId];
    self.networkingManager = nil;
    [[self getServerManagerWithToken:token] GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
        
    }];
    
    
    
}

- (void)putRequestWithMultipart:(NSString*)token withUrl: (NSString *) url withDict: (NSDictionary *) dict withImages:(NSDictionary *)images success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    self.networkingManager = nil;
   
    [[self getServerManagerWithToken:token] PUT:url parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSString *key in images) {
            [formData appendPartWithFileData:[images valueForKey:key] name:key fileName:[NSString stringWithFormat:@"%@.png", key] mimeType:@"image/png"];
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if (success != nil) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];

            NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"error response = %@", errResponse);
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
    }];
}

- (void)postRequest:(NSString*)token withUrl: (NSString *) url withDict: (NSDictionary *) dict  success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    self.networkingManager = nil;
    [[self getServerManagerWithToken:token] POST:url parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            NSString *errorMessage = [self getError:error];
            if (failure != nil) {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                
                NSInteger statusCode = response.statusCode;
                failure(errorMessage, statusCode);
            }
            
        }];
    
    
    
    
    
}

- (void)patchRequest:(NSString*)token withUrl: (NSString *) url withDict: (NSDictionary *) dict  success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    self.networkingManager = nil;
    [[self getServerManagerWithToken:token] PATCH:url parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
            
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
            NSString *errorMessage = [self getError:error];
            if (failure != nil) {
                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
                
                NSInteger statusCode = response.statusCode;
                failure(errorMessage, statusCode);
            }
            
        }];
    
    
    
    
    
}

//- (void)getUsersDetails:(NSString*)token withType: (NSString *) withType withId: (NSString *) withId success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
//
//    NSString *urlString = [NSString stringWithFormat:@"%@/%@", withType, withId];
//
//
//
//    [[self getServerManagerWithToken:token] GET:urlString parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//
//        if (success != nil) {
//            success(responseObject);
//        }
//
//        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
//
//            NSString *errorMessage = [self getError:error];
//            if (failure != nil) {
//                NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
//
//                   NSInteger statusCode = response.statusCode;
//                failure(errorMessage, statusCode);
//            }
//
//    }];
//
//}

- (void)checkIfStudentExists:(NSString*)token licenseNum: (NSString
                                                           *) license licenseState: (NSString *) state  success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    
    
    NSString *urlQuery = [NSString stringWithFormat:@"students/?driver_license_number=%@&driver_license_state=%@", license, state];
    
    [[self getServerManagerWithToken:token] GET:urlQuery parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
        
    }];
    
    
    
}

- (void)getStudentDetails:(NSString*)token studentId: (NSString
                                                       *) idOfStudent success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    
    
    NSString *urlQuery = [NSString stringWithFormat:@"students/%@", idOfStudent];
    
    [[self getServerManagerWithToken:token] GET:urlQuery parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
        
    }];
    
    
    
}

- (void)postUser:(NSString*)token params: (NSDictionary *) withParams  withUrl: (NSString *) url success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {
    
    
    //    if (token != nil && [token length] > 0) {
    //        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
    //        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
    //        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    //    }
    //
    //
    //
    [[self getServerManagerWithToken:token] POST:url parameters:withParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
        if (success != nil) {
            success(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
        NSString *errorMessage = [self getError:error];
        if (failure != nil) {
            NSHTTPURLResponse *response = error.userInfo[AFNetworkingOperationFailingURLResponseErrorKey];
            
            NSInteger statusCode = response.statusCode;
            failure(errorMessage, statusCode);
        }
        
    }];
    
    
}



- (id)getSecurityPolicy {
    return [AFSecurityPolicy defaultPolicy];
    
}

- (NSString*)getError:(NSError*)error {
    
    if (error != nil) {
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        
        NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        
        
        
        if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]] && [responseObject objectForKey:@"detail"] != nil && [[responseObject objectForKey:@"detail"] length] > 0) {
            return [responseObject objectForKey:@"detail"];
        }
    }
    return @"Server Error. Please try again later";
}


@end
