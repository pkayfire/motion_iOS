//
//  MNCaptureViewController.h
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCRecorder.h"

@interface MNCaptureViewController : UIViewController<SCRecorderDelegate>

@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *timeRecordedLabel;
@property (weak, nonatomic) IBOutlet UIView *downBar;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraModeButton;

- (IBAction)switchCameraMode:(id)sender;

@end
