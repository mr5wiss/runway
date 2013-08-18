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
    BOOL _touchBeganNotYetMoved;
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
        //[self addTarget:self action:@selector(nodeTapped:forEvent:) forControlEvents:UIControlEventTouchUpInside];
        self.fireStatus = kRWnodeTypeStatusOff;
        self.lightStatus = kRWnodeTypeStatusOff;
        self.adjustsImageWhenHighlighted = NO;
    }
    return self;
}

- (nodeType)typeForLocation:(CGPoint)location {
    if (self.type != kRWnodeTypeBoth) {
        return self.type;
    }
    if (location.x > 9 && location.y < 90) {
        return kRWnodeTypeFire;
    }
    else {
        return kRWnodeTypeLight;
    }
}

- (IBAction)nodeTapped:(id)sender forEvent:(UIEvent *)event {
    nodeType typeChanged;
    if (self.type != kRWnodeTypeBoth) {
        typeChanged = self.type;
    }
    // this node has both fire and light, so we have to determine where the user tapped
    else {
        RWNodeButton *node = (RWNodeButton *)sender;
        UITouch *touch = [[event touchesForView:node] anyObject];
        CGPoint location = [touch locationInView:self];
        // correct values?
        typeChanged = [self typeForLocation:location];
    }
    // this should cause the correct action to be sent
    // status reversed because it has not been changed yet (might get confusing)
    nodeTypeStatus status = typeChanged == kRWnodeTypeLight ? !self.lightStatus : !self.fireStatus;
    [self.delegate stateWasChangedTo:status forNode:self type:typeChanged];
    // this shows what's happening on the display
    NSTimeInterval duration = typeChanged == kRWnodeTypeLight ? [self.delegate lightDuration] : [self.delegate fireDuration];
    [self changeTapStateForType:typeChanged duration:duration];
}

- (void)revertTapState:(NSTimer *)sender {
    // TO DO: deal with represses before reversion - probably have to keep state
    NSNumber *typeNum = sender.userInfo;
    // TO DO: make sure this isn't turning anything on
    [self changeTapStateForType:[typeNum intValue] duration:0];
}

- (void)changeTapStateForType:(nodeType)type duration:(NSTimeInterval)duration {
    // change only the display, don't send any information
    if (type == kRWnodeTypeFire) {
        self.fireStatus = !self.fireStatus;
    }
    else {
        self.lightStatus = !self.lightStatus;
    }
    [self setBackgroundImageBasedOnStatus];
    nodeTypeStatus status = type == kRWnodeTypeLight ? self.lightStatus : self.fireStatus;
    // use the timer to do it only for a certain duration by scheduling a revert if necessary
    if (status && duration) {
        _tapStateTimer = [NSTimer scheduledTimerWithTimeInterval:duration target:self selector:@selector(revertTapState:) userInfo:[NSNumber numberWithInt:type] repeats:NO];
    }
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

#pragma mark touches functions
// right now, we have to capture these here and send them to the container view
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchBeganNotYetMoved = YES;
 }

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    _touchBeganNotYetMoved = NO;
    [self.superview touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // node was just tapped
    if (_touchBeganNotYetMoved) {
        [self nodeTapped:self forEvent:event];
        _touchBeganNotYetMoved = NO;
    }
    else {
        [self.superview touchesEnded:touches withEvent:event];
    }
}

@end
