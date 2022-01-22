//
//  UIUtility.m
//  TabBarBilling
//
//  Created by Herman on 2011-04-04.
//  Copyright 2011 Tuvalu Software. All rights reserved.
//

#import "UIUtility.h"


@implementation UIUtility

+(void)showAlert:(NSString*)title withMessage:(NSString*)message{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
}

@end
