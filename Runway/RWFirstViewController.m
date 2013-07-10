//
//  RWFirstViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWFirstViewController.h"

// these will be based on the actual images we use
#define LIGHTS_PER_SIDE 41
#define FIRE_PER_SIDE 19
#define VIEW_ADJUSTMENT 483
#define FIRE_TOP_Y 70
#define FIRE_BOTTOM_Y 102
#define LIGHT_TOP_Y 32
#define LIGHT_BOTTOM_Y 142
#define LIGHT_WIDTH 10
#define LIGHT_GAP 14
#define LIGHT_INITIAL_GAP 27

@interface RWFirstViewController ()
@property (nonatomic, strong) SRWebSocket *wSocket;
@end

@implementation RWFirstViewController {
    BOOL _controllingLights;
    BOOL _controllingFire;
    BOOL _touchingFire;
    BOOL _touchingLight;
}
@synthesize patternPicker, allControlsButton, lightsButton, fireButton, tempoSlider, panGS, tapGS, topToolbar, topImage, bottomImage, wSocket, patterns;

- (void)initNetworkCommunication {
    self.wSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://raspberrypi.local:8000"]];
    self.wSocket.delegate = self;
    [self.wSocket open];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initNetworkCommunication];
    self.patterns = [[NSArray alloc] initWithObjects:@"pattern 1", @"pattern 2", @"pattern 3", @"pattern 4", @"pattern 5", @"pattern 6", @"pattern 7", @"pattern 8", @"pattern 9", nil];
    self.topImage.userInteractionEnabled = YES;
    self.bottomImage.userInteractionEnabled = YES;
    
    // for now, turn it "on" here (sending nil simulates both lights and fire)
    [self controlButtonTapped:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)send:(NSString *)msg {
    if (self.wSocket.readyState == SR_OPEN) {
        [self.wSocket send:msg];
        return YES;
    }
    else {
        NSLog(@"socket not open: nothing sent");
        return NO;
    }
}

- (void)sliderChanged:(id)sender {
    UISlider *slider = (UISlider *)sender;
    CGFloat value = slider.value;
    NSLog(@"tick=%f", value);
    [self send:[NSString stringWithFormat:@"tick=%f", value]];
}

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

- (void)imageTapped:(UIGestureRecognizer *)sender {
    UIView *view = sender.view;
    CGPoint location = [sender locationInView:view];
    // sender's view is always bottom image, so check y value to determine which view was clicked on
    NSInteger startingLightNum = location.y < 0 ? 0 : LIGHTS_PER_SIDE;
    NSInteger startingFireNum = location.y < 0 ? 0 : FIRE_PER_SIDE;
    // adjust y value if clicked on top image
    CGFloat adjustedY = location.y;
    if (adjustedY < 0) adjustedY += VIEW_ADJUSTMENT;
    NSLog(@"location:%f,%f", location.x, adjustedY);
    
    BOOL hitFire = NO;
    // fire touch has to be precisely within target
    NSInteger lightCycle = LIGHT_WIDTH + LIGHT_GAP;
    NSInteger minX = LIGHT_INITIAL_GAP + 2*lightCycle + LIGHT_WIDTH;
    if (_controllingFire && adjustedY >= FIRE_TOP_Y && adjustedY <= FIRE_BOTTOM_Y && location.x >= minX) {
        NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
        NSInteger modX = adjustedX % lightCycle;
        NSInteger divX = adjustedX / lightCycle;
        if (modX > LIGHT_WIDTH && divX % 2 == 0) {
            hitFire = YES;
            NSLog(@"fire=%d", startingFireNum + (divX-2)/2);
            [self send:[NSString stringWithFormat:@"fire=%d", startingFireNum + (divX-2)/2]];
        }
    }
    // if fire wasn't hit, turn on closest light to touch, even if it missed the actual target
    if (!hitFire && _controllingLights) {
        NSInteger xAdjustemnt = LIGHT_INITIAL_GAP - LIGHT_GAP/2;
        NSInteger adjustedX = location.x - xAdjustemnt;
        if (adjustedX < 0) adjustedX = 0;
        NSInteger highX = 1024 - xAdjustemnt;
        if (adjustedX > highX) adjustedX = highX;
        NSLog(@"light=%d", startingLightNum + adjustedX/lightCycle);
        [self send:[NSString stringWithFormat:@"light=%d", startingLightNum + adjustedX/lightCycle]];
    }
}

