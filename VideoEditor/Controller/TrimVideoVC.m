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
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
@interface TrimVideoVC (){
    UIView *videoPlayerBGView;
    UIButton *backbtn;
    UIButton *donebtn;
    UILabel *titleNamelabel;
    UIView *titleBarBGView;
}
@end

@implementation TrimVideoVC
@synthesize getSelectedVideoURL;
- (void)viewDidLoad {
    [super viewDidLoad];
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
    
    //VideoPlayer
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:getSelectedVideoURL];
    AVPlayer* player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *layer = [AVPlayerLayer layer];
    [layer setPlayer:player];
    [layer setFrame:CGRectMake(0, 0, self.view.frame.size.width, 240)];
     [layer setBackgroundColor:[UIColor redColor].CGColor];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPlayerBGView.layer addSublayer:layer];
    [player play];
    // Do any additional setup after loading the view.
}
-(void) backbtnClicked:(UIButton*)sender
{
    ViewController *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
    [self presentViewController:VC animated:YES completion:nil];
    
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
