//
//  CSDEyeMovementViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 4/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "CSDEyeMovementViewController.h"
#import "DataRepository.h"
#import "EyeMovement+CoreDataClass.h"
#import "TrainingStudent+CoreDataClass.h"
#import "RCOObjectListViewController.h"
#import "TrainingInstructor+CoreDataClass.h"
#import "NSDate+Misc.h"

#define Key_Student @"studentEmployeeId"
#define Key_Instructor @"instructorEmployeeId"
#import "Settings.h"

@interface CSDEyeMovementViewController ()
@property (nonatomic, strong) NSArray *positions;

@property (nonatomic, strong) NSMutableArray *sequence;
@property (nonatomic, strong) NSMutableArray *sequenceErrors;
@property (nonatomic, strong) NSMutableArray *sequenceTags;
@property (nonatomic, strong) User *student;
@property (nonatomic, strong) User *instructor;
@property (nonatomic, strong) UIBarButtonItem *saveBtn;
@property (nonatomic, strong) UIBarButtonItem *addNewBtn;
@property (nonatomic, strong) UIBarButtonItem *reloadBtn;

@property (nonatomic, assign) CGPoint minPoint;
@property (nonatomic, assign) CGPoint maxPoint;

@property (nonatomic, assign) NSInteger rotations;
@property (nonatomic, assign) NSInteger frontCount;
@property (nonatomic, assign) NSInteger rearCount;
@property (nonatomic, assign) NSInteger leftCount;
@property (nonatomic, assign) NSInteger rightCount;
@property (nonatomic, assign) NSInteger eyeLeadCount;
@property (nonatomic, assign) NSInteger followTimeCount;
@property (nonatomic, assign) NSInteger gaugesCount;
@property (nonatomic, assign) NSInteger intersectionsCount;
@property (nonatomic, assign) NSInteger parkedCarsCount;
@property (nonatomic, assign) NSInteger pedestriansCount;

@property (nonatomic, strong) NSMutableArray *stops;
@property (nonatomic, strong) NSMutableArray *starts;
@property (nonatomic, strong) NSDate *finishDate;
@property (nonatomic, assign) BOOL needsToSave;
@property (nonatomic, strong) EyeMovement *eyeMovement;



#define TagIntersections 100
#define TagFollowTime 101
#define TagEyelead 102
#define TagParkedCars 103
#define TagPedestrians 104
#define TagLeftMirror 105
#define TagRightMirror 106
#define TagGauges 107

@end

@implementation CSDEyeMovementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.minPoint = CGPointMake(10000, 10000);
    
    self.maxPoint = CGPointMake(0, 0);
    /* 24.10.2019 Andrey wanted some changes
    self.positions = [NSArray arrayWithObjects:@"Following Distance", @"Lead Time", @"Intersections", @"Parked cars Left", @"Parked cars Right", @"Pedestrians Left", @"Pedestrians Right", @"Left Mirror", @"Right Mirror", @"Gauges", nil];
     */
    //self.positions = [NSArray arrayWithObjects:@"Following Distance", @"Lead Time", @"Intersections", @"Left Parked Cars", @"Right Parked Cars", @"Left Padestrians", @"Right Padestrians", @"Left Mirror", @"Right Mirror", @"Gauges", nil];

    self.positions = [NSArray arrayWithObjects:@"Intersections", @"Follow-Time", @"Lead-Eye", @"Parked Cars", @"Pedestrians", @"Left Mirror", @"Right Mirror", @"Gauges", nil];

    self.sequence = [NSMutableArray array];
    self.sequenceTags = [NSMutableArray array];

    self.saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                 target:self
                                                                 action:@selector(saveButtonPressed:)];
    
    self.addNewBtn = [[UIBarButtonItem alloc] initWithTitle:@"New"
                                                      style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:@selector(newButtonPressed:)];
    
    self.reloadBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                   target:self
                                                                   action:@selector(reloadButtonPressed:)];


    [self.saveBtn setEnabled:NO];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.reloadBtn, self.addNewBtn, self.saveBtn, nil];

    NSNumber *isDrivingSchool = [Settings getSettingAsNumber:CSD_COMPANY_DRIVING_SCHOOL];
    if ([isDrivingSchool boolValue]) {
        // 09.12.2019
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addNewBtn, self.saveBtn, nil];
    } else {
        // 12.12.2019
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.addNewBtn, nil];
    }

    [self loadPrevInstructor];
    [self loadPrevStudent];
    self.title = @"Eye Movements";
    self.startLabel.layer.borderWidth = 1;
    self.startLabel.layer.borderColor = [UIColor blackColor].CGColor;

    self.stopLabel.layer.borderWidth = 1;
    self.stopLabel.layer.borderColor = [UIColor blackColor].CGColor;

    self.middleLabel.layer.borderWidth = 2;
    self.middleLabel.layer.borderColor = [UIColor blackColor].CGColor;
}

