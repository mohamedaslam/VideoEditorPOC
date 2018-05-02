//
//  CropVideoVC.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 23/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "CropVideoVC.h"
#import "Masonry.h"
#import "TrimVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface CropVideoVC ()<OLCVideoPlayerDelegate>
    {
        UIButton *backbtn;
        UIButton *donebtn;
        UILabel *titleNamelabel;
        UIView *titleBarBGView;
        NSArray *playlist;
        NSURL *uploadedVideoPath;

    }
@property (strong, nonatomic) NSString *tempVideoPath;

    @property (assign, nonatomic) BOOL isPlaying;
    @property (strong, nonatomic)OLCVideoPlayer *vidplayer;
    @property (strong, nonatomic) UIProgressView *sldProgress;
    @property(strong,nonatomic) UIButton *btnPlayPause;
    @property (strong, nonatomic) UILabel *CurrentTimeLabel;
    @property (strong, nonatomic) UILabel *totalDurationLabel;
    @property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
    @property (assign, nonatomic) CGFloat videoPlaybackPosition;
    @property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;
    @property (weak, nonatomic) IBOutlet UIButton *trimButton;
//    @property (strong, nonatomic) NSString *tempVideoPath;

    @property (strong, nonatomic) AVAssetExportSession *exportSession;
    @property (strong, nonatomic) AVAsset *asset;
    @property (assign, nonatomic) CGFloat startTime;
    @property (assign, nonatomic) CGFloat stopTime;
    @property (assign, nonatomic) BOOL restartOnPlay;
@end

