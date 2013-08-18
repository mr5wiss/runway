//
//  RWNodeButton.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWNodeButton;

// currently representing a light node, a fire node, or a fire and light node
typedef enum {
    kRWnodeTypeLight = 0,
    kRWnodeTypeFire,
    kRWnodeTypeBoth
} nodeType;

typedef enum {
    kRWnodeTypeStatusOff = 0,
    kRWnodeTypeStatusOn
} nodeTypeStatus;

@protocol RWNodeButtonDelegate <NSObject>
// called by the button when state has changed
- (void)stateWasChangedTo:(BOOL)state forNode:(RWNodeButton *)node type:(nodeType)type;
- (NSTimeInterval)fireDuration;
- (NSTimeInterval)lightDuration;
@optional
// called when touches have ended, signalling that it's time to act in certain modes
- (void)touchesHaveEnded;
@end

@interface RWNodeButton : UIButton
@property (nonatomic) nodeType type;
@property (nonatomic) NSInteger num;
@property (nonatomic) nodeTypeStatus lightStatus;
@property (nonatomic) nodeTypeStatus fireStatus;
@property (nonatomic, strong) id<RWNodeButtonDelegate>delegate;
- (RWNodeButton *)initWithNum:(NSInteger)num type:(nodeType)type frame:(CGRect)frame;
// change tap state without sending anything (just for feedback display)
- (void)changeTapStateForType:(nodeType)type duration:(NSTimeInterval)duration;
- (nodeType)typeForLocation:(CGPoint)location;
@end
