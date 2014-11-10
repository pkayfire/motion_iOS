//
//  MNUIButton.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNUIButton.h"

@implementation MNUIButton

- (void) setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    UIColor *motionRed = [UIColor colorWithRed:245.0/255.0f green:110.0/255.0f blue:94.0/255.0f alpha:1.0f];
    
    if (highlighted) {
        self.tintColor = motionRed;
    }
    else {
        self.tintColor = motionRed;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