@implementation CropVideoVC
- (void)popNavigationController:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];

    [self.view setBackgroundColor:[UIColor blackColor]];
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setBackgroundImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    [backButton addTarget:self action:@selector(popNavigationController:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backButtonItem;
    //    ////////TitleBar BackGroundView
        titleBarBGView=[[UIView alloc]init];
        titleBarBGView.translatesAutoresizingMaskIntoConstraints = NO;
        [titleBarBGView setBackgroundColor:[UIColor blackColor]];
        [self.view addSubview:titleBarBGView];
        UIEdgeInsets padding = UIEdgeInsetsMake(20, 0, 0, 0);
        [titleBarBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset(padding.top);
            make.left.equalTo(self.view.mas_left).with.offset(padding.left);
            make.right.equalTo(self.view.mas_right).with.offset(-padding.right);
            make.height.equalTo(@(50));
        }];
    
    //    ////////Title Name label
        titleNamelabel = [UILabel new];
        titleNamelabel.backgroundColor = [UIColor clearColor];
        titleNamelabel.textAlignment = NSTextAlignmentCenter;
        titleNamelabel.textColor = [UIColor whiteColor];
        titleNamelabel.text = @"Crop Video";
        [titleBarBGView addSubview:titleNamelabel];
        UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
        [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
            make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
            make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
            make.height.equalTo(@(50));
        }];
    //    ////////////////BackButton
        backbtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backbtn addTarget:self action:@selector(backbtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [backbtn setBackgroundColor:[UIColor clearColor]];
        [backbtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
        [backbtn setExclusiveTouch:YES];
        [titleBarBGView addSubview:backbtn];
        [backbtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleBarBGView).with.offset(8);
            make.left.equalTo(titleBarBGView).with.offset(4);
            make.width.equalTo(@(30));
            make.height.equalTo(@(30));
        }];
       
   
    self.vidplayer = [[OLCVideoPlayer alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
 //   self.vidplayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 240);
    [self.vidplayer setBackgroundColor:[UIColor darkGrayColor]];
    self.vidplayer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.vidplayer];
    [self.vidplayer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(240));
    }];
    [self.vidplayer setDelegate:self];
    /////////
    UIView *progressbarBGView=[[UIView alloc]init];
    progressbarBGView.translatesAutoresizingMaskIntoConstraints = NO;
    [progressbarBGView setBackgroundColor:[UIColor blackColor]];
    [progressbarBGView setAlpha:0.6];
    [self.vidplayer addSubview:progressbarBGView];
    [progressbarBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.vidplayer.mas_bottom).with.offset(0);
        make.left.equalTo(self.vidplayer.mas_left).with.offset(0);
        make.right.equalTo(self.vidplayer.mas_right).with.offset(0);
        make.height.equalTo(@(60));
    }];
    ////////Play/Pause button
    self.btnPlayPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.btnPlayPause addTarget:self action:@selector(playpausebtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnPlayPause setBackgroundColor:[UIColor clearColor]];
    [self.btnPlayPause setImage:[UIImage imageNamed:@"playicon.png"] forState:UIControlStateNormal];
    [self.btnPlayPause setExclusiveTouch:YES];
    [progressbarBGView addSubview:self.btnPlayPause];
    [self.btnPlayPause mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(progressbarBGView).with.offset(10);
        make.left.equalTo(progressbarBGView).with.offset(4);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    self.sldProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.sldProgress.progressTintColor = [UIColor redColor];
    self.sldProgress.translatesAutoresizingMaskIntoConstraints = NO;
    [[self.sldProgress layer]setFrame:CGRectMake(0, 8, 280, 40)];
    self.sldProgress.trackTintColor = [UIColor whiteColor];
    [progressbarBGView addSubview:self.sldProgress];
        [self.sldProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(progressbarBGView);
        make.left.equalTo(progressbarBGView).with.offset(50);
        make.right.equalTo(progressbarBGView).with.offset(-6);
        make.height.equalTo(@(4));
    }];
    
    //    ////////totaltimelabel Name label
  self.totalDurationLabel = [UILabel new];
    self.totalDurationLabel.backgroundColor = [UIColor clearColor];
    self.totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    self.totalDurationLabel.textColor = [UIColor whiteColor];
    [self.totalDurationLabel setFont:[UIFont systemFontOfSize:12]];
    self.totalDurationLabel.text = @"00:00:00";
    self.totalDurationLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [progressbarBGView addSubview:self.totalDurationLabel];
    [self.totalDurationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-6);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];
    //    ////////     /totaltimelabel Name label
    UILabel *slaplabel = [UILabel new];
    slaplabel.backgroundColor = [UIColor clearColor];
    slaplabel.textAlignment = NSTextAlignmentCenter;
    slaplabel.textColor = [UIColor whiteColor];
    [slaplabel setFont:[UIFont systemFontOfSize:12]];
    slaplabel.text = @"/";
    slaplabel.translatesAutoresizingMaskIntoConstraints = NO;
    [progressbarBGView addSubview:slaplabel];
    [slaplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-66);
        make.width.equalTo(@(4));
        make.height.equalTo(@(20));
    }];
    
    //    ////////     /CUrrentrunningtimelabel  label
    self.CurrentTimeLabel = [UILabel new];
    self.CurrentTimeLabel.backgroundColor = [UIColor clearColor];
    self.CurrentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.CurrentTimeLabel.textColor = [UIColor whiteColor];
    [self.CurrentTimeLabel setFont:[UIFont systemFontOfSize:12]];
    self.CurrentTimeLabel.text = @"00:00:00";
    self.CurrentTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [progressbarBGView addSubview:self.CurrentTimeLabel];
    [self.CurrentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(progressbarBGView).with.offset(2);
        make.right.equalTo(progressbarBGView).with.offset(-78);
        make.width.equalTo(@(54));
        make.height.equalTo(@(20));
    }];
    // Do any additional setup after loading the view.
}
-(void) playpausebtn:(UIButton*)sender
{
    if([self.vidplayer isPlaying]){
        [self.vidplayer pause];
    }
    else{
        [self.vidplayer play];
    }
}
-(void) backbtnClicked:(UIButton*)sender
{
    TrimVideoVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TrimVideoVC"];
    VC.getSelectedVideoURL = _getfullSelectedURl;
    [self presentViewController:VC animated:YES completion:nil];
    
}
- (void) viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationClosing:) name:
     UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationOpening:) name:
     UIApplicationWillEnterForegroundNotification object:nil];
    //load our movie Asset
    AVAsset *asset = [AVAsset assetWithURL:_getSelectedURl];
    
    //create an avassetrack with our asset
    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    
    //create a video composition and preset some settings
    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    //here we are setting its render size to its height x height (Square)
    videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height-64);
    
    //create a video instruction
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30));
    
    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
    NSLog(@"%f",clipVideoTrack.naturalSize.height);
    NSLog(@"%f",clipVideoTrack.naturalSize.width);
    NSLog(@"clipVideoTrack.naturalSize.height");

    //Here we shift the viewing square up to the TOP of the video so we only see the top
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0 );
    t1.ty=0.0;
    //Use this code if you want the viewing square to be in the middle of the video
    //CGAffineTransform t1 = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, -(clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height) /2 );
    
    //Make sure the square is portrait
    CGAffineTransform t2 = CGAffineTransformRotate(t1, M_PI_2);
    
    CGAffineTransform finalTransform = t2;
    [transformer setTransform:finalTransform atTime:kCMTimeZero];
    
    //add the transformer layer instructions, then add to video composition
    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
    videoComposition.instructions = [NSArray arrayWithObject: instruction];
    
    //Create an Export Path to store the cropped video
    NSString * documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportPath = [documentsPath stringByAppendingFormat:@"/CroppedVideo.mp4"];
    NSURL *exportUrl = [NSURL fileURLWithPath:exportPath];
    
    //Remove any prevouis videos at that path
    [[NSFileManager defaultManager]  removeItemAtURL:exportUrl error:nil];
    
    //Export
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
    _exportSession.videoComposition = videoComposition;
    _exportSession.outputURL = exportUrl;
    _exportSession.outputFileType = AVFileTypeQuickTimeMovie;

    [_exportSession exportAsynchronouslyWithCompletionHandler:^
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             //Call when finished
             NSLog(@"%@", exportUrl);
             NSLog(@"exportUrl");
              UISaveVideoAtPathToSavedPhotosAlbum([exportUrl relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
            // uploadedVideoPath=[exportUrl absoluteString];
         });
     }];
    // output file
