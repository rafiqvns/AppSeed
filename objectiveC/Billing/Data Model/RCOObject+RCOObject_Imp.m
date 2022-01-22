//
//  RCOObject+RCOObject_Imp.m
//  MobileOffice
//
//  Created by .R.H. on 12/9/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCOObject+RCOObject_Imp.h"
#import "Aggregate.h"
#import "DataRepository.h"

@implementation RCOObject (RCOObject_Imp)



#pragma mark - Object Utilities

- (Aggregate *) aggregate;
{
    return [[DataRepository sharedInstance] getAggregateForClass:self.rcoObjectClass];
}

/**
 @brief retrieves object's displayable name
 @return displayable name
 
 */
- (NSString *)displayableName
{
    SEL nameSel = @selector(constructedName); 
    if ( [self respondsToSelector:nameSel] )
        return [self performSelector:nameSel];
    else
        return [NSString stringWithFormat:@"%@ %@", self.rcoObjectClass, self.rcoObjectId];
}
/**
 @brief retrieves object's displayable number
 @return displayable number
 
 */
- (NSString *)displayableNumber
{
    SEL numberSel = @selector(constructedNumber); 
    if ( [self respondsToSelector:numberSel] )
        return [self performSelector:numberSel];
    else
        return self.rcoObjectId;
}

#pragma mark - Status Utilities


#pragma mark - Object upload status

// checking relationship to server, for objects created by client
- (BOOL) existsOnServer
{
    NSLog(@"THread: %@", [NSThread currentThread]);
    
    return ([self rcoObjectId] != nil && ![[self rcoObjectId] hasPrefix:[self rcoObjectClass]] && ![[self rcoObjectId] hasPrefix:@"("]);
    //09.10.2018 return (self.rcoObjectId != nil && ![self.rcoObjectId hasPrefix:self.rcoObjectClass] && ![self.rcoObjectId hasPrefix:@"("]);
}

- (BOOL) existsOnServerNew
{
    BOOL existOnServer = [self existsOnServer];
    return (existOnServer || [self.rcoRecordId length]);
}

// querying creation/upload status

- (BOOL) isDirty
{
    return [self needsUploading] || [self needsDeleting];
}

- (BOOL) needsUploadingIncludingDetails
{
    if ([self needsUploading])
        return true;
    
    NSArray *details = [[self aggregate] getObjectDetails:self.rcoObjectId];
    for( RCOObject *detail in details )
    {
        if( [detail needsUploadingIncludingDetails] )
        {
            return true;
        }
    }
    
    return false;
}


- (BOOL) needsUploading
{
	return ![self existsOnServer] || [self.objectNeedsUploading boolValue];
}

- (void) setNeedsUploading: (BOOL) needsUploading
{
    if( [self.objectNeedsUploading boolValue] != needsUploading) {
        self.objectNeedsUploading = [NSNumber numberWithBool:needsUploading];
    }
    Aggregate *agg = [self aggregate];
    
    // rfh - not thread safe
    @synchronized(agg.objectsToUpload) {
        if( needsUploading != [agg.objectsToUpload containsObject:self.rcoObjectId]) {
            if( needsUploading ) {
                [agg.objectsToUpload addObject:self.rcoObjectId];
            } else {
                [agg.objectsToUpload removeObject:self.rcoObjectId];
            }
        }
    }
}
-(NSString*)info {
    return nil;
}

- (NSString*)Name {
    return nil;
}

- (NSString*)customId {
    return nil;
}

- (BOOL) isUploading
{
    return ([self.objectIsUploading boolValue] || [self isCreating]);


}

- (void) setIsUploading: (BOOL) isUploading
{
    self.objectIsUploading = [NSNumber numberWithBool:isUploading];
}

- (BOOL) isCreating
{
    return false;
}

- (void) setIsCreating: (BOOL) isCreating
{
   
}

- (BOOL) isInitialized    
{
    return [self.rcoObjectTimestamp longLongValue] >= 0;
}

- (BOOL) needsDeleting
{
    return [self.objectNeedsDeleting boolValue];
}

