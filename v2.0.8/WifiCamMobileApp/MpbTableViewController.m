//
//  MpbTableViewController.m
//  WifiCamMobileApp
//
//  Created by ZJ on 2017/3/24.
//  Copyright © 2017年 iCatchTech. All rights reserved.
//

#import "MpbTableViewController.h"
#import "MpbTableViewCell.h"
#import "WifiCamControl.h"
#import "SDK.h"
#import "WifiCamTableViewSelectedCellTable.h"
#import "MpbPopoverViewController.h"
#import "DiskSpaceTool.h"
#import <SystemConfiguration/CaptiveNetwork.h>

#include "WifiCamSDKEventListener.h"
#include "PCMDataPlayer.h"
#include "MpbSDKEventListener.h"



@interface MpbTableViewController () {
    int observerNo;
    int ShowcCheckItem;
    int LockIconUpdate;
    BOOL FileHasExist;
    SSID_SerialCheck *SSIDSreial;
    
    VideoPbProgressListener *videoPbProgressListener;
    VideoPbProgressStateListener *videoPbProgressStateListener;
    VideoPbDoneListener *videoPbDoneListener;
    VideoPbServerStreamErrorListener *videoPbServerStreamErrorListener;
    
    NSString *dateFormat;
    
    CGFloat curFileNameSize;
    bool updateCellFontSize;
    
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@property(weak, nonatomic) UIBarButtonItem *actionButton;

@property(nonatomic, strong) WifiCam *wifiCam;
@property(nonatomic, strong) WifiCamPhotoGallery *gallery;
@property(nonatomic, strong) WifiCamControlCenter *ctrl;
@property(nonatomic, strong) WifiCamFileTable *fileTable;
@property (nonatomic) ICatchWificamPlayback *playback;
@property(nonatomic) WifiCamTableViewSelectedCellTable *selItemsTable;

@property(nonatomic, strong) NSCache *mpbCache;
@property(nonatomic) BOOL downloadFileProcessing;
@property(nonatomic) dispatch_queue_t thumbnailQueue;
@property(nonatomic) dispatch_queue_t downloadQueue;
@property(nonatomic) dispatch_queue_t downloadPercentQueue;
@property(nonatomic) MpbState curMpbState;

@property(nonatomic) BOOL cancelDownload;
@property(nonatomic) UIPopoverController *popController;
@property(nonatomic) unsigned long long totalDownloadSize;
@property(nonatomic) BOOL isSend;
@property(nonatomic) MBProgressHUD *progressHUD;
@property(nonatomic, getter = isFirstTimeLoaded) BOOL loaded;
@property(nonatomic) NSUInteger totalDownloadFileNumber;
@property(nonatomic) NSUInteger downloadedFileNumber;
@property(nonatomic) NSUInteger downloadedPercent;
@property(nonatomic) unsigned long long curDownloadSize;
@property(nonatomic) NSUInteger downloadedTotalPercent;
@property(nonatomic, getter = isRun) BOOL run;
@property(nonatomic) dispatch_semaphore_t mpbSemaphore;
@property(nonatomic) UIImage *videoPlaybackThumb;
@property(nonatomic) NSUInteger videoPlaybackIndex;
@property(nonatomic) NSUInteger videoPlaybackIndex_section;

@property(nonatomic) UIAlertController *actionSheet;
@property(nonatomic) NSUInteger totalCount;
@property(nonatomic) NSInteger downloadFailedCount;
@property(nonatomic) NSMutableArray *shareFiles;
@property(nonatomic) NSMutableArray *shareFileType;
@property(nonatomic) NSString *SSID;
@property(nonatomic) NSString *NewPaths;
@property(nonatomic) NSString *NvtFileLocalPaths;
/*ICATCH Player Para*/

@property(nonatomic) BOOL ReadyPlay;
@property(nonatomic) PCMDataPlayer *pcmPl;
@property(nonatomic) BOOL PlaybackRun;
@property(nonatomic, getter = isPlayed) BOOL played;
@property(nonatomic, getter = isPaused) BOOL paused;
@property(nonatomic) BOOL seeking;
@property(nonatomic) BOOL exceptionHappen;
@property(nonatomic, getter =  isControlHidden) BOOL controlHidden;
@property(nonatomic) dispatch_semaphore_t semaphore;
@property(nonatomic) NSTimer *pbTimer;
@property(nonatomic) double totalSecs;
@property(nonatomic) double playedSecs;
@property(nonatomic) double curVideoPTS;
@property(nonatomic) dispatch_group_t playbackGroup;
@property(nonatomic) dispatch_queue_t videoPlaybackQ;
@property(nonatomic) dispatch_queue_t audioQueue;
@property(nonatomic) dispatch_queue_t videoQueue;
@property(nonatomic) int times;
@property(nonatomic) int times1;
@property(nonatomic) float totalElapse;
@property(nonatomic) float totalElapse1;
@property(nonatomic) float totalDuration;
/*ICATCH Player Para*/
@property (strong, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic) int LongPress;
@end


@implementation MpbTableViewController

#pragma mark - Initialization
+ (instancetype)tableViewControllerWithIdentifier:(NSString *)identifier {
    UIStoryboard *mainStoryboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    } else {
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    return [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
}

// 懒加载
- (NSCache *)mpbCache {
    if (_mpbCache == nil) {
        _mpbCache = [[NSCache alloc] init];
        _mpbCache.countLimit = 100;
        _mpbCache.totalCostLimit = 4096;
    }
    
    return _mpbCache;
}

- (dispatch_queue_t)thumbnailQueue {
    if (_thumbnailQueue == nil) {
        _thumbnailQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Thumbnail", 0);
    }
    
    return _thumbnailQueue;
}

- (dispatch_queue_t)downloadQueue {
    if (_downloadQueue == nil) {
        _downloadQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Download", 0);
    }
    
    return _downloadQueue;
}

- (dispatch_queue_t)downloadPercentQueue {
    if (_downloadPercentQueue == nil) {
        _downloadPercentQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.DownloadPercent", 0);
    }
    
    return _downloadPercentQueue;
}

- (WifiCamTableViewSelectedCellTable *)selItemsTable {
    if (_selItemsTable == nil) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        _selItemsTable = [[WifiCamTableViewSelectedCellTable alloc] initWithParameters:array
                                                                    andCount:0];
    }

    return _selItemsTable;
}

- (dispatch_semaphore_t)mpbSemaphore {
    if (_mpbSemaphore == nil) {
        _mpbSemaphore = dispatch_semaphore_create(1);
    }
    
    return _mpbSemaphore;
}
#if 0
- (NSMutableArray *)visitDirectoryList:(NSString *)path Isascending:(BOOL)isascending {

    if(_curMpbMediaType == MpbMediaTypeVideo)
    {
        self.FileListVideoPropertyCopy = [self.FileListVideoProperty copy];
        self.FileListVideoPropertySort = [self.FileListVideoProperty sortedArrayUsingComparator:^(NSString *firFile, NSString *secFile) {  // 将文件列表排序
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
    format.dateFormat = @"yyyy-MM-dd";
    
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
    
    NSLog(@"visitDirectoryList = %@", listArray);
    return listArray;
}
#endif
- (void)resetCollectionViewData {
    AppLog(@"%s listFiles start ...",__func__);

    
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
\
        unsigned long long totalPhotoKBytes = 0;
        unsigned long long totalVideoKBytes = 0;
        unsigned long long totalAllKBytes = 0;

        
      
       /* for (int vcount = 0;vcount<section;vcount++)
        {
            for(int)
            
            //index = [_FileListChooseItem objectAtIndex:vcount];
            totalVideoKBytes += ([[[[_FileListVideoPropertySort objectAtIndex:vcount] objectAtIndex:row] objectForKey:@"VideoSize"] intValue]/1000);
        }
        for (int pcount = 0;pcount<_FileListPhotoPropertySort.count;pcount++)
        {
            long int row = [self.tableView numberOfRowsInSection:pcount];
            //index = [_FileListChooseItem objectAtIndex:pcount];
            totalPhotoKBytes += ([[[[_FileListPhotoPropertySort objectAtIndex:pcount] objectAtIndex:row] objectForKey:@"PhotoSize"] intValue]/1000);
        }*/
        for (int vcount = 0;vcount<_FileListVideoProperty.count;vcount++)
        {
            totalVideoKBytes += ([[[_FileListVideoProperty objectAtIndex:vcount] objectForKey:@"VideoSize"] intValue]/1000);
        }
        for (int pcount = 0;pcount<_FileListPhotoProperty.count;pcount++)
        {
            totalPhotoKBytes += ([[[_FileListPhotoProperty objectAtIndex:pcount] objectForKey:@"PhotoSize"] intValue]/1000);
        }
        
        totalAllKBytes = totalPhotoKBytes + totalVideoKBytes;
        /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraAssetsListSizeNotification"
                                                            object:@[@(photoListSize), @(videoListSize)]];*/
        if (_curMpbMediaType == MpbMediaTypePhoto) {
            if (_FileListPhotoProperty.count) {
                _NvtFileTable = [_FileListPhotoProperty count];
                _totalCount = [_FileListPhotoProperty count];;
            }
        } else {
            if (_FileListVideoProperty.count) {
                _NvtFileTable = [_FileListVideoProperty count];
                _totalCount = [_FileListVideoProperty count];
            }
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        _wifiCam.gallery = [WifiCamControl createOnePhotoGallery];
        self.gallery = _wifiCam.gallery;
        
        NSUInteger photoListSize = _gallery.imageTable.fileList.size();
        NSUInteger videoListSize = _gallery.videoTable.fileList.size();
        unsigned long long totalPhotoKBytes = _gallery.imageTable.fileStorage;
        unsigned long long totalVideoKBytes = _gallery.videoTable.fileStorage;
        unsigned long long totalAllKBytes = totalPhotoKBytes + totalVideoKBytes;
        
        AppLog(@"photoListSize: %lu", (unsigned long)photoListSize);
        AppLog(@"videoListSize: %lu", (unsigned long)videoListSize);
        AppLog(@"totalPhotoKBytes : %llu", totalPhotoKBytes);
        AppLog(@"totalVideoKBytes : %llu", totalVideoKBytes);
        AppLog(@"totalAllKBytes : %llu", totalAllKBytes);
        AppLog(@"listFiles end ...");
        
        /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraAssetsListSizeNotification"
                                                            object:@[@(photoListSize), @(videoListSize)]];*/
        
        if (_curMpbMediaType == MpbMediaTypePhoto) {
            if (_gallery.imageTable) {
                _fileTable = _gallery.imageTable;
                _totalCount = _gallery.imageTable.fileList.size();
            }
        } else {
            if (_gallery.videoTable) {
                _fileTable = _gallery.videoTable;
                _totalCount = _gallery.videoTable.fileList.size();
            }
        }
        [self sortList];
    }
}

#pragma mark - lifecycle
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
    
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    
    [self.tableView addGestureRecognizer:lpgr];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    delegate.delegate = self;
    delegate.allowRotation = YES;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        //[self NodePlayerInit];
       
    }
    else
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.ctrl = _wifiCam.controler;
        
        _totalSecs = 0;
        _playedSecs = 0;
        self.semaphore = dispatch_semaphore_create(1);
        self.playbackGroup = dispatch_group_create();
        self.videoPlaybackQ = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Q", 0);
        self.audioQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Audio", 0);
        self.videoQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Video", 0);
    }
    

    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    
    _NewPaths = [path stringByAppendingString:@"/KENWOOD DASH CAM MANAGER"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_NewPaths]) {
        //文件夹已存在
    } else {
        //创建文件夹
        [[NSFileManager defaultManager] createDirectoryAtPath:_NewPaths withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recoverFromDisconnection)
                                             name    :@"kCameraNetworkConnectedNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(destroySDKNotification)
                                             name    :@"kCameraDestroySDKNotification"
                                             object  :nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.FileListChooseItem = [[NSMutableArray alloc] init];
        [self NvtdataInit];
        [self NVTSendHttpCmd:@"3001" Par2:@"2"];
        [NSThread sleepForTimeInterval:1.0];
        [self NVTGetHttpCmd:@"3015"];
        [self sortList];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplete_Novatek) name:@"downloadComplete_Novatek" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFailed_Novatek) name:@"downloadFailed_Novatek" object:nil];
    }
    self.run = YES;
    
    if (_curMpbState == MpbStateNor) {
        [self.selItemsTable.selectedCells removeAllObjects];
        [self postButtonStateChangeNotification:NO];
    }
}
- (void)NvtdataInit
{
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];

    self.FileListVideoProperty = [[NSMutableArray alloc] init];
    self.FileListPhotoProperty = [[NSMutableArray alloc] init];
    self.FileVideoInfo = [[NSMutableDictionary alloc] init];
    self.FilePhotoInfo = [[NSMutableDictionary alloc] init];
    self.FileListVideoPropertyCopy = [[NSArray alloc] init];
    self.FileListPhotoPropertyCopy = [[NSArray alloc] init];
    self.FileListVideoPropertySort = [[NSMutableArray alloc] init];
    self.FileListPhotoPropertySort = [[NSMutableArray alloc] init];
    self.NvtFileWigth = [[NSString alloc] init];
    self.NvtFileHeight = [[NSString alloc] init];
    self.NvtFileLength = [[NSString alloc] init];
}
- (void)recoverFromDisconnection {
    AppLog(@"%s", __func__);
   
    
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.ctrl = _wifiCam.controler;
    }
    
    [self.tableView reloadData];
    [self setCellFileNameSize];
}

- (void)destroySDKNotification
{
    AppLog(@"receive destroySDKNotification.");
    self.run = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewDidAppear:animated];
    if (!_loaded) {
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];
        
        // Get list and udpate collection-view
        dispatch_async(self.thumbnailQueue, ^{
            [self resetCollectionViewData];
            //[self sortList];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                self.loaded = YES;                
                [self.tableView reloadData];
                [self setCellFileNameSize];
                
            });
        });
    } else {
       // [self.tableView reloadData];
    }
    [self sortList];
    //NSLog(@"AAAA->A  %lu",(unsigned long)[_FileListVideoPropertySort count]);
    //NSLog(@"AAAA->B  %lu",(unsigned long)[_FileListPhotoPropertySort count]);
    //NSLog(@"AAAA->C  %@",[[_FileListVideoPropertySort objectAtIndex:0] objectForKey:@"VideoTime"]);
    //NSLog(@"AAAA->D  %@",[[_FileListPhotoPropertySort objectAtIndex:0] objectForKey:@"PhotoTime"]);
    //PhotoTime
    /*
    NSString *firData=@"",*secData=@"";
    for(int i=0;i<[_FileListPhotoProperty count];i++) {
        if(i>0) {
            firData = [[_FileListPhotoProperty objectAtIndex:i-1] objectForKey:@"PhotoTime"];
            secData = [[_FileListPhotoProperty objectAtIndex:i] objectForKey:@"PhotoTime"];
            if (isascending) {
                [firData compare:secData];  // 升序
            } else {
                [secData compare:firData];  // 降序
            }
        }
        
    }*/
    
    /*if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        mpbSegmentViewController.NovatekPlayerInit;
    }*/
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewWillDisappear:animated];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.allowRotation = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.run = NO;
    
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
#if USE_SYSTEM_IOS7_IMPLEMENTATION
    if (_actionSheet.visible) {
        [_actionSheet dismissWithClickedButtonIndex:0 animated:NO];
    }
#else
    [_actionSheet dismissViewControllerAnimated:NO completion:nil];
#endif
    
    if (self.selItemsTable.count > 0 || observerNo > 0 ) {
        [self.selItemsTable removeObserver:self forKeyPath:@"count"];
        --observerNo;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    
    
    
    [[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    AppLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.mpbCache removeAllObjects];
}

- (void)dealloc
{
    AppLog(@"%s", __func__);
    [self.mpbCache removeAllObjects];
    [connect cancel];
}

- (void) sortList {
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
        self.FileListVideoProperty = [self.FileListVideoProperty sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *firFile, NSMutableDictionary *secFile) {  // 将文件列表排序
            
            return [[secFile objectForKey:@"VideoTime"] compare:[firFile objectForKey:@"VideoTime"]];
        }];
        self.FileListPhotoProperty = [self.FileListPhotoProperty sortedArrayUsingComparator:^NSComparisonResult(NSMutableDictionary *firFile, NSMutableDictionary *secFile) {  // 将文件列表排序
            
            return [[secFile objectForKey:@"PhotoTime"] compare:[firFile objectForKey:@"PhotoTime"]];
        }];
        int section = 0;
        NSString *preString=@"",*curString=@"";
        _FileListVideoPropertyTemp = [[NSMutableArray alloc] init];
        _FileListVideoPropertySort = [[NSMutableArray alloc] init];
        for(int i=0;i<[_FileListVideoProperty count];i++) {
            if(i > 0) {
                preString = [[[_FileListVideoProperty objectAtIndex:i-1] objectForKey:@"VideoTime"] substringWithRange:NSMakeRange(0, 10)];
                curString = [[[_FileListVideoProperty objectAtIndex:i] objectForKey:@"VideoTime"] substringWithRange:NSMakeRange(0, 10)];
                if(![preString isEqual:curString]) {
                    section++;
                    _FileListVideoPropertyTemp = [[NSMutableArray alloc] init];
                    [_FileListVideoPropertyTemp addObject:[_FileListVideoProperty objectAtIndex:i]];
                    [_FileListVideoPropertySort addObject:_FileListVideoPropertyTemp];
                } else {
                    [[_FileListVideoPropertySort objectAtIndex:section] addObject:[_FileListVideoProperty objectAtIndex:i]];
                }
            } else {
                [_FileListVideoPropertyTemp addObject:[_FileListVideoProperty objectAtIndex:i]];
                [_FileListVideoPropertySort addObject:_FileListVideoPropertyTemp];
            }
        }
        section = 0;
        _FileListPhotoPropertyTemp = [[NSMutableArray alloc] init];
        _FileListPhotoPropertySort = [[NSMutableArray alloc] init];
        for(int i=0;i<[_FileListPhotoProperty count];i++) {
            if(i > 0) {
                preString = [[[_FileListPhotoProperty objectAtIndex:i-1] objectForKey:@"PhotoTime"] substringWithRange:NSMakeRange(0, 10)];
                curString = [[[_FileListPhotoProperty objectAtIndex:i] objectForKey:@"PhotoTime"] substringWithRange:NSMakeRange(0, 10)];
                if(![preString isEqual:curString]) {
                    section++;
                    _FileListPhotoPropertyTemp = [[NSMutableArray alloc] init];
                    [_FileListPhotoPropertyTemp addObject:[_FileListPhotoProperty objectAtIndex:i]];
                    [_FileListPhotoPropertySort addObject:_FileListPhotoPropertyTemp];
                } else {
                    [[_FileListPhotoPropertySort objectAtIndex:section] addObject:[_FileListPhotoProperty objectAtIndex:i]];
                }
                
            } else {
                [_FileListPhotoPropertyTemp addObject:[_FileListPhotoProperty objectAtIndex:i]];
                [_FileListPhotoPropertySort addObject:_FileListPhotoPropertyTemp];
            }
        }
    } else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial) {
        NSString *dateStr = @"",*dateStr2=@"",*dateStr_pre = @"",*dateStr2_pre=@"";
        int array[_fileTable.fileList.size()],temp = 0;
        vector<ICatchFile> fileList_temp;
        //排序
        for(int i=0;i<_fileTable.fileList.size();i++) {
            array[i] = i;
        }
        for(int i=0;i<_fileTable.fileList.size();i++) {
            for(int j=(i+1);j<_fileTable.fileList.size();j++) {
                //*********** pre file
                dateStr_pre = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(i).getFileDate().c_str()]];
                
                dateStr2_pre = [NSString stringWithFormat:@"%@%@%@",[dateStr_pre substringWithRange:NSMakeRange(9, 2)],[dateStr_pre substringWithRange:NSMakeRange(11, 2)],[dateStr_pre substringWithRange:NSMakeRange(13, 2)]];
                dateStr_pre = [NSString stringWithFormat:@"%@%@%@",[dateStr_pre substringWithRange:NSMakeRange(0, 4)],[dateStr_pre substringWithRange:NSMakeRange(4, 2)],[dateStr_pre substringWithRange:NSMakeRange(6, 2)]];
                //******** cur file
                dateStr = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(j).getFileDate().c_str()]];
                
                dateStr2 = [NSString stringWithFormat:@"%@%@%@",[dateStr substringWithRange:NSMakeRange(9, 2)],[dateStr substringWithRange:NSMakeRange(11, 2)],[dateStr substringWithRange:NSMakeRange(13, 2)]];
                dateStr = [NSString stringWithFormat:@"%@%@%@",[dateStr substringWithRange:NSMakeRange(0, 4)],[dateStr substringWithRange:NSMakeRange(4, 2)],[dateStr substringWithRange:NSMakeRange(6, 2)]];
                if(![dateStr_pre  isEqual: @""] && ![dateStr2_pre  isEqual: @""]) {
                    if([dateStr intValue]-[dateStr_pre intValue] > 0) {
                        temp = array[i];
                        array[i] = array[j];
                        array[j] = temp;
                    } else if([dateStr intValue]-[dateStr_pre intValue] == 0) {
                        if([dateStr2 intValue]-[dateStr2_pre intValue] > 0) {
                            temp = array[i];
                            array[i] = array[j];
                            array[j] = temp;
                            
                        }
                    }
                }
            }
            
        }
        for(int i=0;i<_fileTable.fileList.size();i++) {
            fileList_temp.push_back(_fileTable.fileList.at(array[i]));
            dateStr_pre = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:fileList_temp.at(i).getFileDate().c_str()]];
        }
        _fileTable.fileList = fileList_temp;
        for(int i=0;i<_fileTable.fileList.size();i++) {
            dateStr_pre = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(i).getFileDate().c_str()]];
        }
        //分組
        int section = 0;
        _FileListICatchPropertyTemp = [[NSMutableArray alloc] init];
        _FileListICatchPropertySort = [[NSMutableArray alloc] init];
        for(int i=0;i<_fileTable.fileList.size();i++) {
            dateStr = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(i).getFileDate().c_str()]];
            dateStr = [NSString stringWithFormat:@"%@%@%@",[dateStr substringWithRange:NSMakeRange(0, 4)],[dateStr substringWithRange:NSMakeRange(4, 2)],[dateStr substringWithRange:NSMakeRange(6, 2)]];
            if(i > 0) {
                dateStr_pre = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(i-1).getFileDate().c_str()]];
                dateStr_pre = [NSString stringWithFormat:@"%@%@%@",[dateStr_pre substringWithRange:NSMakeRange(0, 4)],[dateStr_pre substringWithRange:NSMakeRange(4, 2)],[dateStr_pre substringWithRange:NSMakeRange(6, 2)]];
                if(![dateStr_pre isEqual:dateStr]) {
                    section++;
                    _FileListICatchPropertyTemp = [[NSMutableArray alloc] init];
                    [_FileListICatchPropertyTemp addObject:[NSString stringWithFormat:@"%d",i]];
                    [_FileListICatchPropertySort addObject:_FileListICatchPropertyTemp];
                } else {
                    [[_FileListICatchPropertySort objectAtIndex:section] addObject:[NSString stringWithFormat:@"%d",i]];
                }
            } else {
                [_FileListICatchPropertyTemp addObject:[NSString stringWithFormat:@"%d",i]];
                [_FileListICatchPropertySort addObject:_FileListICatchPropertyTemp];
            }
        }
    }
}
- (bool) myfunction :(int)i sec:(int)j {
    return (i<j);
}

