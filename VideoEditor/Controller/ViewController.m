//
//  ViewController.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 16/04/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "ViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AssetBrowserItem.h"
#import <QuartzCore/QuartzCore.h>
#import "ListCollectionViewCell.h"
#import "Masonry.h"
#import "TrimVideoVC.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    UIView *titleBarBGView;
    UIView *videoPlayerBGView;
    UIButton *uparrowbtn;
    UIButton *donebtn;
    UIButton *playbtn;
    UIButton *pausebtn;
    UIButton *stopbtn;
    UILabel *titleNamelabel;
    NSURL *getSelectedURl;
    AVPlayer* player;
    AVPlayerItem* playerItem;
    AVPlayerLayer *layer;
    

}
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) MPMoviePlayerController *mpVideoPlayer;
@property (nonatomic, strong) NSMutableArray *videoURLArray;
@property (nonatomic, strong) NSMutableArray *imagesTHumbnailarray;
@property (nonatomic, strong) NSMutableArray *videosTitlearray;
@property (nonatomic, strong) NSMutableArray *videosURLArray;
@property (nonatomic, strong) NSMutableArray *assetItems;
@property (nonatomic, strong) NSMutableDictionary *dic;
@end

@implementation ViewController
@synthesize assetsLibrary, assetItems,dic;
@synthesize videoURL,videoURLArray, mpVideoPlayer;

#pragma mark - ViewController Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    titleNamelabel.text = @"Choose Picture";
    [titleBarBGView addSubview:titleNamelabel];
    UIEdgeInsets titleNamelabelpadding = UIEdgeInsetsMake(0, 0, 0, 0);
    [titleNamelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.top);
        make.left.equalTo(titleBarBGView).with.offset(titleNamelabelpadding.left);
        make.right.equalTo(titleBarBGView).with.offset(-titleNamelabelpadding.right);
        make.height.equalTo(@(50));
    }];

    ////////Up arrow Button
    uparrowbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [uparrowbtn addTarget:self action:@selector(upArrowBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [uparrowbtn setBackgroundColor:[UIColor clearColor]];
    [uparrowbtn setExclusiveTouch:YES];
    [uparrowbtn setHidden:true];
    [titleBarBGView addSubview:uparrowbtn];
    [uparrowbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBarBGView).with.offset(8);
        make.centerX.equalTo(titleBarBGView);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    
    ////////Done button
    donebtn = [UIButton new];
    donebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [donebtn addTarget:self action:@selector(DonebtnClicked:) forControlEvents:UIControlEventTouchUpInside];
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
    
    ////////videoPlayerBGView
     videoPlayerBGView=[[UIView alloc]init];
    [videoPlayerBGView setBackgroundColor:[UIColor darkGrayColor]];
    [self.view addSubview:videoPlayerBGView];
    [videoPlayerBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.height.equalTo(@(180));
        make.width.equalTo(@(self.view.frame.size.width));
    }];

    ////////List of Vdeos CollectionView
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:CGRectMake(0, 70, self.view.frame.size.width, 400) collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[ListCollectionViewCell class] forCellWithReuseIdentifier:@"ListCollectionViewCell"];
    [_collectionView setBackgroundColor:[UIColor darkGrayColor]];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
}];
    layer = [AVPlayerLayer layer];
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [videoPlayerBGView.layer addSublayer:layer];
  [self buildAssetsLibrary];
}
-(void)viewDidDisappear:(BOOL)animated{
    [player pause];

    [layer removeFromSuperlayer];
     layer = nil;

}

#pragma mark - Custom Methods

-(void) upArrowBtnClicked:(UIButton*)sender
{
    //////Hide Player
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(70);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
    }];
    [titleNamelabel setHidden:false];
    [uparrowbtn setHidden:true];

}
-(void) DonebtnClicked:(UIButton*)sender
{
    TrimVideoVC*VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TrimVideoVC"];
    VC.getSelectedVideoURL = getSelectedURl;
    [self presentViewController:VC animated:YES completion:nil];
    
}
-(void) pausebtnClicked:(UIButton*)sender
{
    [player pause];
    
}

#pragma mark - CollectionView Methods