//    NSString* outputPath = <# your output path here #>;
//    if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath])
//        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
//    NSString* getoutputPath = _getSelectedURl;

//    // input file
//    AVAsset* asset = [AVAsset assetWithURL:_getSelectedURl];
//
//    AVMutableComposition *composition = [AVMutableComposition composition];
//    [composition  addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
//
//    // input clip
//    AVAssetTrack *clipVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
//    CGAffineTransform transform = clipVideoTrack.preferredTransform;
//
//    //get actual display size of video
//    CGSize videoSize;
//    if ((transform.a == 0 && transform.b == 1 && transform.c == -1 && transform.d == 0) // rotate 90
//        || (transform.a == 0 && transform.b == -1 && transform.c == 1 && transform.d == 0)) { // rotate -90
//        videoSize = CGSizeMake(clipVideoTrack.naturalSize.height,clipVideoTrack.naturalSize.width);
//    } else {
//        videoSize = clipVideoTrack.naturalSize;
//    }
//    CGFloat squareDimension = fminf(videoSize.width,videoSize.height);
//
//    // make render size square
//    AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoComposition];
//    videoComposition.renderSize = CGSizeMake(squareDimension,squareDimension);
//    videoComposition.frameDuration = CMTimeMake(1, 30);
//
//    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
//    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
//
//    // shift video to be in the center
//    AVMutableVideoCompositionLayerInstruction* transformer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:clipVideoTrack];
//    CGAffineTransform translation = CGAffineTransformMakeTranslation(- (videoSize.width - squareDimension)/2, -(videoSize.height - squareDimension) /2 );
//    CGAffineTransform finalTransform = CGAffineTransformConcat(transform, translation);
//
//    [transformer setTransform:finalTransform atTime:kCMTimeZero];
//    instruction.layerInstructions = [NSArray arrayWithObject:transformer];
//    videoComposition.instructions = [NSArray arrayWithObject: instruction];
//
//    // export
//    self.exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality] ;
//    self.exporter.videoComposition = videoComposition;
//    NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
////    self.exportSession.outputURL = furl;
//    self.exporter.outputURL = _getSelectedURl;
//    self.exporter.outputFileType=AVFileTypeQuickTimeMovie;
//
//    [self.exporter exportAsynchronouslyWithCompletionHandler:^(void){
//        switch(self.exporter.status) {
//            case AVAssetExportSessionStatusCompleted:
//                NSLog(@"file exported successfully");
//                break;
//            default:
//                NSLog(@"file did not export successfully");
//        }
//    }];
//    NSMutableArray *videos = [[NSMutableArray alloc] init];
//    NSMutableDictionary *video = nil;
//    video = [[NSMutableDictionary alloc] init];
//    [video setObject:outputPath forKey:OLCPlayerVideoURL];
//    [video setValue:@0 forKey:OLCPlayerPlayTime];
//    [videos addObject:video];
//    playlist = videos;
//    [self.vidplayer playVideos:playlist];
//    [self.vidplayer continusPlay:YES];
//    [self.vidplayer shuffleVideos:NO];
   
}
- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
//        CropVideoVC*VC = [self.storyboard instantiateViewControllerWithIdentifier:@"CropVideoVC"];
//        VC.getSelectedURl = movieUrl ;
//        VC.getfullSelectedURl = getSelectedVideoURL;
//        [self presentViewController:VC animated:YES completion:nil];
    }
}
- (void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   // [self.vidplayer setDelegate:nil];
    [self.vidplayer shutdown];
   // self.vidplayer = nil;
//    [self.vidplayer removeFromSuperview];
}
- (void)viewDidLayoutSubviews{

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - OLCVideoPlayer Delegates

- (void) onVideoTrackChanged:(NSUInteger)index
{
}

- (void) onFinishPlaying:(NSUInteger)index{
    
}

- (void) onPause:(NSUInteger)index
{
    [self.btnPlayPause setImage:[UIImage imageNamed:@"playicon.png"] forState:UIControlStateNormal];
}

- (void) onPlay:(NSUInteger)index
{
    [self.btnPlayPause setImage:[UIImage imageNamed:@"pauseicon.png"] forState:UIControlStateNormal];
}

//this get called every 0.5 seconds with video duration and current playtime so we can update our progress bars
- (void) onPlayInfoUpdate:(double)current withDuration:(double)duration
{
    float progress = ( current / duration );
    self.sldProgress.progress = progress;
    self.CurrentTimeLabel.text = [self stringFromSeconds:current];
    self.totalDurationLabel.text = [self stringFromSeconds:duration];
}

#pragma mark - notifications

- (void) applicationClosing:(NSNotification *)notification
{
    [self.vidplayer playInBackground];
}

- (void) applicationOpening:(NSNotification *)notification
{
    [self.vidplayer playInForeground];
}

#pragma mark - private

- (NSString *) stringFromSeconds:(double) value
{
    NSTimeInterval interval = value;
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
