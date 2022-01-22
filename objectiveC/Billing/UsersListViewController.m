//
//  UsersListViewController.m
//  Jobs
//
//  Created by .D. .D. on 2/15/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "UsersListViewController.h"
#import "DataRepository.h"
#import "UserAggregate.h"
/////#import "UserEditViewController.h"
#import "User_Imp.h"

@interface UsersListViewController ()
@property (nonatomic, strong) NSArray *users;
@end

@implementation UsersListViewController

@synthesize tableView;
@synthesize addDelegate;
@synthesize delegateKey;
@synthesize userAggregate;
@synthesize showRecordIdInList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self objectSyncComplete:self.userAggregate];
    if (self.showAddItem) {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemPressed:)];
        self.navigationItem.rightBarButtonItem = addBtn;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    //self.popoverCtrl = nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellTableIdentifier = @"userListcell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellTableIdentifier];
    }
    
    User *user = [self.users objectAtIndex:indexPath.row];
    
    if (showRecordIdInList) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [user Name], user.rcoRecordId];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [user Name]];
    }
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@", user.company, user.phone];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [self.users objectAtIndex:indexPath.row];
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:user forKey:self.delegateKey];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Actions

-(void)addItemPressed:(id)sender {
}

#pragma mark - RCO data delegate view data source

- (void)objectSyncComplete: (Aggregate *) aggregate
{
    [self resetData];
    [self.progressHUD hide:YES];
}

- (void) resetData {
    self.users = [self.userAggregate getAllUsers];
    
    [self.tableView reloadData];
}

#pragma mark AddObject Delegate

-(void)didSaveObject:(RCOObject*)object {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    [self objectSyncComplete:self.userAggregate];
}

-(void)didRemoveObject:(RCOObject*)object {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)didCancelObject:(RCOObject*)object {
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    [self objectSyncComplete:self.userAggregate];
}

@end
