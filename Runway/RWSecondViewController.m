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


#define PATTERNDICT(number, name, displayColor) PATTERNDICT_FULL(number, name, displayColor, NO)
#define PATTERNDICT_FLAME(number, name, displayColor) PATTERNDICT_FULL(number, name, displayColor, YES)


@implementation RWSecondViewController

- (RWFirstViewController *)lightController {
    return [RWFirstViewController sharedInstance];
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

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self layoutPatterns];
    
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

@end
