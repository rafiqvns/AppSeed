//
//  WebViewViewController.m
//  MobileOffice
//
//  Created by .D. .D. on 5/4/12.
//  Copyright (c) 2012 RCO. All rights reserved.
//

#import "WebViewViewController.h"
#import "UIViewController+iOS6.h"
#import <CoreText/CoreText.h>
#import "HTMLConstants.h"
#import "UIPrintPageRenderer+PDF.h"
#import <MessageUI/MessageUI.h>
#import "TestDataDetail+CoreDataClass.h"
#import "TestDataHeader+CoreDataClass.h"
#import "SignatureDetailAggregate.h"
#import "SignatureDetail.h"
#import "DataRepository.h"
#import "Note+CoreDataClass.h"
#import "WKWebView+WKWebView_PDF.h"

#define kPaperSizeA4 CGSizeMake(595.2,841.8)
#define kPaperSizeLetter CGSizeMake(612,792)

@interface WebViewViewController () <WKUIDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;


@property (nonatomic, strong) UIImage *driverSignature;
@property (nonatomic, strong) UIImage *evaluatorSignature;
@property (nonatomic, strong) UIImage *compRepSignature;

@property (nonatomic, strong) NSDate *driverSignatureDate;
@property (nonatomic, strong) NSDate *evaluatorSignatureDate;
@property (nonatomic, strong) NSDate *compRepSignatureDate;

@property (nonatomic, assign) NSInteger pageWidth;


@end

#define kDefaultPageHeight 1242
#define kDefaultPageWidth  960 


@implementation WebViewViewController

@synthesize webView;
@synthesize textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil content:(NSString*)textContent title:(NSString*)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _textContent = textContent;
        _navTitle = title;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil filePath:(NSString*)filePath {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _filePath = filePath;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil fileURL:(NSURL*)fileURL {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _fileURL = fileURL;
    }
    return self;
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
    // Do any additional setup after loading the view from its nib.
    
    /*
    20.04.2020
    self.webView.delegate = self;

    [self.webView setScalesPageToFit:YES];
    */
    
    if (self.loadFromWeb) {
        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:_fileURL];
        // [self.webView loadRequest:urlrequest];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                                 init];
        WKUserContentController *controller = [[WKUserContentController alloc]
                                               init];
        
        [controller addScriptMessageHandler:self name:@"observe"];
        configuration.userContentController = controller;
        
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:configuration];
        self.wkWebView.UIDelegate = self;
        self.wkWebView.navigationDelegate = self;
        
        self.wkWebView.autoresizingMask = self.webView.autoresizingMask;
        [self.wkWebView loadRequest:urlrequest];
        
        [self.view addSubview:self.wkWebView];
        
        // load the HTML that we will use for generating PDF
        _webViewForPDF = [[WKWebView alloc] initWithFrame: CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight)];
        _webViewForPDF.navigationDelegate = self;
        /*
         20.04.2020
         
        [_webViewForPDF setScalesPageToFit:YES];
        [_webViewForPDF setDelegate:self];
         */
        
        if (DEVICE_IS_IPAD && self.addDelegate) {
            UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(closeButtonPressed:)];
            self.navigationItem.leftBarButtonItem = closeButton;
        }

    } else if ([self.object isKindOfClass:[TestDataHeader class]] || self.values || self.loadAsTestHTML) {
        [self.textView removeFromSuperview];

        [self loadSignatures];
        self.title = @"Preview";
                
        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:_fileURL];
        // [self.webView loadRequest:urlrequest];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                                 init];
        WKUserContentController *controller = [[WKUserContentController alloc]
                                               init];
        
        [controller addScriptMessageHandler:self name:@"observe"];
        configuration.userContentController = controller;
        
        self.wkWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:configuration];
        self.wkWebView.UIDelegate = self;
        self.wkWebView.navigationDelegate = self;
        
        self.wkWebView.autoresizingMask = self.webView.autoresizingMask;
        
        [self.wkWebView loadRequest:urlrequest];
        
        [self.view addSubview:self.wkWebView];
        
        _webViewForPDF = [[WKWebView alloc] initWithFrame: CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight)];
        _webViewForPDF.navigationDelegate = self;
        
        /*
        20.04.2020
        [_webViewForPDF setScalesPageToFit:YES];
        [_webViewForPDF setDelegate:self];
         */

        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(closeButtonPressed:)];
        self.navigationItem.leftBarButtonItem = closeBtn;
        
    } else if (!_fileURL && ![self.htmlName isEqualToString:@"I9Form"]) {
    
        [self.webView loadHTMLString:_textContent baseURL:nil];
        /*
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self action:@selector(closeBtn)];
        self.navigationItem.rightBarButtonItem = closeBtn;
        [closeBtn release];
        */
        self.title = _navTitle;
        /*
        self.webView.frame = self.view.frame;
        self.webView.contentStretch = self.webView.frame;
        self.webView.scalesPageToFit = YES;
        */
        self.textView.text = _textContent;
        if (IS_OS_8_OR_LATER && DEVICE_IS_IPHONE) {
            CGRect frame = self.textView.frame;
            frame.origin.y += 64;
            [self.textView setFrame:frame];
        }
    } else if ([self.htmlName isEqualToString:@"I9Form"]) {
        [self.textView removeFromSuperview];
        
        self.title = @"I-9 Form";
        
        NSString *HTMLpath = [[NSBundle mainBundle] pathForResource:@"form2520_I9Labor" ofType:@"html" inDirectory:@"I9Labor/form2520I9Labor"];
        
        NSURL *originalURL = [NSURL fileURLWithPath:HTMLpath];

        NSURL *filePDFURL = [[NSBundle mainBundle] URLForResource:@"form2520_I9Labor" withExtension:@"html"];
        
        NSError *error = nil;
        
        /*
         Data str is the string that we are loading in the webView that we are showing to the users.This HTML should be resizable
         */
        NSString *dataStr = [NSString stringWithContentsOfURL:_fileURL encoding:NSUTF8StringEncoding error:&error];
        
        /*
         Data PDF str is the HTL that has fixes size, this is used for creating PDF
         */
        NSString *dataPDFStr = [NSString stringWithContentsOfURL:filePDFURL encoding:NSUTF8StringEncoding error:&error];
        
        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"image016" ofType:@"jpg"];
        
        // load logo
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"images/image016.jpg" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"images/image016.jpg" withString:path];
        }
        
        
        path = [[NSBundle mainBundle] pathForResource:@"stop" ofType:@"png"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"images/stop.png" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"images/stop.png" withString:path];
        }

        //glyphicons-halflings-regular.eot
        
        path = [[NSBundle mainBundle] pathForResource:@"glyphicons-halflings-regular" ofType:@"eot"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.eot" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.eot" withString:path];
        }

        //glyphicons-halflings-regular.svg
        path = [[NSBundle mainBundle] pathForResource:@"glyphicons-halflings-regular" ofType:@"svg"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.svg" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.svg" withString:path];
        }

        
        //glyphicons-halflings-regular.ttf
        path = [[NSBundle mainBundle] pathForResource:@"glyphicons-halflings-regular" ofType:@"ttf"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.ttf" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.ttf" withString:path];
        }

        
        //glyphicons-halflings-regular.woff2
        path = [[NSBundle mainBundle] pathForResource:@"glyphicons-halflings-regular" ofType:@"woff2"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.woff2" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"fonts/glyphicons-halflings-regular.woff2" withString:path];
        }

        
        for (NSString *key in self.params.allKeys) {
            NSString *val = [self.params objectForKey:key];
            NSString *keyToSearch = [NSString stringWithFormat:@"__%@__", key];
            
            dataStr = [dataStr stringByReplacingOccurrencesOfString:keyToSearch withString:val];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:keyToSearch withString:val];

        }
        
        // load the HTML that is visible to the user
        //[self.webView loadHTMLString:dataStr baseURL:baseURL];
        
        NSURLRequest *urlrequest = [NSURLRequest requestWithURL:originalURL];
       // [self.webView loadRequest:urlrequest];
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]
                                                 init];
        WKUserContentController *controller = [[WKUserContentController alloc]
                                               init];
        
        [controller addScriptMessageHandler:self name:@"observe"];
        configuration.userContentController = controller;

        self.wkWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:configuration];
        self.wkWebView.UIDelegate = self;
        self.wkWebView.navigationDelegate = self;
        
        self.wkWebView.autoresizingMask = self.webView.autoresizingMask;
        [self.wkWebView loadRequest:urlrequest];
        
        [self.view addSubview:self.wkWebView];

        // load the HTML that we will use for generating PDF
        _webViewForPDF = [[WKWebView alloc] initWithFrame: CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight)];
        _webViewForPDF.navigationDelegate = self;
        /*
        20.04.2020
        [_webViewForPDF setScalesPageToFit:YES];
        [_webViewForPDF setDelegate:self];
         */
        //[_webViewForPDF loadHTMLString:dataPDFStr baseURL:baseURL];
        
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(savePressed)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(closePressed)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    } else {
    
        [self.textView removeFromSuperview];
        
        self.title = @"Contract";
        
        NSURL *filePDFURL = [[NSBundle mainBundle] URLForResource:@"A" withExtension:@"html"];
        
        NSError *error = nil;
        
        /*
         Data str is the string that we are loading in the webView that we are showing to the users.This HTML should be resizable
         */
        NSString *dataStr = [NSString stringWithContentsOfURL:_fileURL encoding:NSUTF8StringEncoding error:&error];
        
        /*
         Data PDF str is the HTL that has fixes size, this is used for creating PDF
         */
        NSString *dataPDFStr = [NSString stringWithContentsOfURL:filePDFURL encoding:NSUTF8StringEncoding error:&error];

        NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:bundlePath];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"];
        
        // load logo
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"images/logo.png" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"images/logo.png" withString:path];
        }
        
        path = [[NSBundle mainBundle] pathForResource:@"skeleton" ofType:@"css"];

        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"stylesheets/skeleton.css" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"stylesheets/skeleton.css" withString:path];
        }
        
        path = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"];

        // load styles
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"stylesheets/style.css" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"stylesheets/style.css" withString:path];
        }

        path = [[NSBundle mainBundle] pathForResource:@"html5reset-1.6.1" ofType:@"css"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"stylesheets/html5reset-1.6.1.css" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"stylesheets/html5reset-1.6.1.css" withString:path];
        }
        
        path = [[NSBundle mainBundle] pathForResource:@"layout" ofType:@"css"];

        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"stylesheets/layout.css" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"stylesheets/layout.css" withString:path];
        }

        path = [[NSBundle mainBundle] pathForResource:@"base" ofType:@"css"];
        
        if (path) {
            dataStr = [dataStr stringByReplacingOccurrencesOfString:@"stylesheets/base.css" withString:path];
            dataPDFStr = [dataPDFStr stringByReplacingOccurrencesOfString:@"stylesheets/base.css" withString:path];
        }

        for (NSString *key in self.contractInfo.allKeys) {
            NSString *value = [self.contractInfo objectForKey:key];
            
            if (!value) {
                value = @"";
            } 
            
            dataStr = [self setInput:value
                              forkey:key
                            inString:dataStr];

            dataPDFStr = [self setInput:value
                                 forkey:key
                               inString:dataPDFStr];

        }
        
        // load the HTML that is visible to the user
        [self.webView loadHTMLString:dataStr baseURL:baseURL];
        
        // load the HTML that we will use for generating PDF
        _webViewForPDF = [[WKWebView alloc] initWithFrame: CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight)];
        
        /*
         20.04.2020
        [_webViewForPDF setScalesPageToFit:YES];
        [_webViewForPDF setDelegate:self];
         */

        [_webViewForPDF loadHTMLString:dataPDFStr baseURL:baseURL];
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                    target:self
                                                                                    action:@selector(savePressed)];
        self.navigationItem.rightBarButtonItem = saveButton;
        
        UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(closePressed)];
        self.navigationItem.leftBarButtonItem = closeBtn;
    }
    
    if (self.showEmailButton || self.showPrintButton) {
        
        UIBarButtonItem *emailBtn = [[UIBarButtonItem alloc] initWithTitle:@"Email"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(emailButtonPressed:)];

        UIBarButtonItem *printBtn = [[UIBarButtonItem alloc] initWithTitle:@"Print"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(printButtonPressed:)];

        
        NSMutableArray *items = [NSMutableArray array];
        if (self.showEmailButton) {
            [items addObject:emailBtn];
        }
        
        if (self.showPrintButton) {
            [items addObject:printBtn];
        }
        
        self.navigationItem.rightBarButtonItems = items;;
    }
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.hidesWhenStopped = YES;
    self.spinner.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    
    CGRect activityFrame = self.spinner.frame;
    activityFrame.origin.x = (self.view.frame.size.width - activityFrame.size.width)/2;
    activityFrame.origin.y = (self.view.frame.size.height - activityFrame.size.height)/2;
    
    self.spinner.frame = activityFrame;
    
    [self.spinner startAnimating];
    [self.wkWebView addSubview:self.spinner];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  
    _deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //20.04.2020 self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark -
