//
//  RWNodeButton.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWNodeButton.h"

@implementation RWNodeButton {
    NSTimer *_tapStateTimer;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (RWNodeButton *)initWithNum:(NSInteger)num type:(nodeType)type frame:(CGRect)frame {
    self = [self initWithFrame:frame];
    if (self) {
        self.type = type;
        self.num = num;
        [self addTarget:self action:@selector(nodeTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        self.fireStatus = kRWnodeTypeStatusOff;
        self.lightStatus = kRWnodeTypeStatusOff;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

- (IBAction)nodeTapped:(id)sender forEvent:(UIEvent *)event {
    nodeType typeChanged;
    if (self.type != kRWnodeTypeBoth) {
        typeChanged = self.type;
    }
    else {
        // choose based on location of touch
        RWNodeButton *node = (RWNodeButton *)sender;
        UITouch *touch = [[event touchesForView:node] anyObject];
        CGPoint location = [touch locationInView:self];
        if (location.x > 9 && location.y < 90) {
            typeChanged = kRWnodeTypeFire;
        }
        else {
            typeChanged = kRWnodeTypeLight;
        }
    }
    [self.delegate stateWasChangedTo:YES forNode:self type:typeChanged];
    [self changeTapStateForType:typeChanged duration:[self.delegate lightDuration]];
}

- (void)changeTapStateForType:(nodeType)type duration:(NSTimeInterval)duration {
    // change only the display, don't send any information
    // use the timer to do it for a certain duration
    if (type == kRWnodeTypeFire) {
        self.fireStatus = !self.fireStatus;
    }
    else {
        self.lightStatus = !self.lightStatus;
    }
    [self setBackgroundImageBasedOnStatus];
}

- (void)setBackgroundImageBasedOnStatus {
    if (self.type == kRWnodeTypeBoth) {
        if (self.fireStatus && self.lightStatus) {
            [self setBackgroundImage:[UIImage imageNamed:@"tappedLightTappedFire"] forState:UIControlStateNormal];
        }
        else if (self.fireStatus) {
            [self setBackgroundImage:[UIImage imageNamed:@"untappedLightTappedFire"] forState:UIControlStateNormal];
        }
        else if (self.lightStatus) {
            [self setBackgroundImage:[UIImage imageNamed:@"tappedLightUntappedFire"] forState:UIControlStateNormal];
        }
        else {
            [self setBackgroundImage:[UIImage imageNamed:@"untappedLightUntappedFire"] forState:UIControlStateNormal];
        }
    }
    else if (self.type == kRWnodeTypeFire) {
        UIImage *bgImage = self.fireStatus ? [UIImage imageNamed:@"tappedFire"] : [UIImage imageNamed:@"untappedFire"];
        [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
    else {
        UIImage *bgImage = self.lightStatus ? [UIImage imageNamed:@"tappedLight"] : [UIImage imageNamed:@"untappedLight"];
        [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    }
}

- (void)setType:(nodeType)type {
    _type = type;
    if (type == kRWnodeTypeLight) {
        [self setBackgroundImage:[UIImage imageNamed:@"untappedLight"] forState:UIControlStateNormal];
    }
    else if (type == kRWnodeTypeFire) {
        [self setBackgroundImage:[UIImage imageNamed:@"untappedFire"] forState:UIControlStateNormal];
    }
    else {
        [self setBackgroundImage:[UIImage imageNamed:@"untappedLightUntappedFire"] forState:UIControlStateNormal];
    }
    // redraw?
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
