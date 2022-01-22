//
//  RCOSplitViewController.h
//  MobileOffice
//
//  Created by .R.H. on 5/9/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "MGSplitViewController.h"

@class RCOSplitDragView;
@class RCODataViewController;
@class RCOObject;

#define kReloadList @"reloadList"

@protocol RCOSpliterSelectionDelegate <NSObject>

-(void)RCOSpliterSelectedObject:(RCOObject*)object;
-(void)RCOSpliterSelectedObjectDict:(NSDictionary*)objectDict;
-(void)RCOSpliterWillSelectedObject:(RCOObject*)object;
-(void)RCOSpliterWillSelectedObjectDict:(NSDictionary*)objectDict;
@optional
-(void)RCOSpliterSelectedObjectForEditing:(RCOObject*)object;
-(void)RCOSpliterReceiveMessageFromMaster:(NSString*)message;
-(void)RCOSpliterMasterReceiveMessageFromDetail:(NSString*)message;
-(BOOL)RCOSpliterShouldSelectedObject:(RCOObject*)object;
-(BOOL)RCOSpliterShouldSelectedObjectDict:(NSDictionary*)objectDict;

@end

@protocol RCOSpliterEditorDelegate <NSObject>

-(void)RCOSpliterDetailSavedObject:(RCOObject*)object;
-(void)RCOSpliterDetailRemovedObject:(RCOObject*)object;
-(void)RCOSpliterDetailStartEditingObject:(RCOObject*)object;

@end

@interface RCOSplitViewController : MGSplitViewController <UIAlertViewDelegate> {

    // the view which draws the divider/split between master and detail
    BOOL m_showDragView;
    NSInteger m_draggerWid;
    RCOSplitDragView *m_draggerView;

    UIButton *m_showMasterButton;
}

@property (nonatomic, assign) BOOL showDragView; 
@property (nonatomic, assign) NSInteger draggerWid; 
@property (nonatomic, strong) IBOutlet RCOSplitDragView *draggerView; 
@property (nonatomic, strong) UIButton *showMasterButton; // the view which draws the divider/split between master 

- (id) initWithMaster: (RCODataViewController *) mvc andDetail: (UIViewController<MGSplitViewControllerDelegate>*)dvc;
- (void) hideMaster: (id) sender;
- (void) showMaster: (id) sender;


@end
