//
//  CSDTabBarViewController.m
//  CSD
//
//  Created by .D. .D. on 11/1/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDTabBarViewController.h"
#import "CSDEyeMovementViewController.h"
#import "CSDFormsListViewController.h"

@interface CSDTabBarViewController ()

@property (nonatomic, strong) UIViewController *ctrl1;
@property (nonatomic, strong) UIViewController *ctrl2;

@end

@implementation CSDTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UISegmentedControl *segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Info", @"PreTrip",@"Road", @"Eye",@"SWP", nil]];
    [segControl addTarget:self
                   action:@selector(viewModeChanged:)
         forControlEvents:UIControlEventValueChanged];
    [self.navigationItem setTitleView:segControl];
    
    self.ctrl1 = [[CSDEyeMovementViewController alloc] initWithNibName:@"CSDEyeMovementViewController" bundle:nil];
    //UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:ctrl1];
    CSDFormsListViewController *ctrl22 = [[CSDFormsListViewController alloc] initWithNibName:@"CSDFormsListViewController" bundle:nil];
    //UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:ctrl2];
    ctrl22.formNumber = @"01";
    self.ctrl2 = ctrl22;
    // Do any additional setup after loading the view from its nib.
   // self.viewControllers = [NSArray arrayWithObjects:ctrl1, ctrl2, nil];
    //self.viewControllers = [NSArray arrayWithObjects:nav1, nav2, nil];

}

-(IBAction)viewModeChanged:(UISegmentedControl*)sender {
    if (sender.selectedSegmentIndex == 0) {
        [self addChildViewController:self.ctrl1];
    } else {
    [self addChildViewController:self.ctrl2];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
