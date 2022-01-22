//
//  RCOPortraitLandscapeViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 11/28/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "RCOObjectEditorViewController.h"

@interface RCOPortraitLandscapeViewController : RCOObjectEditorViewController {
    
}

@property (nonatomic, strong) IBOutlet UIView *landscapeView;
@property (nonatomic, strong) IBOutlet UIView *portraitView;

-(void)loadPortraitViews;
-(void)loadLandscapeViews;

@end
