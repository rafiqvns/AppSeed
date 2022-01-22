//
//  SignatureController.m
//  MobileOffice
//
//  Created by Rosalind Hartigan on 12/1/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "SignatureViewController.h"
#import "RCOObjectEditorViewController.h"
#import "Signature+Signature_Imp.h"
#import "ShippingHeader_Imp.h"

@implementation SignatureViewController

@synthesize signatureImageView=m_signatureImageView;
@synthesize textfieldName=m_textfieldName;
@synthesize textfieldTitle=m_textfieldTitle;
@synthesize panner =m_panner;

@synthesize lastPoint, firstPoint;

@synthesize authorizationType=m_authorizationType;
@synthesize nameText=m_nameText;
@synthesize titleText=m_titleText;
@synthesize sigImageData=m_sigImageData;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) dealloc
{
    [m_signatureImageView release];
    [m_textfieldName release];
    [m_textfieldTitle release];
    
    [m_panner release];
    
    [m_authorizationType release];
    [m_titleText release];
    [m_nameText release];
    [m_sigImageData release];
    
    [super dealloc];
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
   
    self.panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
	[self.panner setMinimumNumberOfTouches:1];
	[self.panner setMaximumNumberOfTouches:1];
	[self.panner setDelegate:self];
	[[self.view viewWithTag:1] addGestureRecognizer:self.panner];
    
    self.signatureImageView.image = [UIImage imageWithData:(NSData *) self.sigImageData];
    self.sigImageData=nil;
    self.textfieldName.text = self.nameText;
    self.textfieldTitle.text = self.titleText;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];

    self.signatureImageView=nil;
    self.textfieldName=nil;
    self.textfieldTitle=nil;
    self.panner=nil;

    self.authorizationType=nil;  
    self.titleText=nil;
    self.nameText=nil;
    self.sigImageData=nil;

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}


#pragma mark - touches for signature
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    [self setDirty:true];
    
    if ([touch tapCount] == 2) {
        self.signatureImageView.image= nil;
        return;
    }
    
    lastPoint = [touch locationInView:self.signatureImageView];
    
    firstPoint=lastPoint;
    
    //NSLog(@"touchesBegan");
    
}

- (IBAction) move: (id) sender
{
    CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView: [(UIPanGestureRecognizer *) sender view]];
    //NSLog(@"move %f %f", translatedPoint.x, translatedPoint.y);
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastPoint = translatedPoint;
        lastPoint = [(UIPanGestureRecognizer*)sender locationInView: [(UIPanGestureRecognizer *) sender view]];
    }    

    translatedPoint = CGPointMake(firstPoint.x+translatedPoint.x, firstPoint.y+translatedPoint.y);
    
    UIGraphicsBeginImageContext(self.signatureImageView.frame.size);
    [self.signatureImageView.image drawInRect:CGRectMake(0, 0, self.signatureImageView.frame.size.width, self.signatureImageView.frame.size.height)];
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), translatedPoint.x, translatedPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signatureImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
            
    lastPoint=translatedPoint;
  

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    [self setDirty:true];
    
    if ([touch tapCount] == 2) {
        self.signatureImageView.image = nil;
        return;
    }
    
       
    
}

#pragma mark - Text Editing
- (IBAction) textChanged: (id) sender
{
    [self setDirty:true];
}

- (void) setDirty:(Boolean)dirty
{
    [super setDirty:dirty && [self.textfieldTitle.text isEqualToString:@"1234"]];
}

#pragma mark - RCOFieldEditor
- (void) setEditorDelegate:(RCOObjectEditorViewController *)theDelegate withValue:(NSObject *)theValue forKey:(NSString *)theKey
{
    if( [theKey hasSuffix:SIGNATURE_NAME] )
    {
        self.nameText = (NSString *) theValue;
        self.textfieldName.text = self.nameText;
        self.authorizationType = [theKey substringToIndex:[theKey length] - [SIGNATURE_NAME length]];
    }
    else if( [theKey hasSuffix:SIGNATURE_TITLE] )
    {
        self.titleText = (NSString *) theValue;
        self.textfieldTitle.text = self.titleText;
        self.authorizationType = [theKey substringToIndex:[theKey length] - [SIGNATURE_TITLE length]];
    }
    else if( [theKey hasSuffix:KEY_CONTENT] )
    {
        self.sigImageData = (NSData *) theValue;
        self.signatureImageView.image = [UIImage imageWithData:(NSData *) self.sigImageData];
        
        self.authorizationType = [theKey substringToIndex:[theKey length] - [KEY_CONTENT length]];
    }
    NSLog(@"%@", self.authorizationType);

    [super setEditorDelegate:theDelegate withValue:theValue forKey:theKey];
}

- (void) saveButtonPressed:(id)sender
{
   
    [self.fieldEditingDelegate setObjectValue: self.textfieldName.text 
                                       forKey: [NSString stringWithFormat:@"%@%@", self.authorizationType, SIGNATURE_NAME]];
    
    [self.fieldEditingDelegate setObjectValue: self.textfieldTitle.text 
                                       forKey: [NSString stringWithFormat:@"%@%@", self.authorizationType, SIGNATURE_TITLE]];
    
    if( (id) self.signatureImageView.image != (id) self.sigImageData )
    {
        
        [self.fieldEditingDelegate setObjectValue: UIImageJPEGRepresentation(self.signatureImageView.image, 1.0)
                                           forKey: [NSString stringWithFormat:@"%@%@", self.authorizationType, KEY_CONTENT]];
        
    }
    
    NSLog(@"%@", self.authorizationType);

    [self cancelButtonPressed:sender];
}


@end
