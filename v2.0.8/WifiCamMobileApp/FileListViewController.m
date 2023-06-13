//
//  FileListViewController.m
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/4/9.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "FileListViewController.h"
#import "PlaybackCell.h"
#import "FileCollectionViewCell.h"
#import "PlayerViewController.h"
#import "VideoFileCutViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

#import "SharedItem.h"


@interface FileListViewController ()

@property (weak, nonatomic) IBOutlet UIButton *GPS_Button;

@property (weak, nonatomic) IBOutlet UIView *NavigationBarView;
@property (weak, nonatomic) IBOutlet UISlider *PlayerSlide;
@property(nonatomic) NSTimer *PlayerTimer;
@property (assign,nonatomic) BOOL isPlay; //是否在播放(控制进度条是否移动)
@property (assign,nonatomic) BOOL Seeking;


@property (weak, nonatomic) IBOutlet UIView *GPS_View;
@property (weak, nonatomic) IBOutlet UIButton *GPS_InfoBtn;

@property (weak, nonatomic) IBOutlet UIView *GPS_InfoToolView;
@property (weak, nonatomic) IBOutlet UILabel *SpeedText;
@property (weak, nonatomic) IBOutlet UILabel *DistanceText;
@property (weak, nonatomic) IBOutlet UILabel *GSensorText;
@property (weak, nonatomic) IBOutlet UIView *ZoomIn_Btn;
@property (weak, nonatomic) IBOutlet UIButton *ZoomOut_Btn;
@property (weak, nonatomic) IBOutlet UIView *ZoomGroup;
@property (weak, nonatomic) IBOutlet UIButton *DeleteFileButton;
@property (weak, nonatomic) IBOutlet UIButton *CutButton;
@property (weak, nonatomic) IBOutlet UIButton *UnLockButton;
@property (weak, nonatomic) IBOutlet UIButton *LockButton;
@property (weak, nonatomic) IBOutlet UIButton *ShareFile;
@property (weak, nonatomic) IBOutlet UIButton *NavigationTitle;

@property (weak, nonatomic) IBOutlet UIView *LeftEditBar;
@property (weak, nonatomic) IBOutlet UIView *RightEditBar;
@property (weak, nonatomic) IBOutlet UIButton *Edit_Select_button;
@property (weak, nonatomic) IBOutlet UIView *YesOrNo;
@property (weak, nonatomic) IBOutlet UILabel *NumberOfTitle;
@property (weak, nonatomic) IBOutlet UIButton *BackUpButton;
@property (weak, nonatomic) IBOutlet UIImageView *ListFrame;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *SpeedUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedTitleText;
@property (weak, nonatomic) IBOutlet UILabel *gsensorTitleText;
@property (weak, nonatomic) IBOutlet UILabel *distanceTitleText;
@property (weak, nonatomic) IBOutlet UIImageView *titleDownloadIV;
@property (weak, nonatomic) IBOutlet UILabel *titleDownloadText;
@property (weak, nonatomic) IBOutlet UIView *fullBackView;

@property(nonatomic) dispatch_queue_t thumbnailQueue;
@property(nonatomic) dispatch_semaphore_t mpbSemaphore;
@property (weak, nonatomic) IBOutlet UILabel *kmh;
@property(nonatomic,strong)NSBundle *bundle;
@end


@implementation FileListViewController{
    __weak IBOutlet UITableView *file_tableView;
    __weak IBOutlet UIImageView *file_previewIV;
    __weak IBOutlet UICollectionView *file_collectView;
    __weak IBOutlet UIButton *file_changeViewBT;
    __weak IBOutlet UIButton *file_changeTypeBT;
    __weak IBOutlet UIButton *file_videoPlayBT;
    __weak IBOutlet UIView *file_toolView;
    __weak IBOutlet UIButton *file_toolViewSwitchBT;
    __weak IBOutlet UIButton *Preview_ZoomButton;

    __weak IBOutlet UIButton *AutoCenterLocation;
    
    int LongPress;
    int EditButtonCurrentAction;
    NSMutableArray *fileArray;
    NSMutableArray *checkArray;
    CGSize screenSize;
    PHAsset *selectedAsset;
    bool isEdit;
    CGPoint toolViewCenter;
    CGPoint GPS_InfotoolViewCenter;
    CGPoint ZoomViewCenter;
    CGRect GPSViewFrame;
    CGRect ZoomGroupFrame;
    CGRect ListOutletFrame;
    CGRect GPSInfoViewFrame;
    NSMutableArray *check_array;
    NSMutableArray *CellPlayIndex;
    //播放器
    AVPlayer *_player;
    AVPlayerItem *item;
    //显示画面的Layer
    AVPlayerLayer *imageLayer;
    UIProgressView *progress;
    CGPoint toolviewOriPoint;
    NSMutableArray *selectURL;
    id timeObserver;
    int timercounter;
    int PlayerImageFlag;
    int count;
    NSMutableArray *fileListVideo;
    NSMutableArray *fileListImage;
    
    NSString *DocumentPath;
    NSString *CutFileName;
    NSString *DeleteFileName;
    //========GPS Data========//
    int Metadata_Serial;
    int stoc_position;
    int GPS_Total_Date;
    int current_zoomLevel;
    int GPSInvalid;
    long int per_sec_data_position[300];
    NSString *GPS_ModelName;
    NSString *GPS_ModelVersion;
    NSMutableArray *GPS_PerSecondData;
    NSMutableDictionary *GPS_Dictionary;
    bool hasGPSOffect;
    NSMutableArray *hasInfoGPSPosition;
    NSMutableArray *notHasInfoGPSPosition;
    
    GMSCameraPosition *camera;
    GMSMapView *mapView;
    GMSMarker *marker;
    GMSMarker *marker_sec;
    GMSCircle *circ;
    BOOL GPS_change_location;
    BOOL GPS_camera_animation;
    double GPS_current_Latitude;
    double GPS_current_Longitude;
    double GPS_last_Latitude;
    double GPS_last_Longitude;
   
    bool isJVCKENWOODMachine;
    
    NSString *dateFormat;
    
    CGFloat curFileNameSize;
    bool updateCellFontSize;
    bool searchMode;
    
    AppDelegate *delegate;
}

-(NSString *)translateSecsToString:(NSUInteger)secs {
    NSString *retVal = nil;
    int tempHour = 0;
    int tempMinute = 0;
    int tempSecond = 0;
    
    //NSString *hour = @"";
    NSString *minute = @"";
    NSString *second = @"";
    
    //tempHour = (int)(secs / 3600);
    tempMinute = (int)(secs / 60 - tempHour * 60);
    tempSecond = (int)(secs - (tempHour * 3600 + tempMinute * 60));
    
    //hour = [[NSNumber numberWithInt:tempHour] stringValue];
    //minute = [[NSNumber numberWithInt:tempMinute] stringValue];
    //second = [[NSNumber numberWithInt:tempSecond] stringValue];
    //hour = [@(tempHour) stringValue];
    minute = [@(tempMinute) stringValue];
    second = [@(tempSecond) stringValue];
    
   /* if (tempHour < 10) {
        hour = [@"0" stringByAppendingString:hour];
    }*/
    
    if (tempMinute < 10) {
        minute = [@"0" stringByAppendingString:minute];
    }
    
    if (tempSecond < 10) {
        second = [@"0" stringByAppendingString:second];
    }
    
    retVal = [NSString stringWithFormat:@"%@:%@", minute, second];
    
    return retVal;
}
- (NSMutableArray *)visitDirectoryList:(NSString *)path Isascending:(BOOL)isascending {
    NSArray *fileList  = [[NSFileManager defaultManager] subpathsAtPath:path];  // 取得目录下所有文件列表
    for(int i = 0 ;i < fileList.count; i++)
    {
        if([[fileList objectAtIndex:i] containsString:@".MOV"] ||
           [[fileList objectAtIndex:i] containsString:@".MP4"])
        {
            [fileListVideo addObject:[fileList objectAtIndex:i]];
        }
        else if([[fileList objectAtIndex:i] containsString:@".JPG"])
        {
            [fileListImage addObject:[fileList objectAtIndex:i]];
        }
    }
    if(_listType == 1)
    {
        fileList = [fileListImage sortedArrayUsingComparator:^(NSString *firFile, NSString *secFile) {  // 将文件列表排序
            NSString *firPath = [path stringByAppendingPathComponent:firFile];  // 获取前一个文件完整路径
            NSString *secPath = [path stringByAppendingPathComponent:secFile];  // 获取后一个文件完整路径
            NSDictionary *firFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firPath error:nil];  // 获取前一个文件信息
            NSDictionary *secFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secPath error:nil];  // 获取后一个文件信息
            id firData = [firFileInfo objectForKey:NSFileCreationDate];  // 获取前一个文件创建时间
            id secData = [secFileInfo objectForKey:NSFileCreationDate];  // 获取后一个文件创建时间
            
            if (isascending) {
                return [firData compare:secData];  // 升序
            } else {
                return [secData compare:firData];  // 降序
            }
            
        }];
    }
    else
    {
        fileList = [fileListVideo sortedArrayUsingComparator:^(NSString *firFile, NSString *secFile) {  // 将文件列表排序
            NSString *firPath = [path stringByAppendingPathComponent:firFile];  // 获取前一个文件完整路径
            NSString *secPath = [path stringByAppendingPathComponent:secFile];  // 获取后一个文件完整路径
            NSDictionary *firFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firPath error:nil];  // 获取前一个文件信息
            NSDictionary *secFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secPath error:nil];  // 获取后一个文件信息
            id firData = [firFileInfo objectForKey:NSFileCreationDate];  // 获取前一个文件创建时间
            id secData = [secFileInfo objectForKey:NSFileCreationDate];  // 获取后一个文件创建时间
            
            if (isascending) {
                return [firData compare:secData];  // 升序
            } else {
                return [secData compare:firData];  // 降序
            }
            
        }];
    }
    //______________________________________________________________________________________________________
    // 将所有文件按照日期分成数组
    
    NSMutableArray  *listArray = [NSMutableArray new];//最终数组
    NSMutableArray  *tempArray = [NSMutableArray new];//每天文件数组
    NSDateFormatter *format    = [[NSDateFormatter alloc] init];
    if([dateFormat  isEqual: @"DDMMYYYY"]) {
        format.dateFormat = @"dd-MM-yyyy";
    } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
        format.dateFormat = @"MM-dd-yyyy";
    } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
        format.dateFormat = @"yyyy-MM-dd";
    }
    
    for (NSString *fileName in fileList) {
        NSString     *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
        
        NSMutableDictionary *fileDic = [NSMutableDictionary new];
        fileDic[@"Name"] = fileName;//文件名字
        fileDic[NSFileSize] = fileInfo[NSFileSize];//文件大小
        fileDic[NSFileCreationDate] = fileInfo[NSFileCreationDate];//时间
        
        if (tempArray.count > 0) {  // 获取日期进行比较, 按照 XXXX 年 XX 月 XX 日来装数组
            NSString *currDate = [format stringFromDate:fileInfo[NSFileCreationDate]];
            NSString *lastDate = [format stringFromDate:tempArray.lastObject[NSFileCreationDate]];
            
            if (![currDate isEqualToString:lastDate]) {
                [listArray addObject:tempArray];
                tempArray = [NSMutableArray new];
            }
        }
        [tempArray addObject:fileDic];
    }
    
    if (tempArray.count > 0) {  // 装载最后一个 array 数组
        [listArray addObject:tempArray];
    }
    
    //NSLog(@"visitDirectoryList = %@", listArray);
    return listArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    
    if([[delegate getDateFormat]  isEqual: @"DDMMYYYY"]) {
        dateFormat = @"DDMMYYYY";
    } else if([[delegate getDateFormat]  isEqual: @"MMDDYYYY"]) {
        dateFormat = @"MMDDYYYY";
    } else if([[delegate getDateFormat]  isEqual: @"YYYYMMDD"]) {
        dateFormat = @"YYYYMMDD";
    } else {
        dateFormat = @"DDMMYYYY";
    }
    
    [self.speedTitleText setText:[delegate getStringForKey:@"MapSpeed" withTable:@""]];
    [self.gsensorTitleText setText:[delegate getStringForKey:@"MapGSensor" withTable:@""]];
    [self.distanceTitleText setText:[delegate getStringForKey:@"MapDistance" withTable:@""]];
    /*self.SIGN.translatesAutoresizingMaskIntoConstraints = true;
    self.SpeedText.translatesAutoresizingMaskIntoConstraints = true;
    self.DistanceText.translatesAutoresizingMaskIntoConstraints = true;
    self.GSensorText.translatesAutoresizingMaskIntoConstraints = true;*/
    //self.SpeedUnitLabel.adjustsFontSizeToFitWidth = YES;
    
    _okBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _cancelBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _okBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    _cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(0.001, 0, 0.001, 0);
    /*self.GSensorText.adjustsFontSizeToFitWidth = YES;*/

    CGFloat FontSize = self.GSensorText.font.pointSize;
     self.SpeedText.font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:FontSize];
     self.DistanceText.font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:FontSize];
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [file_tableView addGestureRecognizer:lpgr];

    

    GPS_PerSecondData = [[NSMutableArray alloc] init];
    GPS_Dictionary = [[NSMutableDictionary alloc] init];
    //file_toolView.hidden = YES;
    self.GPS_InfoToolView.hidden = YES;
    self.ZoomGroup.hidden = YES;
    self.GPS_View.hidden = YES;
    
    [AutoCenterLocation.layer setCornerRadius:5];
    AutoCenterLocation.hidden = YES;
    [file_previewIV setUserInteractionEnabled:YES];
    [file_previewIV addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPreview:)]];
    selectURL = [[NSMutableArray alloc] init];
    
    
    //if(!_listType){
        _listType = 0;
    //}
    
    if(!_viewType){
        _viewType = 0;
    }
    GPS_change_location = NO;
    _player.muted = NO;// 静音
    toolViewCenter.x = file_toolView.center.x;
    toolViewCenter.y = file_toolView.center.y;
    toolViewCenter = file_toolView.center;
    GPS_InfotoolViewCenter.x = self.GPS_InfoToolView.center.x;
    GPS_InfotoolViewCenter.y = self.GPS_InfoToolView.center.y;
    GPS_InfotoolViewCenter = self.GPS_InfoToolView.center;
     ZoomViewCenter.x = self.ZoomGroup.center.x;
     ZoomViewCenter.y = self.ZoomGroup.center.y;
    ZoomViewCenter = self.ZoomGroup.center;
   
    UIImage *image3 = [UIImage imageNamed:@"control_seekbar_ball"];
    
    UIImage *image4 =[self imageWithImage:image3 scaledToSize:CGSizeMake(image3.size.width/2, image3.size.height/2)];
    [_PlayerSlide setThumbImage:image4 forState:UIControlStateNormal];
    [_PlayerSlide setThumbImage:image4 forState:UIControlStateHighlighted];
    
    [_PlayerSlide addTarget:self action:@selector(sliderTouchUpInside:)
           forControlEvents:UIControlEventTouchUpInside];
    [_PlayerSlide addTarget:self action:@selector(sliderValueChanged:)
           forControlEvents:UIControlEventValueChanged];
    [_PlayerSlide addTarget:self action:@selector(sliderTouchDown:)
           forControlEvents:UIControlEventTouchDown];

    check_array = [[NSMutableArray alloc] init];
    CellPlayIndex = [[NSMutableArray alloc] init];
    screenSize = [[UIScreen mainScreen] bounds].size;

    
    
    [file_videoPlayBT setImage:[UIImage imageNamed:@"control_play"] forState:UIControlStateNormal];
    [file_videoPlayBT setImage:[UIImage imageNamed:@"control_pause"] forState:UIControlStateSelected];
    
    [_GPS_Button setImage:[UIImage imageNamed:@"control_changemode_map"] forState:UIControlStateNormal];
    [_GPS_Button setImage:[UIImage imageNamed:@"control_changemode_map_select"] forState:UIControlStateSelected];

    /*[UIView animateWithDuration:0.5
                     animations:^(void){
                         self.GPS_InfoToolView.center = CGPointMake(self.GPS_InfoToolView.center.x+200,self.GPS_InfoToolView.center.y);
                     }
                     completion:^(BOOL finished) {
                         
                     }
     ];*/
    fileArray = [NSMutableArray new];
    checkArray = [NSMutableArray new];
    //[self setToolView];
   

    [self GPSMapViewInit];
    

    //[self setCheckArray];
    
    file_videoPlayBT.hidden = YES;
    
    if(_viewType == 0){
        file_tableView.hidden = NO;
        file_collectView.hidden = YES;
    }
    else{
        file_collectView.hidden = YES;
        file_tableView.hidden = NO;
    }
    /*self.NavigationTitle.text = NSLocalizedString(@"SetLocalVideoFile", @"");*/
    file_tableView.backgroundColor = [UIColor clearColor];
    file_tableView.backgroundView = nil;
    file_tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    file_tableView.tableFooterView = [[UIView alloc] init];



    self.DeleteFileButton.userInteractionEnabled = NO;
    self.ShareFile.userInteractionEnabled = NO;
    
    self.CutButton.userInteractionEnabled = NO;
    self.UnLockButton.userInteractionEnabled = NO;
    self.LockButton.userInteractionEnabled = NO;
    
    [self.titleDownloadText setText:[delegate getStringForKey:@"SetLocalVideoFile" withTable:@""]];
    //[_NavigationTitle setTitle:NSLocalizedString(@"SetLocalVideoFile", @"") forState:UIControlStateNormal];
    /*_NavigationTitle.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    _NavigationTitle.imageEdgeInsets = UIEdgeInsetsMake(0.001, -16, 0.001, 32);
    _NavigationTitle.titleEdgeInsets = UIEdgeInsetsMake(0, -56, 0, 0);
    _NavigationTitle.titleLabel.adjustsFontSizeToFitWidth = YES;*/
    //_NavigationTitle.titleLabel.font = [UIFont italicSystemFontOfSize:[UIFont labelFontSize]];

    
    self.GPS_InfoBtn.hidden = YES;
    self.LeftEditBar.hidden = YES;
    self.RightEditBar.hidden = YES;
    file_tableView.scrollEnabled = YES;
    self.YesOrNo.hidden = YES;
     EditButtonCurrentAction = EditNone;
    //file_tableView.bounces = NO;
    [self.LockButton setImage:[UIImage imageNamed:@"control_lock"] forState:UIControlStateNormal];
    
    [self.LockButton setImage:[UIImage imageNamed:@"control_lock_select"] forState:UIControlStateSelected];
    
    [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock"] forState:UIControlStateNormal];
    
    [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock_select"] forState:UIControlStateSelected];
    
    [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete"] forState:UIControlStateNormal];
    
    [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete_select"] forState:UIControlStateSelected];
    
    [self.ShareFile setImage:[UIImage imageNamed:@"control_share"] forState:UIControlStateNormal];
    
    [self.ShareFile setImage:[UIImage imageNamed:@"control_share_select"] forState:UIControlStateSelected];
    
    [self.CutButton setImage:[UIImage imageNamed:@"control_cut"] forState:UIControlStateNormal];
    
    [self.CutButton setImage:[UIImage imageNamed:@"control_cut_select"] forState:UIControlStateSelected];
    
    [self.GPS_InfoBtn setImage:[UIImage imageNamed:@"control_map_info"] forState:UIControlStateNormal];
    [self.GPS_InfoBtn setImage:[UIImage imageNamed:@"control_map_info_select"] forState:UIControlStateSelected];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.PlayerTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimeInfo:) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(__playerItemDidPlayToEndTimeNotification:)
                                                name:AVPlayerItemDidPlayToEndTimeNotification
                                              object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
#if 1
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    DocumentPath = [path stringByAppendingString:@"/KENWOOD DASH CAM MANAGER"];
    //path    NSPathStore2 *    "/var/mobile/Containers/Data/Application/6C4B80B8-2752-481A-8DE4-7C868B10FF3B/Documents"    0x000000028230d440

    fileListVideo = [[NSMutableArray alloc] init];
    fileListImage = [[NSMutableArray alloc] init];

    if(_listType == 1)
    {
        fileListImage = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    else
    {
        fileListVideo = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    //NSLog(@"fileList = %@",fileListVideo);
    
#endif
    //[[[fileListVideo objectAtIndex:section] objectAtIndex:0] objectForKey:NSFileCreationDate]
    [file_tableView reloadData];
    //set cell filename size
    [self setCellFileNameSize];
    
}
-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self _shouldRotateToOrientation:(UIDeviceOrientation)[UIApplication sharedApplication].statusBarOrientation];
    
    
}
-(void)_shouldRotateToOrientation:(UIDeviceOrientation)orientation {
    if (orientation == UIDeviceOrientationPortrait ||orientation ==
        UIDeviceOrientationPortraitUpsideDown) { // 竖屏
        if(_GPS_Button.selected)
        {
            if(self.GPS_InfoBtn.selected)
            {
                if(self.GPS_View.tag)
                {
                    self.GPS_View.frame = GPSViewFrame;
                    self.ListFrame.frame =ListOutletFrame;
                    
                    self.ZoomGroup.frame = ZoomGroupFrame;
                    GPSViewFrame = self.GPS_View.frame;
                    ListOutletFrame = self.ListFrame.frame;
                    ZoomGroupFrame = self.ZoomGroup.frame;
                    
                    self.GPS_InfoToolView.hidden = NO;
                }
            }
        }
    }
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    toolViewCenter.x = file_toolView.center.x;
    toolViewCenter.y = file_toolView.center.y;
    toolViewCenter = file_toolView.center;
    isEdit = false;
    //[self setToolView];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
}
-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.PlayerTimer invalidate];
    self.PlayerTimer = nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    NSLog(@"**DEALLOC**");
    
}
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
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
- (void)RunForeachTableView:(NSIndexPath *)CurrentIndex
{
    long int section = [file_tableView numberOfSections];
    
    for (int i = 0;i<section;i++) {
        long int row = [file_tableView numberOfRowsInSection:i];
        for(int j=0;j<row;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            
            if(ip == CurrentIndex)
            {
                cell.PlayIcon.hidden = NO;
            }
            else
            {
                cell.PlayIcon.hidden = YES;
            }
        }
    }
}
- (void)setToolView
{
    self.NumberOfTitle.hidden = YES;
    //self.NavigationTitle.hidden = NO;
    self.titleDownloadIV.hidden = NO;
    self.titleDownloadText.hidden = NO;
    self.BackUpButton.userInteractionEnabled = YES;
    [self.BackUpButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
    
    if(isEdit){
        NSLog(@"change to not edit");
        long int section = [file_tableView numberOfSections];
        
        for (int i = 0;i<section;i++) {
            long int row = [file_tableView numberOfRowsInSection:i];
            for(int j=0;j<row;j++)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];

                cell.cellBack.hidden = YES;
                cell.tag = 0;
            }
        }
        [check_array removeAllObjects];
        [self setCheckArray];
        
        isEdit = false;
        LongPress = 0;
        file_toolView.hidden = NO;
        /*file_toolViewSwitchBT.hidden = YES;
        file_changeTypeBT.hidden = YES;*/
        self.GPS_Button.hidden = NO;
        file_changeTypeBT.hidden = NO;
        self.GPS_InfoBtn.hidden = YES;
        self.LeftEditBar.hidden = YES;
        self.RightEditBar.hidden = YES;
        self.YesOrNo.hidden = YES;
        EditButtonCurrentAction = EditNone;
        self.CutButton.selected = 0;
        self.LockButton.selected = 0;
        self.UnLockButton.selected = 0;
        self.ShareFile.selected = 0;
        self.DeleteFileButton.selected = 0;
        
    }
    else{
        self.GPS_Button.hidden = YES;
        self.GPS_InfoBtn.hidden = YES;
         self.GPS_Button.hidden = YES;
        long int section = [file_tableView numberOfSections];
        
        for (int i = 0;i<section;i++) {
            long int row = [file_tableView numberOfRowsInSection:i];
            for(int j=0;j<row;j++)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];

                cell.tag = 0;
            }
        }
        
        [check_array removeAllObjects];
        
        [self setCheckArray];
        NSLog(@"ichange to edit");
        
        isEdit = true;
        
        
        self.LeftEditBar.hidden = NO;
        self.RightEditBar.hidden = NO;
        /*
        file_toolViewSwitchBT.hidden = NO;
        file_changeTypeBT.hidden = NO;
         */
        
        file_toolView.hidden = YES;
       
        file_changeTypeBT.hidden = YES;
        
        
    }
}