#pragma mark - Action Progress
- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.view];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        // The sample image is based on the
        // work by: http://www.pixelpressicons.com
        // licence: http://creativecommons.org/licenses/by/2.5/ca/
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/Checkmark.png"]];
        [self.view addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
}

- (void)showProgressHUDNotice:(NSString *)message
                     showTime:(NSTimeInterval)time{
    AppLog(@"%s", __func__);
    self.navigationController.toolbar.userInteractionEnabled = NO;
    if (message) {
        [self.view bringSubviewToFront:self.progressHUD];
        [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.labelFont = [UIFont systemFontOfSize:12];
        self.progressHUD.mode = MBProgressHUDModeText;
        self.progressHUD.dimBackground = YES;
        [self.progressHUD hide:YES afterDelay:time];
    } else {
        [self.progressHUD hide:YES];
    }
    //self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    AppLog(@"%s", __func__);
    if (message) {
        if (self.progressHUD.isHidden) [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.detailsLabelText = nil;
        self.progressHUD.mode = MBProgressHUDModeCustomView;
        [self.progressHUD hide:YES afterDelay:1.0];
    } else {
        [self.progressHUD hide:YES];
    }
    //self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
}

- (void)showProgressHUDWithMessage:(NSString *)message
                    detailsMessage:(NSString *)dMessage
                              mode:(MBProgressHUDMode)mode {
    AppLog(@"%s", __func__);
    self.progressHUD.labelText = message;
    self.progressHUD.detailsLabelText = dMessage;
    self.progressHUD.mode = mode;
    self.progressHUD.dimBackground = YES;
    [self.view bringSubviewToFront:self.progressHUD];
    [self.progressHUD show:YES];
    //self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.navigationController.toolbar.userInteractionEnabled = NO;
    
}

- (void)updateProgressHUDWithMessage:(NSString *)message
                      detailsMessage:(NSString *)dMessage {
    AppLog(@"%s", __func__);
    if (message) {
        self.progressHUD.labelText = message;
    }
    if (dMessage) {
        self.progressHUD.progress = _downloadedPercent / 100.0;
        self.progressHUD.detailsLabelText = dMessage;
    }
}

- (void)hideProgressHUD:(BOOL)animated {
    AppLog(@"%s", __func__);
    [self.progressHUD hide:animated];
    //self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.navigationController.toolbar.userInteractionEnabled = YES;
    
}
#pragma mark - MPB
- (void)goHome:(id)sender
{
    AppLog(@"%s", __func__);
    self.run = NO;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if((deviceOrientation == UIDeviceOrientationLandscapeLeft)||(deviceOrientation == UIDeviceOrientationLandscapeRight))
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                      detailsMessage:nil
                                mode:MBProgressHUDModeIndeterminate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(self.mpbSemaphore, time) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDCompleteMessage:NSLocalizedString(@"STREAM_WAIT_FOR_VIDEO", nil)];
            });
        } else {
            dispatch_semaphore_signal(self.mpbSemaphore);
            if(_played)
            {
                [self stopVideoPb];
                [self removePlaybackObserver];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self dismissViewControllerAnimated:YES completion:^{
                    AppLog(@"MPB QUIT ...");
                }];
            });
        }
    });
}

- (void)edit:(id)sender
{
    AppLog(@"%s", __func__);
    ShowcCheckItem = 1;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    NSIndexPath *index;
    if (_curMpbState == MpbStateNor) {
        //self.navigationItem.leftBarButtonItem = nil;
        //self.title = NSLocalizedString(@"SelectItem", nil);
        self.curMpbState = MpbStateEdit;
        mpbSegmentViewController.EditState = YES;
        mpbSegmentViewController.UpdateEditBar;
        if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            /*[self.selItemsTable addObserver:self forKeyPath:@"count" options:0x0 context:nil];
            observerNo++;*/
            long int section = [self.tableView numberOfSections];
            for(int j=0;j<section;j++) {
                long int lastrow = [[self tableView] numberOfRowsInSection:j];
                for (int i = 0;i<lastrow;i++) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:j];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    [cell setCellBGHidden:YES];
                    //[cell setClickOffIcon];
                    //[cell setSelectedConfirmIconHidden:NO];
                    cell.tag = 0;
                }
            }
            [self.selItemsTable.selectedCells removeAllObjects];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            long int section = [self.tableView numberOfSections];
            for(int j=0;j<section;j++) {
                long int lastrow = [[self tableView] numberOfRowsInSection:j];
                for (int i = 0;i<lastrow;i++) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:j];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    //[cell setClickOffIcon];
                    //[cell setSelectedConfirmIconHidden:NO];
                    cell.tag = 0;
                }
            }
            
            [_FileListChooseItem removeAllObjects];
        }
    } else {
        _LongPress = 0;
        self.curMpbState = MpbStateNor;
        mpbSegmentViewController.EditState = NO;
        mpbSegmentViewController.ActionType = PBEditNone;
        mpbSegmentViewController.UpdateActionIcon;
        mpbSegmentViewController.UpdateEditBar;
        if ([_popController isPopoverVisible]) {
            [_popController dismissPopoverAnimated:YES];
        }
        if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            if ([_ctrl.fileCtrl isBusy]) {
                // Cancel download
                self.cancelDownload = YES;
                [_ctrl.fileCtrl cancelDownload];
            }
        
        
        
       
        
            // Clear

            /*    for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    [cell setSelectedConfirmIconHidden:NO];
                    cell.tag = 0;
                }
            */
           /* if (!_cancelDownload) {
                [self.selItemsTable.selectedCells removeAllObjects];
            }*/
            
            self.selItemsTable.count = 0;
            /*[self.selItemsTable removeObserver:self forKeyPath:@"count"];
            --observerNo;*/
            self.totalDownloadSize = 0;
            //_isSend = NO;
        }
        
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            long int section = [self.tableView numberOfSections];
            for(int j=0;j<section;j++) {
                long int lastrow = [[self tableView] numberOfRowsInSection:j];
                for (int i = 0;i<lastrow;i++) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:j];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    [cell setCellBGHidden:YES];
                    //[cell setClickOffIcon];
                    //[cell setSelectedConfirmIconHidden:YES];
                    cell.tag = 0;
                }
            }
            
            [_FileListChooseItem removeAllObjects];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            long int section = [self.tableView numberOfSections];
            for(int j=0;j<section;j++) {
                long int lastrow = [[self tableView] numberOfRowsInSection:j];
                for (int i = 0;i<lastrow;i++) {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:j];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    [cell setCellBGHidden:YES];
                    //[cell setClickOffIcon];
                    //[cell setSelectedConfirmIconHidden:YES];
                    cell.tag = 0;
                }
            }
            
        }
    }
     //[self.tableView reloadData];
    AppLog(@"%s, curMpbState: %d", __func__, _curMpbState);;
}

