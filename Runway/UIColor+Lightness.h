//
//  UIColor+Lightness.h
//  donna
//
//  Created by Arshad Tayyeb on 10/31/11.
//  Copyright (c) 2011 Incredible Labs All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (UIColor_Lightness)
- (UIColor *)darkerColor;
- (UIColor *)lighterColor;

- (UIColor *)darkerBy:(NSUInteger)percentDarker;
- (UIColor *)lighterBy:(NSUInteger)percentLighter;

- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha;

- (UIColor *)appropriateTextColor;
- (UIColor *)appropriateTextPlaceholderColor;

@end