- (void) setNeedsDeleting: (BOOL) isDeleting
{
    self.objectNeedsDeleting = [NSNumber numberWithBool:isDeleting];
   
}
#pragma mark - Object Download Status
- (BOOL) needsDownloading
{
    return ([self.objectNeedsDownloading boolValue]);
}

- (void) setNeedsDownloading: (BOOL) needsDownloading
{
    self.objectNeedsDownloading = [NSNumber numberWithBool:needsDownloading]; 
}

- (BOOL) isDownloading
{
    return ([self.objectIsDownloading boolValue]);
}

- (void) setIsDownloading: (BOOL) isDownloading
{
    self.objectIsDownloading = [NSNumber numberWithBool:isDownloading];
}


#pragma mark - Content Download/Upload Status
// content handling
- (BOOL) hasContent
{
    if( [[self rcoFileTimestamp] longLongValue] ==  100 ||  [[self rcoFileTimestamp] longLongValue] == 0)
        self.rcoFileTimestamp = nil;
    
    return [self rcoFileTimestamp] != nil;
}

- (void) setHasNoContent
{
    self.rcoFileTimestamp = nil;
}

- (BOOL) contentNeedsDownloading
{
    return [self hasContent] && [self.fileNeedsDownloading boolValue];
}

- (void) setContentNeedsDownloading: (BOOL) needsDownloading
{
    [self setFileNeedsUploading:[NSNumber numberWithBool:needsDownloading]];
    self.fileNeedsDownloading = [NSNumber numberWithBool:needsDownloading];
    
}


- (BOOL) contentIsDownloading
{
    return [self.fileIsDownloading boolValue];
}

- (void) setContentIsDownloading:(BOOL)isDownloading
{
   self.fileIsDownloading = [NSNumber numberWithBool:isDownloading]; 
}


- (BOOL) contentNeedsUploading
{
    return [self.fileNeedsUploading boolValue];;
}

- (void) setContentNeedsUploading: (BOOL) needsUploading
{
    self.fileNeedsUploading = [NSNumber numberWithBool:needsUploading]; 
}

- (BOOL) contentIsUploading
{
    return [self.fileIsUploading boolValue];;
}

- (void) setContentIsUploading: (BOOL) isUploading
{
    self.fileIsUploading = [NSNumber numberWithBool:isUploading]; 
}

#pragma mark - Cat Access
// category access
- (NSString *) getCatPropName: (NSInteger) idx
{
    if( idx < 0 || idx >= MAX_RCOCATEGORIES )
        return nil;
    
    return [NSString stringWithFormat:@"cat%d", idx+1];
    
}

- (NSString *) getCatValue: (NSInteger) idx
{
    NSString *propName = [self getCatPropName:idx];
    
    if(propName != nil )
    {
        return [self valueForKey:propName];
    }

    return nil;
}

- (NSArray *) getCatValues
{
    NSMutableArray *categories = [[NSMutableArray alloc] initWithCapacity:6 ];
    for( NSInteger idx = 0; idx < MAX_RCOCATEGORIES; idx++ )
    {
        NSString *v = [self getCatValue:idx];
        if( [v length] )
        {
            [categories addObject:v];
        }
    }
    
    return categories;
}

- (NSDate *) rcoStringToDateTime: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"MM/dd/yyyy HH:mm:ss"];
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    if ([aDateStr length] && !theDate) {
        NSLog(@"wrong date formattt");
    }
    
    return theDate;
}

- (NSString *) rcoDateTimeString: (NSDate *) aDate
{
    if (!aDate) {
        return @"";
    }
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    return date_str;
}

- (NSString *) rcoDateToString: (NSDate *) aDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSString *date_str =[dateFormat stringFromDate:aDate];
    
    
    return date_str;
}

- (NSDate *) rcoStringToDate: (NSString *) strDate
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date =[dateFormat dateFromString:strDate];
    
    if ([strDate length] && !date) {
        NSLog(@"wrong date formattt2");
    }

    return date;
}

- (NSString *) rcoTimeToString: (NSDate *) aTime
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"HH:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aTime];
    
    
    return time_str;
}

