//
//  LoginMainViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 6/4/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "LoginMainViewController.h"
#import "InputCell.h"
#import "DataRepository.h"
#import "Settings.h"
#import "UIViewController+iOS6.h"
#import "HttpClientOperation.h"

#if TARGET_IPHONE_SIMULATOR || DEBUG
#define kNrSections 4
#else
#define kNrSections 2
#define kNrSections 4
#endif


#define kUserSection 0
#define kConnectSection 1
#define kServerSection 2
#define kPreviousUsers 3

#define kLoginRow 0
#define kPasswordRow 1

#define kLogin @"login"
#define kPassword @"password"
#define kURL @"URL"

#define kMaxTries 3

@interface LoginMainViewController(Private)
- (void)arrangeTableView;
- (void)loadSettings;
- (void)changeTableviewFrame;
- (void)connect;
- (void)saveLastTryLoginDate;
- (void)showLoginAlert;
- (void)saveLogin;
- (BOOL)validateData;

@end

@interface LoginMainViewController ()
@property (atomic, strong) NSString *selectedServer;
@property (atomic, strong) NSArray *availableServers;
@property (nonatomic, strong) NSDictionary *keyboardInfo;
@property (nonatomic, assign) BOOL disableChangeUserAndWorkOffline;

@end


@implementation LoginMainViewController


@synthesize tableView;
@synthesize themebackground;
@synthesize remeberView;
@synthesize rememberSwitch;
@synthesize selectedServer;
@synthesize availableServers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rememberLabel.text = NSLocalizedString(@"Remember password", nil);
    self.workOfflineLabel.text = NSLocalizedString(@"Work offline", nil);

    // Do any additional setup after loading the view from its nib.
    _loginParameters = [NSMutableDictionary new];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    
    UIImage *patternImage = [UIImage imageNamed:@"osxBackground.png"];
    self.themebackground.image = nil;
    self.themebackground.backgroundColor = [UIColor colorWithPatternImage:patternImage];
    
    [self loadSettings];
    NSNumber *numberOfTries = [[NSUserDefaults standardUserDefaults] objectForKey:@"numberOfTries"];

    if (numberOfTries != nil) {
        _numberOfTries = [numberOfTries intValue];
    } else {
        _numberOfTries = kMaxTries;
    }
    _tryLoginDate = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tryLoginDate"] doubleValue];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name: UIKeyboardWillShowNotification object:nil];    
    [nc addObserver:self selector:@selector(keyboardWillHide:) name: UIKeyboardWillHideNotification object:nil];
    
    NSString *server = [NSString stringWithFormat:@"%@", CSD_SERVER];
    [_loginParameters setValue:server forKey:kURL];
    
    
}

-(void)addDefaultLogin {

    NSString *server = [NSString stringWithFormat:@"%@", CSD_SERVER];

// -   [Settings switchToUser:@"csdtrainer"
//  -            withPassword:@"@20803"
//   -              andServer:server];
    
    NSLog(@"Username %@", [_loginParameters valueForKey:kLogin]);
    
    [Settings switchToUser:[_loginParameters valueForKey:kLogin]
              withPassword:[_loginParameters valueForKey:kPassword]
                 andServer:server];

    [Settings save];
    
    
    NSString* identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [[DataRepository sharedInstance] setDeviceId:identifier];
    
    
    
    NSArray *rights = @[ @"Mobile-SyncStaff", @"Mobile-DisplayTrainingCommand", @"Mobile-DisplayUsers", @"Mobile-DisplayTrainingTest", @"Mobile-DisplayTrainingSafety"];
    [[DataRepository sharedInstance] setRights:rights];
//    [_loginParameters setValue:@"crowdbotics" forKey:kLogin];
//    [_loginParameters setValue:@"QBnJcapdfUExrX7j" forKey:kPassword];
    
    [_loginParameters setValue:server forKey:kURL];
    
//    [_loginParameters setObject:@"yes" forKey:WorkOffline];
    [_loginParameters setObject:@"no" forKey:WorkOffline];
    [[DataRepository sharedInstance] setWorkOffline:NO];
    [self.offlineSwitch setOn:NO];

    [Settings setSetting:[NSNumber numberWithBool:YES]
                  forKey:CLIENT_REMEMBER_PASSWORD];
    [Settings save];
    
    [Settings setSetting:[NSArray arrayWithObject:@"LocalAdministrator_CSD"] forKey:USER_ROLES];
    [Settings setSetting:@"Certified Safe Driver" forKey:CLIENT_ORGANIZATION_NAME];
    [Settings setSetting:@"28" forKey:CLIENT_ORGANIZATION_ID];
    [Settings setSetting:@"Certified Safe Driver" forKey:CLIENT_COMPANY_NAME];
    [Settings save];

    self.disableChangeUserAndWorkOffline = NO;
    [self updateInputs:nil];
}