#pragma mark Actions

-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}
-(void)emailButtonPressed:(UIBarButtonItem*)sender {
    /*
    if (self.spinner.isAnimating) {
        [self showSimpleMessage:@"Please wait while loading"];
        return;
    }
    */
    
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputPhoto;
    [render addPrintFormatter:self.wkWebView.viewPrintFormatter startingAtPageAtIndex:0];

    float topPadding = 10.0f;
    float bottomPadding = 10.0f;
    float leftPadding = 10.0f;
    float rightPadding = 10.0f;
    
    BOOL useLetterSize = YES;
    double widthToPrint = 0.0;
    double heightToPrint = 0.0;

    if (useLetterSize) {
        widthToPrint = kPaperSizeLetter.width;
        heightToPrint = kPaperSizeLetter.height;
    } else {
        widthToPrint = kPaperSizeA4.width;
        heightToPrint = kPaperSizeLetter.height;
    }
    
    if (self.values) {
        //28.05.2019 workaround for accident app
        widthToPrint = 1100;
    }
    
    CGRect printableRect = CGRectMake(leftPadding,
                                      topPadding,
                                      widthToPrint-leftPadding-rightPadding,
                                      heightToPrint-topPadding-bottomPadding);
    
    CGRect paperRect = CGRectMake(0, 0, widthToPrint, heightToPrint);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];
    
    NSString *fileName = [self.aggregate savingPathForPDF:self.object];
    
    NSLog(@"\n\n PDF path = %@\n\n", fileName);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileName]) {
        [fileManager removeItemAtPath:fileName error:nil];
    }
    
    
    
    NSData *pdfData = [render printToPDF];
    
    if (pdfData) {
        [pdfData writeToFile:fileName atomically: YES];
    } else {
        NSLog(@"PDF couldnot be created");
    }
    
    if ([MFMailComposeViewController canSendMail]) {
        [self showEmailModalView];
    } else {
        [self showSimpleMessage:@"Please configure your email account"];
    }
}

-(void) showEmailModalView {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    if ([self.object isKindOfClass:[TestDataHeader class]]) {
        TestDataHeader *header = (TestDataHeader*)self.object;
        [picker setSubject:[NSString stringWithFormat:@"%@ %@", ((RCOObject*)self.object).name, [header driverName]]];
    } else {
        [picker setSubject:[NSString stringWithFormat:@"Attachment %@", ((RCOObject*)self.object).name]];
    }
    
    // Fill out the email body text
    NSString *emailBody = nil;
    
    if ([self.object isKindOfClass:[TestDataHeader class]]) {
        TestDataHeader *header = (TestDataHeader*)self.object;
        emailBody = [NSString stringWithFormat:@"<h3> Attached is the %@ for %@ </h3>  <br> <h3> Certified Safe Driving <h3>", ((RCOObject*)self.object).name, [header driverName]];
    } else {
        emailBody = [NSString stringWithFormat:@"<h3> Attached is the %@ Document </h3>  <br> <h3> Mobile Office<h3>", ((RCOObject*)self.object).name];
    }
    
    [picker setMessageBody:emailBody isHTML:YES];
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    
    NSString *filePath = [self.aggregate savingPathForPDF:self.object];
    
    NSData *fileContent = [NSData dataWithContentsOfFile:filePath];
    
    [picker addAttachmentData:fileContent
                     mimeType:@"application/pdf"
                     fileName:filePath];
    
    [self presentModalViewControlleriOS6:picker animated:YES];
}


-(void)printButtonPressed:(UIBarButtonItem*)sender {
    
    if (self.spinner.isAnimating) {
        [self showSimpleMessage:@"Please wait while loading"];
        return;
    }
    
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %lu", error.domain, error.code);
        }
    };
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    // This application produces General content that contains color.
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // We'll use the URL as the job name
    printInfo.jobName = @"";
    
    printInfo.duplex = UIPrintInfoDuplexNone;
    
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    NSString *filePath = [self.aggregate savingPathForPDF:self.object];
    NSData *pdfData = [NSData dataWithContentsOfFile:filePath];
    controller.printingItem = pdfData;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [controller presentFromBarButtonItem:sender
                                    animated:YES
                           completionHandler:completionHandler];
    }else{
        [controller presentAnimated:YES completionHandler:completionHandler];
    }
}

-(NSString*)getWorkDescription:(NSString*)workDesc {
    NSMutableArray *lines = [NSMutableArray array];
    
    NSMutableString *line = [NSMutableString string];
    
    NSArray *words = [workDesc componentsSeparatedByString:@" "];
    
    for (NSString *word in words) {
        
        if (([line length] + [word length]) < 50) {
            [line appendFormat:@" %@", word];
        } else {
            [lines addObject:line];
            line = [NSMutableString string];
            [line appendString:word];
        }
    }
    
    NSString *lastLine = [lines lastObject];
    
    if ([lastLine isEqualToString:line]) {
        NSLog(@"we already added the last line!");
    } else {
        [lines addObject:line];
    }
    
    NSString *nbs = @"&nbsp;";
    
    return [lines componentsJoinedByString:nbs];
}


-(NSString*)getWorkRecommendations:(NSString*)workRecommendation {
    NSMutableArray *lines = [NSMutableArray array];
    
    NSMutableString *line = [NSMutableString string];
    
    NSArray *words = [workRecommendation componentsSeparatedByString:@" "];
    
    for (NSString *word in words) {
        
        if (([line length] + [word length]) < 50) {
            [line appendFormat:@" %@", word];
        } else {
            [lines addObject:line];
            line = [NSMutableString string];
            [line appendString:word];
        }
    }
    
    NSString *lastLine = [lines lastObject];
    
    if ([lastLine isEqualToString:line]) {
        NSLog(@"we already added the last line!");
    } else {
        [lines addObject:line];
    }
    
    NSString *nbs = @"&nbsp;";
    
    return [lines componentsJoinedByString:nbs];
}


-(NSString*)setInput:(NSString*)inputStr forkey:(NSString*)key inString:(NSString*)contentStr {
    if ([key isEqualToString:kWorkDescription]) {
        NSString *workDesc = [self getWorkDescription:inputStr];
        
        return [contentStr stringByReplacingOccurrencesOfString:key withString:workDesc];
    } else if ([key isEqualToString:kWorkRecommendations]) {
        NSString *workRecommendation = [self getWorkRecommendations:inputStr];
        
        return [contentStr stringByReplacingOccurrencesOfString:key withString:workRecommendation];
    }
    
    if ([key hasPrefix:@"workPaymentType"]) {
        NSLog(@"key = %@", key);
        NSLog(@"value = %@", [_contractInfo objectForKey:key]);
        NSLog(@"key = %@", key);
    }
    
    return [contentStr stringByReplacingOccurrencesOfString:key withString:inputStr];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self aggregate] unRegisterForCallback:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

-(void)dealloc {
    _textContent = nil;
    _navTitle = nil;
}

-(void)closeBtn {
    [self dismissModalViewControllerAnimatediOS6:YES];
}

-(void)closePressed {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
    
    if (DEVICE_IS_IPHONE) {
        [self dismissModalViewControllerAnimatediOS6:YES];
    }
}

-(void)savePressed {
}