- (NSString *) rcoTimeHHMMToString: (NSDate *) aTime
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"HH:mm"];
    
    NSString *time_str =[f stringFromDate:aTime];
    
    
    return time_str;
}


- (NSString *) rcoDateRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    
    return time_str;
}

- (NSString *) rcoDateRMSToString2: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}
- (NSString *) rcoDateTimeRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSString *) rcoDateTimeRMSToStringNoSeconds: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}


-(NSString*)escapeInchAndFeet:(NSString*)str {
    
    NSString *res = [NSString stringWithFormat:@"%@", str];
    res = [res stringByReplacingOccurrencesOfString:@"\"" withString:@" inch"];
    res = [res stringByReplacingOccurrencesOfString:@"\'" withString:@" feet"];
    
    return res;
}

-(NSString*)objectShortDescription {
    return @"NoDesc";
}

-(NSDate*)creationDate {
    // returns the creation date of the object from the mobile record id value
    NSDate *date = nil;
    NSArray *components = [self.rcoMobileRecordId componentsSeparatedByString:@"-"];
    
    if ([components count]) {
        NSString *timestampStr = [components lastObject];
        
        NSTimeInterval timestamp = [timestampStr longLongValue];
        
        date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    }
    
    return date;
}

- (void) removeValue:(NSString*)value forKey:(NSString*)key {
    // used to remove a value from a key, this can be comma separated values
    NSString *keyValue = [self valueForKey:key];
    NSMutableArray *values = [NSMutableArray arrayWithArray:[keyValue componentsSeparatedByString:@","]];
    if ([values count]) {
        if ([values containsObject:value]) {
            [values removeObject:value];
            [self setValue:[values componentsJoinedByString:@","] forKey:key];
        }
    }
}

-(void)addSearchString:(NSString*)searchString {
    if ([searchString length]) {
        if ([self.rcoObjectSearchString length] == 0) {
            self.rcoObjectSearchString = searchString;
        } else {
            self.rcoObjectSearchString = [NSString stringWithFormat:@"%@ %@", self.rcoObjectSearchString, searchString];
        }
    }
}
- (NSString*)escapeString:(NSString*)string {
    if ([string length] == 0) {
        return nil;
    }
    NSString *str = [NSString stringWithFormat:@"%@", string];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return str;
}

- (NSString*)getUploadCodingFieldFomValue:(id)value {
    if ([value isKindOfClass:[NSString class]]) {
        if (value) {
            return (NSString*)value;
        } else {
            return @"";
        }
    } else if ([value isKindOfClass:[NSDate class]]) {
        return [self rcoDateToString:(NSDate*) value];
    } else if ([value isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@", (NSNumber*)value];
    }
    
    return @"";
}

- (NSString*)getUploadCodingFieldFomDateTime:(id)value {
    if ([value isKindOfClass:[NSDate class]]) {
        return [self rcoDateTimeString:(NSDate*) value];
    }
    
    return @"";
}

- (NSString*)getUpdateCSVString {
    return nil;
}

- (NSDate*)getCreationDate {
    // returns the date when the object was created on the local DB
    NSArray *mobileRecordIdComp = [self.rcoMobileRecordId componentsSeparatedByString:@"-"];
    if (!mobileRecordIdComp.count) {
        return nil;
    }
    NSString *timeStampStr = [mobileRecordIdComp lastObject];
    NSTimeInterval timeStamp = [timeStampStr longLongValue];
    
    return [NSDate dateWithTimeIntervalSince1970:timeStamp];
}

-(void)addLinkedObject:(NSString*)objMobileRecordId {
    if ([objMobileRecordId length] == 0) {
        return;
    }
    
    //NSArray *str = self.fileLog;
    NSMutableArray *comp = [NSMutableArray arrayWithArray:[self.fileLog componentsSeparatedByString:@","]];
    if (!comp) {
        comp = [NSMutableArray array];
    }
    [comp addObject:objMobileRecordId];

    self.fileLog = [comp componentsJoinedByString:@","];
}

- (NSString*)getImageURL:(BOOL)isFullImage {
    return nil;
}

- (NSString*)getImageURLWithKey:(NSString*)key {
    return nil;
}

+ (NSString*)objectFilterKey {
    return @"NotSet";
}

+ (BOOL)stringIsNumber:(NSString*)strValue {
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];

    if ([strValue rangeOfCharacterFromSet:notDigits].location == NSNotFound) {
        // newString consists only of the digits 0 through 9
        return YES;
    }
    return NO;
}