- (void)getPhotoAblum
{
    //PHFetchOptions: 获取资源时的参数，可以传 nil，即使用系统默认值
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    //根據照片的建立日期進行排序
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    //options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",_listType];
    
    //PHFetchResult : 从一个Photos的获取方法中返回的有序的资源或者集合的列表
    // 获取所有用户创建相册
    PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    //图像请求是通过 requestImageForAsset(...) 方法派发的。这个方法接受一个 PHAsset，可以设置返回图像的大小和图像的其它可选项 (通过 PHImageRequestOptions 参数对象设置)
    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
    
    [fileArray removeAllObjects];
    
    for(NSInteger i=0;i<userAlbums.count;i++) {
        PHCollection *collection = userAlbums[i];
        
        if ([collection.localizedTitle isEqualToString:@"iQViewer"]) {
            PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
            for(NSInteger j=0;j<fetchResult.count;j++){
                PHAsset *fetchAsset = fetchResult[j];
                NSLog(@"file type = %ld",(long)fetchAsset.mediaType);
                if(fetchAsset.mediaType == _listType){
                    [fileArray addObject:fetchAsset];
                }
            }
        }
    }
    //NSLog(@"rrrrr%@",[[fileArray objectAtIndex:1] modificationDate]);
    //NSURL *referenceURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    /*PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:assetURL] options:nil];
     PHAsset *videoAsset = (PHAsset*)fetchResult.firstObject;
     PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:videoAsset] firstObject];
     long long originFileSize = [[resource valueForKey:@"fileSize"] longLongValue];
     int fileSize = (int)originFileSize;
     int fileSize_MB = [[TVUCompareSpaceTool getInstance] convertVideoSizeFromByteToMB:fileSize];*/
    /*PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
     [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     PHAssetCollection *assetCollection = obj;
     if ([assetCollection.localizedTitle isEqualToString:@"iQViewer"])  {
     PHFetchResult *assetResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:[PHFetchOptions new]];
     [assetResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
     //获取相册的最后一张照片
     if (idx == [assetResult count] - 1) {
     [PHAssetChangeRequest deleteAssets:@[obj]];
     }
     } completionHandler:^(BOOL success, NSError *error) {
     NSLog(@"Error: %@", error);
     }];
     }];
     }
     }];*/
    
    
    
    
    NSLog(@"fileArray.count = %lu",(unsigned long)fileArray.count);
    
}

-(void)setCheckArray{
   /* checkArray = [NSMutableArray new];

    long int section = [file_tableView numberOfSections];
    
    for (int i=0;i<section;i++) {
        long int row = [file_tableView numberOfRowsInSection:i];
        for(int j = 0;j<row;j++)
        {
            checkArray[i][j] = [NSNumber numberWithBool:NO];
        }
    }*/
    [check_array removeAllObjects];

}

- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self getPhotoAblum];
        //[checkArray removeAllObjects];
        [self setCheckArray];
        [file_tableView reloadData];
        [file_collectView reloadData];
    });
}
/*
 if(_curMpbMediaType == MpbMediaTypePhoto)
 {
 return _FileListPhotoProperty.count;
 }
 else
 {
 return _FileListVideoProperty.count;
 }*/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if(_listType == 1)
        return [fileListImage count];
    else
        return [fileListVideo count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_listType == 1)
    {
        return [[fileListImage objectAtIndex:section] count];
    }
    else
    {
        return [[fileListVideo objectAtIndex:section] count];
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(_listType == 1)
    {
        if(fileListImage != nil)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           
            if([dateFormat  isEqual: @"DDMMYYYY"]) {
                [dateFormatter setDateFormat:@"ddMMyyyy"];
            } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                [dateFormatter setDateFormat:@"MMddyyyy"];
            } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                [dateFormatter setDateFormat:@"yyyyMMdd"];
            }
            
            //NSLog(@"%@",[dateFormatter stringFromDate:[[[fileListImage objectAtIndex:section] objectAtIndex:0] objectForKey:NSFileCreationDate]]);
            return [[dateFormatter stringFromDate:[[[fileListImage objectAtIndex:section] objectAtIndex:0] objectForKey:NSFileCreationDate]] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        if(fileListVideo != nil)
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            if([dateFormat  isEqual: @"DDMMYYYY"]) {
                [dateFormatter setDateFormat:@"ddMMyyyy"];
            } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                [dateFormatter setDateFormat:@"MMddyyyy"];
            } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                [dateFormatter setDateFormat:@"yyyyMMdd"];
            }
            return [[dateFormatter stringFromDate:[[[fileListVideo objectAtIndex:section] objectAtIndex:0] objectForKey:NSFileCreationDate]] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
            /*str = [str stringByReplacingOccurrencesOfString:@"string" withString:@"duck"];*/
        }
        else
        {
            return nil;
        }
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle==nil) {
        return nil;
    }
    
    // Create header view and add label as a subview

    
    UILabel *label=[[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, file_tableView.frame.size.width, file_tableView.sectionHeaderHeight);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
   
    label.font = [UIFont fontWithName:@"Frutiger LT 45 Light" size:18];
    //label.transform = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
    
    label.adjustsFontSizeToFitWidth = YES;
    label.text = sectionTitle;
    
    UIView *underLine = [[UIView alloc] initWithFrame:CGRectMake(0, file_tableView.sectionHeaderHeight-2, tableView.bounds.size.width, 2)];
    [underLine setBackgroundColor:[UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1]];
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, file_tableView.sectionHeaderHeight)];
    
    
    //[sectionView setBackgroundColor:[UIColor whiteColor]];
    [sectionView setBackgroundColor:[UIColor clearColor]];

    [sectionView addSubview:label];
    [sectionView addSubview:underLine];
    return sectionView;
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PlaybackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlaybackCell" forIndexPath:indexPath];
    //adj font size
    UIFont *font;
    cell.FileName.adjustsFontSizeToFitWidth = YES;
    font = [self adjFontSize:cell.FileName];
    cell.FileName.font = [font fontWithSize:curFileNameSize];
    cell.PhotoCreateTime.font = [font fontWithSize:(curFileNameSize-5.0)];
    cell.FileLenth.font = [font fontWithSize:(curFileNameSize-5.0)];
    cell.FileSize.font = [font fontWithSize:(curFileNameSize-5.0)];
    
    cell.Filethumbnail.image = [UIImage imageNamed:@"pictures_no"];

    cell.cellBack.hidden = YES;
    cell.PlayIcon.hidden = YES;
    if(_listType == 1)
    {
        if(fileListImage.count > 0)
        {
            NSData *data = [NSData dataWithContentsOfFile:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
            
            cell.Filethumbnail.image = [UIImage imageWithData:data];
            
            NSError *error;
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
            
            if (fileAttributes != nil) {
                NSDateFormatter *format    = [[NSDateFormatter alloc] init];
                NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];
               /* NSString *fileOwner = [fileAttributes objectForKey:NSFileOwnerAccountName];
                NSDate *fileModDate = [fileAttributes objectForKey:NSFileModificationDate];*/
                NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
                NSString *Protect = [fileAttributes objectForKey:NSFileProtectionKey];
                if([Protect isEqualToString:@"NSFileProtectionComplete"])
                {
                    cell.LockBox.hidden = NO;
                }
                else
                {
                    cell.LockBox.hidden = YES;
                }

                if([dateFormat  isEqual: @"DDMMYYYY"]) {
                    format.dateFormat = @"dd-MM-yyyy HH:mm:ss";
                } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                    format.dateFormat = @"MM-dd-yyyy HH:mm:ss";
                } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                    format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                }
                NSString *creationTime = [format stringFromDate:fileCreateDate];
                NSString *creationTime2 = [creationTime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
                cell.PhotoCreateTime.text = creationTime2;
                cell.FileSize.text = [NSString stringWithFormat:@"%.2f MB",((double)([fileSize unsignedLongLongValue])/1000/1000)];
            }
            cell.FileName.text = [[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"];
        }
        cell.FileLenth.hidden = YES;
    }
    else
    {
        //[self RunForeachTableView:indexPath];
        NSError *error;
         NSURL *videoURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
        // AVPlayer *player = [AVPlayer playerWithURL:videoURL];
        AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        AVAssetImageGenerator  *imageGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        if (imageGen) {
            imageGen.appliesPreferredTrackTransform = YES;
            CMTime actualTime;
            CGImageRef cgImage = [imageGen copyCGImageAtTime:CMTimeMakeWithSeconds(0, 30) actualTime:&actualTime error:NULL];
            if (cgImage) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithCGImage:cgImage];
                cell.Filethumbnail.image = image;
                CGImageRelease(cgImage);
                     });
            }
        }
        });

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
        
        if (fileAttributes != nil) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize];

            NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
            NSString *Protect = [fileAttributes objectForKey:NSFileProtectionKey];
            if([Protect isEqualToString:@"NSFileProtectionComplete"])
            {
                cell.LockBox.hidden = NO;
            }
            else
            {
                cell.LockBox.hidden = YES;
            }
            if (fileSize) {
                cell.FileSize.text = [NSString stringWithFormat:@"%.2f MB",((double)([fileSize unsignedLongLongValue])/1000/1000)];
                //NSLog(@"File size: %qi\n", [fileSize unsignedLongLongValue]);
            }

            if (fileCreateDate) {
                //NSLog(@"create date:%@\n", fileCreateDate);
            }
            if([dateFormat  isEqual: @"DDMMYYYY"]) {
                format.dateFormat = @"dd-MM-yyyy HH:mm:ss";
            } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                format.dateFormat = @"MM-dd-yyyy HH:mm:ss";
            } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                format.dateFormat = @"yyyy-MM-dd HH:mm:ss";
            }
            NSString *creationTime = [format stringFromDate:fileCreateDate];
            NSString *creationTime2 = [creationTime stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
             cell.PhotoCreateTime.text = creationTime2;
        }

        cell.FileName.text = [[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"];
        
        cell.FileLenth.text = [NSString stringWithFormat:@"%@",[self translateSecsToString:(int)(CMTimeGetSeconds(asset.duration))]];
        
        cell.FileLenth.hidden = NO;
    }
    
    if(!isEdit)
    {
        cell.cellBack.hidden = YES;
    }
    else
    {
        if([check_array containsObject:indexPath])
        {
            UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
            
            view_bg.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.298];
            
            cell.selectedBackgroundView = view_bg;
            cell.cellBack.hidden = NO;
        }
    }
    if(_listType != 1) {
        if([CellPlayIndex containsObject:indexPath])
        {
            cell.PlayIcon.hidden = NO;
        }
        else
        {
            cell.PlayIcon.hidden = YES;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaybackCell *cell = (PlaybackCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    NSString *Title;
    NSString *SelectedTotal;
    
    
    [self.PlayerTimer setFireDate:[NSDate distantFuture]];
    

    timercounter = 0;
    if(PlayerImageFlag)
    {
        //not hidden
        PlayerImageFlag = 0;
        self.PlayerSlide.hidden = NO;
        Preview_ZoomButton.hidden = NO;
        file_videoPlayBT.hidden = NO;
        if(isEdit == false)
            self.GPS_InfoBtn.hidden = NO;
    }

    if(isEdit == false)
    {
        Metadata_Serial = NoneSerial;
        if(_listType == 1){
            
            file_previewIV.layer.sublayers = nil;
            file_videoPlayBT.hidden = YES;
            NSData *data = [NSData dataWithContentsOfFile:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
            file_previewIV.image = [UIImage imageWithData:data];
        }
        else
        {
            [self showProgressHUDWithMessage:NSLocalizedString(@"LOAD_SETTING_DATA", nil)];
            
            if([CellPlayIndex count])
            {
                PlaybackCell *cellpreSelect = (PlaybackCell *)[tableView cellForRowAtIndexPath:[CellPlayIndex objectAtIndex:0]];
                [CellPlayIndex removeAllObjects];
                cellpreSelect.PlayIcon.hidden = YES;
            }
            
            [CellPlayIndex addObject:indexPath];
            cell.PlayIcon.hidden = NO;
            //[self RunForeachTableView:indexPath];
            
             [_player pause];
            //file_previewIV.layer.sublayers = nil;
            
            file_videoPlayBT.selected = 0;
            _PlayerSlide.value = 0;
            [_player seekToTime:kCMTimeZero]; // seek to zero
            if(self.isPlay)
            {
                [_player removeTimeObserver:timeObserver];
                timeObserver = nil;
                self.isPlay = NO;
            }
            file_videoPlayBT.hidden = NO;
            
            NSURL *videoURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];

            AVURLAsset *asset = [AVURLAsset assetWithURL:videoURL];
            
            _PlayerSlide.maximumValue = (int)(CMTimeGetSeconds(asset.duration));
                item = [AVPlayerItem playerItemWithURL:videoURL];
                
                _player = [AVPlayer playerWithPlayerItem:item];
                dispatch_async(dispatch_get_main_queue(), ^{
                    /*file_previewIV.hidden = YES;
                     _PlayerVIewIV.hidden = NO;*/
                    imageLayer   = [AVPlayerLayer playerLayerWithPlayer:_player];
                    imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
                    
                    //2.设置frame
                    imageLayer.frame = file_previewIV.frame;
                    //3.添加到界面上
                    //==================显示图像========================
                    [file_previewIV.layer addSublayer:imageLayer];
                    
                    //[self hideProgressHUD:YES];
                });
                if(fileListVideo != nil)
                {
                    #if 1
                    Metadata_Serial = [self CheckSeries:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];

                    if(Metadata_Serial != NoneSerial)
                    {
                        [self ResetGPS_Variable];
                        if(Metadata_Serial == trim)
                        {
                            GPS_change_location = YES;
                            [self trim_find_CC:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];
                            [self trim_find_CC_PerSecond_Save:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];
                        }
                        else if(Metadata_Serial == Novatake_6x || Metadata_Serial == Novatake_5x || Metadata_Serial == Novatake_7x)
                        {
                            GPS_change_location = YES;
                            [self Nvt_stco_find:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];
                            [self Nvt_gps_PerSecond_Save:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];
                        }
                        else if(Metadata_Serial == ICatchSerial)
                        {
                            GPS_change_location = YES;
                
                            int VideoLength = VideoLength = ([[cell.FileLenth.text substringWithRange:NSMakeRange(0, 2)] intValue])*60 +([[cell.FileLenth.text substringWithRange:NSMakeRange(3, 2)] intValue]);
                            
                            [self ICatch_Udat_find:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"] FileLength:VideoLength];
                            [self ICatch_gps_PerSecond_Save:Metadata_Serial FileName:[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]];
                            
                        }
                    }
                    #endif
                }
                [self hideProgressHUD:YES];
            //}];
        }
        
    }
    else
    {
        bool isSelected = false;
        for(int i=0;i<check_array.count;i++) {
            //NSLog(@"index ->  ok  %ld   %ld",(long)indexPath.section,(long)indexPath.row);
            NSIndexPath *curIndex = [check_array objectAtIndex:i];
            if(curIndex.section== indexPath.section &&
               curIndex.row == indexPath.row) {
                isSelected = true;
            }
        }

        
        if (isSelected == true) { // It's selected.
            //isSelected = false;
            [check_array removeObject:indexPath];
            
            //  checkArray[indexPath.section][indexPath.row] = [NSNumber numberWithBool:NO];
            //[cell.CheckBox setImage:[UIImage imageNamed:@"check_off"]];

            cell.cellBack.hidden = YES;
        } else {
            //isSelected = true;
            [check_array addObject:indexPath];

            UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
            
            view_bg.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.298];
            
            cell.selectedBackgroundView = view_bg;

            cell.cellBack.hidden = NO;
         //   checkArray[indexPath.section][indexPath.row] = [NSNumber numberWithBool:NO];
            /*[cell.CheckBox setImage:[UIImage imageNamed:@"click_ok"]];
            cell.cellBack.hidden = NO;*/
        }
        if(check_array.count > 0)
        {
        self.DeleteFileButton.userInteractionEnabled = YES;
            [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete"] forState:UIControlStateNormal];
            self.ShareFile.userInteractionEnabled = YES;
            [self.ShareFile setImage:[UIImage imageNamed:@"control_share"] forState:UIControlStateNormal];
            
            self.LockButton.userInteractionEnabled = YES;
            [self.LockButton setImage:[UIImage imageNamed:@"control_lock"] forState:UIControlStateNormal];
            
            self.UnLockButton.userInteractionEnabled = YES;
            [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock"] forState:UIControlStateNormal];

        }
        else
        {
            self.DeleteFileButton.userInteractionEnabled = NO;
            [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete_disable"] forState:UIControlStateNormal];
            self.ShareFile.userInteractionEnabled = NO;
             [self.ShareFile setImage:[UIImage imageNamed:@"control_share_disable"] forState:UIControlStateNormal];
            
            self.LockButton.userInteractionEnabled = NO;
            [self.LockButton setImage:[UIImage imageNamed:@"control_lock_disable"] forState:UIControlStateNormal];
            
            self.UnLockButton.userInteractionEnabled = NO;
            [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock_disable"] forState:UIControlStateNormal];
        }
        
        if(_listType != 1)
        {
            if(check_array.count == 1)
            {
                [self.CutButton setImage:[UIImage imageNamed:@"control_cut"] forState:UIControlStateNormal];
                self.CutButton.userInteractionEnabled = YES;
            }
            else
            {
                
                self.CutButton.userInteractionEnabled = NO;
                self.CutButton.selected = 0;
                //self.YesOrNo.hidden = YES;
                [self.CutButton setImage:[UIImage imageNamed:@"control_cut_disable"] forState:UIControlStateNormal];
            }
        }
        
        if(_listType == 1)
        {
            if([check_array count] <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
            }
        }
        else
        {
            if([check_array count] <= 1) {
                SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
            } else {
                SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
            }
        }
        Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];//[NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];
        self.NumberOfTitle.text = Title;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return fileArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FileCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
    
    if (fileArray.count) {
        
      //  BOOL check=[[checkArray objectAtIndex:indexPath.row] boolValue];
        
       /* if(check){
            cell.file_cell_checkIV.hidden = NO;
        }
        else{
            cell.file_cell_checkIV.hidden = YES;
        }*/
        
        PHAsset *tmpAsset = fileArray[indexPath.row];
        [[PHImageManager defaultManager]
         requestImageForAsset:(PHAsset *)tmpAsset
         targetSize:CGSizeMake(tmpAsset.pixelWidth, tmpAsset.pixelHeight)
         contentMode:PHImageContentModeAspectFit
         options:nil
         resultHandler:^(UIImage *result, NSDictionary *info) {
             cell.file_cellIV.image = result;
         }];
        
        [cell.file_cellBT addTarget:self action:@selector(cellClick:withEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return  CGSizeMake((screenSize.width /3),(screenSize.width / 3));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}



-(void)checkClick:(UIButton*)sender withEvent:(UIEvent*)event{
    //int checkTemp=0;
    NSSet *set=[event allTouches];
    UITouch *touch=[set anyObject];
    CGPoint point=[touch locationInView:file_tableView];
    NSIndexPath *indexPath=[file_tableView indexPathForRowAtPoint:point];
    PlaybackCell *cell=[file_tableView cellForRowAtIndexPath:indexPath];
    /*if ([checkArray[indexPath.section][indexPath,row] boolValue]) {
        [cell.checkBT setBackgroundImage:[UIImage imageNamed:@"icon_checkbox"] forState:UIControlStateNormal];
        [checkArray[indexPath.section][indexPath.row] replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
    }else{
        [cell.checkBT setBackgroundImage:[UIImage imageNamed:@"icon_check"] forState:UIControlStateNormal];
        [checkArray replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
    }*/
    
    //NSLog(@"file list indexPath = %d",indexPath);
    
}


-(void)preview:(id)sender withEvent:(UIEvent*)event{
    NSSet *set=[event allTouches];
    UITouch *touch=[set anyObject];
    CGPoint point=[touch locationInView:file_tableView];
    NSIndexPath *indexPath=[file_tableView indexPathForRowAtPoint:point];
    
    selectedAsset = fileArray[indexPath.row];
    [[PHImageManager defaultManager]
     requestImageForAsset:(PHAsset *)selectedAsset
     targetSize:CGSizeMake(selectedAsset.pixelWidth, selectedAsset.pixelHeight)
     contentMode:PHImageContentModeAspectFit
     options:nil
     resultHandler:^(UIImage *result, NSDictionary *info) {
         file_previewIV.image = result;
     }];
    
    if(_listType == 1){
        file_videoPlayBT.hidden = YES;
    }
    else{
        file_videoPlayBT.hidden = NO;
    }
}

-(void)cellClick:(id)sender withEvent:(UIEvent*)event{
    NSSet *set=[event allTouches];
    UITouch *touch=[set anyObject];
    CGPoint point=[touch locationInView:file_collectView];
    NSIndexPath *indexPath=[file_collectView indexPathForItemAtPoint:point];
    //FileCollectionViewCell *cell = [file_collectView cellForItemAtIndexPath:indexPath];
    
    selectedAsset = fileArray[indexPath.row];
    [[PHImageManager defaultManager]
     requestImageForAsset:(PHAsset *)selectedAsset
     targetSize:CGSizeMake(selectedAsset.pixelWidth, selectedAsset.pixelHeight)
     contentMode:PHImageContentModeAspectFit
     options:nil
     resultHandler:^(UIImage *result, NSDictionary *info) {
         file_previewIV.image = result;
     }];
    
    if(_listType == 1){
        file_videoPlayBT.hidden = YES;
    }
    else{
        file_videoPlayBT.hidden = NO;
    }
    
    if(isEdit){
        NSLog(@"is edit");
        /*BOOL cellChecked=[[checkArray objectAtIndex:indexPath.row] boolValue];
        if(cellChecked){
            checkArray[indexPath.row]=[NSNumber numberWithBool:NO];
            cell.file_cell_checkIV.hidden = YES;
        }
        else{
            checkArray[indexPath.row]=[NSNumber numberWithBool:YES];
            cell.file_cell_checkIV.hidden = NO;
        }*/
        //[file_collectView reloadData];
    }
    
}

- (IBAction)file_videoPlayBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(file_videoPlayBT.selected)
    {
        [self.PlayerTimer setFireDate:[NSDate distantFuture]];
        timercounter = 0;
        file_videoPlayBT.selected = !file_videoPlayBT.selected;
        [_player pause];
        self.isPlay = NO;
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    else
    {
        
        [self.PlayerTimer setFireDate:[NSDate distantPast]];
        file_videoPlayBT.selected = !file_videoPlayBT.selected;
        [_player play];
        self.isPlay = YES;
        
        __block FileListViewController *blockSelf = self;
        __block AVPlayer *blockPlayer = _player;
        __block NSMutableArray *GPSDictionary = GPS_PerSecondData;
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
                    
                    CMTime duration = blockPlayer.currentItem.duration;
                    CGFloat durationSec = CMTimeGetSeconds(duration);
                    //NSLog(@"总时长：%f",durationSec);
                    blockSelf.PlayerSlide.maximumValue = durationSec;
                    // 统计当前播放时长
                    CMTime current = blockPlayer.currentItem.currentTime;
                    CGFloat currentSec = CMTimeGetSeconds(current);
                    //NSLog(@"当前时间：%f",currentSec);
                    
                    // 刷新播放进度
                    [blockSelf.PlayerSlide setValue:currentSec animated:YES];
                    //刷新GPS
                    if(currentSec < GPS_Total_Date)
                    {
                        [blockSelf updateGPSMap:GPSDictionary sec:(int)currentSec];
                    }
                }
            }
        }];
    }
}



- (IBAction)file_backBT_clicked:(id)sender {
    if(isEdit)
    {
        [self file_toolSwitchBT_clicked:(id)0];
    }
    else
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.allowRotation = NO;
        UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
        if((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight))
        {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }

        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (IBAction)ActionOK:(id)sender {
    self.YesOrNo.hidden = YES;
    self.BackUpButton.userInteractionEnabled = YES;
    [self.BackUpButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
    if(EditButtonCurrentAction == EditLockAction)
    {
        if([check_array count] >= 1)
            [self LockFileProcess];
    }
    else if(EditButtonCurrentAction == EditUnLockAction)
    {
        if([check_array count] >= 1)
            [self UnLockFileProcess];
    }
    else if(EditButtonCurrentAction == EditDeleteAction)
    {
        if([check_array count] >= 1)
            [self DeleteFileProcess];
    }
    else if(EditButtonCurrentAction == EditShareAction)
    {
        if([check_array count] >= 1)
            [self ShareFileProcess];
    }
    else if(EditButtonCurrentAction == EditCutAction)
    {
        if([check_array count] == 1)
            [self CutFileProcess];
    }
   
}
- (IBAction)ActionCancel:(id)sender {
    EditButtonCurrentAction = EditNone;
    
    self.CutButton.selected = 0;
    self.LockButton.selected = 0;
    self.UnLockButton.selected = 0;
    self.ShareFile.selected = 0;
    self.CutButton.selected = 0;
    self.YesOrNo.hidden = YES;
    //self.NavigationTitle.hidden = NO;
    self.titleDownloadIV.hidden = NO;
    self.titleDownloadText.hidden = NO;
    self.NumberOfTitle.hidden = YES;
    self.BackUpButton.userInteractionEnabled = YES;
    [self.BackUpButton setImage:[UIImage imageNamed:@"control_backbtn"] forState:UIControlStateNormal];
}

- (IBAction)file_changeView_clicked:(id)sender {
    _viewType++;
    _viewType = _viewType % 2;
    
    if(_viewType == 0){
        [file_changeViewBT setImage:[UIImage imageNamed:@"icon_playback_grid"]
                           forState:UIControlStateNormal];
        
        //file_collectView.hidden = NO;
        file_tableView.hidden = NO;
    }
    else{
        [file_changeViewBT setImage:[UIImage imageNamed:@"icon_playback_info"]
                           forState:UIControlStateNormal];
        
        file_tableView.hidden = NO;
        //file_collectView.hidden = YES;
    }
}

-(void)EditSelectIconChange:(int)type
{
    if(type == EditLockAction)
    {
        self.BackUpButton.userInteractionEnabled = NO;
        [self.BackUpButton setImage:[UIImage imageNamed:@"control_lock"] forState:UIControlStateNormal];
        self.YesOrNo.hidden = NO;
        EditButtonCurrentAction = EditLockAction;
        self.LockButton.selected = 1;
        self.UnLockButton.selected = 0;
        self.DeleteFileButton.selected = 0;
        self.ShareFile.selected = 0;
        self.CutButton.selected = 0;
    }
    else if(type == EditUnLockAction)
    {
        self.BackUpButton.userInteractionEnabled = NO;
        [self.BackUpButton setImage:[UIImage imageNamed:@"control_unlock"] forState:UIControlStateNormal];
        self.YesOrNo.hidden = NO;
        EditButtonCurrentAction = EditUnLockAction;
        self.UnLockButton.selected = 1;
        self.LockButton.selected = 0;
        self.DeleteFileButton.selected = 0;
        self.ShareFile.selected = 0;
        self.CutButton.selected = 0;
    }
    else if(type == EditDeleteAction)
    {
        self.BackUpButton.userInteractionEnabled = NO;
        [self.BackUpButton setImage:[UIImage imageNamed:@"control_delete"] forState:UIControlStateNormal];
        self.YesOrNo.hidden = NO;
        EditButtonCurrentAction = EditDeleteAction;
         self.DeleteFileButton.selected = 1;
        self.LockButton.selected = 0;
        self.UnLockButton.selected = 0;
        self.ShareFile.selected = 0;
        self.CutButton.selected = 0;
    }
    else if(type == EditShareAction)
    {
        self.BackUpButton.userInteractionEnabled = NO;
        [self.BackUpButton setImage:[UIImage imageNamed:@"control_share"] forState:UIControlStateNormal];
        self.YesOrNo.hidden = NO;
        EditButtonCurrentAction = EditShareAction;
        self.ShareFile.selected = 1;
        self.LockButton.selected = 0;
        self.UnLockButton.selected = 0;
        self.DeleteFileButton.selected = 0;
        self.CutButton.selected = 0;
    }
    else if(type == EditCutAction)
    {
        self.BackUpButton.userInteractionEnabled = NO;
        [self.BackUpButton setImage:[UIImage imageNamed:@"control_cut"] forState:UIControlStateNormal];
        self.YesOrNo.hidden = NO;
        EditButtonCurrentAction = EditCutAction;
        
        self.CutButton.selected = 1;
        self.LockButton.selected = 0;
        self.UnLockButton.selected = 0;
        self.ShareFile.selected = 0;
        self.DeleteFileButton.selected = 0;
    }
    
}

- (IBAction)file_changeTypeBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _listType++;
    if(_listType >= 2){
        _listType = _listType%2;
    }
    
    if(_listType == 1){
        if(self.isPlay)
        {
            [_player pause];
            file_videoPlayBT.selected = 0;
            _PlayerSlide.value = 0;
            [_player seekToTime:kCMTimeZero]; // seek to zero

            [_player removeTimeObserver:timeObserver];
            timeObserver = nil;
            self.isPlay = NO;
        }
        
        file_videoPlayBT.hidden = NO;
        //self.PlayerSlide.hidden = YES;
        file_videoPlayBT.hidden = YES;
       // self.GPS_InfoBtn.hidden = YES;
        self.GPS_Button.enabled = NO;
         //self.CutButton.hidden = YES;
        self.CutButton.userInteractionEnabled = NO;
        self.CutButton.selected = 0;
        /*self.NavigationTitle.text = NSLocalizedString(@"SetLocalPhotoFile", @"");*/
        [file_changeTypeBT setImage:[UIImage imageNamed:@"control_changemode_video"]
                           forState:UIControlStateNormal];
        
        //_NavigationTitle.titleLabel.text = NSLocalizedString(@"SetLocalPhotoFile", @"");
        [self.titleDownloadText setText:[delegate getStringForKey:@"SetLocalPhotoFile" withTable:@""]];
        
        file_previewIV.layer.sublayers = nil;
    }
    else{
        //self.CutButton.hidden = NO;
        //self.PlayerSlide.hidden = NO;
        self.GPS_InfoBtn.hidden = YES;
        self.GPS_Button.enabled = YES;
        file_videoPlayBT.hidden = NO;
    
        /*self.NavigationTitle.text = NSLocalizedString(@"SetLocalVideoFile", @"");*/
        [file_changeTypeBT setImage:[UIImage imageNamed:@"control_changemode_pic"]
                           forState:UIControlStateNormal];
        //_NavigationTitle.titleLabel.text = NSLocalizedString(@"SetLocalVideoFile", @"");
        [self.titleDownloadText setText:[delegate getStringForKey:@"SetLocalVideoFile" withTable:@""]];
        file_previewIV.image = nil;
        [file_previewIV.layer addSublayer:imageLayer];
    }
    [self setCheckArray];
    fileListVideo = [[NSMutableArray alloc] init];
    fileListImage = [[NSMutableArray alloc] init];
    
    if(_listType == 1)
    {
        fileListImage = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    else
    {
        fileListVideo = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
   
    [file_tableView reloadData];
    //set cell filename size
    [self setCellFileNameSize];
    
    //[file_collectView reloadData];
}
- (IBAction)Edit_Select_Click:(id)sender {
    
     AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.DeleteFileButton.userInteractionEnabled = NO;
    
    [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete_disable"] forState:UIControlStateNormal];
    self.ShareFile.userInteractionEnabled = NO;
    [self.ShareFile setImage:[UIImage imageNamed:@"control_share_disable"] forState:UIControlStateNormal];
    [self.CutButton setImage:[UIImage imageNamed:@"control_cut_disable"] forState:UIControlStateNormal];
    self.CutButton.userInteractionEnabled = NO;
    
    self.LockButton.userInteractionEnabled = NO;
    [self.LockButton setImage:[UIImage imageNamed:@"control_lock_disable"] forState:UIControlStateNormal];
    
    self.UnLockButton.userInteractionEnabled = NO;
    [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock_disable"] forState:UIControlStateNormal];
    [self setToolView];

}

- (IBAction)file_toolSwitchBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    self.DeleteFileButton.userInteractionEnabled = NO;
     
    [self.DeleteFileButton setImage:[UIImage imageNamed:@"control_delete_disable"] forState:UIControlStateNormal];
    self.ShareFile.userInteractionEnabled = NO;
    [self.ShareFile setImage:[UIImage imageNamed:@"control_share_disable"] forState:UIControlStateNormal];
    [self.CutButton setImage:[UIImage imageNamed:@"control_cut_disable"] forState:UIControlStateNormal];
    self.CutButton.userInteractionEnabled = NO;
    
    self.LockButton.userInteractionEnabled = NO;
    [self.LockButton setImage:[UIImage imageNamed:@"control_lock_disable"] forState:UIControlStateNormal];
    
    self.UnLockButton.userInteractionEnabled = NO;
    [self.UnLockButton setImage:[UIImage imageNamed:@"control_unlock_disable"] forState:UIControlStateNormal];
    
    
    [self setToolView];

    
    
    //[file_tableView reloadData];
    // [file_collectView reloadData];
}

- (IBAction)file_deleteBT_clicked:(id)sender {
    NSString *SelectedTotal;
    NSString *Title;
    //self.NavigationTitle.hidden = YES;
    self.titleDownloadText.hidden = YES;
    self.titleDownloadIV.hidden = YES;
    self.NumberOfTitle.hidden = NO;
    if(_listType == 1)
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
        }
    }
    else
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
        }
    }
    Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];
    //Title = [NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];
    
    self.NumberOfTitle.text = Title;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self EditSelectIconChange:EditDeleteAction];
#if 0
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *Protect;
    
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
                if(_listType == 1)
                {
                    [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
                }
                else
                {
                    DeleteFileName = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
                }
                NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:DeleteFileName error:&error];
                
                if (fileAttributes != nil) {
                    
                    Protect = [fileAttributes objectForKey:NSFileProtectionKey];
                    if([Protect isEqualToString:@"NSFileProtectionComplete"])
                    {
        
                    }
                    else
                    {
                        [fileManager removeItemAtPath:DeleteFileName error:nil];
                    }
                
                }
        }
    }
    [self setToolView];

    [fileListVideo removeAllObjects];
    [fileListImage removeAllObjects];
    
    if(_listType == 1)
    {
        fileListImage = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    else
    {
        fileListVideo = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    [file_tableView reloadData];
    long int section2 = [file_tableView numberOfSections];
    
    for (int i = 0;i<section2;i++) {
        long int row2 = [file_tableView numberOfRowsInSection:i];
        for(int j =0;j<row2;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            /*[cell.CheckBox setImage:[UIImage imageNamed:@"check_off"]];
            [cell.CheckBox setHidden:YES];*/
            cell.tag = 0;
        }
    }
    /*[file_collectView reloadData];*/
#endif
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
- (IBAction)sliderTouchUpInside:(UISlider *)slider {
    [self.PlayerTimer setFireDate:[NSDate distantPast]];
    float seconds = self.PlayerSlide.value;
    CMTime startTime = CMTimeMakeWithSeconds(seconds, item.currentTime.timescale);
    //让视频从指定处播放
    [_player seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            self.Seeking = NO;
        }
    }];
    
}
- (IBAction)sliderValueChanged:(UISlider *)slider {
    _PlayerSlide.value = slider.value;
}
- (IBAction)sliderTouchDown:(id)sender {
    timercounter = 0;
    [self.PlayerTimer setFireDate:[NSDate distantFuture]];
    self.Seeking = YES;
}

- (IBAction)GPS_Action:(id)sender {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_GPS_Button.selected)
    {
        if(self.GPS_View.tag)
        {
            self.GPS_View.tag = 0;
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width+self.GPS_InfoToolView.frame.size.width+20, self.GPS_View.frame.size.height);
            GPSViewFrame = self.GPS_View.frame;
            self.ListFrame.frame =CGRectMake(self.ListFrame.frame.origin.x, self.ListFrame.frame.origin.y, self.ListFrame.frame.size.width+self.GPS_InfoToolView.frame.size.width+20, self.ListFrame.frame.size.height);
            ListOutletFrame = self.ListFrame.frame;
            self.ZoomGroup.center =CGPointMake(self.ZoomGroup.center.x+self.GPS_InfoToolView.frame.size.width+20,self.ZoomGroup.center.y);
            
            self.ZoomGroup.frame = self.ZoomGroup.frame;

        }
        self.GPS_InfoToolView.hidden = YES;
        file_tableView.hidden = NO;
        self.GPS_InfoBtn.selected = 0;
        self.GPS_InfoBtn.hidden = YES;
        self.ZoomGroup.hidden = YES;
        file_toolViewSwitchBT.enabled = YES;
        file_changeTypeBT.enabled = YES;
        //file_changeTypeBT.userInteractionEnabled = YES;
        _GPS_View.hidden = YES;
        AutoCenterLocation.hidden = YES;
        
        _GPS_Button.selected = !_GPS_Button.selected;
    }
    else
    {
        file_tableView.hidden = YES;
        self.GPS_InfoBtn.hidden = NO;
        self.ZoomGroup.hidden = NO;
        file_toolViewSwitchBT.enabled = NO;
        file_changeTypeBT.enabled = NO;
       // file_changeTypeBT.userInteractionEnabled = NO;
        _GPS_View.hidden = NO;
        AutoCenterLocation.hidden = NO;
        _GPS_Button.selected = !_GPS_Button.selected;
        if(GPS_change_location == YES)
        {
            [self GPSMapVideoView:GPS_PerSecondData Serial:Metadata_Serial];
            
        }
    }
    
}
- (void)__playerItemDidPlayToEndTimeNotification:(NSNotification *)sender
{
    _PlayerSlide.value = 0;
    file_videoPlayBT.selected = 0;
    [_player seekToTime:kCMTimeZero]; // seek to zero
    if(timeObserver != nil)
    {
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
    }
    [self.PlayerTimer setFireDate:[NSDate distantFuture]];
    timercounter = 0;
    PlayerImageFlag = 0;
    self.PlayerSlide.hidden = NO;
    Preview_ZoomButton.hidden = NO;
    file_videoPlayBT.hidden = NO;
//    self.GPS_InfoBtn.hidden = NO;
    self.isPlay = NO;
    GPS_camera_animation = YES;
    
}
- (IBAction)PreviewZoomAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft ||deviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        /*self.GPS_View.frame = GPSViewFrame;
        self.ListFrame.frame = ListOutletFrame;
        self.ZoomGroup.frame = ZoomGroupFrame;*/
        //self.GPS_InfoBtn.selected = 0;
        //self.GPS_InfoBtn.selected = 0;
        //self.GPS_View.tag = 0;
        //self.GPS_InfoToolView.hidden = YES;
        /*file_toolViewSwitchBT.hidden = NO;
        AutoCenterLocation.hidden = NO;
        if(_GPS_View.hidden == NO)
        {
            self.ZoomGroup.hidden = NO;
        }*/
        [Preview_ZoomButton setImage:[UIImage imageNamed:@"control_unfullscreen"]
                            forState:UIControlStateNormal];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    else
    {
        

        /*file_toolViewSwitchBT.hidden = YES;
        AutoCenterLocation.hidden = YES;
        if(_GPS_View.hidden == YES)
        {
            self.ZoomGroup.hidden = YES;
        }
        if(self.GPS_InfoToolView.hidden == NO)
        {
            self.GPS_InfoToolView.center = CGPointMake(self.GPS_InfoToolView.center.x+200,self.GPS_InfoToolView.center.y);
            
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width+self.GPS_InfoToolView.frame.size.width, self.GPS_View.frame.size.height);
            
            self.ZoomGroup.center = CGPointMake(self.ZoomGroup.center.x+self.GPS_InfoToolView.frame.size.width,self.ZoomGroup.center.y);
            self.GPS_InfoToolView.hidden = YES;
        }*/
        [Preview_ZoomButton setImage:[UIImage imageNamed:@"control_fullscreen"]
                            forState:UIControlStateNormal];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }

}