-(void)updateInputs:(NSString*)val {

    if (self.disableChangeUserAndWorkOffline) {
        [_loginParameters setObject:@"yes" forKey:WorkOffline];
        [[DataRepository sharedInstance] setWorkOffline:YES];

        [Settings setSetting:[NSNumber numberWithBool:YES]
                      forKey:CLIENT_REMEMBER_PASSWORD];
        [Settings save];

        [self.offlineSwitch setEnabled:NO];
        [self.rememberSwitch setEnabled:NO];
    }
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showLoginAlert];
    
    if (_isConnecting) {
        self.progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        
        self.progressHUD.removeFromSuperViewOnHide = YES;

        self.progressHUD.labelText = NSLocalizedString(@"Please wait while logging ...", nil);
        
        [self.view addSubview:self.progressHUD];
        [self.progressHUD show:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"");
}

-(void)viewWillLayoutSubviews {
    [self arrangeTableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _currentOrientation = toInterfaceOrientation;
    [self arrangeTableView];
}

-(void) dealloc {
    
    
    _loginParameters = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(CGSize)getScreenSizeForOrientation:(UIInterfaceOrientation)orientation{
    BOOL isPortrait = NO;
    if ((_currentOrientation < 1) || (_currentOrientation > 4)) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if ((orientation == UIInterfaceOrientationLandscapeRight) ||
            (orientation == UIInterfaceOrientationLandscapeLeft)) {
            isPortrait = NO;
        } else {
            isPortrait = YES;
        }
    } else  if ((_currentOrientation == UIInterfaceOrientationLandscapeLeft) ||
                (_currentOrientation == UIInterfaceOrientationLandscapeRight)) {
        isPortrait = NO;
    } else {
        isPortrait = YES;
    }

    CGSize screenSize = [UIScreen mainScreen].bounds.size;

    CGSize size = CGSizeZero;
    
    if (isPortrait) {
        // we should return the smaller dimension
        if (screenSize.width > screenSize.height) {
            size.height = screenSize.width;
            size.width = screenSize.height;
        } else {
            size.height = screenSize.height;
            size.width = screenSize.width;
        }
    } else {
        if (screenSize.width > screenSize.height) {
            size.height = screenSize.height;
            size.width = screenSize.width;
        } else {
            size.height = screenSize.width;
            size.width = screenSize.height;
        }
    }
    return size;
}

-(void)arrangeTableView {
    
    BOOL isPortrait = NO;
    if ((_currentOrientation < 1) || (_currentOrientation > 4)) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if ((orientation == UIInterfaceOrientationLandscapeRight) || 
            (orientation == UIInterfaceOrientationLandscapeLeft)) {
            isPortrait = NO;
        } else {
            isPortrait = YES;
        }
    } else  if ((_currentOrientation == UIInterfaceOrientationLandscapeLeft) || 
                (_currentOrientation == UIInterfaceOrientationLandscapeRight)) {
            isPortrait = NO;
    } else {
            isPortrait = YES;
    }
    
    CGSize screenSize = [self getScreenSizeForOrientation:_currentOrientation];
    
    if (!isPortrait) {
        if (DEVICE_IS_IPAD) {
            float tablewViewWidth = 600;
            CGRect frame = self.tableView.frame;
            frame.size.width = tablewViewWidth;
            frame.origin.x = (screenSize.width - tablewViewWidth)/2;
            self.tableView.frame = frame;
        } else {
            float tablewViewWidth = 320;
            CGRect frame = self.tableView.frame;
            frame.size.width = tablewViewWidth;
            if (_isEditing) {
                if (self.view.frame.size.height == 320) {
                    frame.size.height = 140;
                } else {
                    frame.size.height = 200;
                }
            } else {
                CGSize screenSize = [self getScreenSizeForOrientation:_currentOrientation];
                frame.size.height = screenSize.height - 20;
            }
            
            frame.origin.x = (screenSize.width - tablewViewWidth)/2;
            self.tableView.frame = frame;
        }
    } else {
        if (DEVICE_IS_IPAD) {
            float tablewViewWidth = 600;
            CGRect frame = self.tableView.frame;
            frame.size.width = tablewViewWidth;
            frame.origin.x = (screenSize.width - tablewViewWidth)/2;
            self.tableView.frame = frame;
        } else {
            float tablewViewWidth = 320;
            CGRect frame = self.tableView.frame;
            frame.size.width = tablewViewWidth;
            frame.origin.x = (screenSize.width - tablewViewWidth)/2;
            self.tableView.frame = frame;
        }
    }
}

