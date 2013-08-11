//
//  RWFirstViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWFirstViewController.h"

// these will be based on the actual images and configuration we use
#define LIGHTS_PER_SIDE 42
#define FIRE_PER_SIDE 20
#define FIRE_TOP_Y 70
#define FIRE_BOTTOM_Y 102
#define LIGHT_TOP_Y 32
#define LIGHT_BOTTOM_Y 142
#define LIGHT_WIDTH 10
#define LIGHT_GAP 14
#define LIGHT_INITIAL_GAP 15

// change as we hook up lights
#define LIGHTS_FOR_TEST 42

@interface RWFirstViewController ()
@property (nonatomic, strong) SRWebSocket *wSocket;
@end

@implementation RWFirstViewController {
    BOOL _controllingLights;
    BOOL _controllingFire;
    NSInteger _numTapped;
    NSDate * _firstTappedTime;
    BOOL _playaMode;
    BOOL _running;
    BOOL _recordOn;
    BOOL _looping;
    NSTimer *_timer;
    NSTimer *_loopTimer;
    NSMutableArray *_panTouchingStatus;
    NSMutableArray *_recordHistory;
}
@synthesize patternPicker, allControlsButton, lightsButton, fireButton, tempoSlider, topToolbar, topImage, bottomImage, wSocket, tapLabel, tapSwitch, onBarButton, offBarButton, panicBarButton, pattern1BarButton, pattern2BarButton, pattern3BarButton, pattern4BarButton, pattern5BarButton, recordBarButton, stopRecordBarButton, loopBarButton, stopLoopBarButton, patterns, debugConnectButton;

#pragma mark socket functions
- (void)initNetworkCommunication {
    NSString *urlString = _playaMode ? @"ws://10.0.0.1:8000" : @"ws://raspberrypi.local:8000";
    self.wSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:urlString]];
    self.wSocket.delegate = self;
    [self.wSocket open];
}

- (BOOL)send:(NSString *)msg {
    NSLog(@"sending %@...", msg);
    if (self.wSocket.readyState == SR_OPEN) {
        [self.wSocket send:msg];
        return YES;
    }
    else {
        if (!_recordOn) {
            NSLog(@"socket not open: nothing sent");
        }
        return NO;
    }
}

