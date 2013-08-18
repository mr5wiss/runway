//
//  RWNodeManager.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWNodeButton.h"

@protocol RWNodeManagerDelegate <NSObject>

// called whenever the node manager has a list of nodes that need updating
// nodes contains dictionaries describing the type and number of the node and the command to be sent (on or off)
- (void)nodesChanged:(NSArray *)nodes;

@end

@interface RWNodeManager : NSObject<RWNodeButtonDelegate>
@property id<RWNodeManagerDelegate>delegate;
@property (readwrite)BOOL sidesLocked;
- (void)addNode:(RWNodeButton *)node number:(NSInteger)num;

@end
