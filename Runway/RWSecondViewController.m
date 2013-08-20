//
//  RWSecondViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWSecondViewController.h"
#import "RWPatternButton.h"
#import "RWFirstViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+UIView_Background.h"


#define HORIZONTAL_PADDING_BETWEEN_BUTTONS 40
#define VERTICAL_PADDING_BETWEEN_BUTTONS 40

#define HORIZONTAL_START_POS HORIZONTAL_PADDING_BETWEEN_BUTTONS;
//#define VERTICAL_START_POS 100;

@interface RWSecondViewController ()
@property (readonly) RWFirstViewController *lightController;
@property (readonly) NSArray *patternArray;
@property (strong) NSDictionary *patternButtonDictionary;
@end

//definitions of the states

//convenience define that makes a row with the state description
#define PATTERNDICT_FULL(number, name, displayColor, hasFlame) @{\
@"number" : @(number),\
@"name" : (name), \
@"displayColor" : (displayColor), \
@"hasFlame": @(hasFlame), \
},

#define PRESETDICT_FULL(number, name, displayColor, hasFlame) @{\
@"number" : @(number),\
@"name" : (name), \
@"displayColor" : (displayColor), \
@"hasFlame": @(hasFlame), \
},


#define PATTERNDICT(number, name, displayColor) PATTERNDICT_FULL(number, name, displayColor, NO)
#define PATTERNDICT_FLAME(number, name, displayColor) PATTERNDICT_FULL(number, name, displayColor, YES)

#define PRESETDICT(number, name) PRESETDICT_FULL(number, name, [UIColor orangeColor], NO)
#define PRESETDICT_FLAME(number, name) PATTERNDICT_FULL(number, name, [UIColor orangeColor], YES)


@implementation RWSecondViewController {
    AVAudioRecorder *_avAudioRecorder;
    NSTimer *_avTimer;
}

- (RWFirstViewController *)lightController {
    return [RWFirstViewController sharedInstance];
}

- (NSArray *)presetArray {
    static NSArray *s_presetArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_presetArray = @[
                          PRESETDICT(0, @"Preset 0")
                          PRESETDICT(1, @"Preset 1")
                          PRESETDICT(2, @"Preset 2")
                          PRESETDICT(3, @"Preset 3")
                          PRESETDICT(4, @"Preset 4")
                          PRESETDICT(5, @"Preset 5")

                          PRESETDICT(6, @"Preset 6")
                          PRESETDICT(7, @"Preset 7")
                          PRESETDICT(8, @"Preset 8")
                          PRESETDICT(9, @"Preset 9")
                          PRESETDICT(10, @"Preset 10")

                          PRESETDICT(11, @"Preset 11")
                          PRESETDICT(12, @"Preset 12")
                          PRESETDICT(13, @"Preset 13")
                          PRESETDICT(14, @"Preset 14")
                          PRESETDICT(15, @"Preset 15")
];
    });

    return s_presetArray;
    
}