-(void)updateCountsForFront:(BOOL)isFront {
    if (!self.starts.count) {
        [self showSimpleMessage:@"Please start the test first!"];
        return;
    }
    if (self.finishDate) {
        [self showSimpleMessage:@"Test is ended!"];
        return;
    }

    if (isFront) {
        self.frontCount++;
    } else {
        self.rearCount++;
    }
    self.frontLabel.text = [NSString stringWithFormat:@"Front %d", (int)self.frontCount];
    self.rearLabel.text = [NSString stringWithFormat:@"Rear %d", (int)self.rearCount];
    self.leftLabel.text = [NSString stringWithFormat:@"Left Mirror\n%d", (int)self.leftCount];
    self.rightLabel.text = [NSString stringWithFormat:@"Right Mirror\n%d", (int)self.rightCount];
    self.followTimeLabel.text = [NSString stringWithFormat:@"Follow-Time\n%d", (int)self.followTimeCount];
    self.eyeLeadLabel.text = [NSString stringWithFormat:@"Eye-Lead\n%d", (int)self.eyeLeadCount];
    self.intersectionsLabel.text = [NSString stringWithFormat:@"Intersections\n%d", (int)self.intersectionsCount];
    self.pedestriansLabel.text = [NSString stringWithFormat:@"Pedestrians\n%d", (int)self.pedestriansCount];
    self.parkedCarsLabel.text = [NSString stringWithFormat:@"Parked Cars\n%d", (int)self.parkedCarsCount];
    self.gaugesLabel.text = [NSString stringWithFormat:@"Gauges\n%d", (int)self.gaugesCount];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    
    NSLog(@"CenterX = %@, coordinator: %@", NSStringFromCGPoint(self.view.center), coordinator);
    
    self.positionsView.image = nil;
    self.minPoint = CGPointMake(10000, 10000);
    self.maxPoint = CGPointMake(0, 0);
    //[self performSelector:@selector(redrawAllLines) withObject:nil afterDelay:0.5];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        NSLog(@"context = %@", context);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        self.rotations++;

        if (/*!(self.rotations%2)*/1) {
           // [self redrawAllLines];
            [self performSelector:@selector(redrawAllLines) withObject:nil afterDelay:0.1];
        }
        
        NSLog(@"contexZZZZZ = %@, percentage = %f", context, context.percentComplete);
    }];
    
    
}

-(CGPoint)getViewCenterWithTag:(NSInteger)tag {
    /*
     20.11.2019 changed
    UIView *v = [self.positionsView viewWithTag:tag];
     */
    CGPoint center = CGPointZero;
    UIView *v = [self.topView viewWithTag:tag];
    if (!v) {
        v = [self.bottomView viewWithTag:tag];
        center = v.center;
        center.y += self.topView.frame.size.height;
    } else {
        center = v.center;
    }
    return center;
}

-(IBAction)positionButtonPressed:(UIButton*)sender {
    if (!self.student) {
        [self showSimpleMessage:@"Please select student!"];
        return;
    }
    NSInteger tag = sender.tag;
    if (tag < 0) {
        tag = 0;
    }
    if (tag < self.positions.count) {
        NSString *pos = [self.positions objectAtIndex:tag];
        if ([self.sequenceTags lastObject] == [NSNumber numberWithInteger:tag]) {
            // 24.04.2019 we already have this position
            return;
        } else {
            NSString *prevPos = nil;
            if (self.sequence.count) {
                prevPos = [self.sequence lastObject];
            }

            // 24.04.2019 we shoud not add the same position twice....
            [self.sequence addObject:pos];
            self.needsToSave = YES;
            
            //29.11.2019 these are errors
            BOOL isError = NO;
            if ([prevPos containsString:@"Mirror"] && [pos containsString:@"Mirror"]) {
                isError = YES;
            } else if ([prevPos containsString:@"Mirror"] && [pos containsString:@"Gauges"]) {
                isError = YES;
            } else if ([pos containsString:@"Mirror"] && [prevPos containsString:@"Gauges"]) {
                isError = YES;
            }
            
            if (isError) {
                if (!self.sequenceErrors) {
                    self.sequenceErrors = [NSMutableArray array];
                }
                [self.sequenceErrors addObject:[NSString stringWithFormat:@"%d", (int)(self.sequence.count - 1)]];
            }

            [self.sequenceTags addObject:[NSNumber numberWithInteger:tag]];
        }
    }
    
    lastPoint = sender.center;
    //[self drawLine];
    [self drawLineFromPoint:firstPoint toPoint:lastPoint andSequence:-1];
    firstPoint = lastPoint;
}

