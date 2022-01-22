//
//  RCOVluesListResizableViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 3/6/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import "RCOVluesListResizableViewController.h"

@interface RCOVluesListResizableViewController ()

@end

@implementation RCOVluesListResizableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView {
    if (self.sectionNames.count > 0) {
        return self.sectionNames.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.sectionNames.count > 0) {
        return 1;
    } else {
        return self.values.count;
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [self.values objectAtIndex:indexPath.section];

    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:15.0f] constrainedToSize:CGSizeMake((self.tableView.frame.size.width - 20), 20000) lineBreakMode: UILineBreakModeWordWrap];

    if (textSize.height < 44) {
        return 44;
    } else {
        return textSize.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self configureTableViewHistory:theTableView cellForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)configureTableViewHistory:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifiecr = @"ItemHistoryDescCell";
    UITableViewCell *cell = nil;
    
    cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifiecr];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifiecr];
    }
    
    cell.textLabel.text = [self.values objectAtIndex:indexPath.section];
    
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
    cell.textLabel.numberOfLines = 100;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    
    return [self.sectionNames objectAtIndex:section];
}



@end