-(void)showPopoverFromBarButtonItem:(UIBarButtonItem *)item
                            message:(NSString *)message
                    fireButtonTitle:(NSString *)fireButtonTitle
                           callback:(SEL)fireAction
{
    AppLog(@"%s", __func__);
    MpbPopoverViewController *contentViewController = [[MpbPopoverViewController alloc] initWithNibName:@"MpbPopover" bundle:nil];
    contentViewController.msg = message;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        contentViewController.msgColor = [UIColor blackColor];
    } else {
        contentViewController.msgColor = [UIColor whiteColor];
    }
    
    UIPopoverController *popController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    if (fireButtonTitle) {
        UIButton *fireButton = [[UIButton alloc] initWithFrame:CGRectMake(5.0f, 110.0f, 260.0f, 47.0f)];
        popController.popoverContentSize = CGSizeMake(270.0f, 170.0f);
        fireButton.enabled = YES;
        
        [fireButton setTitle:fireButtonTitle
                    forState:UIControlStateNormal];
        [fireButton setBackgroundImage:[[UIImage imageNamed:@"iphone_delete_button.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f]
                              forState:UIControlStateNormal];
        [fireButton addTarget:self action:fireAction forControlEvents:UIControlEventTouchUpInside];
        [contentViewController.view addSubview:fireButton];
    } else {
        popController.popoverContentSize = CGSizeMake(270.0f, 160.0f);
    }
    
    self.popController = popController;
    [_popController presentPopoverFromBarButtonItem:item permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)showActionSheetFromBarButtonItem:(UIBarButtonItem *)item
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                 destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                    tag:(NSInteger)tag
{
    AppLog(@"%s", __func__);
#if USE_SYSTEM_IOS7_IMPLEMENTATION
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:message
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                     destructiveButtonTitle:destructiveButtonTitle
                                          otherButtonTitles:nil, nil];
    _actionSheet.tag = tag;
    [_actionSheet showFromBarButtonItem:item animated:YES];
#else
    self.actionSheet = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [_actionSheet addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:nil]];
    if (destructiveButtonTitle != nil) {
        [_actionSheet addAction:[UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            switch (tag) {
                case ACTION_SHEET_DOWNLOAD_ACTIONS:
                    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial){
                        NSString *fileName = @"";
                        float fileSize = 0;
                        int section = 0,row = 0;
                        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
                        [mpbSegmentViewController initDownloadManager];
                        for(int i=0;i<_FileListChooseItem.count;i++) {
                            NSIndexPath *index = [_FileListChooseItem objectAtIndex:i];
                            if(_curMpbMediaType == MpbMediaTypeVideo)
                            {
                                
                                fileName = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoName"];
                                fileSize = [[[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoSize"] floatValue]/1024/1024;
                            }
                            else
                            {
                                fileName = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoName"];
                                fileSize = [[[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoSize"] floatValue]/1024/1024;
                            }
                            [mpbSegmentViewController addDownloadManager:fileName fileSize:fileSize];
                            
                        }
                        [mpbSegmentViewController updateDownloadCell];
                        FileNumber = 0;
                        
                        [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
                        [self NvtdownloadDetail:item];
                    }
                    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
                    {
                        [self downloadDetail:item];
                    }
                    break;
                    
                case ACTION_SHEET_DELETE_ACTIONS:
                    [self deleteDetail:item];
                    break;
                    
                default:
                    break;
            }
        }]];
    }
    
    [self presentViewController:_actionSheet animated:YES completion:nil];
#endif
}
- (IBAction)NvtdownloadDetail:(id)sender{
    
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    //NSString *Fpath,*NvtRealPath;
    __block NSString *NvtRealPath;
    NSSortDescriptor *sort;
    if(_FileListChooseItem.count <= 0) {
        return;
    }
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    if(![mpbSegmentViewController needDownloadFile:FileNumber]) {
        if(FileNumber == _FileListChooseItem.count-1) {
            [mpbSegmentViewController downloadCompletedNotice];
            FileNumber = 0;
            _totalDownloadSize = 0;
            [self edit:(id)@"3"];
            [self tableViewCellEnable];
            self.receiveLength = 0;
            self.NVT_Download_totalLength = 0;
            return;
        } else {
            
            [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
            [mpbSegmentViewController downloadFailed];
            NSLog(@"NvtdownloadDetail  FileNumber = %d",FileNumber);
            FileNumber++;
            [self NvtdownloadDetail:(id)@"3"];
            return;
        }
    }
    
    [self tableViewCellDisable];
    
    
    
    sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    //[_FileListChooseItem sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    //long int ChooseNumber = [[_FileListChooseItem objectAtIndex:FileNumber] row];
    
    NSIndexPath *index = [_FileListChooseItem objectAtIndex:FileNumber];
    if(_curMpbMediaType == MpbMediaTypeVideo)
    {
        
        NvtRealPath = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoFullName"];
        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                         withString:@""];
        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                         withString:@"/"];
    }
    else
    {
        //Fpath = @"PHOTO/";
        NvtRealPath = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoFullName"];
        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                             withString:@""];
        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                             withString:@"/"];
    }
    
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/",NvtRealPath];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //[delegate beginDownloadWithUrl:fullcmd];
    NSURL *url = [NSURL URLWithString:fullcmd];
    NSURLRequest *reques = [NSURLRequest requestWithURL:url];
    connect = [NSURLConnection connectionWithRequest:reques delegate:self];
}
- (IBAction)SeekToSecond:(double)value
{
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
         mpbSegmentViewController.updatePlayerStatusSetTrue;

        
    }
    else
    {
        if(self.played)
        {
            BOOL retVal = [_ctrl.pbCtrl seek:value];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (retVal) {
                    AppLog(@"Seek succeed.");
                    self.playedSecs = value;
                    self.curVideoPTS = _playedSecs;
                  
                } else {
                    AppLog(@"Seek failed.");
                    [self showProgressHUDNotice:@"Seek failed" showTime:2.0];
                }
                self.pbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                              target  :self
                                                              selector:@selector(updateTimeInfo:)
                                                              userInfo:nil
                                                              repeats :YES];

            });
        }
    }
    self.seeking = NO;
}
- (IBAction)sliderTouchDown:(BOOL)isSeek
{
    _seeking = isSeek;
}
-(void)SelectEditAction:(int)ActionMode
{
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    if(ActionMode == PBEditNone)
    {
        mpbSegmentViewController.ActionType = PBEditNone;
        mpbSegmentViewController.UpdateActionIcon;
    }
    else if(ActionMode == PBEditLockAction)
    {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [_FileListChooseItem count];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [self.selItemsTable.selectedCells count];
        }
        mpbSegmentViewController.ActionType = PBEditLockAction;
        mpbSegmentViewController.UpdateActionIcon;
    }
    else if(ActionMode == PBEditUnLockAction)
    {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [_FileListChooseItem count];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [self.selItemsTable.selectedCells count];
        }
        mpbSegmentViewController.ActionType = PBEditUnLockAction;
        mpbSegmentViewController.UpdateActionIcon;
    }
    else if(ActionMode == PBEditDeleteAction)
    {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [_FileListChooseItem count];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [self.selItemsTable.selectedCells count];
        }
        mpbSegmentViewController.ActionType = PBEditDeleteAction;
        mpbSegmentViewController.UpdateActionIcon;
    }
    else if(ActionMode == PBEditDownloadAction)
    {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [_FileListChooseItem count];
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            mpbSegmentViewController.SelectNum = [self.selItemsTable.selectedCells count];
        }
        mpbSegmentViewController.ActionType = PBEditDownloadAction;
        mpbSegmentViewController.UpdateActionIcon;
    }
    
}
- (IBAction)OKAction:(int)ActionType
{
    if(PBEditLockAction == ActionType)
    {
        [self LockProcess];
    }
    else if(PBEditUnLockAction == ActionType)
    {
        [self UnLockProcess];
    }
    else if(PBEditDeleteAction == ActionType)
    {
        [self DeleteProcess];
    }
    else if(PBEditDownloadAction == ActionType)
    {
        [self DownloadProcess];
    }
}
-(void)LockProcess
{
   
    __block NSString *NvtRealPath;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(_FileListChooseItem.count > 5)
        {
            [self showProgressHUDNotice:[delegate getStringForKey:@"SetLockItemOverfive" withTable:@""]
                               showTime:1.0];
        }
        else
        {
            [self showProgressHUDWithMessage:nil];
            NSLog(@"chooseItem = %lu",(unsigned long)[_FileListChooseItem count]);
         
            for(int i = 0;i<[_FileListChooseItem count];i++)
            {
                NSIndexPath *index = [_FileListChooseItem objectAtIndex:i];
                
                //NSLog(@"_FileListVideoProperty = %@",[_FileListVideoProperty objectAtIndex:i]);
                //long int ChooseNumber = [[[_FileListChooseItem objectAtIndex:index.section] objectAtIndex:index.row] row];
                
                    if(_curMpbMediaType == MpbMediaTypeVideo)
                    {
                      //  Fpath = @"VIDEO/";
                        NvtRealPath = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoFullName"];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                             withString:@""];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                             withString:@"/"];
                        [self httpAsynchronousRequest:@"4006" FullFileName:NvtRealPath parameter:@"1"];
                    }
                    else
                    {
                        
                        NvtRealPath = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoFullName"];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                             withString:@""];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                             withString:@"/"];
                        [self httpAsynchronousRequest:@"4006" FullFileName:NvtRealPath parameter:@"1"];
                    }
                     [NSThread sleepForTimeInterval:0.5];
            }
            [self.FileListVideoPropertySort removeAllObjects];
            [self.FileListPhotoPropertySort removeAllObjects];
            
            [self NvtdataInit];
            [self NVTSendHttpCmd:@"3001" Par2:@"2"];
            [NSThread sleepForTimeInterval:1.0];
            [self NVTGetHttpCmd:@"3015"];
            //[NSThread sleepForTimeInterval:0.5];
            [self sortList];
           
            
           
            for(NSIndexPath *indexPath in self.FileListChooseItem)
            {
                if([self.FileListChooseItem containsObject:indexPath])
                {
                    //NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    
                    if(_curMpbMediaType == MpbMediaTypePhoto)
                    {
                        int lock = [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoAttr"] intValue] & 1;
                        if(lock)
                        {
                            [cell setLockIconHidden:NO];
                        }
                        else
                        {
                            [cell setLockIconHidden:YES];
                        }
                    }
                    else
                    {
                        int lock = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoAttr"] intValue] & 1;
                        if(lock)
                        {
                            [cell setLockIconHidden:NO];
                        }
                        else
                        {
                            [cell setLockIconHidden:YES];
                        }
                    }
                }
            }
            
            [self hideProgressHUD:YES];
            [_FileListChooseItem removeAllObjects];
            [self edit:nil];
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if(self.selItemsTable.selectedCells.count > 5)
        {
            [self showProgressHUDNotice:[delegate getStringForKey:@"SetLockItemOverfive" withTable:@""]
                               showTime:1.0];
        }
        else
        {
#if 0
            [self showProgressHUDWithMessage:nil];
            NSLog(@"chooseItem = %lu",(unsigned long)[self.selItemsTable.selectedCells count]);
            /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{*/
                for(int i = 0;i<self.selItemsTable.selectedCells.count;i++)
                {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                    long int ChooseNumber = [[self.selItemsTable.selectedCells objectAtIndex:i] row];
                    NSLog(@"ChooseNumber = %lu",[[self.selItemsTable.selectedCells objectAtIndex:i] row]);
                    if(_curMpbMediaType == MpbMediaTypeVideo)
                    {
                        NSString *IcatchFileFullName;
                        ICatchFile file = _fileTable.fileList.at(ChooseNumber);
                        IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:1;N:1;",file.getFilePath().c_str()];
                        
                        
                        
                        NSLog(@"LockName = %@",IcatchFileFullName);
                        
                        [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];

                    }
                    else
                    {
                        NSString *IcatchFileFullName;
                        ICatchFile file = _fileTable.fileList.at(ChooseNumber);
                        IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:1;N:1;",file.getFileName().c_str()];
                        
                        NSLog(@"LockName = %@",IcatchFileFullName);
                        [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];

                    }
                    
                }
                /*dispatch_async(dispatch_get_main_queue(), ^{*/
                    //[self.tableView reloadData];
            
                    
                    long int lastrow = [[self tableView] numberOfRowsInSection:0];
                    for (int i = 0;i<lastrow;i++) {
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                        MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                        ICatchFile file = _fileTable.fileList.at(i);
                        NSLog(@"vvvd%s",file.getFilePath().c_str());
                        [cell setLockIconHidden:NO];
                        
                        cell.tag = 0;
                    }
                    self.totalDownloadSize = 0;
            
            
                    //[self showProgressHUDNotice:@"Files Lock" showTime:1.0];
                    //[self.selItemsTable.selectedCells removeAllObjects];
                    [NSThread sleepForTimeInterval:2];
            
                    [self resetCollectionViewData];
                    [self hideProgressHUD:YES];
                    /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                    object:@(nil)];*/
            
                    [self edit:nil];
                /*});*/
                
            /*});*/
#else
            NSString *IcatchFileFullName;
            for(NSIndexPath *indexPath in self.selItemsTable.selectedCells)
            {
                if([self.selItemsTable.selectedCells containsObject:indexPath])
                {
                    //NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    int index = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
                    ICatchFile file = _fileTable.fileList.at(index);
                    
                    IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:1;N:1;",file.getFilePath().c_str()];
                    
                    [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];
                    [cell setLockIconHidden:NO];
                }
            }
            [self resetCollectionViewData];
            [self edit:nil];
#endif
        }
        
    }
}
-(void)UnLockProcess
{

    __block NSString *NvtRealPath;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(_FileListChooseItem.count > 5)
        {
            [self showProgressHUDNotice:[delegate getStringForKey:@"SetLockItemOverfive" withTable:@""]
                               showTime:1.0];
        }
        else
        {
            
            [self showProgressHUDWithMessage:nil];
                for(int i = 0;i<[_FileListChooseItem count];i++)
                {
                    NSIndexPath *index = [_FileListChooseItem objectAtIndex:i];
                    //long int ChooseNumber = [[self.FileListChooseItem objectAtIndex:i] row];
                    if(_curMpbMediaType == MpbMediaTypeVideo)
                    {
                        //Fpath = @"VIDEO/";
                        NvtRealPath = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoFullName"];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                             withString:@""];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                             withString:@"/"];
                        [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"0"];
                        
                    }
                    else
                    {
                        //Fpath = @"PHOTO/";
                        NvtRealPath = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoFullName"];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                             withString:@""];
                        NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                             withString:@"/"];
                        [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"0"];
                    }
                      [NSThread sleepForTimeInterval:0.5];
                }
                [self NvtdataInit];
                [self NVTSendHttpCmd:@"3001" Par2:@"2"];
                [NSThread sleepForTimeInterval:1.0];
                [self NVTGetHttpCmd:@"3015"];
                //[NSThread sleepForTimeInterval:0.5];
                [self sortList];
#if 0
                dispatch_async(dispatch_get_main_queue(), ^{
                    long int lastrow = [[self tableView] numberOfRowsInSection:0];
                    for (int i = 0;i<lastrow;i++) {
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                        MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                        if(_curMpbMediaType == MpbMediaTypePhoto)
                        {
                            if([[[_FileListPhotoProperty objectAtIndex:i] objectForKey:@"PhotoLock"] intValue])
                            {
                                [cell setLockIconHidden:NO];
                            }
                            else
                            {
                                [cell setLockIconHidden:YES];
                            }
                        }
                        else
                        {
                            int lock = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoAttr"] intValue] & 1;
                            if(lock)
                            {
                                [cell setLockIconHidden:NO];
                            }
                            else
                            {
                                [cell setLockIconHidden:YES];
                            }
                        }
                        [cell setSelectedConfirmIconHidden:YES];
                        cell.tag = 0;
                    }
                    
                    
                    //[self.tableView reloadData];
                    [self hideProgressHUD:YES];
                    //[self showProgressHUDNotice:@"Files UnLock" showTime:1.0];
                    /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                                                                        object:@(nil)];*/
                    [self.FileListChooseItem removeAllObjects];
                    [self edit:nil];
                });
#else
            for(NSIndexPath *indexPath in self.FileListChooseItem)
            {
                if([self.FileListChooseItem containsObject:indexPath])
                {
                    //NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    
                    if(_curMpbMediaType == MpbMediaTypePhoto)
                    {
                        int lock = [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoAttr"] intValue] & 1;
                        if(lock)
                        {
                            [cell setLockIconHidden:NO];
                        }
                        else
                        {
                            [cell setLockIconHidden:YES];
                        }
                    }
                    else
                    {
                        int lock = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoAttr"] intValue] & 1;
                        if(lock)
                        {
                            [cell setLockIconHidden:NO];
                        }
                        else
                        {
                            [cell setLockIconHidden:YES];
                        }
                    }
                }
            }
            [self hideProgressHUD:YES];
            [self.FileListChooseItem removeAllObjects];
            [self edit:nil];
#endif
            //NSLog(@"choose item position is:%ld",(long)[[_FileListChooseItem objectAtIndex:i] row]);
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if(self.selItemsTable.selectedCells.count > 5)
        {
            [self showProgressHUDNotice:[delegate getStringForKey:@"SetLockItemOverfive" withTable:@""]
                               showTime:1.0];
        }
        else
        {
#if 0
            [self showProgressHUDWithMessage:nil];
            NSLog(@"chooseItem = %lu",(unsigned long)[self.selItemsTable.selectedCells count]);
           /* dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{*/
                for(int i = 0;i<self.selItemsTable.selectedCells.count;i++)
                {
                    
                    long int ChooseNumber = [[self.selItemsTable.selectedCells objectAtIndex:i] row];
                    NSLog(@"ChooseNumber = %lu",[[self.selItemsTable.selectedCells objectAtIndex:i] row]);
                    if(_curMpbMediaType == MpbMediaTypeVideo)
                    {
                        //Fpath = @"F:/VIDEO/";
                        NSString *IcatchFileFullName;
                        ICatchFile file = _fileTable.fileList.at(ChooseNumber);
                        IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:0;N:0;",file.getFilePath().c_str()];
                        
                        
                        
                        NSLog(@"LockName = %@",IcatchFileFullName);
                        
                        [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];
                        // cell.file = &file;
                        /*NvtRealPath = [Fpath stringByAppendingString:[[_FileListVideoProperty objectAtIndex:ChooseNumber] objectForKey:@"VideoName"]];
                         
                         [self httpAsynchronousRequest:@"4006" FullFileName:NvtRealPath parameter:@"1"];*/
                    }
                    else
                    {
                        //Fpath = @"F:/PHOTO/";
                        NSString *IcatchFileFullName;
                        ICatchFile file = _fileTable.fileList.at(ChooseNumber);
                        IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:0;N:0;",file.getFilePath().c_str()];
                        
                        NSLog(@"LockName = %@",IcatchFileFullName);
                        [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];

                    }
                    
                }
                /*dispatch_async(dispatch_get_main_queue(), ^{*/
                    //[self.tableView reloadData];
            
                    
                    long int lastrow = [[self tableView] numberOfRowsInSection:0];
                    for (int i = 0;i<lastrow;i++) {
                        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                        MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                        ICatchFile file = _fileTable.fileList.at(i);
                        NSLog(@"ttty%s",file.getFilePath().c_str());
                        //cell.file = &file;
                        [cell setLockIconHidden:YES];
                       // [cell setSelectedConfirmIconHidden:YES];
                        cell.tag = 0;
                    }
                    self.totalDownloadSize = 0;
                    [self resetCollectionViewData];
                    [self hideProgressHUD:YES];
                    //[self showProgressHUDNotice:@"Files UnLock" showTime:1.0];
                    //[self.selItemsTable.selectedCells removeAllObjects];
                    /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                                                                        object:@(nil)];*/
                    [self edit:nil];
               /* });*/
                
           /* });*/
#else
            NSString *IcatchFileFullName;
            for(NSIndexPath *indexPath in self.selItemsTable.selectedCells)
            {
                if([self.selItemsTable.selectedCells containsObject:indexPath])
                {
                    //NSIndexPath *ip = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
                    MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                    int index = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
                    ICatchFile file = _fileTable.fileList.at(index);
                    IcatchFileFullName = [NSString stringWithFormat:@"F:%s;V:0;N:0;",file.getFilePath().c_str()];

                    [_ctrl.propCtrl SetCustomLock:IcatchFileFullName];
                    [cell setLockIconHidden:YES];
                }
            }
            [self resetCollectionViewData];
            [self edit:nil];
            
#endif
        }
    }
}
-(void) DeleteProcess
{
    NSString *replaceString;
    AppLog(@"%s", __func__);
    /*if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }*/
    
    NSString *message = NSLocalizedString(@"DeleteMultiAsk", nil);
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)self.FileListChooseItem.count];
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)self.selItemsTable.count];
    }
    message = [message stringByReplacingOccurrencesOfString:@"%d"
                                                 withString:replaceString];
    
   /* if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self showPopoverFromBarButtonItem:(id)self
                                   message:message
                           fireButtonTitle:NSLocalizedString(@"SureDelete", @"")
                                  callback:@selector(deleteDetail:)];
    } else {
        [self showActionSheetFromBarButtonItem:(id)self
                                       message:message
                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                        destructiveButtonTitle:NSLocalizedString(@"SureDelete", @"")
                                           tag:ACTION_SHEET_DELETE_ACTIONS];
    }*/
    [self showActionSheetFromBarButtonItem:(id)self
                                   message:message
                         cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                    destructiveButtonTitle:NSLocalizedString(@"SureDelete", @"")
                                       tag:ACTION_SHEET_DELETE_ACTIONS];
}
-(void) DownloadProcess
{
    double freeDiscSpace;
    /*if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }*/
    
    if (!self.shareFiles) {
        self.shareFiles = [NSMutableArray array];
    } else {
        [self.shareFiles removeAllObjects];
    }
    
    if (!self.shareFileType) {
        self.shareFileType = [NSMutableArray array];
    } else {
        [self.shareFileType removeAllObjects];
    }
    
    NSInteger fileNum = 0;
    unsigned long long downloadSizeInKBytes = 0;
    NSString *confrimButtonTitle = nil;
    NSString *message = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        freeDiscSpace = [[self NvtDiskFreeSpace:@"3017"] doubleValue];
    }
    else
    {
        freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    }
    //double freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    
    if (_curMpbState == MpbStateEdit) {
        
        if (_totalDownloadSize < freeDiscSpace/2.0) {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                message = [self makeupDownloadMessageWithSize:_totalDownloadSize
                                                    andNumber:_FileListChooseItem.count];
            }
            else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
            {
                message = [self makeupDownloadMessageWithSize:_totalDownloadSize
                                                    andNumber:_selItemsTable.count];
            }
            confrimButtonTitle = NSLocalizedString(@"SureDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:_totalDownloadSize];
        }
        
    } else {
        fileNum += _fileTable.fileList.size();
        downloadSizeInKBytes += _fileTable.fileStorage;
        
        if (downloadSizeInKBytes < freeDiscSpace) {
            message = [self makeupDownloadMessageWithSize:downloadSizeInKBytes
                                                andNumber:fileNum];
            confrimButtonTitle = NSLocalizedString(@"AllDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:downloadSizeInKBytes];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    } else {
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    }
}
- (IBAction)CancelAction:(id)sender
{
    
}
- (IBAction)LockAction:(id)sender
{
    [self SelectEditAction:PBEditLockAction];
}
- (IBAction)UnLockAction:(id)sender
{
    [self SelectEditAction:PBEditUnLockAction];
}
- (IBAction)playback_fullscreenBT_clicked:(id)sender
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    else if(deviceOrientation == UIDeviceOrientationLandscapeRight)
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    else
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsfullscreenAnimateNotification"
                                                        object:@(nil)];
}
- (void) tableViewCellEnable {
    self.tableView.scrollEnabled = YES;
    self.tableView.allowsSelection = YES;
}

- (void) tableViewCellDisable {
    self.tableView.scrollEnabled = NO;
    self.tableView.allowsSelection = NO;
}
- (IBAction)play:(id)sender
{
   
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    self.ReadyPlay = NO;
    NSData *data = [[NSData alloc] init];
    if(_FileListChooseItem.count || self.selItemsTable.selectedCells)
    {
        [self tableViewCellDisable];
        /*[self showProgressHUDWithMessage:[self getStringForKey:@"Playing" withTable:@""]
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];*/
        [self showProgressHUDWithMessage:@""
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];
        [self performSelector:@selector(tableViewCellEnable) withObject:nil afterDelay:2.0];
        [self.progressHUD hide:YES afterDelay:1.0];
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            UIImage *image;
            NSString *Fpath;
            
            NSString *FileInformation;
            NSIndexPath *index;
            if(_curMpbMediaType == MpbMediaTypePhoto)
            {
                //Fpath = @"PHOTO/";
                _NvtThumbnilPath = [[[_FileListPhotoPropertySort objectAtIndex:_videoPlaybackIndex_section] objectAtIndex:_videoPlaybackIndex] objectForKey:@"PhotoFullName"];
                _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                     withString:@""];
                _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                     withString:@"/"];
                data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
 
                /*FileInformation = [self NVTGetFileInformationCmd:@"4005" FullFileName:_NvtThumbnilPath];
                _NvtFileWigth = [FileInformation substringWithRange:NSMakeRange(6, 9)];
                _NvtFileHeight = [FileInformation substringWithRange:NSMakeRange(19, 22)];*/
            }
            else
            {
               
                
                if(_paused && _played == NO)
                {
                    mpbSegmentViewController.NodePlayerFirstFramePic = NO;
                    self.paused = NO;
                    self.played = YES;
                    mpbSegmentViewController.NovatekPlayerStart;
                    mpbSegmentViewController.updatePlayerStatusSetTrue;
                    self.pbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                  target  :self
                                                                  selector:@selector(updateTimeInfo:)
                                                                  userInfo:nil
                                                                  repeats :YES];
                }
                else
                {
                    self.paused = YES;
                    self.played = NO;
                    mpbSegmentViewController.NovatekPlayerPause;
                    mpbSegmentViewController.updatePlayerStatusSetFalse;
                    [_pbTimer invalidate];
                }
            }
        }
        else
        {

             [self showProgressHUDWithMessage:NSLocalizedString(@"LOAD_SETTING_DATA", nil)];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
                if(dispatch_semaphore_wait(self.semaphore, time) != 0)  {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showProgressHUDNotice:@"Timeout!" showTime:2.0];
                    });
                } else {
                    dispatch_semaphore_signal(self.semaphore);
                    
                    if (_played && !_paused) {
                        // Pause
                        AppLog(@"call pause");
                        self.paused = [_ctrl.pbCtrl pause];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_paused) {
                                [_pbTimer invalidate];
                                /*Change Player ICON to PAUSE*/
                                
                                mpbSegmentViewController.updatePlayerStatus;
                            }
                            
                        });
                    } else {
                        self.PlaybackRun = YES;
                       
                        if (!_played) {
                            // Play
                            dispatch_async(_videoPlaybackQ, ^{
                                ICatchFile file = _fileTable.fileList.at(_videoPlaybackIndex);
                                
                                AppLog(@"call play");
                                self.totalSecs = [_ctrl.pbCtrl play:&file];
                                if (_totalSecs <= 0) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self showProgressHUDNotice:@"Failed to play" showTime:2.0];
                                    });
                                    return;
                                }
                                self.played = YES;
                                self.paused = NO;
                                self.exceptionHappen = NO;
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //_deleteButton.enabled = NO;
                                    //_actionButton.enabled = NO;
                                    mpbSegmentViewController.updatePlayerStatus;
                                    mpbSegmentViewController.SliderMaxValue = _totalSecs;
                                    mpbSegmentViewController.updateSliderMaxValue;
                                    
                                    
                                     [self addPlaybackObserver];
                                    
                                    self.pbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                                  target  :self
                                                                                  selector:@selector(updateTimeInfo:)
                                                                                  userInfo:nil
                                                                                  repeats :YES];
                                });
                                
                                if ([_ctrl.pbCtrl audioPlaybackStreamEnabled]) {
                                    dispatch_group_async(_playbackGroup, _audioQueue, ^{[self playAudio];});
                                } else {
                                    AppLog(@"Playback doesn't contains audio.");
                                }
                                if ([_ctrl.pbCtrl videoPlaybackStreamEnabled]) {
                                    dispatch_group_async(_playbackGroup, _videoQueue, ^{[self playVideo];});
                                } else {
                                    AppLog(@"Playback doesn't contains video.");
                                }
                                
                                dispatch_group_notify(_playbackGroup, _videoPlaybackQ, ^{
                                    
                                });
                            });
                            
                        } else {
                            // Resume
                            AppLog(@"call resume");
                            self.paused = ![_ctrl.pbCtrl resume];
                            
                            if (!_paused) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    //_deleteButton.enabled = NO;
                                    //_actionButton.enabled = NO;
                                    if (![_pbTimer isValid]) {
                                        self.pbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                                      target  :self
                                                                                      selector:@selector(updateTimeInfo:)
                                                                                      userInfo:nil
                                                                                      repeats :YES];
                                    }
                                    mpbSegmentViewController.updatePlayerStatus;
                                });
                            }
                        }
                    }
                    
                }
            });
        }
    }
}
- (void)requestDownloadPercent:(ICatchFile *)file
{
    AppLog(@"%s", __func__);
    if (!file) {
        AppLog(@"file is null");
        return;
    }
    
    ICatchFile *f = file;
    NSString *locatePath = nil;
    NSString *fileName = [NSString stringWithUTF8String:f->getFileName().c_str()];
    unsigned long long fileSize = f->getFileSize();
    locatePath = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileName];
    AppLog(@"locatePath: %@, %llu", locatePath, fileSize);
    
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    dispatch_async(self.downloadPercentQueue, ^{
        do {
            @autoreleasepool {
                /*if (_cancelDownload) break;
                if(![mpbSegmentViewController needDownloadFile:_downloadedFileNumber-1]) {
                    self.cancelDownload = YES;
                    [mpbSegmentViewController downloadFailed];
                }*/
                //self.downloadedPercent = [_ctrl.fileCtrl requestDownloadedPercent:f];
                _curDownloadSize =[_ctrl.fileCtrl getCurDownloadSize];
                self.downloadedPercent = [_ctrl.fileCtrl requestDownloadedPercent2:locatePath
                                                                          fileSize:fileSize];
                //AppLog(@"percent: %lu", (unsigned long)self.downloadedPercent);
                
                [NSThread sleepForTimeInterval:0.2];
            }
        } while (_downloadFileProcessing);
        
    });
}

