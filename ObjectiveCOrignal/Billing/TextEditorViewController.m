//
//  TextEditorViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "UIViewController+iOS6.h"
#import "TextEditorViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Note+CoreDataProperties.h"
#import "DataRepository.h"
#import "RCOObjectListViewController.h"

#define Key_Category @"category"

@interface TextEditorViewController ()
@property (nonatomic, strong) NSMutableArray *barcodes;

@end

@implementation TextEditorViewController

@synthesize textView = _textView;
@synthesize editorDelegate;
@synthesize enableScan;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withText:(NSString*)text forKey:(NSString*)key
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _textString = text;
        _key = key;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.barcodes = [NSMutableArray array];
    
    self.textView.text = _textString;
    self.textView.layer.borderWidth = 1;
    self.textView.layer.borderColor = [[UIColor blackColor] CGColor];
    if (!self.title) {
        self.title = _key;
    }
    if (_isEditing) {
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                 target:self
                                                                                 action:@selector(savePressed)];
        self.navigationItem.rightBarButtonItem = saveBtn;
        
        if (self.enableScan) {
            self.keyboardToolbar.tintColor = self.navigationController.navigationBar.tintColor;
            self.textView.inputAccessoryView = self.keyboardToolbar;
        }
    }
    if (self.textLabelSwitch ) {
        NSArray *views = [self.view subviews];
        for (UIView *view in views) {
            if (view.tag >= 99) {
                CGRect frame = view.frame;
                frame.origin.y += 44 + 20;
                [view setFrame:frame];
            }
        }
    } else if ((IS_OS_8_OR_LATER && DEVICE_IS_IPHONE) || (self.addDelegate)) {
        CGRect frame = self.textView.frame;
        frame.origin.y += 44 + 20;
        [self.textView setFrame:frame];
    }
    
    if (DEVICE_IS_IPAD && self.addDelegate) {
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                  target:self
                                                                                  action:@selector(cancelPressed)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    }
    
    [self configureNote];
    
    if (self.keyboardType) {
        self.textView.keyboardType = self.keyboardType;
    } else {
        self.textView.keyboardType = UIKeyboardTypeDefault;
    }
}

-(void)configureNote {
    if (self.ignoreNoteRecord) {
        return;
    }
    
    if (self.note) {
        [self.textLabelSwitch setEnabled:NO];
    }
    
    if (self.saveLocation) {
        [self.textLabelSwitch setOn:YES];
    }
    
    if (self.note.latitude.length) {
        [self.textLabelSwitch setOn:YES];
    }

    self.textLabel.text = @"Want to record location: Yes or No";
    
    self.textView.text = self.note.notes;
    
    if (self.note) {
    }
    
}


- (IBAction)categoryButtonPressed:(id)sender {
    Aggregate *aggregate = nil;
    NSArray *fields = nil;
    NSString *title = nil;
    NSPredicate *predicate = nil;
    NSString *sortKey = nil;
    NSArray *detailFields = nil;
    
    aggregate = nil;
    
    fields = [NSArray arrayWithObjects:@"name", nil];
    
    sortKey = @"name";
    
    title = @"Categories";
    
    RCOObjectListViewController *listController = [[RCOObjectListViewController alloc] initWithNibName:@"RCOObjectListViewController"
                                                                                                bundle:nil
                                                                                             aggregate:aggregate
                                                                                                fields:fields
                                                                                          detailFields:detailFields
                                                                                                forKey:Key_Category
                                                                                     filterByPredicate:predicate
                                                                                           andSortedBy:sortKey];
    
    listController.selectDelegate = self;
    listController.addDelegateKey = Key_Category;
    listController.title = title;
        
    listController.iPhoneNewLogic = YES;
    listController.isViewControllerPushed = YES;
    [self.navigationController pushViewController:listController animated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(showKeyboard) withObject:nil afterDelay:1];
    
    if ([self.barcodes count] > 0) {
        if (self.textView.text) {
            self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, [self.barcodes componentsJoinedByString:@", "]];
        } else {
            self.textView.text = [self.barcodes componentsJoinedByString:@", "];
        }
    }
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
	AudioSessionSetActive(TRUE);
    
}

-(void)showKeyboard {
    if (_isEditing) {
        [self.textView becomeFirstResponder];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    AudioServicesDisposeSystemSoundID(scanSuccessSound);
    AudioSessionSetActive(FALSE);
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

-(void)setEditMode:(BOOL)editing {
    _isEditing = editing;
}

-(void)cancelPressed {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

-(void)savePressed {
    
    NSString *text = self.textView.text;
    
    text = [text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    text = [text stringByReplacingOccurrencesOfString:@"\r" withString:@" "];
    
    if (self.textLabelSwitch) {
        
        
        NSMutableArray *values = [NSMutableArray array];
        if (self.textLabelSwitch) {
            [values addObject:[NSNumber numberWithBool:self.textLabelSwitch.on]];
        }
        
        if (text) {
            [values addObject:text];
        }
        
        
        if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.addDelegate didAddObjects:values forKeys:[NSArray arrayWithObject:self.addDelegateKey]];
        }
        
    }
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:text forKey:self.addDelegateKey];
    } else {
        [self.editorDelegate selectedStringValue:text forKey:_key];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    _textString = nil;
    _key = nil;
    [self.barcodes removeAllObjects];
    
}


- (IBAction)scanPressed:(id)sender {
    
}

#pragma mark - Text View delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    return _isEditing;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.view endEditing:YES];
}

#pragma mark ZBarDelegate-

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
}

#pragma mark AddObject

-(void)didAddObject:(NSObject *)object forKey:(NSString *)key {


    NSLog(@"");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
