//
//  MNUser.h
//  motionapp
//
//  Created by Peter Kim on 11/9/14.
//  Copyright (c) 2014 Motion. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface MNUser : PFUser<PFSubclassing>

+ (BFTask *)createMNUser;

@end
