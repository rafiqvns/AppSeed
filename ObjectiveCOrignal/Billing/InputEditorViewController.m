//
//  InputEditorViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 1/2/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "InputEditorViewController.h"
#import "InputCell.h"
#import "UIViewController+iOS6.h"

@interface InputEditorViewController ()

@end

@implementation InputEditorViewController

@synthesize optionInputDelegate;
@synthesize tableView;
@synthesize editorId;
@synthesize options;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withInputs:(NSArray*)inputs andButtons:(NSArray*)buttons
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _inputs = inputs;
        _buttons = buttons;
    }
    return self;
}

-(void)dealloc {
    _inputs = nil;
    _buttons = nil;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.options = [NSMutableDictionary dictionary];
    
    if (DEVICE_IS_IPHONE) {
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
        self.navigationItem.leftBarButtonItem = cancelBtn;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancelPressed:(id)sender {

    [self dismissModalViewControllerAnimatediOS6:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [_inputs count];
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_buttons count] + [self.extraOptions count] + 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return self.title;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString *CellIdentifier = @"InputCell";
        InputCell *inputCell = nil;
        
        inputCell = (InputCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (inputCell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"InputCell"
                                                         owner:self
                                                       options:nil];
            inputCell = (InputCell *)[nib objectAtIndex:0];
        }
    
        NSDictionary *inputInfo = [_inputs objectAtIndex:indexPath.row];
        inputCell.titleLabel.text = [inputInfo objectForKey:@"title"];
        
        inputCell.inputTextField.placeholder = [inputInfo objectForKey:@"title"];
        inputCell.inputTextField.text = [inputInfo objectForKey:@"value"];

        [inputCell.inputTextField addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventEditingChanged];
        inputCell.inputTextField.tag = indexPath.row;
        inputCell.inputTextField.delegate = self;
        
        if ([_buttons count] == 0) {
            inputCell.inputTextField.enabled = NO;
        } else {
            inputCell.inputTextField.enabled = YES;
        }
        
        if ([inputInfo objectForKey:@"secure"]) {
            inputCell.inputTextField.secureTextEntry = YES;
        } else {
            inputCell.inputTextField.secureTextEntry = NO;
        }
    
    return inputCell;
    } else if (([self.extraOptions count] > 0) && (indexPath.section <= [self.extraOptions count])) {
        
        NSString *CellIdentifier = @"SwitchCell";
        UITableViewCell *cell = nil;
        cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
                
        NSDictionary *optionInfo = [self.extraOptions objectAtIndex:indexPath.section - 1];
        cell.textLabel.text = [optionInfo objectForKey:@"title"];

        UISwitch *saveSwitch = [[UISwitch alloc] init];
        saveSwitch.on = [[optionInfo objectForKey:@"value"] boolValue];
        cell.accessoryView = saveSwitch;
        
        [saveSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        return cell;
    } else {
        NSString *CellIdentifier = @"SimpleCell";
        UITableViewCell *cell = nil;
        cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
 
        cell.textLabel.text = [_buttons objectAtIndex:(indexPath.section - 1 - [self.extraOptions count])];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section > 0) {
        if (indexPath.section == (1 + [self.extraOptions count])) {
            NSArray *keys = [self.options allKeys];
            for (NSString *key in keys) {
                [self.optionInputDelegate inputEditor:self.editorId didChangeValue:[self.options objectForKey:key] forOption:[key intValue]];
            }
        }
        [self.optionInputDelegate inputEditor:editorId didSelectOption:(indexPath.section - 1)];
        if (DEVICE_IS_IPHONE) {
            [self dismissModalViewControllerAnimatediOS6:YES];
        }
    }
}

-(void)switchChanged:(id)sender {
    NSLog(@"switch");
    BOOL switchValue = ((UISwitch*)sender).on;
    NSDictionary *optionInfo = [self.extraOptions objectAtIndex:0];
    [self.optionInputDelegate inputEditor:self.editorId didChangeValue:[NSNumber numberWithBool:switchValue] forKey:[optionInfo objectForKey:@"key"]];
}

-(void)valueChanged:(UITextField*)sender {
    [self.options setObject:sender.text forKey:[NSString stringWithFormat:@"%d", sender.tag]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

@end
