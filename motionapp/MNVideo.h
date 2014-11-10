//
//  MNVideo.h
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

#import "MNUser.h"

@interface MNVideo : PFObject<PFSubclassing>

+ (NSString *)parseClassName;

@property PFFile *MNVideoFile;
@property MNUser *byUser;

@end
