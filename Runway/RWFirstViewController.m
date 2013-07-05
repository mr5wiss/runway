//
//  RWFirstViewController.m
//  Runway
//
//  Created by Martin Rolf Reinfried on 6/29/13.
//  Copyright (c) 2013 Martin Rolf Reinfried. All rights reserved.
//

#import "RWFirstViewController.h"

@interface RWFirstViewController ()

@end

@implementation RWFirstViewController {
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
}
@synthesize patternPicker, allControlsButton, lightsButton, fireButton, tempoSlider, panGS, tapGS, topToolbar;

- (void)initNetworkCommunication {
    // remove when active
    return;
    
    // use pi server port here
    uint portNo = 5555;
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    // use pi server ip here
    CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"227.3.4.56", portNo, &readStream, &writeStream);
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
    
    [inputStream setDelegate:self];
    [outputStream setDelegate:self];
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self initNetworkCommunication];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)controlButtonTapped:(id)sender {
    // change images based on which controls are active
   
    // coopting this for the moment for testing of socket server
    NSString *dataString  = @"Hello World!";
    NSData *data = [[NSData alloc] initWithData:[dataString dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // respond to pattern choice
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    uint8_t buffer[1024];
    int len;
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"Stream opened now");
            break;
        case NSStreamEventHasBytesAvailable:
            NSLog(@"has bytes");
            if (theStream == inputStream) {
                while ([inputStream hasBytesAvailable]) {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0) {
                        
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output) {
                            NSLog(@"server said: %@", output);
                        }
                    }
                }
            } else {
                NSLog(@"it is NOT theStream == inputStream");
            }
            break;
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"Stream has space available now");
            break;
            
            
        case NSStreamEventErrorOccurred:
            NSLog(@"Can not connect to the host!");
            break;
            
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            break;
            
        default:
            NSLog(@"Unknown event %i", streamEvent);
    }
    
}

@end
