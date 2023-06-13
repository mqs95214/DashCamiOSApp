//
//  VideoFileCutViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2018/9/5.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "VideoFileCutViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "MBProgressHUD.h"
#define TEST 1
#define TIMER 0

#define kCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define kSplitImages  [kCachePath stringByAppendingPathComponent:@"images"]

@interface VideoFileCutViewController ()
@property (weak, nonatomic) IBOutlet UISlider *PlayerSlider;
@property (weak, nonatomic) IBOutlet UIImageView *PreviewImage;
@property (assign,nonatomic) BOOL isPlay; //是否在播放(控制进度条是否移动)
@property (weak, nonatomic) IBOutlet UIButton *PlayVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *PlayVideoButton2;
//@property (weak, nonatomic) IBOutlet UILabel *NavigationTitle;
@property (weak, nonatomic) IBOutlet UIButton *NavigationTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIImageView *file_previewIV;
//@property (nonatomic, strong) IBOutlet UIButton *MoveBar;
//@property (weak, nonatomic) IBOutlet UIButton *LeftMargin;
//@property (weak, nonatomic) IBOutlet UIButton *RightMargin;
//@property (weak, nonatomic) IBOutlet UIImageView *OuterFrame;
@property (weak, nonatomic) IBOutlet UILabel *MinSecLabel;
@property (weak, nonatomic) IBOutlet UILabel *MaxSecLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic) NSString *NewPaths;
@property(nonatomic) NSTimer *PlayerTimer;
@property (assign,nonatomic) BOOL Seeking;
@property (weak, nonatomic) IBOutlet UIButton *okbtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *YesOrNoView;
@property(nonatomic) UIButton *muteBtn;
@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation VideoFileCutViewController
{
    //播放器
    AVPlayer *_player;
    AVPlayerItem *item;
    //显示画面的Layer
    AVPlayerLayer *imageLayer;
    AVURLAsset *asset;
    id timeObserver;
    int timercounter;
    NSString *DocumentPath;
    NSString *resultPath ;
    CGPoint MinMargin;
    CGPoint MaxMargin;
    double original_header_x;
    double ConstOutSideWidth;
    double NewOutSideWidth;
    double NewMinLabel;
    double NewMaxLabel;
    double ConstPrecent;
    double Precent;
    BOOL dragMargin;
    UIView *BlackView;
    __block UIButton *MoveBar;
    __block UIButton *LeftMargin;
    __block UIButton *RightMargin;
    __block UIImageView *OuterFrame;
    __block UIImageView *FrameImage;
    __block UIImageView *FrameImage2;
    __block UIImageView *FrameImage3;
    __block UIImageView *FrameImage4;
    __block UIImageView *FrameImage5;
    
    //GPS_Data
    int stoc_position;
    int GPS_Total_Date;
    int current_zoomLevel;
    long int per_sec_data_position[300];
    NSString *GPS_ModelName;
    NSString *GPS_ModelVersion;
    NSMutableArray *GPS_PerSecondData;
    NSMutableDictionary *GPS_Dictionary;
    bool hasGPSOffect;
    bool isJVCKENWOODMachine;
    
    bool searchMode;
    AppDelegate *delegate;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
-(IBAction)handleButtonClicked:(id)sender
{
    if(self.muteBtn.isSelected) {
        self.muteBtn.selected = NO;
    } else {
        self.muteBtn.selected = YES;
    }
    NSLog(@"handleButtonClicked");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    self.okbtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.cancelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.okbtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    self.cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    self.titleText.text = [delegate getStringForKey:@"SetVideoCutEdit" withTable:@""];
    
    self.NavigationTitle.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _NavigationTitle.imageEdgeInsets = UIEdgeInsetsMake(0.001, -8, 0.001, 32);
    _NavigationTitle.titleEdgeInsets = UIEdgeInsetsMake(0, -72, 0, 0);
    _NavigationTitle.titleLabel.adjustsFontSizeToFitWidth = YES;
    //self.NavigationTitle.titleLabel.font = [UIFont italicSystemFontOfSize:[UIFont systemFontSize]];
    //self.NavigationTitle.text = NSLocalizedString(@"SetVideoCutEdit", @"");
    _player.muted = NO;// 静音
    
    UIImage *image3 = [UIImage imageNamed:@"control_seekbar_ball"];
    
    UIImage *image4 =[self imageWithImage:image3 scaledToSize:CGSizeMake(image3.size.width/2, image3.size.height/2)];
    [_PlayerSlider setThumbImage:image4 forState:UIControlStateNormal];
    [_PlayerSlider setThumbImage:image4 forState:UIControlStateHighlighted];
    [_PlayerSlider addTarget:self action:@selector(sliderTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [_PlayerSlider addTarget:self action:@selector(sliderValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    [_PlayerSlider addTarget:self action:@selector(sliderTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    [_PlayVideoButton setImage:[UIImage imageNamed:@"control_play"] forState:UIControlStateNormal];
    [_PlayVideoButton setImage:[UIImage imageNamed:@"control_pause"] forState:UIControlStateSelected];
    [_PlayVideoButton2 setImage:[UIImage imageNamed:@"control_play_02"] forState:UIControlStateNormal];
    [_PlayVideoButton2 setImage:[UIImage imageNamed:@"control_pause_02"] forState:UIControlStateSelected];
#if TIMER
    self.PlayerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60 target:self selector:@selector(updateTimeInfo:) userInfo:nil repeats:YES];
    
#endif
  /*  [self.MoveBar addTarget:self action:@selector(MoveBarDragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];*/

    
    /*[self.LeftMargin addTarget:self action:@selector(LeftMarginDragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];*/
    
    /*[self.LeftMargin addTarget:self action:@selector(LeftMarginDragEnded:withEvent: )forControlEvents: UIControlEventTouchUpInside |
     UIControlEventTouchUpOutside];*/
    
    LeftMargin = [[UIButton alloc] initWithFrame:CGRectMake(30, ((screenHeight/2)+77)+(screenHeight-((screenHeight/2)+77))/3, 12, 31)];
    NSLog(@"position = %f      %f          %f",self.PlayVideoButton2.frame.origin.y,self.PlayVideoButton2.frame.size.height,screenHeight);
    [LeftMargin setImage:[UIImage imageNamed:@"control_videoclip_leftbar"] forState:UIControlStateNormal];
    [self.view addSubview:LeftMargin];
    
    UIPanGestureRecognizer *LeftMarginPanTouch = [[UIPanGestureRecognizer  alloc]initWithTarget:self action:@selector(LeftMarginHandlePan:)];
    [LeftMargin addGestureRecognizer:LeftMarginPanTouch];
    
    
    RightMargin = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-42, LeftMargin.frame.origin.y, 12, 31)];
    [RightMargin setImage:[UIImage imageNamed:@"control_videoclip_rightbar"] forState:UIControlStateNormal];
    
    [self.view addSubview:RightMargin];
    
    UIPanGestureRecognizer *RightBarPanTouch = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(RightBarHandlePan:)];
    
    [RightMargin addGestureRecognizer:RightBarPanTouch];
    
    
    
    
    OuterFrame = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin.frame.origin.x+LeftMargin.frame.size.width-1, LeftMargin.frame.origin.y,RightMargin.frame.origin.x-(LeftMargin.frame.origin.x+LeftMargin.frame.size.width)+2, 31)];
    
    [OuterFrame setImage:[UIImage imageNamed:@"border_cut_square"]];
    [self.view addSubview:OuterFrame];
    MoveBar = [[UIButton alloc] initWithFrame:CGRectMake(LeftMargin.frame.origin.x+LeftMargin.frame.size.width, LeftMargin.frame.origin.y, 5, 31)];
    
    [MoveBar setImage:[UIImage imageNamed:@"movebar"] forState:UIControlStateNormal];
    [self.view addSubview:MoveBar];
    
    UIPanGestureRecognizer *MoveBarPanTouch = [[UIPanGestureRecognizer  alloc]initWithTarget:self action:@selector(MoveBarHandlePan:)];
    
    [MoveBar addGestureRecognizer:MoveBarPanTouch];

   /* BlackView = [[UIView alloc] initWithFrame:CGRectMake(RightMargin.frame.origin.x+RightMargin.frame.size.width-1, LeftMargin.frame.origin.y,self.view.bounds.size.width - (RightMargin.frame.origin.x+RightMargin.frame.size.width), 31)];
    BlackView.backgroundColor = [UIColor blackColor];*/
    
    [self.view addSubview:BlackView];
    
    FrameImage = [[UIImageView alloc] initWithFrame:CGRectMake(LeftMargin.frame.origin.x+LeftMargin.frame.size.width,LeftMargin.frame.origin.y,OuterFrame.frame.size.width/5,OuterFrame.frame.size.height)];
    FrameImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(FrameImage.frame.origin.x+FrameImage.frame.size.width,FrameImage.frame.origin.y,OuterFrame.frame.size.width/5,OuterFrame.frame.size.height)];
    FrameImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(FrameImage2.frame.origin.x+FrameImage2.frame.size.width,FrameImage2.frame.origin.y,OuterFrame.frame.size.width/5,OuterFrame.frame.size.height)];
    FrameImage4 = [[UIImageView alloc] initWithFrame:CGRectMake(FrameImage3.frame.origin.x+FrameImage3.frame.size.width,FrameImage3.frame.origin.y,OuterFrame.frame.size.width/5,OuterFrame.frame.size.height)];
    FrameImage5 = [[UIImageView alloc] initWithFrame:CGRectMake(FrameImage4.frame.origin.x+FrameImage4.frame.size.width,FrameImage4.frame.origin.y,OuterFrame.frame.size.width/5,OuterFrame.frame.size.height)];
   
    self.muteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, ((OuterFrame.frame.origin.y+OuterFrame.frame.size.height)+(self.view.frame.size.height-_YesOrNoView.frame.size.height)-33)/2.0, self.view.frame.size.width, 33)];
    
    [self.muteBtn setTitle:[delegate getStringForKey:@"SetRemovetheAudio" withTable:@""] forState:UIControlStateNormal];
    [self.muteBtn setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1] forState:UIControlStateNormal];
    //Frutiger LT 55 Roman
    self.muteBtn.titleLabel.font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:18];
    self.muteBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.muteBtn setImage:[UIImage imageNamed:@"control_uncheck"] forState:UIControlStateNormal];
    [self.muteBtn setImage:[UIImage imageNamed:@"control_check"] forState:UIControlStateSelected];
    self.muteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    [self.muteBtn addTarget:self
               action:@selector(handleButtonClicked:)
     forControlEvents:UIControlEventTouchUpInside
     ];
    self.muteBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.muteBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    
    [self.view addSubview:self.muteBtn];
    [self.view insertSubview:FrameImage belowSubview:LeftMargin];
    [self.view insertSubview:FrameImage2 belowSubview:LeftMargin];
    [self.view insertSubview:FrameImage3 belowSubview:LeftMargin];
    [self.view insertSubview:FrameImage4 belowSubview:LeftMargin];
    [self.view insertSubview:FrameImage5 belowSubview:LeftMargin];
   
    