-(void)addPosition:(NSInteger)btnTag {
    
    if (!self.starts.count) {
        return;
    }
    if (self.finishDate) {
        return;
    }

    if (!self.student) {
        [self showSimpleMessage:@"Please select student!"];
        return;
    }
    NSInteger tag = btnTag - 100;
    if (tag < 0) {
        tag = 0;
    }
    if (tag < self.positions.count) {
        NSString *pos = [self.positions objectAtIndex:tag];
        if ([self.sequenceTags lastObject] == [NSNumber numberWithInteger:tag]) {
            // 24.04.2019 we already have this position
            return;
        } else {
            
            // 24.04.2019 we shoud not add the same position twice....
            NSString *prevPos = nil;
            if (self.sequence.count) {
                prevPos = [self.sequence lastObject];
            }
            [self.sequence addObject:pos];
            self.needsToSave = YES;

            //29.11.2019 these are errors
            BOOL isError = NO;
            if ([prevPos containsString:@"Mirror"] && [pos containsString:@"Mirror"]) {
                isError = YES;
            } else if ([prevPos containsString:@"Mirror"] && [pos containsString:@"Gauges"]) {
                isError = YES;
            } else if ([pos containsString:@"Mirror"] && [prevPos containsString:@"Gauges"]) {
                isError = YES;
            }
            
            if (isError) {
                if (!self.sequenceErrors) {
                    self.sequenceErrors = [NSMutableArray array];
                }
                [self.sequenceErrors addObject:[NSString stringWithFormat:@"%d", (int)(self.sequence.count -1)]];
            }
            
            // we should check hete
            [self.sequenceTags addObject:[NSNumber numberWithInteger:tag]];
        }
    }
    
    CGPoint center = [self getViewCenterWithTag:btnTag];
    
    lastPoint = center;
    //[self drawLine];
    [self drawLineFromPoint:firstPoint toPoint:lastPoint andSequence:-1];
    firstPoint = lastPoint;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[self aggregate] registerForCallback:self];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[self aggregate] unRegisterForCallback:self];
    [super viewWillDisappear:animated];
}

/*
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

*/

-(void)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint{
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 1.0, 1.0, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
    
    double x = (fromPoint.x + toPoint.x)/2;
    double y = (fromPoint.y + toPoint.y)/2;
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    double l = 20;
    // 60 degrees
    double angle30 = 0.52;
    
    double tanValue = (toPoint.x - fromPoint.x)/ (toPoint.y - fromPoint.y);
    double alpha = atan(tanValue);
    double angle = alpha - angle30;
    
    BOOL isUp = YES;
    BOOL forceAngle = NO;
    if (toPoint.y > fromPoint.y) {
        isUp = NO;
    } else if (toPoint.y == fromPoint.y) {
        if (toPoint.x < fromPoint.x) {
            isUp = NO;
        } else {
            // ugly workaround....
            forceAngle = YES;
            angle = -4*angle30;
        }
        
        NSLog(@"");
    }
    
    if (!isUp) {
        // from where to start draving the arrow uper middle or wdown middle
        l *= -1;
    }
    
    double x1 = x + l*sin(angle);
    double y1 = y + l*cos(angle);
    
    // first point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    angle = alpha + angle30;
    if (forceAngle) {
        angle = -2*angle30;
    }
    
    CGRect frame = CGRectZero;
    // "fix" the isse regarding the text that was drawn under the line ....
    if (isUp) {
        frame = CGRectMake(x1 - 20, y1 - 20, 20, 20);
    } else {
        frame = CGRectMake(x1 - 20, y1 + 20, 20, 20);
    }
    
    x1 = x + l*sin(angle);
    y1 = y + l*cos(angle);
    
    // secomd point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    // connect to the last point
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
    
    double delta = 20;
    if (isUp) {
        delta *= -1;
    }
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.positionsView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"");
    // UIGraphicsEndImageContext();
}

-(void)drawLineFromPointOld:(CGPoint)fromPoint toPoint:(CGPoint)toPoint andSequence:(NSInteger)sequence{
    if (self.sequence.count < 2) {
        UIGraphicsBeginImageContext(self.positionsView.frame.size);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
        if (self.sequence.count%2) {
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),[UIColor redColor].CGColor);
        } else {
            CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),[UIColor blueColor].CGColor);
        }
        return;
    }
    
    [self.saveBtn setEnabled:YES];
    self.needsToSave = YES;
    
    NSString *step = nil;
    if (sequence > -1) {
        step = [NSString stringWithFormat:@"%d", (int)sequence];
    } else {
        step = [NSString stringWithFormat:@"%d", (int)(self.sequence.count - 1)];
    }
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    //28.11.2019CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    if (self.sequence.count%2) {
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),[UIColor redColor].CGColor);
    } else {
        CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),[UIColor blueColor].CGColor);
    }

    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
    
    double x = (fromPoint.x + toPoint.x)/2;
    double y = (fromPoint.y + toPoint.y)/2;
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    double l = 20;
    // 60 degrees
    double angle30 = 0.52;
    
    double tanValue = (toPoint.x - fromPoint.x)/ (toPoint.y - fromPoint.y);
    double alpha = atan(tanValue);
    double angle = alpha - angle30;
    
    BOOL isUp = YES;
    BOOL forceAngle = NO;
    if (toPoint.y > fromPoint.y) {
        isUp = NO;
    } else if (toPoint.y == fromPoint.y) {
        if (toPoint.x < fromPoint.x) {
            isUp = NO;
        } else {
            // ugly workaround....
            forceAngle = YES;
            angle = -4*angle30;
        }
        
        NSLog(@"");
    }
    
    if (!isUp) {
        // from where to start draving the arrow uper middle or wdown middle
        l *= -1;
    }
    
    double x1 = x + l*sin(angle);
    double y1 = y + l*cos(angle);
    
    // first point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    angle = alpha + angle30;
    if (forceAngle) {
        angle = -2*angle30;
    }
    
    CGRect frame = CGRectZero;
    // "fix" the isse regarding the text that was drawn under the line ....
    if (isUp) {
        frame = CGRectMake(x1 - 20, y1 - 20, 20, 20);
    } else {
        frame = CGRectMake(x1 - 20, y1 + 20, 20, 20);
    }
    
    x1 = x + l*sin(angle);
    y1 = y + l*cos(angle);
    
    // secomd point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    // connect to the last point
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
    
    double delta = 20;
    if (isUp) {
        delta *= -1;
    }
    
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor redColor]};
    attributes = nil;
    
    [step drawInRect:frame
      withAttributes:attributes];
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.positionsView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"");
    //UIGraphicsEndImageContext();
}

