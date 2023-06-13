//
//  MpbSegmentViewController.m
//  WifiCamMobileApp
//
//  Created by ZJ on 2016/11/18.
//  Copyright © 2016年 iCatchTech. All rights reserved.
//

#import "MpbSegmentViewController.h"
#import "MpbViewController.h"
#import "MpbTableViewController.h"
#import "MpbViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#include "MpbSDKEventListener.h"
#import "DowmloadManagerTableViewCell.h"

#define TEST 0
#define BACKGROUNDCOLOR [UIColor colorWithRed:230 / 255.0 green:230 / 255.0 blue:230 / 255.0 alpha:1.0]
#define PAGES 2

@interface MpbSegmentViewController ()
{
    NSString *SSID;
    SSID_SerialCheck *SSIDSreial;
    //播放器
    AVPlayer *_player;
    AVPlayerItem *item;
    //显示画面的Layer
    AVPlayerLayer *imageLayer;

    CGFloat curFileNameSize;
    
    AppDelegate *delegate;
}

//@property (weak, nonatomic) IBOutlet UIButton *photosBtn;
//@property (weak, nonatomic) IBOutlet UIButton *videosBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *pageView;

@property(weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property(strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property(weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *infoButton;
@property (weak, nonatomic) IBOutlet UIButton *displayTypeBT;
@property (weak, nonatomic) IBOutlet UIButton *playback_mediaTypeBT;
@property (weak, nonatomic) IBOutlet UIImageView *playback_displayIV;
@property (weak, nonatomic) IBOutlet UIImageView *playback_display_photoIV;
@property (weak, nonatomic) IBOutlet UIButton *playback_videoPlayBT;
@property (weak, nonatomic) IBOutlet UIButton *playback_fullscreenBT;
@property (weak, nonatomic) IBOutlet UIView *playback_toolView;
@property (weak, nonatomic) IBOutlet UIButton *playback_toolBT;
@property (weak, nonatomic) IBOutlet UILabel *MpbTitle;
@property (weak, nonatomic) IBOutlet UIButton *playback_lock;
@property (weak, nonatomic) IBOutlet UIButton *playback_download;
@property (weak, nonatomic) IBOutlet UIButton *playback_unlock;
@property (weak, nonatomic) IBOutlet UIButton *playback_delete;


@property (weak, nonatomic) IBOutlet UISlider *PlayerSliderBar;
@property (weak, nonatomic) IBOutlet UISlider *BufferSliderBar;
@property (weak, nonatomic) IBOutlet UIButton *NavigationTitle;
@property (weak, nonatomic) IBOutlet UILabel *NumberOfTitle;
@property (weak, nonatomic) IBOutlet UIButton *BackButton;

@property (weak, nonatomic) IBOutlet UIView *RightEditBar;
@property (weak, nonatomic) IBOutlet UIView *LeftEditBar;
@property (weak, nonatomic) IBOutlet UIButton *EditSelectBar;
@property (weak, nonatomic) IBOutlet UIButton *EditBar;
@property (weak, nonatomic) IBOutlet UIView *YesOrCancel;



- (IBAction)photosBtnClink:(id)sender;
- (IBAction)videosBtnClink:(id)sender;

- (IBAction)goHome:(id)sender;
- (IBAction)edit:(id)sender;
- (IBAction)delete:(id)sender;
- (IBAction)action:(id)sender;
- (IBAction)info:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIView *fullBackView;




@property (nonatomic) NSArray *valueArr;
@property (nonatomic) MpbViewController *curVc;
@property (nonatomic) MpbTableViewController *curTableVc;
@property (nonatomic, assign) MpbShowState curShowState;
@property (nonatomic, assign) MpbMediaType curMediaType;
@property (nonatomic, assign) CGFloat progress;
@property(nonatomic,strong)NSBundle *bundle;



/*Sider*/
@property (assign,nonatomic) BOOL Seeking;
@end



@implementation MpbSegmentViewController
CGRect progressRect;
CGPoint toolviewOriPoint;



-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    [self setPleaseWaitViewVisibility:NO];
    [_downloadManagerView setHidden:YES];
    [_downloadManagerCompletedView setHidden:YES];
    //[_maskView setHidden:YES];
    _downloadTableView.delegate = self;
    _downloadTableView.dataSource = self;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_pw"]];
    _downloadTableView.backgroundView = imageView;
    //_downloadTableView.backgroundColor = [UIColor blackColor];
    _downloadTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self initDownloadManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCloseController:) name:@"closeMpbSegmentViewController" object:nil];
    self.navigationController.toolbar.hidden = YES;
    _isVideo = true;
    _playback_videoPlayBT.hidden = YES;
    _playback_fullscreenBT.hidden = NO;
    
    _playback_lock.enabled = NO;
    _playback_unlock.enabled = NO;
    _playback_delete.enabled = NO;
    _playback_download.enabled = NO;
    _pageView.scrollEnabled = NO;

    SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
     
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
      
    }

    UIImage *image = [UIImage new];
    
    [_NavigationTitle setTitle:[delegate getStringForKey:@"SetMpbVideoTitle" withTable:@""] forState:UIControlStateNormal];
    _NavigationTitle.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _NavigationTitle.imageEdgeInsets = UIEdgeInsetsMake(1, 0, 1, 0);
    _NavigationTitle.titleEdgeInsets = UIEdgeInsetsMake(0, -56, 0, 0);
    //_NavigationTitle.titleLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];
    
    _okBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _cancelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _okBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    _cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    UIImage *image3 = [UIImage imageNamed:@"control_seekbar_ball"];
    
    UIImage *image4 =[self imageWithImage:image3 scaledToSize:CGSizeMake(image3.size.width/2, image3.size.height/2)];
    [_PlayerSliderBar setThumbImage:image4 forState:UIControlStateNormal];
    [_PlayerSliderBar setThumbImage:image4 forState:UIControlStateHighlighted];
    [self.PlayerSliderBar addTarget:self action:@selector(sliderTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.PlayerSliderBar addTarget:self action:@selector(sliderValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    [self.PlayerSliderBar addTarget:self action:@selector(sliderTouchDown:)
           forControlEvents:UIControlEventTouchDown];
    
    
    
    [self.BufferSliderBar setThumbImage:image forState:UIControlStateNormal];
    [self.playback_videoPlayBT setImage:[UIImage imageNamed:@"control_play"] forState:UIControlStateNormal];
    [self.playback_videoPlayBT setImage:[UIImage imageNamed:@"control_pause"] forState:UIControlStateSelected];
    
    self.LeftEditBar.hidden = YES;
    self.RightEditBar.hidden = YES;
    
    [self.playback_lock setImage:[UIImage imageNamed:@"control_lock"] forState:UIControlStateNormal];
    
    [self.playback_lock setImage:[UIImage imageNamed:@"control_lock_select"] forState:UIControlStateSelected];
    
    [self.playback_unlock setImage:[UIImage imageNamed:@"control_unlock"] forState:UIControlStateNormal];
    
    [self.playback_unlock setImage:[UIImage imageNamed:@"control_unlock_select"] forState:UIControlStateSelected];
    
    [self.playback_delete setImage:[UIImage imageNamed:@"control_delete"] forState:UIControlStateNormal];
    
    [self.playback_delete setImage:[UIImage imageNamed:@"control_delete_select"] forState:UIControlStateSelected];
    
    [self.playback_download setImage:[UIImage imageNamed:@"control_download"] forState:UIControlStateNormal];
    
    [self.playback_download setImage:[UIImage imageNamed:@"control_download_select"] forState:UIControlStateSelected];
    self.YesOrCancel.hidden = YES;
    //_customProgressView.center = self.view.center;

    //[self NodePlayerInit];
    
    //_customProgressView.center = self.view.center;


    //[self.view addSubview:self.BufferView];
    //[self.view addSubview:self.VideoProgressView];
    
    //[[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        [self NovatekPlayerInit];
    }
    
    [self createPagrVC];
    /*self.MpbTitle.text = NSLocalizedString(@"SetMpbVideoTitle", @"");*/
}

-(void)notificationCloseController:(NSNotification *)notification{
    //NSString  *name=[notification name];
    //NSString  *object=[notification object];
    //NSLog(@"名称:%@----对象:%@",name,object);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)dealloc{
    //NSLog(@"观察者销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self updatePageViewFrame];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBtnText:)
                                             name    :@"kCameraAssetsListSizeNotification"
                                             object  :nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateButtonEnableState:)
                                             name    :@"kCameraButtonsCurStateNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editAnimation:)
                                             name    :@"kCameraButtonsEditAnimateNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updataEditIcon:)
                                             name    :@"kCameraButtonsEditIconNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fullscreenSetImage:)
                                        name    :@"kCameraButtonsfullscreenAnimateNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePhotoGalleryEditState:)
                                             name    :@"kCameraUpdatePhotoGalleryEditStateNotification"
                                             object  :nil];
    [self initPhotoGallery];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*toolviewOriPoint.x = _playback_toolView.center.x;
    toolviewOriPoint.y = _playback_toolView.center.y;*/
    //self.playback_toolBT.enabled = NO;

   /* [UIView animateWithDuration:0.5
                     animations:^(void){
                         _playback_toolView.center = CGPointMake(toolviewOriPoint.x-300,_playback_toolView.center.y);
                     }
                     completion:^(BOOL finished) {
                         _playback_toolView.hidden = YES;
                         [_playback_toolBT setImage:[UIImage imageNamed:@"ic_playback_edit_off"] forState:UIControlStateNormal];
                         self.playback_toolBT.enabled = YES;
                     }
     ];*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraAssetsListSizeNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraButtonsCurStateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraButtonsEditAnimateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraButtonsEditIconNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraButtonsfullscreenAnimateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraUpdatePhotoGalleryEditStateNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
     [super viewDidDisappear:animated];
}



- (void)askRequest{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            NSLog(@"PlaybackVC Authorized");
        }else{
            NSLog(@"PlaybackVC Denied or Restricted");
        }
    }];
}

-(void)setPleaseWaitViewVisibility:(BOOL)on {
    if(on) {
        [_pleaseWaitView setHidden:NO];
        [_maskView setHidden:NO];
        [self performSelector:@selector(setPleaseWaitViewHidden) withObject:nil afterDelay:10];
    } else {
        [_pleaseWaitView setHidden:YES];
        [_maskView setHidden:YES];
    }
}

-(void)setPleaseWaitViewHidden {
    [_pleaseWaitView setHidden:YES];
    [_maskView setHidden:YES];
    
}

-(void)checkFolderAtAlbum{
    PHFetchResult *userCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    __block BOOL isExisted = NO;
    [userCollections enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PHAssetCollection *assetCollection = obj;
        if ([assetCollection.localizedTitle isEqualToString:@"iQViewer"])  {
            isExisted = YES;
        }
    }];
    
    if(!isExisted){
        NSLog(@"相簿不存在");
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:@"iQViewer"];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                NSLog(@"create album success");
            } else {
                NSLog(@"fail to create album:%@", error);
            }
        }];
    }
}

//创建pagecontrol
-(void)createPagrVC
{
    self.pageView.delegate = self;
    
    self.pageView.contentSize = CGSizeMake(CGRectGetWidth(self.pageView.frame) * PAGES, CGRectGetHeight(self.pageView.frame));
    //AppLog(@"----------> contentSize: %@", NSStringFromCGSize(self.pageView.contentSize));
    
    if(_isVideo){
        [self setCurViewController:MpbMediaTypeVideo];
    }
    else{
        [self setCurViewController:MpbMediaTypePhoto];
    }
}

- (void)setCurViewController:(MpbMediaType)type
{
    if (!_curVc) {
        if (_curTableVc && type == _curTableVc.curMpbMediaType) {
            return;
        }
        [self createPageViewController:type];
    } else {
        if (type == _curVc.curMpbMediaType) {
            return;
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                [_curVc.view removeFromSuperview];
                [_curVc removeFromParentViewController];
                _curVc = nil;
                
                [self createPageViewController:type];
            }];
        }
    }
    self.pageView.contentOffset = CGPointMake(type * CGRectGetWidth(self.pageView.frame), 0);
    
    
    //[self setButtonBackgroundColor:type];
}

- (void)createPageViewController:(MpbMediaType)type
{
    @autoreleasepool {
        [_curTableVc.view removeFromSuperview];
        [_curTableVc removeFromParentViewController];
        _curTableVc = nil;
        
        NSLog(@"MpbSegmentViewController curShowState is false");
        
        [_curVc.view removeFromSuperview];
        [_curVc removeFromParentViewController];
        _curVc = nil;
        
        MpbTableViewController *pvController = [MpbTableViewController  tableViewControllerWithIdentifier:@"TableViewID"];
        pvController.curMpbMediaType = type;
        
        /*CGSize frameSize;
         frameSize.width = self.pageView.frame.size.width;
         frameSize.height = self.pageView.frame.size.height+44;
         pvController.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curMediaType, 0, CGRectGetWidth(self.pageView.frame), frameSize.height);*/
        pvController.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curMediaType, 0, CGRectGetWidth(self.pageView.frame), CGRectGetHeight(self.pageView.frame));
        
        self.delegate = pvController;
        _curTableVc = pvController;
        
        [self addChildViewController:pvController];
        [self.pageView addSubview:pvController.view];
        
        self.navigationController.toolbar.hidden = YES;
        
        //[self.pageView scrollRectToVisible:pvController.view.frame animated:YES];
        
        //[self initPhotoGallery];
        self.pageView.contentOffset = CGPointMake(_curMediaType * CGRectGetWidth(self.pageView.frame), 0);
        
        _curShowState = MpbShowStateInfo;
    }
}

