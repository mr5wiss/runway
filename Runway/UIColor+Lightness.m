//
//  UIColor+Lightness.m
//  donna
//
//  Created by Arshad Tayyeb on 10/31/11.
//  Copyright (c) 2011 Incredible Labs All rights reserved.
//

#import "UIColor+Lightness.h"

#define LIGHTNESS_VARIATION_PERCENT 20  //just as a default

@implementation UIColor (UIColor_Lightness)
- (UIColor *)darkerColor
{
    return [self darkerBy:LIGHTNESS_VARIATION_PERCENT];
}

//Modified from: http://www.cocoanetics.com/2009/10/manipulating-uicolors/
- (UIColor *)darkerBy:(NSUInteger)percentDarker;
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4] = {0.0f, 0.0f, 0.0f, 0.0f};

    CGFloat factor = (100.0-percentDarker)/100.0;
    
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
    CGColorRef newColor = nil;
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] *= factor;//oldComponents[0]* (factor - 1);
			newComponents[1] = oldComponents[1];//oldComponents[0]* (factor - 1);

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
            newColor = CGColorCreate(colorSpace, newComponents);
            CGColorSpaceRelease(colorSpace);
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]* factor;
			newComponents[1] = oldComponents[1]* factor;
			newComponents[2] = oldComponents[2]* factor;
			newComponents[3] = oldComponents[3];
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            newColor = CGColorCreate(colorSpace, newComponents);
            CGColorSpaceRelease(colorSpace);
			break;
		}
	}

	UIColor *retColor = newColor ? [UIColor colorWithCGColor:newColor] : [UIColor colorWithCGColor:self.CGColor];
	CGColorRelease(newColor);
    
	return retColor;
}


- (UIColor *)lighterColor
{
    return [self lighterBy:LIGHTNESS_VARIATION_PERCENT];
}

//Modified from: http://www.cocoanetics.com/2009/10/manipulating-uicolors/
- (UIColor *)lighterBy:(NSUInteger)percentLighter
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	CGFloat newComponents[4] = {0.0f, 0.0f, 0.0f, 0.0f};
    
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);

    CGFloat factor = 1.0 + (percentLighter / 100.0);
    
    CGColorRef newColor = nil;
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] *= factor;
			newComponents[1] = oldComponents[1];
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
            newColor = CGColorCreate(colorSpace, newComponents);
            CGColorSpaceRelease(colorSpace);
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0]* factor;
			newComponents[1] = oldComponents[1]* factor;
			newComponents[2] = oldComponents[2]* factor;
			newComponents[3] = oldComponents[3];

            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            newColor = CGColorCreate(colorSpace, newComponents);
            CGColorSpaceRelease(colorSpace);
			break;
		}
	}
    
    //clip
    if (newComponents[0] > 1) newComponents[0] = 1.0;
    if (newComponents[1] > 1) newComponents[1] = 1.0;
    if (newComponents[2] > 1) newComponents[2] = 1.0;
    if (newComponents[3] > 1) newComponents[3] = 1.0;

	UIColor *retColor = newColor ? [UIColor colorWithCGColor:newColor] : [UIColor colorWithCGColor:self.CGColor];
	CGColorRelease(newColor);
    
	return retColor;
}

- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha;
{
	// oldComponents is the array INSIDE the original color
	// changing these changes the original, so we copy it
	CGFloat *oldComponents = (CGFloat *)CGColorGetComponents([self CGColor]);
	int numComponents = CGColorGetNumberOfComponents([self CGColor]);
	CGFloat newComponents[4];
    
	switch (numComponents)
	{
		case 2:
		{
			//grayscale
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[0];
			newComponents[2] = oldComponents[0];
			newComponents[3] = newAlpha;
			break;
		}
		case 4:
		{
			//RGBA
			newComponents[0] = oldComponents[0];
			newComponents[1] = oldComponents[1];
			newComponents[2] = oldComponents[2];
			newComponents[3] = newAlpha;
			break;
		}
	}
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGColorRef newColor = CGColorCreate(colorSpace, newComponents);
	CGColorSpaceRelease(colorSpace);
    
	UIColor *retColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
    
	return retColor;
}

//From: http://stackoverflow.com/questions/2509443/check-if-uicolor-is-dark-or-bright
- (UIColor *)appropriateTextColor
{
        const CGFloat *componentColors = CGColorGetComponents(self.CGColor);
        
        CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
        if (colorBrightness < 0.5)
        {
            //NSLog(@"my color is dark");
            return [UIColor whiteColor];
        }
        else
        {
            return [UIColor blackColor];
        }
}

- (UIColor *)appropriateTextPlaceholderColor
{
    UIColor *color = [[[self appropriateTextColor] darkerBy:20] colorByChangingAlphaTo:.8];
    return color;
}

@end