-(void)drawLineFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint andSequence:(NSInteger)sequence{
    if (self.sequence.count < 2) {
        UIGraphicsBeginImageContextWithOptions(self.positionsView.frame.size, NO, 0.0);
        return;
    }
    
    //UIGraphicsBeginImageContext(self.positionsView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self.saveBtn setEnabled:YES];
    
    NSString *step = nil;
    if (sequence > -1) {
        step = [NSString stringWithFormat:@"%d", (int)sequence];
    } else {
        step = [NSString stringWithFormat:@"%d", (int)(self.sequence.count - 1)];
    }
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);

    UIColor *color = nil;
    if ([self.sequenceErrors containsObject:step]) {
        color = [UIColor redColor];
    } else {
        color = [UIColor blueColor];
    }
    
    CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(),color.CGColor);

    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
    
    double x = (fromPoint.x + toPoint.x)/2;
    double y = (fromPoint.y + toPoint.y)/2;
    
    CGContextAddLineToPoint(context, x, y);
    
    double l = 20;
    // 60 degrees
    double angle30 = 0.52;
    
    double tanValue = (toPoint.x - fromPoint.x)/ (toPoint.y - fromPoint.y);
    double alpha = atan(tanValue);
    double angle = alpha - angle30;
    
    BOOL isUp = YES;
    BOOL forceAngle = NO;
    if (toPoint.y > fromPoint.y) {
        isUp = NO;
    } else if (toPoint.y == fromPoint.y) {
        if (toPoint.x < fromPoint.x) {
            isUp = NO;
        } else {
            // ugly workaround....
            forceAngle = YES;
            angle = -4*angle30;
        }
        
        NSLog(@"");
    }
    
    if (!isUp) {
        // from where to start draving the arrow uper middle or wdown middle
        l *= -1;
    }
    
    double x1 = x + l*sin(angle);
    double y1 = y + l*cos(angle);
    
    // first point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    angle = alpha + angle30;
    if (forceAngle) {
        angle = -2*angle30;
    }
    
    CGRect frame = CGRectZero;
    // "fix" the isse regarding the text that was drawn under the line ....
    if (isUp) {
        frame = CGRectMake(x1 - 20, y1 - 20, 20, 20);
    } else {
        frame = CGRectMake(x1 - 20, y1 + 20, 20, 20);
    }
    
    x1 = x + l*sin(angle);
    y1 = y + l*cos(angle);
    
    // secomd point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    // connect to the last point
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
    
    double delta = 20;
    if (isUp) {
        delta *= -1;
    }
       
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: color/*,  NSStrokeWidthAttributeName : [NSNumber numberWithFloat:10.0]*/};
    
    [step drawInRect:frame
      withAttributes:attributes];
    
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.positionsView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"");
    //UIGraphicsEndImageContext();
}


-(void)redrawAllLines {
    if (self.sequenceTags.count == 0) {
        return;
    }
    
    NSLog(@"redrawAllLines");
    
    self.positionsView.image = nil;
    
    UIGraphicsBeginImageContext(self.positionsView.frame.size);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    
    CGPoint fromBtnCenter = CGPointZero;
    CGPoint toBtnCenter = CGPointZero;
    for (NSInteger i = 0; i < (self.sequenceTags.count -1); i++) {
        
        NSNumber *from = [self.sequenceTags objectAtIndex:i];
        NSInteger fromTag = [from integerValue];
        if (!fromTag) {
            /* 11.11.2019 why?
            fromTag = -1;
            */
        }
        fromBtnCenter = [self getButtonPositionCenterWithTag:fromTag];
        CGPoint fromPoint = fromBtnCenter;
        
        NSNumber *to = [self.sequenceTags objectAtIndex:(i+1)];
        NSInteger toTag = [to integerValue];
        if (!toTag) {
            /* 11.11.2019 why?
            fromTag = -1;
            */
        }
        toBtnCenter = [self getButtonPositionCenterWithTag:toTag];
        CGPoint toPoint = toBtnCenter;
        
        [self drawLineFromPoint:fromPoint toPoint:toPoint andSequence:(i+1)];
    }
    
    if (!((toBtnCenter.x == 0) && (toBtnCenter.y == 0))) {
        lastPoint = toBtnCenter;
        firstPoint = lastPoint;
    }
}