- (void)initPhotoGallery
{
    AppLog(@"%s", __func__);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem = self.doneButton;
        
        self.navigationController.toolbar.hidden = YES;
        
        self.editButton.title = [delegate getStringForKey:@"Edit" withTable:@""];
        self.doneButton.title = [delegate getStringForKey:@"Done" withTable:@""];
        if(_isVideo){
            self.title = @"Video";
        }
        else{
            self.title = @"Photo";
        }
        
        if (_curShowState) {
            [self.displayTypeBT setImage:[UIImage imageNamed:@"icon_playback_grid"] forState:UIControlStateNormal];
        } else {
            [self.displayTypeBT setImage:[UIImage imageNamed:@"icon_playback_info"] forState:UIControlStateNormal];
        }
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    /*CGFloat targetX = (targetContentOffset->x + CGRectGetWidth(self.pageView.frame) * 0.5);
    pageIndex = targetX / CGRectGetWidth(self.pageView.frame);
    
    [self setCurViewController:(MpbMediaType)pageIndex];*/
}
/*- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            printf("STOP IT!!\n");
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        });
    }
}*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photosBtnClink:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self setCurViewController:MpbMediaTypePhoto];
}

- (IBAction)videosBtnClink:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self setCurViewController:MpbMediaTypeVideo];
}

- (IBAction)goHome:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if (_EditState) {
        [self.delegate mpbSegmentViewController:self edit:sender];
    } else {
        if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:goHome:)]) {
            [self.delegate mpbSegmentViewController:self goHome:sender];
        }
    }
    
}

- (IBAction)edit:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:edit:)]) {
        [_playback_lock setImage:[UIImage imageNamed:@"control_lock_disable"]
                        forState:UIControlStateNormal];
        [_playback_unlock setImage:[UIImage imageNamed:@"control_unlock_disable"]
                          forState:UIControlStateNormal];
        [_playback_delete setImage:[UIImage imageNamed:@"control_delete_disable"]
                          forState:UIControlStateNormal];
        [_playback_download setImage:[UIImage imageNamed:@"control_download_disable"]
                            forState:UIControlStateNormal];
        _playback_lock.selected = 0;
        _playback_unlock.selected = 0;
        _playback_delete.selected = 0;
        _playback_download.selected = 0;
        _playback_lock.enabled = NO;
        _playback_unlock.enabled = NO;
        _playback_delete.enabled = NO;
        _playback_download.enabled = NO;
        [self.delegate mpbSegmentViewController:self edit:sender];
    }
    
    /*if(_playback_toolView.hidden){
        self.playback_toolBT.enabled = NO;
        _playback_toolView.hidden = NO;
         _playback_mediaTypeBT.hidden = YES;
        [UIView animateWithDuration:0.5
                     animations:^(void){
                         _playback_toolView.center = CGPointMake(toolviewOriPoint.x,_playback_toolView.center.y);
                     }
                     completion:^(BOOL finished) {
                         [_playback_toolBT setImage:[UIImage imageNamed:@"ic_playback_edit_on"] forState:UIControlStateNormal];
                          self.playback_toolBT.enabled = YES;
                     }
         ];
    }
    else{
        self.playback_toolBT.enabled = NO;
        [UIView animateWithDuration:0.5
                         animations:^(void){
                             _playback_toolView.center = CGPointMake(_playback_toolView.center.x-300,_playback_toolView.center.y);
                         }
                         completion:^(BOOL finished) {
                             
                             _playback_toolView.hidden = YES;
                             [_playback_toolBT setImage:[UIImage imageNamed:@"ic_playback_edit_off"] forState:UIControlStateNormal];
                             self.playback_toolBT.enabled = YES;
                             _playback_mediaTypeBT.hidden = NO;
                         }
         ];
    }*/
}


