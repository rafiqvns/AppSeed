//
//  UINavigationController+Rotation_iOS6.h
//  MobileOffice
//
//  Created by .D. .D. on 5/17/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Rotation_iOS6)
- (BOOL)shouldAutorotate;
- (NSUInteger)supportedInterfaceOrientations;
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation;
@end
