//
//  PSPDFSegmentedControl.h
//  PSPDFKit
//
//  Copyright (c) 2012 Peter Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

// Add support to replace images as the selection changes.
@interface PSPDFSegmentedControl : UISegmentedControl

- (void)setSelectedImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (UIImage *)selectedImageForSegmentAtIndex:(NSUInteger)segment;

@end
