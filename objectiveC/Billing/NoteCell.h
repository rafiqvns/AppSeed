//
//  NoteCell.h
//  MobileOffice
//
//  Created by .D. .D. on 4/23/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteCell : UITableViewCell {
    
}

@property (nonatomic, strong) IBOutlet UILabel *noteLabel;
@property (nonatomic, strong) IBOutlet UILabel *photoLabel;
@property (nonatomic, strong) IBOutlet UIButton *editButton;

@end
