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
        /*if (type == kRWnodeTypeFire) {
            self.backgroundColor = [UIColor blueColor]; // image?
        }
        else if (type == kRWnodeTypeFire) {
            self.backgroundColor = [UIColor orangeColor]; // image?
        }
        else {
            [self setBackgroundImage:[UIImage imageNamed:@"fireLightUnpressed"] forState:UIControlStateNormal];
        }*/
    }
    return self;
}


- (void)changeTapStateForType:(nodeType)type duration:(NSTimeInterval)duration {
    // change only the display, don't send any information
    // use the timer to do it for a certain duration
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
