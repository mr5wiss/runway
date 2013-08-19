//
//  UIView+Image.m
//  DOHome
//
//  Created by Arshad Tayyeb on 11/5/12.
//
//

#import "UIView+Image.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Image)

- (UIImage *)image {
    
	CGRect screenRect = [[UIScreen mainScreen] bounds];
//	screenRect.origin.y = 64; // padding for the navigation controller
//	screenRect.size.height -= 64;
    
	UIGraphicsBeginImageContext(screenRect.size);
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[[UIColor blackColor] set];
	CGContextFillRect(ctx, screenRect);
    
	[self.layer renderInContext:ctx];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newImage;
}

- (NSData *)imageCaptureData {
	UIImage *newImage = [self image];
        
	return UIImagePNGRepresentation(newImage);
}
@end
