//
//  RWFirstViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWFirstViewController.h"
#import "RWNodeManager.h"

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
    
    // plan to do this a different way
    //self.patterns = [[NSArray alloc] initWithObjects:@"--NO PATTERN--", @"pattern 1", @"pattern 2", @"pattern 3", @"pattern 4", @"pattern 5", @"pattern 6", @"pattern 7", @"pattern 8", @"pattern 9", nil];
    
    // create a shared instance - here?
    s_sharedInstance = self;
    
    // initialize the node manager
    _nodeManager = [[RWNodeManager alloc] init];
    _nodeManager.delegate = self;
    
    // add manager to node view and add nodes to node views and manager
    _topNodes.nodeManager = _nodeManager;
    _topNodes.userInteractionEnabled = YES;
    _topNodes.controlMode = kRWControlModeBoth;
    _topNodes.startNum = LIGHTS_PER_SIDE;
    if (![_topNodes addNodes]) {
        NSLog(@"couldn't add nodes to top node view");
    }
    
    _bottomNodes.nodeManager = _nodeManager;
    _bottomNodes.userInteractionEnabled = YES;
    _bottomNodes.controlMode = kRWControlModeBoth;
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
    _panicBarButton.action = @selector(panic:);
    _pattern1BarButton.action = @selector(runPattern:);
    _pattern2BarButton.action = @selector(runPattern:);
    _pattern3BarButton.action = @selector(runPattern:);
    _pattern4BarButton.action = @selector(runPattern:);
    _pattern5BarButton.action = @selector(runPattern:);
    _recordBarButton.action = @selector(recordButtonTapped);
    _stopRecordBarButton.action = @selector(recordOffTapped);
    _loopBarButton.action = @selector(loopTapped);
    _connectButton.action = @selector(connectButtonTapped:);
    
    _recordHistory = [[NSMutableArray alloc] init];
    
    self.patternField.delegate = self;
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
- (void)panic:(id)sender {
    [self send:@"panic=1"];
    // force user to confirm leaving mode
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Panic!" message:@"Everything has been turned off.  Please press OK to exit panic mode" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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

// clear everything
- (IBAction)clearButtonTapped:(id)sender {
    [self send:@"clear=1"];
    // clear the node feedback
    [_nodeManager clearNodes];
}


// TO DO
- (IBAction)allTapped:(id)sender {
    if (sender == _allBottomButton) {
        [_nodeManager turnOnBottom];
    }
    else {
        [_nodeManager turnOnTop];
    }
}

// clear top or bottom
- (IBAction)allReleased:(id)sender {
    if (sender == _allBottomButton) {
        [_nodeManager clearBottom];
    }
    else {
        [_nodeManager clearTop];
    }
}

// tempo
- (void)tempoChanged:(id)sender {
    if (_tapSwitch.on) {
        return;
    }
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    CGFloat total = slider.maximumValue + slider.minimumValue;
    // send time between pattern updates
    [self send:[NSString stringWithFormat:@"tick=%f", total - value]];
    self.tickLabel.text = [NSString stringWithFormat:@"Tick: %.1fs", total - value];
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
        _fireDurationLabel.text = [NSString stringWithFormat:@"%.1fs", value];
    }
}

// fade
- (void)fadeChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    [self send:[NSString stringWithFormat:@"fadetime=%.1f", value]];
    _lightFadeLabel.text = [NSString stringWithFormat:@"%.1fs", value];
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
            self.topNodes.controlMode = kRWControlModeBoth;
            self.bottomNodes.controlMode = kRWControlModeBoth;
            break;
        case 1: // lights
            self.topNodes.controlMode = kRWControlModeLights;
            self.bottomNodes.controlMode = kRWControlModeLights;
            break;
        case 2: // fire
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
        case 0: // on for duration
            _permanence = NO;
            break;
        case 1: // on until changed
            _permanence = YES;
            break;
        default:
            break;
    }
}

// TO DO: get this to work
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

// color - TO DO: decide on colors and do interface well
- (void)colorChosen:(id)sender {
    UISegmentedControl *sc = (UISegmentedControl *)sender;
    // do different stuff based on what was tapped
    switch (sc.selectedSegmentIndex) {
        case 0:
            [self send:[NSString stringWithFormat:@"color=blue"]];
            break;
        case 1:
            [self send:[NSString stringWithFormat:@"color=green"]];
            break;
        case 2:
            [self send:[NSString stringWithFormat:@"color=red"]];
            break;
        case 3:
            [self send:[NSString stringWithFormat:@"color=yellow"]];
            break;
        case 4:
            [self send:[NSString stringWithFormat:@"color=pick"]];
            break;
        case 5:
            [self send:[NSString stringWithFormat:@"color=eq"]];
            break;
        default:
            break;
    }
}

- (void)lockSidesTapped:(id)sender {
    // make sides go in lockstep (and unlock)
    if (!_sidesLocked) {
        [self.lockSidesButton setTitle:@"Unlock" forState:UIControlStateNormal];
        _sidesLocked = YES;
        _nodeManager.sidesLocked = YES;
    }
    else {
        [self.lockSidesButton setTitle:@"Lock" forState:UIControlStateNormal];
        _sidesLocked = NO;
        _nodeManager.sidesLocked = NO;
    }
}

// sends number user typed in - TO DO: better interface
- (IBAction)patternButtonTapped:(id)sender {
    // later, slide in list to choose from
    [self.patternField resignFirstResponder];
    NSInteger patternNum = [self.patternField.text integerValue];
    [self send:[NSString stringWithFormat:@"pattern=%d", patternNum]];
    // change label text
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
    // set protocol letter and convert node number
    NSString *letter;
    if ([type isEqualToString:@"fire"]) {
        letter = @"f";
        num = (num+1)/2;
    }
    else {
        letter = @"l";
        num = num+1;
    }
    //NSString *letter = [type isEqualToString:@"fire"] ? @"f" : @"l";
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

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    NSInteger patternNum = [textField.text integerValue];
    [self send:[NSString stringWithFormat:@"pattern=%d", patternNum]];
    return YES;
}

@end