//////CollectionView DelegateMethods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [_imagesTHumbnailarray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ListCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ListCollectionViewCell" forIndexPath:indexPath];
    cell.backgroundColor=[UIColor greenColor];
    if(_imagesTHumbnailarray.count>0){
        cell._imageView.image = [_imagesTHumbnailarray objectAtIndex:indexPath.row];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(110, 110);
}
- (UIEdgeInsets)collectionView: (UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10,10,10,10);  // top, left, bottom, right
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [uparrowbtn setHidden:false];
    [titleNamelabel setHidden:true];
    [uparrowbtn setImage:[UIImage imageNamed:@"arrowimg.png"] forState:UIControlStateNormal];
    [_collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(250);
        make.left.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
    }];
    getSelectedURl = [_videosURLArray objectAtIndex:indexPath.row];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:[_videosURLArray objectAtIndex:indexPath.row]];
    [layer setFrame:CGRectMake(10, 10, videoPlayerBGView.frame.size.width-20, videoPlayerBGView.frame.size.height-20)];
    player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    [layer setPlayer:player];
    [player play];
    
    pausebtn = [UIButton new];
    pausebtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pausebtn addTarget:self action:@selector(pausebtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [pausebtn setBackgroundColor:[UIColor clearColor]];
    pausebtn.translatesAutoresizingMaskIntoConstraints = NO;
    [pausebtn setExclusiveTouch:YES];
    [videoPlayerBGView addSubview:pausebtn];
    [pausebtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(videoPlayerBGView).with.offset(4);
        make.right.equalTo(videoPlayerBGView).with.offset(-4);
        make.height.equalTo(@(180));
        make.width.equalTo(@(300));
    }];
    
    [_collectionView reloadData];

}

#pragma mark - Show Video List Methods

- (void)buildAssetsLibrary
{
    assetsLibrary = [[ALAssetsLibrary alloc] init];
    ALAssetsLibrary *notificationSender = nil;
    videoURLArray = [[NSMutableArray alloc] init];
    _imagesTHumbnailarray = [[NSMutableArray alloc] init];
    _videosURLArray = [[NSMutableArray alloc] init];
    _videosTitlearray = [[NSMutableArray alloc] init];
    NSString *minimumSystemVersion = @"4.1";
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if ([systemVersion compare:minimumSystemVersion options:NSNumericSearch] != NSOrderedAscending)
        notificationSender = assetsLibrary;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(assetsLibraryDidChange:) name:ALAssetsLibraryChangedNotification object:notificationSender];
    [self updateAssetsLibrary];
}

- (void)assetsLibraryDidChange:(NSNotification*)changeNotification
{
    [self updateAssetsLibrary];
}

- (void)updateAssetsLibrary
{
    assetItems = [NSMutableArray arrayWithCapacity:0];
    ALAssetsLibrary *assetLibrary = assetsLibrary;
    
    [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         if (group)
         {
             [group setAssetsFilter:[ALAssetsFilter allVideos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop)
              {
                  if (asset)
                  {
                      dic = [[NSMutableDictionary alloc] init];
                      ALAssetRepresentation *defaultRepresentation = [asset defaultRepresentation];
                      NSString *uti = [defaultRepresentation UTI];
                      videoURL = [[asset valueForProperty:ALAssetPropertyURLs] valueForKey:uti];
                      mpVideoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
                      NSString *title = [NSString stringWithFormat:@"%@ %lu", NSLocalizedString(@"Video", nil), [assetItems count]+1];
                      
                      [self performSelector:@selector(imageFromVideoURL)];
                      [dic setValue:title forKey:@"VideoTitle"];//kName
                      [dic setValue:videoURL forKey:@"VideoUrl"];//kURL
                      AssetBrowserItem *item = [[AssetBrowserItem alloc] initWithURL:videoURL title:title];
                      [assetItems addObject:item];
                      [videoURLArray addObject:dic];
                      
                  }
                  
                  _imagesTHumbnailarray = [videoURLArray valueForKey:@"ImageThumbnail"];
                  _videosTitlearray = [videoURLArray valueForKey:@"VideoTitle"];
                  _videosURLArray = [videoURLArray valueForKey:@"VideoUrl"];
                  [_collectionView reloadData];

              } ];
         }
         else{
         }
     }
    failureBlock:^(NSError *error)
     {
         NSLog(@"error enumerating AssetLibrary groups %@\n", error);
     }];

}

- (UIImage *)imageFromVideoURL
{
    
    UIImage *image = nil;
    AVAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calc midpoint time of video
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    CMTime midpoint = CMTimeMakeWithSeconds(durationSeconds/2.0, 600);
    
    // get the image from
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef halfWayImage = [imageGenerator copyCGImageAtTime:midpoint actualTime:&actualTime error:&error];
    
    if (halfWayImage != NULL)
    {
        // cgimage to uiimage
        image = [[UIImage alloc] initWithCGImage:halfWayImage];
        [dic setValue:image forKey:@"ImageThumbnail"];//kImage
        CGImageRelease(halfWayImage);
    }
    return image;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