-(CGPoint)getButtonPositionCenterWithTag:(NSInteger)tag {
    if (tag < 100) {
        tag+= 100;
    }

    return [self getViewCenterWithTag:tag];
}


-(void)drawLine {
    if (self.sequence.count < 2) {
        UIGraphicsBeginImageContext(self.positionsView.frame.size);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
        return;
    }

    [self.saveBtn setEnabled:YES];
    self.needsToSave = YES;
    
    NSString *step = [NSString stringWithFormat:@"%d", (int)(self.sequence.count - 1)];
    
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), firstPoint.x, firstPoint.y);
    
    double x = (firstPoint.x + lastPoint.x)/2;
    double y = (firstPoint.y + lastPoint.y)/2;
    
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x, y);

    double l = 20;
    // 60 degrees
    double angle30 = 0.52;

    double tanValue = (lastPoint.x - firstPoint.x)/ (lastPoint.y - firstPoint.y);
    double alpha = atan(tanValue);
    double angle = alpha - angle30;
   
    BOOL isUp = YES;
    BOOL forceAngle = NO;
    if (lastPoint.y > firstPoint.y) {
        isUp = NO;
    } else if (lastPoint.y == firstPoint.y) {
        if (lastPoint.x < firstPoint.x) {
            isUp = NO;
        } else {
            // ugly workaround....
            forceAngle = YES;
            angle = -4*angle30;
        }
            
        NSLog(@"");
    }
    
    if (!isUp) {
        // from where to start draving the arrow uper middle or wdown middle
        l *= -1;
    }
    
    double x1 = x + l*sin(angle);
    double y1 = y + l*cos(angle);

    // first point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);
    
    angle = alpha + angle30;
    if (forceAngle) {
        angle = -2*angle30;
    }
    
    CGRect frame = CGRectZero;
    // "fix" the isse regarding the text that was drawn under the line ....
    if (isUp) {
        frame = CGRectMake(x1 - 20, y1 - 20, 20, 20);
    } else {
        frame = CGRectMake(x1 - 20, y1 + 20, 20, 20);
    }

    x1 = x + l*sin(angle);
    y1 = y + l*cos(angle);

    // secomd point of the arrow
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), x1, y1);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), x, y);

    // connect to the last point
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    
    double delta = 20;
    if (isUp) {
        delta *= -1;
    }
    

    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [UIColor redColor]};
    attributes = nil;
    
    [step drawInRect:frame
      withAttributes:attributes];
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    
    self.positionsView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    NSLog(@"");
   // UIGraphicsEndImageContext();
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)instructorButtonPressed:(id)sender {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
    title = @"Instructors";
    fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
    //detailFields = [NSArray arrayWithObject:@"studentId"];
    sortKey = @"surname";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Instructor
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Instructor;
    if (self.instructor) {
        listController.selectedItem = self.instructor;
    }
    listController.title = title;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(IBAction)studentButtonPressed:(UIBarButtonItem*)sender {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = [[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
    title = @"Students";
    fields = [NSArray arrayWithObjects:@"surname", @"firstname", nil];
    //detailFields = [NSArray arrayWithObject:@"studentId"];
    sortKey = @"surname";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Student
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Student;
    listController.title = title;
    
    if (DEVICE_IS_IPAD) {
        [self showPopoverForViewController:listController fromBarButton:sender];
    } else {
        listController.iPhoneNewLogic = YES;
        listController.isViewControllerPushed = YES;
        [self.navigationController pushViewController:listController animated:YES];
    }
}

-(void)loadPrevInstructor{
    NSString *prevInstructor = [Settings getSetting:CSD_PREV_INSTRUCTOR];
    if (prevInstructor.length == 0) {
        return;
    }
    UserAggregate *instrAgg = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeInstructor];
    self.instructor = (User*)[instrAgg getObjectWithRecordId:prevInstructor];
    if (self.instructor) {
        NSString *title = [NSString stringWithFormat:@"%@ %@", self.instructor.surname, self.instructor.firstname];
        [self.instructorBtn setTitle:title];
    }
}

-(void)loadPrevStudent{
    NSString *prevStudent = [Settings getSetting:CSD_PREV_STUDENT];
    if (prevStudent.length == 0) {
        return;
    }
    UserAggregate *studentAggregate = (UserAggregate*)[[DataRepository sharedInstance] getAggregateForClass:kUserTypeStudent];
    
    if ([prevStudent longLongValue]) {
        self.student = (User*)[studentAggregate getObjectWithRecordId:prevStudent];
    } else {
        self.student = (User*)[studentAggregate getObjectWithMobileRecordId:prevStudent];
    }
    
    if (self.student) {
        NSString *title = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
        [self.studentBtn setTitle:title];
    }
}


-(NSData*)makePDFfromView:(UIView*)view
{
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData(pdfData, view.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    
    return pdfData;
}
-(NSString*)getEmailSubject {
    return [NSString stringWithFormat:@"%@ %@", self.student.firstname, self.student.surname];
}

-(NSString*)getFilePathToSave {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *layOutPath=[NSString stringWithFormat:@"%@/EyeMovement",[paths objectAtIndex:0]];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:layOutPath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:layOutPath withIntermediateDirectories:YES attributes:nil error:nil];
    }

    return [layOutPath stringByAppendingPathComponent:@"EyeMovementPdf.pdf"];
}

-(void)showEmailModalView {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Eye Movement", nil), [self getEmailSubject]]];
    
    // Fill out the email body text
    NSString *emailBody = [NSString stringWithFormat:NSLocalizedString(@"<h3> Attached is the Eye Movement </h3>  <br>", nil)];
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    NSString *path = [self getFilePathToSave];
    
    NSData *fileContent = [self makePDFfromView:self.positionsView];

    BOOL res = [fileContent writeToFile:path atomically:YES];
    if (res) {
        NSLog(@"PDF sucessfully saved!");
    }
    
    [picker addAttachmentData:fileContent
                     mimeType:@"application/pdf"
                     fileName:path];
    
    [self presentViewController:picker
                       animated:YES
                     completion:nil];
}


-(IBAction)emailButtonPressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        [self showEmailModalView];
    } else {
        [self showSimpleMessage:@"Please configure your email account"];
        NSString *path = [self getFilePathToSave];
        
        NSData *fileContent = [self makePDFfromView:self.positionsView];
        
        BOOL res = [fileContent writeToFile:path atomically:YES];
        if (res) {
            NSLog(@"PDF sucessfully saved!");
        }
    }
}

