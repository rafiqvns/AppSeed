//
//  UINavigationController+Rotation_iOS6.m
//  MobileOffice
//
//  Created by .D. .D. on 5/17/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "UINavigationController+Rotation_iOS6.h"

@implementation UINavigationController (Rotation_iOS6)

- (BOOL) shouldAutorotate{
    
    UIViewController *lastObject = [self.viewControllers lastObject];
    
    if ([lastObject isKindOfClass:[UITableViewController class]]) {
        // fix for the infinite recursion when trying to print an invoice
        return NO;
    }
    return [[self.viewControllers lastObject] shouldAutorotate];
}

- (NSUInteger) supportedInterfaceOrientations{
    UIViewController *lastObject = [self.viewControllers lastObject];
    
    if ([lastObject isKindOfClass:[UITableViewController class]]) {
        // fix for the infinite recursion when trying to print an invoice
        return UIInterfaceOrientationMaskPortrait;
    }

    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation{
    
    UIViewController *lastObject = [self.viewControllers lastObject];
    
    if ([lastObject isKindOfClass:[UITableViewController class]]) {
        // fix for the infinite recursion when trying to print an invoice
        return UIInterfaceOrientationPortrait;
    }

    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}

@end
