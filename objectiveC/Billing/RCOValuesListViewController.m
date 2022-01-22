//
//  RCOValuesListViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 7/26/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "RCOValuesListViewController.h"
#import "Settings.h"
#import <QuartzCore/QuartzCore.h>
#import "UILabelWithInset.h"

@interface RCOValuesListViewController ()

@property (nonatomic, strong) NSMutableArray *allItems;
@property (nonatomic, strong) NSMutableArray *itemsToRemove;
@property (nonatomic, strong) NSMutableArray *customColors;
@property (nonatomic, strong) NSMutableDictionary *colorNewAdded;
@property (nonatomic, strong) NSMutableArray *allItemsDescription;
@end

#define kRed @"red"
#define kGreen @"green"
#define kBlue @"blue"
#define kName @"name"
#define TAG_COLOR_NAME 100

#define kCurrencyDescription @"currencyDescription"
#define kCurrencyCode @"currencyCode"

@implementation RCOValuesListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil items:(NSArray*)items forKey:(NSString*)key
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _key = key;
        _items = items;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.allItems = [NSMutableArray arrayWithArray:_items];
    if (self.isCurrencyPicker && self.sortByObjectDescription) {
        // we have the currency symbols and we should sort by currency description
        [self loadItemsDescription];
    } else {
        self.allItemsDescription = [NSMutableArray arrayWithArray:self.allItems];
    }
    self.itemsToRemove = [NSMutableArray array];
    
    
    if (!self.customColors) {
        self.customColors = [NSMutableArray array];
    }
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil)
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;

    if (self.showClearButton) {
        UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Clear", nil)
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(clearPressed:)];
        self.navigationItem.leftBarButtonItem = clearButton;

    } else if (self.allowMultipleSelections) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(savePressed:)];
        [saveButton setEnabled:NO];
        self.navigationItem.rightBarButtonItem = saveButton;
    } else if (self.editType == EditTypeRemove) {
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(savePressed:)];
        self.navigationItem.rightBarButtonItem = saveButton;

        self.tableView.editing = YES;
    }
    
    if (self.allowMultipleSelections) {
        [self.tableView setAllowsMultipleSelection:YES];
    }
    
    if (!self.showColorPicker) {
        CGRect frame = self.tableView.frame;
        frame.size.height += self.bottomToolbar.frame.size.height;
        [self.bottomToolbar removeFromSuperview];
        [self.tableView setFrame:frame];
    }
    
    if (self.screenInfo) {
        CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 44);
        UILabelWithInset *lbl = [[UILabelWithInset alloc] initWithFrame:frame];
        [lbl setNumberOfLines:2];
        lbl.text = self.screenInfo;
        self.tableView.tableHeaderView = lbl;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.isCurrencyPicker && self.sortByObjectDescription) {
        NSInteger index = [self getCodeIndex:self.selectedValue];
        if (index != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionTop];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    _items = nil;
    _key = nil;
}

-(void)clearPressed:(id)sender {
    if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.selectDelegate didAddObject:nil forKey:_key];
    }
}

-(void)cancelPressed:(id)sender {
    if (self.editType == EditTypeRemove) {
        if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
            [self.selectDelegate didAddObject:nil forKey:_key];
        }
    } else {
        if (self.newLogic) {
            if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                if (sender) {
                    [self.selectDelegate didAddObject:nil forKey:nil];
                } else {
                    // 01.02.2019 the value is passed before....
                }
            }

        } else if (self.isPushed) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
                [self.selectDelegate didAddObject:nil forKey:nil];
            }
            if (DEVICE_IS_IPHONE) {
                [self dismissModalViewControllerAnimatediOS6:YES];
            }
        }
    }
}

