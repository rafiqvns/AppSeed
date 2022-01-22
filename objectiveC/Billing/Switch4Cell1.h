//
//  Switch4Cell.h
//  MobileOffice
//
//  Created by .D. .D. on 9/17/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Switch4Cell.h"
//FIX 
/*
@protocol Switch4CellProtocol <NSObject>

-(IBAction)switchSelected:(id)sender;

@end
*/

@interface Switch4Cell1 : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UISegmentedControl *switch1;
@property (nonatomic, strong) IBOutlet UILabel *label1;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switch2;
@property (nonatomic, strong) IBOutlet UILabel *label2;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switch3;
@property (nonatomic, strong) IBOutlet UILabel *label3;
@property (nonatomic, strong) IBOutlet UISegmentedControl *switch4;
@property (nonatomic, strong) IBOutlet UILabel *label4;

@property (nonatomic, weak) id<Switch4CellProtocol> delegate;

@end
