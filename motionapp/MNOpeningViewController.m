//
//  ViewController.m
//  motionapp
//
//  Created by Peter Kim on 11/8/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNOpeningViewController.h"
#import "MNUser.h"

#import "CWStatusBarNotification.h"

@interface MNOpeningViewController () {
    CWStatusBarNotification *_statusBarNotification;
}

@end

@implementation MNOpeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    
    _statusBarNotification = [CWStatusBarNotification new];
    _statusBarNotification.notificationLabelBackgroundColor = motionRed;
    _statusBarNotification.notificationLabelTextColor = [UIColor whiteColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_statusBarNotification displayNotificationWithMessage:@"Welcome to Motion!" completion:nil];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_statusBarNotification dismissNotification];
    });
    
    FLAnimatedImage *backgroundImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"subway_ios" ofType:@"gif"]]];
    self.backgroundImageView.animatedImage = backgroundImage;
    
    self.titleTextView.font = [UIFont fontWithName:@"VarelaRound" size:65.0f];
    self.subtitleTextView.font = [UIFont fontWithName:@"VarelaRound" size:14.0f];
    self.quoteTextView.font = [UIFont fontWithName:@"VarelaRound" size:10.0f];
    
    self.signUpButton.titleLabel.font = [UIFont fontWithName:@"VarelaRound" size:21.0f];
    [self.signUpButton.layer setBorderWidth:2.5f];
    [self.signUpButton.layer setBorderColor:[motionRed CGColor]];
    [self.signUpButton.layer setCornerRadius:5.0f];
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    
    
    visualEffectView.frame = self.view.bounds;
    
    [self.backgroundImageView addSubview:visualEffectView];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSignUpButton:(id)sender {
    [_statusBarNotification displayNotificationWithMessage:@"Signing Up..." completion:nil];

    [[MNUser createMNUser] continueWithBlock:^id(BFTask *task) {
        if (!task.error) {
            [_statusBarNotification dismissNotification];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.25 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        } else {
            [_statusBarNotification dismissNotification];
            [_statusBarNotification displayNotificationWithMessage:@"An error occurred! Please try again." completion:nil];
        }
        return nil;
    }];
}

@end
