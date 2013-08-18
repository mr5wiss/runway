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

- (void)addNode:(RWNodeButton *)node number:(NSInteger)num {
    // add the node to a structure such that nodes can be accessed by number
}


#pragma mark RWNodeButtonDelegate
- (void)stateWasChangedTo:(BOOL)state forNode:(RWNodeButton *)node type:(nodeType)type {
    // do the right thing based on mode
    // assume Now mode for now
    // if mode is now, tell delegate whenever a state change comes in
    NSMutableDictionary *nodeDict = [[NSMutableDictionary alloc] initWithCapacity:3];
    [nodeDict setObject:(state ? @"on" : @"off") forKey:@"command"];
    [nodeDict setObject:(type == kRWnodeTypeFire ? @"fire" : @"light") forKey:@"type"];
    [nodeDict setObject:[NSNumber numberWithInt:node.num] forKey:@"number"];
    [self.delegate nodesChanged:[NSArray arrayWithObject:nodeDict]];
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