+(NSSortDescriptor*)getSortDescriptorForTimeKey:(NSString*)timeKey ascending:(BOOL)ascending {
    
    if (timeKey.length == 0) {
        return nil;
    }
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:timeKey
                                                         ascending:ascending
                                                        comparator:^NSComparisonResult(NSString*  _Nonnull time1, NSString*  _Nonnull time2) {
                                                            
                                                            NSArray *comp1 = [time1 componentsSeparatedByString:@":"];
                                                            NSArray *comp2 = [time2 componentsSeparatedByString:@":"];
                                                            
                                                            if ((comp1.count != 3) ||(comp2.count != 3)) {
                                                                return nil;
                                                            }
                                                            
                                                            
                                                            if ([comp1 objectAtIndex:0] != [comp2 objectAtIndex:0]) {
                                                                return [[comp1 objectAtIndex:0] compare:[comp2 objectAtIndex:0] options:NSNumericSearch];
                                                            }
                                                            
                                                            if ([comp1 objectAtIndex:1] != [comp2 objectAtIndex:1]) {
                                                                return [[comp1 objectAtIndex:1] compare:[comp2 objectAtIndex:1] options:NSNumericSearch];
                                                            }
                                                            
                                                            return [[comp1 objectAtIndex:2] compare:[comp2 objectAtIndex:2] options:NSNumericSearch];
                                                        }];
    return sd;
}

+(NSArray*)getStatesList:(BOOL)showName andAbbreviation:(BOOL)showAbbreviation {
    if (!showName && !showAbbreviation) {
        return nil;
    }
    
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    NSDictionary *stateAbbreviationsMap = [[NSDictionary alloc] initWithContentsOfFile:plist];
    NSArray *statesNames = [stateAbbreviationsMap.allKeys sortedArrayUsingSelector:@selector(compare:)];

    NSMutableArray *states = [NSMutableArray array];
    for (NSString *str in statesNames) {
        NSString *stateAbreviation = [stateAbbreviationsMap objectForKey:str];
        NSString *stateFormatted = nil;
        if (showAbbreviation) {
            stateFormatted = [NSString stringWithFormat:@"%@, %@", [str capitalizedString], stateAbreviation];
        } else {
            stateFormatted = [NSString stringWithFormat:@"%@", [str capitalizedString]];
        }
        [states addObject:stateFormatted];
    }
    return states;
}

+(NSString*)getStateAbbreviationFromString:(NSString*)string {
    if (string.length < 2) {
        return nil;
    } else if (string.length == 2) {
        return string;
    } else {
        NSArray *comp = [string componentsSeparatedByString:@", "];
        if (comp.count == 1) {
            // the string contains just the state name
            NSString *stateName = [comp objectAtIndex:0];
            return [RCOObject getStateAbbreviationForState:stateName];
        } else if (comp.count == 2) {
            // string contains name and abbreviation
            NSString *abbreviation = [comp objectAtIndex:1];
            return abbreviation;
        } else {
            return nil;
        }
    }
    return nil;
}

+(NSString*)getStateNameFromString:(NSString*)string {
    if (string.length < 2) {
        return nil;
    } else if (string.length == 2) {
        // is abbreviation
        return [RCOObject getStateNameForAbbreviation:string];
    } else {
        NSArray *comp = [string componentsSeparatedByString:@", "];
        if (comp.count == 1) {
            // the string contains just the state name
            NSString *stateName = [comp objectAtIndex:0];
            return stateName;
        } else if (comp.count == 2) {
            // string contains name and abbreviation
            NSString *abbreviation = [comp objectAtIndex:0];
            return abbreviation;
        } else {
            return nil;
        }
    }
    return nil;
}