- (IBAction)delete:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:delete:)]) {
        [self.delegate mpbSegmentViewController:self delete:sender];
    }
}
- (IBAction)LockAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:LockAction:)]) {
        [self.delegate mpbSegmentViewController:self LockAction:sender];
    }
}

- (IBAction)UnLockAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:UnLockAction:)]) {
        [self.delegate mpbSegmentViewController:self UnLockAction:sender];
    }
}

- (IBAction)action:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:action:)]) {
        [self.delegate mpbSegmentViewController:self action:sender];
    }
}

- (IBAction)playback_fullscreenBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:playback_fullscreenBT_clicked:)]) {
        [self.delegate mpbSegmentViewController:self playback_fullscreenBT_clicked:sender];
        
    }
}

- (IBAction)playback_playBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:play:)]) {
        [self.delegate mpbSegmentViewController:self play:sender];
        
        
    }
    //self.playback_displayIV.backgroundColor = [UIColor clearColor];
   /* self.playback_displayIV.hidden = YES;
    [self NodePlayerInit];*/
    //NSLog(@"%@",_HttpFileNamePath);
}

- (IBAction)info:(id)sender {

    @autoreleasepool {
        if (!_curShowState) {
            NSLog(@"MpbSegmentViewController curShowState is false");
            
            [_curVc.view removeFromSuperview];
            [_curVc removeFromParentViewController];
            _curVc = nil;
        
            MpbTableViewController *pvController = [MpbTableViewController  tableViewControllerWithIdentifier:@"TableViewID"];
            pvController.curMpbMediaType = _curMediaType;
            
            /*CGSize frameSize;
            frameSize.width = self.pageView.frame.size.width;
            frameSize.height = self.pageView.frame.size.height+44;
            pvController.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curMediaType, 0, CGRectGetWidth(self.pageView.frame), frameSize.height);*/
            pvController.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curMediaType, 0, CGRectGetWidth(self.pageView.frame), CGRectGetHeight(self.pageView.frame));
            
            self.delegate = pvController;
            _curTableVc = pvController;
            
            [self addChildViewController:pvController];
            [self.pageView addSubview:pvController.view];
            
            self.navigationController.toolbar.hidden = YES;
            
            //[self.pageView scrollRectToVisible:pvController.view.frame animated:YES];
            
            [self initPhotoGallery];
            self.pageView.contentOffset = CGPointMake(_curMediaType * CGRectGetWidth(self.pageView.frame), 0);
            
            _curShowState = MpbShowStateInfo;
        } else {
            NSLog(@"MpbSegmentViewController curShowState is true");
            [_curTableVc.view removeFromSuperview];
            [_curTableVc removeFromParentViewController];
            _curTableVc = nil;
            
            [self setCurViewController:_curMediaType];
            _curShowState = MpbShowStateNor;
            self.pageView.contentOffset = CGPointMake(_curMediaType * CGRectGetWidth(self.pageView.frame), 0);
        }
    }
}


- (void)updatePhotoGallery:(BOOL)value
{
    AppLogTRACE();
//    self.deleteButton.enabled = value;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.deleteButton.enabled = NO;
        
        if (value == MpbStateEdit) {
            self.navigationItem.leftBarButtonItem = nil;
            //self.title = NSLocalizedString(@"SelectItem", nil);
            self.editButton.title = [delegate getStringForKey:@"Cancel" withTable:@""];
            self.editButton.style = UIBarButtonItemStyleDone;
            self.actionButton.enabled = NO;
        } else {
            self.navigationItem.leftBarButtonItem = self.doneButton;
            //self.title = NSLocalizedString(@"Albums", nil);
            self.editButton.title = [delegate getStringForKey:@"Edit" withTable:@""];
            
            if (_curVc.curMpbMediaType == MpbMediaTypePhoto && [_valueArr[0] unsignedIntegerValue]) {
                self.actionButton.enabled = YES;
            }else if (_curVc.curMpbMediaType == MpbMediaTypeVideo && [_valueArr[1] unsignedIntegerValue]) {
                self.actionButton.enabled = YES;
            } else self.actionButton.enabled = NO;
        }
    });
}

- (void)updatePhotoGalleryEditState:(NSNotification *)notification
{
    [self updatePhotoGallery:[notification.object boolValue]];
}

