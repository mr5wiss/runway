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
#import "RWNodeView.h"

typedef enum {
    kRWOutputModeNow = 0,
    kRWOutputModeRelease,
    kRWOutputModeExec
} eOutputMode;

@interface RWFirstViewController : UIViewController<SRWebSocketDelegate, RWNodeManagerDelegate>
@property (nonatomic, strong) IBOutlet RWNodeView *topNodes;        // custom view
@property (nonatomic, strong) IBOutlet RWNodeView *bottomNodes;     // custom view
@property (nonatomic, strong) IBOutlet UIView *patternKeyPad;   // custom view
@property (nonatomic, strong) IBOutlet UISegmentedControl *nodeControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *permanenceControl;
@property (nonatomic, strong) IBOutlet UISegmentedControl *timeControl;
@property (nonatomic, strong) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) IBOutlet UISlider *lightDurationSlider;
@property (nonatomic, strong) IBOutlet UISlider *fireDurationSlider;
@property (nonatomic, strong) IBOutlet UIToolbar *topToolbar;
@property (nonatomic, strong) IBOutlet UILabel *tapLabel;
@property (nonatomic, strong) IBOutlet UILabel *tickLabel;
@property (nonatomic, strong) IBOutlet UILabel *patternLabel;
@property (nonatomic, strong) IBOutlet UILabel *fireDurationLabel;
@property (nonatomic, strong) IBOutlet UILabel *lightDurationsLabel;
@property (nonatomic, strong) IBOutlet UISwitch *tapSwitch;
@property (nonatomic, strong) IBOutlet UIButton *debugConnectButton;
@property (nonatomic, strong) IBOutlet UIButton *clear1Button;
@property (nonatomic, strong) IBOutlet UIButton *all1Button;
@property (nonatomic, strong) IBOutlet UIButton *exec1Button;
@property (nonatomic, strong) IBOutlet UIButton *all2Button;
@property (nonatomic, strong) IBOutlet UIButton *clear2Button;
@property (nonatomic, strong) IBOutlet UIButton *exec2Button;
@property (nonatomic, strong) IBOutlet UIButton *patternChooseButton;
@property (nonatomic, strong) IBOutlet UIButton *panicButton;
@property (nonatomic, strong) IBOutlet UIButton *lockSidesButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *onBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *offBarButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *debugBarButton;
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
@property (readonly) BOOL permanence;
@property (readonly) eOutputMode outputMode;

+ (RWFirstViewController *)sharedInstance;

// buttons controlling string nodes
- (IBAction)nodeButtonTapped:(id)sender;
- (IBAction)lockSidesTapped:(id)sender;

// for choosing a pattern
- (IBAction)patternButtonTapped:(id)sender;

// sliders
- (IBAction)tempoChanged:(id)sender;
- (IBAction)durationChanged:(id)sender;

// segmented controls
- (IBAction)nodesChosen:(id)sender;
- (IBAction)permanenceChosen:(id)sender;
- (IBAction)timeChosen:(id)sender;


@end
