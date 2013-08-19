//
//  UIColor+Extensions.m
//  DOHome
//
//  Created by Arshad Tayyeb on 9/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)
- (NSString *)hexValue {
    
    CGColorRef colorref = [self CGColor];
    
    const CGFloat *components = CGColorGetComponents(colorref);
    
    NSMutableString *hexString = [@"#" mutableCopy];
    int hexValue = 0;
    
    for (int i=0; i<3; i++) {
        if (components[i] == 0) {
            [hexString appendFormat:@"00"];
        }else{
            hexValue = 0xFF*components[i];
            if (hexValue <= 0xF)
            {
                [hexString appendFormat:@"0%x", hexValue];
            } else {
                [hexString appendFormat:@"%x", hexValue];
            }
        }
    }
    
    for (int i = hexString.length; i < 7; i++)
    {
        [hexString appendString:@"0"];
    }
    
    return hexString;
}


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end