+(NSString*)getStateNameForAbbreviation:(NSString*)abbreviation {
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    NSDictionary *stateAbbreviationsMap = [[NSDictionary alloc] initWithContentsOfFile:plist];
    NSArray *keys = stateAbbreviationsMap.allKeys;
    for (NSString *key in keys) {
        NSString *val = [stateAbbreviationsMap objectForKey:key];
        if ([[val uppercaseString] isEqualToString:[abbreviation uppercaseString]]) {
            return [key capitalizedString];
        }
    }
    return nil;
}

+(NSString*)getStateNameForAbbreviation:(NSString*)abbreviation andFormatted:(BOOL)showFormatted {
    if (!abbreviation.length) {
        return nil;
    }
    NSString *stateName = [RCOObject getStateNameForAbbreviation:abbreviation];
    if (showFormatted) {
        return [NSString stringWithFormat:@"%@, %@", stateName, abbreviation];
    } else {
        return [NSString stringWithFormat:@"%@", stateName];
    }
}

+(NSString*)getStateAbbreviationForState:(NSString*)state {
    NSString *plist = [[NSBundle mainBundle] pathForResource:@"USStateAbbreviations" ofType:@"plist"];
    NSDictionary *stateAbbreviationsMap = [[NSDictionary alloc] initWithContentsOfFile:plist];
    NSString *stateName = [stateAbbreviationsMap objectForKey:[state uppercaseString]];
    return stateName;
}


@end

// editing wrap around layer
@implementation RCOObjectEditLayer

@synthesize editedValues=m_EditedValues;
@synthesize rcoObj=m_rcoObj;


- (id)init
{
    if( self = [super init] )
    {
        self.editedValues = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}


// handling difference between edit data and original object
- (BOOL) isDirty
{
    for( NSString *propName in self.editedValues.allKeys )
    {
        id theOrigVal = [self getOrigValueForProp:propName];
        id theVal = [self getValueForProp:propName];
        
        if( ! [theVal isEqual: theOrigVal] )
        {
            return true;
        }
        
    }
    
    return false;
}

// move edited data into object
- (void) saveEdits
{
    NSArray *origKeys = self.editedValues.allKeys;
    for( NSString *propName in origKeys )
    {
        id theOrigVal = [self getOrigValueForProp:propName];
        id theVal = [self getValueForProp:propName];
        
            
        if( ! [theVal isEqual: theOrigVal] )
        {
            NSError *anError=nil;
            if( [self.rcoObj validateValue:&theVal forKey:propName error:&anError] )
            {
                [self.rcoObj setValue:theVal forKey:propName]; 
                [self.editedValues removeObjectForKey:propName];
                
                //NSLog(@"saveObjectEdits %@ %@", propName, theVal);
            }
            else
            {
                NSLog(@"Invalid data for %@ %@ %@: %@", self.rcoObj.rcoObjectId, self.rcoObj.rcoObjectType, propName, [anError localizedDescription]);
                NSArray* detailedErrors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
                if(detailedErrors != nil && [detailedErrors count] > 0) 
                {
                    for(NSError* detailedError in detailedErrors) 
                    {
                        NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                    }
                }
                else {
                    NSLog(@"  %@", [anError userInfo]);
                }
            }
        }
    }
}

// get and set values for properties of objects
- (id) getValueForProp: (NSString *) prop
{
    if( [[self.editedValues allKeys] indexOfObject:prop] != NSNotFound )
    {
        return [self.editedValues valueForKey:prop];
    }
    
    return [self getOrigValueForProp:prop];
}

// return unedited properties
- (id) getOrigValueForProp: (NSString *) prop
{
    SEL aSelector = NSSelectorFromString(prop);
    
    if( [self.rcoObj respondsToSelector:aSelector] )
    {
        return [self.rcoObj valueForKey:prop];
    }
    
    return nil;
}

- (void) setValue:(NSObject *) value forProp: (NSString *) prop 
{
    [self.editedValues setValue:value forKey:prop];
}

@end

