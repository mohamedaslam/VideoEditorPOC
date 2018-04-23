//
//  TrimVideoVC.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 18/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "TrimVideoVC.h"
#import "Masonry.h"
#import "ViewController.h"
#import "CropVideoVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface TrimVideoVC ()<ICGVideoTrimmerDelegate>
{
    UIView *videoPlayerBGView;
    UIButton *backbtn;
    UIButton *donebtn;
    UILabel *titleNamelabel;
    UIView *titleBarBGView;
    NSURL *movieUrl;
   // ICGVideoTrimmerView *trimmerView;
}
@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;
@property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;
@property (weak, nonatomic) IBOutlet UIButton *trimButton;
@property (strong, nonatomic) NSString *tempVideoPath;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;
@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;
@property (assign, nonatomic) BOOL restartOnPlay;
@end

@implementation TrimVideoVC
@synthesize getSelectedVideoURL;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];

    [self.view setBackgroundColor:[UIColor blackColor]];
    ////////TitleBar BackGroundView
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
    
    ////////Title Name label
    titleNamelabel = [UILabel new];
    titleNamelabel.backgroundColor = [UIColor clearColor];
    titleNamelabel.textAlignment = NSTextAlignmentCenter;
    titleNamelabel.textColor = [UIColor whiteColor];
    titleNamelabel.text = @"Time Cut";
    [titleBarBGView addSubview:titleNamelabel];
    UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
        make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
        make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
        make.height.equalTo(@(50));
    }];
    ////////////////BackButton
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
    ///////////DoneButton
    donebtn = [UIButton new];
    donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [donebtn setBackgroundColor:[UIColor clearColor]];
    donebtn.translatesAutoresizingMaskIntoConstraints = NO;
    [donebtn setImage:[UIImage imageNamed:@"doneimg.png"] forState:UIControlStateNormal];
    [donebtn setExclusiveTouch:YES];
    [titleBarBGView addSubview:donebtn];
    [donebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(4);
        make.right.equalTo(titleBarBGView).with.offset(-10);
        make.height.equalTo(@(40));
        make.width.equalTo(@(40));
    }];
    /////////// VIdeoPlayer Background VIeww/////////////
    videoPlayerBGView=[[UIView alloc]init];
    [videoPlayerBGView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:videoPlayerBGView];
    [videoPlayerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(240));
        make.width.equalTo(@(self.view.frame.size.width));
    }];
    self.asset = [AVAsset assetWithURL:getSelectedVideoURL];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [videoPlayerBGView.layer addSublayer:self.playerLayer];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [videoPlayerBGView addGestureRecognizer:tap];
    self.videoPlaybackPosition = 0;
    [self tapOnVideoLayer:tap];
    /////////// VIdeoPlayer Background VIeww/////////////
    self.trimmerView = [[ICGVideoTrimmerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 120, self.view.frame.size.width, 120) asset:self.asset];
    [self.trimmerView setBackgroundColor:[UIColor redColor]];
    // set properties for trimmer view
    [self.trimmerView setThemeColor:[UIColor lightGrayColor]];
   //[self.trimmerView setAsset:self.asset];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setRulerLabelInterval:10];
    [self.trimmerView setTrackerColor:[UIColor cyanColor]];
    [self.trimmerView setDelegate:self];
    [self.trimButton setHidden:NO];
    [self.view addSubview:self.trimmerView];