- (IBAction)ShareButton:(id)sender {
   
    NSString *SelectedTotal;
    NSString *Title;
    //self.NavigationTitle.hidden = YES;
    self.titleDownloadText.hidden =YES;
    self.titleDownloadIV.hidden =YES;
    self.NumberOfTitle.hidden = NO;
    if(_listType == 1)
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
        }
    }
    else
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
        }
    }
    Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];
    //Title = [NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];
    
    self.NumberOfTitle.text = Title;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self EditSelectIconChange:EditShareAction];
#if 0
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
                if(_listType == 1)
                {
                    NSURL *outputURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
                    [selectURL addObject:outputURL];
 
                }
                else
                {
                    
                    
                    NSURL *outputURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
                    [selectURL addObject:outputURL];
                }
            }
    }

    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:(NSArray*)selectURL applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    [self setCheckArray];
    [selectURL removeAllObjects];
    
    
    
    
    [self setToolView];
    
#endif
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 0;
    if(scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0,0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    switch (device.orientation) {
            
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            
            break;
            
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
            
            //系統無法判斷目前Device的方向，有可能是斜置
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"屏幕向左横置");
            if(PlayerImageFlag)
            {
                self.PlayerSlide.hidden = YES;
            }
            self.fullBackView.hidden = NO;
            [self fullscreenSetImage:UIDeviceOrientationLandscapeLeft];

            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            if(PlayerImageFlag)
            {
                self.PlayerSlide.hidden = YES;
            }
            self.fullBackView.hidden = NO;
            [self fullscreenSetImage:UIDeviceOrientationLandscapeRight];
            break;
            
        case UIDeviceOrientationPortrait:
            self.PlayerSlide.hidden = NO;
            self.fullBackView.hidden = YES;
            [self fullscreenSetImage:UIDeviceOrientationPortrait];
            NSLog(@"屏幕直立");
           /* [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsfullscreenAnimateNotification"
                                                                object:@(nil)];*/
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}

