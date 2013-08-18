//
//  RWNodeManager.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWNodeManager.h"
#import "RWFirstViewController.h"


@implementation RWNodeManager {
    NSMutableDictionary *_nodes;
}

- (RWNodeManager *)init {
    self = [super init];
    if (self) {
        _nodes = [[NSMutableDictionary alloc] initWithCapacity:2*LIGHTS_PER_SIDE];
    }
    return self;
}

- (void)addNode:(RWNodeButton *)node number:(NSInteger)num {
    // add the node to a structure such that nodes can be accessed by number
    [_nodes setObject:node forKey:[NSNumber numberWithInt:num]];
}

- (void)clearTop {
    for (NSInteger i=LIGHTS_PER_SIDE+1; i<=2*LIGHTS_PER_SIDE; i++) {
        RWNodeButton *node = [_nodes objectForKey:[NSNumber numberWithInt:i]];
        if (node.lightStatus) {
            [node changeTapStateForType:kRWnodeTypeLight duration:0];
        }
    }
}

- (void)clearBottom {
    for (NSInteger i=1; i<=LIGHTS_PER_SIDE; i++) {
        RWNodeButton *node = [_nodes objectForKey:[NSNumber numberWithInt:i]];
        if (node.lightStatus) {
            [node changeTapStateForType:kRWnodeTypeLight duration:0];
        }
    }
}

- (void)clearNodes {
    for (NSString *key in [_nodes allKeys]) {
        RWNodeButton *node = [_nodes objectForKey:key];
        if (node.lightStatus) {
            [node changeTapStateForType:kRWnodeTypeLight duration:0];
        }
    }
}

- (RWNodeButton *)mirroredNode:(RWNodeButton *)node {
    if (node.num < LIGHTS_PER_SIDE) {
        return [_nodes objectForKey:[NSNumber numberWithInt:node.num + LIGHTS_PER_SIDE]];
    }
    else {
        return [_nodes objectForKey:[NSNumber numberWithInt:node.num - LIGHTS_PER_SIDE]];
    }
    return nil;
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
    
    NSMutableDictionary *mirrorNodeDict = nil;
    if (self.sidesLocked) {
        // change other sides' node as well
        NSTimeInterval duration = type == kRWnodeTypeFire ? [self fireDuration] : [self lightDuration];
        RWNodeButton *mirrorNode = [self mirroredNode:node];
        [mirrorNode changeTapStateForType:type duration:duration];
        mirrorNodeDict = [NSMutableDictionary dictionaryWithDictionary:nodeDict];
        [mirrorNodeDict setObject:[NSNumber numberWithInt:mirrorNode.num] forKey:@"number"];
    }
    //[self.delegate nodesChanged:[NSArray arrayWithObject:nodeDict]];
    [self.delegate nodesChanged:[NSArray arrayWithObjects:nodeDict, mirrorNodeDict, nil]];
}

- (NSTimeInterval)lightDuration {
    // TO DO: make this fully work based on mode
    RWFirstViewController *mainController = [RWFirstViewController sharedInstance];
    NSTimeInterval duration = 0;
    if (!mainController.permanence) {
        duration = mainController.lightDurationSlider.value;
    }
    return duration;
    //return (NSTimeInterval)[[[RWFirstViewController sharedInstance] lightDurationSlider] value];
}

- (NSTimeInterval)fireDuration {
    // TO DO: make this fully work based on mode
    return (NSTimeInterval)[[[RWFirstViewController sharedInstance] fireDurationSlider] value];
}

- (void)touchesHaveEnded {
    // do the right thing based on mode
}

@end