- (NSArray *)downloadAllOfType:(WCFileType)type
{
    AppLog(@"%s", __func__);
    ICatchFile *file = NULL;
    vector<ICatchFile> fileList;
    NSInteger downloadedNum = 0;
    NSInteger downloadFailedCount = 0;
    
    switch (type) {
        case WCFileTypeImage:
            fileList = _fileTable.fileList;
            break;
            
        case WCFileTypeVideo:
            fileList = _fileTable.fileList;
            break;
            
        default:
            break;
    }
    
    if (![[SDK instance] openFileTransChannel]) {
        return nil;
    }
    
    for(vector<ICatchFile>::iterator it = fileList.begin();
        it != fileList.end();
        ++it) {
        if (_cancelDownload) {
            break;
        }
        
        file = &(*it);
        
        self.downloadFileProcessing = YES;
        self.downloadedPercent = 0; //Before the download clear downloadedPercent and increase downloadedFileNumber.
        self.downloadedFileNumber ++;
        [self requestDownloadPercent:file];
        //        if (![_ctrl.fileCtrl downloadFile:file]) {
        //            ++downloadFailedCount;
        //            self.downloadFileProcessing = NO;
        //            continue;
        //        }
        if (![[SDK instance] p_downloadFile2:file]) {
            ++downloadFailedCount;
            self.downloadFileProcessing = NO;
            continue;
        }
        self.downloadFileProcessing = NO;
        [NSThread sleepForTimeInterval:0.5];
        
        ++downloadedNum;
        [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:file->getFileName().c_str()]]]];
        [self.shareFileType addObject:[NSNumber numberWithInt:type]];
    }
    
    if (![[SDK instance] closeFileTransChannel]) {
        return nil;
    }
    
    return [NSArray arrayWithObjects:@(downloadedNum), @(downloadFailedCount), nil];
}

- (NSArray *)downloadAll
{
    AppLog(@"%s", __func__);
    NSInteger downloadedPhotoNum = 0, downloadedVideoNum = 0;
    NSInteger downloadFailedCount = 0;
    NSArray *resultArray = nil;
    
    if (_curMpbMediaType == MpbMediaTypePhoto) {
        resultArray = [self downloadAllOfType:WCFileTypeImage];
        downloadedPhotoNum = [resultArray[0] integerValue];
        downloadFailedCount += [resultArray[1] integerValue];
    } else {
        resultArray = [self downloadAllOfType:WCFileTypeVideo];
        downloadedVideoNum = [resultArray[0] integerValue];
        downloadFailedCount += [resultArray[1] integerValue];
    }
    
    [_ctrl.fileCtrl resetDownoladedTotalNumber];
    return [NSArray arrayWithObjects:@(downloadedPhotoNum), @(downloadedVideoNum), @(downloadFailedCount), nil];
}

- (void)downloadSelectedFile:(ICatchFile)f andFailedCount:(NSInteger *)downloadFailedCount andPhotoCount:(NSInteger *)downloadedPhotoNum andVideoCount:(NSInteger *)downloadedVideoNum
{
    do {
        self.downloadedFileNumber ++;
        [self requestDownloadPercent:&f];
        //        if (![_ctrl.fileCtrl downloadFile2:&f]) {
        //            ++(*downloadFailedCount);
        //            self.downloadFileProcessing = NO;
        //            continue;
        //        }
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        if (![[SDK instance] p_downloadFile2:&f]) {
            ++downloadFailedCount;
            dispatch_async(dispatch_get_main_queue(), ^{
                [mpbSegmentViewController downloadFailed];
                [mpbSegmentViewController downloadProcessingNumber:_downloadedFileNumber total:(unsigned long)_totalDownloadFileNumber];
            });
            self.downloadFileProcessing = NO;
            continue;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [mpbSegmentViewController downloadSuccess];
                [mpbSegmentViewController downloadProcessingNumber:_downloadedFileNumber total:(unsigned long)_totalDownloadFileNumber];
            });
        }
        
        self.downloadFileProcessing = NO;
        [NSThread sleepForTimeInterval:0.5];
        
        switch (f.getFileType()) {
            case TYPE_IMAGE:
                ++(*downloadedPhotoNum);
                [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                [self.shareFileType addObject:[NSNumber numberWithInt:TYPE_IMAGE]];
                break;
                
            case TYPE_VIDEO:
                ++(*downloadedVideoNum);
                [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                [self.shareFileType addObject:[NSNumber numberWithInt:TYPE_VIDEO]];
                break;
                
            case TYPE_TEXT:
            case TYPE_AUDIO:
            case TYPE_ALL:
            case TYPE_UNKNOWN:
            default:
                break;
        }
    } while (0);
}
- (void) clearTempDirectory {
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}
- (NSArray *)shareSelectedFiles
{
    AppLog(@"%s", __func__);
    NSInteger downloadedPhotoNum = 0, downloadedVideoNum = 0;
    NSInteger downloadFailedCount = 0;
    int selectedIndex = 0;
    
    ICatchFile f = NULL;
    NSString *fileName = nil;
    NSArray *tmpDirectoryContents = nil;
    
    NSString *filePath;
    if (![[SDK instance] openFileTransChannel]) {
        return nil;
    }
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
        //clear Temp Directory
        [self clearTempDirectory];
        _cancelDownload = NO;
        if(_cancelDownload) break;
        int index = [[[_FileListICatchPropertySort objectAtIndex:ip.section] objectAtIndex:ip.row] intValue];
        if(![mpbSegmentViewController needDownloadFile:selectedIndex]) {
            self.downloadedFileNumber ++;
            [mpbSegmentViewController downloadFailed];
            continue;
        }
        f = _fileTable.fileList.at(index);
        
        fileName = [NSString stringWithUTF8String:f.getFileName().c_str()];
        tmpDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
        
        self.downloadFileProcessing = YES;
        self.downloadedPercent = 0;//Before the download clear downloadedPercent and increase downloadedFileNumber.
        
        if (tmpDirectoryContents.count) {
            for (NSString *name in tmpDirectoryContents) {
                if ([name isEqualToString:fileName]) {
                    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                    NSString *filePath2;
                    long long tempSize = [DiskSpaceTool fileSizeAtPath:filePath];
                    long long fileSize = f.getFileSize();
                    
                    if (tempSize == fileSize) {
                        [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                        [self.shareFileType addObject:[NSNumber numberWithInt:f.getFileType()]];
                        [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
                        
                    } else {
                        [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
                    }
                    //從暫存複製到文件路徑
                    filePath = [NSString stringWithFormat:@"%@/%@",_NewPaths,name];
                    //if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    //    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                    //}
                    
                    filePath2 = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager copyItemAtPath:filePath2 toPath:filePath error:nil];
                    break;
                } else if ([name isEqualToString:[tmpDirectoryContents lastObject]]) {
                    [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
                    //從暫存複製到文件路徑
                    NSString *filePath;
                    NSString *filePath2;
                    filePath = [NSString stringWithFormat:@"%@/%@",_NewPaths,name];
                    //if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    //    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
                    //}
                    filePath2 = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]];
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager copyItemAtPath:filePath2 toPath:filePath error:nil];
                }
            }
        } else {
            [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
            //從暫存複製到文件路徑
            NSString *filePath;
            NSString *filePath2;
            filePath = [NSString stringWithFormat:@"%@/%@",_NewPaths,[NSString stringWithUTF8String:f.getFileName().c_str()]];
            //if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            //    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            //}
            filePath2 = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager copyItemAtPath:filePath2 toPath:filePath error:nil];
        }
        selectedIndex ++;
    }
    
    if (![[SDK instance] closeFileTransChannel]) {
        return nil;
    }
    
    [_ctrl.fileCtrl resetDownoladedTotalNumber];
    return [NSArray arrayWithObjects:@(downloadedPhotoNum), @(downloadedVideoNum), @(downloadFailedCount), nil];
}

- (int)videoAtPathIsCompatibleWithSavedPhotosAlbum:(int)saveNum {
    if (self.shareFileType != nil && self.shareFileType.count > 0) {
        ICatchFileType fileType = (ICatchFileType)[self.shareFileType.firstObject intValue];
        if (fileType != TYPE_VIDEO) {
            return 0;
        }
    } else {
        return 0;
    }
    
    int inCompatible = 0;
    int inCompatibleExceed = 0;
    NSString *path = nil;
    
    if (saveNum == self.shareFiles.count) {
        for (NSURL *temp in self.shareFiles) {
            path = temp.path;
            if (path != nil && !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                inCompatible ++;
            }
        }
    } else {
        NSURL *fileURL = nil;
        for (int i = 0; i < saveNum; i++) {
            fileURL = self.shareFiles[i];
            path = fileURL.path;
            if (path != nil && !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                inCompatible ++;
            }
        }
        
        for (int i = saveNum; i < self.shareFiles.count; i++) {
            fileURL = self.shareFiles[i];
            path = fileURL.path;
            if (path != nil && !UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                inCompatibleExceed ++;
            }
        }
    }
    
    if (inCompatible || inCompatibleExceed) {
        NSString *msg = [NSString stringWithFormat:@"There is %d specified video can not be saved to user’s Camera Roll album", inCompatible + inCompatibleExceed];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    
    return (saveNum - inCompatible);
}

- (void)showUIActivityViewController:(id)sender
{
    AppLog(@"%s", __func__);
   /* if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }*/
    
    uint shareNum = (uint)[self.shareFiles count];
    uint assetNum = (uint)[[SDK instance] retrieveCameraRollAssetsResult].count;
    
    if (shareNum) {
        UIActivityViewController *activityVc = [[UIActivityViewController alloc]initWithActivityItems:self.shareFiles applicationActivities:nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:activityVc animated:YES completion:nil];
        } else {
            // Create pop up
            UIPopoverController *activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityVc];
            // Show UIActivityViewController in popup
            [activityPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        
        activityVc.completionWithItemsHandler = ^(NSString *activityType,
                                                  BOOL completed,
                                                  NSArray *returnedItems,
                                                  NSError *error) {
            if (completed) {
                AppLog(@"We used activity type: %@", activityType);
                
                if ([activityType isEqualToString:@"com.apple.UIKit.activity.SaveToCameraRoll"]) {
                    dispatch_async(dispatch_queue_create("WifiCam.GCD.Queue.Share", DISPATCH_QUEUE_SERIAL), ^{
                        [self showProgressHUDWithMessage:NSLocalizedString(@"PhotoSavingWait", nil)];
                        
                        BOOL ret;
                        AppLog(@"shareNum: %d", shareNum);
                        if (shareNum <= 5) {
                            ret = [[SDK instance] savetoAlbum:@"iQViewer" andAlbumAssetNum:assetNum andShareNum:[self videoAtPathIsCompatibleWithSavedPhotosAlbum:shareNum]];
                        } else {
                            ret = [[SDK instance] savetoAlbum:@"iQViewer" andAlbumAssetNum:assetNum andShareNum:[self videoAtPathIsCompatibleWithSavedPhotosAlbum:5]];
                            
                            for (int i = 5; i < shareNum; i++) {
                                NSURL *fileURL = self.shareFiles[i];
                                if (fileURL == nil) {
                                    continue;
                                }
                                
                                ICatchFileType fileType = (ICatchFileType)[self.shareFileType[i] intValue];
                                if (fileType == TYPE_VIDEO) {
                                    NSString *path = fileURL.path;
                                    if (path && UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
                                        [[SDK instance] addNewAssetWithURL:fileURL toAlbum:@"iQViewer" andFileType:fileType];
                                        NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:path]];
                                    } else {
                                        AppLog(@"The specified video can not be saved to user’s Camera Roll album");
                                    }
                                } else {
                                    [[SDK instance] addNewAssetWithURL:fileURL toAlbum:@"iQViewer" andFileType:fileType];
                                }
                            }
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraDownloadCompleteNotification"
                                                                                object:[NSNumber numberWithInt:ret]];
                            
                            if (ret) {
                                [self showProgressHUDCompleteMessage:NSLocalizedString(@"SavePhotoToAlbum", nil)];
                            } else {
                                [self showProgressHUDCompleteMessage:NSLocalizedString(@"SaveError", nil)];
                            }
                            
                            [self.shareFiles removeAllObjects];
                            [self.shareFileType removeAllObjects];
                        });
                    });
                }
            } else {
                AppLog(@"We didn't want to share anything after all.");
            }
            
            if (error) {
                AppLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
            }
        };
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"没有选择要分享的图片或视频 !"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                                  otherButtonTitles:nil];
        [alertView show];
        [self.shareFiles removeAllObjects];
        [self.shareFileType removeAllObjects];
    }
}

- (void)downloadDetail:(id)sender
{
    AppLog(@"%s", __func__);
   /* if ([sender isKindOfClass:[UIButton self]]) {
        [_popController dismissPopoverAnimated:YES];
    }*/
    
    self.cancelDownload = NO;
    
    // Prepare
    if (_curMpbState == MpbStateNor) {
        [self.selItemsTable addObserver:self forKeyPath:@"count" options:0x0 context:nil];
        observerNo++;
        self.totalDownloadFileNumber = _totalCount;
    } else {
        self.totalDownloadFileNumber = self.selItemsTable.selectedCells.count;
    }

    self.downloadedFileNumber = 0;
    self.downloadedPercent = 0;
    [self addObserver:self forKeyPath:@"downloadedFileNumber" options:0x0 context:nil];
    [self addObserver:self forKeyPath:@"downloadedPercent" options:NSKeyValueObservingOptionNew context:nil];
    NSUInteger handledNum = MIN(_downloadedFileNumber, _totalDownloadFileNumber);
    NSString *msg = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)handledNum, (unsigned long)_totalDownloadFileNumber];
    
    // Show processing notice
    /*if (!handledNum) {
        [self showProgressHUDWithMessage:@"Please wait ..."
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
    } else {
        [self showProgressHUDWithMessage:msg
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
    }*/
    ICatchFile f = NULL;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    [mpbSegmentViewController initDownloadManager];
    for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
        int index = [[[_FileListICatchPropertySort objectAtIndex:ip.section] objectAtIndex:ip.row] intValue];
        f = _fileTable.fileList.at(index);
        [mpbSegmentViewController addDownloadManager:[NSString stringWithUTF8String:f.getFileName().c_str()] fileSize:(float)f.getFileSize()/1024/1024];
    }
    [mpbSegmentViewController updateDownloadCell];
    [mpbSegmentViewController downloadProcessingNumber:1 total:(unsigned long)_totalDownloadFileNumber];
    
    
    // Just in case, _selItemsTable.selectedCellsn wouldn't be destoried after app enter background
    [_ctrl.fileCtrl tempStoreDataForBackgroundDownload:self.selItemsTable.selectedCells];
    dispatch_async(self.downloadQueue, ^{
        NSInteger downloadedPhotoNum = 0, downloadedVideoNum = 0;
        NSInteger downloadFailedCount = 0;
        UIBackgroundTaskIdentifier downloadTask;
        NSArray *resultArray = nil;
        
        [_ctrl.fileCtrl resetBusyToggle:YES];
        // -- Request more time to excute task within background
        UIApplication  *app = [UIApplication sharedApplication];
        downloadTask = [app beginBackgroundTaskWithExpirationHandler: ^{
            
            AppLog(@"-->Expiration");
            NSArray *oldNotifications = [app scheduledLocalNotifications];
            // Clear out the old notification before scheduling a new one
            if ([oldNotifications count] > 5) {
                [app cancelAllLocalNotifications];
            }
            
            NSString *noticeMessage = [NSString stringWithFormat:@"[Progress: %lu/%lu] - App is about to exit. Please bring it to foreground to continue dowloading.", (unsigned long)handledNum, (unsigned long)_totalDownloadFileNumber];
            [_ctrl.comCtrl scheduleLocalNotice:noticeMessage];
        }];
        
        
        // ---------- Downloading
        if (_curMpbState == MpbStateNor) {
            self.curMpbState = MpbStateEdit;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraUpdatePhotoGalleryEditStateNotification" object:@(self.curMpbState)];
            resultArray = [self downloadAll];
        } else {
            //            resultArray = [self downloadSelectedFiles];
            resultArray = [self shareSelectedFiles];
        }
        downloadedPhotoNum = [resultArray[0] integerValue];
        downloadedVideoNum = [resultArray[1] integerValue];
        downloadFailedCount = [resultArray[2] integerValue];
        self.downloadFailedCount = downloadFailedCount;
        // -----------
        
        
        // Download is completed, notice & update GUI
        self.totalDownloadSize = 0;
        // Post local notification
        if (app.applicationState == UIApplicationStateBackground) {
            NSString *noticeMessage = NSLocalizedString(@"SavePhotoToAlbum", @"Download complete.");
            [_ctrl.comCtrl scheduleLocalNotice:noticeMessage];
        }
        // HUD notification
        dispatch_async(dispatch_get_main_queue(), ^{
            [self removeObserver:self forKeyPath:@"downloadedFileNumber"];
            [self removeObserver:self forKeyPath:@"downloadedPercent"];
            
            //[self showUIActivityViewController:self.actionButton];
            // Clear
            for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
                MpbTableViewCell *cell = (MpbTableViewCell *)[self.tableView cellForRowAtIndexPath:ip];
                [cell setSelectedConfirmIconHidden:YES];
                cell.tag = 0;
            }
            [self.selItemsTable.selectedCells removeAllObjects];
            self.selItemsTable.count = 0;
            [self postButtonStateChangeNotification:NO];
            [self.tableView reloadData];
            
            if (!_cancelDownload) {
                NSString *message = nil;
                if (downloadFailedCount > 0) {
                    NSString *message = NSLocalizedString(@"DownloadSelectedError", nil);
                    message = [message stringByReplacingOccurrencesOfString:@"%d" withString:[NSString stringWithFormat:@"%ld", (long)downloadFailedCount]];
                    [self showProgressHUDNotice:message showTime:0.5];
                    
                } else {
                    if (self.downloadedFileNumber) {
                        message = NSLocalizedString(@"DownloadDoneMessage", nil);
                        NSString *photoNum = [NSString stringWithFormat:@"%ld", (long)downloadedPhotoNum];
                        NSString *videoNum = [NSString stringWithFormat:@"%ld", (long)downloadedVideoNum];
                        message = [message stringByReplacingOccurrencesOfString:@"%1"
                                                                     withString:photoNum];
                        message = [message stringByReplacingOccurrencesOfString:@"%2"
                                                                     withString:videoNum];
                    }
                    [self showProgressHUDCompleteMessage:message];
                }
                
            } else {
                [self hideProgressHUD:YES];
            }
            MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
            [mpbSegmentViewController downloadCompletedNotice];
        });
        
        [_ctrl.fileCtrl resetBusyToggle:NO];
        [[UIApplication sharedApplication] endBackgroundTask:downloadTask];
    });
}

-(NSString *)translateSize:(unsigned long long)sizeInKB
{
    NSString *humanDownloadFileSize = nil;
    double temp = (double)sizeInKB/1024; // MB
    if (temp > 1024) {
        temp /= 1024;
        humanDownloadFileSize = [NSString stringWithFormat:@"%.2fGB", temp];
    } else {
        humanDownloadFileSize = [NSString stringWithFormat:@"%.2fMB", temp];
    }
    return humanDownloadFileSize;
}

