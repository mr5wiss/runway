//
//  RWNodeView.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 8/17/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

//static NSString *const kRWnodeTypeFire = @"fire";
//static NSString *const kRWnodeTypeLight = @"light";

#import <UIKit/UIKit.h>
#import "RWNodeManager.h"

typedef enum {
    kRWControlModeFire = 0,
    kRWControlModeLights,
    kRWControlModeBoth
} eControlMode;

@interface RWNodeView : UIView
@property (nonatomic) NSInteger startNum;
@property (nonatomic, strong) RWNodeManager *nodeManager;
@property (nonatomic, readwrite) eControlMode controlMode;
//@property (nonatomic, strong) id<RWNodeButtonDelegate>delegate;
- (id)initWithStartNum:(NSInteger)startNum manager:(RWNodeManager *)manager frame:(CGRect)frame;
- (BOOL)addNodes;

@end
