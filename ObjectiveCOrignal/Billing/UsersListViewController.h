//
//  UsersListViewController.h
//  Jobs
//
//  Created by .D. .D. on 2/15/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "Aggregate.h"
#import "AddObject.h"

@class UserAggregate;

@interface UsersListViewController : HomeBaseViewController <RCODataDelegate, UITableViewDataSource, UITableViewDelegate, AddObject> {
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id <AddObject> addDelegate;
@property (nonatomic, strong) NSString *delegateKey;
@property (nonatomic, weak) UserAggregate *userAggregate;
@property (nonatomic, assign) BOOL showAddItem;
@property (nonatomic, assign) BOOL showRecordIdInList;

@end
