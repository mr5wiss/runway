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

#define HORIZONTAL_START_POS 100;
#define VERTICAL_START_POS 100;

#define HORIZONTAL_PADDING_BETWEEN_BUTTONS 40
#define VERTICAL_PADDING_BETWEEN_BUTTONS 40

@interface RWSecondViewController ()
@property (readonly) RWFirstViewController *lightController;
@property (readonly) NSArray *patternArray;
@property (strong) NSDictionary *patternButtonDictionary;
@end

//definitions of the states

//convenience define that makes a row with the state description
#define PATTERNDICT(number, name, displayColor) @{@"number" : @(number), @"name" : (name), @"displayColor" : (displayColor)},


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
                           //PATTERNDICT(-1, @"Clear", [UIColor whiteColor])
                           //PATTERNDICT(0, @"Show Node", [UIColor grayColor]) //doesn't work without parameters
                          PATTERNDICT(1, @"Show Lights", [UIColor whiteColor])
                          PATTERNDICT(2, @"Show Flames", [UIColor whiteColor])
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
                          PATTERNDICT(13, @"Chase Light Dual", [UIColor grayColor]) //needs lightgap parameter
//                          PATTERNDICT(14, @"Chase Multi Light Dual", [UIColor grayColor]) //needs lightgap parameter
                          PATTERNDICT(15, @"Silly Rabbits", [UIColor whiteColor])

                          //16-20
                          PATTERNDICT(16, @"Fill Up Lights Simple", [UIColor whiteColor])
                          PATTERNDICT(17, @"Fill Up Lights Dual", [UIColor whiteColor])
//                          PATTERNDICT(18, @"Fill Up Lights Dual Eq", [UIColor grayColor]) //needs lightEq parameter
                          PATTERNDICT(19, @"Light And Fire Simple Chaser", [UIColor orangeColor])
                          PATTERNDICT(20, @"Light And Fire Dual Chaser", [UIColor orangeColor])

                          //21-25
                          PATTERNDICT(21, @"Light And Fire Simple Dual", [UIColor orangeColor])
                          PATTERNDICT(22, @"Light And Fire Simple Dual Reverse", [UIColor orangeColor])
                          PATTERNDICT(23, @"Twinkle All Flames", [UIColor orangeColor])
                          PATTERNDICT(24, @"Twinkle ALL", [UIColor orangeColor])
                          PATTERNDICT(25, @"Twinkle All Lights Random Fade", [UIColor whiteColor])
                          ];
        
    });
    return s_patternArray;

}

- (void)layoutPatterns {
    CGFloat xPos = HORIZONTAL_START_POS;
    CGFloat yPos = VERTICAL_START_POS;
    
    NSMutableDictionary *buttonDict = [NSMutableDictionary dictionaryWithCapacity:1];
    
    CGFloat maxX = 1024; //adjust if necessary to make room for other stuff
    
    for (NSDictionary *patternDict in self.patternArray) {
        RWPatternButton *button = [RWPatternButton patternButtonWithDictionary:patternDict];
        button.frame = CGRectMake(xPos, yPos, button.frame.size.width, button.frame.size.height);
        button.delegate = self;
        [self.view addSubview:button];
        
        //adjust for next button
        xPos += button.frame.size.width + HORIZONTAL_PADDING_BETWEEN_BUTTONS;
        if ((xPos + button.frame.size.width)  > maxX) {
            xPos = HORIZONTAL_START_POS;
            yPos += button.frame.size.height + VERTICAL_PADDING_BETWEEN_BUTTONS;
        }
        [buttonDict setObject:button forKey:[patternDict valueForKey:@"number"]];
    }

    self.patternButtonDictionary = buttonDict;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self layoutPatterns];
    
    //listen to commands from first view controller
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandSent:) name:kCommandSentNotification object:nil];
    
}

- (void)viewDidUnload {
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