- (IBAction)AutoCenterPositionAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                         longitude:GPS_current_Longitude
                                              zoom:17];
    [mapView animateToCameraPosition:camera];
    GPS_camera_animation = YES;
    
}
- (IBAction)CutAction:(id)sender {
    NSString *SelectedTotal;
    NSString *Title;
    //self.NavigationTitle.hidden = YES;
    self.titleDownloadText.hidden = YES;
    self.titleDownloadIV.hidden = YES;
    self.NumberOfTitle.hidden = NO;
    if(_listType == 1)
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
        }
    }
    else
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
        }
    }
    Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];
    //Title = [NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];
    
    self.NumberOfTitle.text = Title;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self EditSelectIconChange:EditCutAction];
#if 0
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
                CutFileName = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
        }
    }
    long int section = [file_tableView numberOfSections];
    for (int i = 0;i<section;i++) {
        long int row = [file_tableView numberOfRowsInSection:i];
        for(int j=0;j<row;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            /*[cell.CheckBox setImage:[UIImage imageNamed:@"check_off"]];
            [cell.CheckBox setHidden:YES];*/
            cell.tag = 0;
        }
    }
    
    
    [self setCheckArray];
    [self performSegueWithIdentifier:@"CutVideoSegue" sender:self];
#endif
}

- (void)fullscreenSetImage:(NSInteger)Orientation
{
    
    if(Orientation == UIDeviceOrientationLandscapeLeft ||
       Orientation == UIDeviceOrientationLandscapeRight)
    {
        /*imageLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);*/
        imageLayer.frame = file_previewIV.frame;
        
        /*file_toolViewSwitchBT.hidden = YES;
        AutoCenterLocation.hidden = YES;
        
        self.ZoomGroup.hidden = YES;*/
        [Preview_ZoomButton setImage:[UIImage imageNamed:@"control_unfullscreen"]
                            forState:UIControlStateNormal];
       // if(self.GPS_InfoToolView.hidden == NO)
       // {
            /*self.GPS_InfoToolView.center = CGPointMake(self.GPS_InfoToolView.center.x+200,self.GPS_InfoToolView.center.y);
            
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width+self.GPS_InfoToolView.frame.size.width, self.GPS_View.frame.size.height);*/
            
            /*self.ZoomGroup.center = CGPointMake(self.ZoomGroup.center.x+self.GPS_InfoToolView.frame.size.width,self.ZoomGroup.center.y);
            self.GPS_InfoToolView.hidden = YES;*/
      //  }
       
    }
    else if(Orientation == UIDeviceOrientationPortrait)
    {
        imageLayer.frame = file_previewIV.frame;
        //self.GPS_InfoBtn.selected = 0;
        //self.GPS_InfoToolView.hidden = YES;
        //self.GPS_View.tag = 0;
        
        
      /*  file_toolViewSwitchBT.hidden = NO;
        AutoCenterLocation.hidden = NO;*/
        /*if(_GPS_View.hidden == YES)
        {
            self.ZoomGroup.hidden = YES;
        }
        else
        {
            self.ZoomGroup.hidden = NO;
        }*/
        [Preview_ZoomButton setImage:[UIImage imageNamed:@"control_fullscreen"]
                            forState:UIControlStateNormal];
        
    }
}
-(void)clickPreview:(UITapGestureRecognizer *)gestureRecognizer
{
    //NSLog(@"click");
    UIDevice *device = [UIDevice currentDevice];
    
    if(_listType != 1)
    {
        if(self.isPlay)
        {
            PlayerImageFlag = 0;
            if(self.PlayerSlide.hidden == NO && Preview_ZoomButton.hidden == NO && file_videoPlayBT.hidden == NO/* && self.GPS_InfoBtn.hidden == NO*/)
            {
                timercounter = 0;
                PlayerImageFlag = 0;
                if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight)
                    self.PlayerSlide.hidden = YES;
                else
                    self.PlayerSlide.hidden = NO;
                Preview_ZoomButton.hidden = YES;
                file_videoPlayBT.hidden = YES;
                // self.GPS_InfoBtn.hidden = YES;
                [self.PlayerTimer setFireDate:[NSDate distantFuture]];
            }
            else
            {
                timercounter = 0;
                PlayerImageFlag = 0;
                self.PlayerSlide.hidden = NO;
                Preview_ZoomButton.hidden = NO;
                file_videoPlayBT.hidden = NO;
                //self.GPS_InfoBtn.hidden = NO;
                [self.PlayerTimer setFireDate:[NSDate distantPast]];
            }
        }
        else
        {
            self.PlayerSlide.hidden = NO;
            Preview_ZoomButton.hidden = NO;
            file_videoPlayBT.hidden = NO;
            //self.GPS_InfoBtn.hidden = NO;
        }
    }
    
}
-(int)CheckSeries:(NSString *)Name
{
    int serial = (int)NoneSerial;
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToFileOffset:length-3000];//70
    NSData *datay = [fileHandle readDataToEndOfFile];
    Byte *testByte = (Byte *)[datay bytes];
    hasGPSOffect = NO;
    isJVCKENWOODMachine = NO;
    searchMode = search_Bottom;
    for(int i=0;i<[datay length];i++)
    {
        if(i <= [datay length]-7)
        {
            if(testByte[i] == 'D' && testByte[i+1] == 'E' && testByte[i+2] == 'M' && testByte[i+3] == 'O')
            {
                serial = (int)Novatake_6x;
                break;
            }
            else if(testByte[i] == 'C' && testByte[i+1] == '1' && testByte[i+2] == 'G' && testByte[i+3] == 'W')
            {
                serial =  (int)Novatake_5x;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '2' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0')//200
            {
                serial = (int)Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '3' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//300W
            {
                serial = (int)Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '4' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//400W
            {
                serial = (int)Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '5' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//500W
            {
                serial = (int)Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '2' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1')//201
            {
                serial = (int)Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '3' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//301W
            {
                serial = (int)Novatake_7x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '4' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//401W
            {
                serial = (int)Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '5' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//501W
            {
                serial = (int)Novatake_6x;
                isJVCKENWOODMachine = YES;
                hasGPSOffect = YES;
                break;
            }
            else if(testByte[i] == 't' && testByte[i+1] == 'r' && testByte[i+2] == 'i' && testByte[i+3] == 'm')
            {
                serial = (int)trim;
                break;
            }
            else if(testByte[i] == 'U' && testByte[i+1] == '1'/*testByte[i] == 'C' && testByte[i+1] == 'A' && testByte[i+2] == 'N' && testByte[i+3] == 't'*/)
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'U' && testByte[i+1] == '2'/*testByte[i] == 'C' && testByte[i+1] == 'A' && testByte[i+2] == 'N' && testByte[i+3] == 't'*/)
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'S' && testByte[i+1] == '2'/*testByte[i] == 'C' && testByte[i+1] == 'A' && testByte[i+2] == 'N' && testByte[i+3] == 't'*/)
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'S' && testByte[i+1] == '2' && testByte[i+2] == '+'/*testByte[i] == 'C' && testByte[i+1] == 'A' && testByte[i+2] == 'N' && testByte[i+3] == 't'*/)
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'K' && testByte[i+1] == 'V' &&
                    testByte[i+2] == 'D' && testByte[i+3] == 'R' &&
                    testByte[i+4] == '6' && testByte[i+5] == '0' &&
                    testByte[i+6] == '0' && testByte[i+7] == 'W')//600W
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                    testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                    testByte[i+4] == '6' && testByte[i+5] == '0' &&
                    testByte[i+6] == '1' && testByte[i+7] == 'W')//601W
            {
                serial = (int)ICatchSerial;
                break;
            }
            else if(testByte[i] == 'Z' && testByte[i+1] == '3'/*testByte[i] == 'C' && testByte[i+1] == 'A' && testByte[i+2] == 'N' && testByte[i+3] == 't'*/)
            {
                serial = (int)ICatchSerial;
                break;
            }
        }
    }
    if(serial == (int)NoneSerial) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
        [fileHandle seekToEndOfFile];
        length = [fileHandle offsetInFile];
        [fileHandle seekToFileOffset:1500];
        //datay = [fileHandle readDataToEndOfFile];
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
                    serial = (int)ICatchSerial;
                    searchMode = search_Top;
                    break;
                }
                else if(testByte[i] == 'D' && testByte[i+1] == 'R' &&
                        testByte[i+2] == 'V' && testByte[i+3] == 'A' &&
                        testByte[i+4] == '6' && testByte[i+5] == '0' &&
                        testByte[i+6] == '1' && testByte[i+7] == 'W')//601W
                {
                    serial = (int)ICatchSerial;
                    searchMode = search_Top;
                    break;
                }
            }
        }
    }
    return serial;
}
-(void)trim_find_CC:(int)Metadata_Serial FileName:(NSString *)Name
{
    BOOL stco_flag = NO;
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    
    
    [fileHandle seekToFileOffset:length-36850];//70
    long int current_position = length-36850;
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
    [fileHandle seekToFileOffset:(length-36850)+current_position+1];//70
    long int startData = (length-36850)+current_position+1;
    datay = [fileHandle readDataToEndOfFile];
    testByte = (Byte *)[datay bytes];

    for(long int i = startData,j=0,k=0;; i++)
    {
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
-(void)ICatch_Udat_find:(int)Metadata_Serial FileName:(NSString *)Name FileLength:(int)Length
{
    NSData *datay;
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    long int current_position;
    /*if(Length > 0 && Length <= 60)
    {
        [fileHandle seekToFileOffset:length-14660];//70
        current_position = length-14660;
    }
    else if(Length > 60 && Length <= 180)
    {
        [fileHandle seekToFileOffset:length-(14660*3)];//70
        current_position = length-(14660*3);
    }
    else if(Length > 180 && Length <= 300)
    {
        [fileHandle seekToFileOffset:length-(14660*5)];//70
        current_position = length-(14660*5);
    }*/
    if(searchMode == search_Bottom) {
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
    if(searchMode == search_Bottom) {
        datay = [fileHandle readDataToEndOfFile];
    } else {
        datay = [fileHandle readDataOfLength:200000];
    }
    testByte = (Byte *)[datay bytes];
    
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
   
    
    
}
-(void)Nvt_stco_find:(int)Metadata_Serial FileName:(NSString *)Name
{
    BOOL stco_flag = NO;
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    //NSUInteger length = [[fileHandle availableData] length];
    [fileHandle seekToEndOfFile];
    long int length = [fileHandle offsetInFile];
    long int current_position;
    if(Metadata_Serial == Novatake_6x ||
       Metadata_Serial == Novatake_7x)
    {
        [fileHandle seekToFileOffset:length-3000];//70
       current_position = length-3000;
    }
    else if(Metadata_Serial == Novatake_5x)
    {
        [fileHandle seekToFileOffset:length-1200];//70
        current_position = length-1200;
    }
    NSData *datay = [fileHandle readDataToEndOfFile];
    Byte *testByte = (Byte *)[datay bytes];
    
    if(Metadata_Serial == Novatake_6x ||
       Metadata_Serial == Novatake_7x)
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
    else if(Metadata_Serial == Novatake_5x)
    {
        for(int i=0,j=0;i<[datay length];i++)
        {
            if(i <= [datay length]-3)
            {
                //=============Get total data===============//
                if(stco_flag)
                {
                    printf("\ntestByte[%d] = 0x%x\n",i,testByte[i]);
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
                    printf("\ntestByte[%d] = %d\n",i,testByte[i]);
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
            
            if(testByte == nil) {
                break;
            }
            per_sec_data_position[j] = ((testByte[i]<<24) + (testByte[i+1]<<16) + (testByte[i+2]<<8) + (testByte[i+3])+65536);
            j++;
        }
    }
    
    
    
    //NSLog(@"NAVATAKE STRING0 = %d",b0);
    //NSLog(@"NAVATAKE STRING1 = %@",subData);
    
    
    
    /*[fileHandle seekToFileOffset:length-54];//70
     current_position = length-54;
     datay = [fileHandle readDataToEndOfFile];
     testByte = (Byte *)[datay bytes];
     NSString *tmp_string = [[NSString alloc] init];
     GPS_ModelName = [[NSString alloc] init];
     for(int i=0;i<9;i++)
     {
     tmp_string = [NSString stringWithFormat:@"%c", testByte[i]];
     GPS_ModelName = [GPS_ModelName stringByAppendingString:tmp_string];
     }
     
     [fileHandle seekToFileOffset:length-32];//70
     current_position = length-32;
     datay = [fileHandle readDataToEndOfFile];
     testByte = (Byte *)[datay bytes];
     tmp_string = [[NSString alloc] init];
     GPS_ModelVersion = [[NSString alloc] init];
     for(int i=0;i<24;i++)
     {
     tmp_string = [NSString stringWithFormat:@"%c", testByte[i]];
     GPS_ModelVersion = [GPS_ModelVersion stringByAppendingString:tmp_string];
     }
     [fileHandle closeFile];
     
     NSLog(@"GPS_ModelName = %@",GPS_ModelName);
     NSLog(@"GPS_ModelVersion = %@",GPS_ModelVersion);*/
    
}
-(void)trim_find_CC_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSString *tempString;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
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
        
        
        if([tempString isEqualToString:@"S"])
        {
            tempString = [NSString stringWithFormat:@"-%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18],testByte[j+19],testByte[j+20],testByte[j+21],testByte[j+22],testByte[j+23],testByte[j+24],testByte[j+25],testByte[j+26],testByte[j+27]];
        }
        else
        {
            tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+15],testByte[j+16],testByte[j+17],testByte[j+18],testByte[j+19],testByte[j+20],testByte[j+21],testByte[j+22],testByte[j+23],testByte[j+24],testByte[j+25],testByte[j+26],testByte[j+27]];
        }
        
        
        [GPS_Dictionary setValue:tempString forKey:@"GPS_Latitude"];
        
        
        tempString = [NSString stringWithFormat:@"%c",testByte[j+28]];
        [GPS_Dictionary setValue:tempString forKey:@"GPS_ESInd"];
        
        if([tempString isEqualToString:@"W"])
        {
            tempString = [NSString stringWithFormat:@"-%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+29],testByte[j+30],testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38],testByte[j+39],testByte[j+40],testByte[j+41]];
        }
        else
        {
            tempString = [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c",testByte[j+29],testByte[j+30],testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38],testByte[j+39],testByte[j+40],testByte[j+41]];
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
-(void)ICatch_gps_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    NSData * datay;
    NSString *tempLatitude;
    NSString *tempLongitude;
    NSString *tempAltitude;
    NSString *tempSpeed;
    NSString *tempGSensorX;
    NSString *tempGSensorY;
    NSString *tempGSensorZ;
    NSString *strtemp;
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
        strtemp = [[NSString alloc] initWithFormat:@"%c",testByte[j+30]];
        [GPS_Dictionary setValue:strtemp forKey:@"GPS_NSInd"];
        
        tempLatitude = [[NSString alloc] initWithFormat:@"%c%c%c%c%c%c%c%c",testByte[j+31],testByte[j+32],testByte[j+33],testByte[j+34],testByte[j+35],testByte[j+36],testByte[j+37],testByte[j+38]];
        if([strtemp isEqualToString:@"N"]) {
            Latitude = [[tempLatitude substringWithRange:NSMakeRange(0 , 2)] intValue] +([[tempLatitude substringWithRange:NSMakeRange(2 , 6)] doubleValue] /10000/60);
        } else {
            Latitude = 0-([[tempLatitude substringWithRange:NSMakeRange(0 , 2)] intValue] +([[tempLatitude substringWithRange:NSMakeRange(2 , 6)] doubleValue] /10000/60));
        }

        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Latitude] forKey:@"GPS_Latitude"];
        
        
        strtemp = [[NSString alloc] initWithFormat:@"%c",testByte[j+39]];
        [GPS_Dictionary setValue:strtemp forKey:@"GPS_ESInd"];
        
        
        tempLongitude = [[NSString alloc] initWithFormat:@"%c%c%c%c%c%c%c%c%c",testByte[j+40],testByte[j+41],testByte[j+42],testByte[j+43],testByte[j+44],testByte[j+45],testByte[j+46],testByte[j+47],testByte[j+48]];
        if([strtemp isEqualToString:@"E"]) {
            Longitude = [[tempLongitude substringWithRange:NSMakeRange(0 , 3)] intValue] +([[tempLongitude substringWithRange:NSMakeRange(3 , 6)] doubleValue] /10000/60);
        } else {
            Longitude = 0-([[tempLongitude substringWithRange:NSMakeRange(0 , 3)] intValue] +([[tempLongitude substringWithRange:NSMakeRange(3 , 6)] doubleValue] /10000/60));
        }
        
        
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
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",[tempGSensorZ doubleValue]/100] forKey:@"GSensor_Z"];
            
        }
        else
        {
            tempGSensorZ = [[NSString alloc] initWithFormat:@"%c%c%c",testByte[j+66],testByte[j+67],testByte[j+68]];
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%.2f",([tempGSensorZ doubleValue]/100)*-1] forKey:@"GSensor_Z"];
        }
        
         [GPS_PerSecondData addObject:GPS_Dictionary];
    }

}
-(void)Nvt_gps_PerSecond_Save:(int)MetadataSerial FileName:(NSString *)Name
{
    
    NSString *testname = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",Name]];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:testname];
    NSData * datay;
    
    long int free_gps_position = 0;
    double Latitude;
    double Longitude;
    double Speed;
    double Altitude;
    double GSensor_X;
    double GSensor_Y;
    double GSensor_Z;

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
    int offset;
    if(hasGPSOffect == YES) {
        offset = 32;
    } else {
        offset = 0;
    }
    for(long int i = 0,j = 0; i < GPS_Total_Date; i++)
    {
        GPS_Dictionary = [[NSMutableDictionary alloc] init];
        [fileHandle seekToFileOffset:per_sec_data_position[i]];//70
        datay = [fileHandle readDataOfLength:150];
        Byte *testByte = (Byte *)[datay bytes];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",(int)((testByte[j+47-offset] << 24) + (testByte[j+46-offset] << 16) + (testByte[j+45-offset] << 8) + (testByte[j+44-offset]))] forKey:@"GPS_Hour"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",((testByte[j+51-offset] << 24) + (testByte[j+50-offset] << 16) + (testByte[j+49-offset] << 8) + (testByte[j+48-offset]))] forKey:@"GPS_Minute"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",((testByte[j+55-offset] << 24) + (testByte[j+54-offset] << 16) + (testByte[j+53-offset] << 8) + (testByte[j+52-offset]))] forKey:@"GPS_Second"];
        if(hasGPSOffect == YES) {
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",(((testByte[j+59-offset] << 24) + (testByte[j+58-offset] << 16) + (testByte[j+57-offset] << 8) + (testByte[j+56-offset])))] forKey:@"GPS_Year"];
        } else {
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",(((testByte[j+59-offset] << 24) + (testByte[j+58-offset] << 16) + (testByte[j+57-offset] << 8) + (testByte[j+56-offset]))+2000)] forKey:@"GPS_Year"];
        }
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",((testByte[j+63-offset] << 24) + (testByte[j+62-offset] << 16) + (testByte[j+61-offset] << 8) + (testByte[j+60-offset]))] forKey:@"GPS_Month"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%d",((testByte[j+67-offset] << 24) + (testByte[j+66-offset] << 16) + (testByte[j+65-offset] << 8) + (testByte[j+64-offset]))] forKey:@"GPS_Day"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",(testByte[j+68-offset])] forKey:@"GPS_Status"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",(testByte[j+69-offset])] forKey:@"GPS_NSInd"];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%c",(testByte[j+70-offset])] forKey:@"GPS_ESInd"];
        
        //==========Latitude========//
        
        if(testByte[j+68-offset] == 'A')
        {
            Latitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",((testByte[j+75-offset] << 24) + (testByte[j+74-offset] << 16) + (testByte[j+73-offset] << 8) + (testByte[j+72-offset]))] par2:2];
            if(testByte[j+69-offset] == 'S')
            {
                Latitude = -Latitude;
            }
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Latitude] forKey:@"GPS_Latitude"];
            
            
            Longitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",((testByte[j+79-offset] << 24) + (testByte[j+78-offset] << 16) + (testByte[j+77-offset] << 8) + (testByte[j+76-offset]))] par2:2];
            
            if(testByte[j+70-offset] == 'W')
            {
                Longitude = -Longitude;
            }
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Longitude] forKey:@"GPS_Longitude"];
            
            Speed  = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",((testByte[j+83-offset] << 24) + (testByte[j+82-offset] << 16) + (testByte[j+81-offset] << 8) + (testByte[j+80-offset]))] par2:1];
            Speed = Speed * 1.852;
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Speed] forKey:@"GPS_Speed"];
            
            Altitude = [self toBinarySystemWithDecimalSystem:[[NSString alloc] initWithFormat:@"%d",((testByte[j+87-offset] << 24) + (testByte[j+86-offset] << 16) + (testByte[j+85-offset] << 8) + (testByte[j+84-offset]))] par2:1];
            
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Altitude] forKey:@"GPS_Altitude"];
            
            
        }
        else
        {
            Latitude = GPS_current_Latitude;

            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Latitude] forKey:@"GPS_Latitude"];
            
            
            Longitude = GPS_current_Longitude;
        
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Longitude] forKey:@"GPS_Longitude"];
            
            Speed  = 0;
            
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Speed] forKey:@"GPS_Speed"];
            
            Altitude = 0;
            
            [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%f",Altitude] forKey:@"GPS_Altitude"];
            
        }
        
        /*printf("\n==testByte[j+88] = 0x%x==\n",testByte[j+88-offset]);
        printf("\n==testByte[j+89] = 0x%x==\n",testByte[j+89-offset]);
        printf("\n==testByte[j+90] = 0x%x==\n",testByte[j+90-offset]);
        printf("\n==testByte[j+91] = 0x%x==\n",testByte[j+91-offset]);
        printf("\n==GS91 = %u==\n",((testByte[j+91-offset] << 24)));
        printf("\n==GS90 = %u==\n",((testByte[j+90-offset] << 16)));
        printf("\n==GS89 = %u==\n",((testByte[j+89-offset] << 8)));
        printf("\n==GS88 = %u==\n",((testByte[j+88-offset])));
         printf("\n==GStotal = %u==\n",((testByte[j+91-offset] << 24) + (testByte[j+90-offset] << 16) + (testByte[j+89-offset] << 8) + (testByte[j+88-offset])));*/
        
        GSensor_X = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",((testByte[j+91-offset] << 24) + (testByte[j+90-offset] << 16) + (testByte[j+89-offset] << 8) + (testByte[j+88-offset]))] Y_Zeexl:0];
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%1.2f",GSensor_X] forKey:@"GSensor_X"];
        
        
        GSensor_Y = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",((testByte[j+95-offset] << 24) + (testByte[j+94-offset] << 16) + (testByte[j+93-offset] << 8) + (testByte[j+92-offset]))] Y_Zeexl:1];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%1.2f",GSensor_Y] forKey:@"GSensor_Y"];
        
        
        
        /*printf("\n==testByte[j+92] = 0x%x==\n",testByte[j+92-offset]);
        printf("\n==testByte[j+93] = 0x%x==\n",testByte[j+93-offset]);
        printf("\n==testByte[j+94] = 0x%x==\n",testByte[j+94-offset]);
        printf("\n==testByte[j+95] = 0x%x==\n",testByte[j+95-offset]);
        printf("\n==testByte[j+96] = 0x%x==\n",testByte[j+96-offset]);
         printf("\n==testByte[j+97] = 0x%x==\n",testByte[j+97-offset]);
        printf("\n==testByte[j+98] = 0x%x==\n",testByte[j+98-offset]);
        printf("\n==testByte[j+99] = 0x%x==\n",testByte[j+99-offset]);*/
        
        GSensor_Z = [self toBinarySystemWithDecimalSystemForGSensor:[[NSString alloc] initWithFormat:@"%u",((testByte[j+99-offset] << 24) + (testByte[j+98-offset] << 16) + (testByte[j+97-offset] << 8) + (testByte[j+96-offset]))] Y_Zeexl:0];
        
        [GPS_Dictionary setValue:[[NSString alloc] initWithFormat:@"%1.2f",GSensor_Z] forKey:@"GSensor_Z"];
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
    //NSLog(@"dfvdv");
}

