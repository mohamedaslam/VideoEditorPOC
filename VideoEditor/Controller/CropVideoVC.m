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
@interface CropVideoVC ()
    {
        UIView *videoPlayerBGView;
        UIButton *backbtn;
        UIButton *donebtn;
        UILabel *titleNamelabel;
        UIView *titleBarBGView;
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

@implementation CropVideoVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.tempVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmpMov.mov"];
    
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
    titleNamelabel.text = @"Crop Video";
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
   // NSURL *url = [NSURL URLWithString:_getSelectedURl];

    self.asset = [AVAsset assetWithURL:_getSelectedURl];
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [videoPlayerBGView.layer addSublayer:self.playerLayer];
    [self.player play];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [videoPlayerBGView addGestureRecognizer:tap];
    self.videoPlaybackPosition = 0;
  
    // Do any additional setup after loading the view.
}
- (void)viewDidLayoutSubviews
    {
        self.playerLayer.frame = CGRectMake(0, 0, videoPlayerBGView.frame.size.width, videoPlayerBGView.frame.size.height);
    }
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
