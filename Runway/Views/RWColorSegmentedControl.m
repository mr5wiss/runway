//
//  RWColorSegmentedControl.m
//  Runway
//
//  Created by Arshad Tayyeb on 8/18/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWColorSegmentedControl.h"
#import "RWFirstViewController.h"
#import "ILCircleView.h"
#import "UIView+Image.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Lightness.h"
#import "UIImage+ProportionalFill.h"

#define COLORSDICTIONARY 
@implementation RWColorSegmentedControl


+ (NSDictionary *)colorsDictionary {
    static NSDictionary *s_colorsDictionary = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      s_colorsDictionary = @{\
        @"blue" : [UIColor blueColor],\
        @"green" : [UIColor greenColor],\
        @"red" : [UIColor redColor],\
        @"checker" : [UIColor grayColor],\
        @"eq" : [UIImage imageNamed:@"eq_meter"],\
        @"rainbow" : [UIImage imageNamed:@"colorwheel"],\
        @"random" : [UIImage imageNamed:@"questionmark"],\
        };
    });
    return s_colorsDictionary;
}

//returns the names we want to show in the order we want to show them
+ (NSArray *)colorNamesArray {
    return @[
             @"blue",
             @"green",
             @"red",
             @"checker",
             @"eq",
             @"rainbow",
             @"random",
             ];
}

- (RWColorSegmentedControl *)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {
    return [super initWithItems:items];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)commonInit {
    int i = 0;
    
    for (NSString *colorString in [[self class] colorNamesArray]) {
        
        id value = [[[self class] colorsDictionary] valueForKey:colorString];
        UIImage *image = nil;
        
        if ([value isKindOfClass:[UIColor class]]) {
            //make a circle image
            UIColor *color = (UIColor *)value;
            ILCircleView *circle = [[ILCircleView alloc] initWithCenter:CGPointMake(10,10) radius:10];
            circle.color = color;
            circle.layer.shadowColor = [color darkerColor].CGColor;
            circle.layer.shadowOffset = CGSizeMake(2,2);
            image = [circle imageRepresentation];
        } else if ([value isKindOfClass:[UIImage class]]) {
            image = [value imageScaledToFitSize:CGSizeMake(25, 25)];
        }
        
        if (i < self.numberOfSegments) {
            [self setImage:image forSegmentAtIndex:i++];
        } else {
            NSLog(@"Need more segments in color control %d/%d", i, self.numberOfSegments);
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commandSent:) name:kCommandSentNotification object:nil];

}

#pragma mark updates from the controller
- (void)commandSent:(NSNotification *)note {
    
    NSDictionary *commandInfo = [note object];
    //    NSLog(@"+++ Observed command sent: %@", commandInfo);
    
    if ([[commandInfo allKeys] containsObject:@"color"]) {
        NSString *colorValue = [commandInfo valueForKey:@"color"];
        NSInteger index = [[[self class] colorNamesArray] indexOfObject:colorValue];
        if (index != NSNotFound && index < self.numberOfSegments) {
            self.selectedSegmentIndex = index;
        }
    }
}

- (NSString *)colorString {
    if (self.selectedSegmentIndex != NSNotFound) {
        return [[[self class] colorNamesArray] objectAtIndex:self.selectedSegmentIndex];
    }
    return nil;
}


@end