-(double)toBinarySystemWithDecimalSystem:(NSString *)decimal par2:(int)mode
{
    long int num = [decimal intValue];
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
    if([self toDecimalSystemWithBinarySystem:Indextemp] > 1 &&
       [self toDecimalSystemWithBinarySystem:Indextemp] <= 254)
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
    if(mode == 2) {
        doubleBefor = [newValue intValue]/100;
        doubleAfter = [newValue intValue]%100;
    } else {
        doubleBefor = [newValueBefore intValue];
        doubleAfter = [newValueAfter intValue];
    }
    
    
    for(int i = 1;i <= after_float.length;i++)
    {
        floatbit = [[after_float substringWithRange:NSMakeRange(i-1 ,1)] intValue];
        
        doubleValue += ((float)floatbit * (pow(2, -1*i)));
        
    }
    doubleValue = doubleValue + doubleAfter;
    if(mode == 1)
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
    long long num = [decimal longLongValue];
    long long remainder = 0;      //余数
    long long divisor = 0;        //除数

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
    
    //NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}
- (IBAction)ZoomIn_Action:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    GPS_camera_animation = NO;
    if(current_zoomLevel <=19)
    {
        current_zoomLevel = current_zoomLevel + 1;
        [mapView animateToZoom:current_zoomLevel];
    }
}
- (IBAction)ZoomOut_Action:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    GPS_camera_animation = NO;
    if(current_zoomLevel > 0)
    {
        current_zoomLevel = current_zoomLevel - 1;
        [mapView animateToZoom:current_zoomLevel];
    }
}

- (IBAction)Gps_InfoBtn_Action:(id)sender {
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_GPS_View.hidden == NO)
    {
        self.GPS_InfoBtn.selected = !self.GPS_InfoBtn.selected;
        if(self.GPS_InfoToolView.hidden == YES)
        {
            
            self.GPS_View.tag = 1;
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width-self.GPS_InfoToolView.frame.size.width-20, self.GPS_View.frame.size.height);
            self.ListFrame.frame =CGRectMake(self.ListFrame.frame.origin.x, self.ListFrame.frame.origin.y, self.ListFrame.frame.size.width-self.GPS_InfoToolView.frame.size.width-20, self.ListFrame.frame.size.height);
            /*self.ZoomGroup.frame =CGRectMake(self.ZoomGroup.frame.origin.x-self.GPS_InfoToolView.frame.size.width-20, self.ZoomGroup.frame.origin.y,self.ZoomGroup.frame.size.width, self.ZoomGroup.frame.size.height);*/
            
            self.ZoomGroup.center =CGPointMake(self.ZoomGroup.center.x-self.GPS_InfoToolView.frame.size.width-20,self.ZoomGroup.center.y);
            GPSViewFrame = self.GPS_View.frame;
            ListOutletFrame = self.ListFrame.frame;
            ZoomGroupFrame = self.ZoomGroup.frame;
            
            self.GPS_InfoToolView.hidden = NO;
            /*self.GPS_InfoToolView.center = CGPointMake(self.GPS_InfoToolView.center.x-200,self.GPS_InfoToolView.center.y);
            
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width-self.GPS_InfoToolView.frame.size.width, self.GPS_View.frame.size.height);

            self.ZoomGroup.center = CGPointMake(self.ZoomGroup.center.x-self.GPS_InfoToolView.frame.size.width,self.ZoomGroup.center.y);*/
            

        }
        else
        {
            self.GPS_View.tag = 0;
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width+self.GPS_InfoToolView.frame.size.width+20, self.GPS_View.frame.size.height);
            self.ListFrame.frame =CGRectMake(self.ListFrame.frame.origin.x, self.ListFrame.frame.origin.y, self.ListFrame.frame.size.width+self.GPS_InfoToolView.frame.size.width+20, self.ListFrame.frame.size.height);
            
            /*self.ZoomGroup.frame =CGRectMake(self.ZoomGroup.frame.origin.x+self.GPS_InfoToolView.frame.size.width+20, self.ZoomGroup.frame.origin.y,
                                            self.ZoomGroup.frame.size.width,self.ZoomGroup.frame.size.height);*/
            self.ZoomGroup.center =CGPointMake(self.ZoomGroup.center.x+self.GPS_InfoToolView.frame.size.width+20,self.ZoomGroup.center.y);
            /*self.GPS_InfoToolView.center = CGPointMake(self.GPS_InfoToolView.center.x+200,self.GPS_InfoToolView.center.y);
            
            self.GPS_View.frame = CGRectMake(self.GPS_View.frame.origin.x, self.GPS_View.frame.origin.y, self.GPS_View.frame.size.width+self.GPS_InfoToolView.frame.size.width, self.GPS_View.frame.size.height);
          
            self.ZoomGroup.center = CGPointMake(self.ZoomGroup.center.x+self.GPS_InfoToolView.frame.size.width,self.ZoomGroup.center.y);*/
            GPSViewFrame = self.GPS_View.frame;
            ListOutletFrame = self.ListFrame.frame;
            ZoomGroupFrame = self.ZoomGroup.frame;
             self.GPS_InfoToolView.hidden = YES;

        }
    }
}