- (NSArray *)patternArray {
    static NSArray *s_patternArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_patternArray = @[
                          //0-5
                          PATTERNDICT(-1, @"Clear", [UIColor whiteColor])
                           //PATTERNDICT(0, @"Show Node", [UIColor grayColor]) //doesn't work without parameters
                          PATTERNDICT(1, @"Show Lights", [UIColor whiteColor])
                          PATTERNDICT_FLAME(2, @"Show Flames", [UIColor whiteColor])
                          PATTERNDICT(3, @"Left Side All", [UIColor whiteColor])
                          PATTERNDICT(4, @"Right Side All", [UIColor whiteColor])
                          PATTERNDICT(5, @"Simple Chaser", [UIColor whiteColor])

                          //6-10
                          PATTERNDICT(6, @"Dual Chaser", [UIColor whiteColor])
                          PATTERNDICT(7, @"Dual Reverse Chaser", [UIColor whiteColor])
//                          PATTERNDICT(8, @"Multi Node Dual", [UIColor whiteColor]) // needs parameter (lightgap)
                          PATTERNDICT(9, @"Chase Light Simple", [UIColor whiteColor])
                          PATTERNDICT(10, @"Chase Light Circuit", [UIColor whiteColor])

                          //11-15
                          PATTERNDICT(11, @"Twinkle All", [UIColor whiteColor])
//                          PATTERNDICT(12, @"Show Logical Light", [UIColor grayColor]) //needs parameter
//                          PATTERNDICT(13, @"Chase Light Dual", [UIColor grayColor]) //needs lightgap parameter
//                          PATTERNDICT(14, @"Chase Multi Light Dual", [UIColor grayColor]) //needs lightgap parameter
                          PATTERNDICT(15, @"Silly Rabbits", [UIColor whiteColor])

                          //16-20
                          PATTERNDICT(16, @"Fill Up Lights Simple", [UIColor whiteColor])
                          PATTERNDICT(17, @"Fill Up Lights Dual", [UIColor whiteColor])
//                          PATTERNDICT(18, @"Fill Up Lights Dual Eq", [UIColor grayColor]) //needs lightEq parameter
                          PATTERNDICT_FLAME(19, @"Light And Fire Simple Chaser", [UIColor whiteColor])
                          PATTERNDICT_FLAME(20, @"Light And Fire Dual Chaser", [UIColor whiteColor])

                          //21-25
                          PATTERNDICT_FLAME(21, @"Light And Fire Simple Dual", [UIColor whiteColor])
                          PATTERNDICT_FLAME(22, @"Light And Fire Simple Dual Reverse", [UIColor whiteColor])
                          PATTERNDICT_FLAME(23, @"Twinkle All Flames", [UIColor whiteColor])
                          PATTERNDICT_FLAME(24, @"Twinkle ALL", [UIColor whiteColor])
                          PATTERNDICT(25, @"Twinkle All Lights Random Fade", [UIColor whiteColor])

                          PATTERNDICT_FLAME(26, @"Light and Fire Chaser Left", [UIColor whiteColor])
                          PATTERNDICT_FLAME(27, @"Light and Fire Chaser Right", [UIColor whiteColor])
                          PATTERNDICT_FLAME(28, @"Light and Fire Chaser Left Reverse", [UIColor whiteColor])
                          PATTERNDICT_FLAME(29, @"Light and Fire Chaser Right Reverse", [UIColor whiteColor])
                          PATTERNDICT_FLAME(30, @"Twinkle One Flame", [UIColor whiteColor])
                          
                          PATTERNDICT(31, @"Twinkle One Light", [UIColor whiteColor])
                          PATTERNDICT_FLAME(32, @"Twinkle One Flame and Light", [UIColor whiteColor])
                          PATTERNDICT(33, @"Twinkle All Lights", [UIColor whiteColor])
                          PATTERNDICT_FLAME(34, @"Twinkle All Lights, One Flame", [UIColor whiteColor])
                          
                          PATTERNDICT_FLAME(35, @"Light and Fire Chasers both directions", [UIColor whiteColor])

                          PATTERNDICT_FLAME(36, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(37, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(38, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(39, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(40, @"Pattern", [UIColor whiteColor])

                          PATTERNDICT_FLAME(41, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(42, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(43, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(44, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(45, @"Pattern", [UIColor whiteColor])

                          PATTERNDICT_FLAME(46, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(47, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(48, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(49, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(50, @"Pattern", [UIColor whiteColor])

                          
                          PATTERNDICT_FLAME(51, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(52, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(53, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(54, @"Pattern", [UIColor whiteColor])
                          PATTERNDICT_FLAME(55, @"Pattern", [UIColor whiteColor])

                          ];
        
        
        
    });
    return s_patternArray;

}

- (void)layoutPatterns {
    CGFloat xPos = HORIZONTAL_START_POS;
    CGFloat yPos = VERTICAL_PADDING_BETWEEN_BUTTONS;
    CGFloat buttonHeight;
    
    NSMutableDictionary *buttonDict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    CGFloat maxX = self.patternButtonsContainerView.frame.size.width; //adjust if necessary to make room for other stuff
    
    for (NSDictionary *patternDict in self.patternArray) {
        RWPatternButton *button = [RWPatternButton patternButtonWithDictionary:patternDict];
        buttonHeight = button.frame.size.height;
        button.frame = CGRectMake(xPos, yPos, button.frame.size.width, button.frame.size.height);

        button.delegate = self;
        [self.patternButtonsContainerView addSubview:button];
        
        //adjust for next button
        xPos = button.frame.origin.x + button.frame.size.width + HORIZONTAL_PADDING_BETWEEN_BUTTONS;
        if ((xPos + button.frame.size.width) > maxX) {
            xPos = HORIZONTAL_START_POS;
            yPos += button.frame.size.height + VERTICAL_PADDING_BETWEEN_BUTTONS;
        }
        [buttonDict setObject:button forKey:[patternDict valueForKey:@"number"]];
    }

    self.patternButtonDictionary = buttonDict;
    
    self.patternButtonsContainerView.contentSize = CGSizeMake(self.patternButtonsContainerView.frame.size.width, yPos + buttonHeight + VERTICAL_PADDING_BETWEEN_BUTTONS);
}

- (void)addMicrophoneControlButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self
               action:@selector(micButtonTapped:)
     forControlEvents:UIControlEventTouchDown];
    [button setTitle:@"Start Mic" forState:UIControlStateNormal];
    button.frame = CGRectMake(50.0, 10.0, 100.0, 40.0);
    [_parametersContainerView addSubview:button];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self layoutPatterns];
    [self addMicrophoneControlButton];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.parametersContainerView addDarkRoundyShadowBackground];
    [self.patternButtonsContainerView addDarkRoundyShadowBackground];
    
    //listen to commands from first view controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandSent:) name:kCommandSentNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    UIView *sharedControlsView = [[RWFirstViewController sharedInstance] sharedControlsView];
    if (![sharedControlsView isDescendantOfView:self.view]) {
        if ([sharedControlsView superview]) {
            [sharedControlsView removeFromSuperview];
        }
        [self.view addSubview:sharedControlsView];
    }
}

- (void)viewDidUnload {
    [self setPatternButtonsContainerView:nil];
    [self setParametersContainerView:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark updating UI
- (void)patternSent:(NSInteger)patternNumber {
    for (RWPatternButton *button in [self.patternButtonDictionary allValues]) {
        button.on = (button.patternNumber == patternNumber);
    }
}


#pragma mark RWPatternButtonDelegate
- (void)patternTapped:(NSInteger)patternNumber {
    [[self lightController] sendPatternNumber:patternNumber];
}


#pragma mark updates from the controller
- (void)commandSent:(NSNotification *)note {
    
    NSDictionary *commandInfo = [note object];
//    NSLog(@"+++ Observed command sent: %@", commandInfo);
    
    if ([[commandInfo allKeys] containsObject:@"pattern"]) {
        [self patternSent:[[commandInfo valueForKey:@"pattern"] integerValue]];
    }
    
}

#pragma mark microphone

- (void)updateMicrophoneLevels {
    [_avAudioRecorder updateMeters];
    float leftAvgPower = [_avAudioRecorder averagePowerForChannel:0];
    float leftPeakPower = [_avAudioRecorder peakPowerForChannel:0];
    
    float rightAvgPower = [_avAudioRecorder averagePowerForChannel:1];
    float rightPeakPower = [_avAudioRecorder peakPowerForChannel:1];
    
    // normalise meter levels to between 0 and 40
    int normalisedAvgLeft = (int) ((leftAvgPower + 160.0f)/40.0f);
    int normalisedAvgRight = (int) ((rightAvgPower + 160.0f)/40.0f);
    int normalisedPeakLeft = (int) ((leftPeakPower + 160.0f)/40.0f);
    int normalisedPeakRight = (int) ((rightPeakPower + 160.0f)/40.0f);
    
    // send the levels to the websocket
    [[self lightController] sendString:[NSString stringWithFormat:@"eql=%i,eqr=%i,eqpl=%i,eqpr=%i", normalisedAvgLeft, normalisedAvgRight, normalisedPeakLeft, normalisedPeakRight]];
}

- (void)micButtonTapped:(id)sender {
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"Start Mic"]) {
        [button setTitle:@"Stop Mic" forState:UIControlStateNormal];
        // configure and start the AVAudioRecorder
        NSError *err = nil;
        NSURL *url = [NSURL URLWithString:@"/dev/null"]; // don't save the recording
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:kAudioFormatLinearPCM], [NSNumber numberWithFloat:44100.0f], [NSNumber numberWithInt:2], nil]
                                                         forKeys:[NSArray arrayWithObjects:AVFormatIDKey, AVSampleRateKey, AVNumberOfChannelsKey, nil]];
        _avAudioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:dict error:&err];
        _avAudioRecorder.meteringEnabled = YES;
        [_avAudioRecorder record];
        
        // start timer to update the level meter
        _avTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateMicrophoneLevels) userInfo:nil repeats:YES];
    }
    else {
        [button setTitle:@"Start Mic" forState:UIControlStateNormal];
        // stop the timer which updates the microphone levels
        [_avTimer invalidate];
        _avTimer = nil;
        
        // stop recording the microphone
        [_avAudioRecorder stop];
        _avAudioRecorder = nil;
    }
}

@end
