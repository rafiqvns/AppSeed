//
//  SignatureViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 4/22/13.
//  Copyright (c) 2013 RCO. All rights reserved.
//

#import "SignatureViewController.h"
#import "DataRepository.h"

@interface SignatureViewController ()
// used to return just the valid area
@property (nonatomic, assign) CGPoint minPoint;
@property (nonatomic, assign) CGPoint maxPoint;
@end

@implementation SignatureViewController

@synthesize signatureView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forJob:(NSString*)job
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _currentJob = job;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.minPoint = CGPointMake(10000, 10000);
    
    self.maxPoint = CGPointMake(0, 0);
    
    NSString *leftBtnTitle = nil;
    
    if (self.returnOnlyImage) {
        leftBtnTitle = @"Save";
    } else {
        leftBtnTitle = NSLocalizedString(@"Back", nil);
    }
    
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithTitle:leftBtnTitle
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(saveButtonPressed:)];
    self.navigationItem.rightBarButtonItem = saveBtn;
    
    UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", nil)
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(closePressed:)];
    self.navigationItem.leftBarButtonItem = closeBtn;
    
    _panel = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
	[_panel setMinimumNumberOfTouches:1];
	[_panel setMaximumNumberOfTouches:1];
	[_panel setDelegate:self];
    [self.signatureView addGestureRecognizer:_panel];
    [self.view bringSubviewToFront:self.signatureView];
    self.navigationItem.title = @"Signature";
    
    self.signatureView.image = self.signatureImage;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    _currentJob = nil;
    _panel = nil;
}

-(IBAction)clearPressed:(id)sender {
    self.signatureView.image = nil;
    
    // Remove the old signature file
	NSString *fullPath = [self signatureFileNameForCurrentJob];
    
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:&error];
    
    if (error) {
        NSLog(@"Failed to remove old Signature File");
    } else {
        NSLog(@"Removed old Signature File successfully");
    }
}

-(IBAction)closePressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:nil];
    }
}

-(IBAction)saveButtonPressed:(id)sender{
    if (self.returnOnlyImage) {
        [self returnImage];
    } else {
        [self saveImageToFile];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString*)signatureFileNameForCurrentJob {
    
    NSURL *fullPath =  [[DataRepository sharedInstance] dataDir];
    
    
	fullPath = [fullPath URLByAppendingPathComponent:@"signatureFiles"];
    
    NSString *fileName = [NSString stringWithFormat:@"Job_%@.png", _currentJob];
    
    fullPath = [fullPath URLByAppendingPathComponent:fileName];
    
    return [fullPath path];
}

-(void)returnImage {
    UIImage *signatureImage = nil;
    
    signatureImage = self.signatureView.image;
    
    double border = 10;
    
    CGRect fromRect = CGRectMake(self.minPoint.x - border, self.minPoint.y - border, self.maxPoint.x - self.minPoint.x + 2*border, self.maxPoint.y - self.minPoint.y + 2*border);
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(signatureImage.CGImage, fromRect);
    signatureImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);
    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        if (self.addDelegateKey) {
            [self.addDelegate didAddObject:signatureImage forKey:self.addDelegateKey];
        } else {
            [self.addDelegate didAddObject:signatureImage forKey:@"signature"];
        }
    }
}

- (NSString*)saveImageToFile {
    
    UIImage *signatureImage = nil;
    
    signatureImage = self.signatureView.image;
    
    CGRect fromRect = CGRectMake(self.minPoint.x, self.minPoint.y, self.maxPoint.x - self.minPoint.x, self.maxPoint.y - self.minPoint.y);
    
    CGImageRef drawImage = CGImageCreateWithImageInRect(signatureImage.CGImage, fromRect);
    signatureImage = [UIImage imageWithCGImage:drawImage];
    CGImageRelease(drawImage);

    
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        if (self.addDelegateKey) {
            [self.addDelegate didAddObject:signatureImage forKey:self.addDelegateKey];
        } else {
            [self.addDelegate didAddObject:signatureImage forKey:@"signature"];
        }
    }
    
    if (signatureImage == nil) {
        
        [self showSimpleMessage:@"Signature is empty"];
        return nil;
    }
    
	NSString *fullPath = [self signatureFileNameForCurrentJob];
    
    NSError *error = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[fullPath stringByDeletingLastPathComponent]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if (error) {
        NSLog(@"Signature Failed to create directory at path = %@ -- ", fullPath);
    }
    
    
    
    NSData *signatureData = UIImagePNGRepresentation(signatureImage);
    
    BOOL res = [[NSFileManager defaultManager] createFileAtPath:fullPath contents:signatureData attributes:nil];
    
    if (!res) {
        NSLog(@"Signature Failed to create file at path = %@ -- ", fullPath);
        return nil;
    } else {
        return fullPath;
    }
}

#pragma mark - touches for signature
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        self.signatureView.image= nil;
        return;
    }
    
    lastPoint = [touch locationInView:self.signatureView];
    
    firstPoint=lastPoint;
}

- (IBAction) move: (id) sender
{
    CGPoint translatedPoint;
    
    translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.signatureView];
    
    if([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan) {
        lastPoint = translatedPoint;
        lastPoint = [(UIPanGestureRecognizer*)sender locationInView: self.signatureView];
        // for iPhone does not enter in the
        firstPoint = lastPoint;
        
    }
    translatedPoint = CGPointMake(firstPoint.x+translatedPoint.x, firstPoint.y+translatedPoint.y);
    UIGraphicsBeginImageContext(self.signatureView.frame.size);
    
    [self.signatureView.image drawInRect:CGRectMake(0, 0, self.signatureView.frame.size.width, self.signatureView.frame.size.height)];
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 5.0);
    //CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 0.0, 0.0, 1.0, 1.0);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), translatedPoint.x, translatedPoint.y);
    CGContextStrokePath(UIGraphicsGetCurrentContext());
    self.signatureView.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    lastPoint=translatedPoint;
    
    double maxPointX = self.maxPoint.x;
    double maxPointY = self.maxPoint.y;

    double minPointX = self.minPoint.x;
    double minPointY = self.minPoint.y;
    
    if (translatedPoint.x > self.maxPoint.x) {
        maxPointX = translatedPoint.x;
    }

    if (translatedPoint.y > self.maxPoint.y) {
        maxPointY = translatedPoint.y;
    }

    if (translatedPoint.x < self.minPoint.x) {
        minPointX = translatedPoint.x;
    }

    if (translatedPoint.y < self.minPoint.y) {
        minPointY = translatedPoint.y;
    }
    
    self.minPoint = CGPointMake(minPointX, minPointY);
    self.maxPoint = CGPointMake(maxPointX, maxPointY);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    if ([touch tapCount] == 2) {
        self.signatureView.image = nil;
        return;
    }
}

@end