-(void) loadSettings {
    [_loginParameters setObject:[[DataRepository sharedInstance] userName] forKey:kLogin];
    
    [_loginParameters setObject:CSD_SERVER forKey:kURL];
    NSString *curServer = [[DataRepository sharedInstance] server];
    NSString *server = [NSString stringWithFormat:@"%@", CSD_SERVER];
    
    NSMutableArray *servers = nil;
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSNumber *rememberPassword = [Settings getSettingAsNumber:CLIENT_REMEMBER_PASSWORD];

    {
        servers = [NSMutableArray arrayWithObjects:server, nil];

        if( [curServer length] && ![servers containsObject: curServer] ) {
            [servers addObject:curServer];
        }
    }
    
    self.availableServers = [NSArray arrayWithArray:servers];

    if ([rememberPassword boolValue] && (![[_loginParameters objectForKey:kPassword] length])) {
        [_loginParameters setObject:[Settings getSetting:CLIENT_PASSWORD_KEY] forKey:kPassword];
        self.rememberSwitch.on = YES;
        //_isConnecting = YES;
        //[self performSelector:@selector(connect) withObject:nil afterDelay:0.1];
    } else {
        self.rememberSwitch.on = NO;
    }

    NSString *offlineWork = [Settings getSetting:WorkOffline];
    
    if ([offlineWork boolValue]) {
        self.offlineSwitch.on = YES;
    } else {
        self.offlineSwitch.on = NO;
    }
    if ([offlineWork boolValue]) {
        [_loginParameters setObject:@"yes" forKey:WorkOffline];
        [[DataRepository sharedInstance] setWorkOffline:YES];
    } else {
        [_loginParameters setObject:@"no" forKey:WorkOffline];
        [[DataRepository sharedInstance] setWorkOffline:NO];
    }
}

#pragma mark Actions

-(IBAction)switchValueChanged:(UISwitch*)sender {
    

    if (sender == self.rememberSwitch) {
        [Settings setSetting:[NSNumber numberWithBool:sender.on]
                      forKey:CLIENT_REMEMBER_PASSWORD];
        [Settings save];

    } else if (sender == self.offlineSwitch) {
        NSString *val = @"no";
        if (sender.on) {
            val = @"yes";
        }
        [Settings setSetting:val
                      forKey:WorkOffline];
        [[DataRepository sharedInstance] setWorkOffline:[val boolValue]];

        [Settings save];
    }
}

- (void)connect {
    
   NSString *currentUserName = [_loginParameters objectForKey:kLogin];
    NSString *currentPassword = [_loginParameters objectForKey:kPassword];
    
    if ( ![[DataRepository sharedInstance] isNetworkReachable] || [[DataRepository sharedInstance] workOffline]) {
        if (self.disableChangeUserAndWorkOffline) {
            [self loginAsExistingUser:YES];
        } else {
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            _isConnecting = YES;
            
            [_loginParameters setValue:CSD_SERVER forKey:kURL];

            [[DataRepository sharedInstance] testConnection:[_loginParameters objectForKey:kURL]
                                               withUserName:currentUserName
                                                andPassword:currentPassword
                                                 callBackTo:self];
            
//            [self loginAsExistingUser:NO];
        }
        
    } else {
        // the credentials are not the same as the ones from the previous connect
        // the user might want to login with another account
        _isConnecting = YES;
        
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];

        

        [[DataRepository sharedInstance] testConnection:[_loginParameters objectForKey:kURL]
                                           withUserName:currentUserName 
                                            andPassword:currentPassword 
                                             callBackTo:self];
    }
}