- (void)imagePanned:(UIGestureRecognizer *)sender {
    // reset on end of pan
    if (sender.state == UIGestureRecognizerStateEnded) {
        _touchingLight = NO;
        _touchingFire = NO;
        return;
    }
    // panning
    UIView *view = sender.view;
    CGPoint location = [sender locationInView:view];
    // sender's view is always bottom image, so check y value to determine which view was clicked on
    NSInteger startingLightNum = location.y < 0 ? 0 : LIGHTS_PER_SIDE;
    NSInteger startingFireNum = location.y < 0 ? 0 : FIRE_PER_SIDE;
    // adjust y value if clicked on top image
    CGFloat adjustedY = location.y;
    if (adjustedY < 0) adjustedY += VIEW_ADJUSTMENT;
    NSLog(@"location:%f,%f", location.x, adjustedY);
    
    NSInteger lightCycle = LIGHT_WIDTH + LIGHT_GAP;
    NSInteger minX = LIGHT_INITIAL_GAP + 2*lightCycle + LIGHT_WIDTH;
    if (_controllingFire) {
        if (adjustedY >= FIRE_TOP_Y && adjustedY <= FIRE_BOTTOM_Y && location.x >= minX) {
            NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
            NSInteger modX = adjustedX % lightCycle;
            NSInteger divX = adjustedX / lightCycle;
            // we're touching fire
            if (modX > LIGHT_WIDTH && divX % 2 == 0) {
                // if we were already touching fire, don't send again
                if (_touchingFire) {
                    return;
                }
                // if not, send the command
                else {
                    _touchingFire = YES;
                    _touchingLight = NO;
                    NSLog(@"fire=%d", startingFireNum + (divX-2)/2);
                    [self send:[NSString stringWithFormat:@"fire=%d", startingFireNum + (divX-2)/2]];
                    return;
                }
            }
            // we're touching nothing, set both to NO
            else if (modX > LIGHT_WIDTH) {
                _touchingLight = NO;
                _touchingFire = NO;
                return;
            }
            // we're touching a light area
            // if we were already touching a light, ignore
            else if (_touchingLight) {
                return;
            }
            // newly touching a light area
            else {
                _touchingFire = NO;
                // send command if we're controlling lights
                if (_controllingLights) {
                    _touchingLight = YES;
                    NSLog(@"light=%d", startingLightNum + divX);
                    [self send:[NSString stringWithFormat:@"light=%d", startingLightNum + divX]];
                    return;
                }
            }
        }
        // we're out of fire's range
        else if (_touchingFire) {
            _touchingFire = NO;
        }
    }
    if (_controllingLights) {
        // TO DO: fix these numbers
        if (adjustedY < LIGHT_TOP_Y || adjustedY > LIGHT_BOTTOM_Y || location.x < LIGHT_INITIAL_GAP) {
            _touchingLight = NO;
        }
        else {
            NSInteger adjustedX = location.x - LIGHT_INITIAL_GAP;
            NSInteger modX = adjustedX % lightCycle;
            NSInteger divX = adjustedX / lightCycle;
            // touching light
            if (modX <= LIGHT_WIDTH) {
                // already touching
                if (_touchingLight) {
                    return;
                }
                // newly touching, send command
                else {
                    _touchingLight = YES;
                    _touchingFire = NO;
                    NSLog(@"light=%d", startingLightNum + divX);
                    [self send:[NSString stringWithFormat:@"light=%d", startingLightNum + divX]];
                    return;
                }
            }
            // not touching anything
            else {
                _touchingFire = NO;
                _touchingLight = NO;
            }
        }
    }
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // respond to pattern choice
    NSLog(@"pattern=%d", row);
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
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"webSocket did fail %@", error);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"webSocket did close %d (%@)", code, reason);
    
}

@end
