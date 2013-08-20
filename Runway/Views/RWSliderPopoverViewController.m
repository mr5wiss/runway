//
//  RWSliderPopoverViewController.m
//  Runway
//
//  Created by Arshad Tayyeb on 8/19/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWSliderPopoverViewController.h"

@interface RWSliderPopoverViewController ()
@property (nonatomic, strong) NSMutableArray *tickSubviews;
@end

@implementation RWSliderPopoverViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self layoutTicks];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setDescreteValues:(NSArray *)descreteValues {
    _descreteValues = descreteValues;
    [self layoutTicks];
}
#pragma mark -



- (void)setTandemSlider:(UISlider *)tandemSlider {
    _tandemSlider = tandemSlider;
    if (tandemSlider != nil) {
        NSInteger index = [self indexOfClosestDescreteValueToValue:tandemSlider.value];
        CGFloat snappedValue = [[[self descreteValues] objectAtIndex:index] floatValue];
        _currentValue = snappedValue;
        self.currentValueLabel.text = [self formattedStringForFloat:snappedValue];

        self.slider.value = ((CGFloat)index)/((CGFloat)[self descreteValues].count-1) ;
    
    }
}

#pragma mark -
- (NSString *)formattedStringForFloat:(CGFloat)f {
    
    NSString *labelString = [NSString stringWithFormat:@"%.2f", f];
    
    if (f >= 1.0) {
        labelString = [NSString stringWithFormat:@"%.1f", f];
    }
    return labelString;
}

- (NSInteger)indexOfClosestDescreteValueToValue:(CGFloat)value {
    
    CGFloat bestDiffrence = CGFLOAT_MAX;
    
    NSNumber *bestValue = nil;
    
    for (NSNumber *indexedValue in [self descreteValues]) {
        CGFloat thisDifference = value - [indexedValue floatValue];
        
        if (thisDifference  < 0) {
            thisDifference = -thisDifference;
        }
        
        if (thisDifference < bestDiffrence) {
            bestDiffrence = thisDifference;
            bestValue = indexedValue;
        }
    }
    return [[self descreteValues] indexOfObject:bestValue];
}

- (void)setCurrentValue:(CGFloat)value {
  
    //find the index closest to this value
    int closestIndex = [self indexOfClosestDescreteValueToValue:value];
    CGFloat snappedValue = [[[self descreteValues] objectAtIndex:closestIndex] floatValue];
    
    self.slider.value = ((CGFloat)closestIndex)/((CGFloat)[self descreteValues].count-1) ;

    if (snappedValue == _currentValue) {
        return;
    }
    _currentValue = snappedValue;
    self.currentValueLabel.text = [self formattedStringForFloat:snappedValue];
    self.tandemValueLabel.text = self.currentValueLabel.text;
    NSLog(@"Telling Delegate: %f", snappedValue);
    self.tandemSlider.value = snappedValue;
    
    [self.delegate sliderValueChanged:self];

}

#pragma mark -
- (void)layoutTicks {
    CGFloat xInterval = (self.slider.frame.size.width - 26) / ([self descreteValues].count-1);
    
    CGFloat xPos = self.view.frame.origin.x + 26;
    CGFloat lineHeight = self.view.frame.size.height * .5;
    CGFloat yPos = self.view.center.y;
    
    CGFloat minValue = CGFLOAT_MAX;
    CGFloat maxValue = 0;
    
    if (self.tickSubviews) {
        for (UIView *v in self.tickSubviews) {
            [v removeFromSuperview];
        }
        [self.tickSubviews removeAllObjects];
    } else {
        self.tickSubviews = [NSMutableArray arrayWithCapacity:30];
    }
    
    for (NSNumber *value in [self descreteValues]) {
        
        if ([value floatValue] < minValue) {
            minValue = [value floatValue];
        }
        
        if ([value floatValue] > maxValue) {
            maxValue = [value floatValue];
        }
        
        UIView *newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, lineHeight)];
        newView.center = CGPointMake(xPos, yPos);
        newView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
        [self.view addSubview:newView];
        
        UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
        labelView.font = [UIFont boldSystemFontOfSize:10];
        labelView.textAlignment = UITextAlignmentCenter;
        labelView.textColor = [UIColor colorWithWhite:.2 alpha:1.0];
        
        NSString *labelString = [self formattedStringForFloat:[value floatValue]];
        
        labelView.text = labelString;
        labelView.center = CGPointMake(xPos, self.slider.center.y + 20);
        [self.view addSubview:labelView];
        xPos += xInterval;
        
        [self.tickSubviews addObject:newView];
        [self.tickSubviews addObject:labelView];
        
        
        [self.view bringSubviewToFront:self.slider];
    }
}


- (void)viewDidUnload {
    [self setSlider:nil];
    [self setCurrentValueLabel:nil];
    [super viewDidUnload];
}

- (CGFloat)snappedSliderValueForSliderValue:(CGFloat)sliderValue {
    //slidervalue is the range 0..1
    
    int closestIndex = (int)(([self descreteValues].count-1) * sliderValue);
//    NSLog(@"Closest Value: %d", closestIndex);

    return [[[self descreteValues] objectAtIndex:closestIndex] floatValue];
    
}

- (IBAction)valueChanged:(id)sender {
    CGFloat snappedValue = [self snappedSliderValueForSliderValue:self.slider.value];
    [self setCurrentValue:snappedValue];
}

- (IBAction)fingerUp:(id)sender {
}


@end
