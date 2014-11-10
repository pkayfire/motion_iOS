//
//  ViewController.m
//  motionapp
//
//  Created by Peter Kim on 11/8/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNOpeningViewController.h"

@interface MNOpeningViewController ()

@end

@implementation MNOpeningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    
    FLAnimatedImage *backgroundImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"subway_ios_2" ofType:@"gif"]]];
    self.backgroundImageView.animatedImage = backgroundImage;
    
    self.titleTextView.font = [UIFont fontWithName:@"VarelaRound" size:65.0f];
    self.subtitleTextView.font = [UIFont fontWithName:@"VarelaRound" size:14.0f];
    self.quoteTextView.font = [UIFont fontWithName:@"VarelaRound" size:10.0f];
    
    self.signUpButton.titleLabel.font = [UIFont fontWithName:@"VarelaRound" size:21.0f];
    [self.signUpButton.layer setBorderWidth:2.5f];
    [self.signUpButton.layer setBorderColor:[motionRed CGColor]];
    [self.signUpButton.layer setCornerRadius:5.0f];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
