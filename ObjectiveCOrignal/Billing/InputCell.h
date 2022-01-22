//
//  InputCell.h
//  MobileOffice
//
//  Created by .D. .D. on 4/23/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputCell : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *requiredLabel;
@property (nonatomic, strong) IBOutlet UITextField *inputTextField;

@end
