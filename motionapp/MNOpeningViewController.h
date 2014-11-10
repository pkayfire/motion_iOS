//
//  ViewController.h
//  motionapp
//
//  Created by Peter Kim on 11/8/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

@interface MNOpeningViewController : UIViewController

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;
@property (weak, nonatomic) IBOutlet UITextView *quoteTextView;

@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

@end

