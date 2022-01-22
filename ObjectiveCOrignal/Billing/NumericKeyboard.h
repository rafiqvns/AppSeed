//
//  NumericKeyboard.h
//  MobileOffice
//
//  Created by .D. .D. on 10/29/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    KeyboardKey_00 = 1,
    KeyboardKey_0,
    KeyboardKey_Dot,
    KeyboardKey_1,
    KeyboardKey_2,
    KeyboardKey_3,
    KeyboardKey_4,
    KeyboardKey_5,
    KeyboardKey_6,
    KeyboardKey_7,
    KeyboardKey_8,
    KeyboardKey_9,
    KeyboardKey_Home,
    KeyboardKey_End,
    KeyboardKey_PageUp,
    KeyboardKey_PageDown,
    KeyboardKey_Up,
    KeyboardKey_Left,
    KeyboardKey_Down,
    KeyboardKey_Right,
    KeyboardKey_Backspace,
    KeyboardKey_Done,
    KeyboardKey_X
};

typedef CFIndex  KeyboardKey;

@protocol NumericKeyboardDelegate <NSObject>

-(void)textField:(UITextField*)textField keyPressed:(KeyboardKey)key;
-(void)valueChanged:(NSString*)value forRow:(NSInteger)row andColumn:(NSInteger)column;

@end

@interface NumericKeyboard : UIViewController {
    
}

@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, strong) NSString *maxValue;
@property (nonatomic, strong) NSString *minValue;
@property (nonatomic, assign) BOOL isInputEditable;
@property (nonatomic, weak) id<NumericKeyboardDelegate> keyboardDelegate;

-(IBAction)keyTapped:(id)sender;

@end
