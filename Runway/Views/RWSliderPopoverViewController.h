//
//  RWSliderPopoverViewController.h
//  Runway
//
//  Created by Arshad Tayyeb on 8/19/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RWSliderPopoverViewController;

@protocol RWSliderPopoverViewControllerDelegate <NSObject>
- (void)sliderValueChanged:(RWSliderPopoverViewController *)sender;
@end

@interface RWSliderPopoverViewController : UIViewController

@property (nonatomic, readwrite) CGFloat currentValue;

@property (nonatomic, strong) NSArray *descreteValues; //must be set before this is useful.  An Array of NSNumbers
// example: @[@(0.02), @(0.03), @(0.04), @(0.05), @(0.06), @(0.07), @(0.08), @(0.09), @(0.10), @(0.125), @(0.15), @(0.175), @(0.2), @(0.3), @(0.4), @(0.5), @(0.75), @(1.0), @(1.5), @(2.0), @(2.5), @(3.0)];

@property (nonatomic, strong) UISlider *tandemSlider;  //if provided, this will get an initial value from that slider, and will also adjust the value of that slider as text changes
@property (nonatomic, strong) UILabel *tandemValueLabel;  //if provided, the slider will also update that value label

@property (weak) id<RWSliderPopoverViewControllerDelegate>delegate;

@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *currentValueLabel;

- (IBAction)valueChanged:(id)sender;
- (IBAction)fingerUp:(id)sender;
@end