#if TEST
    NSURL *videoURL = [NSURL fileURLWithPath:_NeedCutVideoName];
    
    item = [AVPlayerItem playerItemWithURL:videoURL];
    
    _player = [AVPlayer playerWithPlayerItem:item];
    
    asset = [AVURLAsset assetWithURL:videoURL];
     
    dispatch_async(dispatch_get_main_queue(), ^{
        imageLayer   = [AVPlayerLayer playerLayerWithPlayer:_player];
        imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        //2.设置frame
        imageLayer.frame = _file_previewIV.frame;
        //3.添加到界面上
        //==================显示图像========================
        [_file_previewIV.layer addSublayer:imageLayer];
        self.MinSecLabel.text = [NSString stringWithFormat:@"0 s"];
        self.MaxSecLabel.text = [NSString stringWithFormat:@"%d s", (int)(CMTimeGetSeconds(asset.duration))];
    });
#endif
    
    [self splitVideo:1];
    [self splitVideo:2];
    [self splitVideo:3];
    [self splitVideo:4];
    [self splitVideo:5];
    
    GPS_PerSecondData = [[NSMutableArray alloc] init];
    GPS_Dictionary = [[NSMutableDictionary alloc] init];
    
    [self SaveOriginData:_NeedCutVideoName];
    
    
    
    /*OutSideWidth = self.RightMargin.frame.origin.x - (self.LeftMargin.frame.origin.x + self.LeftMargin.frame.size.width);
    
    Precent = OutSideWidth /((int)(CMTimeGetSeconds(asset.duration)));*/

    
    // Do any additional setup after loading the view.
}




-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    /*[[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(__playerItemDidPlayToEndTimeNotification:)
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:nil];*/
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    

    
    
    
    
    MinMargin.x = LeftMargin.frame.origin.x;
    MaxMargin.x = RightMargin.frame.origin.x + RightMargin.frame.size.width;

    _PlayerSlider.minimumValue = 0;
    #if TEST
    _PlayerSlider.maximumValue = (int)(CMTimeGetSeconds(asset.duration));
    #else
    _PlayerSlider.maximumValue = 60;
    #endif
    original_header_x = LeftMargin.frame.origin.x + LeftMargin.frame.size.width;
    ConstOutSideWidth = RightMargin.frame.origin.x - (LeftMargin.frame.origin.x + LeftMargin.frame.size.width + MoveBar.frame.size.width);
#if TEST
    ConstPrecent = ConstOutSideWidth / (int)(CMTimeGetSeconds(asset.duration)+1);
#else
    ConstPrecent = ConstOutSideWidth / 60;
#endif
    Precent = ConstPrecent;


    
    
    

}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(timeObserver != nil)
    {
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    if(self.isPlay)
    {
        self.isPlay = NO;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    #if TIMER
    [self.PlayerTimer invalidate];
    self.PlayerTimer = nil;
    #endif
    
}
- (void)dealloc {
    NSLog(@"**DEALLOC**");
    
}
#pragma mark - Action Progress
- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view.window];
        _progressHUD.minSize = CGSizeMake(60, 60);
        _progressHUD.minShowTime = 1;
        _progressHUD.dimBackground = YES;
        // The sample image is based on the
        // work by: http://www.pixelpressicons.com
        // licence: http://creativecommons.org/licenses/by/2.5/ca/
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/Checkmark.png"]];
        [self.view.window addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if (message) {
        [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.detailsLabelText = nil;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.0];
    } else {
        [self.progressHUD hide:YES];
    }
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
}
- (void)MoveBarHandlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:self.view];
    if((recognizer.view.center.x + translation.x + (MoveBar.frame.size.width/2) < RightMargin.frame.origin.x) && (recognizer.view.center.x + translation.x -(MoveBar.frame.size.width/2) > LeftMargin.frame.size.width +LeftMargin.frame.origin.x))
    {
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,recognizer.view.center.y);
    }
   
    Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(_PlayerSlider.maximumValue)) - (int)(floor(_PlayerSlider.minimumValue)));

    NewOutSideWidth = (round)((MoveBar.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width)) / Precent);

    
    _PlayerSlider.value = (int)(floor(_PlayerSlider.minimumValue)) + (NewOutSideWidth);
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.Seeking = NO;
    }
    else
    {
        self.Seeking = YES;
    }
#if TEST

    CMTime startTime = CMTimeMakeWithSeconds(_PlayerSlider.value, item.currentTime.timescale);
    //让视频从指定处播放
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {

        }
    }];
#endif

    [recognizer setTranslation:CGPointZero inView:self.view];
    
}
- (void)LeftMarginHandlePan:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:self.view];
    if(self.isPlay)
    {
        _PlayVideoButton.selected = 0;
        _PlayVideoButton2.selected = 0;
        [_player pause];
        self.isPlay = NO;
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
   
    if((recognizer.view.center.x + translation.x + ((LeftMargin.frame.size.width/2)) + (MoveBar.frame.size.width) <(RightMargin.frame.origin.x)) && (recognizer.view.center.x + translation.x - ((LeftMargin.frame.size.width/2)) > MinMargin.x))
    {
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y);
        MoveBar.center = CGPointMake(LeftMargin.center.x + ((MoveBar.frame.size.width/2))+((LeftMargin.frame.size.width / 2)),
                                          recognizer.view.center.y);
        OuterFrame.frame = CGRectMake(LeftMargin.frame.size.width + LeftMargin.frame.origin.x-1, OuterFrame.frame.origin.y, OuterFrame.frame.size.width-translation.x,OuterFrame.frame.size.height);
        
    }
    
   
    NewMinLabel = ((((int)LeftMargin.frame.origin.x + (int)LeftMargin.frame.size.width)-original_header_x)/ConstPrecent);
    _PlayerSlider.minimumValue = (int)(floor(NewMinLabel));
    _PlayerSlider.value = (int)(floor(NewMinLabel));
    self.MinSecLabel.text = [NSString stringWithFormat:@"%d s",(int)(floor(NewMinLabel))];

    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.Seeking = NO;
    }
    else
    {
        self.Seeking = YES;
    }
#if TEST
    
    CMTime startTime = CMTimeMakeWithSeconds(_PlayerSlider.value, item.currentTime.timescale);
    //让视频从指定处播放
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            
        }
    }];
#endif
    dragMargin = YES;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
}


- (void)RightBarHandlePan:(UIPanGestureRecognizer *)recognizer {

    CGPoint translation = [recognizer translationInView:self.view];
    if(self.isPlay)
    {
        _PlayVideoButton.selected = 0;
        _PlayVideoButton2.selected = 0;
        [_player pause];
        self.isPlay = NO;
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    
    if((recognizer.view.center.x + translation.x + ((RightMargin.frame.size.width/2)) < MaxMargin.x) && ((recognizer.view.center.x + translation.x -(RightMargin.frame.size.width/2)) - MoveBar.frame.size.width) > LeftMargin.frame.origin.x + LeftMargin.frame.size.width)
    {
        recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                             recognizer.view.center.y);
        MoveBar.center = CGPointMake(RightMargin.center.x - ((MoveBar.frame.size.width/2))-((RightMargin.frame.size.width/2)),
                                          recognizer.view.center.y);
        OuterFrame.frame = CGRectMake(OuterFrame.frame.origin.x, OuterFrame.frame.origin.y,OuterFrame.frame.size.width + translation.x, OuterFrame.frame.size.height);
    }

    NewMaxLabel = (((int)RightMargin.frame.origin.x - original_header_x - (int)MoveBar.frame.size.width)/ConstPrecent);
    _PlayerSlider.maximumValue = (int)(floor(NewMaxLabel));
    _PlayerSlider.value = (int)(floor(NewMaxLabel));
    self.MaxSecLabel.text = [NSString stringWithFormat:@"%d s", (int)(floor(NewMaxLabel))];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        self.Seeking = NO;
    }
    else
    {
        self.Seeking = YES;
    }
#if TEST
    
    CMTime startTime = CMTimeMakeWithSeconds(_PlayerSlider.value, item.currentTime.timescale);
    //让视频从指定处播放
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            
        }
    }];
