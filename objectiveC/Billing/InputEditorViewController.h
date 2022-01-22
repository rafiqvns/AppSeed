//
//  InputEditorViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 1/2/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputEditorDelegateProtocol.h"

@interface InputEditorViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    NSArray *_inputs;
    NSArray *_buttons;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withInputs:(NSArray*)inputs andButtons:(NSArray*)buttons;

@property (nonatomic, weak) id <InputEditorDelegateProtocol> optionInputDelegate;
@property (nonatomic, assign) NSInteger editorId;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *options;
@property (nonatomic, strong) NSMutableArray *extraOptions;

@end