- (void)orientationChanged:(NSNotification *)notification{
    UIDevice *deviceInfo = (UIDevice*)notification.object;
    [self setupWebView: self.webView formOrientation:_deviceOrientation toOrientation:deviceInfo.orientation];

    _deviceOrientation = deviceInfo.orientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
     [self setupWebView: self.webView];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setupWebView: self.webView];
}

/*
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"--->>>>>>request = %@", request.URL.scheme);
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"started");
}
- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
    [self setupWebView: aWebView];
    NSLog(@"finished");
}
*/

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"start 1");
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"start 2");
}

- (void) setupWebView:(WKWebView *)aWebView formOrientation:(UIInterfaceOrientation)fromOrientation toOrientation:(UIDeviceOrientation)toOrientation{
    
    CGFloat height = aWebView.scrollView.contentSize.height;
    if(  UIInterfaceOrientationIsLandscape(toOrientation) ) {
        height = height / 2.0;
    }
    
    CGFloat width = aWebView.scrollView.contentSize.width;
    CGRect frame = aWebView.frame;
    frame.size.height = height;
    frame.size.width = width;
    aWebView.frame = frame;
    
    //20.04.2020 aWebView.scalesPageToFit = YES;
    aWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    
    if(  UIInterfaceOrientationIsLandscape(toOrientation) ) {
        //20.04.2020 [webView stringByEvaluatingJavaScriptFromString: @"document.body.style.zoom = 0.80;"];
        [webView evaluateJavaScript:@"document.body.style.zoom = 0.80;" completionHandler:nil];
    }
    else {
        //20.04/2020 [webView stringByEvaluatingJavaScriptFromString: @"document.body.style.zoom = 0.70;"];
        [webView evaluateJavaScript:@"document.body.style.zoom = 0.70;" completionHandler:nil];
    }
    
    [self.view setNeedsLayout];
    /*
    width = aWebView.scrollView.contentSize.width;
    frame = aWebView.frame;
    frame.size.height = height;
    frame.size.width = width;
    aWebView.frame = frame;
    */
}

- (void) setupWebView:(WKWebView *)aWebView
{
    UIInterfaceOrientation orientation =  [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat height = aWebView.scrollView.contentSize.height;
    if(  UIInterfaceOrientationIsLandscape(orientation) ) {
        height = height / 2.0;
    }
    
    CGFloat width = aWebView.scrollView.contentSize.width;
    CGRect frame = aWebView.frame;
    frame.size.height = height;
    frame.size.width = width;
    //aWebView.frame = frame;
    
    //20.04.2020 aWebView.scalesPageToFit = YES;
    aWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    
    if(  UIInterfaceOrientationIsLandscape(orientation) ) {
        //[aWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.marginLeft = \"-60px\";"];
        //[aWebView stringByEvaluatingJavaScriptFromString:@"document.body.className = \"body-landscape\";"];
        //20.04.2020 [webView stringByEvaluatingJavaScriptFromString: @"document.body.style.zoom = 0.80;"];
        [webView evaluateJavaScript:@"document.body.style.zoom = 0.80;" completionHandler:nil];
    }
    else {
       // [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.marginLeft = \"-110px\";"];
        //[aWebView stringByEvaluatingJavaScriptFromString:@"document.body.className = \"body-portrait\";"];
        //20.04.2020 [webView stringByEvaluatingJavaScriptFromString: @"document.body.style.zoom = 0.70;"];
        [webView evaluateJavaScript:@"document.body.style.zoom = 0.70;" completionHandler:nil];
    }
    
    //NSString *widthStr = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.style.marginLeft;"];
   // NSLog(widthStr);
    //[self.view setNeedsLayout];
    
}

/*
 
 20.04.2020
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error = %@", error);
}
*/

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"WK error = %@", error);
}

-(void)createPDFfromUIView:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename {
    // code example from http://coderchrismills.wordpress.com/2011/06/25/making-a-pdf-from-a-uiwebview/
    
    // Creates a mutable data object for updating with binary data, like a byte array
    WKWebView *aWebView = (WKWebView*)aView;
    
    // Store off the original frame so we can reset it when we're done
    CGRect origframe = aWebView.frame;
    NSString *heightStr = nil;
    
    
    if ([aWebView isKindOfClass:[WKWebView class]]) {
        //20.04.2020 heightStr = [aWebView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"]; // Get the height of our webView
        [aWebView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            NSLog(@"");
        }];
        
        int height = [heightStr intValue];
        
        // Size of the view in the pdf page
        CGFloat maxHeight   = kDefaultPageHeight;
        CGFloat maxWidth    = kDefaultPageWidth;
        int pages = ceil(height / maxHeight); // for now have only 1 page.
        
        /*
         20.04.2020 update this log not to use the UIWebView
         
        if ([aWebView isKindOfClass:[UIWebView class]]) {
            [aWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
            [aWebView setScalesPageToFit:YES];
        } else {
            WKWebView *wkWebView = (WKWebView*)aWebView;
        }
        */
        
        // Set up we the pdf we're going to be generating is
        NSMutableData *pdfData = [NSMutableData data];
        
        //UIGraphicsBeginPDFContextToData(pdfData, aWebView.frame, nil);
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
        
        int i = 0;
        for ( ; i < pages; i++) // for multiple pages.   but for now only 1 page.
        {
            if (maxHeight * (i+1) > height)
            { // Check to see if page draws more than the height of the UIWebView
                CGRect f = [aWebView frame];
                f.size.height -= (((i+1) * maxHeight) - height);
                [aWebView setFrame: f];
            }
            // Specify the size of the pdf page
            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            // Move the context for the margins
            CGContextTranslateCTM(currentContext, 0, 0);
            // offset the webview content so we're drawing the part of the webview for the current page
            [[[aWebView subviews] lastObject] setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];
            // draw the layer to the pdf, ignore the "renderInContext not found" warning.
            [aWebView.layer renderInContext:currentContext];
        }
        // all done with making the pdf
        UIGraphicsEndPDFContext();
        // Restore the webview and move it to the top.
        [aWebView setFrame:origframe];
        [[[aWebView subviews] lastObject] setContentOffset:CGPointMake(0, 0) animated:NO];
        
        // Retrieves the document directories from the iOS device
        NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        
        NSString* documentDirectory = [documentDirectories objectAtIndex:0];
        NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:documentDirectoryFilename]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:documentDirectoryFilename error:&error];
            NSLog(@"Delete file %@", error);
        }
        
        // instructs the mutable data object to write its context to a file on disk
        [pdfData writeToFile:documentDirectoryFilename atomically:YES];

    } else {
        WKWebView *wkWebView = (WKWebView*)aWebView;
        CGFloat maxHeight   = kDefaultPageHeight;
        CGFloat maxWidth    = kDefaultPageWidth;
        
        //[wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
        [wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
        
        [wkWebView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id param, NSError * _Nullable error) {
            NSLog(@"");
            
            int height = [param integerValue];
            
            // Size of the view in the pdf page
            int pages = ceil(height / maxHeight); // for now have only 1 page.
            
            
            // Set up we the pdf we're going to be generating is
            NSMutableData *pdfData = [NSMutableData data];
            
            UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
            
            int i = 0;
            pages = 1;
            for ( ; i < pages; i++) // for multiple pages.   but for now only 1 page.
            {
                
                if (maxHeight * (i+1) > height)
                { // Check to see if page draws more than the height of the UIWebView
                    CGRect f = [wkWebView frame];
                    f.size.height -= (((i+1) * maxHeight) - height);
                    [wkWebView setFrame: f];
                }
                
                // Specify the size of the pdf page
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, kDefaultPageWidth, kDefaultPageHeight), nil);
                CGContextRef currentContext = UIGraphicsGetCurrentContext();
                // Move the context for the margins
                CGContextTranslateCTM(currentContext, 0, 0);
                // offset the webview content so we're drawing the part of the webview for the current page
                                      //[[[aWebView subviews] lastObject] setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];
                [wkWebView.scrollView setContentOffset:CGPointMake(0, maxHeight * i) animated:NO];

                // draw the layer to the pdf, ignore the "renderInContext not found" warning.
                [wkWebView.layer renderInContext:currentContext];
            }
            // all done with making the pdf
            UIGraphicsEndPDFContext();
            // Restore the webview and move it to the top.
            /////[wkWebView setFrame:origframe];
            /////[wkWebView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
            
            // Retrieves the document directories from the iOS device
            NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            
            NSString* documentDirectory = [documentDirectories objectAtIndex:0];
            NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:documentDirectoryFilename]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:documentDirectoryFilename error:&error];
                NSLog(@"Delete file %@", error);
            }
            
            NSLog(@">>>PDF file:%@", documentDirectoryFilename);
            
            // instructs the mutable data object to write its context to a file on disk
            [pdfData writeToFile:documentDirectoryFilename atomically:YES];
            
        }];
    }

}