-(void)updateDateLabels {
    if (self.starts.count) {
        NSDate *start = [self.starts objectAtIndex:0];
        self.startLabel.text = [start hoursMinutesSeconds];
    }
    if (self.stops.count) {
        NSDate *stop = [self.stops lastObject];
        self.stopLabel.text = [stop hoursMinutesSeconds];
    }
    
    self.frontLabel.text = [NSString stringWithFormat:@"Front %d", (int)self.frontCount];
    self.rearLabel.text = [NSString stringWithFormat:@"Rear %d", (int)self.rearCount];
    self.leftLabel.text = [NSString stringWithFormat:@"Left Mirror\n%d", (int)self.leftCount];
    self.rightLabel.text = [NSString stringWithFormat:@"Right Mirror\n%d", (int)self.rightCount];
    self.followTimeLabel.text = [NSString stringWithFormat:@"Follow-Time\n%d", (int)self.followTimeCount];
    self.eyeLeadLabel.text = [NSString stringWithFormat:@"Eye-Lead\n%d", (int)self.eyeLeadCount];
    self.intersectionsLabel.text = [NSString stringWithFormat:@"Intersections\n%d", (int)self.intersectionsCount];
    self.pedestriansLabel.text = [NSString stringWithFormat:@"Pedestrians\n%d", (int)self.pedestriansCount];
    self.parkedCarsLabel.text = [NSString stringWithFormat:@"Parked Cars\n%d", (int)self.parkedCarsCount];
    self.gaugesLabel.text = [NSString stringWithFormat:@"Gauges\n%d", (int)self.gaugesCount];

    
    self.driverLabel.text = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
    self.instructorLabel.text = [NSString stringWithFormat:@"%@ %@", self.instructor.surname, self.instructor.firstname];
    NSDate *date = nil;
    if ([self.starts count]) {
        date = [self.starts objectAtIndex:0];
    } else {
        date = [NSDate date];
    }
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:date];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", time_str];

    if (self.finishDate) {
        [self.startButton setEnabled:NO];
        [self.finishButton setEnabled:NO];
        [self.stopButton setEnabled:NO];
    } else if (self.starts.count == self.stops.count) {
        [self.startButton setEnabled:YES];
        [self.stopButton setEnabled:NO];
        if (!self.starts.count) {
            [self.finishButton setEnabled:NO];
        }
    } else {
        [self.startButton setEnabled:NO];
        [self.finishButton setEnabled:YES];
        [self.stopButton setEnabled:YES];
    }
}

