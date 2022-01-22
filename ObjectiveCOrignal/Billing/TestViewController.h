//
//  TestViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 6/7/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController < UITextFieldDelegate>{
    
    BOOL _isCripting;
}

@property (nonatomic, strong) IBOutlet UITextField *textField;
@property (nonatomic, strong) IBOutlet UITextField *passwordField;
@property (nonatomic, strong) IBOutlet UILabel *result;
@property (nonatomic, strong) IBOutlet UIButton *criptButton;

@property (nonatomic, strong) NSData *data;

-(IBAction)test:(id)sender;
-(IBAction)switchValues:(id)sender;

-(IBAction)encriptFile:(id)sender;
-(IBAction)decriptFile:(id)sender;

@end
