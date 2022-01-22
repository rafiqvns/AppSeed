//
//  TextEditorViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionEditorDelegate.h"
#import "BaseViewController.h"
#import <AudioToolbox/AudioServices.h>
#import "AddObject.h"

@class Note;

@interface TextEditorViewController : BaseViewController <UITextViewDelegate, AddObject> {
    NSString *_textString;
    NSString *_key;
    UITextView *_textView;
    BOOL _isEditing;
    SystemSoundID 				scanSuccessSound;
}

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, weak) id <OptionEditorDelegate> editorDelegate;
@property (nonatomic, assign) BOOL enableScan;
@property (nonatomic, assign) BOOL ignoreCategory;
@property (nonatomic, assign) BOOL saveLocation;
@property (nonatomic, assign) BOOL ignoreNoteRecord;

@property (nonatomic, assign) NSInteger keyboardType;

@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UISwitch *textLabelSwitch;
@property (nonatomic, strong) IBOutlet UIButton *categoryBtn;

@property (nonatomic, strong) Note *note;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withText:(NSString*)text forKey:(NSString*)key;

- (void)setEditMode:(BOOL)editing;

- (IBAction)scanPressed:(id)sender;
- (IBAction)categoryButtonPressed:(id)sender;

@end