-(NSString *)makeupDownloadMessageWithSize:(unsigned long long)sizeInKB
                                 andNumber:(NSInteger)num
{
    AppLog(@"%s", __func__);
    
    NSString *message = nil;
    NSString *humanDownloadFileSize = [self translateSize:sizeInKB];
    unsigned long long downloadTimeInHours = (sizeInKB/1024)/3600;
    unsigned long long downloadTimeInMinutes = (sizeInKB/1024)/60 - downloadTimeInHours*60;
    unsigned long long downloadTimeInSeconds = sizeInKB/1024 - downloadTimeInHours*3600 - downloadTimeInMinutes*60;
    AppLog(@"downloadTimeInHours: %llu, downloadTimeInMinutes: %llu, downloadTimeInSeconds: %llu",
           downloadTimeInHours, downloadTimeInMinutes, downloadTimeInSeconds);
    
    if (downloadTimeInHours > 0) {
        message = NSLocalizedString(@"DownloadConfirmMessage3", nil);
        message = [message stringByReplacingOccurrencesOfString:@"%1"
                                                     withString:[NSString stringWithFormat:@"%ld", (long)num]];
        message = [message stringByReplacingOccurrencesOfString:@"%2"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInHours]];
        message = [message stringByReplacingOccurrencesOfString:@"%3"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInMinutes]];
        message = [message stringByReplacingOccurrencesOfString:@"%4"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInSeconds]];
    } else if (downloadTimeInMinutes > 0) {
        message = NSLocalizedString(@"DownloadConfirmMessage2", nil);
        message = [message stringByReplacingOccurrencesOfString:@"%1"
                                                     withString:[NSString stringWithFormat:@"%ld", (long)num]];
        message = [message stringByReplacingOccurrencesOfString:@"%2"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInMinutes]];
        message = [message stringByReplacingOccurrencesOfString:@"%3"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInSeconds]];
    } else {
        message = NSLocalizedString(@"DownloadConfirmMessage1", nil);
        message = [message stringByReplacingOccurrencesOfString:@"%1"
                                                     withString:[NSString stringWithFormat:@"%ld", (long)num]];
        message = [message stringByReplacingOccurrencesOfString:@"%2"
                                                     withString:[NSString stringWithFormat:@"%llu", downloadTimeInSeconds]];
    }
    message = [message stringByAppendingString:[NSString stringWithFormat:@"\n%@", humanDownloadFileSize]];
    return message;
}

-(NSString *)makeupNoDownloadMessageWithSize:(unsigned long long)sizeInKB
{
    AppLog(@"%s", __func__);
    NSString *message = nil;
    NSString *humanDownloadFileSize = [_ctrl.comCtrl translateSize:sizeInKB];
    double freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    NSString *leftSpace = [_ctrl.comCtrl translateSize:freeDiscSpace];
    message = [NSString stringWithFormat:@"%@\n Download:%@, Free:%@", NSLocalizedString(@"NotEnoughSpaceError", nil), humanDownloadFileSize, leftSpace];
    message = [message stringByAppendingString:@"\n Needs double free space"];
    return message;
}

-(void)_showDownloadConfirm:(NSString *)message
                      title:(NSString *)confrimButtonTitle
                     dBytes:(unsigned long long)downloadSizeInKBytes
                     fSpace:(double)freeDiscSpace {
    AppLog(@"%s", __func__);
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if (downloadSizeInKBytes < freeDiscSpace) {
            [self showPopoverFromBarButtonItem:self.actionButton
                                       message:message
                               fireButtonTitle:confrimButtonTitle
                                      callback:@selector(downloadDetail:)];
        } else {
            [self showPopoverFromBarButtonItem:self.actionButton
                                       message:message
                               fireButtonTitle:nil
                                      callback:nil];
        }
        
    } else {
        [self showActionSheetFromBarButtonItem:self.actionButton
                                       message:message
                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                        destructiveButtonTitle:confrimButtonTitle
                                           tag:ACTION_SHEET_DOWNLOAD_ACTIONS];
    }
}

-(void)showShareConfirm
{
    [self SelectEditAction:PBEditDownloadAction];
    AppLog(@"%s", __func__);
#if 0
    
    double freeDiscSpace;
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    if (!self.shareFiles) {
        self.shareFiles = [NSMutableArray array];
    } else {
        [self.shareFiles removeAllObjects];
    }
    
    if (!self.shareFileType) {
        self.shareFileType = [NSMutableArray array];
    } else {
        [self.shareFileType removeAllObjects];
    }
    
    NSInteger fileNum = 0;
    unsigned long long downloadSizeInKBytes = 0;
    NSString *confrimButtonTitle = nil;
    NSString *message = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        freeDiscSpace = [[self NvtDiskFreeSpace:@"3017"] doubleValue];
    }
    else
    {
        freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    }
    //double freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    
    if (_curMpbState == MpbStateEdit) {
        
        if (_totalDownloadSize < freeDiscSpace/2.0) {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                message = [self makeupDownloadMessageWithSize:_totalDownloadSize
                                                    andNumber:_FileListChooseItem.count];
            }
            else
            {
                message = [self makeupDownloadMessageWithSize:_totalDownloadSize
                                                    andNumber:_selItemsTable.count];
            }
            confrimButtonTitle = NSLocalizedString(@"SureDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:_totalDownloadSize];
        }
        
    } else {
        fileNum += _fileTable.fileList.size();
        downloadSizeInKBytes += _fileTable.fileStorage;
        
        if (downloadSizeInKBytes < freeDiscSpace) {
            message = [self makeupDownloadMessageWithSize:downloadSizeInKBytes
                                                andNumber:fileNum];
            confrimButtonTitle = NSLocalizedString(@"AllDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:downloadSizeInKBytes];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    } else {
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    }
#endif
}

- (void)deleteDetail:(id)sender
{
    AppLog(@"%s", __func__);

    __block int failedCount = 0;
    __block NSString *NvtRealPath;
   /* if ([sender isKindOfClass:[UIButton self]]) {
        [_popController dismissPopoverAnimated:YES];
    }*/
    
    self.run = NO;
    [self tableViewCellDisable];
    [self showProgressHUDWithMessage:NSLocalizedString(@"Deleting", nil)
                      detailsMessage:nil
                                mode:MBProgressHUDModeIndeterminate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachedKey = nil;
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        dispatch_semaphore_wait(self.mpbSemaphore, time);
        
        // Real delete icatch file & remove NSCache item
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            /*NSSortDescriptor *sort;
            sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [_FileListChooseItem sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];*/
            
            for(int i = 0;i<_FileListChooseItem.count;i++)
            {
                //long int ChooseNumber = [[_FileListChooseItem objectAtIndex:i] row];
                NSIndexPath *index = [_FileListChooseItem objectAtIndex:i];
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    //Fpath = @"PHOTO/";
                    NvtRealPath = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoFullName"];
                    NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                         withString:@""];
                    NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                         withString:@"/"];
                    [self NvtSendFileDelete:@"4003" FullFileName:NvtRealPath];
                }
                else
                {
                    //Fpath = @"VIDEO/";
                    NvtRealPath = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoFullName"];
                    NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                         withString:@""];
                    NvtRealPath = [NvtRealPath stringByReplacingOccurrencesOfString:@"\\"
                                                                         withString:@"/"];
                    [self NvtSendFileDelete:@"4003" FullFileName:NvtRealPath];
                }
            }
            
            
            dispatch_semaphore_signal(self.mpbSemaphore);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{

                [self NvtdataInit];
                [self NVTSendHttpCmd:@"3001" Par2:@"0"];
                [NSThread sleepForTimeInterval:1.0];
                [self NVTSendHttpCmd:@"3001" Par2:@"2"];
                //[NSThread sleepForTimeInterval:1.0];
                [self NVTGetHttpCmd:@"3015"];
                [self sortList];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self resetCollectionViewData];
                    [self postButtonStateChangeNotification:NO];
                    self.run = YES;
                    [self.tableView reloadData];
                    [self setCellFileNameSize];
                    [self.progressHUD hide:YES];
                    [self tableViewCellEnable];
                    /*NSString *noticeMessage = nil;
                
                    if (failedCount > 0) {
                        noticeMessage = NSLocalizedString(@"DeleteMultiError", nil);
                        NSString *failedCountString = [NSString stringWithFormat:@"%d", failedCount];
                        noticeMessage = [noticeMessage stringByReplacingOccurrencesOfString:@"%d" withString:failedCountString];
                    } else {
                        noticeMessage = NSLocalizedString(@"DeleteDoneMessage", nil);
                    }
                    [self showProgressHUDCompleteMessage:noticeMessage];*/
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                                                                        object:@(nil)];
            });
          });
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
                int index = [[[_FileListICatchPropertySort objectAtIndex:ip.section] objectAtIndex:ip.row] intValue];
                ICatchFile f = _fileTable.fileList.at(index);

                if ([_ctrl.fileCtrl deleteFile:&f] == NO) {
                    ++failedCount;
                }
                cachedKey = [NSString stringWithFormat:@"ID%d", f.getFileHandle()];
                
                [self.mpbCache removeObjectForKey:cachedKey];
            }
            
            // Update the UICollectionView's data source
            [self resetCollectionViewData];
            dispatch_semaphore_signal(self.mpbSemaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedCount != self.selItemsTable.selectedCells.count) {
                    [self.selItemsTable.selectedCells removeAllObjects];
                    [self postButtonStateChangeNotification:NO];
                    self.run = YES;
                    [self.tableView reloadData];
                    [self setCellFileNameSize];
                }
                [self tableViewCellEnable];
                [self.progressHUD hide:YES];
                /*NSString *noticeMessage = nil;
                
                if (failedCount > 0) {
                    noticeMessage = NSLocalizedString(@"DeleteMultiError", nil);
                    NSString *failedCountString = [NSString stringWithFormat:@"%d", failedCount];
                    noticeMessage = [noticeMessage stringByReplacingOccurrencesOfString:@"%d" withString:failedCountString];
                } else {
                    noticeMessage = NSLocalizedString(@"DeleteDoneMessage", nil);
                }
                [self showProgressHUDCompleteMessage:noticeMessage];*/
                /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                                                                    object:@(nil)];*/
                [self edit:nil];
    //            self.selItemsTable.count = 0;
            });
         }
    });
    
}

- (void)delete:(id)sender
{
 [self SelectEditAction:PBEditDeleteAction];
#if 0
    NSString *replaceString;
    AppLog(@"%s", __func__);
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    NSString *message = NSLocalizedString(@"DeleteMultiAsk", nil);
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)self.FileListChooseItem.count];
    }
    else
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)self.selItemsTable.count];
    }
    message = [message stringByReplacingOccurrencesOfString:@"%d"
                                            withString:replaceString];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self showPopoverFromBarButtonItem:sender
                                   message:message
                           fireButtonTitle:NSLocalizedString(@"SureDelete", @"")
                                  callback:@selector(deleteDetail:)];
    } else {
        [self showActionSheetFromBarButtonItem:sender
                                       message:message
                             cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                        destructiveButtonTitle:NSLocalizedString(@"SureDelete", @"")
                                           tag:ACTION_SHEET_DELETE_ACTIONS];
    }
#endif
}

