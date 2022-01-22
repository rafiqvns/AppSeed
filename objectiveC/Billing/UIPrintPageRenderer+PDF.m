//
//  UIPrintPageRenderer+PDF.m
//  MobileOffice
//
//  Created by Dragos Dragos on 2/26/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "UIPrintPageRenderer+PDF.h"

@implementation UIPrintPageRenderer (PDF)
- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, nil );
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex: i inRect: bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}
@end
