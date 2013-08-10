//
//  RWFirstViewController.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"

@interface RWFirstViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, SRWebSocketDelegate>
@property (nonatomic, strong) IBOutlet UIPickerView *patternPicker;
@property (nonatomic, strong) IBOutlet UIButton *allControlsButton;
@property (nonatomic, strong) IBOutlet UIButton *lightsButton;
@property (nonatomic, strong) IBOutlet UIButton *fireButton;
@property (nonatomic, strong) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *panGS;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *tapGS;
@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, strong) IBOutlet UIImageView *topImage;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImage;
@property (nonatomic, strong) IBOutlet UILabel *tapLabel;
@property (nonatomic, strong) IBOutlet UISwitch *tapSwitch;
@property (nonatomic, strong) NSArray *patterns;

- (IBAction)controlButtonTapped:(id)sender;
- (IBAction)sliderChanged:(id)sender;
- (IBAction)imageTapped:(UIGestureRecognizer *)sender;
- (IBAction)imagePanned:(UIGestureRecognizer *)sender;


@end
