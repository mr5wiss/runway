//
//  RWNodeManager.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWNodeManager.h"
#import "RWFirstViewController.h"


@implementation RWNodeManager
//@property id<RW

- (void)addNode:(RWNodeButton *)node number:(NSInteger)num {
    // add the node to a structure such that nodes can be accessed by number
}


#pragma mark RWNodeButtonDelegate
- (void)stateWasChangedTo:(BOOL)state forNode:(RWNodeButton *)node type:(nodeType)type {
    // do the right thing based on mode
}

- (NSTimeInterval)lightDuration {
    // TO DO: make this fully work based on node
    return (NSTimeInterval)[[[RWFirstViewController sharedInstance] lightDurationSlider] value];
}

- (NSTimeInterval)fireDuration {
    // TO DO: make this fully work based on node
    return (NSTimeInterval)[[[RWFirstViewController sharedInstance] fireDurationSlider] value];
}

@end
