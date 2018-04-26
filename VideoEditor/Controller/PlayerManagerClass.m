//
//  PlayerManagerClass.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 26/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "PlayerManagerClass.h"

@implementation PlayerManagerClass
@synthesize someProperty,vidplayer;
#pragma mark Singleton Methods

+ (id)sharedManager {
    static PlayerManagerClass *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
        vidplayer = [[OLCVideoPlayer alloc]init];
    }
    return self;
}

@end