- (void)updateButtonEnableState:(NSNotification*)notification
{
    BOOL ret = [notification.object boolValue];
    
    self.actionButton.enabled = ret;
    self.deleteButton.enabled = ret;
}
- (void)fullscreenSetImage:(NSNotification*)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft ||
       deviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        self.playback_toolBT.hidden = YES;
        [self.playback_fullscreenBT setImage:[UIImage imageNamed:@"control_unfullscreen"]
                                   forState:UIControlStateNormal];
       
        imageLayer.frame = self.playback_displayIV.frame;
    }
    else
    {
        self.playback_toolBT.hidden = NO;
        [self.playback_fullscreenBT setImage:[UIImage imageNamed:@"control_fullscreen"]
                                    forState:UIControlStateNormal];
        imageLayer.frame = self.playback_displayIV.frame;

    }
}
- (void)updataEditIcon:(NSNotification *)notification
{
    [self updateEditCount:[notification.object count]];
    if([notification.object count] > 0)
    {
        [_playback_lock setImage:[UIImage imageNamed:@"control_lock"]
                               forState:UIControlStateNormal];
        [_playback_unlock setImage:[UIImage imageNamed:@"control_unlock"]
                               forState:UIControlStateNormal];
        [_playback_delete setImage:[UIImage imageNamed:@"control_delete"]
                               forState:UIControlStateNormal];
        [_playback_download setImage:[UIImage imageNamed:@"control_download"]
        forState:UIControlStateNormal];
        /*_playback_lock.selected = 0;
        _playback_unlock.selected = 0;
        _playback_delete.selected = 0;
        _playback_download.selected = 0;*/
        _playback_lock.enabled = YES;
        _playback_unlock.enabled = YES;
        _playback_delete.enabled = YES;
        _playback_download.enabled = YES;
        
    }
    else
    {
        
        [_playback_lock setImage:[UIImage imageNamed:@"control_lock_disable"]
                               forState:UIControlStateNormal];
        [_playback_unlock setImage:[UIImage imageNamed:@"control_unlock_disable"]
                               forState:UIControlStateNormal];
        [_playback_delete setImage:[UIImage imageNamed:@"control_delete_disable"]
                               forState:UIControlStateNormal];
        [_playback_download setImage:[UIImage imageNamed:@"control_download_disable"]
                               forState:UIControlStateNormal];
        _playback_lock.selected = 0;
        _playback_unlock.selected = 0;
        _playback_delete.selected = 0;
        _playback_download.selected = 0;
        _playback_lock.enabled = NO;
        _playback_unlock.enabled = NO;
        _playback_delete.enabled = NO;
        _playback_download.enabled = NO;
    }
}
- (void)editAnimation:(NSNotification *)notification
{
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:edit:)])
    {
        [self.delegate mpbSegmentViewController:self edit:(nil)];
    }
   /* if(_playback_toolView.hidden){
        _playback_toolView.hidden = NO;
        self.playback_toolBT.enabled = NO;
         _playback_mediaTypeBT.hidden = YES;
        [UIView animateWithDuration:0.5
                         animations:^(void){
                            _playback_toolView.center = CGPointMake(toolviewOriPoint.x-(self.playback_toolView.frame.size.width/2)+self.playback_toolBT.frame.size.width,_playback_toolView.center.y);
                         }
                         completion:^(BOOL finished) {
                             [_playback_toolBT setImage:[UIImage imageNamed:@"ic_playback_edit_on"] forState:UIControlStateNormal];
                              self.playback_toolBT.enabled = YES;
                         }
         ];
    }
    else{
        self.playback_toolBT.enabled = NO;
        [UIView animateWithDuration:0.5
                         animations:^(void){
                             _playback_toolView.center = CGPointMake(_playback_toolView.center.x-300,_playback_toolView.center.y);
                         }
                         completion:^(BOOL finished) {
                             _playback_toolView.hidden = YES;
                             [_playback_toolBT setImage:[UIImage imageNamed:@"ic_playback_edit_off"] forState:UIControlStateNormal];
                             self.playback_toolBT.enabled = YES;
                              _playback_mediaTypeBT.hidden = NO;
                         }
         ];
    }*/
}
- (void)setButtonBackgroundColor:(MpbMediaType)type
{
    [UIView animateWithDuration:0.5 animations:^{
        if (type == MpbMediaTypePhoto) {
            [_playback_mediaTypeBT setImage:[UIImage imageNamed:@"control_changemode_video"]
                                  forState:UIControlStateNormal];
            //_photosBtn.backgroundColor = [UIColor whiteColor];
            //_videosBtn.backgroundColor = BACKGROUNDCOLOR;
        } else {
            [_playback_mediaTypeBT setImage:[UIImage imageNamed:@"control_changemode_pic"]
                                   forState:UIControlStateNormal];
            //_photosBtn.backgroundColor = BACKGROUNDCOLOR;
            //_videosBtn.backgroundColor = [UIColor whiteColor];
        }
    }];
}

- (void)updateBtnText:(NSNotification*)notification
{
    _valueArr = notification.object;
    //AppLog(@"===========> %@", valueArr);

    dispatch_async(dispatch_get_main_queue(), ^{
        if ((_curVc && _curVc.curMpbMediaType == MpbMediaTypePhoto) || (_curTableVc && _curTableVc.curMpbMediaType == MpbMediaTypePhoto)) {
            if ([_valueArr[0] unsignedIntegerValue]) {
                self.actionButton.enabled = YES;
                self.editButton.enabled = YES;
            } else {
                [self updatePhotoGallery:MpbStateNor];
                self.editButton.enabled = NO;
            }
        } else {
            if ([_valueArr[1] unsignedIntegerValue]) {
                self.actionButton.enabled = YES;
                self.editButton.enabled = YES;
            } else {
                [self updatePhotoGallery:MpbStateNor];
                self.editButton.enabled = NO;
            }
        }
        
        /*[self.photosBtn setTitle:[NSString stringWithFormat:@"Photos (%@)", _valueArr[0]] forState:UIControlStateNormal];
        [self.videosBtn setTitle:[NSString stringWithFormat:@"Videos (%@)", _valueArr[1]] forState:UIControlStateNormal];*/
    });
}

- (void)updatePageViewFrame {
    self.pageView.contentSize = CGSizeMake(CGRectGetWidth(self.pageView.frame) * PAGES, CGRectGetHeight(self.pageView.frame));
    
    if (!_curShowState) {
        _curVc.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curVc.curMpbMediaType, 0, CGRectGetWidth(self.pageView.frame), CGRectGetHeight(self.pageView.frame));
        self.pageView.contentOffset = CGPointMake(_curVc.curMpbMediaType * CGRectGetWidth(self.pageView.frame), 0);
    } else {
        _curTableVc.view.frame = CGRectMake(CGRectGetWidth(self.pageView.frame) * _curMediaType, 0, CGRectGetWidth(self.pageView.frame), CGRectGetHeight(self.pageView.frame));
        self.pageView.contentOffset = CGPointMake(_curMediaType * CGRectGetWidth(self.pageView.frame), 0);
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updatePageViewFrame];
}

