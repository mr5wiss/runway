
//
//  RWGlossyButton.m
//  Runway
//
//  Created by Arshad Tayyeb on 8/18/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWGlossyButton.h"
#import "UIButton+Glossy.h"

@implementation RWGlossyButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setBackgroundToGlossyRectOfColor:self.currentTitleShadowColor withBorder:YES forState:UIControlStateNormal];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame backgroundColor:(UIColor *)backgroundColor {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textColor = [UIColor whiteColor];
        [self setBackgroundToGlossyRectOfColor:backgroundColor withBorder:YES forState:UIControlStateNormal];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundToGlossyRectOfColor:self.currentTitleShadowColor withBorder:YES forState:UIControlStateNormal];
    }
    return self;
}

@end
