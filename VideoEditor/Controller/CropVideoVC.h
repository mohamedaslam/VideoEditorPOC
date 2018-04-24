//
//  CropVideoVC.h
//  VideoEditor
//
//  Created by Mohammed Aslam on 23/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OLCVideoPlayer.h"

@interface CropVideoVC : UIViewController
@property(nonatomic,strong)NSURL *getSelectedURl;
//@property (weak, nonatomic) IBOutlet OLCVideoPlayer *vidplayer;

//@property (weak, nonatomic) IBOutlet UIProgressView *sldProgress;
//@property (weak, nonatomic) IBOutlet UILabel *lblCurrent;
//@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet UISlider *sldVolume;
//@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@end
