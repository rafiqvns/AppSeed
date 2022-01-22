//
//  SignatureController.h
//  MobileOffice
//
//  Created by Rosalind Hartigan on 12/1/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "RCOFieldEditorViewController.h"


@interface SignatureViewController : RCOFieldEditorViewController <UIGestureRecognizerDelegate>
{
    UIImageView *m_signatureImageView;
    UITextField *m_textfieldName;
    UITextField *m_textfieldTitle;
        
    UIPanGestureRecognizer *m_panner;
    CGPoint lastPoint;
    CGPoint firstPoint;
    
    
    NSString *m_authorizationType;
    NSString *m_nameText;
    NSString *m_titleText;
    NSData *m_sigImageData;
    
    
}

@property (nonatomic, retain) IBOutlet UIImageView *signatureImageView;
@property (nonatomic, retain) IBOutlet UITextField *textfieldName;
@property (nonatomic, retain) IBOutlet UITextField *textfieldTitle;
@property (nonatomic, retain) UIPanGestureRecognizer *panner;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, assign) CGPoint firstPoint;

@property (nonatomic, retain) NSString *authorizationType;
@property (nonatomic, retain) NSString *nameText;
@property (nonatomic, retain) NSString *titleText;
@property (nonatomic, retain) NSData *sigImageData;

- (IBAction) textChanged: (id) sender;

@end
