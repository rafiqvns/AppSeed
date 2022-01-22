//
//  DatabaseControlDelegate.h
//  CocoaTouchBarcodes
//
//  Created by Rosalind Hartigan on 2/3/14.
//
//

#import <Foundation/Foundation.h>

@protocol DatabaseControlDelegate <NSObject>
- (void) finishedUnloadingUserAggregates: (NSString *) msg;
@end