-(void)createPDFfromUIView1:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename
{
    // 15.05.2019 is NOT working ....
    
    // code example from http://coderchrismills.wordpress.com/2011/06/25/making-a-pdf-from-a-uiwebview/
    
    // Store off the original frame so we can reset it when we're done
    CGRect origframe = aView.frame;
    NSString *heightStr = nil;
    
    
    WKWebView *wkWebView = (WKWebView*)aView;
    CGFloat maxHeight   = kDefaultPageHeight;
    CGFloat maxWidth    = kDefaultPageWidth;
        
    //[wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
    //14 [wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
        
    [wkWebView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id param, NSError * _Nullable error) {
        NSLog(@"");
            
        int height = [param intValue];
    
        // Size of the view in the pdf page
        int pages = ceil(height / maxHeight); // for now have only 1 page.
            
            
        // Set up we the pdf we're going to be generating is
        NSMutableData *pdfData = [NSMutableData data];
        
        //UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

        CGRect f = [wkWebView frame];
        CGRect originalFrame = [wkWebView frame];

        f.size.height = maxHeight;
        [wkWebView setFrame:f];
        
        CGRect frame = CGRectZero;
        frame.size.width = kDefaultPageWidth;
        frame.size.height = pages*kDefaultPageHeight;
        
        //UIGraphicsBeginPDFContextToData(pdfData, f, nil);
        UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);

        //NSMutableArray *images = [NSMutableArray array];
        //CGContextRef currentContext = UIGraphicsGetCurrentContext();

        int i = 0;

        for ( ; i < pages; i++) // for multiple pages.   but for now only 1 page.
        {
            if (maxHeight * (i+1) > height)
            { // Check to see if page draws more than the height of the UIWebView
                CGRect f = [wkWebView frame];
                f.size.height -= (((i+1) * maxHeight) - height);
                [wkWebView setFrame: f];
            }
            // Specify the size of the pdf page
            //UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, wkWebView.frame.size.width, maxHeight-100), nil);
            //UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, f.size.width, f.size.height), nil);

            UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, originalFrame.size.width, maxHeight), nil);

            CGContextRef currentContext = UIGraphicsGetCurrentContext();

            
            // Move the context for the margins
            //CGContextTranslateCTM(currentContext, 0, 0);
            //CGContextTranslateCTM(currentContext, 0, -i*maxHeight);
            //CGContextTranslateCTM(currentContext, 0, i*maxHeight);

            // offset the webview content so we're drawing the part of the webview for the current page
            //[wkWebView.scrollView setContentOffset:CGPointMake(0, maxHeight*i) animated:YES];

            //[wkWebView.scrollView setNeedsDisplay];
            
            /*
            //NSString *script = [NSString stringWithFormat:@"scrollTo(0, %d)", (int)maxHeight*i];
            
            //[wkWebView evaluateJavaScript:script
                        completionHandler:^(id param, NSError * _Nullable error) {
                            // draw the layer to the pdf, ignore the "renderInContext not found" warning.
                            [wkWebView.scrollView.layer renderInContext:currentContext];
                        }];
            
             */
            [wkWebView.scrollView.layer renderInContext:currentContext];
            //[wkWebView.scrollView.layer drawInContext:currentContext];
            //[wkWebView.layer renderInContext:currentContext];

            [wkWebView.scrollView setContentOffset:CGPointMake(0, maxHeight*i) animated:NO];
            CGRect contentRect = CGRectMake(0, maxHeight*i, wkWebView.frame.size.width, maxHeight);
            [wkWebView.scrollView.layer setContentsRect:contentRect];

            }
            // all done with making the pdf
            UIGraphicsEndPDFContext();
            // Restore the webview and move it to the top.
        
        [wkWebView setFrame:originalFrame];
       // [wkWebView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];

        
            // Retrieves the document directories from the iOS device
            NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            
            NSString* documentDirectory = [documentDirectories objectAtIndex:0];
            NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:documentDirectoryFilename]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:documentDirectoryFilename error:&error];
                NSLog(@"Delete file %@", error);
            }
            
            NSLog(@">>>PDF file:%@", documentDirectoryFilename);
            
            // instructs the mutable data object to write its context to a file on disk
            [pdfData writeToFile:documentDirectoryFilename atomically:YES];
            
        }];
}

-(void)createPDFfromUIView2:(UIView*)aView saveToDocumentsWithFileName:(NSString*)aFilename
{
    // 15.05.2019 is NOT working ....
    // code example from http://coderchrismills.wordpress.com/2011/06/25/making-a-pdf-from-a-uiwebview/
    
    // Store off the original frame so we can reset it when we're done
    CGRect origframe = aView.frame;
    NSString *heightStr = nil;
    
    
    WKWebView *wkWebView = (WKWebView*)aView;
    CGFloat maxHeight   = kDefaultPageHeight;
    CGFloat maxWidth    = kDefaultPageWidth;
    
    //[wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
    //14 [wkWebView setFrame:CGRectMake(0.f, 0.f, maxWidth, maxHeight)];
    
    [wkWebView evaluateJavaScript:@"document.body.scrollHeight;" completionHandler:^(id param, NSError * _Nullable error) {
        NSLog(@"");
        
        int height = [param intValue];
        
        // Size of the view in the pdf page
        int pages = ceil(height / maxHeight); // for now have only 1 page.
        
        
        // Set up we the pdf we're going to be generating is
        NSMutableData *pdfData = [NSMutableData data];
        
        
        //UIGraphicsBeginPDFContextToData(pdfData, CGRectZero, nil);
        
        CGRect f = [wkWebView frame];
        CGRect originalFrame = [wkWebView frame];
        
        f.size.height = maxHeight;
        [wkWebView setFrame:f];
        
        CGRect frame = CGRectZero;
        frame.size.width = kDefaultPageWidth;
        frame.size.height = pages*kDefaultPageHeight;
        
        NSMutableArray *images = [NSMutableArray array];
        
        int i = 0;
        //pages= 1;
        for ( ; i < pages; i++) // for multiple pages.   but for now only 1 page.
        {
            if (maxHeight * (i+1) > height)
            { // Check to see if page draws more than the height of the UIWebView
                CGRect f = [wkWebView frame];
                f.size.height -= (((i+1) * maxHeight) - height);
                [wkWebView setFrame: f];
            }
             UIGraphicsBeginImageContextWithOptions(wkWebView.bounds.size, YES, 0);
             [wkWebView.scrollView drawViewHierarchyInRect:wkWebView.bounds afterScreenUpdates:YES];
             UIImage* uiImage = UIGraphicsGetImageFromCurrentImageContext();
             NSData *imageData = UIImagePNGRepresentation(uiImage);
             if (imageData) {
                [images addObject:imageData];
             }
            [pdfData appendData:imageData];
            
             UIGraphicsEndImageContext();
            [wkWebView.scrollView setContentOffset:CGPointMake(0, maxHeight*i) animated:YES];
        }
        
        [wkWebView setFrame:originalFrame];
        [wkWebView.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        
        
        for (NSInteger i = 0; i < images.count; i++) {
            
            NSData *data = [images objectAtIndex:i];
            
            NSString *aFilename = [NSString stringWithFormat:@"%d", (int)i];
            
            // Retrieves the document directories from the iOS device
            NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
            
            NSString* documentDirectory = [documentDirectories objectAtIndex:0];
            
            NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:documentDirectoryFilename]) {
                NSError *error = nil;
                [fileManager removeItemAtPath:documentDirectoryFilename error:&error];
                NSLog(@"Delete file %@", error);
            }
            
            NSLog(@">>>PDF file:%@", documentDirectoryFilename);
            
            // instructs the mutable data object to write its context to a file on disk
            [data writeToFile:documentDirectoryFilename atomically:YES];
        }
        
        
        // Retrieves the document directories from the iOS device
        NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
        
        NSString* documentDirectory = [documentDirectories objectAtIndex:0];
        NSString* documentDirectoryFilename = [documentDirectory stringByAppendingPathComponent:aFilename];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:documentDirectoryFilename]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:documentDirectoryFilename error:&error];
            NSLog(@"Delete file %@", error);
        }
        
        NSLog(@">>>PDF file:%@", documentDirectoryFilename);
        
        // instructs the mutable data object to write its context to a file on disk
        [pdfData writeToFile:documentDirectoryFilename atomically:YES];
        
    }];
}

- (CFRange)renderPage:(NSInteger)pageNum withTextRange:(CFRange)currentRange
       andFramesetter:(CTFramesetterRef)framesetter
{
    // Get the graphics context.
    CGContextRef    currentContext = UIGraphicsGetCurrentContext();
    
    // Put the text matrix into a known state. This ensures
    // that no old scaling factors are left in place.
    CGContextSetTextMatrix(currentContext, CGAffineTransformIdentity);
    
    // Create a path object to enclose the text. Use 72 point
    // margins all around the text.
    CGRect    frameRect = CGRectMake(72, 72, 468, 648);
    CGMutablePathRef framePath = CGPathCreateMutable();
    CGPathAddRect(framePath, NULL, frameRect);
    
    // Get the frame that will do the rendering.
    // The currentRange variable specifies only the starting point. The framesetter
    // lays out as much text as will fit into the frame.
    CTFrameRef frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, NULL);
    CGPathRelease(framePath);
    
    // Core Text draws from the bottom-left corner up, so flip
    // the current transform prior to drawing.
    CGContextTranslateCTM(currentContext, 0, 792);
    CGContextScaleCTM(currentContext, 1.0, -1.0);
    
    // Draw the frame.
    CTFrameDraw(frameRef, currentContext);
    
    // Update the current range based on what was drawn.
    currentRange = CTFrameGetVisibleStringRange(frameRef);
    currentRange.location += currentRange.length;
    currentRange.length = 0;
    CFRelease(frameRef);
    
    return currentRange;
}

- (void)drawPageNumber:(NSInteger)pageNum
{
    NSString *pageString = [NSString stringWithFormat:@"Page %d", pageNum];
    UIFont *theFont = [UIFont systemFontOfSize:12];
    CGSize maxSize = CGSizeMake(612, 72);
    
    CGSize pageStringSize = [pageString sizeWithFont:theFont
                                   constrainedToSize:maxSize
                                       lineBreakMode:UILineBreakModeClip];
    CGRect stringRect = CGRectMake(((612.0 - pageStringSize.width) / 2.0),
                                   720.0 + ((72.0 - pageStringSize.height) / 2.0),
                                   pageStringSize.width,
                                   pageStringSize.height);
    
    [pageString drawInRect:stringRect withFont:theFont];
}


-(void)convert1 {
    
    CFAttributedStringRef currentText = CFAttributedStringCreate(NULL, (CFStringRef)textView.text, NULL);

    if (currentText) {
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(currentText);
        if (framesetter) {
            
            //NSString *pdfFileName = [self getPDFFileName];
            
            NSString *pdfFileName = @"test2.pdf";
            
            // Create the PDF context using the default page size of 612 x 792.
            UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
            
            CFRange currentRange = CFRangeMake(0, 0);
            NSInteger currentPage = 0;
            BOOL done = NO;
            
            do {
                // Mark the beginning of a new page.
                UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
                
                // Draw a page number at the bottom of each page.
                currentPage++;
                [self drawPageNumber:currentPage];
                
                // Render the current page and update the current range to
                // point to the beginning of the next page.
                //currentRange = [self renderPageWithTextRange:currentRange andFramesetter:framesetter];
                
                currentRange = [self renderPage:1
                                  withTextRange:currentRange
                                 andFramesetter:framesetter];
                
                // If we're at the end of the text, exit the loop.
                if (currentRange.location == CFAttributedStringGetLength((CFAttributedStringRef)currentText))
                    done = YES;
            } while (!done);
            
            // Close the PDF context and write the contents out.
            UIGraphicsEndPDFContext();
            
            // Release the framewetter.
            CFRelease(framesetter);
            
        } else {
            NSLog(@"Could not create the framesetter needed to lay out the atrributed string.");
        }
        // Release the attributed string.
        CFRelease(currentText);
    } else {
        NSLog(@"Could not create the attributed string for the framesetter");
    }

}

