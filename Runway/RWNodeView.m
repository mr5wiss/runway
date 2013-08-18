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

#define LIGHTS_PER_SIDE 42
#define FIRE_PER_SIDE 20
#define NODE_WIDTH 22
#define FIRST_FIRE 1
#define FIRE_GAP 2

@implementation RWNodeView {
    NSArray *_singleNodeButtons;
    NSArray *_doubleNodeButtons;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _startNum = 0;
        _nodeManager = nil;
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

// too general for now
/*- (id)initWithLights:(NSInteger)numLights fire:(NSInteger)numFire firstFire:(NSInteger)firstFire fireGap:(NSInteger)fireGap startNum:(NSInteger)startNum manager:(RWNodeManager *)manager withFrame:(CGRect)frame {
    self = [self initWithFrame:frame];
    if (self) {
        NSInteger width = frame.size.width / numLights;
        for (NSInteger i=0; i<numLights; i++) {
            CGRect buttonFrame = CGRectMake(i*width, 0, width, frame.size.height);
            nodeType type = i >= numFire && (i-firstFire) / fireGap < numFire && (i-firstFire) % fireGap == 0 ? kRWnodeTypeBoth : kRWnodeTypeLight;
            RWNodeButton *button = [[RWNodeButton alloc] initWithNum:startNum+i type:type frame:buttonFrame];
            button.delegate = manager;
        }
    }
}*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
