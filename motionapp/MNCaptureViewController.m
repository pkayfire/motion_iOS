//
//  MNCaptureViewController.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MNCaptureViewController.h"
#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"

#define kVideoPreset AVCaptureSessionPresetHigh

@interface MNCaptureViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    UIImageView *_ghostImageView;
}

@end

@implementation MNCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    UIColor *motionRedLight = [UIColor colorWithRed:248.0/255.0f green:155.0/255.0f blue:144.0/255.0f alpha:1.0f];
    
    
    [self.reverseCameraButton setImage:[UIImage imageNamed:@"switch_camera_button_highlighted"] forState:UIControlStateHighlighted | UIControlStateSelected];
    [self.reverseCameraButton addTarget:self action:@selector(handleReverseCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    _recorder = [SCRecorder recorder];
    _recorder.sessionPreset = AVCaptureSessionPreset1280x720;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = NO;
    
    UIView *previewView = self.previewView;
    _recorder.previewView = previewView;
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSError *error = nil;
        NSLog(@"%@", error);
        
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
}

-(BOOL)prefersStatusBarHidden { return YES; }

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self prepareCamera];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_recorder startRunningSession];
    //[_recorder focusCenter];
}

#pragma mark - SCRecorder Methods

- (void) prepareCamera {
    if (_recorder.recordSession == nil) {
        
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(3, 10000);
        
        _recorder.recordSession = session;
    }
}

#pragma mark - UIButton Methods

- (void) handleReverseCameraTapped:(id)sender {
    [_recorder switchCaptureDevices];
}

- (IBAction)handleCaptureButton:(id)sender {
    NSLog(@"handleCaptureButton");
    [_recorder record];
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession
{
    _recorder.recordSession = nil;
    
    [recordSession endSession:^(NSError *error) {
        if (error == nil) {
            NSURL *fileUrl = recordSession.outputUrl;
            // Do something with the output file :)
            
            NSLog(@"%@", fileUrl);
        } else {
            // Handle the error
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
