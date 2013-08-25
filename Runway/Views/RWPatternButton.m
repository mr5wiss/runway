//
//  RWPatternButton.m
//  Runway
//
//
//
//  Created by Arshad Tayyeb on 8/18/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWPatternButton.h"
#import <QuartzCore/QuartzCore.h>
@interface RWPatternButton ()
@property (readwrite) NSInteger patternNumber;
@property (strong) UILabel *titleLabel;
@property (strong) UILabel *numberLabel;
@property (strong) UIImageView *fireIndicator;
@property (nonatomic, strong) UIColor *preservedBackgroundColor;
@property (strong) UIColor *selectedBackgroundColor;
@property (strong) UIColor *tappedBackgroundColor;
@property (strong) NSString *identifier;
@end

@implementation RWPatternButton
@synthesize patternNumber;

+ (RWPatternButton *)patternButtonWithDictionary:(NSDictionary *)patternInfo {
    UIColor *color = [patternInfo valueForKey:@"displayColor"];
    NSString *title = [patternInfo valueForKey:@"name"];
    NSInteger number = [[patternInfo valueForKey:@"number"] integerValue];
    BOOL hasFire = [[patternInfo valueForKey:@"hasFlame"] boolValue];
    BOOL isPreset = [[patternInfo valueForKey:@"isPreset"] boolValue];
//    NSDictionary *parameters = [patternInfo valueForKey:@"parameters"];
    
    RWPatternButton *aButton = [[RWPatternButton alloc] initWithFrame:CGRectMake(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT)];
    aButton.titleLabel.text = title ? title : [NSString stringWithFormat:@"Pattern %d", 1];
    aButton.isPreset = isPreset;
    aButton.patternNumber = number;
    aButton.preservedBackgroundColor = color ? color : [UIColor whiteColor];
    aButton.selectedBackgroundColor = [UIColor yellowColor];
    aButton.tappedBackgroundColor = [UIColor orangeColor];
    aButton.frame = CGRectMake(0,0,BUTTON_WIDTH, BUTTON_HEIGHT);
    aButton.numberLabel.text = [NSString stringWithFormat:@"%d", number];
    aButton.fireIndicator.hidden = !hasFire;
    aButton.identifier = [patternInfo valueForKey:@"identifier"];
    return aButton;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.borderColor = [UIColor colorWithWhite:.5 alpha:1.0].CGColor;
        self.layer.borderWidth = 2.0;
        self.layer.cornerRadius = 4.0;
        self.layer.shadowColor = [UIColor colorWithWhite:.2 alpha:.5].CGColor;
        self.layer.shadowOffset = CGSizeMake(-2,-2);
        
        self.fireIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fire"]];
        self.fireIndicator.contentMode = UIViewContentModeScaleAspectFit;
        self.fireIndicator.frame = CGRectMake(BUTTON_WIDTH-18, 2, 15, 15);
        self.fireIndicator.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:self.fireIndicator];
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, BUTTON_HEIGHT-15, 25, 10)];
        self.numberLabel.font = [UIFont boldSystemFontOfSize:14];
        self.numberLabel.textColor = [UIColor colorWithWhite:.3 alpha:1.0];
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.textAlignment = UITextAlignmentLeft;
        [self addSubview:self.numberLabel];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectInset(frame, 4, 4)];
        self.titleLabel.center = self.center;
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        self.titleLabel.numberOfLines = 3;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];

        UIGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:gr];
        
        self.userInteractionEnabled = YES;
                
    }
    return self;
}

- (void)setPreservedBackgroundColor:(UIColor *)preservedBackgroundColor {
    _preservedBackgroundColor = preservedBackgroundColor;
    self.layer.backgroundColor = preservedBackgroundColor.CGColor;
}

- (BOOL)on {
    return self.layer.borderWidth == 4.0;
}

- (void)setOn:(BOOL)on {
    if (on) {
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 4.0;
        if (self.selectedBackgroundColor) {
            self.layer.backgroundColor = self.selectedBackgroundColor.CGColor;
        }
    } else {
        self.layer.borderColor = [UIColor colorWithWhite:.5 alpha:1.0].CGColor;
        self.layer.borderWidth = 2.0;
        self.layer.backgroundColor = self.preservedBackgroundColor.CGColor;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}


- (void)tapped:(UITapGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateEnded) {
        NSLog(@"TAPPED! %d", self.patternNumber);
        if (self.isPreset) {
            [self.delegate presetTapped:self.patternNumber];
        } else {
            [self.delegate patternTapped:self.patternNumber];
        }
        self.on = YES;
        self.layer.backgroundColor = self.preservedBackgroundColor.CGColor;
    } else if (gr.state == UIGestureRecognizerStateCancelled) {
        self.on = NO;
    } else if (gr.state == UIGestureRecognizerStateBegan) {
        if (self.tappedBackgroundColor) {
            self.layer.backgroundColor = self.tappedBackgroundColor.CGColor;
        }
    } else if (gr.state == UIGestureRecognizerStateFailed) {
        self.on = NO;
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        self.backgroundColor = self.selectedBackgroundColor;
    } else {
        self.backgroundColor = self.preservedBackgroundColor;
    }    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, point)) {
        self.backgroundColor = self.selectedBackgroundColor;
    } else {
        self.backgroundColor = self.preservedBackgroundColor;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.backgroundColor = [self on] ? self.selectedBackgroundColor : self.preservedBackgroundColor;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [self on] ? self.selectedBackgroundColor : self.preservedBackgroundColor;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
