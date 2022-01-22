//
//  WKWebView+WKWebView_PDF.h
//  MobileOffice
//
//  Created by .D. .D. on 5/14/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (WKWebView_PDF)
-(NSURL*)saveWebViewPdf:(NSData*)data;
-(NSURL*)exportAsPdfFromWebView;
-(NSData*)createPdfFile:(UIViewPrintFormatter*)printFormatter;
@end

NS_ASSUME_NONNULL_END
