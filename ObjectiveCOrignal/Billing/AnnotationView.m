//
//  AnnotationView.m
//  MobileOffice
//
//  Created by .D. .D. on 4/1/16.
//  Copyright © 2016 RCO. All rights reserved.
//

#import "AnnotationView.h"

@interface AnnotationView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation AnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier image:(UIImage *)image {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setDraggable:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        CGRect frame = CGRectMake(0, 0, image.size.width, image.size.height * 2);
        [self setFrame:frame];
        [self setCenterOffset:CGPointMake(0, -CGRectGetHeight(frame) / 2)];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self setImageView:imageView];
        [self addSubview:imageView];
        
        CGRect imageFrame = imageView.frame;
        imageFrame.origin.x = (CGRectGetWidth(frame) - CGRectGetWidth(imageFrame)) / 2;
        imageFrame.origin.y = CGRectGetHeight(frame) - CGRectGetHeight(imageFrame);
        [imageView setFrame:imageFrame];
    }
    
    return self;
}

- (void)setDragState:(MKAnnotationViewDragState)newDragState animated:(BOOL)animated {
    [super setDragState:newDragState animated:animated];
    
    if (newDragState == MKAnnotationViewDragStateStarting) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect imageFrame = self.imageView.frame;
            imageFrame.origin.y = 0;
            [self.imageView setFrame:imageFrame];
        }];
    } else if (newDragState == MKAnnotationViewDragStateNone) {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect imageFrame = self.imageView.frame;
            imageFrame.origin.y = CGRectGetHeight(self.frame) - CGRectGetHeight(imageFrame);
            [self.imageView setFrame:imageFrame];
        }];
    }
}

@end
