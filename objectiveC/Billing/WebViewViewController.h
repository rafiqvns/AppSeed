//
//  WebViewViewController.h
//  MobileOffice
//
//  Created by .D. .D. on 5/4/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
// 13.04.2020 #import "HomeBaseViewController.h"
#import "HomeBaseViewController.h"
#import "AddObject.h"

@class FormI9;
@class Aggregate;

@interface WebViewViewController : /*13.04.2020 BaseViewController*/HomeBaseViewController </*UIWebViewDelegate, */WKNavigationDelegate> {
    NSString *_textContent;
    NSString *_navTitle;
    NSString *_filePath;
    NSURL *_fileURL;
    BOOL _loadFromFile;
    
    //20.04.2020 UIWebView *_webViewForPDF;
    WKWebView *_webViewForPDF;

    UIDeviceOrientation _deviceOrientation;
}

//20.04.2020 @property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet WKWebView *webView;

@property (nonatomic, strong) IBOutlet UITextView *textView;

@property (nonatomic, strong) NSDictionary *contractInfo;

@property (nonatomic, strong) NSArray *contractBoolValues;

@property (nonatomic, strong) NSArray *tags;

@property (nonatomic, strong) NSString *htmlName;

@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) FormI9 *form;

@property (nonatomic, strong) Aggregate *aggregate;

@property (nonatomic, strong) id object;

@property (nonatomic, strong) NSArray *details;

@property (nonatomic, strong) NSArray *notes;

@property (nonatomic, strong) NSArray *notesImages;

@property (nonatomic, assign) BOOL loadFromWeb;

@property (nonatomic, strong) NSDictionary *values;

@property (nonatomic, assign) BOOL showEmailButton;

@property (nonatomic, assign) BOOL showPrintButton;

@property (nonatomic, strong) NSArray *chartKeys1;
@property (nonatomic, strong) NSArray *chartValues1;

@property (nonatomic, strong) NSArray *chartKeys2;
@property (nonatomic, strong) NSArray *chartValues2;

@property (nonatomic, strong) NSDictionary *htmlExtraKeys;
@property (nonatomic, assign) BOOL loadAsTestHTML;
@property (nonatomic, strong) NSDictionary *testCristicalItems;
@property (nonatomic, strong) NSString *formNumber;
@property (nonatomic, strong) NSArray *fieldsNA;
@property (nonatomic, strong) NSString *js;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil content:(NSString*)textContent title:(NSString*)title;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filePath:(NSString*)filePath;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fileURL:(NSURL*)fileURL;

@end