-(void)prepareForAction
{
    AppLog(@"%s", __func__);
    NSInteger selectedPhotoNum = 0;
    NSInteger selectedVideoNum = 0;
    
    for (NSIndexPath *ip in self.selItemsTable.selectedCells) {
        int index = [[[_FileListICatchPropertySort objectAtIndex:ip.section] objectAtIndex:ip.row] intValue];
        ICatchFile f = _fileTable.fileList.at(index);

        switch (f.getFileType()) {
            case TYPE_IMAGE:
                ++selectedPhotoNum;
                break;
                
            case TYPE_VIDEO:
                ++selectedVideoNum;
                break;
            default:
                break;
        }
    }
    AppLog(@"VIDEO: %ld, IMAGE: %ld", (long)selectedVideoNum, (long)selectedPhotoNum);
    
    if ((selectedPhotoNum > 0) && (selectedVideoNum > 0)) {
        NSString  *demoTitle = NSLocalizedString(@"SelectedItems", nil);
        NSString  *items = [NSString stringWithFormat:@"%ld", (long)(selectedPhotoNum + selectedVideoNum)];
        self.title = [demoTitle stringByReplacingOccurrencesOfString:@"%d" withString:items];
        
    } else if (selectedPhotoNum > 0) {
        if (selectedPhotoNum == 1) {
            self.title = NSLocalizedString(@"SelectedOnePhoto", nil);
        } else {
            NSString  *demoTitle = NSLocalizedString(@"SelectedPhotos", nil);
            NSString  *items = [NSString stringWithFormat:@"%ld", (long)selectedPhotoNum];
            self.title = [demoTitle stringByReplacingOccurrencesOfString:@"%d" withString:items];
        }
    } else if (selectedVideoNum > 0) {
        if (selectedVideoNum == 1) {
            self.title = NSLocalizedString(@"SelectedOneVideo", nil);
        } else {
            NSString  *demoTitle = NSLocalizedString(@"SelectedVideos", nil);
            NSString  *items = [NSString stringWithFormat:@"%ld", (long)selectedVideoNum];
            self.title = [demoTitle stringByReplacingOccurrencesOfString:@"%d" withString:items];
        }
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath
        ofObject              :(id)object
        change                :(NSDictionary *)change
        context               :(void *)context
{
    AppLog(@"%s", __func__);
    if ([keyPath isEqualToString:@"count"]) {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            if (self.selItemsTable.count > 0) {
                [self prepareForAction];
            } else {
            }
        }
        else
        {
            if (self.selItemsTable.count > 0) {
                [self prepareForAction];
            } else {
            }
        }
    } else if ([keyPath isEqualToString:@"downloadedFileNumber"]) {
        NSUInteger handledNum = MIN(_downloadedFileNumber, _totalDownloadFileNumber);
        NSString *msg = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)handledNum, (unsigned long)_totalDownloadFileNumber];
        //[self updateProgressHUDWithMessage:msg detailsMessage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
            if(_downloadedFileNumber-1 < 0)
                [mpbSegmentViewController downloadProcessingNumber:0 total:(unsigned long)_totalDownloadFileNumber];
            else
                [mpbSegmentViewController downloadProcessingNumber:_downloadedFileNumber-1 total:(unsigned long)_totalDownloadFileNumber];
        });
        
    } else if([keyPath isEqualToString:@"downloadedPercent"]) {
        NSString *msg = [NSString stringWithFormat:@"%lu%%", (unsigned long)_downloadedPercent];
        if (self.downloadedFileNumber) {
            //[self updateProgressHUDWithMessage:nil detailsMessage:msg];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(_downloadedPercent == 100 || _downloadedPercent == 0)
                    return;
                MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
                //NSLog(@"FileNumberBBBBBBBRR = %d",FileNumber);
                [mpbSegmentViewController setDownloadProgress:_downloadedFileNumber-1 Progress:_downloadedPercent ProgressStorage:(float)_curDownloadSize/1024/1024];
                //[mpbSegmentViewController size];//_curDownloadSize
            });
        }
    }
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popController = nil;
}
/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 if(_curMpbMediaType == MpbMediaTypePhoto)
 {
 NSLog(@"dataaaaAAAA = %d",[[[_FileListPhotoPropertySort objectAtIndex:_FileListPhotoPropertySort.count-1] objectForKey:@"section"] intValue]);
 return 1;//[[[_FileListPhotoPropertySort objectAtIndex:_FileListPhotoPropertySort.count-1] objectForKey:@"section"] intValue];
 }
 else
 {
 NSLog(@"dataaaaAAAA = %d",[[[_FileListVideoPropertySort objectAtIndex:_FileListVideoPropertySort.count-1] objectForKey:@"section"] intValue]);
 return 1;//[[[_FileListVideoPropertySort objectAtIndex:_FileListVideoPropertySort.count-1] objectForKey:@"section"] intValue];
 }
 }
 
 - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
 {
 if(_curMpbMediaType == MpbMediaTypePhoto)
 {
 //NSLog(@"dataaaaAAAAB = %d",[[[_FileListPhotoPropertySort objectAtIndex:section] objectForKey:@"section"] intValue]);
 return _FileListPhotoProperty.count;//[[[_FileListPhotoPropertySort objectAtIndex:section] objectForKey:@"section"] intValue];
 //return _FileListPhotoProperty.count;
 }
 else
 {
 //NSLog(@"dataaaaAAAAB = %d",[[[_FileListVideoPropertySort objectAtIndex:section] objectForKey:@"section"] intValue]);
 return _FileListVideoProperty.count;//[[[_FileListVideoPropertySort objectAtIndex:section] objectForKey:@"section"] intValue];
 //return _FileListVideoProperty.count;
 }
 }
 else
 {
 return _fileTable.fileList.size();
 
 }
 }
 /*-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
 {
 if(_curMpbMediaType == MpbMediaTypePhoto) {
 return @"2019";
 } else {
 
 return @"2019";
 }
 }*/
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
        if(_curMpbMediaType == MpbMediaTypePhoto)
        {
            if(_FileListPhotoPropertySort.count > 0) {
                return [_FileListPhotoPropertySort count];
            } else {
                return 1;
            }
        }
        else
        {
            if(_FileListVideoPropertySort.count > 0) {
                return [_FileListVideoPropertySort count];
            } else {
                return 1;
            }
        }
    } else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial) {
        if(_FileListICatchPropertySort.count > 0)
            return [_FileListICatchPropertySort count];
        else
            return 1;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(_curMpbMediaType == MpbMediaTypePhoto)
        {
            if([_FileListPhotoPropertySort count]>0)
                return [[_FileListPhotoPropertySort objectAtIndex:section] count];
            else
                return 0;
        }
        else
        {
            if([_FileListVideoPropertySort count]>0) {
                return [[_FileListVideoPropertySort objectAtIndex:section] count];
            }
            else
                return 0;
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial) {
        if(_FileListICatchPropertySort.count > 0)
            return [[_FileListICatchPropertySort objectAtIndex:section] count];
        else
            return 0;
    } else {
        return 0;
    }
    /*if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(_curMpbMediaType == MpbMediaTypePhoto)
        {
            return _FileListPhotoProperty.count;
        }
        else
        {
            return _FileListVideoProperty.count;
        }
    }
    else
    {
        return _fileTable.fileList.size();

    }*/
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDate *date;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
        if(_curMpbMediaType == MpbMediaTypePhoto) {
            if(_FileListPhotoPropertySort != nil && _FileListPhotoPropertySort.count > 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                
                date=[dateFormatter dateFromString:[[[_FileListPhotoPropertySort objectAtIndex:section] objectAtIndex:0] objectForKey:@"PhotoTime"]];
                
                
                if([dateFormat  isEqual: @"DDMMYYYY"]) {
                    [dateFormatter setDateFormat:@"ddMMyyyy"];
                } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                    [dateFormatter setDateFormat:@"MMddyyyy"];
                } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                }
                
                
                return [dateFormatter stringFromDate:date];
            } else {
                return nil;
            }
        } else {
            if(_FileListVideoPropertySort != nil && _FileListVideoPropertySort.count > 0) {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                
                date=[dateFormatter dateFromString:[[[_FileListVideoPropertySort objectAtIndex:section] objectAtIndex:0] objectForKey:@"VideoTime"]];
                
                
                if([dateFormat  isEqual: @"DDMMYYYY"]) {
                    [dateFormatter setDateFormat:@"ddMMyyyy"];
                } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                    [dateFormatter setDateFormat:@"MMddyyyy"];
                } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                    [dateFormatter setDateFormat:@"yyyyMMdd"];
                }
                
                
                return [dateFormatter stringFromDate:date];
            } else {
                return nil;
            }
        }
    } else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial) {
        if(_fileTable.fileList.size() > 0) {
            int index = [[[_FileListICatchPropertySort objectAtIndex:section] objectAtIndex:0] intValue];
            NSString *str;
            str = [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String:_fileTable.fileList.at(index).getFileDate().c_str()]];
            //NSLog(@"ASASASASASA  =  %@  AA  %@  PP  %@",[str substringWithRange:NSMakeRange(0, 4)],[str substringWithRange:NSMakeRange(4, 2)],[str substringWithRange:NSMakeRange(6, 2)]);
            //NSLog(@"ASASASASASARR  =  %@  AA  %@  PP  %@",[str substringWithRange:NSMakeRange(9, 2)],[str substringWithRange:NSMakeRange(11, 2)],[str substringWithRange:NSMakeRange(13, 2)]);
            str = [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",[str substringWithRange:NSMakeRange(0, 4)],[str substringWithRange:NSMakeRange(4, 2)],[str substringWithRange:NSMakeRange(6, 2)],[str substringWithRange:NSMakeRange(9, 2)],[str substringWithRange:NSMakeRange(11, 2)],[str substringWithRange:NSMakeRange(13, 2)]];
            //NSLog(@"ASASASASASATime    %@",str);
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
            
            date=[dateFormatter dateFromString:str];
            if([dateFormat  isEqual: @"DDMMYYYY"]) {
                [dateFormatter setDateFormat:@"ddMMyyyy"];
            } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                [dateFormatter setDateFormat:@"MMddyyyy"];
            } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                [dateFormatter setDateFormat:@"yyyyMMdd"];
            }
            
            return [dateFormatter stringFromDate:date];
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle=[self tableView:tableView titleForHeaderInSection:section];
    
    
    // Create header view and add label as a subview
    
    
    UILabel *label=[[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, self.tableView.frame.size.width, self.tableView.sectionHeaderHeight);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
    
    label.font = [UIFont fontWithName:@"Frutiger LT 45 Light" size:18];
    //label.transform = CGAffineTransformMake(1, 0, tanf(-15 * (CGFloat)M_PI / 180), 1, 0, 0);
    
    label.adjustsFontSizeToFitWidth = YES;
    if (sectionTitle!=nil) {
        label.text = sectionTitle;
    }
    
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, self.tableView.sectionHeaderHeight)];
    
    
    //[sectionView setBackgroundColor:[UIColor whiteColor]];
    [sectionView setBackgroundColor:[UIColor clearColor]];
    
    [sectionView addSubview:label];
    return sectionView;
    
}
- (void)setCellTag:(MpbTableViewCell *)cell
         indexPath:(NSIndexPath *)indexPath {
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        /*if ([_FileListChooseItem containsObject:indexPath]) {
           [cell setClickIconHidden:NO];
            cell.tag = 1;
        } else {
            [cell setClickIconHidden:YES];
            cell.tag = 0;
        }*/
    }
    else
    {
        if ([self.selItemsTable.selectedCells containsObject:indexPath]) {
            [cell setSelectedConfirmIconHidden:NO];
            cell.tag = 1;
        } else {
            [cell setSelectedConfirmIconHidden:YES];
            cell.tag = 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MpbTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyTableViewCellID" forIndexPath:indexPath];
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    UIFont *font;
    __block NSData *data = [[NSData alloc] init];
    __block NSString *Fpath;
    __block UIImage *image;
    
    [cell setCellBGHidden:YES];

    if (cell == nil) {
        cell = [[MpbTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyTableViewCellID"];
    }
    else
    {
        [cell getCellLabel:0].adjustsFontSizeToFitWidth = YES;
        font = [mpbSegmentViewController adjFontSize:[cell getCellLabel:0]];//取最長的size
        [cell getCellLabel:0].font = [font fontWithSize:curFileNameSize];
        [cell getCellLabel:1].font = [font fontWithSize:(curFileNameSize-5.0)];
        [cell getCellLabel:2].font = [font fontWithSize:(curFileNameSize-5.0)];
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    ICatchFile file = nil;
                    NSDate *date;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    
                    date=[dateFormatter dateFromString:[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoTime"]];
                    
                    
                    if([dateFormat  isEqual: @"DDMMYYYY"]) {
                        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
                    } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    }
                    [dateFormatter stringFromDate:date];
                   
                    cell.SSID = _SSID;
                    cell.NvtName = [[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoName"];
                    cell.NvtDate = [dateFormatter stringFromDate:date];//[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoTime"];
                    cell.NvtSize = [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoSize"] intValue];
                    cell.NvtType = 1;
                    //cell.file = &file;
                    [cell setFile:&file DateFormat:dateFormat];
                    Fpath = @"PHOTO/";
                    int lock = [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoAttr"] intValue] & 1;
                    if(lock)
                    {
                        [cell setLockIconHidden:NO];
                    }
                    else
                    {
                        [cell setLockIconHidden:YES];
                    }
                    
                }
                else
                {
                    ICatchFile file = nil;
                    NSDate *date;
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    
                    date=[dateFormatter dateFromString:[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoTime"]];
                    
                    
                    if([dateFormat  isEqual: @"DDMMYYYY"]) {
                        [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
                    } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                        [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
                    } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    }
                    [dateFormatter stringFromDate:date];
                    
                    
                    cell.SSID = _SSID;
                    cell.NvtName = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoName"];
                    cell.NvtDate = [dateFormatter stringFromDate:date];//[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoTime"];
                    cell.NvtSize = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoSize"] intValue];
                    cell.NvtType = 2;
                    //cell.file = &file;
                    [cell setFile:&file DateFormat:dateFormat];
                    int lock = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoAttr"] intValue] & 1;
                    if(lock)
                    {
                        [cell setLockIconHidden:NO];
                        Fpath = @"PROTECTED/";
                    }
                    else
                    {
                        [cell setLockIconHidden:YES];
                        Fpath = @"VIDEO/";
                    }
                    
                    
                }
                if(_curMpbState == MpbStateNor)
                {
                    [cell setCellBGHidden:YES];
                    //[cell setClickOffIcon];
                    //[cell setClickIconHidden:YES];
                }
                else
                {
                    //[cell setClickIconHidden:NO];
                    if([_FileListChooseItem containsObject:indexPath])
                    {
                        UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
            
                        view_bg.backgroundColor = [UIColor colorWithRed:76/255.0 green:29/255.0 blue:31/255.0 alpha:1];
            
                        cell.selectedBackgroundView = view_bg;
                        [cell setCellBGHidden:NO];
                        //[cell setClickOnIcon];
                    }
                    else
                    {
                        //[cell setClickOffIcon];
                    }
                }
                //image = [UIImage imageWithData: data];
                if (image) {
                    cell.fileThumbs.image = image;
                }
                else
                {
                    cell.fileThumbs.image = [UIImage imageNamed:@"pictures_no"];
                    double delayInSeconds = 0.05;
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(delayTime, self.thumbnailQueue, ^{
 
                        
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                        // Just in case, make sure the cell for this indexPath is still On-Screen.
                        dispatch_semaphore_wait(self.mpbSemaphore, time);
                        //if ([tableView cellForRowAtIndexPath:indexPath]) {
                        if(_curMpbMediaType == MpbMediaTypePhoto)
                        {
                            //Fpath = @"PHOTO/";
                            _NvtThumbnilPath = [[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoFullName"];
                            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                           withString:@""];
                            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                           withString:@"/"];
                            data = [self NVTGetFileThunbnailCmd:@"4001" FullFileName:_NvtThumbnilPath];
                            image = [UIImage imageWithData: data];
                        }
                        else
                        {
                           
                            _NvtThumbnilPath = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"];
                            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                           withString:@""];
                            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                           withString:@"/"];
                            data = [self NVTGetFileThunbnailCmd:@"4001" FullFileName:_NvtThumbnilPath];
                            image = [UIImage imageWithData: data];
                            //============做二次判斷 如果有上鎖卻沒換路徑就照原路徑==========//
                            if(image)
                            {
                                
                            }
                            else
                            {
                                //Fpath = @"VIDEO/";
                                _NvtThumbnilPath = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"];
                                _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                               withString:@""];
                                _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                               withString:@"/"];
                                data = [self NVTGetFileThunbnailCmd:@"4001" FullFileName:_NvtThumbnilPath];
                                image = [UIImage imageWithData: data];
                            }
                            
                        }
                        
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                // [self.mpbCache setObject:image forKey:cachedKey];
                                MpbTableViewCell *c = (MpbTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (c) {
                                    c.fileThumbs.image = image;
                                    if(_curMpbMediaType == MpbMediaTypePhoto)
                                    {
                                        
                                    }
                                    else
                                    {
                                        int lock = [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoAttr"] intValue] & 1;
                                        if(lock)
                                        {
                                            [c setLockIconHidden:NO];
                                        }
                                        else
                                        {
                                            [c setLockIconHidden:YES];
                                        }
                                    }
                                    if(_curMpbState == MpbStateNor)
                                    {
                                        //[cell setClickOffIcon];
                                        //[cell setClickIconHidden:YES];
                                    }
                                    else
                                    {
                                        //[cell setClickIconHidden:NO];
                                        if([_FileListChooseItem containsObject:indexPath])
                                        {
                                            //[cell setClickOnIcon];
                                        }
                                        else
                                        {
                                            //[cell setClickOffIcon];
                                        }
                                    }
                                } else {
                                    [c setLockIconHidden:NO];
                                    // 解决thumbs显示错行
                                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                }
                            });
                        } else {
                            AppLog(@"request thumbnail failed");
                        }
                        //}
                        dispatch_semaphore_signal(self.mpbSemaphore);
                    });
                }
                
            }
            else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
            {
                int index = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
                NSLog(@"ASASASASASA---->   %d",[[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue]);
                ICatchFile file = _fileTable.fileList.at(index);
                NSLog(@"sdcsdc%s",file.getFilePath().c_str());
                [cell setFile:&file DateFormat:dateFormat];
                //cell.file = &file;

                if(_curMpbState == MpbStateNor)
                {

                }
                else
                {
                
                    if([self.selItemsTable.selectedCells containsObject:indexPath])
                    {
                        [cell setCellBGHidden:NO];
                    //    [cell setClickOnIcon];
                    }
                    else
                    {
                        [cell setCellBGHidden:YES];
                      //  [cell setClickOffIcon];
                    }
                }
                
                
                if(file.getFileProtection())
                {
                    [cell setLockIconHidden:NO];
                }
                else
                {
                    [cell setLockIconHidden:YES];
                }
                
                if (image) {
                    cell.fileThumbs.image = image;
                } else {
                    cell.fileThumbs.image = [UIImage imageNamed:@"pictures_no"];
                    
                    double delayInSeconds = 0.05;
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(delayTime, self.thumbnailQueue, ^{
                        /*if (!_run) {
                            AppLog(@"bypass...");
                            return;
                        }*/
                        
                        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                        // Just in case, make sure the cell for this indexPath is still On-Screen.
                        dispatch_semaphore_wait(self.mpbSemaphore, time);
                        //if ([tableView cellForRowAtIndexPath:indexPath]) {
                        UIImage *image = [[SDK instance] requestThumbnail:(ICatchFile *)&file];
                        if (image) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                //[self.mpbCache setObject:image forKey:cachedKey];
                                MpbTableViewCell *c = (MpbTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
                                if (c) {
                                    c.fileThumbs.image = image;
                                } else {
                                    // 解决thumbs显示错行
                                    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                }
                            });
                        } else {
                            AppLog(@"request thumbnail failed");
                        }
                        //}
                        dispatch_semaphore_signal(self.mpbSemaphore);
                    });
                }
            }
        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppLog(@"%s, curMpbState: %d", __func__, _curMpbState);

    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if (_curMpbState == MpbStateNor) {
            SEL callback = nil;
            
            switch (_curMpbMediaType) {
                case MpbMediaTypePhoto:
                    callback = @selector(photoSinglePlaybackCallback:);
                    break;
                    
                case MpbMediaTypeVideo:
                    callback = @selector(videoSinglePlaybackCallback:);
                    break;
                    
                default:
                    break;
            }
            
            if ([self respondsToSelector:callback]) {
                AppLog(@"callback-index: %ld", (long)indexPath.item);
                [self performSelector:callback withObject:indexPath afterDelay:0];
            } else {
                AppLog(@"It's not support to playback this file.");
            }
        } else {
            MpbTableViewCell *cell = (MpbTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            if (cell.tag == 1)// It's selected.
            {
                cell.tag = 0;
                [cell setCellBGHidden:YES];
                //[cell setClickOffIcon];
                [_FileListChooseItem removeObject:indexPath];
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    _totalDownloadSize -= [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoSize"] intValue]>>10;
                }
                else
                {
                    _totalDownloadSize -= [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoSize"] intValue]>>10;
                }
            }
            else
            {
                cell.tag = 1;
                //[cell setClickOnIcon];
                [_FileListChooseItem addObject:indexPath];
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    _totalDownloadSize += [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoSize"] intValue]>>10;
                }
                else
                {
                     _totalDownloadSize += [[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoSize"] intValue]>>10;
                }
                UIView *view_bg = [[UIView alloc]initWithFrame:cell.frame];
            
            	view_bg.backgroundColor = [UIColor colorWithRed:76/255.0 green:29/255.0 blue:31/255.0 alpha:1];
            
            	cell.selectedBackgroundView = view_bg;

            	[cell setCellBGHidden:NO];
               
            }

            self.ChooseItemcount = [_FileListChooseItem count];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditIconNotification"
                                                                object:_FileListChooseItem];
            /*self.selItemsTable.count = self.selItemsTable.selectedCells.count;
            
            if (self.selItemsTable.count) {
                if (!_isSend) {
                    [self postButtonStateChangeNotification:YES];
                }
            } else {
                if (_isSend) {
                    [self postButtonStateChangeNotification:NO];
                }
            }*/
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        int index = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
        ICatchFile file = _fileTable.fileList.at(index);
        if (_curMpbState == MpbStateNor) {
            SEL callback = nil;
            
            switch (file.getFileType()) {
                case TYPE_IMAGE:
                    callback = @selector(photoSinglePlaybackCallback:);
                    break;
                   
                case TYPE_VIDEO:
                    callback = @selector(videoSinglePlaybackCallback:);
                    break;
                    
                default:
                    break;
            }
            
            if ([self respondsToSelector:callback]) {
                AppLog(@"callback-index: %ld", (long)indexPath.item);
                [self performSelector:callback withObject:indexPath afterDelay:0];
            } else {
                AppLog(@"It's not support to playback this file.");
            }
        } else {
            MpbTableViewCell *cell = (MpbTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
            if (cell.tag == 1) { // It's selected.
                cell.tag = 0;
                //[cell setClickOffIcon];
                [self.selItemsTable.selectedCells removeObject:indexPath];
                _totalDownloadSize -= file.getFileSize()>>10;
                [cell setCellBGHidden:YES];
            } else {
                cell.tag = 1;
                //[cell setClickOnIcon];
                [self.selItemsTable.selectedCells addObject:indexPath];
                _totalDownloadSize += file.getFileSize()>>10;
                [cell setCellBGHidden:NO];
            }
            
            self.selItemsTable.count = self.selItemsTable.selectedCells.count;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditIconNotification"
                                                                object:self.selItemsTable];
           /* if (self.selItemsTable.count) {
                if (!_isSend) {
                    [self postButtonStateChangeNotification:YES];
                }
            } else {
                if (_isSend) {
                    [self postButtonStateChangeNotification:NO];
                }
            }*/
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)postButtonStateChangeNotification:(BOOL)state
{
    _isSend = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsCurStateNotification"
                                                        object:@(state)];
}



#pragma mark - UITableViewDelegate
- (void)photoSinglePlaybackCallback:(NSIndexPath *)indexPath {

    __block UIImage *image;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        __block NSString *Fpath;
        __block NSData *data = [[NSData alloc] init];
        _videoPlaybackIndex = indexPath.row;
        _videoPlaybackIndex_section = indexPath.section;
        if(_curMpbMediaType == MpbMediaTypePhoto)
        {
            //Fpath = @"PHOTO/";
           /* _NvtThumbnilPath = [Fpath stringByAppendingString:[[_FileListPhotoProperty objectAtIndex:_videoPlaybackIndex] objectForKey:@"PhotoFullName"]];*/
            self.NvtThumbnilPath = [[[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoFullName"] stringByReplacingOccurrencesOfString:@"A:\\"
                                                                           withString:@""];
            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                           withString:@"/"];
            //http://192.168.1.254/PHOTO/20190101000717_000620.JPG
            _NvtThumbnilPath = [NSString stringWithFormat:@"http://192.168.1.254/%@",_NvtThumbnilPath];
            //data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        else{
            //Fpath = @"VIDEO/";
            _NvtThumbnilPath = [Fpath stringByAppendingString:[[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"]];
            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                           withString:@""];
            _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                           withString:@"/"];
            _NvtThumbnilPath = [NSString stringWithFormat:@"http://192.168.1.254/%@",_NvtThumbnilPath];
            //data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: _NvtThumbnilPath]];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                // WARNING: is the cell still using the same data by this point??
                image = [UIImage imageWithData: data];
                //cell.image = [UIImage imageWithData: data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
                    mpbSegmentViewController.fileType = 1;
                    mpbSegmentViewController.thumbImage = image;
                    mpbSegmentViewController.updatePreview;
                });
            });
            data = nil;
        });
        
#if 0
        if (!image) {
            
            dispatch_suspend(self.thumbnailQueue);
            
            [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                              detailsMessage:nil
                                        mode:MBProgressHUDModeIndeterminate];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!_run) {
                    return;
                }
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                dispatch_semaphore_wait(self.mpbSemaphore, time);
                
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    _NvtThumbnilPath = [[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoName"];
                    _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                   withString:@""];
                    _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                   withString:@"/"];
                    data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                }
                else{
                    _NvtThumbnilPath = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"];
                    _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                   withString:@""];
                    _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                   withString:@"/"];
                    data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                }
                image = [UIImage imageWithData: data];
                /* if (image != nil) {
                 [self.mpbCache setObject:image forKey:cachedKey];
                 }*/
                dispatch_semaphore_signal(self.mpbSemaphore);
                dispatch_resume(self.thumbnailQueue);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
                    mpbSegmentViewController.fileType = 1;
                    mpbSegmentViewController.updatePreview;
                });
            });
        } else {
            //_videoPlaybackThumb = image;
            //[self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
            MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
            mpbSegmentViewController.fileType = 1;
            mpbSegmentViewController.thumbImage = image;
            mpbSegmentViewController.updatePreview;
        }
#endif
    }
    else
    {
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
      /*  self.browser = [_ctrl.fileCtrl createOneMWPhotoBrowserWithDelegate:self];
        [_browser setCurrentPhotoIndex:indexPath.item];
    
        [self.navigationController pushViewController:self.browser animated:YES];*/
        ICatchFile file = _fileTable.fileList.at(indexPath.row);
        
        UIImage *image = [[SDK instance] requestImage:(ICatchFile *)&file];/*[_ctrl.fileCtrl requestImage:(ICatchFile *)&file];*/
        mpbSegmentViewController.fileType = 1;
        mpbSegmentViewController.thumbImage = image;
        mpbSegmentViewController.updatePreview;
    }
}

