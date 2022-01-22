//
//  Settings.m
//  Billing
//
//  Created by .R.H. on 7/3/11.
//  Copyright 2011 RCO All rights reserved.
//

#import "Settings.h"

@interface Settings ()
    + (NSString *) currentUserSettingsKey;
    + (NSString *) userSettingsKey: (NSString *) userName onServer: (NSString *) server;

@end

static NSMutableDictionary* s_settingsDict;
static NSMutableDictionary* s_userSettingsDict;

@implementation Settings


- (id) init
{
	if((self = [super init]) != nil)
	{
	}
	return self;
}

- (void)dealloc
{
	[Settings releaseStatics];
}

+ (NSString *) getSetting: (NSString *) key
{
	[self initStatics];
    NSString * the_val = nil;
    
    @synchronized(s_settingsDict) {
        the_val = [s_settingsDict objectForKey:key];
    
        if([the_val isKindOfClass:[NSString class]] )
            return( the_val);
        else
            return nil;
    }
}

+ (NSNumber *) getSettingAsNumber: (NSString *) key
{
	[self initStatics];
	
	NSNumber * the_val = [s_settingsDict objectForKey:key];
    
    if([the_val isKindOfClass:[NSNumber class]] )
        return( the_val);
	else
        return nil;
}

+ (NSArray *) getSettingAsArray: (NSString *) key
{
	[self initStatics];
	
	id the_val = [s_settingsDict objectForKey:key];
    
    if([the_val isKindOfClass:[NSArray class]] )
        return( the_val);
	else
        return nil;
}

+ (NSDate *) getSettingAsDate: (NSString *) key
{
	[self initStatics];
	
	id the_val = [s_settingsDict objectForKey:key];
    
    if([the_val isKindOfClass:[NSDate class]] )
        return( the_val);
	else
        return nil;
}

+(void)resetKey:(NSString*)key {
    if (key) {
        
        NSLog(@"Key %@", key);
        
        [s_settingsDict removeObjectForKey:key];
    }
}

+ (NSDictionary *) getSettingAsDictionary: (NSString *) key
{
	[self initStatics];
	
	id the_val = [s_settingsDict objectForKey:key];
    
    if([the_val isKindOfClass:[NSDictionary class]] )
        return( the_val);
	else
        return nil;
}

+ (void) setSetting:(NSString *)val forKey:(NSString *)key
{
	[self initStatics];
    
    if (!val) {
        return;
    }
    
    if (!key) {
        return;
    }
	
    @synchronized(s_settingsDict) {
        [s_settingsDict setObject:val forKey:key];
        [s_userSettingsDict setObject:val forKey:key];
    }
}

+ (void) setSettingAsNumber:(NSNumber *)val forKey:(NSString *)key
{
	[self initStatics];
	
	[s_settingsDict setObject:val forKey:key];
    [s_userSettingsDict setObject:val forKey:key];

}

+ (NSString *) getThemeName
{
    return nil;
}


+ (NSString *) getThemeImageNameOfType: (NSString *) imageType forOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    NSString *p = (DEVICE_IS_IPAD) ? @"iPad" : @"iPhone";
    
    NSString *themeName = [Settings getThemeName];
    
    BOOL bIsPortrait = ((interfaceOrientation == UIInterfaceOrientationPortrait) || 
                        (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
    NSString *o = (bIsPortrait) ? @"_portrait" : @"_landscape";
    // orientation doesnt matter for the open button
    if( [imageType isEqualToString:@"divider_open"] )
    {
        o = @"";
    }
    
    NSString *imgName;
    
    // some special cases:paper and wood use same border
    if( [imageType isEqualToString:@"border"] && ![themeName isEqualToString:@"aluminum"] )
    {
       imgName = [NSString stringWithFormat:@"%@_%@%@", p, imageType, o];
    }
    else 
    {
        imgName = [NSString stringWithFormat:@"%@_%@_%@%@", p, imageType ,themeName, o];
    }
    
    
    return imgName;
}


// Check to make sure dictionary has been initialize
#pragma mark - init/destroy

+ (void) initStatics
{
	if( s_settingsDict == nil ) {
		[Settings loadSettings];
	}
}



+ (void) reset
{
	// reset our defaults
    [Settings releaseStatics];
	
	s_settingsDict = [Settings getNewSettingsDictionary];
	s_userSettingsDict = [Settings getNewSettingsDictionary];
}

+ (NSMutableDictionary *) getNewSettingsDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    // identifying information
	[dict setObject:@"" forKey:CLIENT_LOGIN_KEY];
	[dict setObject:@"" forKey:CLIENT_PASSWORD_KEY];
	[dict setObject:[NSNumber numberWithBool:NO] forKey:CLIENT_REMEMBER_PASSWORD];

#ifdef APPLE_STORE
    [dict setObject:CSD_SERVER forKey:SERVER_URL_KEY];
    [dict setObject:[NSString stringWithFormat:@"https://%@", CSD_SERVER] forKey:SERVER_URL_KEY];

#else
#endif
	
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    
    // user rights
    [dict setObject:[NSMutableArray array] forKey:CLIENT_RIGHTS_KEY];
    [dict setObject:[NSMutableArray array] forKey:FUNCTIONALGROUP_IDS];
    
    // organization info
    [dict setObject:@"" forKey:CLIENT_ORGANIZATION_ID];
    [dict setObject:@"" forKey:CLIENT_ORGANIZATION_NAME];
    [dict setObject:@"" forKey:USER_ROLES];
    [dict setObject:@"" forKey:USER_TYPE];
    [dict setObject:@"" forKey:DEFAULT_STORE];
    
	[dict setObject:@"60" forKey:TIMEOUT_KEY];
	
	[dict setObject:@"" forKey:MOBILE_DEVICE_ID];
	    
    NSMutableDictionary *networkOptions = [[NSMutableDictionary alloc] init ];
    [networkOptions setObject:[NSNumber numberWithBool:YES] forKey:kNetworkSyncKey];
    [networkOptions setObject:[NSNumber numberWithBool:YES] forKey:kWIFIFileKey];
    [networkOptions setObject:[NSNumber numberWithBool:YES] forKey:kWIFIContentKey];
    [networkOptions setObject:[NSNumber numberWithBool:YES] forKey:kWIFICodingKey];
    
    [dict setObject:networkOptions forKey:kUserNetworkSyncOptionsKey];
    
    return dict;
}