#pragma mark -
#pragma mark iOS 6 Only

-(NSUInteger)supportedInterfaceOrientations
{
#ifdef UIInterfaceOrientationMaskAll
    return UIInterfaceOrientationMaskAll;
#else
    typedef enum {
        UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
        UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
        UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
        UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
        UIInterfaceOrientationMaskLandscape =
        (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
        UIInterfaceOrientationMaskAll =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
        UIInterfaceOrientationMaskAllButUpsideDown =
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft |
         UIInterfaceOrientationMaskLandscapeRight),
    } UIInterfaceOrientationMask;
    
    return UIInterfaceOrientationMaskAll;
#endif
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message = %@", message);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"message = %@", message);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"message = %@", prompt);
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    // Check to make sure the name is correct
    if ([message.name isEqualToString:@"observe"]) {
        // Log out the message received
        NSLog(@"Received event %@", message.body);
        
        // Then pull something from the device using the message body
        NSString *version = [[UIDevice currentDevice] valueForKey:message.body];
        
        // Execute some JavaScript using the result
        NSString *exec_template = @"set_headline(\"received: %@\");";
        NSString *exec = [NSString stringWithFormat:exec_template, version];
        [self.wkWebView evaluateJavaScript:exec completionHandler:nil];
    }
}

-(void)loadFromDictionary {
    for (NSString *codingField in self.values.allKeys) {
        id value = [self.values objectForKey:codingField];
        NSString *boolValue = @"false";
        if (![value isKindOfClass:[NSDate class]] && [value boolValue]) {
            boolValue = @"true";
        }
        
        if ([codingField isEqualToString:@"dotExpirationDate"]) {
            NSLog(@"");
        }
        
        
        //NSString *exp = [NSString stringWithFormat: @"var element=document.getElementById('%@'); if (element.getAttribute('type') == 'text') {element.value='%@';} else if (element.getAttribute('type') == 'checkbox'){element.checked=%@} else {element.innerHTML='%@';}",codingField, value, boolValue, value];
        //NSString *exp = [NSString stringWithFormat: @"var element=document.getElementById('%@'); if (element.getAttribute('type') == 'text') {element.value='%@';} else if (element.getAttribute('type') == 'checkbox'){element.checked=%@} else {element.textContent='%@';}",codingField, value, boolValue, value];

        //NSString *exp = [NSString stringWithFormat: @"var element=document.getElementById('%@'); element.textContent='XXXXXX';",codingField];

        //NSString *exp = [NSString stringWithFormat: @"var element=document.getElementById('%@'); element.innerText='XXXXXX';",codingField];

        NSString *exp = [NSString stringWithFormat: @"var element=document.getElementById('%@'); if (element.getAttribute('type') == 'text') {element.value='%@';} else if (element.getAttribute('type') == 'checkbox'){element.checked=%@} else {element.innerText='%@';}",codingField, value, boolValue, value];

        
        /*
        NSString *exp = [NSString stringWithFormat: @"var table=document.getElementById('table'); var row=document.getElementById('%@'); var index = -1; var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;} } if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j];  var newrow=table.insertRow(index+1+j); var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1); cell.setAttribute('colspan', 5); cell.setAttribute('bgColor', 'red'); cell.innerHTML=st; } ", rowId, str, nr];
        */
        
        [self.wkWebView evaluateJavaScript:exp
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@"");
                         }];

    }
    
    [self.wkWebView evaluateJavaScript:@"document.body.scrollWidth;" completionHandler:^(id param, NSError * _Nullable error) {
        NSLog(@"");
        self.pageWidth = [param intValue];
    }];
}

-(TestDataDetail*)getDetailForSection:(NSString*)sectionNumber {
    if (!sectionNumber.length) {
        return nil;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"testSectionNumber=%@", sectionNumber];
    NSArray *res = [self.details filteredArrayUsingPredicate:pred];
    if (res.count) {
        return [res objectAtIndex:0];
    }
    return nil;
}