- (BOOL) loginAsExistingUser:(BOOL)withSuccess {
    NSString *currentUserName = [_loginParameters objectForKey:kLogin];
    NSString *currentPassword = [_loginParameters objectForKey:kPassword];
    
    if( [Settings userIsValid: currentUserName
                 withPassword: currentPassword
                    andServer: [_loginParameters objectForKey:kURL]] )
    {
        _tryLoginDate = 3;
        _numberOfTries = kMaxTries;
        [self saveLastTryLoginDate];
        
        [self saveLogin];
        NSArray *rights = @[ @"Mobile-SyncStaff", @"Mobile-DisplayTrainingCommand", @"Mobile-DisplayUsers", @"Mobile-DisplayTrainingTest", @"Mobile-DisplayTrainingSafety"];
        [[DataRepository sharedInstance] setRights:rights];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMenuItems" object:[NSNumber numberWithBool:YES]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectPreviousCommand" object:nil];
        [self dismissModalViewControllerAnimatediOS6:NO];
        
        if ( ![[DataRepository sharedInstance] isNetworkReachable] ) {
            // if we don't have IC then we should post the notification the the app started loading, because loading the aggregates are already loaded
        } else {
            if (withSuccess) {
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationStartLoading" object:nil];
            }
        }
        return true;
    }

    _numberOfTries--;
    NSString *msg = nil;
    
    _numberOfTries = 3;

    if (_numberOfTries > 0) {
        if( _numberOfTries == 1 )
            msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login as previous user. You have 1 try remaining.", nil)];
        else
            msg = [NSString stringWithFormat:NSLocalizedString(@"Failed to login as previous user. You have %d more tries left.", nil), (int)_numberOfTries];
        
        _tryLoginDate = [[NSDate date] timeIntervalSince1970];
    } else {
        msg = NSLocalizedString(@"Please try to login in one hour", nil);
    }
    
    [self saveLastTryLoginDate];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network Unavailable", nil)
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];


return false;

}

- (void) saveLogin {
    
//    [Settings switchToUser:[_loginParameters objectForKey:kLogin]
//              withPassword:[_loginParameters objectForKey:kPassword]
//                 andServer:[_loginParameters objectForKey:kURL]];
    
    [DataRepository sharedInstance].isLoggedIn = true;
    [[DataRepository sharedInstance] setUser:[_loginParameters objectForKey:kLogin]
                                withPassword:[_loginParameters objectForKey:kPassword] 
                                   andServer:[_loginParameters objectForKey:kURL]];
    
    [Settings setSetting:[NSNumber numberWithBool:self.rememberSwitch.on]
                  forKey:CLIENT_REMEMBER_PASSWORD];
    [Settings resetKey:CLIENT2_SELECTED];
    
    
    NSArray *rights = @[ @"Mobile-SyncStaff", @"Mobile-DisplayTrainingCommand", @"Mobile-DisplayUsers", @"Mobile-DisplayTrainingTest", @"Mobile-DisplayTrainingSafety"];
    [[DataRepository sharedInstance] setRights:rights];
    
    [Settings save];
    
    [self addDefaultLogin];

}

- (void)showLoginAlert {
    
    return;
    
    NSTimeInterval currentTimeStamp = [[NSDate date] timeIntervalSince1970];
    if ((currentTimeStamp - _tryLoginDate < 3600)  && 
        (_numberOfTries == 0)){
        //the user tried to login before the 1 houre puased
        double minutes =  60 - (currentTimeStamp - _tryLoginDate)/60;
        NSString *msg = [NSString stringWithFormat: NSLocalizedString(@"You have to wait %d more minutes before next try", nil), (int)minutes];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil) 
                                                        message:msg 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles: nil];
        [alert show];
        _numberOfTries = 0;
    } else if (currentTimeStamp - _tryLoginDate >= 3600) {
        _numberOfTries = kMaxTries;
    }
    else
    {
        NSNumber *autoLogin = [Settings getSettingAsNumber:CLIENT_REMEMBER_PASSWORD];
        if ([autoLogin boolValue]) {
            //[self connect];
        }
    }
}

