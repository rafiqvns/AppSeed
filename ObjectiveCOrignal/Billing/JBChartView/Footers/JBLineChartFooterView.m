//
//  JBLineChartFooterView.m
//  JBChartViewDemo
//
//  Created by Terry Worona on 11/8/13.
//  Copyright (c) 2013 Jawbone. All rights reserved.
//

#import "JBLineChartFooterView.h"
#import "JBFontConstants.h"

// Numerics
CGFloat const kJBLineChartFooterViewSeparatorWidth = 0.5f;
CGFloat const kJBLineChartFooterViewSeparatorHeight = 3.0f;
CGFloat const kJBLineChartFooterViewSeparatorSectionPadding = 1.0f;

//#define kNumberOfHorizontalValues 11
#define kNumberOfHorizontalValues 12

// Colors
static UIColor *kJBLineChartFooterViewDefaultSeparatorColor = nil;

@interface JBLineChartFooterView ()

@property (nonatomic, strong) UIView *topSeparatorView;

@end

@implementation JBLineChartFooterView

#pragma mark - Alloc/Init

+ (void)initialize
{
	if (self == [JBLineChartFooterView class])
	{
		kJBLineChartFooterViewDefaultSeparatorColor = [UIColor whiteColor];
	}
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _footerSeparatorColor = kJBLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        
        _topSeparatorView.backgroundColor = [UIColor redColor];
        [self addSubview:_topSeparatorView];
        
        
        self.labels = [NSMutableArray new];
        
        for (NSString *months in self.bottomValues) {
            UILabel *lbl = [[UILabel alloc] init];
            lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            lbl.textAlignment = NSTextAlignmentLeft;
            lbl.textColor = [UIColor whiteColor];
            lbl.backgroundColor = [UIColor clearColor];
            [self addSubview:lbl];
            [self.labels addObject:lbl];
        }
        
        self.legendLabels = [NSMutableArray new];
        
        for (int i = 0; i < 4; i++) {
            
            UILabel *lbl = [[UILabel alloc] init];
            lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            lbl.textAlignment = NSTextAlignmentLeft;
            lbl.textColor = [UIColor whiteColor];
            lbl.backgroundColor = [UIColor clearColor];
            lbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [self addSubview:lbl];
            [self.legendLabels addObject:lbl];
        }
        
        /*
        _leftLabel = [[UILabel alloc] init];
        _leftLabel.adjustsFontSizeToFitWidth = YES;
        _leftLabel.font = kJBFontFooterSubLabel;
        _leftLabel.textAlignment = NSTextAlignmentLeft;
        _leftLabel.textColor = [UIColor whiteColor];
        _leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_leftLabel];
        
        _rightLabel = [[UILabel alloc] init];
        _rightLabel.adjustsFontSizeToFitWidth = YES;
        _rightLabel.font = kJBFontFooterSubLabel;
        _rightLabel.textAlignment = NSTextAlignmentRight;
        _rightLabel.textColor = [UIColor whiteColor];
        _rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_rightLabel];
        */
        
        
    }
    return self;
}

-(void)loadItemsCounts {
    NSInteger chartItems = 0;
    for (NSNumber *count in self.itemsCounts) {
        chartItems += [count integerValue];
    }
    
    _numberOfChartItems = chartItems;
}

- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values forChartItemsCounts:(NSArray*)chartItemsCounts {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.itemsCounts = chartItemsCounts;
        
        NSInteger chartItems = 0;
        for (NSNumber *count in self.itemsCounts) {
            chartItems += [count integerValue];
        }
        
        _numberOfChartItems = chartItems;
        
        _footerSeparatorColor = kJBLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        _topSeparatorView.backgroundColor = [UIColor blackColor];
        
        _topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_topSeparatorView];
        
        
        self.labels = [NSMutableArray new];
        
        self.bottomValues = [[NSMutableArray alloc] initWithArray:values];
        
        int i = 0;
        
        for (NSString *month in self.bottomValues) {
            UILabel *lbl = [[UILabel alloc] init];
            //lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            if (i < kNumberOfHorizontalValues) {
                lbl.textAlignment = NSTextAlignmentLeft;
            } else {
                lbl.textAlignment = NSTextAlignmentRight;
            }
            lbl.textColor = [UIColor whiteColor];
            lbl.textColor = [UIColor blackColor];
            
            lbl.backgroundColor = [UIColor clearColor];
            
            i++;
            
            lbl.text = month;
            [self addSubview:lbl];
            [self.labels addObject:lbl];
        }
        
        self.legendLabels = [NSMutableArray new];
        
        for (int i = 0; i < chartItems; i++) {
            
            UILabel *lbl = [[UILabel alloc] init];
            lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor clearColor];
            [self addSubview:lbl];
            [self.legendLabels addObject:lbl];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values forChartItems:(NSInteger*)chartItems {
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
       
        _numberOfChartItems = chartItems;
        
        _footerSeparatorColor = kJBLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        _topSeparatorView.backgroundColor = [UIColor blackColor];
        
        _topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_topSeparatorView];
        
        
        self.labels = [NSMutableArray new];
        
        self.bottomValues = [[NSMutableArray alloc] initWithArray:values];
        
        int i = 0;
        
        for (NSString *month in self.bottomValues) {
            UILabel *lbl = [[UILabel alloc] init];
            //lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            if (i < kNumberOfHorizontalValues) {
                lbl.textAlignment = NSTextAlignmentLeft;
            } else {
                lbl.textAlignment = NSTextAlignmentRight;
            }
            lbl.textColor = [UIColor whiteColor];
            lbl.textColor = [UIColor blackColor];
            
            lbl.backgroundColor = [UIColor clearColor];
            
            i++;
            
            lbl.text = month;
            [self addSubview:lbl];
            [self.labels addObject:lbl];
        }
        
        self.legendLabels = [NSMutableArray new];
        
        for (int i = 0; i < chartItems; i++) {
            
            UILabel *lbl = [[UILabel alloc] init];
            lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor clearColor];
            [self addSubview:lbl];
            [self.legendLabels addObject:lbl];
        }
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame andValues:(NSArray*)values
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        _footerSeparatorColor = kJBLineChartFooterViewDefaultSeparatorColor;
        
        _topSeparatorView = [[UIView alloc] init];
        _topSeparatorView.backgroundColor = _footerSeparatorColor;
        _topSeparatorView.backgroundColor = [UIColor blackColor];

        _topSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_topSeparatorView];
        
        
        self.labels = [NSMutableArray new];
        
        self.bottomValues = [[NSMutableArray alloc] initWithArray:values];
        
        int i = 0;
        
        for (NSString *month in self.bottomValues) {
            UILabel *lbl = [[UILabel alloc] init];
            //lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            if (i < kNumberOfHorizontalValues) {
                lbl.textAlignment = NSTextAlignmentLeft;
            } else {
                lbl.textAlignment = NSTextAlignmentRight;
            }
            lbl.textColor = [UIColor whiteColor];
            lbl.textColor = [UIColor blackColor];

            lbl.backgroundColor = [UIColor clearColor];

            i++;
            
            lbl.text = month;
            [self addSubview:lbl];
            [self.labels addObject:lbl];
        }
        
        self.legendLabels = [NSMutableArray new];
        
        for (int i = 0; i < 4; i++) {
            
            UILabel *lbl = [[UILabel alloc] init];
            lbl.adjustsFontSizeToFitWidth = YES;
            lbl.font = kJBFontFooterSubLabel;
            lbl.textAlignment = NSTextAlignmentRight;
            lbl.textColor = [UIColor blackColor];
            lbl.backgroundColor = [UIColor clearColor];
            [self addSubview:lbl];
            [self.legendLabels addObject:lbl];
        }
    }
    
    return self;
}


