//
//  PhotoViewController.h
//  Jobs
//
//  Created by .D. .D. on 2/19/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddObject.h"

@class GTLServiceDrive;
@interface PhotoViewController : UIViewController {
    
}

@property (nonatomic, strong) IBOutlet UIImageView *photoImageView;
@property (nonatomic, strong) UIImage *photoImage;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) GTLServiceDrive *driveService;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) id<AddObject> addDelegate;
@property (nonatomic, strong) NSString *addDelegateKey;

@end
