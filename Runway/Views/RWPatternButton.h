//
//  RWPatternButton.h
//  Runway
//
//  //in case we want to customize
//
//
//  Created by Arshad Tayyeb on 8/18/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BUTTON_WIDTH 100.0
#define BUTTON_HEIGHT 60.0

@protocol RWPatternButtonDelegate <NSObject>
- (void)patternTapped:(NSInteger)patternNumber;
@end

@interface RWPatternButton : UIView <UIGestureRecognizerDelegate>
@property (readonly) NSInteger patternNumber;
@property (readwrite) BOOL on;  // on will set the border to red
@property (weak) id<RWPatternButtonDelegate>delegate;
+ (RWPatternButton *)patternButtonWithDictionary:(NSDictionary *)patternInfo;
@end
