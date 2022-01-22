// UIImage+Alpha.h
// Created by Trevor Harmon on 9/20/09.
// Free for personal or commercial use, with or without modification.
// No warranty is expressed or implied.

// Helper methods for adding an alpha layer to an image
@interface UIImage (Alpha)
- (BOOL)hasAlpha;
- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;
- (UIImage*)addText:(NSString*)text1
               XPos:(int)xpos
               YPos:(int)ypos
           fontName:(NSString*)fontName
           fontSize:(CGFloat)fontSize
          fontColor:(UIColor*)fontColor;
@end
