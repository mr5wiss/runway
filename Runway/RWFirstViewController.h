//
//  RWFirstViewController.h
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWFirstViewController : UIViewController<UIPickerViewDelegate>
@property (nonatomic, strong) IBOutlet UIPickerView *patternPicker;
@property (nonatomic, strong) IBOutlet UIButton *allControlsButton;
@property (nonatomic, strong) IBOutlet UIButton *lightsButton;
@property (nonatomic, strong) IBOutlet UIButton *fireButton;
@property (nonatomic, strong) IBOutlet UISlider *tempoSlider;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *panGS;
@property (nonatomic, strong) IBOutlet UIPanGestureRecognizer *tapGS;

- (IBAction)controlButtonTapped:(id)sender;


@end