-(IBAction)startButtonPressed:(UIButton*)sender {

    if (!self.starts) {
        self.starts = [NSMutableArray array];
    }
    
    [self.starts addObject:[NSDate date]];
    
    [self.startButton setEnabled:NO];
    [self.stopButton setEnabled:YES];
    [self.finishButton setEnabled:YES];
    [self updateDateLabels];
}
-(IBAction)stopButtonPressed:(UIButton*)sender {
    if (!self.stops) {
        self.stops = [NSMutableArray array];
    }
    [self.stops addObject:[NSDate date]];
    [self.finishButton setEnabled:YES];
    [self.startButton setEnabled:YES];
    [self.stopButton setEnabled:NO];
    [self updateDateLabels];
}
-(IBAction)finishButtonPressed:(UIButton*)sender {
    self.finishDate = [NSDate date];
    [self.stopButton setEnabled:NO];
    [self.finishButton setEnabled:NO];
    [self.startButton setEnabled:NO];
    [self updateDateLabels];
}
/*
 Intesections:100, Follow-time:101, Eye-Lead:102, Parked Cars:103, Pedestrians:104; left Mirror:105, Right Mirror:106, Gauges:107
 */

-(IBAction)followTimeButtonPressed:(UIButton*)sender {
    self.followTimeCount++;
    [self updateCountsForFront:YES];
    [self addPosition:TagFollowTime];
}
-(IBAction)parkedCarsButtonPressed:(UIButton*)sender {
    self.parkedCarsCount++;
    [self updateCountsForFront:YES];
    [self addPosition:TagParkedCars];
}
-(IBAction)gaugesButtonPressed:(UIButton*)sender {
    self.gaugesCount++;
    [self updateCountsForFront:NO];
    [self addPosition:TagGauges];
}
-(IBAction)leftMirrorButtonPressed:(UIButton*)sender {
    self.leftCount++;
    [self updateCountsForFront:NO];
    [self addPosition:TagLeftMirror];
}
-(IBAction)eyeLeadButtonPressed:(UIButton*)sender {
    self.eyeLeadCount++;
    [self updateCountsForFront:YES];
    [self addPosition:TagEyelead];
}
-(IBAction)pedestriansButtonPressed:(UIButton*)sender {
    self.pedestriansCount++;
    [self updateCountsForFront:YES];
    [self addPosition:TagPedestrians];
}
-(IBAction)intersectionsButtonPressed:(UIButton*)sender {
    self.intersectionsCount++;
    [self updateCountsForFront:YES];
    [self addPosition:TagIntersections];
}
-(IBAction)rightMirrorButtonPressed:(UIButton*)sender {
    self.rightCount++;
    [self updateCountsForFront:NO];
    [self addPosition:TagRightMirror];
}

-(IBAction)newButtonPressed:(UIButton*)sender {
    // reset the Settings
    [self resetTest];
    /*23.10.2019 we should not reset the student
    self.student = nil;
    [self.studentBtn setTitle:@"Student"];
    */
    [self.saveBtn setEnabled:NO];
    self.needsToSave = NO;
}

-(void)resetTest {
    self.sequence = [NSMutableArray array];
    self.sequenceErrors = [NSMutableArray array];
    self.sequenceTags = [NSMutableArray array];
    self.positionsView.image = nil;
    
    self.leftCount = 0;
    self.rightCount = 0;
    self.frontCount = 0;
    self.rearCount = 0;
    self.followTimeCount = 0;
    self.eyeLeadCount = 0;
    self.intersectionsCount = 0;
    self.pedestriansCount = 0;
    self.parkedCarsCount = 0;
    self.gaugesCount = 0;
    
    self.stops = nil;
    self.starts = nil;
    self.finishDate = nil;
    
    self.eyeMovement = nil;
    
    self.minPoint = CGPointMake(10000, 10000);
    self.maxPoint = CGPointMake(0, 0);
    self.startLabel.text = nil;
    self.stopLabel.text = nil;
    [self updateDateLabels];
}

-(IBAction)reloadButtonPressed:(id)sender {

    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                message:@"Reload the most recent Test Info?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
        [self loadPrevInstructor];
        [self loadPrevStudent];
        
        [self resetTest];
        [self.saveBtn setEnabled:NO];
        self.needsToSave = NO;
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                        }];

    [al addAction:cancelAction];
    [al addAction:yesAction];
    [self presentViewController:al animated:YES completion:nil];
}

-(NSString*)getTimesFromDatesArray:(NSArray*)arr {
    NSMutableArray *s = [NSMutableArray array];
    for (NSDate *d in arr) {
        [s addObject:[d hoursMinutesSeconds]];
    }
    return [s componentsJoinedByString:@","];
}