#pragma mark -
#pragma mark UITableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kUserSection:
            return 2;
        case kConnectSection:
            return 1;
        case kServerSection: {
#ifdef APPLE_STORE
            return 0;
#else
            return [self.availableServers count];
#endif
        }
        default:
            return 0;
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kNrSections;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == kConnectSection) {
        return 90;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    if (section == kConnectSection) {
        return self.remeberView;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = nil;
    
    UITableViewCell *cell = nil;
   
    
    switch (indexPath.section) {
        case kUserSection: {
            CellIdentifier = @"InputCell";
            
            InputCell *inputCell = (InputCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (inputCell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell"
                                                             owner:self
                                                           options:nil];
                inputCell = (InputCell *)[nib objectAtIndex:0];
            }

            NSString *title = nil;
            NSString *value = nil;
            switch (indexPath.row) {
                case kLoginRow:
                    title = NSLocalizedString(@"Login:", nil);
                    value = [_loginParameters valueForKey:kLogin];
                    inputCell.inputTextField.tag = kLoginRow;
                    if ([value length] == 0) {
                        [inputCell.inputTextField becomeFirstResponder];
                    }
                    inputCell.inputTextField.returnKeyType = UIReturnKeyNext;
                    if (self.disableChangeUserAndWorkOffline) {
                        [inputCell.inputTextField setEnabled:NO];
                    }
                    break;
                case kPasswordRow:
                    title = NSLocalizedString(@"Password:", nil);
                    value = [_loginParameters valueForKey:kPassword];
                    inputCell.inputTextField.tag = kPasswordRow;
                    if ([[_loginParameters valueForKey:kLogin] length] > 0) {
                        [inputCell.inputTextField becomeFirstResponder];
                    }
                    inputCell.inputTextField.returnKeyType = UIReturnKeyGo;
                    if (self.disableChangeUserAndWorkOffline) {
                        [inputCell.inputTextField setEnabled:NO];
                    }
                    break;
            }
            
            inputCell.titleLabel.text = title;
            inputCell.selectionStyle = UITableViewCellSelectionStyleNone;
            [inputCell.inputTextField addTarget:self
                                         action:@selector(textFieldChanged:)
                               forControlEvents:UIControlEventEditingChanged];
            inputCell.inputTextField.delegate = self;
            if (value) {
                inputCell.inputTextField.text = value;
            }
            
            inputCell.inputTextField.secureTextEntry = (indexPath.row == kPasswordRow);
            inputCell.inputTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            
            return inputCell;
            break;
        }
        case kConnectSection:
            CellIdentifier = @"SimpleCell";
            cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"Connect", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
            
        case kServerSection:
            CellIdentifier = @"SimpleSelectionCell";
            cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:CellIdentifier];
            }
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.text = [self.availableServers objectAtIndex:indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            if( [cell.textLabel.text isEqualToString:[_loginParameters objectForKey:kURL]] ) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            break;

    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == kConnectSection) {
        
        if (_numberOfTries == 0) {
            [self connect];

            [self showLoginAlert];
        } else {
            [self.view endEditing:YES];
            
            if (![self validateData]) {
                return;
            }
            if (!_isConnecting) {
                [self connect];
            }
        }
    }
    else if (indexPath.section == kServerSection) {
        
        [_loginParameters setObject:[self.availableServers objectAtIndex:indexPath.row] forKey:kURL];
        
        NSLog(@"Server: %@", [_loginParameters objectForKey:kURL]);
        [self.tableView reloadData];
    }
}
#pragma mark -
#pragma mark UITextFieldDelegate Methods

-(void)textFieldChanged:(UITextField*)textField {
    switch (textField.tag) {
        case kLoginRow:
            [_loginParameters setObject:textField.text forKey:kLogin];
            break;
        case kPasswordRow:
            [_loginParameters setObject:textField.text forKey:kPassword];
            break;            
    }
}

