//
//  NumericKeyboard.m
//  MobileOffice
//
//  Created by .D. .D. on 10/29/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "NumericKeyboard.h"

@interface NumericKeyboard ()

@end

@implementation NumericKeyboard

@synthesize keyboardDelegate;
@synthesize textField;
@synthesize maxValue;
@synthesize minValue;

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
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    CGRect frame = self.view.frame;
    if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        frame.size.height = 264;
        frame.origin.y = 1024 - 264;
    } else {
        frame.size.height = 352;
        frame.origin.y = 768 - 352;
    }
    
    self.view.frame = frame;
    [self.view layoutSubviews];
    
    NSArray *views = self.view.subviews;
    for (UIView *subview in views) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton*)subview;

            if(UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
                [btn.titleLabel setFont:[UIFont systemFontOfSize:18]];
            } else {
                [btn.titleLabel setFont:[UIFont systemFontOfSize:20]];
            }
            [btn setBackgroundImage:[[UIImage imageNamed:@"key-background"] stretchableImageWithLeftCapWidth:8 topCapHeight:79] forState:UIControlStateNormal];
        }

         if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
             if (subview.tag == 300 || subview.tag == 301) {
                 // page Up and Page Down
                 [((UILabel*)subview) setFont:[UIFont systemFontOfSize:18]];
             }
         } else {
             if (subview.tag == 300 || subview.tag == 301) {
                 // page Up and page Down
                 [((UILabel*)subview) setFont:[UIFont systemFontOfSize:20]];
             }
         }
    }
}

-(void)addText:(NSString*)text {
    if (self.isInputEditable) {
        double value = [self.textField.text doubleValue];
        NSString *valueString = self.textField.text;
        if (value == 0 && [valueString length] == 1) {
            self.textField.text = text;
        } else {
            self.textField.text = [self.textField.text stringByAppendingString:text];
        }
        if ([self.keyboardDelegate respondsToSelector:@selector(valueChanged:forRow:andColumn:)]) {
            NSInteger row = self.textField.tag / 1000;
            NSInteger column = self.textField.tag - row*1000;
            [self.keyboardDelegate valueChanged:textField.text forRow:row andColumn:column];
        }
    }
}

-(void)addDot {
    if (self.isInputEditable) {
        NSRange range = [self.textField.text rangeOfString:@"."];
        if (range.length == 0) {
            self.textField.text = [self.textField.text stringByAppendingString:@"."];
            if ([self.keyboardDelegate respondsToSelector:@selector(valueChanged:forRow:andColumn:)]) {
                NSInteger row = self.textField.tag / 1000;
                NSInteger column = self.textField.tag - row*1000;
                [self.keyboardDelegate valueChanged:textField.text forRow:row andColumn:column];
            }
        }
    }
}

-(IBAction)keyTapped:(id)sender {
    KeyboardKey key = ((UIButton*)sender).tag;
    NSString *value = ((UIButton*)sender).titleLabel.text;
    double valueDouble = [self.textField.text doubleValue];
    
    switch (key) {
        case KeyboardKey_00: {
            if (valueDouble > 0) {
                [self addText:value];
            }
        }
            break;
        case KeyboardKey_0:
            if ((valueDouble > 0) || ([self.textField.text length] == 0))  {
                [self addText:value];
            }
            break;
        case KeyboardKey_1:
            [self addText:value];
            break;
        case KeyboardKey_2:
            [self addText:value];
            break;
        case KeyboardKey_3:
            [self addText:value];
            break;
        case KeyboardKey_4:
            [self addText:value];
            break;
        case KeyboardKey_5:
            [self addText:value];
            break;
        case KeyboardKey_6:
            [self addText:value];
            break;
        case KeyboardKey_7:
            [self addText:value];
            break;
        case KeyboardKey_8:
            [self addText:value];
            break;
        case KeyboardKey_9:
            [self addText:value];
            break;
        case KeyboardKey_Home:
        case KeyboardKey_End:
        case KeyboardKey_PageDown:
        case KeyboardKey_PageUp:
        case KeyboardKey_Up:
        case KeyboardKey_Down:
        case KeyboardKey_Left:
        case KeyboardKey_Right:
        case KeyboardKey_Done:
        case KeyboardKey_X:
            if ([self.keyboardDelegate respondsToSelector:@selector(textField:keyPressed:)]) {
                [self.keyboardDelegate textField:self.textField keyPressed:key];
            }
            break;
        case KeyboardKey_Backspace:
            if (self.isInputEditable) {
                if(self.textField.text.length > 0) {
                    self.textField.text = [self.textField.text substringToIndex:self.textField.text.length-1];
                    if ([self.keyboardDelegate respondsToSelector:@selector(valueChanged:forRow:andColumn:)]) {
                        NSInteger row = self.textField.tag / 1000;
                        NSInteger column = self.textField.tag - row*1000;
                        [self.keyboardDelegate valueChanged:textField.text forRow:row andColumn:column];
                    }
                }
            }
            break;
        case KeyboardKey_Dot:
            [self addDot];
        default:
            break;
    }
}

@end
