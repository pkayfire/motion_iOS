//
//  MNVideo.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNVideo.h"
#import <Parse/PFObject+Subclass.h>

@implementation MNVideo

@dynamic MNVideoFile;
@dynamic byUser;

+ (void)load
{
    [self registerSubclass];
}

+ (NSString *)parseClassName
{
    return @"MNVideo";
}

@end
