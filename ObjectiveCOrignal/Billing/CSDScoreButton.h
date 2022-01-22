//
//  CSDScoreButton.h
//  CSD
//
//  Created by .D. .D. on 2/25/20.
//  Copyright © 2020 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSDScoreButton : UIButton  {
    NSInteger _selectedSegmentIndex;
}
@property (nonatomic, assign) NSInteger numberOfSegments;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, assign, readonly) NSInteger selectedSegmentIndex;
-(void)setSelectedSegmentIndex:(NSInteger)index;
-(NSInteger)numberOfSegments;
@end

NS_ASSUME_NONNULL_END
