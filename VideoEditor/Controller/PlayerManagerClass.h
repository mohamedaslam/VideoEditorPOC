//
//  PlayerManagerClass.h
//  VideoEditor
//
//  Created by Mohammed Aslam on 26/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLCVideoPlayer.h"

@interface PlayerManagerClass : NSObject
{
    NSString *someProperty;
    OLCVideoPlayer *vidplayer;

}
@property (strong, nonatomic)OLCVideoPlayer *vidplayer;

@property (nonatomic, retain) NSString *someProperty;
+ (id)sharedManager;

@end