- (IBAction)OKAction:(id)sender {
    self.YesOrCancel.hidden = YES;
    self.playback_lock.selected = 0;
    self.playback_unlock.selected = 0;
    self.playback_delete.selected = 0;
    self.playback_download.selected = 0;
    self.NavigationTitle.hidden = YES;
    self.NumberOfTitle.hidden = NO;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if(self.ActionType == PBEditLockAction)
    {
        if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:OKAction:)]) {
            [self.delegate mpbSegmentViewController:self OKAction:PBEditLockAction];
        }
    }
    else if(self.ActionType == PBEditUnLockAction)
    {
        if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:OKAction:)]) {
            [self.delegate mpbSegmentViewController:self OKAction:PBEditUnLockAction];
        }
    }
    else if(self.ActionType == PBEditDeleteAction)
    {
        if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:OKAction:)]) {
            [self.delegate mpbSegmentViewController:self OKAction:PBEditDeleteAction];
        }
    }
     else if(self.ActionType == PBEditDownloadAction)
     {
         if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:OKAction:)]) {
             [self.delegate mpbSegmentViewController:self OKAction:PBEditDownloadAction];
         }
     }
}
- (IBAction)CancelAction:(id)sender {
    self.YesOrCancel.hidden = YES;
    self.NavigationTitle.hidden = NO;
    self.NumberOfTitle.hidden = YES;
    self.playback_lock.selected = 0;
    self.playback_unlock.selected = 0;
    self.playback_delete.selected = 0;
    self.playback_download.selected = 0;
    self.BackButton.userInteractionEnabled = YES;
    [self.BackButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
}

-(void)UpdateActionIcon
{
    NSString *SelectedTotal;
    NSString *Title;
    if(self.ActionType == PBEditNone)
    {
        self.YesOrCancel.hidden = YES;
        self.playback_lock.selected = 0;
        self.playback_unlock.selected = 0;
        self.playback_delete.selected = 0;
        self.playback_download.selected = 0;
        self.BackButton.userInteractionEnabled = YES;
        [self.BackButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
    }
    else if(self.ActionType == PBEditLockAction)
    {
        self.NavigationTitle.hidden = YES;
        self.NumberOfTitle.hidden = NO;
        self.YesOrCancel.hidden = NO;
        if(_isVideo)
        {
            //SelectedTotal = @"Video Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        else
        {
            //SelectedTotal = @"Photo Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        
        //Title = [NSString stringWithFormat:@"%d %@",self.SelectNum,SelectedTotal];
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)self.SelectNum]];
        
        self.NumberOfTitle.text = Title;
        self.playback_lock.selected = 1;
        self.playback_unlock.selected = 0;
        self.playback_delete.selected = 0;
        self.playback_download.selected = 0;
        self.BackButton.userInteractionEnabled = NO;
        [self.BackButton setImage:[UIImage imageNamed:@"control_lock"] forState:UIControlStateNormal];
    }
    else if(self.ActionType == PBEditUnLockAction)
    {
        self.NavigationTitle.hidden = YES;
        self.NumberOfTitle.hidden = NO;
        self.YesOrCancel.hidden = NO;
        if(_isVideo)
        {
            //SelectedTotal = @"Video Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        else
        {
            //SelectedTotal = @"Photo Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        
        //Title = [NSString stringWithFormat:@"%d %@",self.SelectNum,SelectedTotal];
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)self.SelectNum]];
        
        self.NumberOfTitle.text = Title;
        self.playback_lock.selected = 0;
        self.playback_unlock.selected = 1;
        self.playback_delete.selected = 0;
        self.playback_download.selected = 0;
        self.BackButton.userInteractionEnabled = NO;
        [self.BackButton setImage:[UIImage imageNamed:@"control_unlock"] forState:UIControlStateNormal];
    }
    else if(self.ActionType == PBEditDeleteAction)
    {
        self.NavigationTitle.hidden = YES;
        self.NumberOfTitle.hidden = NO;
        self.YesOrCancel.hidden = NO;
        if(_isVideo)
        {
            //SelectedTotal = @"Video Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        else
        {
            //SelectedTotal = @"Photo Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        
        //Title = [NSString stringWithFormat:@"%d %@",self.SelectNum,SelectedTotal];
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)self.SelectNum]];
        
        self.NumberOfTitle.text = Title;
        self.playback_lock.selected = 0;
        self.playback_unlock.selected = 0;
        self.playback_delete.selected = 1;
        self.playback_download.selected = 0;
        self.BackButton.userInteractionEnabled = NO;
        [self.BackButton setImage:[UIImage imageNamed:@"control_delete"] forState:UIControlStateNormal];
    }
    else if(self.ActionType == PBEditDownloadAction)
    {
        self.NavigationTitle.hidden = YES;
        self.NumberOfTitle.hidden = NO;
        self.YesOrCancel.hidden = NO;
        if(_isVideo)
        {
            //SelectedTotal = @"Video Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        else
        {
            //SelectedTotal = @"Photo Selected";
            if(self.SelectNum <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        
        //Title = [NSString stringWithFormat:@"%d %@",self.SelectNum,SelectedTotal];
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)self.SelectNum]];
        
        self.NumberOfTitle.text = Title;
        self.playback_lock.selected = 0;
        self.playback_unlock.selected = 0;
        self.playback_delete.selected = 0;
        self.playback_download.selected = 1;
        self.BackButton.userInteractionEnabled = NO;
        [self.BackButton setImage:[UIImage imageNamed:@"control_download"] forState:UIControlStateNormal];
    }
}
-(void) UpdateEditBar{
    if(self.EditState)
    {
        
        self.playback_mediaTypeBT.hidden = YES;
        self.EditBar.hidden = YES;
        self.RightEditBar.hidden = NO;
        self.LeftEditBar.hidden = NO;
    }
    else
    {
        self.YesOrCancel.hidden = YES;
        self.BackButton.userInteractionEnabled = YES;
        [self.BackButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
        self.NavigationTitle.hidden = NO;
        self.NumberOfTitle.hidden = YES;
        self.playback_mediaTypeBT.hidden = NO;
        self.EditBar.hidden = NO;
        self.RightEditBar.hidden = YES;
        self.LeftEditBar.hidden = YES;
    }
}
-(void) updateEditCount:(int)count {
    NSString *SelectedTotal;
    NSString *Title;
    if(self.EditState) {
        //self.NavigationTitle.hidden = YES;
        //self.NumberOfTitle.hidden = NO;
        if(_isVideo)
        {
            //SelectedTotal = @"Video Selected";
            if(count <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        else
        {
            //SelectedTotal = @"Photo Selected";
            if(count <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        
        //Title = [NSString stringWithFormat:@"%d %@",self.SelectNum,SelectedTotal];
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)count]];
        
        self.NumberOfTitle.text = Title;
    }
    
}
-(void) updatePreview{
   /* if(_thumbImage){
        _playback_displayIV.image = _thumbImage;
        [_playback_displayIV setContentMode:UIViewContentModeScaleAspectFill];
    }*/
    
    if(_fileType == 0){//0 = video
        if(_thumbImage){
            if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
            {
                  //self.playback_displayIV.hidden = NO;
                
                self.playback_videoPlayBT.hidden = NO;
                //self.PlayerSliderBar.hidden = NO;
                //self.BufferSliderBar.hidden = NO;
            }
            else if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
            {
                //self.playback_displayIV.hidden = YES;
          
                self.playback_videoPlayBT.hidden = NO;
                //self.PlayerSliderBar.hidden = NO;
                //self.BufferSliderBar.hidden = NO;
                
            }
            _playback_displayIV.image = _thumbImage;
            [_playback_displayIV setContentMode:UIViewContentModeScaleAspectFit];
        }
        _playback_displayIV.hidden = NO;
        _playback_display_photoIV.hidden = YES;
        _playback_videoPlayBT.hidden = NO;
        
    }
    else{
        if(_thumbImage){
            if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
            {
                //self.playback_displayIV.hidden = NO;
              
                self.playback_videoPlayBT.hidden = YES;
                //self.PlayerSliderBar.hidden = YES;
                //self.BufferSliderBar.hidden = YES;
            }
            else if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
            {
                //self.playback_displayIV.hidden = NO;
                
                self.playback_videoPlayBT.hidden = YES;
                //self.PlayerSliderBar.hidden = YES;
                //self.BufferSliderBar.hidden = YES;
                
            }
            
            
            _playback_display_photoIV.image = _thumbImage;
            [_playback_display_photoIV setContentMode:UIViewContentModeScaleAspectFit];
        }
        _playback_displayIV.hidden = YES;
        _playback_display_photoIV.hidden = NO;
        _playback_videoPlayBT.hidden = YES;
    }
    
    _playback_fullscreenBT.hidden = NO;
}
-(void) updateSeekBarValue
{
    if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
       
        self.PlayerSliderBar.value = _seekvalue;
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        if(!self.Seeking)
        {

            //if(self.PlayerView.layer.sublayers)
            //printf("\nSliderMaxValue = %lf\n",_SliderMaxValue);
            //printf("\nSliderValue = %lf\n",((double)[self.np getCurrentPosition]/1000));
            
            
#if TEST
            if([self.np getCurrentPosition] >= 100 && self.NodePlayerFirstFramePic == YES)
            {
                if(self.np.isPlaying)
                {
                    [self.np pause];
                }
                //self.NodePlayerFirstFramePic = NO;
            }
            else if(self.NodePlayerFirstFramePic == YES && [self.np getCurrentPosition] < 100)
            {
                
            }
            else if(self.NodePlayerFirstFramePic == NO)
            {
                self.PlayerSliderBar.value = ((double)[self.np getCurrentPosition]/1000);
                self.seekvalue = self.PlayerSliderBar.value;
            }
#endif
            CMTime current = _player.currentItem.currentTime;
            CGFloat currentSec = CMTimeGetSeconds(current);
            NSLog(@"当前时间：%f",currentSec);
            self.PlayerSliderBar.value = currentSec;
            self.seekvalue = currentSec;//self.PlayerSliderBar.value;
            // 刷新播放进度
           // [self.PlayerSliderBar setValue:currentSec animated:YES];
        }
    }
}

-(void) updateSliderMaxValue
{
    self.PlayerSliderBar.maximumValue = _SliderMaxValue;
    self.BufferSliderBar.maximumValue = _SliderMaxValue;
}
-(void) updateBufferSliderValue
{
    self.BufferSliderBar.value = _BufferValue;
}
-(void) updatePlayerStatus
{
    self.playback_videoPlayBT.selected = !self.playback_videoPlayBT.selected;
}
-(void) updatePlayerStatusSetFalse
{
    self.playback_videoPlayBT.selected = 0;
}
-(void) updatePlayerStatusSetTrue
{
    self.playback_videoPlayBT.selected = 1;
}
-(void) hideFullBackView:(bool)hide {
    self.fullBackView.hidden = hide;
}

-(void) NovatekPlayerInit
{
    [self AVPlayerInit];
}
-(void) NovatekSetPlayPath
{
    [self NodePlaySetUrl];
}
-(void) NovatekSliderMaxValue
{
    CMTime duration = _player.currentItem.asset.duration;
    CGFloat durationSec = CMTimeGetSeconds(duration);
    NSLog(@"time!!!!->   %f",durationSec);
    
    _SliderMaxValue = durationSec;
    
    self.PlayerSliderBar.maximumValue = _SliderMaxValue;
    self.BufferSliderBar.maximumValue = _SliderMaxValue;
    
}
-(void) NovatekPlayerStart
{
    [self NodePlayerStart];
}
-(void) NovatekPlayerPause
{
    [self NodePlayerPause];
}
-(void) NovatekPlayerStop
{
    [self NodePlayerStop];
}
-(void) setNodePlayerPositionZero
{
    self.PlayerSliderBar.value = 0;
    self.seekvalue = self.PlayerSliderBar.value;
}
-(double) getBufferValue
{
    return self.BufferSliderBar.value;
}
-(double) getNodePlayerPosition
{
    return _PlayerSliderBar.value;
}
-(BOOL) NovatekPlayerStatus
{
    if(_player.status == 1) {
        return true;
    } else {
        return false;
    }
    //return _player.status;
}
- (IBAction)Edit_Select_Click:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:edit:)]) {
        [self.delegate mpbSegmentViewController:self edit:sender];
    }
}

