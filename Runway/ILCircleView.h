//
//  ILCircleView.h
//  DOHome
//
//  Created by Arshad Tayyeb on 12/28/12.
//
//

#import <UIKit/UIKit.h>

@interface ILCircleView : UIView
- (id)initWithCenter:(CGPoint)center radius:(CGFloat)radius;
@property (nonatomic, strong) UIColor *color;
@property (readwrite) CGFloat radius;
- (UIImage *)imageRepresentation;
@end
