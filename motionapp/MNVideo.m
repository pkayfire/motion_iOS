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

+ (BFTask *)createMNVideoWithData:(NSData *)videoData
{
    BFTaskCompletionSource *createMNVideoCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFFile *videoFile = [PFFile fileWithName:@"mnvideo.mp4" data:videoData];
    MNVideo *mnVideo = [[MNVideo alloc] init];
    
    [mnVideo setMNVideoFile:videoFile];
    [mnVideo setByUser:[MNUser currentUser]];
    
    [mnVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [createMNVideoCompletionSource setResult:[NSNumber numberWithBool:succeeded]];
        } else {
            [createMNVideoCompletionSource setError:error];
        }
    }];

    return createMNVideoCompletionSource.task;
}

@end
