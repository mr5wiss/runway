//
//  UIView+UIView_Background.m
//  DOHome
//
//  Created by Dav Yaginuma on 4/2/13.
//  Copyright (c) 2013 Incredible Labs. All rights reserved.
//

#import "UIView+UIView_Background.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (UIView_Background)


- (UIView *) addDarkRoundyShadowBackground {
    self.layer.cornerRadius = 8.0;
    self.layer.shadowColor = [UIColor colorWithWhite:.2 alpha:.5].CGColor;
    self.layer.shadowOffset = CGSizeMake(-2,-2);
    return self;
}


@end
