//
//  RWNodeView.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWNodeView.h"
#import "RWNodeManager.h"
#import "RWNodeButton.h"
#import "RWFirstViewController.h"

#define NODE_WIDTH 22
#define FIRST_FIRE 1
#define FIRE_GAP 2

@implementation RWNodeView {
    RWNodeButton *_lastTouchedNode;
    nodeType _lastTypeChanged;
    CGPoint _lastTouchLocation;
    BOOL _lastDirectionWasForward;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _startNum = 0;
        _nodeManager = nil;
        _controlMode = kRWControlModeBoth;
    }
    return self;
}

// the view needs to know the start node number, the node manager, and the frame
- (id)initWithStartNum:(NSInteger)startNum manager:(RWNodeManager *)manager frame:(CGRect)frame {
    self = [self initWithFrame:frame];
    if (self) {
        _startNum = startNum;
        _nodeManager = manager;
        // create nodes, add them as subviews, and them to the manager
        for (NSInteger i=0; i<LIGHTS_PER_SIDE; i++) {
            CGRect buttonFrame = CGRectMake(i*NODE_WIDTH, 0, NODE_WIDTH, self.frame.size.height);
            // light node or both (pure fire nodes don't exist on initialization)
            nodeType type = i >= FIRST_FIRE && (i-FIRST_FIRE) / FIRE_GAP < FIRE_PER_SIDE && (i-FIRST_FIRE) % FIRE_GAP == 0 ? kRWnodeTypeBoth : kRWnodeTypeLight;
            RWNodeButton *node = [[RWNodeButton alloc] initWithNum:startNum+i type:type frame:buttonFrame];
            [self addSubview:node];
            [manager addNode:node number:startNum+i];
            node.delegate = manager;
        }
    }
    return self;
}

- (BOOL)addNodes {
    if (!_nodeManager) {
        return NO;
    }
    // create nodes, add them as subviews, and them to the manager
    for (NSInteger i=0; i<LIGHTS_PER_SIDE; i++) {
        CGRect buttonFrame = CGRectMake(i*NODE_WIDTH, 0, NODE_WIDTH, self.frame.size.height);
        // light node or both (pure fire nodes don't exist on initialization)
        nodeType type = i >= FIRST_FIRE && (i-FIRST_FIRE) / FIRE_GAP < FIRE_PER_SIDE && (i-FIRST_FIRE) % FIRE_GAP == 0 ? kRWnodeTypeBoth : kRWnodeTypeLight;
        RWNodeButton *node = [[RWNodeButton alloc] initWithNum:_startNum+i type:type frame:buttonFrame];
        [self addSubview:node];
        [_nodeManager addNode:node number:_startNum+i];
        node.delegate = _nodeManager;
    }
    return YES;
}

- (void)setControlMode:(eControlMode)controlMode {
    if (controlMode == self.controlMode) {
        return;
    }
    else {
        if (controlMode == kRWControlModeBoth) {
            int i=0;
            for (RWNodeButton *node in self.subviews) {
                node.type = i >= FIRST_FIRE && (i-FIRST_FIRE) / FIRE_GAP < FIRE_PER_SIDE && (i-FIRST_FIRE) % FIRE_GAP == 0 ? kRWnodeTypeBoth : kRWnodeTypeLight;
                node.hidden = NO;
                i++;
            }
        }
        else if (controlMode == kRWControlModeFire) {
            int i=0;
            for (RWNodeButton *node in self.subviews) {
                
                if (i >= FIRST_FIRE && (i-FIRST_FIRE) / FIRE_GAP < FIRE_PER_SIDE && (i-FIRST_FIRE) % FIRE_GAP == 0) {
                    node.type = kRWnodeTypeFire;
                }
                else {
                    node.hidden = YES;
                }
                i++;
            }
        }
        else {
            for (RWNodeButton *node in self.subviews) {
                node.type = kRWnodeTypeLight;
                node.hidden = NO;
            }
        }
    }
    _controlMode = controlMode;
}

- (NSInteger)locationToNodeNum:(CGPoint)location {
    NSInteger nodeNum = location.x / NODE_WIDTH;
    if (nodeNum > self.startNum + LIGHTS_PER_SIDE - 1) {
        nodeNum = self.startNum + LIGHTS_PER_SIDE - 1;
    }
    return nodeNum;
}

#pragma mark touches functions
// catch touches here, so that we can determine what node we dragged into
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    //NSLog(@"touch moved at location: %f,%f", location.x, location.y);
    RWNodeButton *node = [self.subviews objectAtIndex:[self locationToNodeNum:location]];
    if (node.hidden) {
        return;
    }
    CGPoint convertedPoint = [self convertPoint:location toView:node];
    BOOL currentDirectionIsForward = location.x > _lastTouchLocation.x;
    nodeType typeChanged = [node typeForLocation:convertedPoint];
    if (node == _lastTouchedNode && typeChanged == _lastTypeChanged &&
        (![[RWFirstViewController sharedInstance] permanence] || _lastDirectionWasForward == currentDirectionIsForward)) {
        _lastTouchLocation = location;
        return;
    }   
    _lastTouchLocation = location;
    _lastDirectionWasForward = currentDirectionIsForward;
    _lastTouchedNode = node;
    _lastTypeChanged = typeChanged;
    nodeTypeStatus status = typeChanged == kRWnodeTypeLight ? !node.lightStatus : !node.fireStatus;
    [_nodeManager stateWasChangedTo:status forNode:node type:typeChanged];
    // this shows what's happening on the display
    NSTimeInterval duration = typeChanged == kRWnodeTypeLight ? [_nodeManager lightDuration] : [_nodeManager fireDuration];
    [node changeTapStateForType:typeChanged duration:duration];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSLog(@"touch ended at location: %f,%f", location.x, location.y);
    _lastTouchedNode = nil;
    [_nodeManager touchesHaveEnded];
}

@end
