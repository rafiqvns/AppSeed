//
//  HomeBaseViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "HomeBaseViewController.h"
#import "Settings.h"
#import "UIColor+TKCategory.h"
#import "DataRepository.h"

@interface HomeBaseViewController ()

@end

#define kDefaultPageHeight 1242
#define kDefaultPageWidth  960

@implementation HomeBaseViewController

@synthesize bottomToolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.progressHUD.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.progressHUD.delegate = self;
    
    NSNumber *themeId = [NSNumber numberWithInt:1];
    
    if ([self.navigationController.viewControllers count] == 1) {
        // we add home button only for rootView controller
        UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Home", nil)
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(homePressed:)];
        if ([themeId intValue] == 1) {
            //[homeButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor grayColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        }
        self.navigationItem.leftBarButtonItem = homeButton;
    } else {
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(backPressed:)];
        if ([themeId intValue] == 1) {
            //[backButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIColor grayColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
        }
        self.navigationItem.leftBarButtonItem = backButton;
    }
    
    
    if ([themeId intValue] == 1) {
        self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:187.0/255.0 green:188.0/255.0 blue:191.0/255.0 alpha:1];
        
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
        
        /*mediacom*/
        self.bottomToolbar.tintColor = [UIColor colorWithRed:187.0/255.0 green:188.0/255.0 blue:191.0/255.0 alpha:1];
        
        self.bottomToolbar.tintColor = [UIColor darkGrayColor];
        
        //self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor grayColor] forKey:UITextAttributeTextColor];
        
        NSArray *items = self.bottomToolbar.items;
        
        NSMutableArray *newItems = [NSMutableArray array];
        
        for (UIBarButtonItem *btn in items) {
            [newItems addObject:btn];
        }
        
        [self.bottomToolbar setItems:newItems];
    } else {
    }
    
    [[UIToolbar appearance] setBarTintColor:[UIColor toolBarColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation duration:0];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];    
}

-(void)unregisterKeyboardEvents {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)registerKeyboardEvents {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)backPressed:(id)sender {
    if (DEVICE_IS_IPAD) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"homeTapped" object:[NSNumber numberWithBool:YES]];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)homePressed:(id)sender {
    if ([self respondsToSelector:@selector(unRegisterCallbacks)]) {
        [self unRegisterCallbacks];
    }
    /*
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
    */
    [self dismissModalViewControllerAnimatediOS6:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"homeTapped" object:[NSNumber numberWithBool:YES]];

    // fis a issue wit a loading not being removed from the screen
    [[NSNotificationCenter defaultCenter] postNotificationName:@"commandLoaded" object:nil];
}

#pragma mark -
#pragma mark KeyboardNotifications

- (void)keyboardWillShow:(NSNotification *)notification {
    // this should be overwritten
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // this should be overwritten
}

-(void)dealloc {
    if (0) {
        //[self.popoverCtrl dismissPopoverAnimated:NO];
    }
    self.actionButton = nil;
    
}

#pragma mark - Callbacks

- (void)unRegisterCallbacks {
}

- (void)registerCallbacks {
}

#pragma mark -
#pragma mark MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    
}

#pragma mark -
#pragma mark UIPopoverControllerDelegate

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    if (DEVICE_IS_IPAD) {
        if (!self.presentedViewController.isBeingDismissed) {
            [super dismissViewControllerAnimated:flag completion:completion];
        } else {
        }
    } else {
        [super dismissViewControllerAnimated:flag completion:completion];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
    return _shouldDismissPopover;
}


#pragma mark -
#pragma mark Email Methods

- (void)sendEmail:(NSDictionary*)params {
    [self showEmailModalViewWithInfo:params];
}

-(void) showEmailModalViewWithInfo:(NSDictionary*)info {
    
    BOOL isPlainContnt = [[info objectForKey:EMAIL_CONTENTPLAIN] boolValue];
    
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString* documentDirectory = [documentDirectories objectAtIndex:0];
    NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:@"calendar.pdf"];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    
    [picker setSubject:[info objectForKey:EMAIL_SUBJECT]];
    
    // Fill out the email body text
    
    NSString *emailBody = [info objectForKey:EMAIL_CONTENT];
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    
    NSData *fileContent = [NSData dataWithContentsOfFile:documentDirectoryFilename];
    
    if (!isPlainContnt) {
        [picker addAttachmentData:fileContent
                         mimeType:@"application/pdf"
                         fileName:documentDirectoryFilename];
    }
    
    [self presentModalViewControlleriOS6:picker animated:YES];
    
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertController *al = [UIAlertController alertControllerWithTitle:@"Email"
                                                                        message:@"Sending Failed "
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
            [al addAction:okAction];
            [self presentViewController:al animated:YES completion:nil];
        }
            
            break;
    }
    [self dismissModalViewControllerAnimatediOS6:YES];
}

-(void)showMessage:(NSString*)message {
    if (message) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

@end