+ (void) loadSettings
{
	// reinit the settings object
	[Settings reset];
	
	// add objects from user defaults
	NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
	
	[s_settingsDict addEntriesFromDictionary:[[NSUserDefaults standardUserDefaults] persistentDomainForName:bundleId ]];
    
    [s_userSettingsDict addEntriesFromDictionary:[s_settingsDict objectForKey:[Settings currentUserSettingsKey]]];
}

+ (void) save2
{
    NSLog(@"current thread, thread = %@", [NSThread currentThread]);
    
    NSLog(@"make sure we are on main thread, thread = %@", [NSThread currentThread]);
    NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
    
    id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
    if( workaround51Crash != nil )
    {
        [s_settingsDict setObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
    }
    
    
    [s_settingsDict setObject:s_userSettingsDict forKey:[Settings currentUserSettingsKey]];
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:s_settingsDict forName:bundleId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    /*
     NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
     
     id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
     if( workaround51Crash != nil )
     {
     [s_settingsDict setObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
     }
     
     
     [s_settingsDict setObject:s_userSettingsDict forKey:[Settings currentUserSettingsKey]];
     [[NSUserDefaults standardUserDefaults] setPersistentDomain:s_settingsDict forName:bundleId];
     [[NSUserDefaults standardUserDefaults] synchronize];
     */
}

+ (void) save
{
    
    
    NSLog(@"current thread, thread = %@", [NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"make sure we are on main thread, thread = %@", [NSThread currentThread]);
        NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
        
        id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
        
        if( workaround51Crash != nil ) {
            [s_settingsDict setObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
        }
        
        @synchronized(s_userSettingsDict) {
            [s_settingsDict setObject:s_userSettingsDict forKey:[Settings currentUserSettingsKey]];
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:s_settingsDict forName:bundleId];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    });
    
    /*
    NSString * bundleId = [[NSBundle mainBundle] bundleIdentifier];
	
    id workaround51Crash = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
    if( workaround51Crash != nil )
    {
        [s_settingsDict setObject:workaround51Crash forKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
    }

    
    [s_settingsDict setObject:s_userSettingsDict forKey:[Settings currentUserSettingsKey]];
	[[NSUserDefaults standardUserDefaults] setPersistentDomain:s_settingsDict forName:bundleId];
	[[NSUserDefaults standardUserDefaults] synchronize];
    */
}

+ (void) releaseStatics
{
	if( s_settingsDict != nil ) {
		s_settingsDict = nil;
    }
    if( s_userSettingsDict != nil ) {
		s_userSettingsDict = nil;
	}
}

#pragma mark - User Management

+ (void) switchToUser: (NSString *) userName withPassword:(NSString *) pwd andServer:(NSString *) serverName
{
    // save out the old
    [Settings save];
        
    // repopulate the user dictionary
    s_userSettingsDict = [Settings getNewSettingsDictionary];
    [s_userSettingsDict addEntriesFromDictionary:[s_settingsDict objectForKey:[Settings userSettingsKey:userName onServer:serverName]]];
    
    // and move the preferences into the present dictionary
    [s_settingsDict addEntriesFromDictionary:s_userSettingsDict];
    if (userName) {
        [Settings setSetting:userName forKey:CLIENT_LOGIN_KEY];
    }
    if (pwd) {
        [Settings setSetting:pwd forKey:CLIENT_PASSWORD_KEY];
    }
    if (serverName) {
        [Settings setSetting:serverName forKey:SERVER_URL_KEY];
    }
    
    
    [Settings save];
}

+ (BOOL) userExists: (NSString *) userName onServer:(NSString *) serverName
{
    NSString *key = [Settings userSettingsKey:userName onServer:serverName];
    
    NSDictionary *userSettingsDict = [s_settingsDict objectForKey:key];
    
    return (userSettingsDict != nil);
    
}

+ (BOOL) userIsValid: (NSString *) userName withPassword:(NSString *) pwd andServer:(NSString *) serverName
{
    NSString *key = [Settings userSettingsKey:userName onServer:serverName];
    
    NSDictionary *userSettingsDict = [s_settingsDict objectForKey:key];
    
    return ((userSettingsDict != nil) &&
            [userName isEqualToString: [userSettingsDict objectForKey:CLIENT_LOGIN_KEY]] &&
            [pwd isEqualToString:[userSettingsDict objectForKey:CLIENT_PASSWORD_KEY]] &&
            [serverName isEqualToString:[userSettingsDict objectForKey:SERVER_URL_KEY]]);
}

+ (NSString *) userSettingsKey: (NSString *) userName onServer: (NSString *) server
{
    
    NSString *userSettingsKey = [NSString stringWithFormat:@"USER_SETTINGS_%@_%@", userName, server];
    
    return userSettingsKey;
    
}

+ (NSString *) currentUserSettingsKey
{
    NSString *login = [s_settingsDict objectForKey:CLIENT_LOGIN_KEY];
	NSString *server = [s_settingsDict objectForKey:SERVER_URL_KEY];
    
    return [Settings userSettingsKey:login onServer:server];
}


@end

