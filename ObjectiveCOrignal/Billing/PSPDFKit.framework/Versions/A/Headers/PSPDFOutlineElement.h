//
//  PSPDFOutlineElement.h
//  PSPDFKit
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import <Foundation/Foundation.h>

/// Represents a single outline/table of contents element.
@interface PSPDFOutlineElement : NSObject

/// Init with title, page, child elements and deepness level.
- (id)initWithTitle:(NSString *)title page:(NSUInteger)page elements:(NSArray *)elements level:(NSUInteger)level;

/// Returns all elements + flattened subelements
- (NSArray *)flattenedChildren;

/// Outline title.
@property(nonatomic, strong) NSString *title;

/// Page reference.
@property(nonatomic, assign) NSUInteger page;

/// Child elements.
@property(nonatomic, strong, readonly) NSArray *children;

/// Current outline level.
@property(nonatomic, assign) NSUInteger level;

/// Expansion state of current outline element.
@property(nonatomic, assign, getter=isExpanded) BOOL expanded;

@end
