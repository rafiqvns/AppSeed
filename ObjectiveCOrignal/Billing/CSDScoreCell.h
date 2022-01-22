//
//  CSDScoreCell.h
//  CSD
//
//  Created by .D. .D. on 1/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSDScoreCell : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *firstNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *lastNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UIButton *discolureBtn;
@property (nonatomic, strong) IBOutlet UILabel *statusLabel;
@property (nonatomic, strong) IBOutlet UIImageView *statusImage;

@end

NS_ASSUME_NONNULL_END
