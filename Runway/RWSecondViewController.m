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
                          //0-4
                          PATTERNDICT(0, @"Clear", [UIColor whiteColor])
                          PATTERNDICT(1, @"Random String", [UIColor whiteColor])
                          PATTERNDICT(2, @"Random Point", [UIColor whiteColor])
                          PATTERNDICT(3, @"Simple Chaser", [UIColor whiteColor])
                          PATTERNDICT(4, @"Cylon Chaser", [UIColor whiteColor])
                          //5-9
                          PATTERNDICT(5, @"String Blink", [UIColor whiteColor])
                          PATTERNDICT(6, @"Lightning String Blink", [UIColor whiteColor])
                          PATTERNDICT(7, @"String Pulsate", [UIColor whiteColor])
                          PATTERNDICT(8, @"Watery", [UIColor whiteColor])
                          PATTERNDICT(9, @"Blue Watery", [UIColor whiteColor])
                          //10-14
                          PATTERNDICT(10, @"Light Chase", [UIColor whiteColor])
                          PATTERNDICT(11, @"Blink Specific", [UIColor whiteColor])
                          PATTERNDICT(12, @"All On", [UIColor yellowColor])
                          PATTERNDICT(13, @"Light Chase Blue", [UIColor whiteColor])
                          PATTERNDICT(14, @"Blink Specific All", [UIColor whiteColor])
                          //15-19
                          PATTERNDICT(15, @"Chase Specific", [UIColor whiteColor])
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
