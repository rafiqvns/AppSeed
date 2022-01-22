//
//  CSDEyeMovementViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 4/12/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "AddObject.h"
#import <MessageUI/MessageUI.h>
#import "CSDTestSelectObject.h"
#import "ServerManager.h"
#import "HelperUtility.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSDEyeMovementViewController : HomeBaseViewController <AddObject, MFMailComposeViewControllerDelegate, CSDSelectObject> {
    CGPoint lastPoint;
    CGPoint firstPoint;
}
@property (nonatomic, strong) IBOutlet UIImageView *positionsView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *studentBtn;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *instructorBtn;
@property (nonatomic, assign) BOOL addParentMobileRecordId;
@property (nonatomic, strong) IBOutlet UILabel *frontLabel;
@property (nonatomic, strong) IBOutlet UILabel *rearLabel;
@property (nonatomic, strong) IBOutlet UILabel *leftLabel;
@property (nonatomic, strong) IBOutlet UILabel *rightLabel;

@property (nonatomic, strong) IBOutlet UILabel *eyeLeadLabel;
@property (nonatomic, strong) IBOutlet UILabel *followTimeLabel;
@property (nonatomic, strong) IBOutlet UILabel *gaugesLabel;
@property (nonatomic, strong) IBOutlet UILabel *intersectionsLabel;
@property (nonatomic, strong) IBOutlet UILabel *parkedCarsLabel;
@property (nonatomic, strong) IBOutlet UILabel *pedestriansLabel;

@property (nonatomic, strong) IBOutlet UILabel *startLabel;
@property (nonatomic, strong) IBOutlet UILabel *stopLabel;
@property (nonatomic, strong) IBOutlet UILabel *finishLabel;
@property (nonatomic, strong) IBOutlet UILabel *middleLabel;

@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIView *bottomView;

@property (nonatomic, strong) IBOutlet UIButton *startButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *finishButton;

@property (nonatomic, strong) IBOutlet UILabel *driverLabel;
@property (nonatomic, strong) IBOutlet UILabel *instructorLabel;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;


-(IBAction)positionButtonPressed:(UIButton*)sender;

-(IBAction)studentButtonPressed:(id)sender;
-(IBAction)instructorButtonPressed:(id)sender;
-(IBAction)emailButtonPressed:(id)sender;

-(IBAction)startButtonPressed:(UIButton*)sender;
-(IBAction)stopButtonPressed:(UIButton*)sender;
-(IBAction)finishButtonPressed:(UIButton*)sender;

-(IBAction)followTimeButtonPressed:(UIButton*)sender;
-(IBAction)parkedCarsButtonPressed:(UIButton*)sender;
-(IBAction)gaugesButtonPressed:(UIButton*)sender;
-(IBAction)leftMirrorButtonPressed:(UIButton*)sender;
-(IBAction)eyeLeadButtonPressed:(UIButton*)sender;
-(IBAction)pedestriansButtonPressed:(UIButton*)sender;
-(IBAction)intersectionsButtonPressed:(UIButton*)sender;
-(IBAction)rightMirrorButtonPressed:(UIButton*)sender;

@end

NS_ASSUME_NONNULL_END