-(void)GPSMapViewInit
{
    GPS_current_Latitude = 34.1461334;
    GPS_current_Longitude = -118.14504269999998;
    camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                         longitude:GPS_current_Longitude
                                              zoom:17];
    current_zoomLevel = 17;
    
    mapView = [GMSMapView mapWithFrame:self.GPS_View.bounds camera:camera];
    
    mapView.myLocationEnabled = YES;
    mapView.delegate = self;
    mapView.settings.compassButton = YES;
    //mapView.layer.cornerRadius = 50;
    //mapView.settings.myLocationButton = YES;
    mapView.autoresizingMask =
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //self.GPS_View = mapView;
    // self.GPS_View.contentMode = UIViewContentModeScaleAspectFill;
    [self.GPS_View addSubview:mapView];
    
    //mapView.layer.cornerRadius = 1;
    //self.ListFrame.clipsToBounds = true;
   // self.GPS_View.layer.masksToBounds = YES;
    
    //self.GPS_View.layer.cornerRadius = 50;
    // Creates a marker in the center of the map.
    marker = [[GMSMarker alloc] init];
    marker_sec = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(34.1461334,-118.14504269999998);
    /*UIImage *image = [UIImage imageNamed:@"map_arrow"];
    CGSize newSize;
    newSize.width = image.size.width/2.0;
    newSize.height = image.size.height/2.0;
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    marker.icon = newImage;//[UIImage imageNamed:@"map_arrow"];*/
    marker.icon = [UIImage imageNamed:@"map_arrow"];
    marker.map = mapView;
    //[self.GPS_View bringSubviewToFront:self.GPS_InfoToolView];
    [self.GPS_View bringSubviewToFront:AutoCenterLocation];
     /*[self.GPS_View bringSubviewToFront:self.ZoomGroup];*/
   /* NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *styleUrl = [mainBundle URLForResource:@"dark" withExtension:@"json"];
    NSError *error;
    
    // Set the map style by passing the URL for style.json.
    GMSMapStyle *style = [GMSMapStyle styleWithContentsOfFileURL:styleUrl error:&error];
    
    if (!style) {
        NSLog(@"The style definition could not be loaded: %@", error);
    }
    
    mapView.mapStyle = style;*/
    //[self.GPS_View bringSubviewToFront:self.ZoomGroup];

}
-(void)GPSMapVideoView:(NSMutableArray *)VideoMetadata Serial:(int)SerialNumber
{
    double distance;
    double latitude,longitude,latitude_pre,longitude_pre;
    int pre_position,last_position;
    GPSInvalid = 0;
    [mapView clear];
    marker = [[GMSMarker alloc] init];
    marker.icon = [UIImage imageNamed:@"map_arrow"];
    /*UIImage *image = [UIImage imageNamed:@"map_arrow"];
    CGSize newSize;
    newSize.width = image.size.width/2.0;
    newSize.height = image.size.height/2.0;
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    marker.icon = newImage;//[UIImage imageNamed:@"map_arrow"];*/
    if(SerialNumber == Novatake_6x || SerialNumber == Novatake_5x ||
       SerialNumber == Novatake_7x)
    {
        for(int i = 0;i<GPS_Total_Date;i++)
        {
            if([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_Status"] isEqualToString:@"A"] &&
               ([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_NSInd"] isEqualToString:@"N"] ||
                [[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_NSInd"] isEqualToString:@"S"]) &&
               ([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_ESInd"] isEqualToString:@"E"] ||
                [[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_ESInd"] isEqualToString:@"W"])
               )
            {
                GPSInvalid = 1;
            }
        }
    }
    else if(SerialNumber == trim)
    {
        for(int i = 0;i<GPS_Total_Date;i++)
        {
            if(([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_Latitude"] intValue] != 0)&& ([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_Longitude"] intValue] != 0))
            {
                GPSInvalid = 1;
            }
        }
    }
    else if(SerialNumber == ICatchSerial)
    {
        for(int i = 0;i<GPS_Total_Date;i++)
        {
            if(([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_Latitude"] intValue] != 0)&& ([[[VideoMetadata objectAtIndex:i] objectForKey:@"GPS_Longitude"] intValue] != 0))
            {
                GPSInvalid = 1;
            }
        }
    }
    if(GPSInvalid)
    {
        hasInfoGPSPosition = [[NSMutableArray alloc] init];
        notHasInfoGPSPosition = [[NSMutableArray alloc] init];
        GPS_current_Latitude = [[[VideoMetadata objectAtIndex:0] objectForKey:@"GPS_Latitude"] doubleValue];
        GPS_current_Longitude = [[[VideoMetadata objectAtIndex:0] objectForKey:@"GPS_Longitude"] doubleValue];
        
        
        
        /*camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                             longitude:GPS_current_Longitude
                                                  zoom:17];*/
        current_zoomLevel = 17;
        // Creates a marker in the center of the map.
        
        marker.position = CLLocationCoordinate2DMake(GPS_current_Latitude,GPS_current_Longitude);
        
        marker.map = mapView;
        
        GMSMutablePath *path = [GMSMutablePath path];
        
        distance = 0;
        latitude = 0;
        longitude = 0;
        latitude_pre = 0;
        longitude_pre = 0;
        pre_position = 0;
        for(int i = 0;i<GPS_Total_Date;i++)
        {
            latitude = [[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Latitude"] doubleValue];
            longitude = [[[GPS_PerSecondData objectAtIndex:i] objectForKey:@"GPS_Longitude"] doubleValue];
            if(i>0) {
                latitude_pre = [[[GPS_PerSecondData objectAtIndex:pre_position] objectForKey:@"GPS_Latitude"] doubleValue];
                longitude_pre = [[[GPS_PerSecondData objectAtIndex:pre_position] objectForKey:@"GPS_Longitude"] doubleValue];
            }
            if(latitude == 0 && longitude == 0) {
                if(i-1 == pre_position &&
                   pre_position > 0) {
                    [hasInfoGPSPosition addObject:[NSString stringWithFormat:@"%d",pre_position]];
                }
                continue;
            } else {
                if(i-1 != pre_position &&
                   i>0) {
                    [notHasInfoGPSPosition addObject:[NSString stringWithFormat:@"%d",i]];
                }
                pre_position = i;
            }
            [path addCoordinate:CLLocationCoordinate2DMake(latitude , longitude)];
            //距離計算
            if(i>0 && latitude_pre != 0 && longitude_pre != 0) {
                distance = distance + [self getDistance:(float)latitude_pre lng1:(float)longitude_pre lat2:(float)latitude lng2:(float)longitude];
            }
            last_position = i;
            //NSLog(@"distance = %lf  i = %d",distance,i);
        }
        if(hasInfoGPSPosition.count < notHasInfoGPSPosition.count) {//先無在有類型
            GPS_current_Latitude = [[[VideoMetadata objectAtIndex:[[notHasInfoGPSPosition objectAtIndex:0] intValue]] objectForKey:@"GPS_Latitude"] doubleValue];
            GPS_current_Longitude = [[[VideoMetadata objectAtIndex:[[notHasInfoGPSPosition objectAtIndex:0] intValue]] objectForKey:@"GPS_Longitude"] doubleValue];
            marker.position = CLLocationCoordinate2DMake(GPS_current_Latitude,GPS_current_Longitude);
        }
        camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                             longitude:GPS_current_Longitude
                                                  zoom:17];
        GMSPolyline *rectangle = [GMSPolyline polylineWithPath:path];
        rectangle.map = mapView;
        // 线的颜色
        rectangle.strokeColor = [UIColor redColor];
        // 线的宽度
        rectangle.strokeWidth = 3;
        
        /*int last_position;
        if(hasInfoGPSPosition.count <= 0) {
            last_position = GPS_Total_Date-1;
        } else {
            last_position = [[hasInfoGPSPosition objectAtIndex:(hasInfoGPSPosition.count-1)] intValue];
        }*/
        
        
        GPS_last_Latitude = [[[VideoMetadata objectAtIndex:last_position] objectForKey:@"GPS_Latitude"] doubleValue];
        GPS_last_Longitude = [[[VideoMetadata objectAtIndex:last_position] objectForKey:@"GPS_Longitude"] doubleValue];
        
        circ = [GMSCircle circleWithPosition:CLLocationCoordinate2DMake(GPS_last_Latitude,GPS_last_Longitude)
                                      radius:10];
        // 圈内填充的颜色
        circ.fillColor = [UIColor redColor/*colorWithRed:1.0 green:0 blue:0 alpha:1*/];
        // 圆边的颜色
        circ.strokeColor = [UIColor redColor];
        // 圆边的宽度
        /*circ.strokeWidth = 5;*/
        circ.map = mapView;
        
        circ = [GMSCircle circleWithPosition:marker.position
                                      radius:10];
        // 圈内填充的颜色
        circ.fillColor = [UIColor redColor/*colorWithRed:1.0 green:0 blue:0 alpha:1*/];
        // 圆边的颜色
        circ.strokeColor = [UIColor redColor];
        // 圆边的宽度
        /*circ.strokeWidth = 5;*/
        circ.map = mapView;
        
        
    }
    else
    {
        GPS_current_Latitude = 34.1461334;
        GPS_current_Longitude = -118.14504269999998;
        GPS_last_Latitude = 34.1461334;
        GPS_last_Longitude = -118.14504269999998;
        camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                             longitude:GPS_current_Longitude
                                                  zoom:17];
         current_zoomLevel = 17;
        marker.position = CLLocationCoordinate2DMake(GPS_current_Latitude,GPS_current_Longitude);
        
        marker.map = mapView;
        distance = 0;
        NSLog(@"distance zero = %lf",distance);
    }
    
    
    //公制英制判斷
    if([[delegate getSpeedUnit]  isEqual: @"Metric Unit"]) {
        if(distance * 0.001 < 0.1) {   //小於0.1公里   用公尺
            //distanceDouble = distanceDouble;
            
            [_distanceUnitLabel setText:[delegate getStringForKey:@"Unitm" withTable:@""]];
            //df = new DecimalFormat("###");
            self.DistanceText.text = [NSString stringWithFormat:@"%d",(int)distance];
        } else {//大於0.1公里用 公里
            distance = distance * 0.001;
            [_distanceUnitLabel setText:[delegate getStringForKey:@"Unitkm" withTable:@""]];
            //df = new DecimalFormat("##0.0");
            self.DistanceText.text = [NSString stringWithFormat:@"%0.1f",distance];
        }
        if([VideoMetadata count] > 0) {
            self.SpeedText.text = [NSString stringWithFormat:@"%d",[[[VideoMetadata objectAtIndex:0] objectForKey:@"GPS_Speed"] intValue]];
        } else {
            self.SpeedText.text = @"0.0";
        }
        
        
        [_SpeedUnitLabel setText:[delegate getStringForKey:@"UnitKmh" withTable:@""]];
    } else/* if([[delegate getSpeedUnit]  isEqual: @"Imperial Unit"])*/{
        
        if(distance * 0.000621371 < 0.1) {   //小於0.1英里   用英呎
            distance = distance * 3.28084;
            [_distanceUnitLabel setText:[delegate getStringForKey:@"UnitFt" withTable:@""]];
            //df = new DecimalFormat("###");
            self.DistanceText.text = [NSString stringWithFormat:@"%d",(int)distance];
        } else {//大於0.1英里用 英里
            distance = distance * 0.000621371;
            [_distanceUnitLabel setText:[delegate getStringForKey:@"UnitMile" withTable:@""]];
            //df = new DecimalFormat("##0.0");
            self.DistanceText.text = [NSString stringWithFormat:@"%0.1f",distance];
        }
        if([VideoMetadata count] > 0) {
            self.SpeedText.text = [NSString stringWithFormat:@"%0.0f",[[[VideoMetadata objectAtIndex:0] objectForKey:@"GPS_Speed"] intValue]* 0.62137];
        } else {
            self.SpeedText.text = @"0.0";
        }
        
        
        [_SpeedUnitLabel setText:[delegate getStringForKey:@"UnitMph" withTable:@""]];
    }
    //self.DistanceText.text = [NSString stringWithFormat:@"%03d",(int)distance];
    //self.SpeedText.text = [NSString stringWithFormat:@"%03d",[[[VideoMetadata objectAtIndex:0] objectForKey:@"GPS_Speed"] intValue]];
    
    if(distance == 0) {
        [self.GSensorText setText:@"0"];
    } else {
        if([[[VideoMetadata objectAtIndex:0] objectForKey:@"GSensor_Z"] doubleValue]>=0)
        {
            self.GSensorText.text = [NSString stringWithFormat:@"+%.2f",[[[VideoMetadata objectAtIndex:0] objectForKey:@"GSensor_Z"] doubleValue]];
        }
        else
        {
            self.GSensorText.text = [NSString stringWithFormat:@"-%.2f",[[[VideoMetadata objectAtIndex:0] objectForKey:@"GSensor_Z"] doubleValue] * (-1)];
        }
    }
    
  
    
    [mapView animateToCameraPosition:camera];
    GPS_camera_animation = YES;
}

-(void)updateGPSMap:(NSMutableArray *)VideoMetadata sec:(int)seconds
{
    
    double getAngle = 0.0;
    if(GPSInvalid)
    {
        GPS_current_Latitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Latitude"] doubleValue];
        GPS_current_Longitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Longitude"] doubleValue];
        if(GPS_current_Latitude == 0 && GPS_current_Longitude == 0) {
            for(int i=0;i<hasInfoGPSPosition.count;i++) {//有無有 有無
                if(i <= notHasInfoGPSPosition.count &&
                   notHasInfoGPSPosition.count > 0) {
                    if(seconds >= [[hasInfoGPSPosition objectAtIndex:i] intValue] && seconds < [[notHasInfoGPSPosition objectAtIndex:i] intValue]) {//有無有
                        seconds = [[hasInfoGPSPosition objectAtIndex:i] intValue];
                        
                        GPS_current_Latitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Latitude"] doubleValue];
                        GPS_current_Longitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Longitude"] doubleValue];
                        break;
                    }
                } else {
                    if(seconds >= [[hasInfoGPSPosition objectAtIndex:i] intValue]) {//有無
                        seconds = [[hasInfoGPSPosition objectAtIndex:i] intValue];
                        GPS_current_Latitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Latitude"] doubleValue];
                        GPS_current_Longitude = [[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Longitude"] doubleValue];
                        break;
                    }
                }
            }
            if(hasInfoGPSPosition.count < notHasInfoGPSPosition.count) {//無有
                GPS_current_Latitude = [[[VideoMetadata objectAtIndex:[[notHasInfoGPSPosition objectAtIndex:0] intValue]] objectForKey:@"GPS_Latitude"] doubleValue];
                GPS_current_Longitude = [[[VideoMetadata objectAtIndex:[[notHasInfoGPSPosition objectAtIndex:0] intValue]] objectForKey:@"GPS_Longitude"] doubleValue];
            }
        }
        camera = [GMSCameraPosition cameraWithLatitude:GPS_current_Latitude
                                             longitude:GPS_current_Longitude
                                                  zoom:17];
        marker.position = CLLocationCoordinate2DMake(GPS_current_Latitude,GPS_current_Longitude);
        if(seconds != (GPS_Total_Date - 1))
        {
            marker_sec.position =CLLocationCoordinate2DMake([[[VideoMetadata objectAtIndex:seconds+1] objectForKey:@"GPS_Latitude"] doubleValue],[[[VideoMetadata objectAtIndex:seconds+1] objectForKey:@"GPS_Longitude"] doubleValue]);
        }
        getAngle = [self angleFromCoordinate:marker.position toCoordinate:marker_sec.position];
        marker.rotation = getAngle * (180.0 / M_PI);
        //公制英制判斷
        if([[delegate getSpeedUnit]  isEqual: @"Metric Unit"]) {
            self.SpeedText.text = [NSString stringWithFormat:@"%d",[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Speed"] intValue]];
            [_SpeedUnitLabel setText:[delegate getStringForKey:@"UnitKmh" withTable:@""]];
        } else /*if([[delegate getSpeedUnit]  isEqual: @"Imperial Unit"])*/ {
            self.SpeedText.text = [NSString stringWithFormat:@"%0.0f",[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Speed"] floatValue]* 0.62137];
            //NSLog(@"speed->>>    %f     float    ->>>   %0.0f",[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Speed"] floatValue],[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Speed"] floatValue]*0.62137);
            
            [_SpeedUnitLabel setText:[delegate getStringForKey:@"UnitMph" withTable:@""]];
        }
        //self.SpeedText.text = [NSString stringWithFormat:@"%03d",[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GPS_Speed"] intValue]];
        
       
        
        if([[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GSensor_Z"] doubleValue]>=0)
        {
           
             self.GSensorText.text = [NSString stringWithFormat:@"+%.2f",[[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GSensor_Z"] doubleValue]];
        }
        else
        {
             self.GSensorText.text = [NSString stringWithFormat:@"-%.2f",([[[VideoMetadata objectAtIndex:seconds] objectForKey:@"GSensor_Z"] doubleValue] * (-1))];
        }
        marker.map = mapView;
        if(GPS_camera_animation)
        {
            [mapView animateToCameraPosition:camera];
        }
    }
}
-(void)updateTimeInfo:(NSTimer *)timer{
    
    UIDevice *device = [UIDevice currentDevice];
    
    if(self.isPlay)
    {
        timercounter++;
        //NSLog(@"timercounter = %d",timercounter);
        if(timercounter == 5)
        {
            timercounter = 0;
            PlayerImageFlag = 1;
            if(device.orientation == UIDeviceOrientationLandscapeLeft || device.orientation == UIDeviceOrientationLandscapeRight)
                self.PlayerSlide.hidden = YES;
            else
                self.PlayerSlide.hidden = NO;
            Preview_ZoomButton.hidden = YES;
            file_videoPlayBT.hidden = YES;
            /*self.GPS_InfoBtn.hidden = YES;*/
            [self.PlayerTimer setFireDate:[NSDate distantFuture]];
        }
    }
    else
    {
        [self.PlayerTimer setFireDate:[NSDate distantFuture]];
        timercounter = 0;
        PlayerImageFlag = 0;
    }
}
-(void)ResetGPS_Variable
{
    stoc_position = nil;
    GPS_Total_Date = nil;
    
    memset(per_sec_data_position, 0, sizeof(per_sec_data_position));
   
    [GPS_Dictionary removeAllObjects];
    [GPS_PerSecondData removeAllObjects];
    GPS_current_Latitude = 0;
    GPS_current_Longitude = 0;

}
#pragma mark -- 两点距离角度计算
-(double)distanceBetweenPoints:(CLLocationCoordinate2D)startCoor endCoor:(CLLocationCoordinate2D)endCoor
{
    double sx=startCoor.latitude;
    double sy=startCoor.longitude;
    double ex=endCoor.latitude;
    double ey=endCoor.longitude;
    
    return sqrt(fabs(ex-sx)*fabs(ex-sx)+fabs(ey-sy)*fabs(ey-sy));
}
-(double)calcAngleStrtCoor:(CLLocationCoordinate2D)startCoor endCoor:(CLLocationCoordinate2D)endCoor
{
    //角度时钟0点计算旋转
    double sx=startCoor.latitude;
    double sy=startCoor.longitude;
    double ex=endCoor.latitude;
    double ey=endCoor.longitude;
    NSLog(@"start %f,%f",sx,sy);
    double angle1= (atan2((ey-sy), (ex-sx)));
    double theta= angle1 *(180/M_PI);
    NSLog(@"%f",theta);
    double theta1=90;
    NSLog(@"上一个角度%f",theta1);
    if (theta<0) {
        theta=360-fabs(theta)-theta1;
    }else
    {
        theta=theta-theta1;
    }
    NSLog(@"旋转角度%f",theta);
    angle1 = M_PI/180*theta;
    return angle1;
}
- (double)angleFromCoordinate:(CLLocationCoordinate2D)first
                 toCoordinate:(CLLocationCoordinate2D)second {
    
    double deltaLongitude = second.longitude - first.longitude;
    double deltaLatitude = second.latitude - first.latitude;
    double angle = (M_PI * .5f) - atan(deltaLatitude / deltaLongitude);
    
    if (deltaLongitude > 0)      return angle;
    else if (deltaLongitude < 0) return angle + M_PI;
    else if (deltaLatitude < 0)  return M_PI;
    
    return 0.0f;
}
-(double)radian:(double)d{
    
    return d * M_PI/180.0;
}
-(float)getDistance:(float)lat1 lng1:(float)lng1 lat2:(float)lat2 lng2:(float)lng2
{
    double EARTH_RADIUS = 6378137;//地球半径  人类规定(单位：m)
    double radLat1 = [self radian:lat1];
    double radLat2 = [self radian:lat2];
    double radLng1 = [self radian:lng1];
    double radLng2 = [self radian:lng2];
    
    double a = radLat1 - radLat2;
    double b = radLng1 - radLng2;
    
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2)*pow(sin(b/2),2)));//google maps里面实现的算法
    s = s * EARTH_RADIUS;
    
    return s;
}
//开始
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture
{
    if(gesture)
    {
        GPS_camera_animation = NO;
    }
    //    NSLog(@"mapViewDidStartTileRendering ==== %@",mapView);
}
- (void)mapViewDidStartTileRendering:(GMSMapView *)mapView{
    //    NSLog(@"mapViewDidStartTileRendering ==== %@",mapView);
    
}
//滑动
- (void)mapViewDidFinishTileRendering:(GMSMapView *)mapView{
    
    //    NSLog(@"mapViewDidFinishTileRendering ==== %@",mapView);
}
//暂停
- (void)mapViewSnapshotReady:(GMSMapView *)mapView{
    //    NSLog(@"mapViewSnapshotReady ==== %@",mapView);
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // segue.identifier：获取连线的ID
    if ([segue.identifier isEqualToString:@"CutVideoSegue"]) {

        VideoFileCutViewController *receive = segue.destinationViewController;
        receive.NeedCutVideoName = CutFileName;

        
        
      /*  [self setToolView];
        [self getPhotoAblum];
        [self setCheckArray];*/
        // 这里不需要指定跳转了，因为在按扭的事件里已经有跳转的代码
              //  [self.navigationController pushViewController:receive animated:YES];
    }
}
- (IBAction)UnLockAction:(id)sender {
    NSString *SelectedTotal;
    NSString *Title;
    //self.NavigationTitle.hidden = YES;
    self.titleDownloadText.hidden = YES;
    self.titleDownloadIV.hidden = YES;
    self.NumberOfTitle.hidden = NO;
    if(_listType == 1)
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
        }
    }
    else
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
        }
    }
    Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];
    //Title = [NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];
    
    self.NumberOfTitle.text = Title;

    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self EditSelectIconChange:EditUnLockAction];
#if 0
    NSError *error = nil;
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
                NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionCompleteUntilFirstUserAuthentication forKey:NSFileProtectionKey];
                
                [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
                
                NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
                cell.LockBox.hidden = YES;
        }
    }
    [self setToolView];
#endif
}
- (IBAction)LockAction:(id)sender {
    NSString *SelectedTotal;
    NSString *Title;
    //self.NavigationTitle.hidden = YES;
    self.titleDownloadText.hidden = YES;
    self.titleDownloadIV.hidden = YES;
    self.NumberOfTitle.hidden = NO;
    if(_listType == 1)
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOnePhoto" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedPhotos" withTable:@""];
        }
    }
    else
    {
        if([check_array count] <= 1) {
            SelectedTotal = [delegate getStringForKey:@"SelectedOneVideo" withTable:@""];
        } else {
            SelectedTotal = [delegate getStringForKey:@"SelectedVideos" withTable:@""];
        }
    }
    Title = [SelectedTotal stringByReplacingOccurrencesOfString:@"$1$" withString:[NSString stringWithFormat:@"%lu",(unsigned long)[check_array count]]];
    //Title = [NSString stringWithFormat:@"%lu %@",(unsigned long)[check_array count],SelectedTotal];

    self.NumberOfTitle.text = Title;


    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self EditSelectIconChange:EditLockAction];
#if 0
    NSError *error = nil;

    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];

            [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
                
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            cell.LockBox.hidden = NO;
        }
    }
    [self setToolView];
#endif
}
-(void)LockFileProcess
{
    NSError *error = nil;
    
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete forKey:NSFileProtectionKey];
            if(_listType == 1)
            {
                [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
            }
            else
            {
                [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
            }
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            cell.LockBox.hidden = NO;
        }
    }
    [self setToolView];
}
-(void)UnLockFileProcess
{
    NSError *error = nil;
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionCompleteUntilFirstUserAuthentication forKey:NSFileProtectionKey];
            if(_listType == 1)
            {
                    [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
            }
            else
            {
                [[NSFileManager defaultManager] setAttributes:attr ofItemAtPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]] error:&error];
            }
            NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            cell.LockBox.hidden = YES;
        }
    }
    [self setToolView];
}
-(void)DeleteFileProcess
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *Protect;
    
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            if(_listType == 1)
            {
                DeleteFileName = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
            }
            else
            {
                DeleteFileName = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
            }
            NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:DeleteFileName error:&error];
            
            if (fileAttributes != nil) {
                
                Protect = [fileAttributes objectForKey:NSFileProtectionKey];
                if([Protect isEqualToString:@"NSFileProtectionComplete"])
                {
                    
                }
                else
                {
                    [fileManager removeItemAtPath:DeleteFileName error:nil];
                }
                
            }
        }
    }
    [self setToolView];
    
    [fileListVideo removeAllObjects];
    [fileListImage removeAllObjects];
    
    if(_listType == 1)
    {
        fileListImage = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    else
    {
        fileListVideo = [self visitDirectoryList:DocumentPath Isascending:NO];
    }
    [file_tableView reloadData];
    long int section2 = [file_tableView numberOfSections];
    
    for (int i = 0;i<section2;i++) {
        long int row2 = [file_tableView numberOfRowsInSection:i];
        for(int j =0;j<row2;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            /*[cell.CheckBox setImage:[UIImage imageNamed:@"check_off"]];
             [cell.CheckBox setHidden:YES];*/
            cell.tag = 0;
        }
    }
}
-(void)ShareFileProcess
{
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            if(_listType == 1)
            {
                NSURL *outputURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListImage objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
                [selectURL addObject:outputURL];
                
            }
            else
            {
                
                
                NSURL *outputURL = [NSURL fileURLWithPath:[DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]]];
                [selectURL addObject:outputURL];
            }
        }
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:(NSArray*)selectURL applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
    [self setCheckArray];
    [selectURL removeAllObjects];
    
    
    
    
    [self setToolView];
}
-(void)CutFileProcess
{
    for(NSIndexPath *indexPath in check_array)
    {
        if([check_array containsObject:indexPath])
        {
            CutFileName = [DocumentPath stringByAppendingString:[NSString stringWithFormat:@"/%@",[[[fileListVideo objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"Name"]]];
        }
    }
    long int section = [file_tableView numberOfSections];
    for (int i = 0;i<section;i++) {
        long int row = [file_tableView numberOfRowsInSection:i];
        for(int j=0;j<row;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            /*[cell.CheckBox setImage:[UIImage imageNamed:@"check_off"]];
             [cell.CheckBox setHidden:YES];*/
            cell.tag = 0;
        }
    }
    
    
    [self setCheckArray];
    [self setToolView];
    //[]   2019/05/13  tom加的不知做什麼
    //**** stop player ****
    [_player pause];
    //file_previewIV.layer.sublayers = nil;
    
    file_videoPlayBT.selected = 0;
    _PlayerSlide.value = 0;
    [_player seekToTime:kCMTimeZero]; // seek to zero
    if(self.isPlay)
    {
        [_player removeTimeObserver:timeObserver];
        timeObserver = nil;
        self.isPlay = NO;
    }
    file_videoPlayBT.hidden = NO;
    //********
    
    [self performSegueWithIdentifier:@"CutVideoSegue" sender:self];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:file_tableView];
    NSIndexPath *indexPath = [file_tableView indexPathForRowAtPoint:p];
    if(indexPath == nil)
    {
        NSLog(@"long press on table viewbut not on a row ");
    }
    else
    {
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan && (LongPress == 0))
        {
            LongPress = 1;
            [self file_toolSwitchBT_clicked:(id)0];
        }
    }
}
-(UIFont*)adjFontSize:(UILabel*)label{
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
- (void) setCellFileNameSize {
    //get videlist max filename lenght
    long lenght = 0;
    NSString *fileNameTemp = @"";
    NSString *fileNameTemp2 = @"";
    long int section;
    long int row;
    UIFont *font;
    if(_listType == 1) {
        section = [file_tableView numberOfSections];
        for (int i = 0;i<section;i++) {
            row = [file_tableView numberOfRowsInSection:i];
            for(int j=0;j<row;j++) {
                if(lenght < [[[[fileListImage objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"] length]) {
                    lenght = [[[[fileListImage objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"] length];
                    fileNameTemp = [[[fileListImage objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"];
                }
            }
        }
    } else {
        section = [file_tableView numberOfSections];
        for (int i = 0;i<section;i++) {
            row = [file_tableView numberOfRowsInSection:i];
            for(int j=0;j<row;j++) {
                if(lenght < [[[[fileListVideo objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"] length]) {
                    lenght = [[[[fileListVideo objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"] length];
                    fileNameTemp = [[[fileListVideo objectAtIndex:i] objectAtIndex:j] objectForKey:@"Name"];
                }
            }
        }
    }
    //NSLog(@"filename = %@",fileNameTemp);
    //set cell font size
    
    curFileNameSize = 18;
    updateCellFontSize = YES;
    section = [file_tableView numberOfSections];
    for (int i = 0;i<section;i++) {
        row = [file_tableView numberOfRowsInSection:i];
        for(int j=0;j<row;j++)
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
            PlaybackCell *cell = (PlaybackCell *)[file_tableView cellForRowAtIndexPath:ip];
            //adj font size
            cell.FileName.adjustsFontSizeToFitWidth = YES;
            if(updateCellFontSize == YES &&
               cell != nil) {
                fileNameTemp2 = cell.FileName.text;//保存
                [cell.FileName setText:fileNameTemp];//設定最長的text
                font = [self adjFontSize:cell.FileName];//取最長的size
                [cell.FileName setText:fileNameTemp2];//設定回原本的text
                curFileNameSize = font.pointSize;
                updateCellFontSize = NO;
            }
            cell.FileName.font = [font fontWithSize:curFileNameSize];
            cell.PhotoCreateTime.font = [font fontWithSize:(curFileNameSize-5.0)];
            cell.FileLenth.font = [font fontWithSize:(curFileNameSize-5.0)];
            cell.FileSize.font = [font fontWithSize:(curFileNameSize-5.0)];
        }
    }
}
@end
