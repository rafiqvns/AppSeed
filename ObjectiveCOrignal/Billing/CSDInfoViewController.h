//
//  CSDInfoViewController.h
//  CSD
//
//  Created by .D. .D. on 11/1/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSDInfoViewController : HomeBaseViewController<UITabBarControllerDelegate, UITabBarDelegate, AddObject>
@property (nonatomic, strong) IBOutlet UIView *tabContentView;

@end

NS_ASSUME_NONNULL_END
