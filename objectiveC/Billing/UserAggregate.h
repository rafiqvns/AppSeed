//
//  UserAggregate.h
//  Billing2
//
//  Created by .R.H. on 8/21/11.
//  Copyright 2011 RCO All rights reserved.
//

#import <Foundation/Foundation.h>


#import "Aggregate.h"
#import "User_Imp.h"

#define CREATE_USER @"createUser"
#define CREATE_USER_GROUP @"createUserGroup"
#define GET_USER_GROUP_MEMBERS @"getUserGroupMembers"

// functional group methods
#define CREATE_FUNCTIONAL_GROUP @"createFunctionalGroup"
#define ADD_USER_TO_FUNCTIONAL_GROUP @"addUserToFunctionalGroup"
#define DELETE_USER_FROM_FUNCTIONAL_GROUP @"deleteUserFromFunctionalGroup"
#define GET_FUNCTIONAL_GROUP_MEMBERS @"getFunctionalGroupMembers"


#define SET_USERS @"setUsers"
#define MOVE_USER_TO_GROUP @"moveUserToNamedGroup"


#define kCustomerRight  @"Mobile-Displaycustomersoftheorganization"
#define kCustomerSyncRight  @"Mobile-SyncCustomers"

#define kVendorRight  @"Mobile-Displayvendorsoftheorganization"
#define kVendorSyncRight  @"Mobile-SyncVendors"


#define kStaffRight  @"Mobile-Displayemployeesoftheorganization"
#define kStaffSyncRight  @"Mobile-SyncStaff"

//#define kLeadsRight  @"Mobile-DisplayLeads"
#define kLeadsRight  @"Mobile-DisplaySalesLeads"
#define kDealsRight  @"Mobile-DisplaySalesDeals"

#define kDealerRight  @"Mobile-DisplayDealer"
#define kProspectRight  @"Mobile-DisplayProspects"
#define kTechnicianSyncRight  @"Mobile-SyncTechnicians"
#define kMechanicSyncRight  @"Mobile-SyncMechanics"


#define kUserTypeStaff @"staff"
#define kUserTypeTechnician @"technician"
#define kUserTypeLabor @"labor"
#define kUserTypeCustomer @"client"
#define kUserTypeInstructor @"instructor"
#define kUserTypeStudent @"student"
#define kUserTypeVendor @"vendor"
#define kUserTypeDealer @"dealer"
#define kUserTypeDriver @"driver"
#define kUserTypeVendorGrower @"grower"
#define kUserTypeStaffManager @"manager"
#define kUserType @"userType"
#define kUserItemType @"itemType"

@interface UserSection : NSObject
{
@private
	NSString* __weak sectionHeader;
	NSArray* __weak usersArray;
	
}
-(id)initWithHeader:(NSString*)header andUsers:(NSArray*)userList;

@property (weak, readonly) NSString* sectionHeader;
@property (weak, readonly) NSArray* usersArray;

@end

@interface UserAggregate : Aggregate {
    
}

/*!
 Get all the clients sorted alphabetically
 @return NSArray of User entities
 */
-(NSArray*)getAllUsers;

/*!
 Get all the users ( cliens, vendors ..)
 @return NSArray of User entities
 */
-(NSArray*)getAllTypesOfUsers;

/*!
 Get all the users grouped into alphabetical groups
 @return NSArray containing UserSection objects
 */
-(NSArray*)getAllUsersGroupedAlphabetically;

/*!
 Get the user for specified user number, or nil if not found
 */
-(User*)getUserForNumber:(NSString*)userNum;

/*!
 Get the user for specified object id, or nil if not found
 */
-(User*)getUserForId:(NSString*)userId;

-(User*)getUserForRecordId:(NSString*)userRecordId;

-(User*)getUserWithEmployeeId:(NSString*)employeeId;

-(User*)getUserWithdDriverLicenseNumber:(NSString*)number andState:(NSString*)state;

/*!
 Get the users matching the specified object ids, or nil if not found
 */
-(NSArray*)getUsersMatchingId:(NSString*)userId;

/*!
 Get the users matching the specified Company, or nil if not found
 */
-(NSArray*)getUsersForCompany:(NSString*)company;

/*!
 Get the users matching the specified name, or nil if not found
 */
-(NSArray*)getUsersMatchingName:(NSString*)name;

/*
 Get the users matching the recordId, or nil if not found
 */
- (User *) getAnyUserWithRecordId: (NSString *) recordId;

- (User *) getAnyUserWithEmployeeId: (NSString *) employeeNumber;

- (User *) getAnyUserWithObjectId: (NSString *) recordId;

- (User *) getAnyUserWithNumber: (NSString *) customerNumber;

/*
 Get the users matching the company, or nil if not found
 */
- (User *) getAnyUserWithCompanyName: (NSString *) companyname;

- (User *) getAnyUserWithFirstName: (NSString *) firstName;

- (User *) getAnyUserWithFirstName: (NSString *) firstName andLastName:(NSString*)lastName;

- (User *) getAnyUserWithFirstName: (NSString *) firstName lastName:(NSString*)lastName andType:(NSString*)userType;

- (User *) getAnyUserWithFirstName: (NSString *) firstName andType:(NSString*)userType;

- (User *) getAnyUserWithLastName: (NSString *) lastName;

- (User *) getAnyUserWithDriverLicenseNumber: (NSString *) number andDriverLicenseState:(NSString*)state;

- (User *) getAnyUserWithEmail: (NSString *) email;

- (NSArray *) getAnyUsersWithEmails: (NSArray *) emails;

/* get user image */
-(UIImage*)getImageForUser:(NSString*)userNum size:(int) pels;

-(void)moveUserToGroup:(NSString*)userId groupName:(NSString*)name;

-(void)createNewUser:(NSDictionary*)info;

-(void)updateObject:(RCOObject *)object;

-(void)updateObject:(RCOObject *)object withData:(NSString*)dataStr;

/* caching methods*/
//loadUsersToCaching:  should not ce called outside the User Aggregate class
-(void)loadUsersToCaching;

-(NSDictionary*)getUserDictForRecordId:(NSString*)userRecordId;
-(void)removeUserFromCaching:(NSString*)userRecordId;
-(void)addUserToCaching:(NSDictionary*)userDict;


// helping methods
-(NSString*)getUpdateAddress1:(NSString*)address1 forRecordId:(NSString*)recordId;

-(void)getChildrenDirectoryIdsForGroupId:(NSString*)groupId andType:(NSString*)type;

-(NSArray*)getAllUsersWithIds:(NSArray*)ids;

#pragma mark UserGroup Methods

-(void)getUserGroupsForCompany:(NSString*)company;
-(void)createNewUserGroup:(NSString*)groupName forCompany:(NSString*)company;
-(void)getUserGroupMembers:(NSString*)groupName;

#pragma mark FunctionalGroup Methods

-(void)getFunctionalGroupsforCompany:(NSString* )name;
-(void)createFunctionalGroup:(NSString*)groupName forCompany:(NSString*)company;
-(void)getFunctionalGroupMembers:(NSString*)groupName;
-(void)addUser:(NSString*)userRecordId toFunctionalGroup:(NSString*)groupName;
-(void)deleteUser:(NSString*)userRecordId fromFunctionalGroup:(NSString*)groupName;
-(void)getRMSUserWithDriverLicenseNumber:(NSString*)driverLicenseNumber andState:(NSString*)driverLicenseState;
-(void)updateCurrentUserPosition;
@end
