//
//  CSDScoreDetailCell.h
//  CSD
//
//  Created by .D. .D. on 1/6/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSDScoreDetailCell : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *testNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationNameLabel;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;

@end

NS_ASSUME_NONNULL_END