-(void) loadTestDataForm {
    NSArray *headerFields = [NSMutableArray arrayWithObjects:@"company", @"dateTime", @"employeeId", @"driverName", @"driverLicenseExpirationDate", @"driverLicenseClass", @"driverHistoryReviewed", @"endorsements", @"dotExpirationDate", @"pointsPercentage", @"pointsPossible", @"pointsReceived", @"powerUnit", @"correctiveLensRequired", @"driverLicenseNumber", @"driverLicenseState", @"endDateTime", @"startDateTime",  nil];
    
    for (NSString *codingField in headerFields) {
        id value = [self.object valueForKey:codingField];
        if ([self.fieldsNA containsObject:codingField]) {
            // 12.05.2020 if the coding field is in the NA list and there is no value then we should display NA this is NOT saved as NA is just displayed
            if (!value || ([value isKindOfClass:[NSString class]] && (((NSString*)value).length == 0))) {
                value = @"NA";
            }
        } else {
            if (!value) {
               // continue;
                value = @"";
            }
        }
        NSString *strValue = nil;
        NSString *val = nil;
        
        if ([codingField isEqualToString:@"pointsPossible"]) {
            NSLog(@"");
        }
        
       if ([value isKindOfClass:[NSString class]]) {
            strValue = (NSString*)value;
            //val = [NSString stringWithFormat:@"document.getElementById('%@').value='%@';", codingField, strValue];
           val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", codingField, strValue];

       } else if ([value isKindOfClass:[NSDate class]]) {
            strValue = [self rcoDateRMSToString:(NSDate*)value];
            //val = [NSString stringWithFormat:@"document.getElementById('%@').value='%@';", codingField, strValue];
           val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", codingField, strValue];
        }
        
        if ([val length]) {
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                             }];
        }
    }
    
    // populate some extra disctionaries to get the data for the bottom part. It can be implemented much better....
    NSMutableDictionary *dictReceived = [NSMutableDictionary dictionary];
    NSMutableDictionary *dictPossible = [NSMutableDictionary dictionary];
    NSMutableDictionary *instructions = [NSMutableDictionary dictionary];
    NSMutableDictionary *instructionsNr = [NSMutableDictionary dictionary];

    NSMutableArray *notes = [NSMutableArray array];
    
    if (self.details.count) {
        // For Production Test we need to insert dinamically the sections before setting the values
        TestDataDetail *detail = [self.details objectAtIndex:0];
        if ([detail.testNumber isEqualToString:TestProd]) {
            for (NSInteger i = 1; i < 100 ;i++) {
                NSString *sectionNumber = [NSString stringWithFormat:@"%d", (int)i];
                TestDataDetail *det = [self getDetailForSection:sectionNumber];
                if (!det) {
                    break;
                } else {
                    [self insertDivForSectionName:det.testSectionName andSectionNumber:det.testSectionNumber];
                }
            }
        }
    }
    
    NSString *testNumber = nil;
    
    for (TestDataDetail *detail in self.details) {
        NSString *strValue = nil;
        NSString *score = detail.score;
        NSString *sectionName = detail.testSectionName;
        
        NSLog(@"++--++%@", score);
        
        testNumber = [NSString stringWithFormat:@"%@", detail.testNumber];
        
        NSString *codingField = [NSString stringWithFormat:@"%@%@", detail.testSectionNumber, detail.testItemNumber];
        
        if (detail.testTeachingString.length && [score integerValue] >=0) {
            NSMutableArray *strings = [instructions objectForKey:detail.testSectionNumber];
            if (!strings) {
                strings = [NSMutableArray array];
            }
            //&quot;
            //NSString *escapedString = [detail.testTeachingString stringByReplacingOccurrencesOfString:@"'" withString:@"&quot;"];
            NSString *escapedString = [detail.testTeachingString stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
            
            // 25.11.2019 we should add the student first name
            BOOL addName = YES;
            BOOL skipAddTeachingString = NO;
            if (addName) {
                if ([detail.testNumber isEqualToString:TestVRT]) {
                    if ([score integerValue] == 0) {
                        escapedString = [NSString stringWithFormat:@"I instructed %@ to %@", detail.studentFirstName, escapedString];
                    } else {
                        skipAddTeachingString = YES;
                    }
                } else if ([score integerValue] == 4) {
                    escapedString = [NSString stringWithFormat:@"I reinforced with %@ to %@", detail.studentFirstName, escapedString];
                } else if (([score integerValue] == 3) || ([score integerValue] == 2)) {
                    escapedString = [NSString stringWithFormat:@"I instructed %@ to %@", detail.studentFirstName, escapedString];
                } else if ([score integerValue] == 1) {
                    escapedString = [NSString stringWithFormat:@"Driver %@ failed to %@", detail.studentFirstName, escapedString];
                }
            }
            if (!skipAddTeachingString) {
                [strings addObject:escapedString];
            
                [instructions setObject:strings forKey:detail.testSectionNumber];
            
                NSMutableArray *stringsNr = [instructionsNr objectForKey:detail.testSectionNumber];
                if (!stringsNr) {
                    stringsNr = [NSMutableArray array];
                }
            
                NSString *key1 = [NSString stringWithString:codingField];
                // remove 0 from the begin
                if ([key1 hasPrefix:@"0"]) {
                    key1 = [key1 substringFromIndex:1];
                }

                [stringsNr addObject:key1];
                [instructionsNr setObject:stringsNr forKey:detail.testSectionNumber];
            }
        }

        if ([notes containsObject:sectionName]) {
            // we already added the notes for this section
        } else {
            [self insertNotesForSection:sectionName withNumber:detail.testSectionNumber];
            [notes addObject:sectionName];
        }
        
        if (![detail.testNumber isEqualToString:TestVRT]) {
            if ([score integerValue] < 0) {
                strValue = @"N/A";
            } else if ([score integerValue] > 0) {
                strValue = score;
            } else {
                strValue = @"0";
            }
        }
       
        if ([detail.testNumber isEqualToString:TestVRT]) {
            if ([detail.testItemName isEqualToString:@"Score"]) {
                NSLog(@"");
                if ([score integerValue] < 0) {
                    strValue = @"N/A";
                } else if ([score integerValue] > 0) {
                    strValue = score;
                } else {
                    strValue = @"0";
                }
            } else {
                if ([score integerValue] == 0) {
                    strValue = @"Imp";
                } else if ([score integerValue] == 1){
                    strValue = @"Ok";
                } else {
                    strValue = @"N/A";
                }
            }
        } else if ([detail.testNumber isEqualToString:TestSWP] && [detail.testSectionNumber isEqualToString:@"1"]) {
            // 26.11.2019 is a special
            if ([strValue isEqualToString:TestValueYes]) {
                strValue = @"Yes";
            } else if ([strValue isEqualToString:TestValueNo]) {
                strValue = @"No";
            }
        } else if ([detail.testNumber isEqualToString:TestProd]) {
            // 26.11.2019 is Prod form and here we have some values that are strings
            if ([detail.testItemName isEqualToString:@"Location"]) {
                strValue = detail.location;
            } else if ([detail.testItemName isEqualToString:@"Trailer"]) {
                strValue = detail.trailerNumber;
            } else if ([detail.testItemName isEqualToString:@"Odometer"]) {
                strValue = detail.odometer;
            }
            if (!strValue.length) {
                strValue = @"  ";
            }
        }
        
        
        NSString *val = nil;
        
        //is div
        //val = [NSString stringWithFormat:@"var cell = document.getElementById('%@'); cell.innerHTML='%@'; cell.setAttribute('bgColor', 'orange');", codingField, strValue];
        //val = [NSString stringWithFormat:@"var cell = document.getElementById('%@'); cell.innerHTML='%@'; cell.bgColor = \"orange\";", codingField, strValue];
        //val = [NSString stringWithFormat:@"var cell = document.getElementById('%@'); cell.innerHTML='%@'; cell.style.backgroundColor = \"orange\";", codingField, strValue];
        val = [NSString stringWithFormat:@"var cell = document.getElementById('%@'); cell.innerHTML='%@';", codingField, strValue];

        if ([val length]) {
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                                 
                             }];
            
        }
        NSInteger sc = [[dictReceived objectForKey:detail.testSectionNumber] integerValue];
        if ([score integerValue] >= 0) {
            if ([detail.testNumber isEqualToString:TestVRT]) {
                //21.01.2020 For VRT we are calculating by summing the score for "Score" Item
                if ([detail.testItemName isEqualToString:@"Score"]) {
                    sc += [score integerValue];
                }
            } else {
                sc += [score integerValue];
            }
        }
        [dictReceived setObject:[NSNumber numberWithInteger:sc] forKey:detail.testSectionNumber];
        
        sc = [[dictPossible objectForKey:detail.testSectionNumber] integerValue];
        if ([score integerValue] >= 0) {
            if ([detail.testNumber isEqualToString:TestVRT]) {
                //21.01.2020 For VRT we are calculating by summing the score for "Score" Item
                if ([detail.testItemName isEqualToString:@"Score"]) {
                    sc += 4;
                }
            } else {
                sc += 5;
            }
        }
        [dictPossible setObject:[NSNumber numberWithInteger:sc] forKey:detail.testSectionNumber];
    }
    
    NSArray *keys = [NSArray arrayWithArray:dictPossible.allKeys];
    
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
         return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    for (NSString *key in keys) {
        NSNumber *valPoss = [dictPossible objectForKey:key];
        NSNumber *valRecv = [dictReceived objectForKey:key];
        NSArray *instr = [instructions objectForKey:key];
        NSArray *instrNr = [instructionsNr objectForKey:key];

        if ([key hasPrefix:TestBTW]) {
            NSLog(@"");
        }
        
        BOOL insertRow = NO;
        BOOL hasNotes = NO;
        
        if ([testNumber isEqualToString:TestVRT]) {
            // 02.03.2020 we need to insert notes also because the HTML for VRT does not have the table inside
            if (instr.count || hasNotes) {
                insertRow = YES;
            }
        } else {
            if (instr.count) {
                insertRow = YES;
            }
        }
        
        if (insertRow) {
            NSLog(@"");
            if ([testNumber isEqualToString:TestVRT]) {
                NSLog(@"");
                if (instr.count) {
                    NSString *str = [instr componentsJoinedByString:@"-*-"];
                    NSString *strNr = [instrNr componentsJoinedByString:@"-*-"];
                    NSString *rowKey = [NSString stringWithFormat:@"%d", [key intValue]];
                    // 03.03.02020 [self addHTMLRow:str afterRow:rowKey withNumbers:strNr];
                    [self addHTMLRow:str afterRow:key withNumbers:strNr];
                }
            
              //  [self insertHTMLRowForNotesSection:[NSString stringWithFormat:@"%@_note", key]];
            } else {
                NSString *str = [instr componentsJoinedByString:@"-*-"];
                NSString *strNr = [instrNr componentsJoinedByString:@"-*-"];
                NSString *rowKey = [NSString stringWithFormat:@"%@_tr", key];
                NSArray *criticalItems = [self.testCristicalItems objectForKey:key];
                [self addHTMLRow:str afterRow:rowKey withNumbers:strNr criticalItems:criticalItems];
            }
        }
        double percentage = 0;
        if ([valPoss doubleValue]) {
            percentage =  [valRecv doubleValue]*1.0/[valPoss doubleValue];
        }
        
        NSString *val = nil;
        
        BOOL useJustOneDecimal = YES;

        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString *keyFormatted3 = nil;
            NSString *valFormatted3 = nil;
            NSString *keyFormatted2 = nil;
            NSString *valFormatted2 = nil;

            keyFormatted3 = [NSString stringWithFormat:@"%@", @"form_scored1"];
            if (useJustOneDecimal) {
                valFormatted3 = [NSString stringWithFormat:@"%0.1f%%", [[self.object valueForKey:@"pointsPercentage"] doubleValue]];
            } else {
                valFormatted3 = [NSString stringWithFormat:@"%0.2f%%", [[self.object valueForKey:@"pointsPercentage"] doubleValue]];
            }
            keyFormatted2 = [NSString stringWithFormat:@"%@", @"form_scored2"];
            if (useJustOneDecimal) {
                valFormatted2 = [NSString stringWithFormat:@"%0.1f%%", [[self.object valueForKey:@"pointsPercentage"] doubleValue]];
            } else {
                valFormatted2 = [NSString stringWithFormat:@"%0.2f%%", [[self.object valueForKey:@"pointsPercentage"] doubleValue]];
            }

            val = [NSString stringWithFormat:@"document.getElementById('%@').innerText='%@';document.getElementById('%@').innerText='%@';", keyFormatted2, valFormatted2, keyFormatted3, valFormatted3];
        } else {
            NSString *keyFormatted1 = [NSString stringWithFormat:@"%@_possible_p", key];
            NSString *valFormatted1 = [NSString stringWithFormat:@"Possible Points: %@", valPoss];

            NSString *keyFormatted2 = [NSString stringWithFormat:@"%@_received_p", key];
            NSString *valFormatted2 = [NSString stringWithFormat:@"Points Received: %@", valRecv];

            NSString *keyFormatted3 = nil;
            NSString *valFormatted3 = nil;

            keyFormatted3 = [NSString stringWithFormat:@"%@_effective_p", key];
            if (useJustOneDecimal) {
                valFormatted3 = [NSString stringWithFormat:@"Percent Effective: %0.1f%%", percentage*100];
            } else {
                valFormatted3 = [NSString stringWithFormat:@"Percent Effective: %0.2f%%", percentage*100];
            }
            val = [NSString stringWithFormat:@"document.getElementById('%@').innerHTML='%@'; document.getElementById('%@').innerHTML='%@';document.getElementById('%@').innerHTML='%@';", keyFormatted1, valFormatted1, keyFormatted2, valFormatted2, keyFormatted3, valFormatted3];
        }

        [self.wkWebView evaluateJavaScript:val
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@"");
                             
                         }];
    }
    NSLog(@"");
}

-(void)insertDivForSectionName:(NSString*)sectionName andSectionNumber:(NSString*)sectionNumber {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"prodSection" ofType:@"html"];
    NSError *error = nil;
    NSString *div = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    div = [div stringByReplacingOccurrencesOfString:@"__section_number__" withString:sectionNumber];
    div = [div stringByReplacingOccurrencesOfString:@"__start_time__" withString:sectionName];

    // we need to remove new lines
    div = [div stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    div = [div stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    NSString *exp = [NSString stringWithFormat:@"var lastDiv = document.getElementById('%@'); lastDiv.insertAdjacentHTML('beforebegin', '%@');", @"insert_before_this_div", div];
    //NSString *exp = [NSString stringWithFormat:@"var lastDiv = document.getElementById('%@'); lastDiv.insertAdjacentElement('afterend', '%@');", @"insert_after_this_div", div];

    
    [self.wkWebView evaluateJavaScript:exp
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
                     }];

}

-(void)addHTMLRow:(NSString*)str afterRow:(NSString*)rowId withNumbers:(NSString*)nr {
    NSString *exp = nil;
    
    NSString *currentRowId = [NSString stringWithFormat:@"%d", ([rowId intValue] + 1)];
    // 03.03.2020 we should user the format for the id: 01_tr ....
    rowId = [NSString stringWithFormat:@"%@_tr", rowId];
/*
    exp = [NSString stringWithFormat: @"var table=document.getElementById('table');var row=document.getElementById('%@');var index = -1;var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;}} if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var rowId = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j]; var newrow=table.insertRow(index+1+j); newrow.setAttribute('id', rowId);var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1);cell.setAttribute('colspan', 5); cell.innerHTML=st; } ", rowId, str, nr, currentRowId];
*/
    
    exp = [NSString stringWithFormat: @"var table=document.getElementById('table');var row=document.getElementById('%@');var index = -1;var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;}} if (index >= 0) {index = index + 1;} var str = '%@'; var strNr = '%@';  var rowId = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j]; var newrow=table.insertRow(index); newrow.setAttribute('id', rowId);var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1);cell.setAttribute('colspan', 5); cell.innerHTML=st; } ", rowId, str, nr, currentRowId];
    
    [self.wkWebView evaluateJavaScript:exp
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
        if (error) {
            NSLog(@">>>\n\n%@\n\n<<<", error);
        }
                     }];
}

