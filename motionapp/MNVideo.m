//
//  MNVideo.m
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import "MNVideo.h"
#import <Parse/PFObject+Subclass.h>
#import <AVFoundation/AVFoundation.h>

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

+ (BFTask *)getAllMNVideosAsOneVideo
{
    BFTaskCompletionSource *getAllMNVideosCompletionSource = [BFTaskCompletionSource taskCompletionSource];
    
    PFQuery *mnVideoQuery = [PFQuery queryWithClassName:@"MNVideo"];
    [[mnVideoQuery findObjectsInBackground] continueWithBlock:^id(BFTask *task) {
        if (task.error) {
            [getAllMNVideosCompletionSource setError:task.error];
        }
        
        NSArray *mnVideoObjects = task.result;
        NSMutableArray *getMNVideoFilesTasks = [[NSMutableArray alloc] init];
        
        for (MNVideo *video in mnVideoObjects) {
            [getMNVideoFilesTasks addObject:[[video MNVideoFile] getDataInBackground]];
        }
        
        [[BFTask taskForCompletionOfAllTasks:getMNVideoFilesTasks] continueWithBlock:^id(BFTask *task) {
            NSMutableArray *videoAssets = [[NSMutableArray alloc] init];
            for (int i = 0; i < getMNVideoFilesTasks.count; i++) {
                NSData *videoFileData = [getMNVideoFilesTasks[i] result];
                NSURL *tempDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", @"tempVideoFile", [self getRandomString]];
                NSURL *videoFileURL = [[tempDirURL URLByAppendingPathComponent:uniqueFileName]URLByAppendingPathExtension:@"mp4"];
                
                [videoFileData writeToURL:videoFileURL options:NSAtomicWrite error:nil];
                AVAsset *videoAsset = [AVAsset assetWithURL:videoFileURL];
                [videoAssets addObject:videoAsset];
            }
            [getAllMNVideosCompletionSource setResult:videoAssets];
            return nil;
        }];
        
        return nil;
    }];
    
    return getAllMNVideosCompletionSource.task;
}

+ (NSString *)getRandomString
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

@end