#endif
    dragMargin = YES;
    [recognizer setTranslation:CGPointZero inView:self.view];
    
}
- (IBAction)PlaySliderAction:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sliderTouchUpInside:(UISlider *)slider {

    float seconds = self.PlayerSlider.value;
    CMTime startTime = CMTimeMakeWithSeconds(seconds, item.currentTime.timescale);
    //让视频从指定处播放
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            self.Seeking = NO;
        }
    }];
    
}
- (IBAction)sliderValueChanged:(UISlider *)slider {
    _PlayerSlider.value = slider.value;
    if([self.MaxSecLabel.text intValue] != [self.MinSecLabel.text intValue])
    {
        Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(_PlayerSlider.maximumValue)) - (int)(floor(_PlayerSlider.minimumValue)));
        
        NewOutSideWidth = LeftMargin.frame.origin.x +LeftMargin.frame.size.width + ((slider.value - (int)(floor(_PlayerSlider.minimumValue))) * Precent);

        MoveBar.center = CGPointMake(NewOutSideWidth +(MoveBar.frame.size.width/2),MoveBar.center.y);
    }
}
- (IBAction)sliderTouchDown:(id)sender {
    self.Seeking = YES;
}
- (IBAction)PlayAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_PlayVideoButton.selected)
    {
        self.isPlay = NO;
         [_player pause];
        _PlayVideoButton.selected = !_PlayVideoButton.selected;
        _PlayVideoButton2.selected = !_PlayVideoButton2.selected;
#if TIMER
        [self.PlayerTimer setFireDate:[NSDate distantFuture]];
#endif
        

        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    else
    {
        self.isPlay = YES;
        if(dragMargin)
        {
            dragMargin = NO;
            self.PlayerSlider.value = _PlayerSlider.minimumValue;
            CMTime startTime = CMTimeMakeWithSeconds(_PlayerSlider.value, item.currentTime.timescale);
            //让视频从指定处播放
            [_player seekToTime:startTime completionHandler:^(BOOL finished) {
                if (finished) {
                    
                }
            }];
        }
        [_player play];
        _PlayVideoButton.selected = !_PlayVideoButton.selected;
        _PlayVideoButton2.selected = !_PlayVideoButton2.selected;
        
        #if TIMER
        [self.PlayerTimer setFireDate:[NSDate distantPast]];
        #endif
        
#if 1
        __block VideoFileCutViewController *blockSelf = self;
        __block AVPlayer *blockPlayer = _player;

        timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            // 周期性回调该block的代码块
            
            /* CMTime ： value/timescale = seconds.
             time指的就是時間(不是秒),
             而時間要換算成秒就要看第二個參數timeScale了.
             timeScale指的是1秒需要由幾個frame構成(可以視為fps,帧数),
             因此真正要表達的時間就會是 time / timeScale 才會是秒.
             */
            if(blockSelf.isPlay)
            {
                if(!blockSelf.Seeking)
                {
                    CMTime current = blockPlayer.currentItem.currentTime;
                    CGFloat currentSec = CMTimeGetSeconds(current);
                    NSLog(@"当前时间：%f",currentSec);
                    
                    // 刷新播放进度
                    [blockSelf.PlayerSlider setValue:currentSec animated:YES];
#if TEST
                    if([blockSelf.MaxSecLabel.text intValue] != [blockSelf.MinSecLabel.text intValue])
                    {
                        Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(blockSelf.PlayerSlider.maximumValue)) - (int)(floor(blockSelf.PlayerSlider.minimumValue)));
                        
                        NewOutSideWidth = LeftMargin.frame.origin.x +LeftMargin.frame.size.width + ((blockSelf.PlayerSlider.value - (int)(floor(blockSelf.PlayerSlider.minimumValue))) * Precent);
                        
                        MoveBar.center = CGPointMake(NewOutSideWidth +(MoveBar.frame.size.width/2),MoveBar.center.y);
                        
                    }
                    if(blockSelf.PlayerSlider.value >= blockSelf.PlayerSlider.maximumValue)
                    {
                        [self playerItemDidPlayToEndTimeNotification];
                    }
#endif
                }
            }
        }];
#endif
    }
}
- (IBAction)PlayAction2:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_PlayVideoButton2.selected)
    {
         self.isPlay = NO;
        [_player pause];
    #if TIMER
        [self.PlayerTimer setFireDate:[NSDate distantFuture]];
    #endif
        _PlayVideoButton.selected = !_PlayVideoButton.selected;
        _PlayVideoButton2.selected = !_PlayVideoButton2.selected;
        
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    else
    {
        self.isPlay = YES;
        if(dragMargin)
        {
            dragMargin = NO;
            self.PlayerSlider.value = _PlayerSlider.minimumValue;
            CMTime startTime = CMTimeMakeWithSeconds(_PlayerSlider.value, item.currentTime.timescale);
            //让视频从指定处播放
            [_player seekToTime:startTime completionHandler:^(BOOL finished) {
                if (finished) {
                    
                }
            }];
        }
         [_player play];
        _PlayVideoButton.selected = !_PlayVideoButton.selected;
        _PlayVideoButton2.selected = !_PlayVideoButton2.selected;
       
        #if TIMER
        [self.PlayerTimer setFireDate:[NSDate distantPast]];
        #endif
        
        
        
#if 1
        __block VideoFileCutViewController *blockSelf = self;
        __block AVPlayer *blockPlayer = _player;
        
        timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {

            // 周期性回调该block的代码块
            
            /* CMTime ： value/timescale = seconds.
             time指的就是時間(不是秒),
             而時間要換算成秒就要看第二個參數timeScale了.
             timeScale指的是1秒需要由幾個frame構成(可以視為fps,帧数),
             因此真正要表達的時間就會是 time / timeScale 才會是秒.
             */
            if(blockSelf.isPlay)
            {
                if(!blockSelf.Seeking)
                {
                    // 统计时长
                   /* CMTime duration = blockPlayer.currentItem.duration;
                    CGFloat durationSec = CMTimeGetSeconds(duration);
                    //NSLog(@"总时长：%f",durationSec);
                    blockSelf.PlayerSlider.maximumValue = durationSec;*/
                    // 统计当前播放时长
                    CMTime current = blockPlayer.currentItem.currentTime;
                    CGFloat currentSec = CMTimeGetSeconds(current);
                    //NSLog(@"当前时间：%f",currentSec);
                    
                    // 刷新播放进度
                    [blockSelf.PlayerSlider setValue:currentSec animated:YES];
#if TEST
                    if([blockSelf.MaxSecLabel.text intValue] != [blockSelf.MinSecLabel.text intValue])
                    {
                        Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(blockSelf.PlayerSlider.maximumValue)) - (int)(floor(blockSelf.PlayerSlider.minimumValue)));
                        
                        NewOutSideWidth = LeftMargin.frame.origin.x +LeftMargin.frame.size.width + ((blockSelf.PlayerSlider.value - (int)(floor(blockSelf.PlayerSlider.minimumValue))) * Precent);

                           MoveBar.center = CGPointMake(NewOutSideWidth +(MoveBar.frame.size.width/2),MoveBar.center.y);
                    }
                    if(blockSelf.PlayerSlider.value >= blockSelf.PlayerSlider.maximumValue)
                    {
                        [self playerItemDidPlayToEndTimeNotification];
                    }
#endif
                }
            }
        }];
#endif
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)playerItemDidPlayToEndTimeNotification
{
    [_player pause];
    _PlayerSlider.value = 0;
    _PlayVideoButton.selected = 0;
    _PlayVideoButton2.selected = 0;
    float seconds = self.PlayerSlider.minimumValue;
    CMTime startTime = CMTimeMakeWithSeconds(seconds, item.currentTime.timescale);
    [_player seekToTime:startTime]; // seek to zero
    
    if([self.MinSecLabel.text intValue] != _PlayerSlider.maximumValue)
    {
    Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(self.PlayerSlider.maximumValue)) - (int)(floor(self.PlayerSlider.minimumValue)));
    
    NewOutSideWidth = LeftMargin.frame.origin.x +LeftMargin.frame.size.width + ((self.PlayerSlider.value - (int)(floor(self.PlayerSlider.minimumValue))) * Precent);
    
    MoveBar.center = CGPointMake(NewOutSideWidth +(MoveBar.frame.size.width/2),MoveBar.center.y);
    }
    if(timeObserver != nil)
    {
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    self.isPlay = NO;
    
}

- (IBAction)OK_Action:(id)sender {
    if([self.MaxSecLabel.text intValue] != [self.MinSecLabel.text intValue])
    {
        [self.progressHUD show:YES];
        self.okbtn.enabled = NO;
        NSDate * date = [NSDate date];
        NSTimeInterval sec = [date timeIntervalSinceNow];
        NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
        
        //设置时间输出格式：
        NSDateFormatter * df = [[NSDateFormatter alloc] init ];
        [df setDateFormat:@"yyyyMMdd_HHmmss"];
        NSString * na = [df stringFromDate:currentDate];
        NSString *CurDataTimeVideoName = [na stringByAppendingString:@".MOV"];
        // [df setDateFormat:@"yyyyMMdd_HHmmss.MOV"];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *path = [paths objectAtIndex:0];
        
        
        NSString *DocumentPathCut = [path stringByAppendingString:@"/KENWOOD DASH CAM MANAGER/"];
        
        
        NSString *cutName = @"Cut_";
        NSString *cutVideoName = [cutName stringByAppendingString:CurDataTimeVideoName];
        resultPath = [DocumentPathCut stringByAppendingString:cutVideoName];

       
        NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeAudio];
        AVMutableAudioMix *exportAudioMix;
        if([tracks count] > 0) {
            AVAssetTrack *track = [tracks objectAtIndex:0];
            exportAudioMix = [AVMutableAudioMix audioMix];
            AVMutableAudioMixInputParameters *exportAudioMixInputParameters =
            [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
            
            if(self.muteBtn.selected)
            {
            [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:0.0
                                                              timeRange:CMTimeRangeFromTimeToTime(CMTimeMake([self.MinSecLabel.text intValue], 1), CMTimeMake([self.MaxSecLabel.text intValue], 1))];
            }
            else
            {
                [exportAudioMixInputParameters setVolumeRampFromStartVolume:1.0 toEndVolume:1.0
                                                                  timeRange:CMTimeRangeFromTimeToTime(CMTimeMake([self.MinSecLabel.text intValue], 1), CMTimeMake([self.MaxSecLabel.text intValue], 1))];
            }
            exportAudioMix.inputParameters = [NSArray
                                              arrayWithObject:exportAudioMixInputParameters];
        } else {
        
        }
            
        
        AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        if (exportSession == nil)
        {
            return;
        }
        
        
        //设置输出路径 / 文件类型 / 截取时间段

        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        if([tracks count] > 0) {
            exportSession.audioMix = exportAudioMix;
        }
        exportSession.timeRange = CMTimeRangeFromTimeToTime(CMTimeMake([self.MinSecLabel.text intValue], 1), CMTimeMake([self.MaxSecLabel.text intValue], 1));
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            //exporeSession.status
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"AVAssetExportSessionStatusCancelled");
                    self.okbtn.enabled = YES;
                    [self.progressHUD hide:YES];
                    break;
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"AVAssetExportSessionStatusUnknown");
                    self.okbtn.enabled = YES;
                    [self.progressHUD hide:YES];
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"AVAssetExportSessionStatusWaiting");
                    self.okbtn.enabled = YES;
                    [self.progressHUD hide:YES];
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"AVAssetExportSessionStatusExporting");
                    self.okbtn.enabled = YES;
                    [self.progressHUD hide:YES];
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSLog(@"resultPath = %@",resultPath);
                    int Metadata_Serial = [self CheckSeries:_NeedCutVideoName];
                    
                    if(Metadata_Serial != Cut_NoneSerial)
                    {
                        if(Metadata_Serial == Cut_trim)
                        {
                            [self ReWriteGPS_METADATA_Header:resultPath];
                            [self ReWriteGPS_METADATA_Data:resultPath];
                            [self ReWriteGPS_METADATA_End:resultPath];
                        }
                        else if(Metadata_Serial == Cut_Novatake_5x ||
                                Metadata_Serial == Cut_Novatake_6x ||
                                Metadata_Serial == Cut_Novatake_7x)
                        {
                            [self ReWriteGPS_METADATA_Header:resultPath];
                            [self ReWriteGPS_METADATA_Data:resultPath];
                            [self ReWriteGPS_METADATA_End:resultPath];
                        }
                        else if(Metadata_Serial == Cut_ICatchSerial)
                        {
                            [self ReWriteGPS_METADATA_Header_ICatch:resultPath];
                            [self ReWriteGPS_METADATA_Data_ICatch:_NeedCutVideoName OutFilePath:resultPath];
                            [self ReWriteGPS_METADATA_End_ICatch:resultPath];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.progressHUD hide:YES];
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                    NSLog(@"AVAssetExportSessionStatusCompleted");
                    
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"AVAssetExportSessionStatusFailed");
                    self.okbtn.enabled = YES;
                    [self.progressHUD hide:YES];
                    break;
            }
        }];
        
    }
}

