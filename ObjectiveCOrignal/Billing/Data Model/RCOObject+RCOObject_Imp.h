//
//  RCOObject+RCOObject_Imp.h
//  MobileOffice
//
//  Created by .R.H. on 12/9/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCOObject.h"

@class Aggregate;

#define RCO_OBJECT_TYPE_RECORD_ID @"[[recordid]]"
#define RCO_OBJECT_TYPE_MOBILE_RECORD_ID @"[[mobilerecordid]]"

#define MAX_RCOCATEGORIES   5

#define RCOOBJECT_TIMESTAMP      @"rcoObjectTimestamp"
#define RCOOBJECT_NEEDSDELETING  @"objectNeedsDeleting"

#define kRCOObjectShortDescription @"RCOObjectShortDescription"

#define RCOOBJECT_LINES_TO_SAVE @"rcoObjectLinesToSave"

#define RCOOBJECT_RECORDID  @"rcoRecordId"
#define RCOOBJECT_OBJECTID  @"rcoObjectId"
#define RCOOBJECT_MOBILERECORDID  @"rcoMobileRecordId"
#define RCOOBJECT_OBJECTTYPE  @"rcoObjectType"
#define RCOOBJECT_OBJECT_CLASS  @"rcoObjectClass"
#define RCOOBJECT_CONTENT_SIZE  @"rcoObjectContentSize"

#define Key_ReloadObject @"ReloadObject"
#define Key_ReloadList @"ReloadList"

#define ItemTypePhoto @"photo"
#define ItemTypeNote @"note"

#define CreateDateCodingField @"Creation Date"

@interface RCOObject (RCOObject_Imp)

// returns objects aggregate
- (Aggregate *) aggregate;

/**
 @brief Retrieves a displayable name 
 @return the name 
 */
- (NSString *)displayableName;

/**
 @brief Retrieves a displayable Number 
 @return the number
 */
- (NSString *)displayableNumber;
- (NSString*)Name;
- (NSString*)customId;

// object status manipulation


// server sync handling
- (BOOL) isDirty;
- (BOOL) existsOnServer;
- (BOOL) existsOnServerNew;

- (BOOL) needsUploading;
- (BOOL) needsUploadingIncludingDetails;
- (void) setNeedsUploading: (BOOL)needsUploading;
- (BOOL) isUploading;
- (void) setIsUploading: (BOOL) isUploading;

/*- (BOOL) needsDownloading;
- (void) setNeedsDownloading: (BOOL)needsDownloading;
- (BOOL) isDownloading;
- (void) setIsDownloading: (BOOL)needsIsloading;
*/

- (BOOL) isCreating;
- (void) setIsCreating: (BOOL) isCreating;
- (BOOL) isInitialized;

- (BOOL) needsDeleting;
- (void) setNeedsDeleting: (BOOL) needsDeleting;

// content handling
- (BOOL) hasContent;
- (void) setHasNoContent;
- (BOOL) contentNeedsDownloading;
- (void) setContentNeedsDownloading: (BOOL) needsDownloading;
- (BOOL) contentIsDownloading;
- (void) setContentIsDownloading: (BOOL) isDownloading;
- (BOOL) contentNeedsUploading;
- (void) setContentNeedsUploading: (BOOL) needsUploading;
- (BOOL) contentIsUploading;
- (void) setContentIsUploading: (BOOL) isUploading;

// category access
- (NSString *) getCatPropName: (NSInteger) idx;
- (NSString *) getCatValue: (NSInteger) idx;
- (NSArray *) getCatValues;

- (NSString *) rcoDateToString: (NSDate *) aDate;
- (NSString *) rcoTimeHHMMToString: (NSDate *) aTime;
- (NSString *) rcoTimeToString: (NSDate *) aTime;
- (NSString *) rcoDateTimeString: (NSDate *) aDate;
- (NSString *) rcoDateRMSToString: (NSDate *) aDate;

- (NSDate *) rcoStringToDate: (NSString *) strDate;
- (NSDate *) rcoStringToDateTime: (NSString *) aDateStr;
- (NSString *) rcoDateTimeRMSToString: (NSDate *) aDate;
- (NSString *) rcoDateRMSToString2: (NSDate *) aDate;
- (NSString *) rcoDateTimeRMSToStringNoSeconds: (NSDate *) aDate;


- (NSString*)escapeInchAndFeet:(NSString*)str;
- (NSString*)objectShortDescription;
- (NSDate*)creationDate;

- (void) removeValue:(NSString*)value forKey:(NSString*)key;

- (void)addSearchString:(NSString*)searchString;
- (NSString*)escapeString:(NSString*)string;
- (NSString*)getUploadCodingFieldFomValue:(id)value;
- (NSString*)getUploadCodingFieldFomDateTime:(id)value;
- (NSString*)getUpdateCSVString;

- (NSDate*)getCreationDate;

- (void)addLinkedObject:(NSString*)objMobileRecordId;

- (NSString*)getImageURL:(BOOL)isFullImage;
- (NSString*)getImageURLWithKey:(NSString*)key;

+ (NSString*)objectFilterKey;

+ (BOOL)stringIsNumber:(NSString*)strValue;

+(NSSortDescriptor*)getSortDescriptorForTimeKey:(NSString*)timeKey ascending:(BOOL)ascending;

+(NSArray*)getStatesList:(BOOL)showName andAbbreviation:(BOOL)showAbbreviation;
+(NSString*)getStateNameForAbbreviation:(NSString*)abbreviation;
+(NSString*)getStateAbbreviationForState:(NSString*)state;
+(NSString*)getStateAbbreviationFromString:(NSString*)string;
+(NSString*)getStateNameFromString:(NSString*)string;
+(NSString*)getStateNameForAbbreviation:(NSString*)abbreviation andFormatted:(BOOL)showFormatted;

@end

// editing wrap around layer
@interface RCOObjectEditLayer : NSObject {

    NSMutableDictionary * m_EditedValues;
    RCOObject           * m_rcoObj;
}

@property (nonatomic, strong) NSMutableDictionary* editedValues;
@property (nonatomic, strong) RCOObject* rcoObj;

- (id)init;

// handling difference between edit data and original object
- (BOOL) isDirty;
- (void) saveEdits;

- (id) getValueForProp: (NSString *) prop;
- (id) getOrigValueForProp: (NSString *) prop;
- (void) setValue:(NSObject *) value forProp: (NSString *) prop;

@end