- (void)videoSinglePlaybackCallback:(NSIndexPath *)indexPath
{
    AppLog(@"%s", __func__);
    __block UIImage *image;
    self.ReadyPlay =YES;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        __block NSString *HttpFilePath = @"http://192.168.1.254/";
        //__block NSString *Fpath;
        __block NSData *data = [[NSData alloc] init];
         _videoPlaybackIndex = indexPath.row;
        _videoPlaybackIndex_section = indexPath.section;
        if(_curMpbMediaType == MpbMediaTypePhoto)
        {
            //Fpath = @"PHOTO/";
            self.NvtPlayerUrl = [[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoFullName"];
            self.NvtPlayerUrl = [self.NvtPlayerUrl stringByReplacingOccurrencesOfString:@"A:\\"
                                                                           withString:@""];
            self.NvtPlayerUrl = [self.NvtPlayerUrl stringByReplacingOccurrencesOfString:@"\\"
                                                                           withString:@"/"];
            
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:self.NvtPlayerUrl];
            
            image = [UIImage imageWithData: data];
            if (!image) {
                dispatch_suspend(self.thumbnailQueue);
                
                [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                                  detailsMessage:nil
                                            mode:MBProgressHUDModeIndeterminate];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (!_run) {
                        return;
                    }
                    
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                    dispatch_semaphore_wait(self.mpbSemaphore, time);
                    
                    if(_curMpbMediaType == MpbMediaTypePhoto)
                    {
                        _NvtThumbnilPath = [[[_FileListPhotoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"PhotoFullName"];
                        _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                       withString:@""];
                        _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                       withString:@"/"];
                        data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                    }
                    else{
                        _NvtThumbnilPath = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"];
                        _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                                       withString:@""];
                        _NvtThumbnilPath = [_NvtThumbnilPath stringByReplacingOccurrencesOfString:@"\\"
                                                                                       withString:@"/"];
                        data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                    }
                    image = [UIImage imageWithData: data];
                    /* if (image != nil) {
                     [self.mpbCache setObject:image forKey:cachedKey];
                     }*/
                    dispatch_semaphore_signal(self.mpbSemaphore);
                    dispatch_resume(self.thumbnailQueue);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        mpbSegmentViewController.fileType = 1;
                        mpbSegmentViewController.updatePreview;
                        HttpFilePath = [HttpFilePath stringByAppendingString:_NvtThumbnilPath];
                        mpbSegmentViewController.HttpFileNamePath = HttpFilePath;
                    });
                });
            } else {
                //_videoPlaybackThumb = image;
                //[self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
                mpbSegmentViewController.fileType = 1;
                mpbSegmentViewController.thumbImage = image;
                mpbSegmentViewController.updatePreview;
                HttpFilePath = [HttpFilePath stringByAppendingString:_NvtThumbnilPath];
                mpbSegmentViewController.HttpFileNamePath = HttpFilePath;
                
            }
        }
        else
        {
            NSString *FileInformation;
            [_pbTimer invalidate];

            
            
            self.NvtPlayerUrl = [[[_FileListVideoPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] objectForKey:@"VideoFullName"];
             self.NvtPlayerUrl = [ self.NvtPlayerUrl stringByReplacingOccurrencesOfString:@"A:\\" withString:@""];
             self.NvtPlayerUrl = [ self.NvtPlayerUrl stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
            
            //FileInformation = [self NVTGetFileInformationCmd:@"4005" FullFileName:self.NvtPlayerUrl];
            
            self.PlaybackRun = YES;
            self.played = NO;
            self.paused = YES;
            //NSRange searchResult1 = [FileInformation rangeOfString:@"Length:"];
            //NSRange searchResult2 = [FileInformation rangeOfString:@"sec"];

            
            //self.totalSecs = [[FileInformation substringWithRange:NSMakeRange(searchResult1.location+searchResult1.length, (searchResult2.location)-(searchResult1.location+searchResult1.length))] doubleValue];
            //mpbSegmentViewController.SliderMaxValue = self.totalSecs;
            mpbSegmentViewController.NodePlayerClearView;
            mpbSegmentViewController.fileType = 0;
            mpbSegmentViewController.updatePreview;
            mpbSegmentViewController.updatePlayerStatusSetFalse;
            //mpbSegmentViewController.NovatekSliderMaxValue;
            
            mpbSegmentViewController.PlayerPath = self.NvtPlayerUrl;
            mpbSegmentViewController.NovatekSetPlayPath;
            mpbSegmentViewController.NodePlayerFirstFramePic = YES;
            //mpbSegmentViewController.NovatekPlayerStart;
            
           // mpbSegmentViewController.NodePlayerSeekToZero;
            
            self.pbTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                          target  :self
                                                          selector:@selector(updateTimeInfo:)
                                                          userInfo:nil
                                                          repeats :YES];
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
#if 1
        _videoPlaybackIndex = indexPath.row;
        _videoPlaybackIndex_section = indexPath.section;
        if(self.played)
        {
            [self stopVideoPb];
        }
        
        [self showProgressHUDWithMessage:NSLocalizedString(@"LOAD_SETTING_DATA", nil)];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
            if(dispatch_semaphore_wait(self.semaphore, time) != 0)  {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showProgressHUDNotice:@"Timeout!" showTime:2.0];
                });
            } else {
                dispatch_semaphore_signal(self.semaphore);

                    self.PlaybackRun = YES;
                        // Play
                        dispatch_async(_videoPlaybackQ, ^{
                            ICatchFile file = _fileTable.fileList.at(_videoPlaybackIndex);
                            [_ctrl.pbCtrl stop];
                            AppLog(@"call play");
                            self.totalSecs = [_ctrl.pbCtrl play:&file];
                            if (_totalSecs <= 0) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self showProgressHUDNotice:@"Failed to play" showTime:2.0];
                                });
                                //return;
                            }
                            self.played = YES;
                            self.paused = NO;
                            self.exceptionHappen = NO;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                 [self addPlaybackObserver];
                                mpbSegmentViewController.updatePlayerStatusSetFalse;
                                mpbSegmentViewController.seekvalue = 0;
                                mpbSegmentViewController.updateSeekBarValue;
                                mpbSegmentViewController.SliderMaxValue = _totalSecs;
                                mpbSegmentViewController.updateSliderMaxValue;
                                

                            });
                           
                            if ([_ctrl.pbCtrl audioPlaybackStreamEnabled]) {
                                dispatch_group_async(_playbackGroup, _audioQueue, ^{[self playAudio];});
                            } else {
                                AppLog(@"Playback doesn't contains audio.");
                            }
                            if ([_ctrl.pbCtrl videoPlaybackStreamEnabled]) {
                                dispatch_group_async(_playbackGroup, _videoQueue, ^{[self playVideo];});
                            } else {
                                AppLog(@"Playback doesn't contains video.");
                            }
                        });
            }
        });
#endif
    }
}



- (void)allPlaybackCallback:(NSIndexPath *)indexPath
{
    AppLog(@"%s", __func__);
    int index = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
    ICatchFile file = _fileTable.fileList.at(index);
    
    switch (file.getFileType()) {
        case TYPE_IMAGE:
            [self photoSinglePlaybackCallback:indexPath];
            break;
            
        case TYPE_VIDEO:
            [self videoSinglePlaybackCallback:indexPath];
            break;
            
        default:
            [self nonePlaybackCallback:indexPath];
            break;
    }
}


- (void)nonePlaybackCallback:(NSIndexPath *)indexPath
{
    AppLog(@"%s", __func__);
    [self showProgressHUDCompleteMessage:NSLocalizedString(@"It's not supported yet.", nil)];
}
/*
#pragma mark - MWPhotoBrowserDataSource
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    AppLog(@"%s", __func__);
    return _gallery.imageTable.fileList.size();
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser
                photoAtIndex:(NSUInteger)index
{
    AppLog(@"%s(%lu)", __func__, (unsigned long)index);
    MWPhoto *photo = nil;
    unsigned long listSize = 0;

    listSize = _gallery.imageTable.fileList.size();
    ICatchFile file = _gallery.imageTable.fileList.at(index);
    
    if (index < listSize) {
        photo = [MWPhoto photoWithURL:[NSURL URLWithString:@"sdk://test"] funcBlock:^{
            return [_ctrl.fileCtrl requestImage:(ICatchFile *)&file];
        }];
    }
    
    return photo;
}
*/
- (void)showShareConfirmForphotoBrowser
{
    NSIndexPath *ip = [self.selItemsTable.selectedCells firstObject];
    int index = [[[_FileListICatchPropertySort objectAtIndex:ip.section] objectAtIndex:ip.row] intValue];
    ICatchFile f = _fileTable.fileList.at(index);
    
    NSString *fileName = [NSString stringWithUTF8String:f.getFileName().c_str()];
    NSArray *tmpDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
    
    self.downloadFileProcessing = YES;
    self.downloadedPercent = 0;
    if (tmpDirectoryContents.count) {
        for (NSString *name in tmpDirectoryContents) {
            if ([name isEqualToString:fileName]) {
                [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                break;
            } else if ([name isEqualToString:[tmpDirectoryContents lastObject]]) {
                if ([[SDK instance] p_downloadFile:&f]) {
                    [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                }
            }
        }
    } else {
        if ([[SDK instance] p_downloadFile:&f]) {
            [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
        }
    }
}
/*
#pragma mark - MWPhotoBrowserDelegate
-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
    AppLog(@"%s", __func__);
    if (!self.shareFiles) {
        self.shareFiles = [NSMutableArray array];
    } else {
        [self.shareFiles removeAllObjects];
    }

    [self.selItemsTable.selectedCells removeAllObjects];
    [self.selItemsTable.selectedCells addObject:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (BOOL)photoBrowser      :(MWPhotoBrowser *)photoBrowser
        deletePhotoAtIndex:(NSUInteger)index
{
    AppLog(@"%s", __func__);
    NSUInteger i = 0;
    unsigned long listSize = 0;
    BOOL ret = NO;

    listSize = _gallery.imageTable.fileList.size();
    if (listSize>0) {
        i = MAX(0, MIN(index, listSize - 1));
        ICatchFile file = _gallery.imageTable.fileList.at(i);
        ret = [_ctrl.fileCtrl deleteFile:&file];
        if (ret) {
            NSString *cachedKey = [NSString stringWithFormat:@"ID%d", file.getFileHandle()];
            [self.mpbCache removeObjectForKey:cachedKey];
            [self resetCollectionViewData];
        }
    }
    
    return ret;
}

-(BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser downloadPhotoAtIndex:(NSUInteger)index
{
    AppLog(@"%s", __func__);
    [self showShareConfirm];
    
    return _downloadFailedCount>0?NO:YES;
}

-(void)photoBrowser:(MWPhotoBrowser *)photoBrowser shareImageAtIndex:(NSUInteger)index {
    AppLog(@"%s", __func__);
    [self showUIActivityViewController:photoBrowser.actionButton];
}

-(void)shareImage:(MWPhotoBrowser *)photoBrowser {
    AppLog(@"%s", __func__);
    [self showShareConfirmForphotoBrowser];
}
*/
#pragma mark - MpbSegmentViewController delegate
- (MpbState)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController edit:(id)sender
{
    [self edit:sender];
    AppLog(@"%s, curMpbState: %d", __func__, _curMpbState);
    
    return _curMpbState;
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController play:(id)sender
{
    [self play:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController OKAction:(int)ActionType
{
    [self OKAction:ActionType];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController CancelAction:(id)sender
{
    [self CancelAction:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController playback_fullscreenBT_clicked:(id)sender
{
    [self playback_fullscreenBT_clicked:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController goHome:(id)sender
{
    [self goHome:sender];
}

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController delete:(id)sender
{
    [self delete:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController LockAction:(id)sender
{
    [self LockAction:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController UnLockAction:(id)sender
{
    [self UnLockAction:sender];
}

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController action:(id)sender
{
    self.actionButton = mpbSegmentViewController.actionButton;
    [self showShareConfirm];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController sliderTouchDown:(BOOL)isSeek
{
    [self sliderTouchDown:isSeek];
}

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController SeekToSecond:(double)value
{
    [self SeekToSecond:value];
}

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController cancelDownload:(id)sender
{
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
        [connect cancel];
        FileHasExist = NO;
        FileNumber = 0;
        _totalDownloadSize = 0;
        self.receiveLength = 0;
        self.NVT_Download_totalLength = 0;
        [self edit:(id)@"3"];
        [self tableViewCellEnable];
    } else {
        
    }
}
#pragma mark AppDelegateProtocol
- (void)sdcardRemoveCallback {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressHUDNotice:NSLocalizedString(@"CARD_REMOVED", nil) showTime:2.0];
    });
}
- (NSString *)recheckSSID
{
    //    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    //    NSLog(@"Networks: %@",networkInterfaces);
    
    NSString *ssid = nil;
    //NSString *bssid = @"";
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
- (NSString *)NvtDiskFreeSpace:(NSString *)cmd{
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/?custom=1&cmd=",cmd];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    
    [m_parser setDelegate:self];
    
    BOOL flag = [m_parser parse]; //开始解析
    if(flag) {
        NSLog(@"解析指定路径的xml文件成功");
    }
    else {
        NSLog(@"解析指定路径的xml文件失败");
    }
    // NSLog(@"NVT ALL COMMAND = @%@",[self.NVTGetHttpValueDict allKeys]);
    //for(NSString *key in self.NVTGetHttpValueDict){
    //NSLog(@"command value = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    // }
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    NSLog(@"GetValue = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    
    return [self.NVTGetHttpValueDict objectForKey:cmd];
}
- (void)NvtSendFileDownload:(NSString *)Name{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/",Name];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    [NSURLConnection connectionWithRequest:request delegate:self];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NAVATAKE STRING = %@",str);
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        
    }
    
}
- (void)NvtSendFileDelete:(NSString *)cmd FullFileName:(NSString *)Name{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    Name = [Name stringByReplacingOccurrencesOfString:@"/" withString:@"%5C"];
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&str=A%3A%5C",Name];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        
    }
    
}
- (void)NvtSendFileLock:(NSString *)cmd FullFileName:(NSString *)Name parameter:(NSString *)LockValue{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    Name = [Name stringByReplacingOccurrencesOfString:@"/" withString:@"%5C"];
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&par=",LockValue,"&str=A:%5C",Name];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    else{
        
    }
    
}
- (void)httpAsynchronousRequest:(NSString *)cmd FullFileName:(NSString *)Name parameter:(NSString *)LockValue
{
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    Name = [Name stringByReplacingOccurrencesOfString:@"/" withString:@"%5C"];
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&par=",LockValue,"&str=A:%5C",Name];
    
    NSURL *url =[NSURL URLWithString:fullcmd];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    //3.获得会话对象
    NSURLSession *session=[NSURLSession sharedSession];
    
    //4.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask=[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        if(error==nil){
            //6.解析服务器返回的数据
            //说明：（此处返回的数据是JSON格式的，因此使用NSJSONSerialization进行反序列化处理）
            NSDictionary *dict=[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            
            NSLog(@"%@",dict);
        }
    }];
    //5.执行任务
    [dataTask resume];
}
- (NSString *)NVTGetFileInformationCmd:(NSString *)cmd FullFileName:(NSString *)Name{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/",Name,"?custom=1&cmd=",cmd];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NAVATAKE STRING = %@",str);
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    
    [m_parser setDelegate:self];
    
    BOOL flag = [m_parser parse]; //开始解析
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    
    //UIImage *image = [UIImage imageWithData: data];
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    return [self.NVTGetHttpValueDict objectForKey:cmd];;
}
- (NSData *)NVTGetFileThunbnailCmd:(NSString *)cmd FullFileName:(NSString *)Name{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/",Name,"?custom=1&cmd=",cmd];
    
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"NAVATAKE STRING = %@",str);
    
    /*http://192.168.1.254/NOVATEK/MOVIE/2014_0321_011922_002.MOV?custom=1&cmd=4001*/
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    
    //UIImage *image = [UIImage imageWithData: data];
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    return data;
}
- (void)NVTSendHttpCmd:(NSString *)cmd Par2:(NSString *)par{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&par=",par];
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"NAVATAKE STRING = %@",str);
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    
    
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    
}
- (NSString *)NVTGetHttpCmd:(NSString *)cmd{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/?custom=1&cmd=",cmd];
    NSURL *url = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NAVATAKE STRING = %@",str);
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    
    [m_parser setDelegate:self];
    
    BOOL flag = [m_parser parse]; //开始解析
    if(flag) {
        NSLog(@"解析指定路径的xml文件成功");
    }
    else {
        NSLog(@"解析指定路径的xml文件失败");
    }
    // NSLog(@"NVT ALL COMMAND = @%@",[self.NVTGetHttpValueDict allKeys]);
    //for(NSString *key in self.NVTGetHttpValueDict){
    //NSLog(@"command value = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    // }
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    NSLog(@"GetValue = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    
    return [self.NVTGetHttpValueDict objectForKey:cmd];
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    
}
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}
//step 2：准备解析节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"Cmd"]){
        storingFlag = TRUE;
        CmdFlag = YES;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
    }
    else if([elementName isEqualToString:@"NAME"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        FileListFlag = YES;
        NameFlag = YES;
    }
    else if([elementName isEqualToString:@"FPATH"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        FpathFlag = YES;
    }
    else if([elementName isEqualToString:@"SIZE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        SizeFlag = YES;
    }
    else if([elementName isEqualToString:@"TIMECODE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        TimeCodeFlag = YES;
    }
    else if([elementName isEqualToString:@"TIME"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        TimeFlag = YES;
    }
    else if([elementName isEqualToString:@"LOCK"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        LockFlag = YES;
    }
    else if([elementName isEqualToString:@"ATTR"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        AttrFlag = YES;
    }
}
//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingFlag) {
        storingFlag = FALSE;
        if(CmdFlag)
        {
            CmdFlag = NO;
            currentElementCommand = [[NSString alloc] initWithString:string];
        }
        else if(StatusFlag){
            StatusFlag = NO;
            currentElementStatus = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementStatus forKey:currentElementCommand];
        }
        else if(ValueFlag){
            ValueFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(StringFlag){
            StringFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(FileListFlag){
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            if(NameFlag)
            {
                NameFlag = NO;
                _FileVideoInfo = [[NSMutableDictionary alloc] init];
                _FilePhotoInfo = [[NSMutableDictionary alloc] init];
                if([string containsString:@".JPG"]){
                    isVideo = NO;
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoName"];

                }
                else{
                    isVideo = YES;
                    [_FileVideoInfo setValue:currentElementValue forKey:@"VideoName"];

                }
                
                // [FileListName addObject:currentElementValue];
                
                //[[self.FileList objectAtIndex:Pens] objectAtIndex:Item];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"NAME"];
                
            }
            else if(FpathFlag)
            {
                FpathFlag = NO;
                if(isVideo){
                     [_FileVideoInfo setValue:currentElementValue forKey:@"VideoFullName"];
                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoFullName"];
                }
                
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"FPATH"];
            }
            else if(SizeFlag)
            {
                SizeFlag = NO;
                if(isVideo){
                    [_FileVideoInfo setValue:currentElementValue forKey:@"VideoSize"];
                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoSize"];
  
                }
            }
            else if(TimeCodeFlag)
            {
                TimeCodeFlag = NO;
                if(isVideo){
                    [_FileVideoInfo setValue:currentElementValue forKey:@"VideoTimeCode"];

                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoTimeCode"];
                }
                //[FileListTimeCode addObject:currentElementValue];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"TIMECODE"];
            }
            else if(TimeFlag)
            {
                TimeFlag = NO;
                if(isVideo){
                     [_FileVideoInfo setValue:currentElementValue forKey:@"VideoTime"];
                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoTime"];
                }

            }
            else if(LockFlag)
            {
                LockFlag = NO;
                if(isVideo){
                    [_FileVideoInfo setValue:currentElementValue forKey:@"VideoLock"];
                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoLock"];

                }
            }
            else if(AttrFlag)
            {
                if(isVideo){
                    [_FileVideoInfo setValue:currentElementValue forKey:@"VideoAttr"];
                    [_FileListVideoProperty addObject:_FileVideoInfo];

                }
                else{
                    [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoAttr"];
                    [_FileListPhotoProperty addObject:_FilePhotoInfo];
                }
                AttrFlag = NO;
                FileListFlag = NO;
                //isVideo = NO;

            }
        }
    }
}


//step 4 ：解析完当前节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

//step 5：解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}
//step 6：获取cdata块数据
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    isDownloadError = false;
    fileHandle = nil;
    self.receiveLength = 0;
    self.NVT_Download_totalLength = 0;
    NSLog(@"取得網站回應");
    
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
    
    NSLog(@"FileNumberAAAAA-> %d",FileNumber);
    
    
    
    self.NVT_Download_totalLength = response.expectedContentLength;
    /*[self showProgressHUDWithMessage:@"请稍候 ..."
                      detailsMessage:nil
                                mode:MBProgressHUDModeDeterminate];*/
    
    
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    __block float progress = 0;
    
    if(fileHandle) {
        // 找到檔案的尾巴
        [fileHandle seekToEndOfFile];
    }
    else {
    /*NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
        
        NSString *path = [paths objectAtIndex:0];*/
        NSIndexPath *index = [_FileListChooseItem objectAtIndex:FileNumber];
        if(_curMpbMediaType == MpbMediaTypeVideo)
        {
            DocumentsfilePath = [[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoFullName"];
            DocumentsfilePath = [DocumentsfilePath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                           withString:@""];
            DocumentsfilePath = [DocumentsfilePath stringByReplacingOccurrencesOfString:@"\\"
                                                                           withString:@"/"];
            self.NvtFileLocalPaths = [NSString stringWithFormat:@"%@/%@",_NewPaths,[[[_FileListVideoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"VideoName"]];
            [[NSFileManager defaultManager] createFileAtPath:self.NvtFileLocalPaths contents:nil attributes:nil];
        }
        else
        {
            DocumentsfilePath = [[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoFullName"];
            DocumentsfilePath = [DocumentsfilePath stringByReplacingOccurrencesOfString:@"A:\\"
                                                                             withString:@""];
            DocumentsfilePath = [DocumentsfilePath stringByReplacingOccurrencesOfString:@"\\"
                                                                             withString:@"/"];
            self.NvtFileLocalPaths = [NSString stringWithFormat:@"%@/%@",_NewPaths,[[[_FileListPhotoPropertySort objectAtIndex:index.section] objectAtIndex:index.row] objectForKey:@"PhotoName"]];
            
            [[NSFileManager defaultManager] createFileAtPath:self.NvtFileLocalPaths contents:nil attributes:nil];
        }
        FileHasExist = [[NSFileManager defaultManager] fileExistsAtPath:self.NvtFileLocalPaths];
        
        
        // 建立檔案的URL
        
        // 初始化檔案處理
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.NvtFileLocalPaths];
        
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.receiveLength += data.length;
        progress = (float)_receiveLength / (float)_NVT_Download_totalLength;
        self.downloadedPercent = MAX(0, MIN(100, progress*100));
        //NSString *msg = [NSString stringWithFormat:@"%lu%%", (unsigned long)_downloadedPercent];
        //NSString *number = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)FileNumber, (unsigned long)[_FileListChooseItem count]];
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        if(_receiveLength != 0) {
            //NSLog(@"FileNumberBBBBBBB = %d",FileNumber);
            if([mpbSegmentViewController needUpdateProgress:FileNumber]) {
                [mpbSegmentViewController setDownloadProgress:(unsigned long)FileNumber Progress:(unsigned long)_downloadedPercent ProgressStorage:(float)_receiveLength/1024/1024];
            }
        }
        /*[self showProgressHUDWithMessage:number
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
        
        [self updateProgressHUDWithMessage:nil detailsMessage:msg];*/
    });
    
    
    // 寫入資料到硬碟
    [fileHandle writeData:data];
    //NSLog(@"取得資料  %d",FileNumber);
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    if(![mpbSegmentViewController needDownloadFile:FileNumber]) {
        [connect cancel];
        FileNumber++;
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        [mpbSegmentViewController downloadFailed];
        [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
        if(FileNumber == _FileListChooseItem.count)
        {
            [mpbSegmentViewController downloadCompletedNotice];
            FileNumber = 0;
            _totalDownloadSize = 0;
            [self edit:(id)@"3"];
            [self tableViewCellEnable];
            self.receiveLength = 0;
            self.NVT_Download_totalLength = 0;
        }
        else{
            [self NvtdownloadDetail:(id)@"3"];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"發生錯誤！");
    FileNumber++;
    //if(isDownloadError == true) {
    
        //return;
    //}
    isDownloadError = true;
    
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    [mpbSegmentViewController downloadFailed];
    [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
    FileHasExist = NO;
    if(FileNumber == _FileListChooseItem.count)
    {
        
        [mpbSegmentViewController downloadCompletedNotice];
        /*NSString *number = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)FileNumber, (unsigned long)[_FileListChooseItem count]];
        [self showProgressHUDWithMessage:number
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];*/
        NSLog(@"下載完成AA  %d",FileNumber);
        FileNumber = 0;
        _totalDownloadSize = 0;
        //[self hideProgressHUD:YES];
        [self edit:(id)@"3"];
        [self tableViewCellEnable];
        /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
         object:@(nil)];*/
        self.receiveLength = 0;
        self.NVT_Download_totalLength = 0;
    }
    else{
        //FileNumber++;
        [self NvtdownloadDetail:(id)@"3"];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileHandle closeFile];
    #if 0
    if(!FileHasExist)
    {
        if(_curMpbMediaType == MpbMediaTypeVideo)
        {

            NSURL *url = [NSURL fileURLWithPath:DocumentsfilePath];
            __block NSString *localIdentifier;
            PHFetchResult *collectonResuts = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            //对获取到集合进行遍历
            [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAssetCollection *assetCollection = obj;
                //folderName是我们写入照片的相册
                if ([assetCollection.localizedTitle isEqualToString:@"iQViewer"])  {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        //请求创建一个Asset
                        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                        //请求编辑相册
                        PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        //为Asset创建一个占位符，放到相册编辑请求中
                        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset];
                        //相册中添加视频
                        [collectonRequest addAssets:@[placeHolder]];
                        
                        localIdentifier = placeHolder.localIdentifier;
                        
                    } completionHandler:^(BOOL success, NSError *error) {
                        if (success) {
                            NSLog(@"保存视频成功!");
                        } else {
                            NSLog(@"保存视频失败:%@", error);
                        }
                    }];
                }
            }];

        }
        else
        {
           
            UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:DocumentsfilePath];
            PHFetchResult *collectonResuts = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:[PHFetchOptions new]] ;
            //对获取到集合进行遍历
            [collectonResuts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                PHAssetCollection *assetCollection = obj;
                //Camera Roll是我们写入照片的相册
                if ([assetCollection.localizedTitle isEqualToString:@"iQViewer"])  {
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        //请求创建一个Asset
                        PHAssetChangeRequest *assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:imgFromUrl3];
                        //请求编辑相册
                        PHAssetCollectionChangeRequest *collectonRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
                        //为Asset创建一个占位符，放到相册编辑请求中
                        PHObjectPlaceholder *placeHolder = [assetRequest placeholderForCreatedAsset ];
                        //相册中添加照片
                        [collectonRequest addAssets:@[placeHolder]];
                    } completionHandler:^(BOOL success, NSError *error) {
                        NSLog(@"Error:%@", error);
                    }];
                }
            }];
        }
    }
    #endif
    FileHasExist = NO;
    FileNumber++;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    [mpbSegmentViewController downloadSuccess];
    if(FileNumber == _FileListChooseItem.count)
    {
        
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        [mpbSegmentViewController downloadProcessingNumber:FileNumber total:(unsigned long)[_FileListChooseItem count]];
        /*NSString *number = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)FileNumber, (unsigned long)[_FileListChooseItem count]];
        [self showProgressHUDWithMessage:number
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];*/
        NSLog(@"下載完成BB  %d",FileNumber);
        [mpbSegmentViewController downloadCompletedNotice];
        FileNumber = 0;
        _totalDownloadSize = 0;
        //[self hideProgressHUD:YES];
        [self edit:(id)@"3"];
        [self tableViewCellEnable];
        /*[[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsEditAnimateNotification"
                                                            object:@(nil)];*/
        self.receiveLength = 0;
        self.NVT_Download_totalLength = 0;
    }
    else{
        
        [self NvtdownloadDetail:(id)@"3"];
    }

    /* [self removeObserver:self forKeyPath:@"downloadedFileNumber"];
     [self removeObserver:self forKeyPath:@"downloadedPercent"];*/
    // NSLog(@"下載完成");
}
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */

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
            [mpbSegmentViewController hideFullBackView:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsfullscreenAnimateNotification"
                                                                object:@(nil)];
            break;
            
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"屏幕向右橫置");
            [mpbSegmentViewController hideFullBackView:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsfullscreenAnimateNotification"
                                                                object:@(nil)];
            break;
            
        case UIDeviceOrientationPortrait:

            NSLog(@"屏幕直立");
            [mpbSegmentViewController hideFullBackView:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsfullscreenAnimateNotification"
                                                                object:@(nil)];
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}


- (void)addPlaybackObserver
{
     videoPbProgressListener = new VideoPbProgressListener(self);
     [_ctrl.comCtrl addObserver:ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_PROGRESS
     listener:videoPbProgressListener
     isCustomize:NO];
     videoPbProgressStateListener = new VideoPbProgressStateListener(self);
     [_ctrl.comCtrl addObserver:ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_CHANGED
     listener:videoPbProgressStateListener
     isCustomize:NO];
     videoPbDoneListener = new VideoPbDoneListener(self);
     [_ctrl.comCtrl addObserver:ICATCH_EVENT_VIDEO_STREAM_PLAYING_ENDED
     listener:videoPbDoneListener
     isCustomize:NO];
     videoPbServerStreamErrorListener = new VideoPbServerStreamErrorListener(self);
     [_ctrl.comCtrl addObserver:ICATCH_EVENT_SERVER_STREAM_ERROR
     listener:videoPbServerStreamErrorListener
     isCustomize:NO];
}

- (void)removePlaybackObserver
{
     if (videoPbProgressListener) {
     [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_PROGRESS
     listener:videoPbProgressListener
     isCustomize:NO];
     delete videoPbProgressListener; videoPbProgressListener = NULL;
     }
     if (videoPbProgressStateListener) {
     [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_CHANGED
     listener:videoPbProgressStateListener
     isCustomize:NO];
     delete videoPbProgressStateListener; videoPbProgressStateListener = NULL;
     }
     if (videoPbDoneListener) {
     [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_STREAM_PLAYING_ENDED
     listener:videoPbDoneListener
     isCustomize:NO];
     delete videoPbDoneListener; videoPbDoneListener = NULL;
     }
     if (videoPbServerStreamErrorListener) {
     [_ctrl.comCtrl removeObserver:ICATCH_EVENT_SERVER_STREAM_ERROR
     listener:videoPbServerStreamErrorListener
     isCustomize:NO];
     delete videoPbServerStreamErrorListener; videoPbServerStreamErrorListener = NULL;
     }
    
}
- (void)updateVideoPbProgress:(double)value
{
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    printf("\n value = %lf,self.totalSecs = %lf,value/self.totalSecs = %lf\n",value,self.totalSecs,value/self.totalSecs);
    dispatch_async(dispatch_get_main_queue(), ^{
    mpbSegmentViewController.BufferValue = value;
    mpbSegmentViewController.updateBufferSliderValue;
      //  [_bufferingView setNeedsDisplay];
    });
}

- (void)updateVideoPbProgressState:(BOOL)caching
{
    if (!_played || _paused) {
        return;
    }
    /*dispatch_async(dispatch_get_main_queue(), ^{
        if (caching) {
            [_ctrl.pbCtrl pause];
            //[_al pause];

        } else {
            //[_al play];
            [_ctrl.pbCtrl resume];
        }
    });*/
}

- (void)stopVideoPb
{
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    
    self.PlaybackRun = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(_semaphore, time) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:@"Timeout!" showTime:2.0];
            });
        } else {
            [_ctrl.pbCtrl stop];
            [self removePlaybackObserver];
            self.played = NO;
            self.paused = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                //_deleteButton.enabled = YES;
                //_actionButton.enabled = YES;
                
                dispatch_semaphore_signal(self.semaphore);
                mpbSegmentViewController.updatePlayerStatusSetFalse;
                [_pbTimer invalidate];
                
                self.curVideoPTS = 0;
                self.playedSecs = 0;
            });
        }
    });
}

