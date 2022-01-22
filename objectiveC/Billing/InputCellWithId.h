//
//  InputCell.h
//  MobileOffice
//
//  Created by .D. .D. on 4/23/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

@interface InputCellWithId : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *requiredLabel;
@property (nonatomic, strong) IBOutlet TextField *inputTextField;

@end
