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
    [mnVideoQuery whereKey:@"createdAt" greaterThan:[[NSDate date] dateByAddingTimeInterval:-3.5*24*60*60]];
    
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
            AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
            
            AVMutableCompositionTrack *mutableCompVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            AVMutableCompositionTrack *mutableCompAudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            
            CMTime currentCMTime = kCMTimeZero;
            
            for (int i = 0; i < getMNVideoFilesTasks.count; i++) {
                NSData *videoFileData = [getMNVideoFilesTasks[i] result];
                NSURL *randomVideoFileURL = [self getRandomVideoFileURL];
                
                [videoFileData writeToURL:randomVideoFileURL options:NSAtomicWrite error:nil];
                AVAsset *videoAsset = [AVAsset assetWithURL:randomVideoFileURL];
        
                [mutableCompVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:currentCMTime error:nil];
                [mutableCompAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:currentCMTime error:nil];
                
                currentCMTime = CMTimeAdd(currentCMTime, videoAsset.duration);
            }
            
            NSURL *randomFinalVideoFileURL = [self getRandomVideoFileURL];
            AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPreset640x480];
            exportSession.outputFileType=AVFileTypeQuickTimeMovie;
            exportSession.outputURL = randomFinalVideoFileURL;
            
            CMTimeValue val = mixComposition.duration.value;
            CMTime start = CMTimeMake(0, 1);
            CMTime duration = CMTimeMake(val, 1);
            CMTimeRange range = CMTimeRangeMake(start, duration);
            exportSession.timeRange = range;
            
            [exportSession exportAsynchronouslyWithCompletionHandler:^{
                switch ([exportSession status]) {
                    case AVAssetExportSessionStatusFailed:
                    {
                        NSLog(@"Export failed: %@ %@", [[exportSession error] localizedDescription],[[exportSession error]debugDescription]);
                    }
                    case AVAssetExportSessionStatusCancelled:
                    {
                        NSLog(@"Export canceled");
                        break;
                    }
                    case AVAssetExportSessionStatusCompleted:
                    {
                        NSLog(@"Export complete!");
                        [getAllMNVideosCompletionSource setResult:exportSession.outputURL];
                    }
                    default:
                    {
                        NSLog(@"default");
                    }
                }
            }];
            
            return nil;
        }];
        
        return nil;
    }];
    
    return getAllMNVideosCompletionSource.task;
}

+ (NSURL *)getRandomVideoFileURL
{
    NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0; i < 20; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    NSURL *tempDirURL = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSString *uniqueFileName = [NSString stringWithFormat:@"%@_%@", @"tempVideoFile", s];
    NSURL *videoFileURL = [[tempDirURL URLByAppendingPathComponent:uniqueFileName]URLByAppendingPathExtension:@"mp4"];
    
    return videoFileURL;
}

@end
