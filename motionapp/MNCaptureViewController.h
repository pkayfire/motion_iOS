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

@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)handleCaptureButton:(id)sender;

@end