-(void)insertHTMLRowForNotesSection:(NSString*)section {
    NSString *exp = nil;
    NSString *rowId = [NSString stringWithFormat:@"%@_tr", section];
    NSString *cellId = [NSString stringWithFormat:@"%@_note", section];

    exp = [NSString stringWithFormat: @"var table=document.getElementById('table'); var newrow=table.insertRow(-1); newrow.setAttribute('id', '%@');var cell0 = newrow.insertCell(-1); cell0.setAttribute('colspan', 2); cell0.setAttribute('id', '%@')", rowId, cellId];
    
    [self.wkWebView evaluateJavaScript:exp
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
        if (error) {
            NSLog(@">>>\n\n%@\n\n<<<", error);
        }
                     }];
}

-(void)addHTMLRow:(NSString*)str afterRow:(NSString*)rowId withNumbers:(NSString*)nr criticalItems:(NSArray*)criticalItems{
    /*
     search table with id "table" in the HTML;
     search the row with id "rowId" in the HTML;
     split the string "str" to get the array with instrunctions
     split the string "nr" to get the array with instrunctions numbers
     these 2 arrays should have the same size.
     */

   // NSString *exp = [NSString stringWithFormat: @"var table=document.getElementById('table'); var row=document.getElementById('%@'); var index = -1; var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;} } if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j];  var newrow=table.insertRow(index+1+j); var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1); cell.setAttribute('colspan', 5); cell.setAttribute('bgColor', 'red'); cell.innerHTML=st; } ", rowId, str, nr];

    //NSString *exp = [NSString stringWithFormat: @"var table=document.getElementById('table'); var row=document.getElementById('%@'); var index = -1; var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;} } if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j];  var newrow=table.insertRow(index+1+j); var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1); cell.setAttribute('colspan', 5); cell.setAttribute('bgColor', 'red'); cell.innerHTML=st; } ", rowId, str, nr];
    NSString *exp = nil;
    if (criticalItems) {
        NSString *jsArr = [NSString stringWithFormat:@"%@", [criticalItems componentsJoinedByString:@"*"]];
        
        exp = [NSString stringWithFormat: @"var crit = '%@'; var critArr = crit.split('*'); var table=document.getElementById('table'); var row=document.getElementById('%@'); var index = -1; var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;} } if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j];  var newrow=table.insertRow(index+1+j); var isCritical = critArr.includes(stNr); if (isCritical) {newrow.setAttribute('class', 'critical-item'); } var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1); cell.setAttribute('colspan', 5); cell.innerHTML=st; } ",jsArr, rowId, str, nr];
    } else {
        exp = [NSString stringWithFormat: @"var table=document.getElementById('table'); var row=document.getElementById('%@'); var index = -1; var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;} } if (index == -1) {index = 0;} var str = '%@'; var strNr = '%@';  var arr = str.split('-*-'); var arrNr = strNr.split('-*-'); for (var j = 0; j < arr.length; j++) {var st = arr[j]; var stNr = arrNr[j];  var newrow=table.insertRow(index+1+j); var cell0 = newrow.insertCell(-1); cell0.innerHTML=stNr; var cell=newrow.insertCell(-1); cell.setAttribute('colspan', 5); cell.innerHTML=st; } ", rowId, str, nr];
    }

    
    [self.wkWebView evaluateJavaScript:exp
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
                     }];
}

-(void)insertNoteRow:(NSString*)noteStr andImage:(UIImage*)img  andIndex:(NSInteger)index{
    // 06.12.2019 this is to insert a note row in the Notes html note & thumbnail
    NSString *path = [[NSBundle mainBundle] pathForResource:@"notesRow" ofType:@"html"];
    NSError *error = nil;
    NSString *imageId = [NSString stringWithFormat:@"Image%d", (int)index];
    
    NSString *row = [NSString stringWithContentsOfFile:path
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    row = [row stringByReplacingOccurrencesOfString:@"__NOTE__" withString:noteStr];
    row = [row stringByReplacingOccurrencesOfString:@"__IMAGE_ID__" withString:imageId];

    // we need to remove new lines
    row = [row stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    row = [row stringByReplacingOccurrencesOfString:@"\r" withString:@""];

    NSString *exp = nil;
    
    if (img) {
        // we should insert here the image also
        NSString*imgScript = [self setBgImageSCript:img forOption:imageId];
        exp = [NSString stringWithFormat:@"var lastRow = document.getElementById('%@'); lastRow.insertAdjacentHTML('beforebegin', '%@');", @"endtable", row];
        exp = [NSString stringWithFormat:@"%@%@", exp, imgScript];
    } else {
        exp = [NSString stringWithFormat:@"var lastRow = document.getElementById('%@'); lastRow.insertAdjacentHTML('beforebegin', '%@');", @"endtable", row];
    }
    
    [self.wkWebView evaluateJavaScript:exp
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");

                     }];
}

-(void)insertRow:(NSInteger)rowIndex {

}

-(void)deleteHTMLRowWithId:(NSString*)rowId {
    NSString *exp = nil;

    exp = [NSString stringWithFormat: @"var table=document.getElementById('table');var row=document.getElementById('%@');var index = -1;var rows = table.rows; for (var i=0;i<rows.length; i++){ if (rows[i] == row) {index = i;break;}} if (index >= 0) {table.deleteRow(index);}", rowId];
       
    [self.wkWebView evaluateJavaScript:exp
                        completionHandler:^(id res, NSError * _Nullable error) {
                            NSLog(@"");
            if (error) {
               NSLog(@">>>\n\n%@\n\n<<<", error);
           }
                        }];
}

-(void)insertNotesForSection:(NSString*)section withNumber:(NSString*)sectionNumber {
    if (!section.length || !sectionNumber.length) {
        return ;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"category=%@", section];
    NSArray *res = [self.notes filteredArrayUsingPredicate:predicate];
    if (!res.count) {
        if ([self.formNumber isEqualToString:TestVRT]) {
            // 03.03.2020 we should delete the rows that don't have notes
            [self deleteHTMLRowWithId:[NSString stringWithFormat:@"%@_tr", sectionNumber]];
        }
        return;
    }
        
    NSMutableArray *noteStr = [NSMutableArray array];
    
    for (Note *n in res) {
        if (n.notes.length) {
            [noteStr addObject:n.notes];
        }
    }
    NSString *keyFormatted = [NSString stringWithFormat:@"%@_note", sectionNumber];
    NSString *valFormatted = nil;
    
    if ([self.formNumber isEqualToString:TestProd]) {
        valFormatted = [NSString stringWithFormat:@"%@", [noteStr componentsJoinedByString:@","]];
    } else {
        valFormatted = [NSString stringWithFormat:@"Note: %@", [noteStr componentsJoinedByString:@","]];
    }
    
    NSString *val = nil;
    /*if ([self.formNumber isEqualToString:TestVRT]) {
        NSString *rowId = [NSString stringWithFormat:@"%@_tr", sectionNumber];
        val = [NSString stringWithFormat: @"var table=document.getElementById('table'); var newrow=table.insertRow(-1); newrow.setAttribute('id', '%@');var cell0 = newrow.insertCell(-1); cell0.setAttribute('colspan', 2); cell0.setAttribute('id', '%@');cell0.innerHTML='%@';", rowId, keyFormatted, valFormatted];
        
    } else */{
        val = [NSString stringWithFormat:@"document.getElementById('%@').innerHTML='%@';", keyFormatted, valFormatted];
    }
    
    [self.wkWebView evaluateJavaScript:val
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
                         
                     }];
}

-(void) setValue {
}


- (void)webView:(WKWebView *)wkWebView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"");
    
    if (self.js) {
        [self.wkWebView evaluateJavaScript:self.js
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@" eooroooo = %@", error);
                             
                         }];

    }
    
    if (self.values) {
        // we should load the kes from Dictionary
        [self loadFromDictionary];
    } else if ([self.object isKindOfClass:[TestDataHeader class]]) {
        [self loadTestDataForm];
        [self loadSignaturesHTML];
        [self addExtraKeys];
        // for all of them we need?
        [self runChartScript];
    
    } else {
        [self setValue];
    }

    if (self.loadAsTestHTML) {
        if (!self.details.count && self.notes.count) {
            for (NSInteger i = 0; i < self.notes.count; i++) {
                Note *note = [self.notes objectAtIndex:i];
                UIImage *image = nil;
                if (i < self.notesImages.count) {
                    id img = [self.notesImages objectAtIndex:i];
                    if ([img isKindOfClass:[UIImage class]]) {
                        image = (UIImage*)img;
                    }
                }
                [self insertNoteRow:note.notes andImage:image andIndex:i];
            }
        }
        [self addExtraKeys];
    }
    
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
}

- (NSString *) rcoDateRMSToString: (NSDate *) aDate
{
    NSDateFormatter *f = [[NSDateFormatter alloc] init];
    [f setDateFormat:@"MM/dd/yyyy"];
    
    NSString *time_str =[f stringFromDate:aDate];
    
    return time_str;
}

- (NSDate *) rcoStringToDate: (NSString *) aDateStr
{
    NSDateFormatter * f = [[NSDateFormatter alloc] init];
    [f setDateFormat: @"MM/dd/yyyy"];
    
    NSDate *theDate =  [f dateFromString:aDateStr];
    
    return theDate;
}