- (IBAction)playback_typeBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    SSID = [self recheckSSID];
    if([SSIDSreial CheckSSIDSerial:SSID] == NoSerial)
        return;
    if(_isVideo){
        /*self.MpbTitle.text = NSLocalizedString(@"SetMpbPhotoTitle", @"");*/
        [self setCurViewController:MpbMediaTypePhoto];

        [self.playback_mediaTypeBT setImage:[UIImage imageNamed:@"control_changemode_video"]
                          forState:UIControlStateNormal];
        [_NavigationTitle setTitle:[delegate getStringForKey:@"SetMpbPhotoTitle" withTable:@""] forState:UIControlStateNormal];
        _isVideo = false;
        //self.PlayerSliderBar.hidden = YES;
        //self.BufferSliderBar.hidden = YES;
        self.playback_videoPlayBT.hidden = YES;
        self.playback_displayIV.hidden = YES;
        self.playback_display_photoIV.hidden = NO;
    }
    else
    {
        /*self.MpbTitle.text = NSLocalizedString(@"SetMpbVideoTitle", @"");*/
        [self setCurViewController:MpbMediaTypeVideo];
        [self.playback_mediaTypeBT setImage:[UIImage imageNamed:@"control_changemode_pic"]
                                   forState:UIControlStateNormal];
        [_NavigationTitle setTitle:[delegate getStringForKey:@"SetMpbVideoTitle" withTable:@""] forState:UIControlStateNormal];

        _isVideo = true;
        //self.PlayerSliderBar.hidden = NO;
        //self.BufferSliderBar.hidden = NO;
        self.playback_videoPlayBT.hidden = NO;
        self.playback_displayIV.hidden = NO;
        self.playback_display_photoIV.hidden = YES;
    }
}
- (void)AVPlayerInit
{
#if TEST
    self.np = [[NodePlayer alloc] init];
    [self.np setNodePlayerDelegate:self];
    [self.np setAudioEnable:YES];
    self.np.receiveAudio = YES;
    
    /*[self.np setAudioEnable:YES];
    [self.np setVideoEnable:YES];
    //self.np.hwEnable = YES;*/
    [self.np setContentMode:UIViewContentModeScaleAspectFill];

    [self.np setPlayerView:self.PlayerView];
#endif
    //self.playback_displayIV
    
}
-(void)NodePlaySetUrl
{
#if TEST
    NSString *Head = @"http://192.168.1.254/";
    [self.np setInputUrl:[Head stringByAppendingString:self.PlayerPath]];
#endif
    NSString *Head = @"http://192.168.1.254/";
    //NSURL *videoURL = [NSURL fileURLWithPath:[Head stringByAppendingString:self.PlayerPath]];
    NSURL *videoURL = [NSURL URLWithString:[Head stringByAppendingString:self.PlayerPath]];
    item = [AVPlayerItem playerItemWithURL:videoURL];
    _player = [AVPlayer playerWithPlayerItem:item];
    [self NovatekSliderMaxValue];
    imageLayer   = [AVPlayerLayer playerLayerWithPlayer:_player];
    imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //2.设置frame
    imageLayer.frame = self.playback_displayIV.frame;
    //3.添加到界面上
    //==================显示图像========================
    [self.playback_displayIV.layer addSublayer:imageLayer];
}
-(void)NodePlayerStart
{
#if TEST
    [self.np start];
#endif
    
    [_player play];
}
-(void)NodePlayerPause
{
#if TEST
    [self.np pause];
#endif
    [_player pause];
}
-(void)NodePlayerStop
{
#if TEST
    [self.np stop];
#endif
    
    [_player pause];
}
-(void)NodePlayerClearView
{
#if TEST
    if(self.np)
    {
        [self.np start];
        [self.np stop];
        self.PlayerSliderBar.value = 0;
        self.BufferSliderBar.value = 0;
       // self.np = nil;
    }
#endif
    if(_player)
    {
        [_player pause];
        self.PlayerSliderBar.value = 0;
        self.BufferSliderBar.value = 0;
    }
}