- (IBAction)Cancel_Action:(id)sender {
     [self.navigationController popToRootViewControllerAnimated:YES];
}

-(UIImage *)getImage:(NSString *)videoURL{
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(20.5, 600);  //  参数( 截取的秒数， 视频每秒多少帧)
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    
    return thumb;
    
}
-(void)splitVideo:(int)secondsOfFrame
{
   /* AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //防止时间出现偏差
    imgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    
    [imgGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:CMTimeMakeWithSeconds(secondsOfFrame, NSEC_PER_SEC)]] completionHandler:
     ^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error)
     {
         
         NSLog(@"actual got image at time:%f", CMTimeGetSeconds(actualTime));
         if(image)
         {
             switch (result) {
                 case AVAssetImageGeneratorCancelled:
                     NSLog(@"Cancelled");
                     break;
                 case AVAssetImageGeneratorFailed:
                     NSLog(@"Failed");
                     break;
                 case AVAssetImageGeneratorSucceeded: {
                     
                     UIImage *frameImg = [UIImage imageWithCGImage:image];
                     if(secondsOfFrame == 1)
                     {
                         FrameImage.image = frameImg;
                     }
                     else if(secondsOfFrame == 2)
                     {
                         FrameImage2.image = frameImg;
                     }
                     else if(secondsOfFrame == 3)
                     {
                         FrameImage3.image = frameImg;
                     }
                     else if(secondsOfFrame == 4)
                     {
                         FrameImage4.image = frameImg;
                     }
                     else if(secondsOfFrame == 5)
                     {
                         FrameImage5.image = frameImg;
                     }
                 }
                break;
             }
         }
         
     }];
    */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    AVAssetImageGenerator  *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    if (imageGen) {
        imageGen.appliesPreferredTrackTransform = YES;
        CMTime actualTime;
        CGImageRef cgImage = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(secondsOfFrame, 30) actualTime:&actualTime error:NULL];
        if (cgImage) {
            dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageWithCGImage:cgImage];
            if(secondsOfFrame == 1)
            {
                FrameImage.image = image;
            }
            else if(secondsOfFrame == 2)
            {
                FrameImage2.image = image;
            }
            else if(secondsOfFrame == 3)
            {
                FrameImage3.image = image;
            }
            else if(secondsOfFrame == 4)
            {
                FrameImage4.image = image;
            }
            else if(secondsOfFrame == 5)
            {
                FrameImage5.image = image;
            }
            CGImageRelease(cgImage);
            });
        }
    }
        });
}
-(void)SaveOriginData:(NSString *)FilePath
{
    int Metadata_Serial = Cut_NoneSerial;
    Metadata_Serial = [self CheckSeries:FilePath];
    
    if(Metadata_Serial != Cut_NoneSerial)
    {
        [self ResetGPS_Variable];
        if(Metadata_Serial == Cut_trim)
        {
            [self trim_find_CC:Metadata_Serial FileName:FilePath];
            [self trim_find_CC_PerSecond_Save:Metadata_Serial FileName:FilePath];
        }
        else if(Metadata_Serial == Cut_Novatake_5x ||
                Metadata_Serial == Cut_Novatake_6x ||
                Metadata_Serial == Cut_Novatake_7x)
        {
            [self Nvt_stco_find:Metadata_Serial FileName:FilePath];
            [self Nvt_gps_PerSecond_Save:Metadata_Serial FileName:FilePath];
        }
        else if(Metadata_Serial == Cut_ICatchSerial)
        {
            GPS_Dictionary = [[NSMutableDictionary alloc] init];
            [self ICatch_Udat_find:Metadata_Serial FileName:FilePath];
            [self ICatch_gps_PerSecond_Save:Metadata_Serial FileName:FilePath];
        }
    }
    
    
}

-(void)ReWriteGPS_METADATA_Header:(NSString *)FilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:FilePath];
    [fileHandle seekToEndOfFile];
    NSString *Header = @"CCCCCCCCCCCCCCCCCCCCCC";
    NSData* data = [Header dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}


-(void)ReWriteGPS_METADATA_Data:(NSString *)FilePath
{
    if(GPS_PerSecondData.count == 0) {
        return;
    }
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:FilePath];
    NSString *GPSData;
    NSString *Latitude;
    NSString *Longitude;
    NSString *GPSNSInd;
    NSString *GPSESInd;
    NSString *ResultLatitude;
    NSString *ResultLongitude;
    NSString *Indextemp;
    NSString *Speed;
    NSString *ALTITUDE;
    NSString *GSensor_X;
    NSString *GSensor_Y;
    NSString *GSensor_Z;
    NSString *TotalData;
    NSString *HeaderString = @"GPSDATA--";
    //NSUInteger length = [[fileHandle availableData] length];
    for(int i = [self.MinSecLabel.text intValue];i < [self.MaxSecLabel.text intValue];i++)
    {
        if(i > GPS_PerSecondData.count-1) {
            break;
        }
        [fileHandle seekToEndOfFile];

         GPSData = [[NSString alloc] initWithFormat:(@"%@%@%@%@%@%@"),[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Year"],[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Month"],[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Day"],[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Hour"],[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Minute"],[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Second"]];
        
        
        NSLog(@"Data = %@",GPSData);
        //GPS_PerData =  [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Year"];
        Latitude = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Latitude"];
        Longitude = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Longitude"];
        GPSNSInd = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_NSInd"];
        GPSESInd = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_ESInd"];
        
        ResultLatitude = [GPSNSInd stringByAppendingString:Latitude];
        ResultLongitude = [GPSESInd stringByAppendingString:Longitude];
        
        NSLog(@"Lat = %@",ResultLatitude);
        NSLog(@"Lon = %@",ResultLatitude);
        if(ResultLatitude.length > 14)
        {
            ResultLatitude = [ResultLatitude substringToIndex:14];
        }
        else if(ResultLatitude.length < 14)
        {
            while(ResultLatitude.length < 14)
            {
                Indextemp = @"0";
                ResultLatitude = [ResultLatitude stringByAppendingString:Indextemp];
            }
        }
        
        if(ResultLongitude.length > 14)
        {
            ResultLongitude = [ResultLongitude substringToIndex:14];
        }
        else if(ResultLongitude.length < 14)
        {
            while(ResultLongitude.length < 14)
            {
                Indextemp = @"0";
                ResultLongitude = [ResultLongitude stringByAppendingString:Indextemp];
            }
        }
        
        Speed = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Speed"];
        if(Speed.length > 14)
        {
            Speed = [Speed substringToIndex:14];
        }
        else if(Speed.length < 14)
        {
            while(Speed.length < 14)
            {
                Indextemp = @"0";
                Speed = [Speed stringByAppendingString:Indextemp];
            }
        }
        ALTITUDE = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Altitude"];
        if(ALTITUDE.length > 14)
        {
            ALTITUDE = [ALTITUDE substringToIndex:14];
        }
        else if(ALTITUDE.length < 14)
        {
            while(ALTITUDE.length < 14)
            {
                Indextemp = @"0";
                ALTITUDE = [ALTITUDE stringByAppendingString:Indextemp];
            }
        }
        GSensor_X = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GSensor_X"];
        GSensor_Y = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GSensor_Y"];
        GSensor_Z = [[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GSensor_Z"];
        
        if(GSensor_X.length > 14)
        {
            GSensor_X = [GSensor_X substringToIndex:14];
        }
        else if(GSensor_X.length < 14)
        {
            while(GSensor_X.length < 14)
            {
                Indextemp = @"0";
                GSensor_X = [GSensor_X stringByAppendingString:Indextemp];
            }
        }
        
        if(GSensor_Y.length > 14)
        {
            GSensor_Y = [GSensor_Y substringToIndex:14];
        }
        else if(GSensor_Y.length < 14)
        {
            while(GSensor_Y.length < 14)
            {
                Indextemp = @"0";
                GSensor_Y = [GSensor_Y stringByAppendingString:Indextemp];
            }
        }
        
        if(GSensor_Z.length > 14)
        {
            GSensor_Z = [GSensor_Z substringToIndex:14];
        }
        else if(GSensor_Z.length < 14)
        {
            while(GSensor_Z.length < 14)
            {
                Indextemp = @"0";
                GSensor_Z = [GSensor_Z stringByAppendingString:Indextemp];
            }
        }
        TotalData = [[NSString alloc] initWithFormat:(@"%@%@%@%@%@%@%@%@%@"),HeaderString,GPSData,ResultLatitude,ResultLongitude,Speed,ALTITUDE,GSensor_X,GSensor_Y,GSensor_Z];
       

        NSData* data = [TotalData dataUsingEncoding:NSUTF8StringEncoding];
        [fileHandle writeData:data];
        
    }

    [fileHandle closeFile];
}
-(void)ReWriteGPS_METADATA_End:(NSString *)FilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:FilePath];
    [fileHandle seekToEndOfFile];
    NSString *Header = @"fmt....NOVATAKE.....?inf....trim....?";
    NSData* data = [Header dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}

