//
//  RWSecondViewController.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "RWPatternButton.h"

@interface RWSecondViewController : UIViewController <RWPatternButtonDelegate>
@property (weak, nonatomic) IBOutlet UIView *parametersContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *patternButtonsContainerView;

@end
