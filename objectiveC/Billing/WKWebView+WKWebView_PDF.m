//
//  WKWebView+WKWebView_PDF.m
//  MobileOffice
//
//  Created by .D. .D. on 5/14/19.
//  Copyright © 2019 RCO. All rights reserved.
//

#import "WKWebView+WKWebView_PDF.h"
#import "UIPrintPageRenderer+PDF.h"

@implementation WKWebView (WKWebView_PDF)

-(NSURL*)saveWebViewPdf:(NSData*)data {
    /*
     let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
     let docDirectoryPath = paths[0]
     let pdfPath = docDirectoryPath.appendingPathComponent("webViewPdf.pdf")
     if data.write(to: pdfPath, atomically: true) {
     return pdfPath.path
     } else {
     return ""
     }
     }
     */
    NSArray *paths = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *docDirectoryPath = [paths objectAtIndex:0];
    NSURL *path = [docDirectoryPath URLByAppendingPathComponent:@"webViewPdf.pdf"];
    BOOL res = [data writeToURL:path atomically:YES];
    if (res) {
        return path;
    } else {
        return nil;
    }
}

-(NSURL*)exportAsPdfFromWebView {
    NSData *pdfData = [self createPdfFile:self.viewPrintFormatter];
    return [self saveWebViewPdf:pdfData];

}

-(NSData*)createPdfFile:(UIViewPrintFormatter*)printFormatter {
    /*
     let originalBounds = self.bounds
     self.bounds = CGRect(x: originalBounds.origin.x, y: bounds.origin.y, width: self.bounds.size.width, height: self.scrollView.contentSize.height)
     let pdfPageFrame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.scrollView.contentSize.height)
     let printPageRenderer = UIPrintPageRenderer()
     printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
     printPageRenderer.setValue(NSValue(cgRect: UIScreen.main.bounds), forKey: "paperRect")
     printPageRenderer.setValue(NSValue(cgRect: pdfPageFrame), forKey: "printableRect")
     self.bounds = originalBounds
     return printPageRenderer.generatePdfData()

     */
    CGRect originalBounds = self.bounds;
    self.bounds = CGRectMake(originalBounds.origin.x, originalBounds.origin.y, self.bounds.size.width, self.scrollView.contentSize.height);
    CGRect pdfPageFrame = CGRectMake(0, 0, self.bounds.size.width, self.scrollView.contentSize.height);
    UIPrintPageRenderer *printPageRenderer = [[UIPrintPageRenderer alloc] init];
    [printPageRenderer addPrintFormatter:printFormatter startingAtPageAtIndex:0];
    [printPageRenderer setValue:[NSValue valueWithCGRect:[UIScreen mainScreen].bounds] forKey:@"paperRect"];
    [printPageRenderer setValue:[NSValue valueWithCGRect:pdfPageFrame] forKey:@"printableRect"];
    self.bounds = originalBounds;
    
    NSData *data = [printPageRenderer printToPDF];

    return data;
}

@end
