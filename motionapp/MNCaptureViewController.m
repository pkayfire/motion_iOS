//
//  MNCaptureViewController.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "MNCaptureViewController.h"
#import "MNCaptureViewController+Animations.h"

#import "MNOpeningViewController.h"

#import "MNVideo.h"

#import "SCAudioTools.h"
#import "SCRecorderFocusView.h"

#import "CWStatusBarNotification.h"

#define kVideoPreset AVCaptureSessionPresetHigh

@interface MNCaptureViewController () {
    SCRecorder *_recorder;
    UIView *_recorderPreviewView;
    SCRecordSession *_recordSession;
    
    CWStatusBarNotification *_statusBarNotification;
    
    PBJVideoPlayerController *_videoPlayerController;
    UIButton *_videoPlayerControllerExitButton;

    NSURL *_videoPath;
    
    BOOL _inPlaybackMode;
}

@end

@implementation MNCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = motionRed;
    _statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
    [self.reverseCameraButton setAlpha:0.0f];
    
    _inPlaybackMode = YES;
    
    [self initVideoPlayer];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_recorder previewViewFrameChanged];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
}

#pragma mark - VideoPlayer Methods

- (void)initVideoPlayer
{
    [_statusBarNotification displayNotificationWithMessage:@"Motioning..." completion:nil];
    [[MNVideo getAllMNVideosAsOneVideo] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            return nil;
        }
        
        NSURL *mergedVideoURL = (NSURL *) task.result;
        [self prepareVideoPlayerWithVideoURL:mergedVideoURL];
        
        return nil;
    }];
}

#pragma mark - SCRecorder Methods

- (void)setUpCamera
{
    if (!_recorder) {
        _recorder = [SCRecorder recorder];
    }
    _recorder.sessionPreset = AVCaptureSessionPreset352x288;
    _recorder.audioEnabled = YES;
    _recorder.delegate = self;
    _recorder.autoSetVideoOrientation = NO;
    
    // On iOS 8 and iPhone 5S, enabling this seems to be slow
    _recorder.initializeRecordSessionLazily = NO;
    
    if (!_recorderPreviewView) {
       _recorderPreviewView = [[UIView alloc] initWithFrame:self.playbackView.frame];
    }
    _recorder.previewView = _recorderPreviewView;
    
    [_recorder openSession:^(NSError *sessionError, NSError *audioError, NSError *videoError, NSError *photoError) {
        NSLog(@"==== Opened session ====");
        NSLog(@"Session error: %@", sessionError.description);
        NSLog(@"Audio error : %@", audioError.description);
        NSLog(@"Video error: %@", videoError.description);
        NSLog(@"Photo error: %@", photoError.description);
        NSLog(@"=======================");
        [self prepareCamera];
    }];
    
//    UIVisualEffect *blurEffect;
//    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    
//    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//    _visualEffectView.frame = self.view.bounds;
//    _visualEffectView.alpha = 1.0f;
//    [_recorder.previewView addSubview:_visualEffectView];
    
    [self.playbackView insertSubview:_recorderPreviewView aboveSubview:_videoPlayerController.view];
}

- (void)prepareCamera
{
    if (_recorder.recordSession == nil) {
        SCRecordSession *session = [SCRecordSession recordSession];
        session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(2, 10000);
        _recorder.recordSession = session;
    }
    [_videoPlayerController pause];
    _inPlaybackMode = NO;
    [_recorder startRunningSession];
    [self showCaptureButtons];
}

- (void)cleanUpCamera
{
    [_recorder closeSession];
    [_recorderPreviewView removeFromSuperview];
    _inPlaybackMode = YES;
    [_videoPlayerController playFromCurrentTime];
}

#pragma mark - SCRecorder Delegate Methods

- (void)recorder:(SCRecorder *)recorder didCompleteRecordSession:(SCRecordSession *)recordSession
{
    _recorder.recordSession = nil;
    [recordSession endSession:^(NSError *error) {
        if (error == nil) {
            NSURL *fileUrl = recordSession.outputUrl;
            _videoPath = fileUrl;
            
            [self cleanUpCamera];
            [self showPlaybackButtons];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_statusBarNotification displayNotificationWithMessage:@"Saving Motion..." completion:nil];
                
                [[MNVideo createMNVideoWithData:[NSData dataWithContentsOfURL:fileUrl]] continueWithBlock:^id(BFTask *task) {
                    if (!task.error) {
                        _statusBarNotification.notificationLabel.text = @"Motion Saved!";
                    } else {
                        _statusBarNotification.notificationLabel.text = @"An error occured! Please try again.";
                    }
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        [_statusBarNotification dismissNotification];
                        [self initVideoPlayer];
                    });
                    
                    return nil;
                }];
            });
            
        } else {
            _statusBarNotification.notificationLabel.text = @"An error occured! Please try again.";
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [_statusBarNotification dismissNotification];
            });
        }
    }];
}

#pragma mark - PBJVideoPlayerControllerDelegate

- (void)prepareVideoPlayerWithVideoURL:(NSURL *)videoURL
{
    _inPlaybackMode = YES;
    
    // allocate controller
    if (!_videoPlayerController) {
        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    }
    _videoPlayerController.delegate = self;
    _videoPlayerController.view.frame = self.view.bounds;
    
    // setup media
    _videoPlayerController.videoPath = [videoURL absoluteString];
    _videoPlayerController.videoFillMode = AVLayerVideoGravityResizeAspectFill;
    [_videoPlayerController setPlaybackLoops:YES];
}

- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer
{
    NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
    [self addChildViewController:_videoPlayerController];
    
    [self.playbackView insertSubview:_videoPlayerController.view atIndex:0];
    [_videoPlayerController didMoveToParentViewController:self];
    [_videoPlayerController playFromBeginning];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hideBlurBackground];
        [_statusBarNotification dismissNotification];
    });
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer
{
    
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer
{

}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer
{
    
}

#pragma mark - UIButton Methods

- (IBAction)handleCaptureButton:(id)sender
{
    if (_inPlaybackMode) {
        [self setUpCamera];
    } else {
        if (!_recorder.recordSession) {
            SCRecordSession *session = [SCRecordSession recordSession];
            session.suggestedMaxRecordDuration = CMTimeMakeWithSeconds(2, 10000);
            _recorder.recordSession = session;
        }
        
        [self hideButtons];
        [_recorder record];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_statusBarNotification displayNotificationWithMessage:@"Recording Motion..." completion:nil];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _statusBarNotification.notificationLabel.text = @"1 Second Remaining";
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2.0 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [_statusBarNotification dismissNotification];
        });
    }
}

- (IBAction)handleExitButton:(id)sender
{
    if (_inPlaybackMode) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MNOpeningViewController *openingVC = [sb instantiateViewControllerWithIdentifier:@"MNOpeningViewController"];
        [self presentViewController:openingVC animated:YES completion:nil];
    } else {
        [self cleanUpCamera];
        [self showPlaybackButtons];
    }
}

- (IBAction)handleSwitchCameraButton:(id)sender {
    if (!_inPlaybackMode) {
        [_recorder switchCaptureDevices];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