-(void)ReWriteGPS_METADATA_Header_ICatch:(NSString *)FilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:FilePath];
    [fileHandle seekToEndOfFile];
    NSString *Header = @"udtaVIDEOUUUUUUUUUUUUUUUUUUUUUU";
    NSData* data = [Header dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}
-(void)ReWriteGPS_METADATA_Data_ICatch:(NSString *)FilePath OutFilePath:(NSString*)outFilePath
{
    NSData *datay;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:FilePath];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    long int current_position;
    
    if(searchMode == search_bottom) {
        current_position = length-100000;
        [fileHandle seekToFileOffset:current_position];//70
        datay = [fileHandle readDataToEndOfFile];
    } else {
        current_position = 1500;
        [fileHandle seekToFileOffset:current_position];//70
        datay = [fileHandle readDataOfLength:200000];
    }
    
    Byte *testByte = (Byte *)[datay bytes];
    
    for(int i=0;i<[datay length];i++)
    {
        if(testByte[i] == 'u' && testByte[i+1] == 'd' && testByte[i+2] == 't' && testByte[i+3] == 'a')
        {
            current_position = current_position + i;
            break;
        }
    }
    [fileHandle seekToFileOffset:current_position];
    if(searchMode == search_bottom) {
        datay = [fileHandle readDataToEndOfFile];
    } else {
        datay = [fileHandle readDataOfLength:200000];
    }
    //testByte = (Byte *)[datay bytes];
    NSString *string = [[NSString alloc] initWithData:datay
                                             encoding:NSASCIIStringEncoding];
    NSString *string2 = @"";
    //int count = 0;
    //count = (string.length-33)/251;
    int startTime = [[self.MinSecLabel.text substringWithRange:NSMakeRange(0, self.MinSecLabel.text.length-2)] intValue];
    int endTime = [[self.MaxSecLabel.text substringWithRange:NSMakeRange(0, self.MaxSecLabel.text.length-2)] intValue];
    for(int i=startTime;i<endTime;i++) {
        string2 = [string2 stringByAppendingString:[NSString stringWithFormat:@"??%@",[string substringWithRange:NSMakeRange(33+(251*i), 249)]]];
    }//udtaVIDEOUUUUUUUUUUUUUUUUUUUUUU
    //NSLog(@"strmin   -> %d",[[self.MinSecLabel.text substringWithRange:NSMakeRange(0, self.MinSecLabel.text.length-2)] intValue]);
    //NSLog(@"strmax   -> %d",[[self.MaxSecLabel.text substringWithRange:NSMakeRange(0, self.MaxSecLabel.text.length-2)] intValue]);
    NSData* data = [string2 dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle closeFile];
    
    NSFileHandle *fileHandle2 = [NSFileHandle fileHandleForUpdatingAtPath:outFilePath];
    [fileHandle2 seekToEndOfFile];
    [fileHandle2 writeData:data];
    [fileHandle2 closeFile];
}
-(void)ReWriteGPS_METADATA_End_ICatch:(NSString *)FilePath
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:FilePath];
    [fileHandle seekToEndOfFile];
    NSString *Header = @"inf....KENWOOD-DRVA601W_Vx.x_ZZZZZZ_Z.....?fmtKENWOOD.........ICAT6500";
    NSData* data = [Header dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle writeData:data];
    [fileHandle closeFile];
}
-(void)trim_find_CC:(int)Metadata_Serial FileName:(NSString *)Name
{
    BOOL stco_flag = NO;
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    
    [fileHandle seekToFileOffset:length-3000];//70
    long int current_position = length-3000;
    NSData *datay = [fileHandle readDataToEndOfFile];
    Byte *testByte = (Byte *)[datay bytes];
    
    for(int i=0,j=0;i<[datay length];i++)
    {
        if(i <= [datay length]-3)
        {
            //=============Get total data===============//
            if(stco_flag)
            {
                j++;
                if(j == 21)
                {
                    j=0;
                    stco_flag = NO;
                    current_position = i;
                    break;
                }
            }
            //=============Get stoc position===============//
            if(testByte[i] == 'C' && testByte[i+1] == 'C' && testByte[i+2] == 'C' && testByte[i+3] == 'C' && testByte[i+4] == 'C' && testByte[i+5] == 'C')
            {
                stco_flag = YES;
                stoc_position = current_position;
            }
            
        }
        
        current_position = i;
    }
    [fileHandle seekToFileOffset:(length-3000)+current_position+1];//70
    long int startData = (length-3000)+current_position+1;
    datay = [fileHandle readDataToEndOfFile];
    testByte = (Byte *)[datay bytes];
    
    for(long int i = startData,j=0,k=0;; i++)
    {
        if([datay length] == 0)
            break;
        if(testByte[k] == 'f' && testByte[k+1] == 'm' && testByte[k+2] == 't')
        {
            break;
        }
        else if(testByte[k] == 'G' && testByte[k+1] == 'P' && testByte[k+2] == 'S' && testByte[k+3] == 'D' && testByte[k+4] == 'A' && testByte[k+5] == 'T'&& testByte[k+6] == 'A')
        {
            
            per_sec_data_position[j] = i + 9;
            j++;
            GPS_Total_Date++;
        }
        k++;
    }
    
    
}
-(void)Nvt_stco_find:(int)Metadata_Serial FileName:(NSString *)Name
{
    BOOL stco_flag = NO;
    long int current_position;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    
    if(Metadata_Serial == Cut_Novatake_6x ||
       Metadata_Serial == Cut_Novatake_7x)
    {
        [fileHandle seekToFileOffset:length-3000];//70
        current_position = length-3000;
    }
    else if(Metadata_Serial == Cut_Novatake_5x)
    {
        [fileHandle seekToFileOffset:length-1200];//70
        current_position = length-1200;
    }
    
    NSData *datay = [fileHandle readDataToEndOfFile];
    Byte *testByte = (Byte *)[datay bytes];
    
    
    if(Metadata_Serial == Cut_Novatake_6x ||
       Metadata_Serial == Cut_Novatake_7x)
    {
        for(int i=0,j=0;i<[datay length];i++)
        {
            if(i <= [datay length]-3)
            {
                //=============Get total data===============//
                if(stco_flag)
                {
                    j++;
                    if(j == 11)
                    {
                        j=0;
                        stco_flag = NO;
                        GPS_Total_Date = testByte[i];
                        current_position = i;
                        break;
                    }
                }
                //=============Get stoc position===============//
                if(testByte[i] == 'g' && testByte[i+1] == 'p' && testByte[i+2] == 's')
                {
                    stco_flag = YES;
                    stoc_position = current_position;
                }
                
            }
            current_position = i;
        }
        [fileHandle seekToFileOffset:(length-3000)+current_position+1];//70
        datay = [fileHandle readDataOfLength:GPS_Total_Date * 8];
        testByte = (Byte *)[datay bytes];
        
        for(long int i = 0,j=0 ; i < (GPS_Total_Date * 8) ; i+=8)
        {
            //printf("testByte =%d\n",((testByte[i]<<24) + (testByte[i+1]<<16) + (testByte[i+2]<<8) + (testByte[i+3])));
            per_sec_data_position[j] = ((testByte[i]<<24) + (testByte[i+1]<<16) + (testByte[i+2]<<8) + (testByte[i+3]));
            j++;
            //printf("per_sec_data_position = %d",per_sec_data_position[j]);
        }
        
    }
    else if(Metadata_Serial == Cut_Novatake_5x)
    {
        
        for(int i=0,j=0;i<[datay length];i++)
        {
            if(i <= [datay length]-3)
            {
                //=============Get total data===============//
                if(stco_flag)
                {
                    j++;
                    if(j == 11)
                    {
                        j=0;
                        stco_flag = NO;
                        GPS_Total_Date = testByte[i];
                        current_position = i;
                        //break;
                    }
                }
                //=============Get stoc position===============//
                if(testByte[i] == 's' && testByte[i+1] == 't' && testByte[i+2] == 'c' && testByte[i+3] == 'o')
                {
                    stco_flag = YES;
                    stoc_position = current_position;
                }
                
            }
            current_position = i;
        }
        current_position = stoc_position+12;
        
        
        printf("stoc_position = %d\n",stoc_position);
        printf("GPS_Total_Date = %d\n",GPS_Total_Date);
        

        [fileHandle seekToFileOffset:(length-1200)+current_position+1];//70
        datay = [fileHandle readDataOfLength:GPS_Total_Date * 4];
        testByte = (Byte *)[datay bytes];
        
        
        
        for(long int i = 0,j=0 ; i < (GPS_Total_Date * 4) ; i+=4)
        {
            if(testByte == nil)
                break;
            per_sec_data_position[j] = ((testByte[i]<<24) + (testByte[i+1]<<16) + (testByte[i+2]<<8) + (testByte[i+3])+65536);
            j++;
            
        }
    }
}
-(void)trim_find_CC_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    NSString *tempString;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    NSData * datay;
    for(long int i = 0,j = 0; i < GPS_Total_Date; i++)
    {
        GPS_Dictionary = [[NSMutableDictionary alloc] init];
        [fileHandle seekToFileOffset:per_sec_data_position[i]];//70
        datay = [fileHandle readDataOfLength:150];
        Byte *testByte = (Byte *)[datay bytes];
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c",testByte[j],testByte[j+1],testByte[j+2],testByte[j+3]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Year"];
        
        tempString = [NSString stringWithFormat:@"%c%c",testByte[j+4],testByte[j+5]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Month"];
        
        tempString = [NSString stringWithFormat:@"%c%c",testByte[j+6],testByte[j+7]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Day"];
        
        tempString = [NSString stringWithFormat:@"%c%c",testByte[j+8],testByte[j+9]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Hour"];
        
        tempString = [NSString stringWithFormat:@"%c%c",testByte[j+10],testByte[j+11]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Minute"];
        
        tempString = [NSString stringWithFormat:@"%c%c",testByte[j+12],testByte[j+13]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Second"];
        
        tempString = [NSString stringWithFormat:@"%c",testByte[j+14]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_NSInd"];
        
        if(MetadataSerial == Cut_trim)
        {
            tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18],testByte[j+19],testByte[j+20],testByte[j+21],testByte[j+22],testByte[j+23],testByte[j+24],testByte[j+25],testByte[j+26],testByte[j+27]];
        }
        else
        {
            if([tempString isEqualToString:@"S"])
            {
                tempString = [NSString stringWithFormat:@"-%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18],testByte[j+19],testByte[j+20],testByte[j+21],testByte[j+22],testByte[j+23],testByte[j+24],testByte[j+25],testByte[j+26],testByte[j+27]];
            }
            else
            {
                tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18],testByte[j+19],testByte[j+20],testByte[j+21],testByte[j+22],testByte[j+23],testByte[j+24],testByte[j+25],testByte[j+26],testByte[j+27]];
            }
        }
        
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Latitude"];
        
        
        tempString = [NSString stringWithFormat:@"%c",testByte[j+28]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_ESInd"];
        
        
        if(MetadataSerial == Cut_trim)
        {
            tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+29],testByte[j+30],testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38],testByte[j+39],testByte[j+40],testByte[j+41]];
        }
        else
        {
            if([tempString isEqualToString:@"W"])
            {
                tempString = [NSString stringWithFormat:@"-%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+29],testByte[j+30],testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38],testByte[j+39],testByte[j+40],testByte[j+41]];
            }
            else
            {
                tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+29],testByte[j+30],testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38],testByte[j+39],testByte[j+40],testByte[j+41]];
            }
        }
        
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Longitude"];
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+42],testByte[j+43],testByte[j+44],testByte[j+45],testByte[j+46],testByte[j+47],testByte[j+48],testByte[j+49],testByte[j+50],testByte[j+51],testByte[j+52],testByte[j+53],testByte[j+54],testByte[j+55]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Speed"];
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+56],testByte[j+57],testByte[j+58],testByte[j+59],testByte[j+60],testByte[j+61],testByte[j+62],testByte[j+63],testByte[j+64],testByte[j+65],testByte[j+66],testByte[j+67],testByte[j+68],testByte[j+69]];
        
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Altitude"];
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+70],testByte[j+71],testByte[j+72],testByte[j+73],testByte[j+74],testByte[j+75],testByte[j+76],testByte[j+77],testByte[j+78],testByte[j+79],testByte[j+80],testByte[j+81],testByte[j+82],testByte[j+83]];
        
        [GPS_Dictionary setValue:tempString forKey:@"GSensor_X"];
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+84],testByte[j+85],testByte[j+86],testByte[j+87],testByte[j+88],testByte[j+89],testByte[j+90],testByte[j+91],testByte[j+92],testByte[j+93],testByte[j+94],testByte[j+95],testByte[j+96],testByte[j+97]];
        
        [GPS_Dictionary setValue:tempString forKey:@"GSensor_Y"];
        
        
        tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+98],testByte[j+99],testByte[j+100],testByte[j+101],testByte[j+102],testByte[j+103],testByte[j+104],testByte[j+105],testByte[j+106],testByte[j+107],testByte[j+108],testByte[j+109],testByte[j+110],testByte[j+111]];
        
        [GPS_Dictionary setValue:tempString forKey:@"GSensor_Z"];
        
        [GPS_PerSecondData addObject:GPS_Dictionary];
    }
    
}
-(void)Nvt_gps_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    NSData * datay;
    
    long int free_gps_position;
    double Latitude;
    double Longitude;
    double Speed;
    double Altitude;
    double GSensor_X;
    double GSensor_Y;
    double GSensor_Z;
    NSNumber *number;
    int data = 0;
    for(long int i = 0; i < GPS_Total_Date; i++)
    {
        [fileHandle seekToFileOffset:per_sec_data_position[i]];//70
        free_gps_position = per_sec_data_position[i];
        datay = [fileHandle readDataOfLength:40];
        Byte *testByte = (Byte *)[datay bytes];
        for(int j = 0 ; j < 40;j++)
        {
            if(testByte[j] == 'f' && testByte[j+1] == 'r' && testByte[j+2] == 'e' && testByte[j+3] == 'e' && testByte[j+4] == 'G' && testByte[j+5] == 'P' && testByte[j+6] == 'S')
            {
                per_sec_data_position[i] = free_gps_position;
            }
            free_gps_position++;
        }
    }
    int offect;
    if(hasGPSOffect == YES) {
        offect = 32;
    } else {
        offect = 0;
    }
    for(long int i = 0,j = 0; i < GPS_Total_Date; i++)
    {
        GPS_Dictionary = [[NSMutableDictionary alloc] init];
        [fileHandle seekToFileOffset:per_sec_data_position[i]];//70
        datay = [fileHandle readDataOfLength:150];
        Byte *testByte = (Byte *)[datay bytes];
        //NSLog(@"data->>>>>AA %d",(int)((testByte[j+47-offect] << 24) + (testByte[j+46-offect] << 16) + (testByte[j+45-offect] << 8) + (testByte[j+44-offect])));
        data = (int)((testByte[j+47-offect] << 24) + (testByte[j+46-offect] << 16) + (testByte[j+45-offect] << 8) + (testByte[j+44-offect]));
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%02d",data] forKey:@"GPS_Hour"];
        data = ((testByte[j+51-offect] << 24) + (testByte[j+50-offect] << 16) + (testByte[j+49-offect] << 8) + (testByte[j+48-offect]));
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%02d",data] forKey:@"GPS_Minute"];
        data = ((testByte[j+55-offect] << 24) + (testByte[j+54-offect] << 16) + (testByte[j+53-offect] << 8) + (testByte[j+52-offect]));
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%02d",data] forKey:@"GPS_Second"];
        if(hasGPSOffect == YES) {
            data = (((testByte[j+59-offect] << 24) + (testByte[j+58-offect] << 16) + (testByte[j+57-offect] << 8) + (testByte[j+56-offect])));
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%04d",data] forKey:@"GPS_Year"];
        } else {
            data = (((testByte[j+59-offect] << 24) + (testByte[j+58-offect] << 16) + (testByte[j+57-offect] << 8) + (testByte[j+56-offect]))+2000);
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%04d",data] forKey:@"GPS_Year"];
        }
        data = ((testByte[j+63-offect] << 24) + (testByte[j+62-offect] << 16) + (testByte[j+61-offect] << 8) + (testByte[j+60-offect]));
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%02d",data] forKey:@"GPS_Month"];
        data = ((testByte[j+67-offect] << 24) + (testByte[j+66-offect] << 16) + (testByte[j+65-offect] << 8) + (testByte[j+64-offect]));
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%02d",data] forKey:@"GPS_Day"];
        data = (testByte[j+68-offect]);
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",data] forKey:@"GPS_Status"];
        data = (testByte[j+69-offect]);
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",data] forKey:@"GPS_NSInd"];
        data = (testByte[j+70-offect]);
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",data] forKey:@"GPS_ESInd"];
        //==========Latitude========//
        data = ((testByte[j+75-offect] << 24) + (testByte[j+74-offect] << 16) + (testByte[j+73-offect] << 8) + (testByte[j+72-offect]));
        if(data == 0) {
            Latitude = (double)0.0;
        } else {
            Latitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",data] par2:0];
        }
        /*if(testByte[j+69] == 'S')
        {
            Latitude = -Latitude;
        }*/
        number = [NSNumber numberWithDouble:Latitude];
        //NSString *aString = [number stringValue];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GPS_Latitude"];
       /* [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Latitude] forKey:@"GPS_Latitude"];
        */
        data = ((testByte[j+79-offect] << 24) + (testByte[j+78-offect] << 16) + (testByte[j+77-offect] << 8) + (testByte[j+76-offect]));
        if(data == 0) {
            Longitude = (double)0.0;
        } else {
            Longitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",data] par2:0];
        }
        
        /*if(testByte[j+70] == 'W')
        {
            Longitude = -Longitude;
        }*/
        number = [NSNumber numberWithDouble:Longitude];
        //NSString *aString = [number stringValue];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GPS_Longitude"];
        data = ((testByte[j+83-offect] << 24) + (testByte[j+82-offect] << 16) + (testByte[j+81-offect] << 8) + (testByte[j+80-offect]));
        if(data == 0) {
            Speed = (double)0.0;
        } else {
            Speed  = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",data] par2:1];
        }
        Speed = Speed * 1.852;
        
        
        /*[GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Speed] forKey:@"GPS_Speed"];*/
        number = [NSNumber numberWithDouble:Speed];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GPS_Speed"];
        
        data = ((testByte[j+87-offect] << 24) + (testByte[j+86-offect] << 16) + (testByte[j+85-offect] << 8) + (testByte[j+84-offect]));
        if(data == 0) {
            Altitude = (double)0.0;
        } else {
            Altitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",data] par2:1];
        }
        
        number = [NSNumber numberWithDouble:Altitude];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GPS_Altitude"];
        /*[GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Altitude] forKey:@"GPS_Altitude"];*/
        data = ((testByte[j+91-offect] << 24) + (testByte[j+90-offect] << 16) + (testByte[j+89-offect] << 8) + (testByte[j+88-offect]));
        if(data == 0) {
            GSensor_X = (double)0.0;
        } else {
            GSensor_X = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",data] Y_Zeexl:0];
        }
        number = [NSNumber numberWithDouble:GSensor_X];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GSensor_X"];
        /*[GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",GSensor_X] forKey:@"GSensor_X"];*/
        
        data = ((testByte[j+95-offect] << 24) + (testByte[j+94-offect] << 16) + (testByte[j+93-offect] << 8) + (testByte[j+92-offect]));
        if(data == 0) {
            GSensor_Y = (double)0.0;
        } else {
            GSensor_Y = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",data] Y_Zeexl:1];
        }
        number = [NSNumber numberWithDouble:GSensor_Y];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GSensor_Y"];
        /*[GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",GSensor_Y] forKey:@"GSensor_Y"];*/
        
        data = ((testByte[j+99-offect] << 24) + (testByte[j+98-offect] << 16) + (testByte[j+97-offect] << 8) + (testByte[j+96-offect]));
        if(data == 0) {
            GSensor_Z = (double)0.0;
        } else {
            GSensor_Z = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",data] Y_Zeexl:0];
        }
        number = [NSNumber numberWithDouble:GSensor_Z];
        [GPS_Dictionary setValue:[number stringValue] forKey:@"GSensor_Z"];
        /*[GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",GSensor_Z] forKey:@"GSensor_Z"];*/
        
        if(isJVCKENWOODMachine == YES) {
            if(i>=2)
                [GPS_PerSecondData addObject:GPS_Dictionary];
        } else {
            [GPS_PerSecondData addObject:GPS_Dictionary];
        }
    }
    if(isJVCKENWOODMachine == YES) {
        GPS_Total_Date = GPS_Total_Date-2;
    }
}
-(void)ICatch_gps_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    NSData * datay;
    NSString *tempLatitude;
    NSString *tempLongitude;
    NSString *tempAltitude;
    NSString *tempSpeed;
    NSString *tempGSensorX;
    NSString *tempGSensorY;
    NSString *tempGSensorZ;
    long int free_gps_position;
    
    
    float Latitude;
    float Longitude;
    int Speed;
    int Altitude;
    float GSensor_X;
    float GSensor_Y;
    float GSensor_Z;
    for(long int i = 0,j = 0; i < GPS_Total_Date; i++)
    {
        GPS_Dictionary = [[NSMutableDictionary alloc] init];
        [fileHandle seekToFileOffset:per_sec_data_position[i]];//70
        datay = [fileHandle readDataOfLength:150];
        Byte *testByte = (Byte *)[datay bytes];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18]] forKey:@"GPS_Year"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c",testByte[j+19],testByte[j+20]] forKey:@"GPS_Month"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c",testByte[j+21],testByte[j+22]] forKey:@"GPS_Day"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c",testByte[j+23],testByte[j+24]] forKey:@"GPS_Hour"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c",testByte[j+25],testByte[j+26]] forKey:@"GPS_Minute"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c%c",testByte[j+27],testByte[j+28]] forKey:@"GPS_Second"];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",testByte[j+30]] forKey:@"GPS_NSInd"];
        
        
        tempLatitude = [[NSString alloc] initWithFormat:@"%c%c%c%c%c%c%c%c",testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38]];
        
        Latitude = [[tempLatitude substringWithRange:NSMakeRange(0 , 2)] intValue] +([[tempLatitude substringWithRange:NSMakeRange(2 , 6)] doubleValue] /10000/60);
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Latitude] forKey:@"GPS_Latitude"];
        
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",testByte[j+39]] forKey:@"GPS_ESInd"];
        
        
        tempLongitude = [[NSString alloc] initWithFormat:@"%c%c%c%c%c%c%c%c%c",testByte[j+40],testByte[j+41],testByte[j+42],testByte[j+43],testByte[j+44],testByte[j+45],testByte[j+46],testByte[j+47],testByte[j+48]];
        
        
        Longitude = [[tempLongitude substringWithRange:NSMakeRange(0 , 3)] intValue] +([[tempLongitude substringWithRange:NSMakeRange(3 , 6)] doubleValue] /10000/60);
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Longitude] forKey:@"GPS_Longitude"];
        
        
        tempAltitude = [[NSString alloc] initWithFormat:@"%c%c%c%c",testByte[j+50],testByte[j+51],testByte[j+52],testByte[j+53]];
        
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",[tempAltitude intValue]] forKey:@"GPS_Altitude"];
        
        tempSpeed = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+54],testByte[j+55],testByte[j+56]];
        
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",[tempSpeed intValue]] forKey:@"GPS_Speed"];
        
        if(testByte[j+57] == '+')
        {
            tempGSensorX = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+58],testByte[j+59],testByte[j+60]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",[tempGSensorX doubleValue]/100] forKey:@"GSensor_X"];
            
        }
        else
        {
            tempGSensorX = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+58],testByte[j+59],testByte[j+60]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",([tempGSensorX doubleValue]/100)*-1] forKey:@"GSensor_X"];
        }
        
        
        if(testByte[j+61] == '+')
        {
            tempGSensorY = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+62],testByte[j+63],testByte[j+64]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",[tempGSensorY doubleValue]/100] forKey:@"GSensor_Y"];
            
        }
        else
        {
            tempGSensorY = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+62],testByte[j+63],testByte[j+64]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",([tempGSensorY doubleValue]/100)*-1] forKey:@"GSensor_Y"];
        }
        
        if(testByte[j+65] == '+')
        {
            tempGSensorZ = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+66],testByte[j+67],testByte[j+68]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",[tempGSensorZ doubleValue]/100] forKey:@"GSensor_Y"];
            
        }
        else
        {
            tempGSensorZ = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+66],testByte[j+67],testByte[j+68]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",([tempGSensorZ doubleValue]/100)*-1] forKey:@"GSensor_Y"];
        }
        
        [GPS_PerSecondData addObject:GPS_Dictionary];
    }
    
}
-(double)toBinarySystemWithDecimalSystem:(NSString *)decimal par2:(int)mode
{
    int num = [decimal intValue];
    //int remainder = 0;      //余数
    //int divisor = 0;        //除数
    int index = 0;          //指數
    int floatbit;
    double tempDV;
    int doubleBefor = 0;
    int doubleAfter = 0;
    double doubleValue = 0.0;
    
    NSString *brefore_float = @"";
    NSString *after_float = @"";
    NSString *Indextemp = @"";
    NSString *floattemp = @"";
    NSString *floattemp2 = @"";
    
    NSString * prepare = @"";
    NSString * result = @"";
    NSString * newValue = @"";
    NSString * newValueBefore = @"";
    NSString * newValueAfter = @"";
    while (num>0)
    {
        prepare = [[NSString stringWithFormat:@"%lu",num&1] stringByAppendingString:prepare];
        num = num >> 1;
    }
    result = prepare;
    while(result.length < 32)
    {
        Indextemp = @"0";
        Indextemp = [Indextemp stringByAppendingString:result];
        result = Indextemp;
    }
    
    Indextemp = [result substringWithRange:NSMakeRange(1 , 8)];
    index = [self toDecimalSystemWithBinarySystem:Indextemp] - 127;
    
    Indextemp = @"1";
    floattemp = [result substringWithRange:NSMakeRange(9 , 32-9)];
    floattemp2 = [Indextemp stringByAppendingString:floattemp];
    if(index < 0)
    {
        index = -index;
        index = index - 1;
        while(index != 0)
        {
            index--;
            floattemp2 = [@"0" stringByAppendingString:floattemp2];
        }
        floattemp2 = [@"0." stringByAppendingString:floattemp2];
        brefore_float = [floattemp2 substringWithRange:NSMakeRange(0 , 1)];
        after_float = [floattemp2 substringWithRange:NSMakeRange(2 ,floattemp2.length-2)];
    }
    else if(index == 0)
    {
        brefore_float = [floattemp2 substringWithRange:NSMakeRange(0 , 1)];
        after_float = [floattemp2 substringWithRange:NSMakeRange(1 ,floattemp2.length-index-1)];
    }
    else
    {
        brefore_float = [floattemp2 substringWithRange:NSMakeRange(0 , index+1)];
        after_float = [floattemp2 substringWithRange:NSMakeRange(index+1 ,floattemp2.length-index-1)];
    }
    doubleBefor = [self toDecimalSystemWithBinarySystem:brefore_float];
    newValue = [newValue stringByAppendingFormat:@"%d",doubleBefor];
    if(newValue.length == 5)
    {
        newValueBefore = [newValue substringWithRange:NSMakeRange(0 , 3)];
        newValueAfter = [newValue substringWithRange:NSMakeRange(3 , 2)];
    }
    else if(newValue.length == 4)
    {
        newValueBefore = [newValue substringWithRange:NSMakeRange(0 , 2)];
        newValueAfter = [newValue substringWithRange:NSMakeRange(2 , 2)];
    }
    else if(newValue.length == 3)
    {
        newValueBefore = [newValue substringWithRange:NSMakeRange(0 , 2)];
        newValueAfter = [newValue substringWithRange:NSMakeRange(2 , 1)];
    }
    else if(newValue.length == 2)
    {
        newValueBefore = [newValue substringWithRange:NSMakeRange(0 , 2)];
        newValueAfter = @"0";
    }
    else
    {
        newValueBefore = [NSString stringWithFormat:@"%d",doubleBefor];
        newValueAfter = [NSString stringWithFormat:@"%d",doubleAfter];
    }
    doubleBefor = [newValueBefore intValue];
    doubleAfter = [newValueAfter intValue];
    
    for(int i = 1;i <= after_float.length;i++)
    {
        floatbit = [[after_float substringWithRange:NSMakeRange(i-1 ,1)] intValue];
        
        doubleValue += ((float)floatbit * (pow(2, -1*i)));
        
    }
    doubleValue = doubleValue + doubleAfter;
    if(mode)
    {
        tempDV = (doubleValue);
    }
    else
    {
        tempDV = (doubleValue /60.0);
    }
    
    
    return (doubleBefor + tempDV);
    /*rang = NSMakeRange(0, index-1);
     doubleBefor = [self toDecimalSystemWithBinarySystem:[floattemp2 substringWithRange:rang]];
     printf("doubleBefor = %d",doubleBefor);*/
    
    //doubleValue = [Indextemp doubleValue];
    
    /* doubleValue = doubleValue * pow(2, index);
     doubleBefor = (int)doubleValue;
     
     floattemp2 = [floattemp2 stringByAppendingFormat:@"%f",doubleValue-doubleBefor];
     
     floattemp2 = [floattemp2 substringWithRange:NSMakeRange(2 , floattemp2.length-2)];*/
    
    
}
-(double)toBinarySystemWithDecimalSystemForGSensor:(NSString *)decimal Y_Zeexl:(int)Zeexl
{
    NSInteger num = [decimal integerValue];
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    
    NSInteger doubleBefor = 0;
    int PNS_Flag = 0;
    double doubleValue = 0.0;
    NSString *Indextemp = @"";
    NSString * prepare = @"";
    NSString * result = @"";
    
    while (true)
    {
        remainder = num % 2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",(long)remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    
    
    for (NSInteger i = prepare.length - 1; i >= 0; i--)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
        
    }
    
    if(result.length < 32)
    {
        while(result.length < 32)
        {
            Indextemp = @"0";
            Indextemp = [Indextemp stringByAppendingString:result];
            result = Indextemp;
        }
    }
    else
    {
        Indextemp = [Indextemp stringByAppendingString:result];
    }
    
    if([[Indextemp substringWithRange:NSMakeRange(0 , 1)] isEqual:@"1"])
    {
        PNS_Flag = 1;
    }
    else
    {
        PNS_Flag = 0;
    }
    
    if(PNS_Flag)
    {
        int GSensorCount = 0;
        NSString *OneComplement = @"";
        while (GSensorCount < 32) {
            
            if([[Indextemp substringWithRange:NSMakeRange(GSensorCount , 1)] isEqual:@"1"])
            {
                OneComplement = [OneComplement stringByAppendingString:@"0"];
            }
            else
            {
                OneComplement = [OneComplement stringByAppendingString:@"1"];
            }
            GSensorCount++;
            
        }
        
        if(Zeexl == 1)
        {
            doubleBefor = ([self toDecimalSystemWithBinarySystem:Indextemp]+1)*(-1);
            doubleValue = (float)(doubleBefor + 256)/256;
        }
        else
        {
            doubleBefor = ([self toDecimalSystemWithBinarySystem:Indextemp]);
            doubleValue = (float)(doubleBefor)/256;
        }
        
    }
    else
    {
        doubleBefor = ([self toDecimalSystemWithBinarySystem:Indextemp]);
        doubleValue = (float)(doubleBefor)/256;
    }
    
    /* for (long int i = prepare.length - 1; i >= 0; i--)
     {
     result = [result stringByAppendingFormat:@"%@",
     [prepare substringWithRange:NSMakeRange(i , 1)]];
     }*/
    
    // doubleValue = ([self toDecimalSystemWithBinarySystem:result]/256);
    /*doubleBefor = [self toDecimalSystemWithBinarySystem:Indextemp];
     doubleValue = (float)(doubleBefor)/256;*/
    return (doubleValue);
}
-(int)toDecimalSystemWithBinarySystem:(NSString *)binary
{
    int result = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        result += temp;
    }
    
    //NSString * result = [NSString stringWithFormat@"%d",ll];
    
    return result;
}
-(int)CheckSeries:(NSString *)Name
{
    int serial = (int)Cut_NoneSerial;

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    [fileHandle seekToFileOffset:length-80000];//70
    NSData *datay = [fileHandle readDataToEndOfFile];
    Byte *testByte = (Byte *)[datay bytes];
    
    
    hasGPSOffect = NO;
    isJVCKENWOODMachine = NO;
    searchMode = search_bottom;
    for(int i=0;i<[datay length];i++)
    {
        if(i <= [datay length]-7)
        {
            if(testByte[i] == 68 && testByte[i+1] == 69 && testByte[i+2] == 77 && testByte[i+3] == 79)
            {
                serial = (int)Cut_Novatake_6x;
            }
            else if(testByte[i] == 'C' && testByte[i+1] == '1' && testByte[i+2] == 'G' && testByte[i+3] == 'W')
            {
                serial = (int)Cut_Novatake_5x;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '2' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0')//200
            {
                serial = (int)Cut_Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '3' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//300W
            {
                serial = (int)Cut_Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '4' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//400W
            {
                serial = (int)Cut_Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '5' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//500W
            {
                serial = (int)Cut_Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '2' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1')//201
            {
                serial = (int)Cut_Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '3' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W') //301W
            {
                serial = (int)Cut_Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '4' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//401W
            {
                serial = (int)Cut_Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '5' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//501W
            {
                serial = (int)Cut_Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 't' && testByte[i+1] == 'r' && testByte[i+2] == 'i' && testByte[i+3] == 'm')
            {
                serial = (int)Cut_trim;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '6' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//600W
            {
                serial = (int)Cut_ICatchSerial;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '6' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//601W
            {
                serial = (int)Cut_ICatchSerial;
                break;
            }
        }
    }
    
    if(serial == (int)Cut_NoneSerial) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
        [fileHandle seekToEndOfFile];
        length = [fileHandle offsetInFile];
        [fileHandle seekToFileOffset:1500];//70
        datay = [fileHandle readDataOfLength:200000];
        testByte = (Byte *)[datay bytes];
        
        hasGPSOffect = NO;
        isJVCKENWOODMachine = NO;
        for(int i=0;i<[datay length];i++)
        {
            if(i <= [datay length]-7)
            {
                if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                        testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                        testByte[i+4] == '6' && testByte[i+5] == '0' &&
                        testByte[i+6] == '0' && testByte[i+7] == 'W')//600W
                {
                    serial = (int)Cut_ICatchSerial;
                    searchMode = search_top;
                    break;
                }
                else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                        testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                        testByte[i+4] == '6' && testByte[i+5] == '0' &&
                        testByte[i+6] == '1' && testByte[i+7] == 'W')//601W
                {
                    serial = (int)Cut_ICatchSerial;
                    searchMode = search_top;
                    break;
                }
            }
        }
    }
    return serial;
}
-(void)updateTimeInfo:(NSTimer *)timer{

    if(self.isPlay)
    {
        CMTime current = _player.currentItem.currentTime;
        CGFloat currentSec = CMTimeGetSeconds(current);
        //NSLog(@"当前时间：%f",currentSec);
        
        // 刷新播放进度
        [self.PlayerSlider setValue:currentSec animated:YES];
        if([self.MaxSecLabel.text intValue] != [self.MinSecLabel.text intValue])
        {
            Precent = (RightMargin.frame.origin.x - (LeftMargin.frame.origin.x+LeftMargin.frame.size.width + MoveBar.frame.size.width)) /((int)(floor(self.PlayerSlider.maximumValue)) - (int)(floor(self.PlayerSlider.minimumValue)));
            
            NewOutSideWidth = LeftMargin.frame.origin.x +LeftMargin.frame.size.width + ((self.PlayerSlider.value - (int)(floor(self.PlayerSlider.minimumValue))) * Precent);
            
          
            MoveBar.center = CGPointMake(NewOutSideWidth+(MoveBar.frame.size.width/2) /*(self.MoveBar.frame.size.width/2)*/,MoveBar.center.y);
        }
    }
    else
    {
        //[self.PlayerTimer setFireDate:[NSDate distantFuture]];
    }
}
-(void)ResetGPS_Variable
{
    stoc_position = nil;
    GPS_Total_Date = nil;
    
    memset(per_sec_data_position, 0, sizeof(per_sec_data_position));
    
    [GPS_Dictionary removeAllObjects];
    [GPS_PerSecondData removeAllObjects];

    
}
- (IBAction)BackHomeBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)ICatch_Udat_find:(int)Metadata_Serial FileName:(NSString *)Name
{
    NSData *datay;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:Name];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    long int current_position;
    if(searchMode == search_bottom) {
        current_position = length-100000;
        [fileHandle seekToFileOffset:current_position];//70
        datay = [fileHandle readDataToEndOfFile];
    } else {
        current_position = 1500;
        [fileHandle seekToFileOffset:current_position];//70
        datay = [fileHandle readDataOfLength:200000];
    }
    
    Byte *testByte = (Byte *)[datay bytes];
    
    for(int i=0;i<[datay length];i++)
    {
        if(testByte[i] == 'u' && testByte[i+1] == 'd' && testByte[i+2] == 't' && testByte[i+3] == 'a')
        {
            current_position = current_position + i +33;
            break;
        }
    }
    [fileHandle seekToFileOffset:current_position];//70
    if(searchMode == search_bottom) {
        datay = [fileHandle readDataToEndOfFile];
    } else {
        datay = [fileHandle readDataOfLength:200000];
    }
    
    testByte = (Byte *)[datay bytes];
    memset(per_sec_data_position, 0, sizeof(per_sec_data_position));
    for(long int i = 0,j=0 ; i < [datay length]; i+=251)
    {
        per_sec_data_position[j] = current_position + i;
        GPS_Total_Date = j;
        j++;
        
        if(testByte[i+249] == 'i' && testByte[i+250] == 'n' && testByte[i+251] == 'f')
        {
            break;
        }
    }
    [fileHandle closeFile];
}
@end