-(NSString*)setBgImageSCript:(UIImage*)img forOption:(NSString*)option{
    
    NSData *imageData = nil;
    
    if (!img) {
        img = [UIImage imageNamed:@"transparent.png"];
    }
    
    imageData = UIImagePNGRepresentation(img);
    
    NSString *imageDataBase64 = [imageData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    NSString* script = nil;
    
    script = [NSString stringWithFormat:@"document.getElementById('%@').setAttribute( 'src', 'data:image/png;base64,%@');", option, imageDataBase64];
    
    return script;
}

-(void)loadSignatures {
    if (!self.object) {
        return;
    }
    
    Aggregate *agg = [[DataRepository sharedInstance] getAggregateForClass:@"TestDataHeader"];
    
    SignatureDetailAggregate *signatureAgg = [agg.detailAggregates objectAtIndex:1];
    
    SignatureDetail *detail = nil;
    
    TestDataHeader *header = (TestDataHeader*)self.object;
    
    if ([header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:header.rcoBarcode andType:TestSignatureDriver];
    } else {
        detail = [signatureAgg getDetailForParentId:header.rcoObjectId andType:TestSignatureDriver];
    }
    
    self.driverSignature = [signatureAgg getObjectImage:detail];
    self.driverSignatureDate = detail.documentDate;
    
    if (!self.driverSignature) {
        self.driverSignature = [self.htmlExtraKeys objectForKey:KeySignatureDriver];
        if (self.driverSignature) {
            self.driverSignatureDate = [NSDate date];
        }
    }
    
    detail = nil;
    
    if ([header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:header.rcoBarcode andType:TestSignatureEvaluator];
    } else {
        detail = [signatureAgg getDetailForParentId:header.rcoObjectId andType:TestSignatureEvaluator];
    }
    
    self.evaluatorSignature = [signatureAgg getObjectImage:detail];
    self.evaluatorSignatureDate = detail.documentDate;
    
    if (!self.evaluatorSignature) {
        self.evaluatorSignature = [self.htmlExtraKeys objectForKey:KeySignatureEvaluator];
        if (self.evaluatorSignature) {
            self.evaluatorSignatureDate = [NSDate date];
        }
    }

    detail = nil;
    
    if ([header.rcoBarcode length]) {
        detail = [signatureAgg getDetailForParentBarcode:header.rcoBarcode andType:TestSignatureCompanyRep];
    } else {
        detail = [signatureAgg getDetailForParentId:header.rcoObjectId andType:TestSignatureCompanyRep];
    }
    
    self.compRepSignature = [signatureAgg getObjectImage:detail];
    self.compRepSignatureDate = detail.documentDate;

    if (!self.compRepSignature) {
        self.compRepSignature = [self.htmlExtraKeys objectForKey:KeySignatureCompanyRepresentative];
        if (self.compRepSignature) {
            self.compRepSignatureDate = [NSDate date];
        }
    }
}

-(void)loadSignaturesHTML {
    
    // we should load the signatures in the html
    if (1) {
        NSString*imgScript = [self setBgImageSCript:self.driverSignature forOption:@"pdf_driver_signature"];
        
        [self.wkWebView evaluateJavaScript:imgScript completionHandler:^(id _Nullable p, NSError * _Nullable error) {
            if (error) {
                NSLog(@"");
            }
        }];
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString*imgScript = [self setBgImageSCript:self.driverSignature forOption:@"dmv_pdf_driver_signature"];
            
            [self.wkWebView evaluateJavaScript:imgScript completionHandler:^(id _Nullable p, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"");
                }
            }];
        }
    }
    
    if (self.driverSignatureDate) {
        NSString *key = @"pdf_driver_signature_date";
        
        NSString *strValue = [self rcoDateRMSToString:self.driverSignatureDate];
        NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
        [self.wkWebView evaluateJavaScript:val
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@"");
                             
                         }];
        
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString *key = @"dmv_pdf_driver_signature_date";
            
            NSString *strValue = [self rcoDateRMSToString:self.driverSignatureDate];
            NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                                 
                             }];

        }
    }
    
    if (1) {
        NSString*imgScript = [self setBgImageSCript:self.evaluatorSignature forOption:@"pdf_evaluators_signature"];
        
        [self.wkWebView evaluateJavaScript:imgScript completionHandler:^(id _Nullable res, NSError * _Nullable error) {
            NSLog(@"");
            if (error)  {
            NSLog(@"");
            }
        }];
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString*imgScript = [self setBgImageSCript:self.evaluatorSignature forOption:@"dmv_pdf_evaluators_signature"];
            
            [self.wkWebView evaluateJavaScript:imgScript completionHandler:^(id _Nullable p, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"");
                }
            }];
        }
    }
    
    if (self.evaluatorSignatureDate) {
        NSString *key = @"pdf_evaluators_signature_date";
        
        NSString *strValue = [self rcoDateRMSToString:self.evaluatorSignatureDate];
        NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
        [self.wkWebView evaluateJavaScript:val
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@"");
                             
                         }];
        
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString *key = @"dmv_pdf_evaluators_signature_date";
            NSString *strValue = [self rcoDateRMSToString:self.evaluatorSignatureDate];
            NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                                 
                             }];

        }
        
    }

    if (1) {
        NSString*imgScript = [self setBgImageSCript:self.compRepSignature forOption:@"pdf_company_rep_signature"];
        
        [self.wkWebView evaluateJavaScript:imgScript completionHandler:nil];
        
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString*imgScript = [self setBgImageSCript:self.compRepSignature forOption:@"dmv_pdf_company_rep_signature"];
            
            [self.wkWebView evaluateJavaScript:imgScript completionHandler:^(id _Nullable p, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"");
                }
            }];
        }
    }
    
    if (self.compRepSignatureDate) {
        NSString *key = @"pdf_company_rep_signature_date";
        
        NSString *strValue = [self rcoDateRMSToString:self.compRepSignatureDate];
        NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
        [self.wkWebView evaluateJavaScript:val
                         completionHandler:^(id res, NSError * _Nullable error) {
                             NSLog(@"");
                             
                         }];
        
        if ([self.formNumber isEqualToString:TestVRT]) {
            NSString *key = @"dmv_pdf_company_rep_signature_date";
            
            NSString *strValue = [self rcoDateRMSToString:self.compRepSignatureDate];
            NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, strValue];
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                             }];
        }
    }
    /*
    // load logo like any other image
    UIImage *imgLogo = [UIImage imageNamed:@"CSDlogo"];
    
    NSString*imgScript = [self setBgImageSCript:imgLogo forOption:@"logo"];
    [self.wkWebView evaluateJavaScript:imgScript completionHandler:nil];
    */
}

-(void)addExtraKeys {
    // extra keys that are passed. these are values that we don't have in the  object...
    for (NSString *key in self.htmlExtraKeys.allKeys) {
        
        if ([key isEqualToString:@"turnsMap"]) {
            NSString *imagePath = [self.htmlExtraKeys objectForKey:key];
            
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            NSString*imgScript = [self setBgImageSCript:image forOption:@"turnsMap"];

            [self.wkWebView evaluateJavaScript:imgScript completionHandler:nil];

        } else {
            id value = [self.htmlExtraKeys objectForKey:key];
            NSString *val = [NSString stringWithFormat:@"document.getElementById('%@').textContent='%@';", key, value];
            [self.wkWebView evaluateJavaScript:val
                             completionHandler:^(id res, NSError * _Nullable error) {
                                 NSLog(@"");
                                 
                             }];
        }
    }
}

-(void)runChartScript {
    NSString *chartTitleKey = @"chart_title";
    NSString *chartTitleValue = @"Accident Probability Chart";
    
    if ([self.object isKindOfClass:[TestDataHeader class]]) {
        TestDataHeader *h = (TestDataHeader*)self.object;
        if ([h.number isEqualToString:TestSWP]) {
            // swp
            chartTitleValue = @"Injury Probability Graph";
        } else if ([h.number isEqualToString:TestPreTrip]) {
            // Pre Trip
            chartTitleValue = @"Critical Items";
        }
    }

    NSString *chartDataKey = @"chart_Data";
    NSString *chartContainerKey = @"container_name";
    NSString *chartContainerValue = @"container1";
    
    NSMutableArray *vals = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.chartKeys1.count; i++) {
        NSString *key = [self.chartKeys1 objectAtIndex:i];
        NSString *value = [self.chartValues1 objectAtIndex:i];
        
        [vals addObject:[NSString stringWithFormat:@"['%@',%@]", key, value]];
    }

    NSString *chartDataValue = [vals componentsJoinedByString:@","];
    NSString *JSpath = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"js"];

    NSError *error = nil;
    NSString *val = [NSString stringWithContentsOfFile:JSpath
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    
    val = [val stringByReplacingOccurrencesOfString:chartTitleKey withString:chartTitleValue];
    val = [val stringByReplacingOccurrencesOfString:chartDataKey withString:chartDataValue];
    val = [val stringByReplacingOccurrencesOfString:chartContainerKey withString:chartContainerValue];

    [self.wkWebView evaluateJavaScript:val
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
                         
                     }];

    /////////////////////////
    chartTitleKey = @"chart_title";
    chartTitleValue = @"Element Effective Chart";
    chartDataKey = @"chart_Data";
    
    chartContainerKey = @"container_name";
    chartContainerValue = @"container2";
    
    vals = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.chartKeys2.count; i++) {
        NSString *key = [self.chartKeys2 objectAtIndex:i];
        NSString *value = [self.chartValues2 objectAtIndex:i];
        
        [vals addObject:[NSString stringWithFormat:@"['%@',%@]", key, value]];
    }
    
    chartDataValue = [vals componentsJoinedByString:@","];
    JSpath = [[NSBundle mainBundle] pathForResource:@"chart" ofType:@"js"];
    
    error = nil;
    val = [NSString stringWithContentsOfFile:JSpath
                                              encoding:NSUTF8StringEncoding
                                                 error:&error];
    
    val = [val stringByReplacingOccurrencesOfString:chartTitleKey withString:chartTitleValue];
    val = [val stringByReplacingOccurrencesOfString:chartDataKey withString:chartDataValue];
    val = [val stringByReplacingOccurrencesOfString:chartContainerKey withString:chartContainerValue];
    
    [self.wkWebView evaluateJavaScript:val
                     completionHandler:^(id res, NSError * _Nullable error) {
                         NSLog(@"");
                         
                     }];
    
    //
    
}

@end