- (void)showServerStreamError
{
    AppLog(@"server error!");
    self.exceptionHappen = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressHUDNotice:NSLocalizedString(@"CameraPbError", nil)
                           showTime:2.0];
    });
    [self stopVideoPb];
}
- (void)playAudio
{
    NSMutableData *audioBuffer = [[NSMutableData alloc] init];
    
    ICatchAudioFormat format = [_ctrl.propCtrl retrievePlaybackAudioFormat];
    AppLog(@"Codec:%x, freq: %d, chl: %d, bit:%d", format.getCodec(), format.getFrequency(), format.getNChannels(), format.getSampleBits());
    
    _pcmPl = [[PCMDataPlayer alloc] initWithFreq:format.getFrequency() channel:format.getNChannels() sampleBit:format.getSampleBits()];
    if (!_pcmPl) {
        AppLog(@"Init audioQueue failed.");
        return;
    }
    
    while (_PlaybackRun) {
        @autoreleasepool {
            if (_paused) {
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
            
            NSDate *begin = [NSDate date];
            [audioBuffer setLength:0];
            
            for (int i = 0; i < 4; i++) {
                NSDate *begin1 = [NSDate date];
                ICatchFrameBuffer *buff = [_ctrl.propCtrl prepareDataForPlaybackAudioTrack1];
                NSDate *end1 = [NSDate date];
                NSTimeInterval elapse1 = [end1 timeIntervalSinceDate:begin1] * 1000;
                RunLog(@"getNextAudioFrame time: %fms", elapse1);
                _totalElapse1 += elapse1;
                
                if (buff != NULL) {
                    [audioBuffer appendBytes:buff->getBuffer() length:buff->getFrameSize()];
                    if (audioBuffer.length > MIN_SIZE_PER_FRAME) {
                        break;
                    }
                }
            }
            
            if (audioBuffer.length > 0) {
                [_pcmPl play:(void *)audioBuffer.bytes length:audioBuffer.length];
            }
            
            NSDate *end = [NSDate date];
            NSTimeInterval elapse = [end timeIntervalSinceDate:begin] * 1000;
            float duration = audioBuffer.length/4.0/format.getFrequency() * 1000;
            RunLog(@"[A]Get %lu, elapse: %fms, duration: %fms", (unsigned long)audioBuffer.length, elapse, duration);
            _totalElapse += elapse;
            _totalDuration += duration;
            _times1 ++;
        }
    }
    
    if (_pcmPl) {
        [_pcmPl stop];
    }
    _pcmPl = nil;
    
    AppLog(@"quit audio");
}

- (void)playVideo
{
    UIImage *receivedImage = nil;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    while (_PlaybackRun) {
        @autoreleasepool {
            
            if (_paused) {
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
            
            WifiCamAVData *wifiCamData = [_ctrl.propCtrl prepareDataForPlaybackVideoFrame];
            
            if (wifiCamData.data.length > 0) {
                self.curVideoPTS = wifiCamData.time;
                receivedImage = [[UIImage alloc] initWithData:wifiCamData.data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (receivedImage) {
                        if(self.ReadyPlay == YES)
                        {
                            [self stopVideoPb];
                            _PlaybackRun = NO;
                            mpbSegmentViewController.fileType = 0;
                        }
                        [self hideProgressHUD:YES];
                        mpbSegmentViewController.thumbImage = receivedImage;
                        mpbSegmentViewController.updatePreview;
                        
                    }
                });
                receivedImage = nil;
            }

        }
    }
    AppLog(@"quit video");
}


- (void)updateTimeInfo:(NSTimer *)sender {
#if 1
   
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        
         MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        if (!_seeking) {//durationSec
            if(/*self.totalSecs*/mpbSegmentViewController.SliderMaxValue == mpbSegmentViewController.seekvalue)
            {
                mpbSegmentViewController.NodePlayerSeekToZero;
                mpbSegmentViewController.updatePlayerStatusSetFalse;
                mpbSegmentViewController.NovatekPlayerStop;
                self.PlaybackRun = NO;
                self.played = NO;
                self.paused = YES;
                [_pbTimer invalidate];
            }
            else
            {
                if(mpbSegmentViewController.NovatekPlayerStatus){
                    mpbSegmentViewController.updateSeekBarValue;
                }
                else
                {
                    
                    NSLog(@"sdvsvd");
                }
            }
        } else {
            AppLog(@"seeking");
        }
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
         MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        if (!_seeking) {
                self.playedSecs = _curVideoPTS;
            
            
                float sliderPercent = _playedSecs/_totalSecs; // slider value
                dispatch_async(dispatch_get_main_queue(), ^{
                    mpbSegmentViewController.seekvalue = _playedSecs;
                    mpbSegmentViewController.updateSeekBarValue;
                   // _slideController.value = [@(_playedSecs) floatValue];
                    
                    if (sliderPercent > mpbSegmentViewController.getBufferValue) {
                        mpbSegmentViewController.BufferValue = sliderPercent;
                        mpbSegmentViewController.updateBufferSliderValue;
                    }
                    if(_totalSecs == _playedSecs)
                    {
                        mpbSegmentViewController.seekvalue = 0;
                    mpbSegmentViewController.updateSeekBarValue;
                        [self stopVideoPb];
                    }
                });
        } else {
            AppLog(@"seeking");
        }
    }
#endif
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if(indexPath == nil)
    {
        NSLog(@"long press on table viewbut not on a row ");
        
    }
    else
    {
        if(gestureRecognizer.state == UIGestureRecognizerStateBegan && (_LongPress == 0))
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            _LongPress = 1;
            [self edit:nil];
            //[self file_toolSwitchBT_clicked:(id)0];
            NSLog(@"long press");
        }
    }
}
/*ICatchFile file = _fileTable.fileList.at(indexPath.row);
 NSLog(@"vvvvvvvwwwwww");
 if (_curMpbState == MpbStateNor) {
 SEL callback = nil;
 
 switch (file.getFileType()) {
 case TYPE_IMAGE:
 callback = @selector(photoSinglePlaybackCallback:);
 break;
 
 case TYPE_VIDEO:
 callback = @selector(videoSinglePlaybackCallback:);
 break;
 
 default:
 break;
 }*/
- (void) setCellFileNameSize {
    //get videlist max filename lenght
    long lenght = 0;
    NSString *fileNameTemp = @"";
    NSString *fileNameTemp2 = @"";
    long int section;
    long int row;
    UIFont *font;
    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
        /*if(_curMpbMediaType == MpbMediaTypeVideo){
            [_FileVideoInfo setValue:currentElementValue forKey:@"VideoFullName"];
        }
        else{
            [_FilePhotoInfo setValue:currentElementValue forKey:@"PhotoFullName"];
        }*/
        if(_curMpbMediaType == MpbMediaTypePhoto) {
            section = [_tableview numberOfSections];
            for (int i = 0;i<section;i++) {
                row = [_tableview numberOfRowsInSection:i];
                for(int j=0;j<row;j++) {
                    if(lenght < [[[[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"PhotoName"] length]) {
                        lenght = [[[[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"PhotoName"] length];
                        fileNameTemp = [[[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"PhotoName"];
                    }
                }
            }
        } else {
            section = [_tableview numberOfSections];
            for (int i = 0;i<section;i++) {
                row = [_tableview numberOfRowsInSection:i];
                for(int j=0;j<row;j++) {
                    if(lenght < [[[[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"VideoName"] length]) {
                        lenght = [[[[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"VideoName"] length];
                        fileNameTemp = [[[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j] objectForKey:@"VideoName"];
                    }
                }
            }
        }
        NSLog(@"filename = %@",fileNameTemp);
        //set cell font size
        
        curFileNameSize = 18;
        updateCellFontSize = YES;
        section = [_tableview numberOfSections];
        for (int i = 0;i<section;i++) {
            row = [_tableview numberOfRowsInSection:i];
            for(int j=0;j<row;j++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                MpbTableViewCell *cell = (MpbTableViewCell *)[_tableview cellForRowAtIndexPath:ip];
                //adj font size
                [cell getCellLabel:0].adjustsFontSizeToFitWidth = YES;
                if(updateCellFontSize == YES &&
                   cell != nil) {
                    fileNameTemp2 = [cell getCellLabel:0].text;//保存
                    [cell setFileNameText:fileNameTemp];//設定最長的text
                    font = [mpbSegmentViewController adjFontSize:[cell getCellLabel:0]];//取最長的size
                    [cell setFileNameText:fileNameTemp2];//設定回原本的text
                    curFileNameSize = font.pointSize;
                    updateCellFontSize = NO;
                }
                [cell setCellLabelSize:curFileNameSize];
                //NSLog(@"filenamepointsize2  ->   %f",[cell getCellLabel:0].font.pointSize);
            }
        }
    } else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial) {
        //int index;// = [[[_FileListICatchPropertySort objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] intValue];
        //ICatchFile file = _fileTable.fileList.at(index);
        if(_curMpbMediaType == MpbMediaTypePhoto) {
            section = [_tableview numberOfSections];
            for (int i = 0;i<section;i++) {
                row = [_tableview numberOfRowsInSection:i];
                for(int j=0;j<row;j++) {
                    if(lenght < [[[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] intValue]) {
                        lenght = [[[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] intValue];
                        fileNameTemp = [[_FileListPhotoPropertySort objectAtIndex:i] objectAtIndex:j] ;
                    }
                }
            }
        } else {
            section = [_tableview numberOfSections];
            for (int i = 0;i<section;i++) {
                row = [_tableview numberOfRowsInSection:i];
                for(int j=0;j<row;j++) {
                    if(lenght < [[[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j] intValue]) {
                        lenght = [[[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j] intValue];
                        fileNameTemp = [[_FileListVideoPropertySort objectAtIndex:i] objectAtIndex:j];
                    }
                }
            }
        }
        curFileNameSize = 18;
        updateCellFontSize = YES;
        section = [_tableview numberOfSections];
        for (int i = 0;i<section;i++) {
            row = [_tableview numberOfRowsInSection:i];
            for(int j=0;j<row;j++) {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:j inSection:i];
                MpbTableViewCell *cell = (MpbTableViewCell *)[_tableview cellForRowAtIndexPath:ip];
                //adj font size
                [cell getCellLabel:0].adjustsFontSizeToFitWidth = YES;
                if(updateCellFontSize == YES &&
                   cell != nil) {
                    fileNameTemp2 = [cell getCellLabel:0].text;//保存
                    [cell setFileNameText:fileNameTemp];//設定最長的text
                    font = [mpbSegmentViewController adjFontSize:[cell getCellLabel:0]];//取最長的size
                    [cell setFileNameText:fileNameTemp2];//設定回原本的text
                    curFileNameSize = font.pointSize;
                    updateCellFontSize = NO;
                }
                [cell setCellLabelSize:curFileNameSize];
                //NSLog(@"filenamepointsize2  ->   %f",[cell getCellLabel:0].font.pointSize);
            }
        }
    }
    
}
- (void) downloadComplete_Novatek {
    [self tableViewCellEnable];
}
- (void) downloadFailed_Novatek {
    [self tableViewCellEnable];
}
@end
