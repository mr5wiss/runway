//
//  ILCircleView.m
//  DOHome
//
//  Created by Arshad Tayyeb on 12/28/12.
//
//

#import "ILCircleView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Lightness.h"
#import "UIView+Image.h"

@implementation ILCircleView
{
    CGFloat _radius;
    UIColor *_color;    
}
@synthesize radius = _radius, color = _color;

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    //constrain to square
    if (frame.size.width > frame.size.height)
        frame.size.height = frame.size.width;
    else
        frame.size.width = frame.size.height;
    
    if (self = [super initWithFrame:frame])
    {
        self.radius = frame.size.height/2;
    }
    [self commonInit];
    return self;
}

- (void)awakeFromNib
{
    [self commonInit];
    self.color = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    ILCircleView *obj = [super initWithCoder:aDecoder];
    CGPoint center = obj.center;
    CGRect frame = obj.frame;
    if (frame.size.width > frame.size.height)
        frame.size.height = frame.size.width;
    else
        frame.size.width = frame.size.height;
    obj.radius = frame.size.height/2;
    obj.frame = frame;
    obj.center = center;
    return obj;
}

- (id)initWithCenter:(CGPoint)center radius:(CGFloat)radius
{
    self = [super initWithFrame:CGRectMake(0, 0, radius*2, radius*2)];
    if (self) {
        self.center = center;
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    static CGRect nativeRect = { 0.f, 0.f, 512.f, 512.f };
    
    CGContextSaveGState(context); {
        
        // determine aspect ratio and scale from native resolution to current bounds size
        CGSize boundsSize = self.bounds.size;
        CGSize nativeSize = nativeRect.size;
        CGFloat nativeAspect = nativeSize.width / nativeSize.height;
        CGFloat boundsAspect = boundsSize.width / boundsSize.height;
        CGFloat scale = (nativeAspect > boundsAspect ?
                         boundsSize.width / nativeSize.width :
                         boundsSize.height / nativeSize.height);
        
        // transform to current bounds
        CGContextTranslateCTM(context,
                              0.5 * (boundsSize.width  - scale * nativeSize.width),
                              0.5 * (boundsSize.height - scale * nativeSize.height));
        CGContextScaleCTM(context, scale, scale);
                
        // my color
        CGContextAddEllipseInRect(context, nativeRect);
        CGContextSetFillColorWithColor(context, [self.color darkerColor].CGColor);
        CGContextFillEllipseInRect(context, nativeRect);
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        CGContextFillEllipseInRect(context, CGRectInset(nativeRect, 50, 50));
        CGContextClip(context);
        
        
    
    } CGContextRestoreGState(context);
}

- (void)drawRectx:(CGRect)rect
{
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    CGGradientRef glossGradient;
//    size_t num_locations = 2;
//    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
//        1.0, 1.0, 1.0, 0.06 }; // End color
//    
//    rgbColorspace = CGColorSpaceCreateDeviceRGB();
//    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
//    
//    CGRect currentBounds = self.bounds;
//    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
//    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
//    CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, midCenter, 0);
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat tComponents[] = { 0.0, 0.68, 1.00, 0.75,
        0.0, 0.45, 0.62, 0.55,
        0.0, 0.45, 0.62, 0.00 };
    CGFloat tGlocations[] = { 0.0, 0.25, 0.40 };
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, tComponents, tGlocations, 3);
    
    CGContextDrawRadialGradient(currentContext, glossGradient, self.center, 4.0, self.center, self.radius, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

- (UIImage *)imageRepresentation {
	UIGraphicsBeginImageContext(self.bounds.size);
    
	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	[[UIColor blackColor] set];
//	CGContextFillRect(ctx, self.bounds);
    
	[self.layer renderInContext:ctx];
    
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
    
	return newImage;
}

@end