-(void)savePressed:(id)sender {
    if (self.allowMultipleSelections) {
        if ([self.selectDelegate respondsToSelector:@selector(didAddObjects:forKeys:)]) {
            [self.selectDelegate didAddObjects:self.selectedValues forKeys:[NSArray arrayWithObjects:_key, nil]];
        }
    } else if ([self.itemsToRemove count]) {
        NSString *message = [NSString stringWithFormat:@"Do you really want to remove: %d items?", (int)[self.itemsToRemove count]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Yes", nil), @"No", nil];
        alert.tag = -1;
        [alert show];
    } else {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:@"There are no items to remove!"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* OKAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
        
        [ac addAction:OKAction];
        [self presentViewController:ac animated:YES completion:nil];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allItems count] + [self.customColors count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.numberOfLines) {
        return self.numberOfLines * 44;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"rcoValueList";
    
    UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if ([self.detailValues count]) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
    } else {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
    }
    
    if (self.numberOfLines) {
        [cell.textLabel setNumberOfLines:self.numberOfLines];
    }
    
    NSString *value = nil;

    if (self.isCurrencyPicker) {
        
        NSDictionary *currencyInfo = [self.allItemsDescription objectAtIndex:indexPath.row];
        
        NSString *code = [currencyInfo objectForKey:kCurrencyCode];
        value = [currencyInfo objectForKey:kCurrencyDescription];

        if ([self.selectedValues containsObject:code]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else if ([code isEqualToString:self.selectedValue]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

    } else if (self.showColorSample) {
        UIColor *color = nil;
        
        NSDictionary *colorDict = nil;
        
        if (indexPath.row < self.allItems.count) {
            colorDict = [self.allItems objectAtIndex:indexPath.row];
        } else {
            NSInteger index = indexPath.row - self.allItems.count;
            colorDict = [self.customColors objectAtIndex:index];
        }
        
        int red = [[colorDict objectForKey:kRed] intValue];
        int blue = [[colorDict objectForKey:kBlue] intValue];
        int green = [[colorDict objectForKey:kGreen] intValue];
        value = [colorDict objectForKey:kName];
        color = [UIColor colorWithRed:red*1.0/255.0
                                green:green*1.0/255.0
                                 blue:blue*1.0/255.0
                                alpha:1];

        cell.imageView.image = [UIImage imageNamed:@"transparent.png"];
        cell.imageView.backgroundColor = color;
        
        cell.imageView.layer.cornerRadius = 5.0;

    } else {
        if (indexPath.row < self.allItems.count) {
            if (self.propertiesToShow) {
                NSMutableArray *valueArray = [NSMutableArray array];
                
                NSDictionary *dictObj = [self.allItems objectAtIndex:indexPath.row];
                for (NSString *property in self.propertiesToShow) {
                    NSString *val = [dictObj objectForKey:property];
                    if (val) {
                        //[valueArray addObject:val];
                        [valueArray addObject:NSLocalizedString(val, nil)];
                    }
                }
                if ([valueArray count]) {
                    value = [valueArray componentsJoinedByString:@", "];
                } else {
                    value = @"";
                }
            } else {
                value = [self.allItems objectAtIndex:indexPath.row];
                value = NSLocalizedString(value, nil);
            }
            
            if ([self.selectedValues containsObject:value]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else if (self.selectedValue) {
                if ([value isEqualToString:self.selectedValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    
    cell.textLabel.text = value;
    
    if ([self.detailValues count]) {
        NSString *detailTxt = nil;
        
        if (indexPath.row < [self.detailValues count]) {
            detailTxt = [self.detailValues objectAtIndex:indexPath.row];
        }
        cell.detailTextLabel.text = detailTxt;
    }
    
    if (self.shrinkContentToFit) {
        [cell.textLabel setAdjustsFontSizeToFitWidth:YES];
    }
    
    if (self.showIndex) {
        NSString *formattedText = [NSString stringWithFormat:@"%d.%@", (int)(indexPath.row +1), cell.textLabel.text];
        cell.textLabel.text = formattedText;
    }
    
    return cell;
}

-(NSString*)textValueForIndexPath:(NSIndexPath*)indexPath {
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editType == EditTypeRemove) {
        return nil;
    }
    return indexPath;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editType == EditTypeRemove) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath  {

    if (self.editType == EditTypeRemove) {
        NSDictionary *dictObj = [self.allItems objectAtIndex:indexPath.row];

        NSMutableArray *valueArray = [NSMutableArray array];
        
        for (NSString *property in self.propertiesToShow) {
            NSString *val = [dictObj objectForKey:property];
            
            if (val) {
                [valueArray addObject:val];
            }
        }
        
        NSString *message = [NSString stringWithFormat:@"Remove: %@", [valueArray componentsJoinedByString:@", "]];
        
        return message;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = [self.allItems objectAtIndex:indexPath.row];
    
    NSMutableArray *valueArray = [NSMutableArray array];
    
    for (NSString *property in self.propertiesToShow) {
        NSString *val = [dict objectForKey:property];
        
        if (val) {
            [valueArray addObject:val];
        }
    }
    
    NSString *message = [NSString stringWithFormat:@"Do you really want to remove:\n%@", [valueArray componentsJoinedByString:@", "]];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notification", nil)
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:NSLocalizedString(@"Yes", nil), @"No", nil];
    alert.tag = indexPath.row;
    
    [alert show];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSDictionary *dict = [self.allItems objectAtIndex:indexPath.row];
    NSLog(@"asds");
}

- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSDictionary *dict = [self.allItems objectAtIndex:indexPath.row];
    NSLog(@"asds");

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSObject *value = nil;
    
    if (self.propertiesToShow) {
        NSDictionary *dictObj = [self.allItems objectAtIndex:indexPath.row];

        if ([self.propertiesToShow count] == 1) {
            NSString *property = [self.propertiesToShow objectAtIndex:0];
            value = [dictObj objectForKey:property];
        } else {
            value = dictObj;
        }
    } else {
        if (indexPath.row < self.allItems.count) {
            value = [self.allItems objectAtIndex:indexPath.row];
        } else {
            NSInteger index = indexPath.row - self.allItems.count;
            value = [self.customColors objectAtIndex:index];
        }
    }
    
    if ([value isKindOfClass:[NSString class]]) {
        NSString *valStr = (NSString*)value;
    }
    
    if (self.isCurrencyPicker && self.sortByObjectDescription) {
        // when showing currency picker we need to sort by currency description but we need to sednd back currency code
        NSDictionary *currencyInfo = [self.allItemsDescription objectAtIndex:indexPath.row];
        value = [currencyInfo objectForKey:kCurrencyCode];
    }
    
    BOOL skipCancel = NO;
    
    if (self.allowMultipleSelections) {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        if ([self.selectedValues containsObject:value]) {
            // we should remove it
            [self.selectedValues removeObject:value];
        } else {
            // we should add it
            if (!self.selectedValues) {
                self.selectedValues = [NSMutableArray array];
            }
            [self.selectedValues addObject:value];
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
    } else if ([self.selectDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.selectDelegate didAddObject:value forKey:_key];
        if (DEVICE_IS_IPAD) {
            skipCancel = YES;
        }
    }
    
    if ((!skipCancel) && !self.allowMultipleSelections) {
        [self cancelPressed:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == TAG_COLOR_NAME) {
        UITextField *input = [alertView textFieldAtIndex:0];
        NSString *colorName = input.text;
        NSLog(@"input value = %@", colorName);
        if (buttonIndex == 0) {
            [self.colorNewAdded setObject:colorName forKey:kName];
            [self.customColors addObject:self.colorNewAdded];
            
            [Settings save];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        [self.tableView reloadData];

    } else {
        if (buttonIndex == 0) {
            if (alertView.tag >= 0) {
                // tapped on yes remove item
                NSObject *obj = [self.allItems objectAtIndex:alertView.tag];
                [self.allItems removeObject:obj];
                [self.itemsToRemove addObject:obj];
                [self.tableView reloadData];
                
            } else {
                // confirmation for delete all removed items
                if ([self.selectDelegate respondsToSelector:@selector(didRemoveObjects:forKey:)]) {
                    [self.selectDelegate didRemoveObjects:self.itemsToRemove forKey:_key];
                }
            }
        }
    }
}

-(IBAction)colorPickerButtonPressed:(id)sender {
}

#pragma mark Utilities 

-(void)loadItemsDescription {
    
    NSLocale *locale = [NSLocale currentLocale];

    self.allItemsDescription = [NSMutableArray array];
    
    if (self.isCurrencyPicker && self.sortByObjectDescription) {
        for (NSString *currencyCode in _items) {
            
            NSString *value = [NSString stringWithFormat:@"%@ - (%@-%@)", [locale displayNameForKey:NSLocaleCurrencyCode value:currencyCode], currencyCode, [locale displayNameForKey:NSLocaleCurrencySymbol value:currencyCode]];
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:value forKey:kCurrencyDescription];
            [dict setObject:currencyCode forKey:kCurrencyCode];

            [self.allItemsDescription addObject:dict];
        }
    }
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:kCurrencyDescription ascending:YES comparator:^(id obj1, id obj2) { return [obj1 compare:obj2 options:NSCaseInsensitiveSearch]; }];
    [self.allItemsDescription sortUsingDescriptors:[NSArray arrayWithObject:sd]];
    
}

-(NSInteger)getCodeIndex:(NSString*)code {
    NSInteger index = 0;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K=%@", kCurrencyCode, code];
    NSArray *items = [self.allItemsDescription filteredArrayUsingPredicate:predicate];
    if ([items count]) {
        NSDictionary *currencyInfo = [items objectAtIndex:0];
        index = [self.allItemsDescription indexOfObject:currencyInfo];
    }
    return index;
}

-(void)showCustomReminderPicker {
}

-(double)heightForText:(NSString*)text {
    CGRect frame = self.tableView.frame;
    CGSize maximumLabelSize = CGSizeMake(frame.size.width - 40, CGFLOAT_MAX);
    UIFont *fontText = [UIFont systemFontOfSize:17];
    
    CGRect textRect = [text boundingRectWithSize:maximumLabelSize
                                         options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      attributes:@{NSFontAttributeName: fontText}
                                         context:nil];
    if (textRect.size.height < 44) {
        return 44;
    }
    
    return textRect.size.height + 10;
}


@end
