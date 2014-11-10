//
//  MNCaptureViewController.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MNCaptureViewController.h"
#import "MNVideo.h"

#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"

#import "CWStatusBarNotification.h"

#define kVideoPreset AVCaptureSessionPresetHigh

@interface MNCaptureViewController () {
    SCRecorder *_recorder;
    UIImage *_photo;
    SCRecordSession *_recordSession;
    
    CWStatusBarNotification *_statusBarNotification;
    UIVisualEffectView *_visualEffectView;
}

@end

@implementation MNCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    //UIColor *motionRedLight = [UIColor colorWithRed:248.0/255.0f green:155.0/255.0f blue:144.0/255.0f alpha:1.0f];
    
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = motionRed;
    _statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
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
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = self.view.bounds;
    [self.previewView addSubview:_visualEffectView];
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
    if (!_recorder.recordSession) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(3, 10000);
        _recorder.recordSession = session;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_statusBarNotification displayNotificationWithMessage:@"Recording Motion... 3 Seconds Remaining" completion:nil];
    });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _statusBarNotification.notificationLabel.text = @"2 Seconds Remaining";
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        _statusBarNotification.notificationLabel.text = @"1 Second Remaining";
    });
    
    [_recorder record];
}

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession
{
    _recorder.recordSession = nil;
    _statusBarNotification.notificationLabel.text = @"Saving Motion...";
    
    [recordSession endSession:^(NSError *error) {
        if (error == nil) {
            NSURL *fileUrl = recordSession.outputUrl;
            [[MNVideo createMNVideoWithData:[NSData dataWithContentsOfURL:fileUrl]] continueWithBlock:^id(BFTask *task) {
                if (!task.error) {
                    _statusBarNotification.notificationLabel.text = @"Motion Saved!";
                } else {
                    _statusBarNotification.notificationLabel.text = @"An error occured! Please try again.";
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [_statusBarNotification dismissNotification];
                });
                return nil;
            }];
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