-(void)NodePlayerSeekToZero
{
#if TEST
    [self.np seekTo:0];
#endif
    [_player seekToTime:kCMTimeZero];
    self.PlayerSliderBar.value = 0;
    self.seekvalue = self.PlayerSliderBar.value;
}
- (IBAction)sliderTouchUpInside:(UISlider *)slider {
    self.Seeking = NO;
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
#if TEST
        [self.np seekTo:(self.PlayerSliderBar.value)*1000];
#endif
        float seconds = self.PlayerSliderBar.value;
        CMTime startTime = CMTimeMakeWithSeconds(seconds, item.currentTime.timescale);
        [_player seekToTime:startTime completionHandler:^(BOOL finished) {
            if (finished) {
                self.Seeking = NO;
            }
        }];
    }
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:SeekToSecond:)]) {
        [self.delegate mpbSegmentViewController:self SeekToSecond:_PlayerSliderBar.value];
    }
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:sliderTouchDown:)]) {
        [self.delegate mpbSegmentViewController:self sliderTouchDown:(BOOL)self.Seeking];
    }
}
- (IBAction)sliderValueChanged:(UISlider *)slider {
    _PlayerSliderBar.value = slider.value;
}
- (IBAction)sliderTouchDown:(id)sender {
    self.Seeking = YES;
    self.NodePlayerIsPlaying = NO;
    if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:sliderTouchDown:)]) {
        [self.delegate mpbSegmentViewController:self sliderTouchDown:(BOOL)self.Seeking];
    }
    
}


- (NSString *)recheckSSID
{
    //    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    //    NSLog(@"Networks: %@",networkInterfaces);
    
    NSString *ssid = nil;
    
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo((CFStringRef)CFArrayGetValueAtIndex(myArray, 0));
        /*
         Core Foundation functions have names that indicate when you own a returned object:
         
         Object-creation functions that have “Create” embedded in the name;
         Object-duplication functions that have “Copy” embedded in the name.
         If you own an object, it is your responsibility to relinquish ownership (using CFRelease) when you have finished with it.
         
         */
        CFRelease(myArray);
        if (myDict) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
            //bssid = [dict valueForKey:@"BSSID"];
        }
    }
    NSLog(@"ssid : %@", ssid);
    //NSLog(@"bssid: %@", bssid);
    
    return ssid;
}
-(UIFont*)adjFontSize:(UILabel*)label{
    //NSLog(@"label text ->%@",label.text);
    float curFontSize = label.font.pointSize;
    UIFont *font = label.font;
    
    CGRect rect;
    rect = [label bounds];
    if(rect.size.width == 0.0f || rect.size.height == 0.0f) {
        return 0;
    }
    while(curFontSize > label.minimumScaleFactor && curFontSize > 0.0f) {
        CGSize size = CGSizeZero;
        if(label.numberOfLines == 1) {
            size = [label.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 0.0f) lineBreakMode:NSLineBreakByClipping];
        } else {
            size = [label.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 0.0f) lineBreakMode:NSLineBreakByWordWrapping];
        }
        if(size.width < rect.size.width && size.height <= rect.size.height) {
            break;
        }
        curFontSize -= 1.0f;
        font = [font fontWithSize:curFontSize];
    }
    if(curFontSize <= label.minimumScaleFactor) {
        curFontSize = label.minimumScaleFactor;
    }
    if(curFontSize < 0.0f) {
        curFontSize = 1.0f;
    }
    font = [font fontWithSize:curFontSize];
    return font;
}