#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.footerSeparatorColor.CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextSetShouldAntialias(context, YES);

    CGFloat xOffset = 0;
    CGFloat yOffset = kJBLineChartFooterViewSeparatorWidth;
    CGFloat stepLength = ceil((self.bounds.size.width) / (self.sectionCount - 1));
    
    for (int i=0; i<self.sectionCount; i++)
    {
        CGContextSaveGState(context);
        {
            CGContextMoveToPoint(context, xOffset + (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset);
            CGContextAddLineToPoint(context, xOffset + (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset + kJBLineChartFooterViewSeparatorHeight);
            CGContextStrokePath(context);
            xOffset += stepLength;
        }
        CGContextRestoreGState(context);
    }
    
    if (self.sectionCount > 1)
    {
        CGContextSaveGState(context);
        {
            CGContextMoveToPoint(context, self.bounds.size.width - (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset);
            CGContextAddLineToPoint(context, self.bounds.size.width - (kJBLineChartFooterViewSeparatorWidth * 0.5), yOffset + kJBLineChartFooterViewSeparatorHeight);
            
            CGContextStrokePath(context);
        }
        CGContextRestoreGState(context);
    }
    
    xOffset = 100;
    yOffset = 40;
    
    CGContextSetLineWidth(context, 2.5);
    
    NSInteger numberofLinesFromLegend = [self.chartLineDelegate numberOfLinesInLegendChartView:self];

    for (int i = 0; i < numberofLinesFromLegend; i++) {
        CGContextSaveGState(context);
        {
            UIColor *color = [self.chartLineDelegate lineChartViewColorForLineAtLineIndex:i];
            
            CGContextSetStrokeColorWithColor(context, color.CGColor);

            CGContextMoveToPoint(context, xOffset, yOffset);
            CGContextAddLineToPoint(context, xOffset + 60, yOffset);
            CGContextStrokePath(context);
            yOffset += 20;
        }
        CGContextRestoreGState(context);
    }
}

#pragma mark - Layout

-(NSInteger)getItemsCountForLabel:(NSInteger)labelIndex {
    return [[self.itemsCounts objectAtIndex:labelIndex] integerValue];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _topSeparatorView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, /*kJBLineChartFooterViewSeparatorWidth*/1);
    
    CGFloat xOffset = 0;
    CGFloat yOffset = kJBLineChartFooterViewSeparatorSectionPadding;
    /*
    18.09.2015 OLD
     CGFloat stepLength = ceil((self.bounds.size.width) / (self.sectionCount - 1));
    */
    
    [self loadItemsCounts];
    
    CGFloat stepLength = 0;
    if (_numberOfChartItems) {
        //stepLength = ceil((self.bounds.size.width) / _numberOfChartItems);
        stepLength = (self.frame.size.width) / _numberOfChartItems;

    }

    for (int i = 0; i < self.labels.count; i++) {
        UILabel *lbl = [self.labels objectAtIndex:i];
        NSInteger numberOfItems = [self getItemsCountForLabel:i];
        /*
        18.09.2015 OLD
         double width = ((self.bounds.size.width) / (self.sectionCount - 1));
         */
        double width = numberOfItems *stepLength;
        
        if (i < kNumberOfHorizontalValues) {
            lbl.frame = CGRectMake(xOffset, yOffset, width, /*self.bounds.size.height*/25);
            xOffset += width;
        } else {
            xOffset -= width;
            
            CGRect frame = CGRectMake(xOffset, yOffset, width, /*self.bounds.size.height*/25);
            
            lbl.frame = frame;
        }
    }
    
    xOffset = 10;
    yOffset = 30;
    

    NSInteger numberofLinesFromLegend = [self.chartLineDelegate numberOfLinesInLegendChartView:self];

    for (int i = 0; i < numberofLinesFromLegend; i++) {
        
        if (i < self.legendLabels.count) {
            UILabel *lbl = [self.legendLabels objectAtIndex:i];
            
            CGRect frame = CGRectMake(xOffset, yOffset, 70, 20);
            NSString *text = [self.chartLineDelegate lineChartViewLegendTextForLineAtLineIndex:i];
            
            lbl.text = text;
            lbl.frame = frame;
            yOffset += 20;
        }
    }

    NSLog(@" offset = %f", xOffset);
    /*
    self.leftLabel.frame = CGRectMake(xOffset, yOffset, width, self.bounds.size.height);
    self.rightLabel.frame = CGRectMake(CGRectGetMaxX(_leftLabel.frame), yOffset, width, self.bounds.size.height);
    */
}

#pragma mark - Setters

- (void)setSectionCount:(NSInteger)sectionCount
{
    _sectionCount = sectionCount;
    [self setNeedsDisplay];
}

- (void)setFooterSeparatorColor:(UIColor *)footerSeparatorColor
{
    _footerSeparatorColor = footerSeparatorColor;
    _topSeparatorView.backgroundColor = _footerSeparatorColor;
    [self setNeedsDisplay];
}

@end
