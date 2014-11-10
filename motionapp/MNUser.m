//
//  MNUser.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation MNUser

+ (void)load
{
    [self registerSubclass];
}

+ (BFTask *)createMNUser
{
    BFTaskCompletionSource *createMNUserCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    MNUser *mnUser = [[MNUser alloc] init];
    
    mnUser.username = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    mnUser.password = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [mnUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [createMNUserCompletionSource setResult:[NSNumber numberWithBool:succeeded]];
        } else {
            [createMNUserCompletionSource setError:error];
        }
    }];

    return createMNUserCompletionSource.task;
}

@end
