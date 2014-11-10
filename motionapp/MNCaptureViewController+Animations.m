//
//  MNCaptureViewController+Animations.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNCaptureViewController+Animations.h"

@implementation MNCaptureViewController (Animations)

- (void)showBlurBackground
{
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.visualEffectView.alpha = 0.0f;
                     } completion:nil];
}

- (void)hideBlurBackground
{
    [UIView animateWithDuration:1.0f
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.visualEffectView.alpha = 0.0f;
                     } completion:nil];
}

@end