#pragma mark view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.patterns = [[NSArray alloc] initWithObjects:@"--NO PATTERN--", @"pattern 1", @"pattern 2", @"pattern 3", @"pattern 4", @"pattern 5", @"pattern 6", @"pattern 7", @"pattern 8", @"pattern 9", nil];
    self.topImage.userInteractionEnabled = YES;
    self.bottomImage.userInteractionEnabled = YES;
    
    // for now, turn it "on" here (sending nil simulates both lights and fire)
    [self controlButtonTapped:nil];
    
    // label tap recognizer to enable tapping for tempo
    tapLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tempoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tempoTapped:)];
    [tapLabel addGestureRecognizer:tempoTapRecognizer];
    
    // init
    _playaMode = YES;
    _running = NO;
    _recordOn = NO;
    _looping = NO;
    _numTapped = 0;
    
    //actions
    [tapSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // bar buttons
    self.offBarButton.tintColor = [UIColor blueColor];
    onBarButton.action = @selector(initNetworkCommunication);
    offBarButton.action = @selector(disconnect);
    panicBarButton.action = @selector(panic);
    pattern1BarButton.action = @selector(runPattern:);
    pattern2BarButton.action = @selector(runPattern:);
    pattern3BarButton.action = @selector(runPattern:);
    pattern4BarButton.action = @selector(runPattern:);
    pattern5BarButton.action = @selector(runPattern:);
    recordBarButton.action = @selector(recordButtonTapped);
    stopRecordBarButton.action = @selector(recordOffTapped);
    loopBarButton.action = @selector(loopTapped);
    
    // set up array for panning view
    _panTouchingStatus = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableDictionary *view1TouchDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableDictionary *view2TouchDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [view1TouchDict setObject:@NO forKey:@"fire"];
    [view1TouchDict setObject:@NO forKey:@"light"];
    [_panTouchingStatus addObject:view1TouchDict];
    [_panTouchingStatus addObject:view2TouchDict];
    
    _recordHistory = [[NSMutableArray alloc] init];
    
    //self.view.multipleTouchEnabled = YES;
    
#ifndef DEBUG
    debugConnectButton.hidden = YES;
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark actions
// send heartbeat
- (void)timerFire:(NSTimer *)timer {
    [self send:@"alive=1"];
}

- (void)disconnect {
    [self.wSocket close];
}

// SHUT EVERYTHING OFF!!!
- (void)panic {
    [self send:@"panic=1"];
}

- (void)recordButtonTapped {
    _recordOn = YES;
    recordBarButton.tintColor = [UIColor blueColor];
    // clear out any current recording
    [_recordHistory removeAllObjects];
}

- (void)recordOffTapped {
    // record final state
    [self record:nil];
    _recordOn = NO;
    recordBarButton.tintColor = nil;
    // save it?
}

- (void)playRecordHistory:(NSTimer *)timer {
    NSDate *previousTime = nil;
    NSTimeInterval cumulative = 0;
    for (NSDictionary *tuple in _recordHistory) {
        // skip end marker
        if (tuple == [_recordHistory lastObject]) {
            break;
        }
        NSString *msg = [tuple objectForKey:@"message"];
        if (!previousTime) {
            [self send:msg];
            previousTime = [tuple objectForKey:@"timestamp"];
        }
        else {
            NSTimeInterval timeSincePrevious = [(NSDate *)[tuple objectForKey:@"timestamp"] timeIntervalSinceDate:previousTime];
            previousTime = [tuple objectForKey:@"timestamp"];
            cumulative += timeSincePrevious;
            //NSLog(@"sending msg: %@ with delay: %f", msg, cumulative);
            [self performSelector:@selector(send:) withObject:msg afterDelay:cumulative];
        }
    }
}

- (void)setLoopTimer {
    NSDate *first = [[_recordHistory objectAtIndex:0] objectForKey:@"timestamp"];
    // what should this be?
    NSDate *last = [[_recordHistory lastObject] objectForKey:@"timestamp"];
    NSTimeInterval length = [last timeIntervalSinceDate:first];
    // at least one second
    if (length == 0) {
        length = 1;
    }
    //NSLog(@"loop interval: %f", length);
    _loopTimer = [NSTimer scheduledTimerWithTimeInterval:length target:self selector:@selector(playRecordHistory:) userInfo:nil repeats:YES];
}

- (void)loopTapped {
    // record final state
    [self record:nil];
    _recordOn = NO;
    recordBarButton.tintColor = nil;
    if (!_looping && [_recordHistory count] > 0) {
        _looping = YES;
        loopBarButton.tintColor = [UIColor blueColor];
        // play it once and set timer to repeat
        [self playRecordHistory:nil];
        [self setLoopTimer];
    }
    // turning off
    else {
        _looping = NO;
        loopBarButton.tintColor = nil;
        [_loopTimer invalidate];
    }
}

// tests
- (void)runPattern:(id)sender {
    NSString *buttonTitle = [(UIBarButtonItem *)sender title];
    NSTimeInterval delay;
    // single run patterns
    // crossover pattern (up chaser and down chaser simultaneously)
    if ([buttonTitle isEqualToString:@"Pattern 1"]) {
        delay = 0.3;
        for (NSInteger i=0; i<LIGHTS_FOR_TEST; i++) {
            NSTimeInterval fullDelay = delay*(i+1);
            [self performSelector:@selector(send:) withObject:[NSString stringWithFormat:@"light=%d", i+1] afterDelay:fullDelay];
        }
        for (NSInteger i=LIGHTS_FOR_TEST-1; i>=0; i--) {
            NSTimeInterval fullDelay = delay*(LIGHTS_FOR_TEST-i-1);
            [self performSelector:@selector(send:) withObject:[NSString stringWithFormat:@"light=%d", i+1] afterDelay:fullDelay];
        }
        return;
    }
    // double chaser
    else if ([buttonTitle isEqualToString:@"Pattern 2"]) {
        delay = 0.2;
        for (NSInteger i=0; i<LIGHTS_FOR_TEST/2; i++) {
            NSTimeInterval fullDelay = delay*(i+1);
            [self performSelector:@selector(send:) withObject:[NSString stringWithFormat:@"light=%d", i+1] afterDelay:fullDelay];
        }
        for (NSInteger i=LIGHTS_FOR_TEST/2; i<LIGHTS_FOR_TEST; i++) {
            NSTimeInterval fullDelay = delay*(i-LIGHTS_PER_SIDE+1);
            [self performSelector:@selector(send:) withObject:[NSString stringWithFormat:@"light=%d", i+1] afterDelay:fullDelay];
        }
        return;
    }
    // repeating single chasers
    // fastish
    else if ([buttonTitle isEqualToString:@"Pattern 3"]) {
        delay = 0.1;
    }
    // fast
    else if ([buttonTitle isEqualToString:@"Pattern 4"]) {
        delay = 0.05;
    }
    // blazing
    else if ([buttonTitle isEqualToString:@"Pattern 5"]) {
        delay = 0.005;
    }
    // do it 8 times so we can spot any glitches
    for (int j=0; j<8; j++) {
        for (NSInteger i=0; i<LIGHTS_FOR_TEST; i++) {
            // complicated but right
            NSTimeInterval fullDelay = delay*LIGHTS_FOR_TEST*j + delay*(i+1);
            [self performSelector:@selector(send:) withObject:[NSString stringWithFormat:@"light=%d", i+1] afterDelay:fullDelay];
        }
    }
}

// tempo
- (void)sliderChanged:(id)sender {
    if (tapSwitch.on) {
        return;
    }
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    // send time between pattern updates
    [self send:[NSString stringWithFormat:@"tick=%f", 1.1 - value]];
}

// bpm tapping
- (void)switchChanged:(id)sender {
    _numTapped = 0;
}

- (void)tempoTapped:(id)sender {
    if (!tapSwitch.on) {
        return;
    }
    _numTapped++;
    if (_numTapped == 1) {
        _firstTappedTime = [NSDate date];
    }
    else {
        NSDate *currentTapTime = [NSDate date];
        NSTimeInterval interval = [currentTapTime timeIntervalSinceDate:_firstTappedTime];
        // calculate average tick length
        CGFloat rate = interval / _numTapped;
        // only send tick after 5 taps
        if (_numTapped >= 5) {
            [self send:[NSString stringWithFormat:@"tick=%f", rate]];
        }
    }
}

// when not in playa mode
- (void)connectButtonTapped:(id)sender {
    _playaMode = NO;
    if (!_running) {
        [self initNetworkCommunication];
    }
}

// what nodes are you controlling?
- (void)controlButtonTapped:(id)sender {
    // change images based on which controls are active
    if ((UIButton *)sender == fireButton) {
        self.topImage.image = [UIImage imageNamed:@"runwayFire.png"];
        self.bottomImage.image = [UIImage imageNamed:@"runwayFire.png"];
        _controllingFire = YES;
        _controllingLights = NO;
    }
    else if ((UIButton *)sender == lightsButton) {
        self.topImage.image = [UIImage imageNamed:@"runwayLights.png"];
        self.bottomImage.image = [UIImage imageNamed:@"runwayLights.png"];
        _controllingLights = YES;
        _controllingFire = NO;
    }
    else {
        self.topImage.image = [UIImage imageNamed:@"runwayLightsFire.png"];
        self.bottomImage.image = [UIImage imageNamed:@"runwayLightsFire.png"];
        _controllingFire = YES;
        _controllingLights = YES;
    }
}

#pragma mark recording

- (void)record:(NSString *)message {
    if (!_recordOn) {
        return;
    }
    NSDate *timeStamp = [NSDate date];
    if (!message) {
        message = @"XXX";
    }
    NSDictionary *nodeTuple = [NSDictionary dictionaryWithObjectsAndKeys:message, @"message", timeStamp, @"timestamp", nil];
    [_recordHistory addObject:nodeTuple];
}

#pragma mark node calculations
- (void)sendNodeDataBasedOnTap:(CGPoint)location view:(NSInteger)viewNum {
    NSInteger startingLightNum = viewNum == 0 ? 1 : LIGHTS_PER_SIDE+1;
    NSInteger startingFireNum = viewNum == 0 ? 0 : FIRE_PER_SIDE;
    // no adjustment now
    CGFloat adjustedY = location.y;
    
    BOOL hitFire = NO;
    // fire touch has to be precisely within target
    NSInteger lightCycle = LIGHT_WIDTH + LIGHT_GAP;
    NSInteger minX = LIGHT_INITIAL_GAP + lightCycle + LIGHT_WIDTH;
    NSInteger maxX = LIGHT_INITIAL_GAP + (LIGHTS_PER_SIDE-1)*lightCycle;
    if (_controllingFire && adjustedY >= FIRE_TOP_Y && adjustedY <= FIRE_BOTTOM_Y && location.x >= minX && location.x < maxX) {
        NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
        NSInteger modX = adjustedX % lightCycle;
        NSInteger divX = adjustedX / lightCycle;
        if (modX > LIGHT_WIDTH && divX % 2 == 1) {
            hitFire = YES;
            NSString *sendString = [NSString stringWithFormat:@"fire=%d", startingFireNum + (divX-1)/2];
            [self record:sendString];
            [self send:sendString];
        }
    }
    // if fire wasn't hit, turn on closest light to touch, even if it missed the actual target
    if (!hitFire && _controllingLights) {
        NSInteger xAdjustemnt = LIGHT_INITIAL_GAP - LIGHT_GAP/2;
        NSInteger adjustedX = location.x - xAdjustemnt;
        if (adjustedX < 0) adjustedX = 0;
        NSInteger highX = 1023 - 2*xAdjustemnt;
        if (adjustedX > highX) adjustedX = highX;
        NSString *sendString = [NSString stringWithFormat:@"light=%d", startingLightNum + adjustedX/lightCycle];
        [self record:sendString];
        [self send:sendString];
    }
}

// TO DO: deal with multiple pans on same side and pans from one view to another
- (void)sendNodeDataBasedOnPan:(CGPoint)location view:(NSInteger)viewNum {
    // sender's view is always bottom image, so check y value to determine which view was clicked on
    NSInteger startingLightNum = viewNum == 0 ? 1 : LIGHTS_PER_SIDE+1;
    NSInteger startingFireNum = viewNum == 0 ? 0 : FIRE_PER_SIDE;
    // no adjustment anymore
    CGFloat adjustedY = location.y;
    
    NSMutableDictionary *touchingDict = [_panTouchingStatus objectAtIndex:viewNum];
    
    NSInteger lightCycle = LIGHT_WIDTH + LIGHT_GAP;
    NSInteger minX = LIGHT_INITIAL_GAP + lightCycle + LIGHT_WIDTH;
    NSInteger maxX = LIGHT_INITIAL_GAP + (LIGHTS_PER_SIDE-1)*lightCycle;
    if (_controllingFire) {
        if (adjustedY >= FIRE_TOP_Y && adjustedY <= FIRE_BOTTOM_Y && location.x >= minX && location.x < maxX) {
            NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
            NSInteger modX = adjustedX % lightCycle;
            NSInteger divX = adjustedX / lightCycle;
            // we're touching fire
            if (modX > LIGHT_WIDTH && divX % 2 == 1) {
                // if we were already touching fire, don't send again
                if ([[touchingDict objectForKey:@"fire"] boolValue]) {
                    return;
                }
                // if not, send the command
                else {
                    [touchingDict setObject:@YES forKey:@"fire"];
                    [touchingDict setObject:@NO forKey:@"light"];
                    NSString *sendString = [NSString stringWithFormat:@"fire=%d", startingFireNum + (divX-1)/2];
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
            // we're touching nothing, set both to NO
            else if (modX > LIGHT_WIDTH) {
                [touchingDict setObject:@NO forKey:@"light"];
                [touchingDict setObject:@NO forKey:@"fire"];
                return;
            }
            // we're touching a light area
            // if we were already touching a light, ignore
            else if ([[touchingDict objectForKey:@"light"] boolValue]) {
                return;
            }
            // newly touching a light area
            else {
                [touchingDict setObject:@NO forKey:@"fire"];
                // send command if we're controlling lights
                if (_controllingLights) {
                    [touchingDict setObject:@YES forKey:@"light"];
                    NSString *sendString = [NSString stringWithFormat:@"light=%d", startingLightNum + divX];
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
        }
        // we're out of fire's range
        else if ([[touchingDict objectForKey:@"fire"] boolValue]) {
            [touchingDict setObject:@NO forKey:@"fire"];
        }
    }
    if (_controllingLights) {
        // TO DO: fix these numbers
        if (adjustedY < LIGHT_TOP_Y || adjustedY > LIGHT_BOTTOM_Y || location.x < LIGHT_INITIAL_GAP) {
            [touchingDict setObject:@NO forKey:@"light"];
        }
        else {
            NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
            NSInteger modX = adjustedX % lightCycle;
            NSInteger divX = adjustedX / lightCycle;
            // touching light
            if (modX <= LIGHT_WIDTH) {
                // already touching
                if ([[touchingDict objectForKey:@"light"] boolValue]) {
                    return;
                }
                // newly touching, send command
                else {
                    [touchingDict setObject:@YES forKey:@"light"];
                    [touchingDict setObject:@NO forKey:@"fire"];
                    NSString *sendString = [NSString stringWithFormat:@"light=%d", startingLightNum + divX];
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
            // not touching anything
            else {
                [touchingDict setObject:@NO forKey:@"fire"];
                [touchingDict setObject:@NO forKey:@"light"];
            }
        }
    }
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // respond to pattern choice
    [self send:[NSString stringWithFormat:@"pattern=%d", row]];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return patterns.count;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [patterns objectAtIndex:row];
}

#pragma mark SRWebSocketDelegate
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"webSocket did receive message: %@", message);
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"webSocket did open");
    _running = YES;
    // indicate connection status
    self.offBarButton.tintColor = nil;
    self.onBarButton.tintColor = [UIColor blueColor];
    // turn on heartbeat timer to tell pi we're connected
    _timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    // this doesn't seem to get called if we call open and can't connect (or maybe it just takes forever)
    NSLog(@"webSocket did fail %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Failure" message:@"The app could not connect to the pi" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"webSocket did close %d (%@)", code, reason);
    _running = NO;
    // indicate connection status
    self.onBarButton.tintColor = nil;
    self.offBarButton.tintColor = [UIColor blueColor];
    // views to defaults
    self.tempoSlider.value = 0.5;
    [self.patternPicker selectedRowInComponent:0];
    self.tapSwitch.on = NO;
    // disconnected, so no more heartbeat
    [_timer invalidate];
}

#pragma mark touches functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    CGPoint location = [touch locationInView:touch.view];
    NSInteger viewNum = touch.view.frame.origin.y < 50 ? 0 : 1;
    [self sendNodeDataBasedOnTap:location view:viewNum];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    CGPoint location = [touch locationInView:touch.view];
    NSInteger viewNum = touch.view.frame.origin.y < 50 ? 0 : 1;
    [self sendNodeDataBasedOnPan:location view:viewNum];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (![touch.view isKindOfClass:[UIImageView class]]) {
        return;
    }
    NSInteger viewNum = touch.view.frame.origin.y < 200 ? 0 : 1;
    NSMutableDictionary *touchDict = [_panTouchingStatus objectAtIndex:viewNum];
    [touchDict setObject:@NO forKey:@"fire"];
    [touchDict setObject:@NO forKey:@"light"];
}

@end
