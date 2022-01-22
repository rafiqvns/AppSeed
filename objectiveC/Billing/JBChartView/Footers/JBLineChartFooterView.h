//
//  JBLineChartFooterView.h
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/8/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JBLineChartView.h"

@interface JBLineChartFooterView : UIView {
    NSInteger _numberOfChartItems;
}

@property (nonatomic, strong) UIColor *footerSeparatorColor; // footer separator (default = white)
@property (nonatomic, assign) NSInteger sectionCount; // # of notches (default = 2 on each edge)
@property (nonatomic, readonly) UILabel *leftLabel;
@property (nonatomic, readonly) UILabel *rightLabel;
@property (nonatomic, strong) NSArray *bottomValues;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *legendLabels;
@property (nonatomic, strong) NSArray *itemsCounts;

@property (nonatomic, assign) id<JBLineChartViewDataSource> chartLineDelegate;

- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values;
- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values forChartItems:(NSInteger*)chartItems;
- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values forChartItemsCounts:(NSArray*)chartItemsCounts;

@end
