//
//  RWFirstViewController.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SRWebSocket.h"
#import "RWNodeManager.h"
#import "FPNumberPadView.h"
#import "RWNodeView.h"
#import "RWSliderPopoverViewController.h"

#define LIGHTS_PER_SIDE 42
#define FIRE_PER_SIDE 20

//This lets any listening controller (e.g. RWSecondViewController) know when any command was sent and react appropriately
#define kCommandSentNotification @"kCommandSentNotification"  //sends dictionary of {@"command" : commandString, @"value" : value} 

@interface RWFirstViewController : UIViewController<SRWebSocketDelegate, RWNodeManagerDelegate, UITextFieldDelegate, FPKeypadDelegate, RWSliderPopoverViewControllerDelegate>
// the main input views
@property (nonatomic, strong) IBOutlet RWNodeView *topNodes;
@property (nonatomic, strong) IBOutlet RWNodeView *bottomNodes;

// mode controls
@property (nonatomic, strong) IBOutlet UISegmentedControl *nodeControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *permanenceControl;

// sliders
@property (nonatomic, strong) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) IBOutlet UISlider *lightDurationSlider;
@property (nonatomic, strong) IBOutlet UISlider *fireDurationSlider;
@property (nonatomic, strong) IBOutlet UISlider *fadeInSlider;
@property (nonatomic, strong) IBOutlet UISlider *fadeOutSlider;

@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar;

// labels
@property (nonatomic, strong) IBOutlet UILabel *tapLabel;
@property (nonatomic, strong) IBOutlet UILabel *tickLabel;
@property (nonatomic, strong) IBOutlet UILabel *patternLabel;
@property (nonatomic, strong) IBOutlet UILabel *fireDurationLabel;
@property (nonatomic, strong) IBOutlet UILabel *lightDurationsLabel;
@property (nonatomic, strong) IBOutlet UILabel *fadeInLabel;
@property (nonatomic, strong) IBOutlet UILabel *fadeOutLabel;

// buttons controlling nodes
@property (nonatomic, strong) IBOutlet UIButton *clearButton;
@property (nonatomic, strong) IBOutlet UIButton *lockSidesButton;
@property (nonatomic, strong) IBOutlet UIButton *allTopButton;
@property (nonatomic, strong) IBOutlet UIButton *allBottomButton;

// bar buttons
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
@property (nonatomic, strong) IBOutlet UIBarButtonItem *connectButton;

// other
@property (nonatomic, strong) IBOutlet UISwitch *tapSwitch;
@property (nonatomic, strong) IBOutlet UIButton *panicButton;

// pattern stuff - needs work
@property (nonatomic, strong) IBOutlet UIButton *patternChooseButton;
@property (nonatomic, strong) IBOutlet UITextField *patternField;
@property (nonatomic, strong) IBOutlet UISegmentedControl *colorControl;
@property (nonatomic, strong) IBOutlet UIView *patternKeyPadContainer; //  not implemented
@property (weak, nonatomic) IBOutlet UIView *fireTogglesContainerView;
@property (weak, nonatomic) IBOutlet UIView *patternContainerView;
@property (weak, nonatomic) IBOutlet UIView *tempoContainerView;

// are lights staying on until turned off, or only for duration
@property (readonly) BOOL permanence;

+ (RWFirstViewController *)sharedInstance;

// buttons controlling string nodes
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)lockSidesTapped:(id)sender;
- (IBAction)allTapped:(id)sender;
- (IBAction)allReleased:(id)sender;

// for choosing a pattern
- (IBAction)patternButtonTapped:(id)sender;

// sliders
- (IBAction)tempoChanged:(id)sender;
- (IBAction)durationChanged:(id)sender;
- (IBAction)fadeChanged:(id)sender;

// segmented controls
- (IBAction)nodesChosen:(id)sender;
- (IBAction)permanenceChosen:(id)sender;
- (IBAction)timeChosen:(id)sender;

- (IBAction)colorChosen:(id)sender;
- (IBAction)panic:(id)sender;
- (IBAction)showPopover:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lightDurationButton;
@property (weak, nonatomic) IBOutlet UIButton *fireDurationButton;
@property (weak, nonatomic) IBOutlet UIButton *fadeOutButton;
@property (weak, nonatomic) IBOutlet UIButton *fadeInButton;

@property (weak, nonatomic) IBOutlet UIView *sharedControlsView;

#pragma mark control interface for external callers (e.g., RWSecondViewController)
- (void)sendPatternNumber:(NSInteger)patternNumber;

@end
