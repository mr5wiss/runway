//
//  RWFirstViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWFirstViewController.h"
#import "RWNodeManager.h"

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
    BOOL _sidesLocked;
    NSTimer *_timer;
    NSTimer *_loopTimer;
    NSMutableArray *_panTouchingStatus;
    NSMutableArray *_recordHistory;
    RWNodeManager *_nodeManager;
    RWFirstViewController *_s_sharedInstance;
}

static RWFirstViewController *s_sharedInstance;

+ (RWFirstViewController *)sharedInstance {
    return s_sharedInstance;
}

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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    BOOL res = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight);
    //NSLog(@"Should: %d : %d", toInterfaceOrientation, res);
    return res;
}

#pragma mark view lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    //self.patterns = [[NSArray alloc] initWithObjects:@"--NO PATTERN--", @"pattern 1", @"pattern 2", @"pattern 3", @"pattern 4", @"pattern 5", @"pattern 6", @"pattern 7", @"pattern 8", @"pattern 9", nil];
    
    // here?
    s_sharedInstance = self;
    
    _nodeManager = [[RWNodeManager alloc] init];
    _nodeManager.delegate = self;
    
    // add manager to node view and add nodes to node views and manager
    _topNodes.nodeManager = _nodeManager;
    _topNodes.userInteractionEnabled = YES;
    if (![_topNodes addNodes]) {
        NSLog(@"couldn't add nodes to top node view");
    }
    
    _bottomNodes.nodeManager = _nodeManager;
    _bottomNodes.userInteractionEnabled = YES;
    _bottomNodes.startNum = LIGHTS_PER_SIDE;
    if (![_bottomNodes addNodes]) {
        NSLog(@"couldn't add nodes to top node view");
    }
    
    // label tap recognizer to enable tapping for tempo
    _tapLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tempoTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tempoTapped:)];
    [_tapLabel addGestureRecognizer:tempoTapRecognizer];
    
    // init
    _playaMode = YES;
    _running = NO;
    _recordOn = NO;
    _looping = NO;
    _numTapped = 0;
    _sidesLocked = NO;
    
    //actions
    [_tapSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    
    // bar buttons
    _offBarButton.tintColor = [UIColor blueColor];
    _onBarButton.action = @selector(initNetworkCommunication);
    _offBarButton.action = @selector(disconnect);
    _panicBarButton.action = @selector(panic);
    _pattern1BarButton.action = @selector(runPattern:);
    _pattern2BarButton.action = @selector(runPattern:);
    _pattern3BarButton.action = @selector(runPattern:);
    _pattern4BarButton.action = @selector(runPattern:);
    _pattern5BarButton.action = @selector(runPattern:);
    _recordBarButton.action = @selector(recordButtonTapped);
    _stopRecordBarButton.action = @selector(recordOffTapped);
    _loopBarButton.action = @selector(loopTapped);
    
    // set up array for panning view
    _panTouchingStatus = [[NSMutableArray alloc] initWithCapacity:2];
    NSMutableDictionary *view1TouchDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    NSMutableDictionary *view2TouchDict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [view1TouchDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
    [view1TouchDict setObject:[NSNumber numberWithBool:NO] forKey:@"light"];
    [_panTouchingStatus addObject:view1TouchDict];
    [_panTouchingStatus addObject:view2TouchDict];
    
    _recordHistory = [[NSMutableArray alloc] init];
    
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
    _recordBarButton.tintColor = [UIColor blueColor];
    // clear out any current recording
    [_recordHistory removeAllObjects];
}

- (void)recordOffTapped {
    // record final state
    [self record:nil];
    _recordOn = NO;
    _recordBarButton.tintColor = nil;
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
    _recordBarButton.tintColor = nil;
    if (!_looping && [_recordHistory count] > 0) {
        _looping = YES;
        _loopBarButton.tintColor = [UIColor blueColor];
        // play it once and set timer to repeat
        [self playRecordHistory:nil];
        [self setLoopTimer];
    }
    // turning off
    else {
        _looping = NO;
        _loopBarButton.tintColor = nil;
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

- (IBAction)nodeButtonTapped:(id)sender {
    if (sender == self.clear1Button){
        // send clear message for string 1
    }
    else if (sender == self.clear2Button) {
        // send clear message for string 2
    }
    else if (sender == self.all1Button) {
        
    }
    else if (sender == self.all2Button) {
        
    }
    else if (sender == self.exec1Button) {
        
    }
    else if (sender == self.exec2Button) {
        
    }
}

// tempo
- (void)tempoChanged:(id)sender {
    if (_tapSwitch.on) {
        return;
    }
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    // send time between pattern updates
    [self send:[NSString stringWithFormat:@"tick=%f", 1.1 - value]];
    self.tickLabel.text = [NSString stringWithFormat:@"Tick: %.1fs", 1.1 - value];
}

// duration
- (void)durationChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    if (slider == _lightDurationSlider) {
        // send light duration updarte
        [self send:[NSString stringWithFormat:@"lightduration=%f", value]];
        _lightDurationsLabel.text = [NSString stringWithFormat:@"%.1fs", value];
    }
    else {
        // send fire duration updarte
        [self send:[NSString stringWithFormat:@"fireduration=%f", value]];
        _fireDurationLabel.text = [NSString stringWithFormat:@"%.2fs", value];
    }
}

// bpm tapping
- (void)switchChanged:(id)sender {
    _numTapped = 0;
}

- (void)tempoTapped:(id)sender {
    if (!_tapSwitch.on) {
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

- (void)nodesChosen:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    // do different stuff based on what was tapped
    switch (sc.selectedSegmentIndex) {
        case 0: // both
            // stuff
            self.topNodes.controlMode = kRWControlModeBoth;
            self.bottomNodes.controlMode = kRWControlModeBoth;
            break;
        case 1: // lights
            // stuff
            // go through node manager instead?
            self.topNodes.controlMode = kRWControlModeLights;
            self.bottomNodes.controlMode = kRWControlModeLights;
            break;
        case 2: // fire
            // stuff
            self.topNodes.controlMode = kRWControlModeFire;
            self.bottomNodes.controlMode = kRWControlModeFire;
            break;
        default:
            break;
    }
}

- (void)permanenceChosen:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    // do different stuff based on what was tapped
    switch (sc.selectedSegmentIndex) {
        case 0:
            // stuff
            break;
        case 1:
            // stuff
            break;
        case 2:
            // stuff
            break;
        default:
            break;
    }
}

- (void)timeChosen:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    // do different stuff based on what was tapped
    switch (sc.selectedSegmentIndex) {
        case 0:
            // stuff
            break;
        case 1:
            // stuff
            break;
        case 2:
            // stuff
            break;
        default:
            break;
    }
}

// what nodes are you controlling?
/*- (void)controlButtonTapped:(id)sender {
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
}*/

- (void)lockSidesTapped:(id)sender {
    // make sides go in lockstep (and unlock)
    if (!_sidesLocked) {
        [self.lockSidesButton setTitle:@"Unlock" forState:UIControlStateNormal];
        _sidesLocked = YES;
    }
    else {
        [self.lockSidesButton setTitle:@"Lock Sides" forState:UIControlStateNormal];
        _sidesLocked = NO;
    }
}

- (IBAction)patternButtonTapped:(id)sender {
    // slide in list to choose from
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
            NSInteger fireNum = startingFireNum + (divX-1)/2;
            NSString *sendString = [NSString stringWithFormat:@"fire=%d", fireNum];
            if (_sidesLocked) {
                sendString = [sendString stringByAppendingFormat:@",fire=%d", fireNum + FIRE_PER_SIDE];
            }
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
        NSInteger lightNum = startingLightNum + adjustedX/lightCycle;
        NSString *sendString = [NSString stringWithFormat:@"light=%d", lightNum];
        if (_sidesLocked) {
            sendString = [sendString stringByAppendingFormat:@",light=%d", lightNum + LIGHTS_PER_SIDE];
        }
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
                    [touchingDict setObject:[NSNumber numberWithBool:YES] forKey:@"fire"];
                    [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"light"];
                    NSInteger fireNum = startingFireNum + (divX-1)/2;
                    NSString *sendString = [NSString stringWithFormat:@"fire=%d", fireNum];
                    if (_sidesLocked) {
                        sendString = [sendString stringByAppendingFormat:@",fire=%d", fireNum + FIRE_PER_SIDE];
                    }
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
            // we're touching nothing, set both to NO
            else if (modX > LIGHT_WIDTH) {
                [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"light"];
                [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
                return;
            }
            // we're touching a light area
            // if we were already touching a light, ignore
            else if ([[touchingDict objectForKey:@"light"] boolValue]) {
                return;
            }
            // newly touching a light area
            else {
                [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
                // send command if we're controlling lights
                if (_controllingLights) {
                    [touchingDict setObject:[NSNumber numberWithBool:YES] forKey:@"light"];
                    NSInteger lightNum = startingLightNum + divX;
                    NSString *sendString = [NSString stringWithFormat:@"light=%d", lightNum];
                    if (_sidesLocked) {
                        sendString = [sendString stringByAppendingFormat:@",light=%d", lightNum + LIGHTS_PER_SIDE];
                    }
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
        }
        // we're out of fire's range
        else if ([[touchingDict objectForKey:@"fire"] boolValue]) {
            [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
        }
    }
    if (_controllingLights) {
        // TO DO: fix these numbers
        if (adjustedY < LIGHT_TOP_Y || adjustedY > LIGHT_BOTTOM_Y || location.x < LIGHT_INITIAL_GAP) {
            [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"light"];
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
                    [touchingDict setObject:[NSNumber numberWithBool:YES] forKey:@"light"];
                    [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
                    NSInteger lightNum = startingLightNum + divX;
                    NSString *sendString = [NSString stringWithFormat:@"light=%d", lightNum];
                    if (_sidesLocked) {
                        sendString = [sendString stringByAppendingFormat:@",light=%d", lightNum + LIGHTS_PER_SIDE];
                    }
                    [self record:sendString];
                    [self send:sendString];
                    return;
                }
            }
            // not touching anything
            else {
                [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"fire"];
                [touchingDict setObject:[NSNumber numberWithBool:NO] forKey:@"light"];
            }
        }
    }
}

/*#pragma mark - UIPickerViewDelegate
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
}*/

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
    self.tapSwitch.on = NO;
    // disconnected, so no more heartbeat
    [_timer invalidate];
}

#pragma mark

- (NSString *)messageFromDict:(NSDictionary *)node {
    NSString *command = [node valueForKey:@"command"];
    NSString *type = [node valueForKey:@"type"];
    NSInteger num = [[node valueForKey:@"number"] intValue];
    NSString *letter = [type isEqualToString:@"fire"] ? @"f" : @"l";
    if ([command isEqualToString:@"off"]) {
        return [NSString stringWithFormat:@"%@x=%d", letter, num];
    }
    else {
        return [NSString stringWithFormat:@"%@%@=%d", letter, self.permanence ? @"r" : @"", num];
    }
}

#pragma mark RWNodeManagerDelegate

- (void)nodesChanged:(NSArray *)nodes {
    NSString *connector = @"";
    NSString *sendMessage = @"";
    for (NSDictionary *node in nodes) {
        NSString *nodeMsg = [self messageFromDict:node];
        sendMessage = [sendMessage stringByAppendingFormat:@"%@%@", connector, nodeMsg];
        if (connector.length == 0) {
            connector = @",";
        }
    }
    [self send:sendMessage];
}

@end
