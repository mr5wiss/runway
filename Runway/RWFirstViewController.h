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
@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, strong) IBOutlet UIImageView *topImage;
@property (nonatomic, strong) IBOutlet UIImageView *bottomImage;
@property (nonatomic, strong) IBOutlet UILabel *tapLabel;
@property (nonatomic, strong) IBOutlet UISwitch *tapSwitch;
@property (nonatomic, strong) IBOutlet UIButton *debugConnectButton;
@property (nonatomic, strong) IBOutlet UIButton *lockSidesButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *onBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *offBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *panicBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pattern1BarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pattern2BarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pattern3BarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pattern4BarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *pattern5BarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *recordBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopRecordBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *loopBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *stopLoopBarButton;
@property (nonatomic, strong) NSArray *patterns;

- (IBAction)controlButtonTapped:(id)sender;
- (IBAction)connectButtonTapped:(id)sender;
- (IBAction)lockSidesTapped:(id)sender;
- (IBAction)sliderChanged:(id)sender;


@end
