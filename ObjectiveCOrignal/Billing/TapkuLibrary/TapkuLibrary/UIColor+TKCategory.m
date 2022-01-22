//
//  UIColor+TKCategory.m
//  Created by Devin Ross on 5/14/11.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "UIColor+TKCategory.h"

@implementation UIColor (TKCategory)


+ (id) colorWithHex:(unsigned int)hex{
	return [UIColor colorWithHex:hex alpha:1];
}

+ (id) colorWithHex:(unsigned int)hex alpha:(CGFloat)alpha{
	
	return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hex & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hex & 0xFF)) / 255.0
                           alpha:alpha];
	
}

+ (UIColor*) randomColor{
	
	int r = arc4random() % 255;
	int g = arc4random() % 255;
	int b = arc4random() % 255;
	return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
	
}

- (UIColor *)lighterColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.5, 1.0)
                               green:MIN(g + 0.5, 1.0)
                                blue:MIN(b + 0.5, 1.0)
                               alpha:a];
    return nil;
}


- (UIColor *)darkerColorForColor:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.4, 0.0)
                               green:MAX(g - 0.4, 0.0)
                                blue:MAX(b - 0.4, 0.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColorForColorOpaque:(UIColor *)c
{
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.5, 0.0)
                               green:MAX(g - 0.5, 0.0)
                                blue:MAX(b - 0.5, 0.0)
                               alpha:1];
    return nil;
}

+ (UIColor *)eventGreenColor {
    return [UIColor colorWithRed:71.0/255.0 green:143.0/255.0 blue:41.0/255.0 alpha:0.7];
}

+ (UIColor *)eventBlueColor {
    return [UIColor colorWithRed:28.0/255.0 green:57.0/255.0 blue:246.0/255.0 alpha:0.7];
}

+ (UIColor *)hightlitedBlueColor {
    return [UIColor colorWithRed:45.0/255.0 green:96.0/255.0 blue:221.0/255.0 alpha:0];
}

+(UIColor *)navigationBarColor {
    return [UIColor lightGrayColor];
}

+(UIColor *)toolBarColor {
    return [UIColor lightGrayColor];
}

+ (UIColor *)navigationBarTitleColor {
    return [UIColor darkTextColor];
}

+ (UIColor *)eventTodayBackgroundColor {
    return [UIColor colorWithRed:0 green:122.0/255.0 blue:255.0/255.0 alpha:1];
}

+ (UIColor *)eventTodayTextColor {
    return [UIColor whiteColor];
}

+ (UIColor *)eventHolidayBackgroundColor {
    return [UIColor lightGrayColor];
}

+ (UIColor *)eventHolidayTextColor {
    return [UIColor darkTextColor];
}


@end