- (IBAction)downloadManagerClose:(id)sender {
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        if ([self.delegate respondsToSelector:@selector(mpbSegmentViewController:cancelDownload:)]) {
            [self.delegate mpbSegmentViewController:self cancelDownload:@""];
        }
        [_downloadManagerView setHidden:YES];
        [self downloadCompletedNotice];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        
    }
    
}
- (IBAction)downloadManagerCompletedClose:(id)sender {
    [_downloadManagerCompletedView setHidden:YES];
    [_maskView setHidden:YES];
}
- (IBAction)downloadManagerCompletedOK:(id)sender {
    [_downloadManagerCompletedView setHidden:YES];
    [_maskView setHidden:YES];
}
-(void)cancelDownloadCell:(UIButton*) sender{
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        NSLog(@"indextag->  %d",sender.tag);
        NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
        DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
        UIImage *image = [cell.stateImageBtn imageForState:UIControlStateNormal];
        if([image isEqual:[UIImage imageNamed:@"control_pw_cancel"]]) {
            [_downloadStateList replaceObjectAtIndex:sender.tag withObject:@"2"];
            [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_failed"] forState:UIControlStateNormal];
        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        NSLog(@"indextag->  %d",sender.tag);
        if(sender.tag == downloadCurIndex)
            return;
        NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag inSection:0];
        DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
        UIImage *image = [cell.stateImageBtn imageForState:UIControlStateNormal];
        if([image isEqual:[UIImage imageNamed:@"control_pw_cancel"]]) {
            [_downloadStateList replaceObjectAtIndex:sender.tag withObject:@"2"];
            [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_failed"] forState:UIControlStateNormal];
        }
    }
    
    
}
-(void) downloadCompletedNotice {
    NSString *str = @"";
    [self updateDownloadCell];
    if(downloadWait>0){
        downloadDone = downloadTotal-downloadFailed;
    }
    [_downloadCompletedText setText:[delegate getStringForKey:@"SetDownloadcompleted" withTable:@""]];
    [_downloadManagerCompletedTitle setText:[delegate getStringForKey:@"SetDownloadManagerTitle" withTable:@""]];
    [_downloadManagerOKBtn setTitle:[delegate getStringForKey:@"BtnOK" withTable:@""] forState:UIControlStateNormal];
    str = [[delegate getStringForKey:@"SetDownloadcompletedResult" withTable:@""] stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%d",downloadDone]];
    str = [str stringByReplacingOccurrencesOfString:@"$2$" withString:[NSString stringWithFormat:@"%d",downloadFailed]];
    [_downloadSuccess_Completed setText:str];
    [_downloadFailed_Completed setText:@""];
    //[_downloadFailed_Completed setText:[NSString stringWithFormat:@"Failed : %d",downloadFailed]];
    [_downloadManagerView setHidden:YES];
    [_downloadManagerCompletedView setHidden:NO];
}
-(bool)needDownloadFile:(int)selectedFile{
    //if(selectedFile >= downloadTotal) {
    //    return false;
    //}
    NSIndexPath *ip = [NSIndexPath indexPathForRow:selectedFile inSection:0];
    DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
    
    UIImage *image = [cell.stateImageBtn imageForState:UIControlStateNormal];
    //NSLog(@"needDownloadFile  - >>>>   %hhd    YYYYY  =   %d",[image isEqual:[UIImage imageNamed:@"control_pw_cancel"]],selectedFile);
    if([[_downloadStateList objectAtIndex:selectedFile] isEqualToString:@"0"]) {
        return true;
    } else {
        return false;
    }
}
-(bool)needUpdateProgress:(int)index{
    if(index < 0)
        return false;
    if(index >= _downloadStateList.count)
        return false;
    if([[_downloadStateList objectAtIndex:index] isEqualToString:@"2"]) {
        return false;
    } else {
        return true;
    }
}
//download manager tableview
-(void)initDownloadManager {
    NSString *str = [delegate getStringForKey:@"SetDownloadProgressCurrentResult" withTable:@""];
    _list = [[NSMutableArray alloc] init];
    _contentList = [[NSArray alloc] init];
    _downloadStateList = [[NSMutableArray alloc] init];
    downloadDone = 0;
    downloadWait = 0;
    downloadFailed = 0;
    [_downloadManagerTitle setText:[delegate getStringForKey:@"SetDownloadManagerTitle" withTable:@""]];
    str = [str stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%d",downloadDone]];
    str = [str stringByReplacingOccurrencesOfString:@"$2$" withString:[NSString stringWithFormat:@"%d",downloadWait]];
    str = [str stringByReplacingOccurrencesOfString:@"$3$" withString:[NSString stringWithFormat:@"%d",downloadFailed]];
    [_downloadCurrentResult setText:str];
}
-(void)addDownloadManager:(NSString *)fileName fileSize:(float)fileSize {
    _contentList = [NSArray arrayWithObjects:fileName,@"0.0M",[NSString stringWithFormat:@"%.1fM",fileSize],@"0%",nil];
    if([_contentList count] > 0) {
        [_list addObject:_contentList];
        [_downloadStateList addObject:@"0"];
    }
}
-(void) updateDownloadCell {
    for(int i=0;i<_list.count;i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
        [_downloadStateList replaceObjectAtIndex:i withObject:@"0"];
        [cell.stateImageBtn setImage:[UIImage imageNamed:@"control_pw_cancel"] forState:UIControlStateNormal];
        [cell.stateImageBtn setHidden:NO];
    }
    
    [_downloadTableView reloadData];
    
    [_downloadTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}
-(void) downloadProcessingNumber:(int)currentIndex total:(long long)total {
    [_maskView setHidden:NO];
    [_downloadManagerView setHidden:NO];
    downloadCurIndex = currentIndex;
    downloadTotal = total;
    //if(downloadCurIndex == 0) {//當下載第一個檔案
    //    downloadFailed = 0;
    //}
    if(downloadTotal < downloadCurIndex) {
        return;
    }
    if(downloadCurIndex < 0) {
        return;
    }
    downloadDone = (downloadCurIndex)-downloadFailed;
    downloadWait = downloadTotal - (downloadCurIndex);
    NSLog(@"total->    %d/%d",downloadCurIndex,downloadTotal);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *str = [delegate getStringForKey:@"SetDownloadProgressCurrentResult" withTable:@""];
        str = [str stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%d",downloadDone]];
        str = [str stringByReplacingOccurrencesOfString:@"$2$" withString:[NSString stringWithFormat:@"%d",downloadWait]];
        str = [str stringByReplacingOccurrencesOfString:@"$3$" withString:[NSString stringWithFormat:@"%d",downloadFailed]];
        [_downloadCurrentResult setText:str];
    });
}
-(void) downloadFailed {
    downloadFailed++;
    if(downloadTotal < downloadCurIndex) {
        return;
    }
    if(downloadCurIndex < 0) {
        return;
    }
    NSIndexPath *ip = [NSIndexPath indexPathForRow:downloadCurIndex inSection:0];
    DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
    if(downloadCurIndex >= _downloadStateList.count) {
        if(_downloadStateList.count == 0) {
            [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_failed"] forState:UIControlStateNormal];
            [cell.stateImageBtn setHidden:NO];
            return;
        }
        downloadCurIndex = _downloadStateList.count-1;
    }
    [_downloadStateList replaceObjectAtIndex:downloadCurIndex withObject:@"2"];
    [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_failed"] forState:UIControlStateNormal];
    [cell.stateImageBtn setHidden:NO];
    
}
-(void) downloadSuccess {
    NSIndexPath *ip = [NSIndexPath indexPathForRow:downloadCurIndex inSection:0];
    DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
    [_downloadStateList replaceObjectAtIndex:downloadCurIndex withObject:@"1"];
    [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_successed"] forState:UIControlStateNormal];
    [cell.progressSlider setValue:100];
    [cell.progressText setText:@"100%"];
    [cell.stateImageBtn setHidden:NO];
}
-(void) setDownloadProgress:(unsigned long)number Progress:(unsigned long)progress ProgressStorage:(float)progressStorage {
    if(downloadCurIndex >= _downloadStateList.count) {
        return;
    }
    if(![[_downloadStateList objectAtIndex:downloadCurIndex] isEqualToString:@"0"]) {
        return;
    }
    NSString *progressStr = [NSString stringWithFormat:@"%lu%%",progress];
    NSArray *arrayTemp;// = [[NSArray alloc] init];
    int section = 0,row = 0;
    if(number >= 0) {
        arrayTemp = [NSArray arrayWithObjects:[[_list objectAtIndex:number] objectAtIndex:0],[NSString stringWithFormat:@"%.1fM",progressStorage],[[_list objectAtIndex:number] objectAtIndex:2],progressStr,nil];
        [_list removeObjectAtIndex:number];
        [_list  insertObject:arrayTemp atIndex:number];
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:number inSection:0];
        DowmloadManagerTableViewCell *cell = (DowmloadManagerTableViewCell *)[_downloadTableView cellForRowAtIndexPath:ip];
        [cell.stateImageBtn setHidden:YES];
        [cell.progressText setText:progressStr];
        NSRange range = [progressStr rangeOfString:@"%"];
        if(range.location == NSNotFound) {
            
        } else {
            int progressInt = [[progressStr substringWithRange:NSMakeRange(0, range.location)] intValue];
            [cell.progressSlider setValue:progressInt];
            [cell.fileSize setText:[NSString stringWithFormat:@"%@/%@",[[_list objectAtIndex:number] objectAtIndex:1],[[_list objectAtIndex:number] objectAtIndex:2]]];
        }
        
        //[_downloadTableView reloadData];
    }
}
//UITableViewDataSource上的方法，
//用以表示有多少筆資料，
//在此回傳_contacts陣列的個數
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}
//UITableViewDataSource上的方法，
//回傳TableView顯示每列資料用的UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *progressStr = [[_list objectAtIndex:indexPath.row] objectAtIndex:3];
    //建立UITableViewCell物件
    DowmloadManagerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dashcamDownloadCell"];//[[UITableViewCell alloc] init];
    
    cell.stateImageBtn.tag = indexPath.row;
    [cell.stateImageBtn addTarget:self action:@selector(cancelDownloadCell:) forControlEvents:UIControlEventTouchUpInside];
    if(indexPath.row == downloadCurIndex-1) {
        [cell.stateImageBtn setHidden:YES];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //UITableViewCell有個屬性為textLabel,
    //其是⼀一個UILabel物件,
    //透過setText可設定其顯示的字樣
    [cell.fileName setText:[[_list objectAtIndex:indexPath.row] objectAtIndex:0]];
    [cell.fileSize setText:[NSString stringWithFormat:@"%@/%@",[[_list objectAtIndex:indexPath.row] objectAtIndex:1],[[_list objectAtIndex:indexPath.row] objectAtIndex:2]]];
    [cell.progressText setText:progressStr];
    cell.backgroundColor = [UIColor clearColor];
    cell.progressSlider.userInteractionEnabled = NO;
    [cell.progressSlider setMinimumValue:0];
    [cell.progressSlider setMaximumValue:100];
    
    NSRange range = [progressStr rangeOfString:@"%"];
    if(range.location == NSNotFound) {
        
    } else {
        int progressInt = [[progressStr substringWithRange:NSMakeRange(0, range.location)] intValue];
        [cell.progressSlider setValue:progressInt];
    }
    if([[_downloadStateList objectAtIndex:indexPath.row] isEqualToString:@"0"]) {
        [cell.stateImageBtn setImage:[UIImage imageNamed:@"control_pw_cancel"] forState:UIControlStateNormal];
    } else if([[_downloadStateList objectAtIndex:indexPath.row] isEqualToString:@"1"]) {
        [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_successed"] forState:UIControlStateNormal];
        [cell.progressSlider setValue:100];
        [cell.progressText setText:@"100%"];
    } else if([[_downloadStateList objectAtIndex:indexPath.row] isEqualToString:@"2"]) {
        [cell.stateImageBtn setImage:[UIImage imageNamed:@"pw_failed"] forState:UIControlStateNormal];
    }
    
    
    cell.separatorInset = UIEdgeInsetsMake(0,0,0,[UIScreen mainScreen].bounds.size.width);
    //回傳cell物件,以供UITableView顯示在畫面上
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage *scaleImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}
@end
