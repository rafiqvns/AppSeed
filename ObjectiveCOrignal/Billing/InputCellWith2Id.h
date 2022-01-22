//
//  InputCellWith2Id.h
//  MobileOffice
//
//  Created by .D. .D. on 4/23/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextField.h"

@interface InputCellWith2Id : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *titleLabel1;
@property (nonatomic, strong) IBOutlet UILabel *requiredLabel1;
@property (nonatomic, strong) IBOutlet TextField *inputTextField1;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel2;
@property (nonatomic, strong) IBOutlet UILabel *requiredLabel2;
@property (nonatomic, strong) IBOutlet TextField *inputTextField2;


@end
