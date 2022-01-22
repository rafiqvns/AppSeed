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
        self.networkingManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:CSD_SERVER_DEV]];



        
        self.networkingManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.networkingManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.networkingManager.responseSerializer.acceptableContentTypes = [self.networkingManager.responseSerializer.acceptableContentTypes setByAddingObjectsFromArray:@[@"text/html", @"application/json", @"text/json"]];
        
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];


        self.networkingManager.securityPolicy = [self getSecurityPolicy];
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


    if (token != nil && [token length] > 0) {
        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    }
    

    
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

- (void)getStudents:(NSString*)token success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {


    if (token != nil && [token length] > 0) {
        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    }
    
    [self.networkingManager GET:@"students/" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
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

- (void)postStudent:(NSString*)token params: (NSDictionary *) withParams  success:(ServerManagerSuccess)success failure:(ServerManagerFailure)failure {


    if (token != nil && [token length] > 0) {
        NSString *headerToken = [[NSString alloc]initWithFormat:@"Bearer %@",token];
        [[self.networkingManager requestSerializer] setValue:headerToken forHTTPHeaderField:@"Authorization"];
        [[self.networkingManager requestSerializer] setValue:@"private, max-age=0, no-cache" forHTTPHeaderField:@"cache-control"];
    }
    
    
    
    [[self getServerManagerWithToken:token] POST:@"students/register/" parameters:withParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        
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
