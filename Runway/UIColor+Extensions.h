//
//  UIColor+Extensions.h
//  DOHome
//
//  Created by Arshad Tayyeb on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#if !defined RGBCOLOR
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#endif
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface UIColor (Extensions)
+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (NSString *)hexValue;
@end