#pragma mark - Text delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == kLoginRow) {
        // we should go to next input
        
        InputCell *cell = (InputCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kPasswordRow inSection:0]];
        [cell.inputTextField becomeFirstResponder];
        
    } else {
        _isEditing = NO;
        [self.view endEditing:YES];
        [self connect];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    _isEditing = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {

}

-(void)changeTableviewFrame {
    
    if (DEVICE_IS_IPAD) {
    } else {
        [UIView beginAnimations:@"ChangeFrame" context:nil];
        [UIView setAnimationDuration:0.3];
        
        NSInteger keyBoardHeight = [[self.keyboardInfo objectForKey:@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;

        CGSize screenSize = [self getScreenSizeForOrientation:_currentOrientation];
        CGFloat X = (screenSize.width - 320)/2;
        
        self.tableView.frame = CGRectMake(X, 0, 320, screenSize.height - 20 - keyBoardHeight);

        [UIView commitAnimations];
    }
}

#pragma mark -
#pragma mark KeyboardNotifications

- (void)keyboardWillShow:(NSNotification *)notification {

    _isEditing = YES;

    if (DEVICE_IS_IPHONE) {
        self.keyboardInfo = notification.userInfo;
        [self changeTableviewFrame];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    _isEditing = NO;
    
    if (DEVICE_IS_IPAD) {
        
    } else {
        CGSize screenSize = [self getScreenSizeForOrientation:_currentOrientation];
        CGFloat X = (screenSize.width - 320)/2;

        self.tableView.frame = CGRectMake(X, 0, 320, screenSize.height - 20);
    }
}

#pragma mark -
#pragma mark ASIHTTPRequest delegate

- (void)requestFinished:(id )request {
    NSString *response = nil;
    NSString *errorStatusCode = nil;
    NSString *accessToken = nil;
    if ([request isKindOfClass:[NSData class]]) {
        response = [[NSString alloc] initWithData:((NSData*)request) encoding:NSUTF8StringEncoding];
    } else if ([request isKindOfClass:[NSDictionary class]]) {
        
        errorStatusCode = [(NSDictionary*)request objectForKey:ERROR_DETAIL];
        
        accessToken = [(NSDictionary*)request objectForKey:@"access"];
        
        
    } else {
        response = [[DataRepository sharedInstance] getResponseStringFromRequest:request];
    }
    
    
    [self.progressHUD hide:YES];
    if (accessToken) {
        
//        NSArray *rights = @[ @"Mobile-SyncStaff", @"Mobile-DisplayTrainingCommand", @"Mobile-DisplayUsers", @"Mobile-DisplayTrainingTest", @"Mobile-DisplayTrainingSafety"];
//        [[DataRepository sharedInstance] setRights:rights];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:accessToken forKey:USER_ACCESS_TOKEN];
//        [userDefaults setObject:accessToken forKey:USER_ACCESS_TOKEN];
        
        [userDefaults synchronize];
        
        [Settings setSetting:accessToken
                      forKey:USER_ACCESS_TOKEN];
        [Settings save];

        _tryLoginDate = 3;
        _numberOfTries = kMaxTries;
        
        [self saveLastTryLoginDate];
        
        BOOL isSameUser = NO;
        if ([[DataRepository sharedInstance].userName isEqualToString:[_loginParameters objectForKey:kLogin]] &&
            [[DataRepository sharedInstance].userPassword isEqualToString:[_loginParameters objectForKey:kPassword]] &&
            [[DataRepository sharedInstance].server isEqualToString:[_loginParameters objectForKey:kURL]]) {
            isSameUser = YES;
        }
        
        [self saveLogin];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBackground" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadMenuItems" object:[NSNumber numberWithBool:YES]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectPreviousCommand" object:nil];
        
        if ([[[DataRepository sharedInstance].syncOptions valueForKey:kDataSyncManuallyKey] boolValue] && isSameUser) {
            /*
             04.11 2014
             Do we need to show something?
             */
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectPreviousCommand" object:nil];
        } else {
            // Start logging message was shown while the user calls were made to the server, get user rights, functional group map, group map. device id ...
            if ([[DataRepository sharedInstance] workOffline]) {
                // 10.08.2016 we should not nything, or we should do ?
            } else {
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationStartLoading" object:nil];
            }
        }
        
        

        [self dismissModalViewControllerAnimatediOS6:YES];
    } else if (errorStatusCode) {
        NSString *msg = [NSString stringWithFormat:@"Exception: %@ while logging", errorStatusCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else if( [response isEqualToString:@"\"login failed.\""]) {
        _numberOfTries--;
        NSString *msg = nil;
        
        if (_numberOfTries > 0) {
            msg = [NSString stringWithFormat:NSLocalizedString(@"Login failed. You have %d more tries left", nil), (int)_numberOfTries];
            _tryLoginDate = [[NSDate date] timeIntervalSince1970];
        } else {
            msg = NSLocalizedString(@"Please try to login in one hour", nil);
        }
        [self saveLastTryLoginDate];
        
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil) 
                                                        message:msg 
                                                       delegate:nil 
                                              cancelButtonTitle:@"Ok" 
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        _tryLoginDate = 3;
        _numberOfTries = kMaxTries;
        
        [self saveLastTryLoginDate];
        
        BOOL isSameUser = NO;
        if ([[DataRepository sharedInstance].userName isEqualToString:[_loginParameters objectForKey:kLogin]] &&
            [[DataRepository sharedInstance].userPassword isEqualToString:[_loginParameters objectForKey:kPassword]] &&
            [[DataRepository sharedInstance].server isEqualToString:[_loginParameters objectForKey:kURL]]) {
            isSameUser = YES;
        } 
        
        [self saveLogin];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loadBackground" object:nil];
        
        if ([[[DataRepository sharedInstance].syncOptions valueForKey:kDataSyncManuallyKey] boolValue] && isSameUser) {
            /* 
             04.11 2014
             Do we need to show something?
             */
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectPreviousCommand" object:nil];
        } else {
            // Start logging message was shown while the user calls were made to the server, get user rights, functional group map, group map. device id ...
            if ([[DataRepository sharedInstance] workOffline]) {
                // 10.08.2016 we should not nything, or we should do ?
            } else {
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"applicationStartLoading" object:nil];
            }
        }

        [self dismissModalViewControllerAnimatediOS6:YES];
    }
    
    _isConnecting = NO;

}

- (void)requestFailed:(id )request {
    
    [MBProgressHUD hideHUDForView:self.view animated:true];
    
    NSString *errorMessage = [[DataRepository sharedInstance] getErrorFromRequestResponse:request];
    NSString *responseString  = [[DataRepository sharedInstance] getResponseStringFromRequest:request];
    NSInteger responseStatusCode = [[DataRepository sharedInstance] getStatusCodeFromRequestResponse:request];
    
    if (responseStatusCode == 500) {
        // bad login
        [self requestFinished:request];
        return;
    }
    
    NSLog(@"login request Failed: %@\n", errorMessage);

    // see if the user entered a known uid/pwd combination:
//    [self loginAsExistingUser:NO];
    
    if (responseStatusCode == 0 && !responseString) {
        // the call failed, this should be usually the lack of IC
        [[DataRepository sharedInstance] setLoginCallFailed];
    }
    _isConnecting = NO;
}

-(void)saveLastTryLoginDate {
    NSNumber *tryLoginDate = [NSNumber numberWithDouble:_tryLoginDate];
    NSNumber *numberOfTries = [NSNumber numberWithInteger:_numberOfTries];

    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:tryLoginDate forKey:@"tryLoginDate"];
    [userDefaults setObject:numberOfTries forKey:@"numberOfTries"];
    [userDefaults synchronize];
}

- (BOOL)validateData {
    NSString *message = nil;
    BOOL isvalidData = YES;
    
    if ([[_loginParameters valueForKey:kLogin] length] == 0) {
        message = NSLocalizedString(@"Please set login field", nil);
        isvalidData = NO;
    }
    if (isvalidData && [[_loginParameters valueForKey:kPassword] length] == 0) {
        message = NSLocalizedString(@"Please set password field", nil);
        isvalidData = NO;
    }
    
    if (!isvalidData) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:message 
                                                       delegate:nil 
                                              cancelButtonTitle:@"OK" 
                                              otherButtonTitles:nil];
        [alert show];
    }
    return  isvalidData;
}

#pragma mark HTTPClientDelegate Methods

-(void)HTTPClientOperation:(HttpClientOperation *)client didFinished:(id)resp {

    [MBProgressHUD hideHUDForView:self.view animated:true];
    [self requestFinished:resp];
}

-(void)HTTPClientOperation:(HttpClientOperation *)client didFailWithError:(NSDictionary *)errorInfoDict {
    NSInteger errorStatusCode = [[errorInfoDict objectForKeyedSubscript:ERROR_STATUS_CODE] integerValue];
    if (errorStatusCode == 500) {
        // this is bad user name or password
        [self requestFinished:errorInfoDict];
    } else {
        NSError *error = [errorInfoDict objectForKey:@"errorKey"];
        if (error) {

            NSString *errorDesc = error.description;
            /*
             31.07.2017
             we should show a radable message
             */
            
            errorDesc = @"Incorrect login please call support for assistance.";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                            message:errorDesc
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
        [self requestFailed:errorInfoDict];
    }
    NSLog(@"");
}
@end