-(IBAction)saveButtonPressed:(id)sender {
    if (!self.needsToSave) {
        return;
    }
    
    NSString *parentMobileRecordId = nil;
    if (self.addParentMobileRecordId) {
        parentMobileRecordId = [Settings getSetting:CSD_TEST_INFO_MOBILE_RECORD_ID];
        if (!parentMobileRecordId.length) {
            [self showSimpleMessage:@"Please add test info first!"];
            return;
        }
    }
    
    if (!self.sequence.count) {
        return;
    }
    
    if (!self.eyeMovement) {
        self.eyeMovement = (EyeMovement*)[[self aggregate] createNewObject];
        self.eyeMovement.dateTime = [NSDate date];
    }
    
    self.eyeMovement.eyeMovement = [self.sequence componentsJoinedByString:@","];
    self.eyeMovement.company = self.student.company;
    self.eyeMovement.studentFirstName = self.student.firstname;
    self.eyeMovement.studentLastName = self.student.surname;
    self.eyeMovement.driverLicenseState = self.student.driverLicenseState;
    self.eyeMovement.driverLicenseNumber = self.student.driverLicenseNumber;
    self.eyeMovement.studentEmployeeId = self.student.rcoRecordId;
    self.eyeMovement.studentEmployeeId = self.student.employeeNumber;

    self.eyeMovement.instructorFirstName = self.instructor.firstname;
    self.eyeMovement.instructorLastName = self.instructor.surname;
    self.eyeMovement.instructorEmployeeId = self.instructor.rcoRecordId;

    self.eyeMovement.masterMobileRecordId = parentMobileRecordId;
    self.eyeMovement.finishDateTime = self.finishDate;
    self.eyeMovement.stopTimes = [self getTimesFromDatesArray:self.stops];
    self.eyeMovement.startTimes = [self getTimesFromDatesArray:self.starts];
    
    self.eyeMovement.rearCounter = [NSString stringWithFormat:@"%d", (int)self.rearCount];
    self.eyeMovement.frontCounter = [NSString stringWithFormat:@"%d", (int)self.frontCount];
    self.eyeMovement.leftMirrorCounter = [NSString stringWithFormat:@"%d", (int)self.leftCount];
    self.eyeMovement.rightMirrorCounter = [NSString stringWithFormat:@"%d", (int)self.rightCount];
    self.eyeMovement.followTimeCounter = [NSString stringWithFormat:@"%d", (int)self.followTimeCount];
    self.eyeMovement.eyeLeadCounter = [NSString stringWithFormat:@"%d", (int)self.eyeLeadCount];
    self.eyeMovement.intersectionsCounter = [NSString stringWithFormat:@"%d", (int)self.intersectionsCount];
    self.eyeMovement.pedestriansCounter = [NSString stringWithFormat:@"%d", (int)self.pedestriansCount];
    self.eyeMovement.parkedCarsCounter = [NSString stringWithFormat:@"%d", (int)self.parkedCarsCount];
    self.eyeMovement.gaugesCounter = [NSString stringWithFormat:@"%d", (int)self.gaugesCount];

    [[self aggregate] createNewRecord:self.eyeMovement];
    if (sender) {
        [self showSimpleMessage:@"Eye movement saved!"];
        [self resetTest];
    }
    [self.saveBtn setEnabled:NO];
    self.needsToSave = NO;
    [self.addNewBtn setEnabled:YES];
}

-(Aggregate*)aggregate {
    return [[DataRepository sharedInstance] getAggregateForClass:@"EyeMovement"];
}

#pragma mark AddObject delegate

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {
  
    if ([key isEqualToString:Key_Instructor]) {
        if ([object isKindOfClass:[User class]]) {
            self.instructor = (User*)object;
            if ([self.instructor.rcoRecordId length]) {
                [Settings setSetting:self.instructor.rcoRecordId forKey:CSD_PREV_INSTRUCTOR];
                [Settings save];
            }
            NSString *title = [NSString stringWithFormat:@"%@ %@", self.instructor.surname, self.instructor.firstname];
            [self.instructorBtn setTitle:title];
        }
    } else if ([key isEqualToString:Key_Student]) {
        if ([object isKindOfClass:[User class]]) {
            self.student = (User*)object;
            
            if ([self.student.rcoRecordId length]) {
                [Settings setSetting:self.student.rcoRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            } else if ([self.student.rcoMobileRecordId length]) {
                [Settings setSetting:self.student.rcoMobileRecordId forKey:CSD_PREV_STUDENT];
                [Settings save];
            }
            
            NSString *title = [NSString stringWithFormat:@"%@ %@", self.student.surname, self.student.firstname];
            [self.studentBtn setTitle:title];
        }
    }
    
    if (DEVICE_IS_IPAD) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma Mark CSD Selection Protocol

-(void)CSDInfoDidSelectObject:(NSString *)parentMobileRecordId {
    NSLog(@"%@", parentMobileRecordId);
    
    if ([self.eyeMovement.masterMobileRecordId isEqualToString:parentMobileRecordId] && parentMobileRecordId.length) {
        // 12.12.2019 do nothing here, we should not reload anything .. is the same test and is the same eyemovement record
        NSLog(@"");
    } else {
        [self loadPrevInstructor];
        [self loadPrevStudent];
    
        [self resetTest];
        [self.saveBtn setEnabled:NO];
        self.needsToSave = NO;
    }
}

-(void)CSDInfoDidSavedObject:(NSString *)parentMobileRecordId {
    NSLog(@"");
}

-(BOOL)CSDInfoCanSelectScreen {
    return !self.needsToSave;
}

-(NSString*)CSDInfoScreenTitle{
    return @"Eye Movements";
}

-(void)CSDSaveRecordOnServer:(BOOL)onServer {
    NSLog(@"");
    [self saveButtonPressed:nil];
}

@end