//    [self.trimmerView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.view).with.offset(0);
//        make.left.equalTo(self.view).with.offset(10);
//        make.right.equalTo(self.view).with.offset(10);
//
//        make.height.equalTo(@(120));
//    }];
    //important: reset subviews
    [self.trimmerView resetSubviews];
    // Do any additional setup after loading the view.
}
-(void) backbtnClicked:(UIButton*)sender
{
    ViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:VC animated:YES completion:nil];
    
}
-(void) buttonClicked:(UIButton*)sender
{
    [self deleteTempFile];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:self.asset];
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        self.exportSession = [[AVAssetExportSession alloc]
                              initWithAsset:self.asset presetName:AVAssetExportPresetPassthrough];
        // Implementation continues.
        NSURL *furl = [NSURL fileURLWithPath:self.tempVideoPath];
        self.exportSession.outputURL = furl;
        self.exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        CMTime start = CMTimeMakeWithSeconds(self.startTime, self.asset.duration.timescale);
        CMTime duration = CMTimeMakeWithSeconds(self.stopTime - self.startTime, self.asset.duration.timescale);
        CMTimeRange range = CMTimeRangeMake(start, duration);
        self.exportSession.timeRange = range;
        [self.exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([self.exportSession status]) {
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"Export failed: %@", [[self.exportSession error] localizedDescription]);
                    break;
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"Export canceled");
                    break;
                default:
                    NSLog(@"NONE");
                    dispatch_async(dispatch_get_main_queue(), ^{
                       movieUrl = [NSURL fileURLWithPath:self.tempVideoPath];
                        NSLog(@"asdfasdfasfd%@", [movieUrl relativePath]);
                        UISaveVideoAtPathToSavedPhotosAlbum([movieUrl relativePath], self,@selector(video:didFinishSavingWithError:contextInfo:), nil);
                    });
                    break;
            }
        }];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - ICGVideoTrimmerDelegate

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    _restartOnPlay = YES;
    [self.player pause];
    self.isPlaying = NO;
    [self stopPlaybackTimeChecker];
    [self.trimmerView hideTracker:true];
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    else{ // right has changed
        [self seekVideoToPos:endTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
    
}
#pragma mark - Actions
- (void)deleteTempFile
{
    NSURL *url = [NSURL fileURLWithPath:self.tempVideoPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL exist = [fm fileExistsAtPath:url.path];
    NSError *err;
    if (exist) {
        [fm removeItemAtURL:url error:&err];
        NSLog(@"file deleted");
        if (err) {
            NSLog(@"file remove error, %@", err.localizedDescription );
        }
    } else {
        NSLog(@"no file by that name");
    }
}

- (IBAction)selectAsset:(id)sender
{
    UIImagePickerController *myImagePickerController = [[UIImagePickerController alloc] init];
    myImagePickerController.sourceType =  UIImagePickerControllerSourceTypePhotoLibrary;
    myImagePickerController.mediaTypes =
    [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    myImagePickerController.delegate = self;
    myImagePickerController.editing = NO;
    [self presentViewController:myImagePickerController animated:YES completion:nil];
}


- (void)video:(NSString*)videoPath didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        CropVideoVC*VC = [self.storyboard instantiateViewControllerWithIdentifier:@"CropVideoVC"];
        VC.getSelectedURl = movieUrl ;
        [self presentViewController:VC animated:YES completion:nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
//                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
    }
}

- (void)viewDidLayoutSubviews
{
    self.playerLayer.frame = CGRectMake(0, 0, videoPlayerBGView.frame.size.width, videoPlayerBGView.frame.size.height);
}

- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
    }else {
        if (_restartOnPlay){
            [self seekVideoToPos: self.startTime];
            [self.trimmerView seekToTime:self.startTime];
            _restartOnPlay = NO;
        }
        [self.player play];
        [self startPlaybackTimeChecker];
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

#pragma mark - PlaybackTimeCheckerTimer

- (void)onPlaybackTimeCheckerTimer
{
    CMTime curTime = [self.player currentTime];
    Float64 seconds = CMTimeGetSeconds(curTime);
    if (seconds < 0){
        seconds = 0; // this happens! dont know why.
    }
    self.videoPlaybackPosition = seconds;
    [self.trimmerView seekToTime:seconds];
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [self.trimmerView seekToTime:self.startTime];
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];

    [self.player pause];
    
    [self.playerLayer removeFromSuperlayer];
    self.playerLayer = nil;
    
}
- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    //NSLog(@"seekVideoToPos time:%.2f", CMTimeGetSeconds(time));
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
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
