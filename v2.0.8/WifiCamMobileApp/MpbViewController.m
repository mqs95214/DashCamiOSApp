//
//  CollectionViewController.m
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import "MpbSegmentViewController.h"
#import "MpbViewControllerPrivate.h"
#import "MpbViewController.h"
#include "UtilsMacro.h"
#import "MpbCollectionViewCell.h"
#import "MpbCollectionHeaderView.h"
#import "MpbPopoverViewController.h"
#import "MBProgressHUD.h"
#import "WifiCamControl.h"

#import "UIActivityItemImage.h"
#import "UIActivityItemVideo.h"

#import "UIActivityDownload.h"
#import "UIActivityFacebook.h"
#import "UIActivityTwitter.h"
#import "UIActivityWeibo.h"
#import "UIActivityTencentWeibo.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIActivityShare.h"
#import "DiskSpaceTool.h"
#import <SystemConfiguration/CaptiveNetwork.h>
static NSString *kCellID = @"cellID";
NSIndexPath *chooseIndex;

int download_totalLength;

@implementation MpbViewController

@synthesize observerNo;

+ (instancetype)mpbViewControllerWithIdentifier:(NSString *)identifier
{
    UIStoryboard *mainStoryboard;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    } else {
        mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    return [mainStoryboard instantiateViewControllerWithIdentifier:identifier];
}

#pragma mark - Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    databaseName = @"info";
    tableName = @"appsetting";
    [self initLanguage];
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    
    self.navigationController.toolbar.hidden = YES;
    
    observerNo=0;
    if(/*[_SSID containsString:@"C1GW"] || [_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {

    /*    NSLog(@"FileListArray = %@",[[self.FileList objectAtIndex:0] objectAtIndex:0]);
        NSLog(@"FileListArray = %@",[[self.FileList objectAtIndex:1] objectAtIndex:1]);
        NSLog(@"FileListArray = %@",[[self.FileList objectAtIndex:2] objectAtIndex:2]);*/
    }
    else
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.ctrl = _wifiCam.controler;
        self.staticData = [WifiCamStaticData instance];
    }
    [self initPhotoGallery];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.delegate = self;
}

- (void)initPhotoGallery
{
    AppLog(@"%s", __func__);
    self.navigationItem.leftBarButtonItem = self.doneButton;
    self.title = NSLocalizedString(@"Albums", @"");
    self.editButton.title = NSLocalizedString(@"Edit", @"");
    self.doneButton.title = NSLocalizedString(@"Done", @"");
    self.mpbSemaphore = dispatch_semaphore_create(1);
    self.thumbnailQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Thumbnail", 0);
    self.downloadQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Download", 0);
    self.downloadPercentQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.DownloadPercent", 0);
    self.collDataArray = [[NSMutableDictionary alloc] init];
    self.selItemsTable = [_ctrl.fileCtrl createOneCellsTable];
    self.mpbCache = [_ctrl.fileCtrl createCacheForMultiPlaybackWithCountLimit:100
                                                               totalCostLimit:4096];
    self.enableHeader = YES;
    self.loaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewWillAppear:animated];
   
    
   // NSData *data = [[NSData alloc] init];
    //UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 120, 100,100 )];
    if(/*[_SSID containsString:@"C1GW"] || [_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
        _FileListVideoName = [[NSMutableArray alloc] init];
        _FileListPhotoName = [[NSMutableArray alloc] init];
        _FileListVideoFullName = [[NSMutableArray alloc] init];
        _FileListPhotoFullName = [[NSMutableArray alloc] init];
        //FileListFullName = [[NSMutableArray alloc] init];
        _FileListVideoSize = [[NSMutableArray alloc] init];
        _FileListPhotoSize = [[NSMutableArray alloc] init];
        _FileListVideoTimeCode = [[NSMutableArray alloc] init];
        _FileListPhotoTimeCode = [[NSMutableArray alloc] init];
        _FileListVideoTime = [[NSMutableArray alloc] init];
        _FileListPhotoTime = [[NSMutableArray alloc] init];
        _FileListVideoLock = [[NSMutableArray alloc] init];
        _FileListPhotoLock = [[NSMutableArray alloc] init];
        _FileListVideoAttr = [[NSMutableArray alloc] init];
        _FileListPhotoAttr = [[NSMutableArray alloc] init];
        _FileListChooseItem = [[NSMutableArray alloc] init];
        _NvtFileWigth = [[NSString alloc] init];
        _NvtFileHeight = [[NSString alloc] init];
        _NvtFileLength = [[NSString alloc] init];
        //self.FileList = [[NSMutableArray alloc] init];
        //self.FileProperty = [[NSMutableArray alloc] init];
        [self NVTSendHttpCmd:@"3001" Par2:@"2"];
        [self NVTGetHttpCmd:@"3015"];
       // FileImformation = [self NVTGetHttpCmd:@"4005"];
       
       /* data = [self NVTGetFileThunbnailCmd:@"4001" FullFileName:@"PHOTO/2018_0714_171401_008.JPG"];
        UIImage *image = [UIImage imageWithData: data];
      //  @"A:\\PHOTO\\2018_0105_101530_001.JPG"
        imageview.image = image;
        [self.view addSubview:imageview];*/

    
    }
    //[self.navigationController setToolbarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recoverFromDisconnection)
                                             name    :@"kCameraNetworkConnectedNotification"
                                             object  :nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(destroySDKNotification)
                                             name    :@"kCameraDestroySDKNotification"
                                             object  :nil];
    self.run = YES;
    
    if (_curMpbState == MpbStateNor) {
        [_selItemsTable.selectedCells removeAllObjects];
        [self postButtonStateChangeNotification:NO];
    }
}

-(void)destroySDKNotification
{
    AppLog(@"receive destroySDKNotification.");
    self.run = NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    AppLog(@"%s", __func__);

    [super viewDidAppear:animated];
#if 1
    if (!_loaded) {
        [self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];
        
        // Get list and udpate collection-view
        dispatch_async(_thumbnailQueue, ^{
            
            [self resetCollectionViewData];

            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                self.loaded = YES;
                
                if (_totalCount > 0) {
                    _editButton.enabled = YES;
                    _actionButton.enabled = YES;
                } else {
                    _editButton.enabled = NO;
                    _actionButton.enabled = NO;
               
                }
                
                [self.collectionView reloadData];
            });
        });
    } else {
        if (_totalCount > 0) {
            _editButton.enabled = YES;
            _actionButton.enabled = YES;
        } else {
            _editButton.enabled = NO;
            _actionButton.enabled = NO;
        }
        
        [self.collectionView reloadData];
    }
#endif
}

- (void)resetCollectionViewData
{
    AppLog(@"%s listFiles start ...",__func__);


    if(/*[_SSID containsString:@"C1GW"] || [_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSUInteger videoListSize = [_FileListVideoSize count];
        NSUInteger photoListSize = [_FileListPhotoSize count];
        unsigned long long totalPhotoKBytes = 0;
        unsigned long long totalVideoKBytes = 0;
        unsigned long long totalAllKBytes = 0;
        for (NSString * str in _FileListPhotoSize)
        {
            totalPhotoKBytes += ([str intValue]/1000);
        }
        for (NSString * str in _FileListVideoSize)
        {
            totalVideoKBytes += ([str intValue]/1000);
        }
        totalAllKBytes = totalPhotoKBytes + totalVideoKBytes;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraAssetsListSizeNotification"
                                                            object:@[@(photoListSize), @(videoListSize)]];
        // Clean-up
        [_collDataArray removeAllObjects];
        if (_curMpbMediaType == MpbMediaTypePhoto) {
            SEL photoSinglePlaybackFunction = @selector(photoSinglePlaybackCallback:);
            NSDictionary *photoDict = @{@(SectionTitle): NSLocalizedString(@"Photos",nil),
                                        @(SectionType):@(WCFileTypeImage),
                                        @(SectionTotalFileKBytes):@(totalPhotoKBytes),
                                       @(SectionDataTable):@([_FileListPhotoName count]), @(SectionPlaybackCallback):NSStringFromSelector(photoSinglePlaybackFunction)};
            [_collDataArray setObject:photoDict forKey:@(0)];
            self.totalCount = photoListSize;
        } else {
            SEL videoSinglePlaybackFunction = @selector(videoSinglePlaybackCallback:);
            NSDictionary *videoDict = @{@(SectionTitle): NSLocalizedString(@"Videos",nil),
                                        @(SectionType):@(WCFileTypeVideo),
                                        @(SectionTotalFileKBytes):@(totalVideoKBytes),
                                      @(SectionDataTable):@([_FileListVideoName count]), @(SectionPlaybackCallback):NSStringFromSelector(videoSinglePlaybackFunction)};
            [_collDataArray setObject:videoDict forKey:@(0)];
            self.totalCount = videoListSize;
        }
    }
    else
    {
        _wifiCam.gallery = [WifiCamControl createOnePhotoGallery];
        self.gallery = _wifiCam.gallery;
        
        NSUInteger photoListSize = _gallery.imageTable.fileList.size();
        NSUInteger videoListSize = _gallery.videoTable.fileList.size();
        unsigned long long totalPhotoKBytes = _gallery.imageTable.fileStorage;
        unsigned long long totalVideoKBytes = _gallery.videoTable.fileStorage;
        unsigned long long totalAllKBytes = totalPhotoKBytes + totalVideoKBytes;
        
        /*AppLog(@"photoListSize: %lu", (unsigned long)photoListSize);
        AppLog(@"videoListSize: %lu", (unsigned long)videoListSize);
        AppLog(@"totalPhotoKBytes : %llu", totalPhotoKBytes);
        AppLog(@"totalVideoKBytes : %llu", totalVideoKBytes);
        AppLog(@"totalAllKBytes : %llu", totalAllKBytes);
        AppLog(@"listFiles end ...");*/
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraAssetsListSizeNotification"
                                                            object:@[@(photoListSize), @(videoListSize)]];
        // Clean-up
        [_collDataArray removeAllObjects];
        
        /*if (_enableHeader) {
         
         SEL photoSinglePlaybackFunction = @selector(photoSinglePlaybackCallback:);
         NSDictionary *photoDict = @{@(SectionTitle): NSLocalizedString(@"Photos",nil),
         @(SectionType):@(WCFileTypeImage),
         @(SectionDataTable):_gallery.imageTable,
         @(SectionTotalFileKBytes):@(totalPhotoKBytes),
         @(SectionPlaybackCallback):NSStringFromSelector(photoSinglePlaybackFunction)};
         [_collDataArray setObject:photoDict forKey:@(SectionIndexPhoto)];
         
         SEL videoSinglePlaybackFunction = @selector(videoSinglePlaybackCallback:);
         NSDictionary *videoDict = @{@(SectionTitle): NSLocalizedString(@"Videos",nil),
         @(SectionType):@(WCFileTypeVideo),
         @(SectionDataTable):_gallery.videoTable,
         @(SectionTotalFileKBytes):@(totalVideoKBytes),
         @(SectionPlaybackCallback):NSStringFromSelector(videoSinglePlaybackFunction)};
         [_collDataArray setObject:videoDict forKey:@(SectionIndexVideo)];
         } else {
         SEL allPlaybackFunction = @selector(allPlaybackCallback:);
         NSDictionary *photoDict = @{@(SectionTitle): NSLocalizedString(@"Photos",nil),
         @(SectionType):@(WCFileTypeAll),
         @(SectionDataTable):_gallery.allFileTable,
         @(SectionTotalFileKBytes):@(totalAllKBytes),
         @(SectionPlaybackCallback):NSStringFromSelector(allPlaybackFunction)};
         [_collDataArray setObject:photoDict forKey:@(0)];
         }*/
        if (_curMpbMediaType == MpbMediaTypePhoto) {
            SEL photoSinglePlaybackFunction = @selector(photoSinglePlaybackCallback:);
            NSDictionary *photoDict = @{@(SectionTitle): NSLocalizedString(@"Photos",nil),
                                        @(SectionType):@(WCFileTypeImage),
                                        @(SectionDataTable):_gallery.imageTable,
                                        @(SectionTotalFileKBytes):@(totalPhotoKBytes),
                                        @(SectionPlaybackCallback):NSStringFromSelector(photoSinglePlaybackFunction)};
            [_collDataArray setObject:photoDict forKey:@(0)];
            self.totalCount = photoListSize;
        } else {
            SEL videoSinglePlaybackFunction = @selector(videoSinglePlaybackCallback:);
            NSDictionary *videoDict = @{@(SectionTitle): NSLocalizedString(@"Videos",nil),
                                        @(SectionType):@(WCFileTypeVideo),
                                        @(SectionDataTable):_gallery.videoTable,
                                        @(SectionTotalFileKBytes):@(totalVideoKBytes),
                                        @(SectionPlaybackCallback):NSStringFromSelector(videoSinglePlaybackFunction)};
            [_collDataArray setObject:videoDict forKey:@(0)];
            self.totalCount = videoListSize;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewWillDisappear:animated];
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
    
    if (_selItemsTable.count > 0 || observerNo > 0 ) {
        [self.selItemsTable removeObserver:self forKeyPath:@"count"];
        --observerNo;
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    AppLog(@"%s", __func__);
    [super viewDidDisappear:animated];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraNetworkConnectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    AppLog(@"%s", __func__);
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_mpbCache removeAllObjects];
}

-(void)dealloc
{
    AppLog(@"%s", __func__);
    [_mpbCache removeAllObjects];
    self.doneButton = nil;
    
}

-(void)recoverFromDisconnection
{
    AppLog(@"%s", __func__);
    WifiCamManager *app = [WifiCamManager instance];
    self.wifiCam = [app.wifiCams objectAtIndex:0];
    self.ctrl = _wifiCam.controler;
    self.staticData = [WifiCamStaticData instance];
    
    [self.collectionView reloadData];
}

-(void) setEditStatus{
    NSLog(@"setEditStatus");
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
    //self.navigationController.toolbar.userInteractionEnabled = NO;
    if (message) {
        [self.view bringSubviewToFront:self.progressHUD];
        [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeText;
        self.progressHUD.dimBackground = YES;
        [self.progressHUD hide:YES afterDelay:time];
    } else {
        [self.progressHUD hide:YES];
    }
    //self.navigationController.navigationBar.userInteractionEnabled = NO;
    //self.navigationController.toolbar.userInteractionEnabled = YES;
    
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
    //self.navigationController.toolbar.userInteractionEnabled = YES;
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
    //self.navigationController.toolbar.userInteractionEnabled = NO;
    
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
    //self.navigationController.toolbar.userInteractionEnabled = YES;
    
}

#pragma mark - MPB
- (IBAction)gplayback_fullscreenBT_clickedoHome:(id)sender
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
}
- (IBAction)goHome:(id)sender
{
    AppLog(@"%s", __func__);
    self.run = NO;
    [self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                      detailsMessage:nil
                                mode:MBProgressHUDModeIndeterminate];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(_mpbSemaphore, time) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDCompleteMessage:NSLocalizedString(@"STREAM_WAIT_FOR_VIDEO", nil)];
            });
            
        } else {
            
            dispatch_semaphore_signal(_mpbSemaphore);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self dismissViewControllerAnimated:YES completion:^{
                    AppLog(@"MPB QUIT ...");
                }];
                
            });
        }
        
    });
}
- (IBAction)playback_fullscreenBT_clicked:(id)sender
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if(deviceOrientation == UIDeviceOrientationLandscapeLeft)
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
    }
    else
    {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }
}
- (IBAction)edit:(id)sender
{
    AppLog(@"%s", __func__);
    if (_curMpbState == MpbStateNor) {
        self.navigationItem.leftBarButtonItem = nil;
        self.title = NSLocalizedString(@"SelectItem", nil);
        self.curMpbState = MpbStateEdit;
        self.editButton.title = NSLocalizedString(@"Cancel", @"");
        self.editButton.style = UIBarButtonItemStyleDone;
        
        self.actionButton.enabled = NO;
        self.deleteButton.enabled = NO;
        [self.selItemsTable addObserver:self forKeyPath:@"count" options:0x0 context:nil];
        observerNo++;
        
    } else {
        if ([_ctrl.fileCtrl isBusy]) {
            // Cancel download
            self.cancelDownload = YES;
            [_ctrl.fileCtrl cancelDownload];
        }
        
        self.navigationItem.leftBarButtonItem = self.doneButton;
        self.title = NSLocalizedString(@"Albums", @"");
        self.curMpbState = MpbStateNor;
        self.editButton.title = NSLocalizedString(@"Edit", @"");
        
        if ([_popController isPopoverVisible]) {
            [_popController dismissPopoverAnimated:YES];
        }
        
        // Clear
        for (NSIndexPath *ip in _selItemsTable.selectedCells) {
            //      ICatchFile *file = (ICatchFile *)[[a lastObject] pointerValue];
            MpbCollectionViewCell *cell = (MpbCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
            [cell setSelectedConfirmIconHidden:YES];
            cell.tag = 0;
        }
        if (!_cancelDownload) {
            [_selItemsTable.selectedCells removeAllObjects];
        }
        
        self.selItemsTable.count = 0;
        [self.selItemsTable removeObserver:self forKeyPath:@"count"];
        --observerNo;
        self.totalDownloadSize = 0;
        _isSend = NO;
    }
    AppLog(@"%s, curMpbState: %d", __func__, _curMpbState);;
}

- (IBAction)play:(id)sender
{
   
    NSData *data = [[NSData alloc] init];
    
    if(chooseIndex){
        /*[self showProgressHUDWithMessage:[self getStringForKey:@"Playing" withTable:@""]
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];*/
        [self showProgressHUDWithMessage:@""
                          detailsMessage:nil
                                    mode:MBProgressHUDModeIndeterminate];
        if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
           [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            UIImage *image;
            NSString *Fpath;
            
            NSString *FileInformation;
            _videoPlaybackIndex = chooseIndex.item;

            
            int sectionType = [[[_collDataArray objectForKey:@(chooseIndex.section)] objectForKey:@(SectionType)] intValue];
            switch (sectionType) {
                case TYPE_IMAGE:
                    Fpath = @"PHOTO/";
                    break;
                    
                case TYPE_VIDEO:
                    if([[_FileListVideoLock objectAtIndex:chooseIndex.item] isEqualToString:@"1"])
                    {
                        if([_SSID isEqualToString:@"D200GW"])
                        {
                            Fpath = @"PROTECTED/";
                        }
                        else{
                            Fpath = @"VIDEO/";
                        }
                    }
                    else
                    {
                        Fpath = @"VIDEO/";
                    }
                    break;
                    
                default:
                    break;
            }
            if(sectionType == 0x01){
                _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:chooseIndex.item]];
                
                data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                /*FileInformation = [self NVTGetFileInformationCmd:@"4005" FullFileName:_NvtThumbnilPath];
                _NvtFileWigth = [FileInformation substringWithRange:NSMakeRange(6, 9)];
                _NvtFileHeight = [FileInformation substringWithRange:NSMakeRange(19, 22)];*/

            }
            else{
                _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:chooseIndex.item]];
                data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
                /*FileInformation = [self NVTGetFileInformationCmd:@"4005" FullFileName:_NvtThumbnilPath];
                _NvtFileWigth = [FileInformation substringWithRange:NSMakeRange(6, 4)];
                _NvtFileHeight = [FileInformation substringWithRange:NSMakeRange(19, 4)];
                NSRange searchResult = [FileInformation rangeOfString:@"sec"];
                _NvtFileLength = [FileInformation substringWithRange:NSMakeRange(32, searchResult.location-1-32)];*/
                

            }
            
            image = [UIImage imageWithData: data];
            _videoPlaybackThumb = image;
            [self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
        }
        else
        {
            if (![_ctrl.fileCtrl isVideoPlaybackEnabled]) {
                [self showProgressHUDNotice:NSLocalizedString(@"ShowNoViewVideoTip", nil) showTime:1.0];
                return;
            }
        
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(chooseIndex.section)] objectForKey:@(SectionDataTable)];
            ICatchFile file = fileTable.fileList.at(chooseIndex.item);
        
            NSString *cachedKey = [NSString stringWithFormat:@"ID%d", file.getFileHandle()];
            _videoPlaybackIndex = chooseIndex.item;
        
            UIImage *image = [_mpbCache objectForKey:cachedKey];
            if (!image) {
                dispatch_suspend(_thumbnailQueue);
            
                [self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                              detailsMessage:nil
                                        mode:MBProgressHUDModeIndeterminate];
            
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    if (!_run) {
                        return;
                    }
                
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                    dispatch_semaphore_wait(_mpbSemaphore, time);
                
                    UIImage *image = [_ctrl.fileCtrl requestThumbnail:(ICatchFile *)&file];
                    if (image != nil) {
                        [_mpbCache setObject:image forKey:cachedKey];
                    }
                    dispatch_semaphore_signal(_mpbSemaphore);
                    dispatch_resume(_thumbnailQueue);
                
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                    
                        _videoPlaybackThumb = image;
                        [self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
                    });
                });
            } else {
                _videoPlaybackThumb = image;
                [self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
            }
        }
    }
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
                    if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
                       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial){
                        [self NvtdownloadDetail:item];
                    }
                    else
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
    __block NSString *Fpath,*NvtRealPath;
    dispatch_queue_t concurrentQueue;
    NSSortDescriptor *sort;
    sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [_FileListChooseItem sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    
    
    long int ChooseNumber = [[_FileListChooseItem objectAtIndex:FileNumber] row];
    /*dispatch_async(concurrentQueue, ^{
    do {
            
    } while (_downloadFileProcessing);
        
    });*/
    
        if(_curMpbMediaType == MpbMediaTypeVideo)
        {
            Fpath = @"VIDEO/";
            NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
        }
        else
        {
            Fpath = @"PHOTO/";
            NvtRealPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:ChooseNumber]];
        }
    

    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/",NvtRealPath];
    NSURL *url = [NSURL URLWithString:fullcmd];
    NSURLRequest *reques = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:reques delegate:self];
    /*if([ssid containsString:@"C1GW"] || [ssid containsString:@"S2"]||[ssid containsString:@"D200GW"])
    {
        NSSortDescriptor *sort;
        sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
        [_FileListChooseItem sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];

       // for(int i = 0;i<_FileListChooseItem.count;i++)
        {
            long int ChooseNumber = [[_FileListChooseItem objectAtIndex:0] row];
            if([[_FileListVideoName objectAtIndex:ChooseNumber] containsString:@".MOV"])
            {
                Fpath = @"VIDEO/";
            }
            else
            {
                Fpath = @"PHOTO/";
            }
            NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
            [self NvtSendFileDownload:NvtRealPath];
        }
    }*/
    /*long int ChooseNumber = [[_FileListChooseItem objectAtIndex:0] row];
    if([[_FileListVideoName objectAtIndex:ChooseNumber] containsString:@".MOV"])
    {
        Fpath = @"VIDEO/";
    }
    else
    {
        Fpath = @"PHOTO/";
    }
    NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
    [self NvtSendFileDownload:NvtRealPath];
    /*fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/",NvtRealPath];
    NSURL *url = [NSURL URLWithString:fullcmd];
    NSURLRequest *reques = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:reques delegate:self];*/
    //__block NSString *groupName = [self groupName];
    
}
-(void)showActivityViewController:(NSArray *)activityItems
                         delegate:(id <ActivityWrapperDelegate>)delegate
{
    AppLog(@"%s", __func__);
    UIActivityDownload *download = [[UIActivityDownload alloc] initWithDelegate:delegate];
    UIActivityShare *share = [[UIActivityShare alloc] initWithDelegate:delegate];
    UIActivityFacebook *facebook = [[UIActivityFacebook alloc] initWithDelegate:delegate];
    UIActivityTwitter *twitter = [[UIActivityTwitter alloc] initWithDelegate:delegate];
    UIActivityWeibo *weibo = [[UIActivityWeibo alloc] initWithDelegate:delegate];
    UIActivityTencentWeibo *tWeibo = [[UIActivityTencentWeibo alloc] initWithDelegate:delegate];
    //    UIActivityWechatSession *wechatSession = [[UIActivityWechatSession alloc] initWithDelegate:delegate];
    //    UIActivityWechatTimeline *wechatMoments = [[UIActivityWechatTimeline alloc] initWithDelegate:delegate];
    //    UIActivityWechatFavorite *wechatFavorite = [[UIActivityWechatFavorite alloc] initWithDelegate:delegate];
    //    UIActivityQQ *qq = [[UIActivityQQ alloc] initWithDelegate:delegate];
    //    UIActivityEmail *email = [[UIActivityEmail alloc] initWithDelegate:delegate];
    NSArray *appActivities = @[download, share, facebook, twitter, weibo, tWeibo/*, wechatSession, wechatMoments, wechatFavorite, qq, email*/];
    self.activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                    applicationActivities:appActivities];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        self.activityViewController.popoverPresentationController.barButtonItem = _actionButton;
    }
    
    // Exclude
    /*
     self.activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,
     UIActivityTypePostToTwitter,
     UIActivityTypePostToWeibo,
     UIActivityTypeMessage,
     UIActivityTypeMail,
     UIActivityTypePrint,
     UIActivityTypeCopyToPasteboard,
     UIActivityTypeAssignToContact,
     UIActivityTypeSaveToCameraRoll,
     UIActivityTypeAddToReadingList,
     UIActivityTypePostToFlickr,
     UIActivityTypePostToVimeo,
     UIActivityTypePostToTencentWeibo,
     UIActivityTypeAirDrop];
     */
    [self presentViewController:_activityViewController animated:YES completion:nil];
}

//LaunchServices: invalidationHandler called
-(void)_showSLComposeViewController:(NSString *)serviceType {
    AppLog(@"%s", __func__);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        SLComposeViewController *SLComposeSheet = nil;
        
        SLComposeSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [SLComposeSheet removeAllImages];
        [SLComposeSheet removeAllURLs];
        
        // Downloading
        for (NSIndexPath *ip in _selItemsTable.selectedCells) {
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
            ICatchFile f = fileTable.fileList.at(ip.item);
            switch (f.getFileType()) {
                case TYPE_IMAGE: {
                    AppLog(@"Request image...");
                    UIImage *sharedImage = [_ctrl.fileCtrl requestImage:&f];
                    [SLComposeSheet addImage:sharedImage];
                    
                }
                    break;
                    
                case TYPE_VIDEO:
                    break;
                default:
                    break;
            }
        }
        
        // Done
        [SLComposeSheet setInitialText:@"Shared image from WifiCamMobileApp"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:NO];
            [self presentViewController:SLComposeSheet animated:YES completion: nil];
        });
    });
}

-(void)showSLComposeViewController:(NSString *)serviceType
{
    AppLog(@"%s", __func__);
    [self showProgressHUDWithMessage:nil detailsMessage:nil mode:MBProgressHUDModeIndeterminate];
    AppLog(@"serviceType: %@", serviceType);
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_activityViewController dismissViewControllerAnimated:YES completion:nil];
        [self _showSLComposeViewController:serviceType];
    } else {
        [_activityViewController dismissViewControllerAnimated:YES completion:^{
            [self _showSLComposeViewController:serviceType];
        }];
    }
    
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

-(void)showDownloadConfirm
{
    AppLog(@"%s", __func__);
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    NSInteger fileNum = 0;
    unsigned long long downloadSizeInKBytes = 0;
    NSString *confrimButtonTitle = nil;
    NSString *message = nil;
    double freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    
    if (_curMpbState == MpbStateEdit) {
        
        if (_totalDownloadSize < freeDiscSpace/2.0) {
            message = [self makeupDownloadMessageWithSize:_totalDownloadSize
                                                andNumber:_selItemsTable.count];
            confrimButtonTitle = NSLocalizedString(@"SureDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:_totalDownloadSize];
        }
        
    } else {
        
        for (int i =0; i<_collDataArray.count; ++i) {
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(i)] objectForKey:@(SectionDataTable)];
            fileNum += fileTable.fileList.size();
            downloadSizeInKBytes += [[[_collDataArray objectForKey:@(i)] objectForKey:@(SectionTotalFileKBytes)] longLongValue];
        }
        
        if (downloadSizeInKBytes < freeDiscSpace) {
            message = [self makeupDownloadMessageWithSize:downloadSizeInKBytes
                                                andNumber:fileNum];
            confrimButtonTitle = NSLocalizedString(@"AllDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:downloadSizeInKBytes];
        }
        
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_activityViewController dismissViewControllerAnimated:YES completion:nil];
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    } else {
        [_activityViewController dismissViewControllerAnimated:YES completion:^{
            [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
        }];
    }
}

-(void)showShareConfirm
{
    AppLog(@"%s", __func__);
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
    if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        freeDiscSpace = [[self NvtDiskFreeSpace:@"3017"] doubleValue];
    }
    else
    {
        freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
    }

    
    if (_curMpbState == MpbStateEdit) {
        
        if (_totalDownloadSize < freeDiscSpace/2.0) {
            if(/*[_SSID containsString:@"C1GW"] || [_SSID containsString:@"D200GW"]*/
               [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
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
        
        for (int i =0; i<_collDataArray.count; ++i) {
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(i)] objectForKey:@(SectionDataTable)];
            fileNum += fileTable.fileList.size();
            downloadSizeInKBytes += [[[_collDataArray objectForKey:@(i)] objectForKey:@(SectionTotalFileKBytes)] longLongValue];
        }
        
        if (downloadSizeInKBytes < freeDiscSpace) {
            message = [self makeupDownloadMessageWithSize:downloadSizeInKBytes
                                                andNumber:fileNum];
            confrimButtonTitle = NSLocalizedString(@"AllDownload", @"");
        } else {
            message = [self makeupNoDownloadMessageWithSize:downloadSizeInKBytes];
        }
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [_activityViewController dismissViewControllerAnimated:YES completion:nil];
        [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
    } else {
        [_activityViewController dismissViewControllerAnimated:YES completion:^{
            [self _showDownloadConfirm:message title:confrimButtonTitle dBytes:downloadSizeInKBytes fSpace:freeDiscSpace];
        }];
    }
    //    for (int i =0; i<_collDataArray.count; ++i) {
    //        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(i)] objectForKey:@(SectionDataTable)];
    //        fileNum += fileTable.fileList.size();
    //        downloadSizeInKBytes += [[[_collDataArray objectForKey:@(i)] objectForKey:@(SectionTotalFileKBytes)] longLongValue];
    //    }
    //
    //    if (downloadSizeInKBytes < freeDiscSpace) {
    //        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
    //            [_activityViewController dismissViewControllerAnimated:YES completion:nil];
    //            [self downloadDetail:sender];
    //
    //        } else {
    //            [_activityViewController dismissViewControllerAnimated:YES completion:^{
    //                [self downloadDetail:sender];
    //            }];
    //        }
    //    }
}

//- (void)showShareConfirm
//{
//    AppLog(@"%s", __func__);
//    if (_popController.popoverVisible) {
//        [_popController dismissPopoverAnimated:YES];
//    }
//
//    [self showProgressHUDWithMessage:@"请稍候 ..."];
//
//    dispatch_queue_t shareQueue = dispatch_queue_create("WifiCam.GCD.Queue.Playback.Share", 0);
//
//    dispatch_async(shareQueue, ^{
//        NSArray *shareArray = [self shareSelectedFiles];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self hideProgressHUD:YES];
//            [self showUIActivityViewController:shareArray];
//        });
//    });
//}

// fixed BSP-1242 issue
- (int)videoAtPathIsCompatibleWithSavedPhotosAlbum:(int)saveNum {
    if (self.shareFileType != nil && self.shareFileType.count > 0) {
        ICatchFileType fileType = (ICatchFileType)[self.shareFileType.firstObject intValue];
        if (fileType != TYPE_VIDEO) {
            return saveNum;
        }
    } else {
        return saveNum;
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
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    uint shareNum = (uint)[self.shareFiles count];
    uint assetNum = (uint)[[SDK instance] retrieveCameraRollAssetsResult].count;
    
    if (shareNum && self.shareFileType != nil && self.shareFileType.count > 0) {
        UIActivityViewController *activityVc = [[UIActivityViewController alloc]initWithActivityItems:self.shareFiles applicationActivities:nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:activityVc animated:YES completion:nil];
        } else {
            // Create pop up
            UIPopoverController *activityPopoverController = [[UIPopoverController alloc] initWithContentViewController:activityVc];
            // Show UIActivityViewController in popup
            //                    [activityPopoverController presentPopoverFromRect:CGRectZero inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
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
    /*
     NSString *message = NSLocalizedString(@"DownloadConfirmMessage", nil);
     NSString *humanDownloadFileSize = [_ctrl.comCtrl translateSize:sizeInKB];
     
     double downloadTime = (double)sizeInKB/1024/60;
     message = [message stringByReplacingOccurrencesOfString:@"%1"
     withString:[NSString stringWithFormat:@"%ld", (long)num]];
     message = [message stringByReplacingOccurrencesOfString:@"%2"
     withString:[NSString stringWithFormat:@"%.2f", downloadTime]];
     message = [message stringByAppendingString:[NSString stringWithFormat:@"\n%@", humanDownloadFileSize]];
     return message;
     */
    
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

- (IBAction)actionButtonPressed:(id)sender
{
  
    AppLog(@"%s", __func__);
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    /*
     NSInteger fileNum = 0;
     unsigned long long downloadSizeInKBytes = 0;
     NSString *confrimButtonTitle = nil;
     NSString *message = nil;
     double freeDiscSpace = [_ctrl.comCtrl freeDiskSpaceInKBytes];
     
     if (_curMpbState == MpbStateEdit) {
     if (_totalDownloadSize < freeDiscSpace) {
     message = [self makeupDownloadMessageWithSize:_totalDownloadSize
     andNumber:_selItemsTable.count];
     confrimButtonTitle = NSLocalizedString(@"SureDownload", @"");
     } else {
     message = [self makeupNoDownloadMessageWithSize:_totalDownloadSize];
     }
     
     } else {
     
     for (int i =0; i<_collDataArray.count; ++i) {
     WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(i)] objectForKey:@(SectionDataTable)];
     fileNum += fileTable.fileList.size();
     downloadSizeInKBytes += [[[_collDataArray objectForKey:@(i)] objectForKey:@(SectionTotalFileKBytes)] longLongValue];
     }
     
     if (downloadSizeInKBytes < freeDiscSpace) {
     message = [self makeupDownloadMessageWithSize:downloadSizeInKBytes
     andNumber:fileNum];
     confrimButtonTitle = NSLocalizedString(@"AllDownload", @"");
     } else {
     message = [self makeupNoDownloadMessageWithSize:downloadSizeInKBytes];
     }
     
     }
     */
    if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else
    {
        NSMutableArray *items = [[NSMutableArray alloc] init];
        for (NSIndexPath *ip in _selItemsTable.selectedCells) {
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
            ICatchFile f = fileTable.fileList.at(ip.item);
            switch (f.getFileType()) {
                case TYPE_IMAGE: {
                    UIActivityItemImage *sharedImage = [[UIActivityItemImage alloc] init];
                    //                UIImage *sharedImage = [[UIImage alloc] init];
                    [items addObject:sharedImage];
                }
                    break;
                    
                case TYPE_VIDEO: {
                    UIActivityItemVideo *sharedVideo = [[UIActivityItemVideo alloc] init];
                    [items addObject:sharedVideo];
                }
                    break;
                default:
                    break;
            }
        }
    }
    
    //    [self showActivityViewController:items delegate:self];
    //    [self showUIActivityViewController:sender];
    //    [self showShareConfirm:sender];
    [self showShareConfirm];
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
    
    dispatch_async(_downloadPercentQueue, ^{
        do {
            @autoreleasepool {
                if (_cancelDownload) break;
                //self.downloadedPercent = [_ctrl.fileCtrl requestDownloadedPercent:f];
                self.downloadedPercent = [_ctrl.fileCtrl requestDownloadedPercent2:locatePath
                                                                          fileSize:fileSize];
                AppLog(@"percent: %lu", (unsigned long)self.downloadedPercent);
                
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
            fileList = _gallery.imageTable.fileList;
            break;
            
        case WCFileTypeVideo:
            fileList = _gallery.videoTable.fileList;
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
//        self.downloadedFileNumber = [_ctrl.fileCtrl retrieveDownloadedTotalNumber];
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

- (NSArray *)downloadSelectedFiles
{
    AppLog(@"%s", __func__);
    NSInteger downloadedPhotoNum = 0, downloadedVideoNum = 0;
    NSInteger downloadFailedCount = 0;
    
    if (![[SDK instance] openFileTransChannel]) {
        return nil;
    }
    
    for (NSIndexPath *ip in _selItemsTable.selectedCells) {
        if (_cancelDownload) break;
        
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
        ICatchFile f = fileTable.fileList.at(ip.item);
        
        self.downloadFileProcessing = YES;
        self.downloadedPercent = 0;//Before the download clear downloadedPercent and increase downloadedFileNumber.
        //        self.downloadedFileNumber = [_ctrl.fileCtrl retrieveDownloadedTotalNumber];
        self.downloadedFileNumber ++;
        [self requestDownloadPercent:&f];
        //        if (![_ctrl.fileCtrl downloadFile2:&f]) {
        //            ++downloadFailedCount;
        //            self.downloadFileProcessing = NO;
        //            continue;
        //        }
        if (![[SDK instance] p_downloadFile2:&f]) {
            ++downloadFailedCount;
            self.downloadFileProcessing = NO;
            continue;
        }
        
        self.downloadFileProcessing = NO;
        [NSThread sleepForTimeInterval:0.5];
        
        switch (f.getFileType()) {
            case TYPE_IMAGE:
                ++downloadedPhotoNum;
                [self.shareFileType addObject:[NSNumber numberWithInt:TYPE_IMAGE]];
                break;
                
            case TYPE_VIDEO:
                ++downloadedVideoNum;
                [self.shareFileType addObject:[NSNumber numberWithInt:TYPE_VIDEO]];
                break;
                
            case TYPE_TEXT:
            case TYPE_AUDIO:
            case TYPE_ALL:
            case TYPE_UNKNOWN:
            default:
                break;
        }
        
        [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
    }
    
    if (![[SDK instance] closeFileTransChannel]) {
        return nil;
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
        if (![[SDK instance] p_downloadFile2:&f]) {
            ++downloadFailedCount;
            self.downloadFileProcessing = NO;
            continue;
        }
        
        self.downloadFileProcessing = NO;
        [NSThread sleepForTimeInterval:0.5];
        
        switch (f.getFileType()) {
            case TYPE_IMAGE:
                ++(*downloadedPhotoNum);
                [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                [self.shareFileType addObject:[NSNumber numberWithInt:TYPE_IMAGE]];
                //                [self.shareFiles addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
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

- (NSArray *)shareSelectedFiles
{
    AppLog(@"%s", __func__);
    NSInteger downloadedPhotoNum = 0, downloadedVideoNum = 0;
    NSInteger downloadFailedCount = 0;
    
    WifiCamFileTable *fileTable = nil;
    ICatchFile f = NULL;
    NSString *fileName = nil;
    NSArray *tmpDirectoryContents = nil;
    
    if (![[SDK instance] openFileTransChannel]) {
        return nil;
    }
    
    for (NSIndexPath *ip in _selItemsTable.selectedCells) {
        if (_cancelDownload) break;
        
        fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
        f = fileTable.fileList.at(ip.item);
        
        fileName = [NSString stringWithUTF8String:f.getFileName().c_str()];
        tmpDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];//獲取所有子文件
        
        self.downloadFileProcessing = YES;
        self.downloadedPercent = 0;//Before the download clear downloadedPercent and increase downloadedFileNumber.
        //        self.downloadedFileNumber = [_ctrl.fileCtrl retrieveDownloadedTotalNumber];
        
        if (tmpDirectoryContents.count) {
            for (NSString *name in tmpDirectoryContents) {
                if ([name isEqualToString:fileName]) {
                    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                    long long tempSize = [DiskSpaceTool fileSizeAtPath:filePath];
                    long long fileSize = f.getFileSize();
                    
                    if (tempSize == fileSize) {
                        [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                        [self.shareFileType addObject:[NSNumber numberWithInt:f.getFileType()]];
                        //                    if (f.getFileType() == TYPE_VIDEO) {
                        //                        [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                        //                    } else if (f.getFileType() == TYPE_IMAGE) {
                        //                        [self.shareFiles addObject:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), [NSString stringWithUTF8String:f.getFileName().c_str()]]]];
                        //                    }
                    } else {
                        [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
                    }
                    break;
                } else if ([name isEqualToString:[tmpDirectoryContents lastObject]]) {
                    [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
                }
            }
        } else {
            [self downloadSelectedFile:f andFailedCount:(&downloadFailedCount) andPhotoCount:(&downloadedPhotoNum) andVideoCount:(&downloadedVideoNum)];
        }
    }
    
    if (![[SDK instance] closeFileTransChannel]) {
        return nil;
    }
    
    [_ctrl.fileCtrl resetDownoladedTotalNumber];
    return [NSArray arrayWithObjects:@(downloadedPhotoNum), @(downloadedVideoNum), @(downloadFailedCount), nil];
}

//- (NSArray *)shareSelectedFiles:(id)sender
//{
//    AppLog(@"%s", __func__);
//
//    NSMutableArray *shareFiles = [NSMutableArray array];
//    WifiCamFileTable *fileTable = nil;
//    ICatchFile f = NULL;
//    NSString *fileName = nil;
//    NSArray *tmpDirectoryContents = nil;
//
//    for (NSIndexPath *ip in _selItemsTable.selectedCells) {
//        if (_cancelDownload) break;
//
//        fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
//        f = fileTable.fileList.at(ip.item);
//
//        fileName = [NSString stringWithUTF8String:f.getFileName().c_str()];
//        tmpDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:nil];
//
//        if (tmpDirectoryContents.count) {
//            for (NSString *name in tmpDirectoryContents) {
//                if ([name isEqualToString:fileName]) {
//                    [self.shareFiles addObject:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), fileName]]];
//                    [self showUIActivityViewController:sender];
//                    break;
//                } else if ([name isEqualToString:[tmpDirectoryContents lastObject]]) {
//                    [self showDownloadShareFiles:sender];
//                }
//            }
//        } else {
//            [self showDownloadShareFiles:sender];
//        }
//    }
//
//    return shareFiles;
//}

- (IBAction)downloadDetail:(id)sender
{
    AppLog(@"%s", __func__);
    if ([sender isKindOfClass:[UIButton self]]) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    self.cancelDownload = NO;
    
    // Prepare
    if (_curMpbState == MpbStateNor) {
        self.navigationItem.leftBarButtonItem = nil;
        self.editButton.title = NSLocalizedString(@"Cancel", @"");
        self.editButton.style = UIBarButtonItemStyleDone;
        [self.selItemsTable addObserver:self forKeyPath:@"count" options:0x0 context:nil];
        observerNo++;
        self.totalDownloadFileNumber = _totalCount;
    } else {
        self.totalDownloadFileNumber = _selItemsTable.selectedCells.count;
    }
    self.actionButton.enabled = NO;
    self.deleteButton.enabled = NO;
    self.downloadedFileNumber = 0;
    self.downloadedPercent = 0;
    [self addObserver:self forKeyPath:@"downloadedFileNumber" options:0x0 context:nil];
    [self addObserver:self forKeyPath:@"downloadedPercent" options:NSKeyValueObservingOptionNew context:nil];
    NSUInteger handledNum = MIN(_downloadedFileNumber, _totalDownloadFileNumber);
    NSString *msg = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)handledNum, (unsigned long)_totalDownloadFileNumber];
    
    // Show processing notice
    if (!handledNum) {
        //        [self showProgressHUDWithMessage:@"请稍候 ..."];
        [self showProgressHUDWithMessage:@"请稍候 ..."
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
    } else {
        [self showProgressHUDWithMessage:msg
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
    }
    // Just in case, _selItemsTable.selectedCellsn wouldn't be destoried after app enter background
    [_ctrl.fileCtrl tempStoreDataForBackgroundDownload:_selItemsTable.selectedCells];
    
    dispatch_async(_downloadQueue, ^{
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
            
            [self showUIActivityViewController:self.actionButton];
            // Clear
            for (NSIndexPath *ip in _selItemsTable.selectedCells) {
                MpbCollectionViewCell *cell = (MpbCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:ip];
                [cell setSelectedConfirmIconHidden:YES];
                cell.tag = 0;
            }
            [_selItemsTable.selectedCells removeAllObjects];
            self.selItemsTable.count = 0;
            [self postButtonStateChangeNotification:NO];
            
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
        });
        
        [_ctrl.fileCtrl resetBusyToggle:NO];
        [[UIApplication sharedApplication] endBackgroundTask:downloadTask];
    });
}

- (IBAction)delete:(id)sender
{
    AppLog(@"%s", __func__);
    if (_popController.popoverVisible) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    NSString *replaceString;
    NSString *message = NSLocalizedString(@"DeleteMultiAsk", nil);
    if(/*[_SSID containsString:@"C1GW"] || [_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)_selItemsTable.count];
    }
    else
    {
        replaceString = [NSString stringWithFormat:@"%ld", (long)_FileListChooseItem.count];
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
}
- (IBAction)LockAction:(id)sender
{
    NSString *Fpath;
    NSString *NvtRealPath;
    if(self.ChooseItemcount > 5)
    {
        [self showProgressHUDNotice:@"Choose Over"
                           showTime:1.0];
    }
    else
    {
        [self showProgressHUDWithMessage:nil];
        for(int i = 0;i<[_FileListChooseItem count];i++)
        {
            int ChooseNumber = [[_FileListChooseItem objectAtIndex:i] row];
            if(_curMpbMediaType == MpbMediaTypeVideo)
            {
                Fpath = @"VIDEO/";
                NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
                [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"1"];
            }
            else
            {
                 Fpath = @"PHOTO/";
                NvtRealPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:ChooseNumber]];
                [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"1"];
            }
            
            
            //NSLog(@"choose item position is:%ld",(long)[[_FileListChooseItem objectAtIndex:i] row]);
        }
        [self hideProgressHUD:YES];
        [self showProgressHUDNotice:@"Files Lock"
                           showTime:1.0];
    }

}
- (IBAction)UnLockAction:(id)sender
{
    NSString *Fpath;
    NSString *NvtRealPath;
    if(self.ChooseItemcount > 5)
    {
        [self showProgressHUDNotice:@"Choose Over"
                           showTime:1.0];
    }
    else
    {
        [self showProgressHUDWithMessage:nil];
        for(int i = 0;i<[_FileListChooseItem count];i++)
        {
            int ChooseNumber = [[_FileListChooseItem objectAtIndex:i] row];
            if(_curMpbMediaType == MpbMediaTypeVideo)
            {
                Fpath = @"VIDEO/";
                NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
                [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"0"];
            }
            else
            {
                Fpath = @"PHOTO/";
                NvtRealPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:ChooseNumber]];
                [self NvtSendFileLock:@"4006" FullFileName:NvtRealPath parameter:@"0"];
            }
           
            
            //NSLog(@"choose item position is:%ld",(long)[[_FileListChooseItem objectAtIndex:i] row]);
        }
        [self hideProgressHUD:YES];
        [self showProgressHUDNotice:@"Files UnLock"
                           showTime:1.0];
    }
}
- (IBAction)deleteDetail:(id)sender
{
    AppLog(@"%s", __func__);
 

    __block int failedCount = 0;
    __block NSString *Fpath;
    __block NSString *NvtRealPath;
    if ([sender isKindOfClass:[UIButton self]]) {
        [_popController dismissPopoverAnimated:YES];
    }
    
    self.run = NO;
    [self showProgressHUDWithMessage:NSLocalizedString(@"Deleting", nil)
                      detailsMessage:nil
                                mode:MBProgressHUDModeIndeterminate];
    
    //  NSMutableArray *toDeletedIndexPaths = [[NSMutableArray alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachedKey = nil;
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        dispatch_semaphore_wait(_mpbSemaphore, time);
        
        // Real delete icatch file & remove NSCache item
        if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
           [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            
            NSSortDescriptor *sort;
            sort = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
            [_FileListChooseItem sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
            
            for(int i = 0;i<_FileListChooseItem.count;i++)
            {
                long int ChooseNumber = [[_FileListChooseItem objectAtIndex:i] row];
                if(_curMpbMediaType == MpbMediaTypePhoto)
                {
                    Fpath = @"PHOTO/";
                    NvtRealPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:ChooseNumber]];
                    [self NvtSendFileDelete:@"4003" FullFileName:NvtRealPath];
                }
                else
                {
                    Fpath = @"VIDEO/";
                    NvtRealPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:ChooseNumber]];
                    [self NvtSendFileDelete:@"4003" FullFileName:NvtRealPath];
                }
                

                if(_curMpbMediaType == MpbMediaTypeVideo)
                {
                    [_FileListVideoName removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoFullName removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoSize removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoTimeCode removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoTime removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoLock removeObjectAtIndex:ChooseNumber];
                    [_FileListVideoAttr removeObjectAtIndex:ChooseNumber];
                }
                else
                {
                    [_FileListPhotoName removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoFullName removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoSize removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoTimeCode removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoTime removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoLock removeObjectAtIndex:ChooseNumber];
                    [_FileListPhotoAttr removeObjectAtIndex:ChooseNumber];
                }
                
            }
            [_FileListChooseItem removeAllObjects];
            [self resetCollectionViewData];
            dispatch_semaphore_signal(_mpbSemaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
            //[_selItemsTable.selectedCells removeAllObjects];
            [self postButtonStateChangeNotification:NO];
            self.run = YES;
            [self.collectionView reloadData];
                
            NSString *noticeMessage = nil;

            //noticeMessage = NSLocalizedString(@"DeleteDoneMessage", nil);
                
            //[self showProgressHUDCompleteMessage:noticeMessage];
                //            self.selItemsTable.count = 0;
            });
        }
        else
        {
            for (NSIndexPath *ip in _selItemsTable.selectedCells)
            {
                //      int type = [[a objectAtIndex:1] intValue];

                WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
                ICatchFile f = fileTable.fileList.at(ip.item);
                //ICatchFile *file = (ICatchFile *)[[a lastObject] pointerValue];
                if ([_ctrl.fileCtrl deleteFile:&f] == NO) {
                    ++failedCount;
                }
                cachedKey = [NSString stringWithFormat:@"ID%d", f.getFileHandle()];
                [_mpbCache removeObjectForKey:cachedKey];
            }
            // Update the UICollectionView's data source
            [self resetCollectionViewData];
            dispatch_semaphore_signal(_mpbSemaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failedCount != _selItemsTable.selectedCells.count) {
                    [_selItemsTable.selectedCells removeAllObjects];
                    [self postButtonStateChangeNotification:NO];
                    self.run = YES;
                    [self.collectionView reloadData];
                }
                
                //NSString *noticeMessage = nil;
                
                if (failedCount > 0) {
                    //noticeMessage = NSLocalizedString(@"DeleteMultiError", nil);
                    //NSString *failedCountString = [NSString stringWithFormat:@"%d", failedCount];
                    //noticeMessage = [noticeMessage stringByReplacingOccurrencesOfString:@"%d" withString:failedCountString];
                } else {
                    //noticeMessage = NSLocalizedString(@"DeleteDoneMessage", nil);
                }
                //[self showProgressHUDCompleteMessage:noticeMessage];
                //            self.selItemsTable.count = 0;
            });
        }
    });
}

-(void)prepareForAction
{
    AppLog(@"%s", __func__);
    NSInteger selectedPhotoNum = 0;
    NSInteger selectedVideoNum = 0;
    
    self.deleteButton.enabled = YES;
    self.actionButton.enabled = YES;
    
    for (NSIndexPath *ip in _selItemsTable.selectedCells) {
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
        ICatchFile f = fileTable.fileList.at(ip.item);
        //    int type = [[a objectAtIndex:1] intValue];
        //    ICatchFile *file = (ICatchFile *)[[a lastObject] pointerValue];
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

-(void)prepareForCancelAction
{
    AppLog(@"%s", __func__);
    if (_curMpbState == MpbStateEdit) {
        self.deleteButton.enabled = NO;
        self.actionButton.enabled = NO;
        if (_totalCount > 0) {
            self.title = NSLocalizedString(@"SelectItem", nil);
        } else {
            self.curMpbState = MpbStateNor;
            self.title = NSLocalizedString(@"Albums", @"");
            self.editButton.title = NSLocalizedString(@"Edit", @"");
            self.editButton.enabled = NO;
            self.navigationItem.leftBarButtonItem = self.doneButton;
        }
    } else {
        self.deleteButton.enabled = NO;
        self.actionButton.enabled = _totalCount > 0 ? YES : NO;
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
        if (_selItemsTable.count > 0) {
            [self prepareForAction];
        } else {
            [self prepareForCancelAction];
        }
    } else if ([keyPath isEqualToString:@"downloadedFileNumber"]) {
        NSUInteger handledNum = MIN(_downloadedFileNumber, _totalDownloadFileNumber);
        NSString *msg = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)handledNum, (unsigned long)_totalDownloadFileNumber];
        [self updateProgressHUDWithMessage:msg detailsMessage:nil];
    } else if([keyPath isEqualToString:@"downloadedPercent"]) {
        // TODO: NSKeyValueChangeNewKey
        //AppLog(@"xxx : %d", [[change objectForKey:@"NSKeyValueChangeNewKey"] intValue]);
        
        NSString *msg = [NSString stringWithFormat:@"%lu%%", (unsigned long)_downloadedPercent];
        if (self.downloadedFileNumber) {
            [self updateProgressHUDWithMessage:nil detailsMessage:msg];
        }
    }
}

#if USE_SYSTEM_IOS7_IMPLEMENTATION
#pragma mark - UIActionSheetDelegate

- (void)actionSheet         :(UIActionSheet *)actionSheet
        clickedButtonAtIndex:(NSInteger)buttonIndex
{
    AppLog(@"%s", __func__);
    _actionSheet = nil;
    switch (actionSheet.tag) {
        case ACTION_SHEET_DOWNLOAD_ACTIONS:
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self downloadDetail:self];
            }
            break;
            
        case ACTION_SHEET_DELETE_ACTIONS:
            if (buttonIndex == actionSheet.destructiveButtonIndex) {
                [self deleteDetail:self];
            }
            break;
            
        default:
            break;
    }
    
}
#else
#endif

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    _popController = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    AppLog(@"%s", __func__);
    NSUInteger count = _collDataArray.count;
    
    if (count > 0 && !_enableHeader) {
        count = 1;
    }
    
    AppLog(@"numberOfSectionsInCollectionView: %lu", (unsigned long)count);
    return count;
}

- (NSInteger) collectionView        :(UICollectionView *)collectionView
              numberOfItemsInSection:(NSInteger)section
{
    AppLog(@"%s", __func__);

    NSInteger num = 0;
    if(/*[_SSID containsString:@"C1GW"] ||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *str = [[NSString alloc] init];
       str = [[_collDataArray objectForKey:@(section)] objectForKey:@(SectionDataTable)];
        num = [str intValue];
    }
    else{
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(section)] objectForKey:@(SectionDataTable)];
        num = fileTable.fileList.size();
    }
    AppLog(@"numberOfItemsInSection: %ld", (long)num);
    return num;
}

- (void)setCellTag:(MpbCollectionViewCell *)cell
         indexPath:(NSIndexPath *)indexPath {
    if ([_selItemsTable.selectedCells containsObject:indexPath]) {
        [cell setSelectedConfirmIconHidden:NO];
        cell.tag = 1;
    } else {
        [cell setSelectedConfirmIconHidden:YES];
        cell.tag = 0;
    }
}
/*
 - (WCFileType)calcType:(int)sectionType
 cell:(MpbCollectionViewCell *)cell
 indexPath:(NSIndexPath *)indexPath
 {
 WCFileType type = WCFileTypeUnknow;
 switch (sectionType) {
 case WCFileTypeVideo:
 type = WCFileTypeVideo;
 [cell setVideoStaticIconHidden:NO];
 [self setCellTag:cell indexPath:indexPath withType:WCFileTypeVideo];
 break;
 case WCFileTypeImage:
 type = WCFileTypeImage;
 [cell setVideoStaticIconHidden:YES];
 [self setCellTag:cell indexPath:indexPath withType:WCFileTypeImage];
 break;
 case WCFileTypeAudio:
 type = WCFileTypeAudio;
 [cell setVideoStaticIconHidden:YES];
 [self setCellTag:cell indexPath:indexPath withType:WCFileTypeAudio];
 break;
 case WCFileTypeText:
 type = WCFileTypeText;
 [cell setVideoStaticIconHidden:YES];
 [self setCellTag:cell indexPath:indexPath withType:WCFileTypeText];
 break;
 case WCFileTypeAll:
 [self calcType:[_ctrl.fileCtrl requestFileTypeAtAll:indexPath.item] cell:cell indexPath:indexPath];
 type = WCFileTypeAll;
 default:
 break;
 }
 
 return type;
 }
 */

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MpbCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:kCellID
                                                                forIndexPath:indexPath];
    //  WCFileType type = WCFileTypeUnknow;
    //  int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
    //  type = [self calcType:sectionType cell:cell indexPath:indexPath];
    
    
   
    NSData *data = [[NSData alloc] init];
    
    UIImage *image;
    NSString *Fpath;
    
    if(/*[_SSID containsString:@"C1GW"] ||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
        [self setCellTag:cell indexPath:indexPath];
        switch (sectionType) {
            case TYPE_IMAGE:
                Fpath = @"PHOTO/";
                [cell setVideoStaticIconHidden:YES];
                break;
                
            case TYPE_VIDEO:
                if([[_FileListVideoLock objectAtIndex:indexPath.row] isEqualToString:@"1"])
                {
                    if([_SSID isEqualToString:@"D200GW"])
                    {
                        Fpath = @"PROTECTED/";
                    }
                    else{
                        Fpath = @"VIDEO/";
                    }
                }
                else
                {
                    Fpath = @"VIDEO/";
                }
                [cell setVideoStaticIconHidden:NO];
                break;
                
            default:
                break;
        }
        if(sectionType == 0x01){
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:indexPath.row]];
         data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        else{
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:indexPath.row]];
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        image = [UIImage imageWithData: data];
        if (image) {
            cell.imageView.image = image;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"pictures_no"];
        }
       
    }
    else{
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
        ICatchFile file = fileTable.fileList.at(indexPath.item);
        
        [self setCellTag:cell indexPath:indexPath];
        switch (file.getFileType()) {
            case TYPE_IMAGE:
                [cell setVideoStaticIconHidden:YES];
                break;
                
            case TYPE_VIDEO:
                [cell setVideoStaticIconHidden:NO];
                break;
                
            default:
                break;
        }
        NSString *cachedKey = [NSString stringWithFormat:@"ID%d", file.getFileHandle()];
         image = [_mpbCache objectForKey:cachedKey];
    
        if (image) {
            cell.imageView.image = image;
        } else {
            cell.imageView.image = [UIImage imageNamed:@"pictures_no"];
            
            double delayInSeconds = 0.05;
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(delayTime, _thumbnailQueue, ^{
                if (!_run) {
                    AppLog(@"bypass...");
                    return;
                }
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                dispatch_semaphore_wait(_mpbSemaphore, time);
                // Just in case, make sure the cell for this indexPath is still On-Screen.
                if ([cv cellForItemAtIndexPath:indexPath]) {
                    UIImage *image = [_ctrl.fileCtrl requestThumbnail:(ICatchFile *)&file];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [_mpbCache setObject:image forKey:cachedKey];
                            MpbCollectionViewCell *c = (MpbCollectionViewCell *)[cv cellForItemAtIndexPath:indexPath];
                            if (c) {
                                c.imageView.image = image;
                            }
                        });
                    } else {
                        AppLog(@"request thumbnail failed");
                    }
                }
                dispatch_semaphore_signal(_mpbSemaphore);
            });
            
        }
    }
     [cell.imageView setContentMode:UIViewContentModeScaleAspectFill];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.collectionView reloadData];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)cv
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    AppLog(@"%s", __func__);
    UICollectionReusableView *reusableView = nil;
    
    if (_enableHeader && kind == UICollectionElementKindSectionHeader) {
        
        MpbCollectionHeaderView *headerView = [cv dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                     withReuseIdentifier:@"headerView"
                                                                            forIndexPath:indexPath];
        WifiCamFileTable *dataTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
        NSInteger totalNum = dataTable.fileList.size();
        if (totalNum > 0) {
            
            headerView.title.text = [NSString stringWithFormat:@"%@ : %ld",
                                     [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionTitle)],
                                     (long)totalNum];
            
        } else {
            int type = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
            headerView.title.text = [_staticData.noFileNoticeDict objectForKey:@(type)];
            if (!headerView.title.text) {
                headerView.title.text = NSLocalizedString(@"No files", nil);
            }
        }
        
        reusableView = headerView;
    } else if (_enableFooter && kind == UICollectionElementKindSectionFooter) {
        // ...
    }
    
    if (reusableView) {
        return reusableView;
    } else {
        AppLog(@"Some exception message for unexpected tableView");
        abort();
    }
}


#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section
{
    AppLog(@"%s", __func__);
    if (_enableHeader && _totalCount > 0) {
        return CGSizeMake(0, 0);//CGSizeMake(self.collectionView.bounds.size.width, 50);
    } else {
        return CGSizeMake(0, 0);
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView
                 layout:(UICollectionViewLayout *)collectionViewLayout
referenceSizeForFooterInSection:(NSInteger)section
{
    AppLog(@"%s", __func__);
    if (_enableFooter && _totalCount > 0) {
        return CGSizeMake(self.collectionView.bounds.size.width, 50);
    } else {
        return CGSizeMake(0, 0);
    }
}


#pragma mark - UICollectionViewDelegate

- (void)itemLongClicked:(UILongPressGestureRecognizer *)gestureRecognizer{
    CGPoint pointTouch = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:pointTouch];
    if (indexPath != nil) {
        NSLog(@"Section = %ld,Row = %ld",(long)indexPath.section,(long)indexPath.row);
    }
    
}

- (void)photoSinglePlaybackCallback:(NSIndexPath *)indexPath {
    chooseIndex = indexPath;
    if(/*[_SSID containsString:@"C1GW"]||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSData *data = [[NSData alloc] init];
        
        NSString *Fpath;
        UIImage *image;
        int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
        switch (sectionType) {
            case TYPE_IMAGE:
                Fpath = @"PHOTO/";
                break;
            case TYPE_VIDEO:
                Fpath = @"VIDEO/";
                break;
                
            default:
                break;
        }
        if(sectionType == 0x01){
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:chooseIndex.row]];
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        else{
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:chooseIndex.row]];
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        image = [UIImage imageWithData: data];
        
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        //mpbSegmentViewController.SSIDSreial;
        mpbSegmentViewController.fileType = 1;
        mpbSegmentViewController.thumbImage = image;
        mpbSegmentViewController.updatePreview;
    }
    else
    {
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
        ICatchFile file = fileTable.fileList.at(indexPath.item);
        NSString *cachedKey = [NSString stringWithFormat:@"ID%d", file.getFileHandle()];
        UIImage *image = [_mpbCache objectForKey:cachedKey];
        
        if(!image){
            NSLog(@"can't load image");
        }
        else{
            MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
            mpbSegmentViewController.fileType = 1;
            mpbSegmentViewController.thumbImage = image;
            mpbSegmentViewController.updatePreview;
        }
    }
}

- (void)videoSinglePlaybackCallback:(NSIndexPath *)indexPath
{
    chooseIndex = indexPath;

    if(/*[_SSID containsString:@"C1GW"] ||[_SSID containsString:@"D200GW"]*/
       [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSData *data = [[NSData alloc] init];
        
        NSString *Fpath;
        UIImage *image;
        int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
        switch (sectionType) {
            case TYPE_IMAGE:
                Fpath = @"PHOTO/";
                break;
            case TYPE_VIDEO:
                Fpath = @"VIDEO/";
                break;
                
            default:
                break;
        }
        if(sectionType == 0x01){
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListPhotoName objectAtIndex:chooseIndex.row]];
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        else{
            _NvtThumbnilPath = [Fpath stringByAppendingString:[_FileListVideoName objectAtIndex:chooseIndex.row]];
            data = [self NVTGetFileThunbnailCmd:@"4002" FullFileName:_NvtThumbnilPath];
        }
        image = [UIImage imageWithData: data];
     
        MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
        mpbSegmentViewController.fileType = 0;
        mpbSegmentViewController.thumbImage = image;
        mpbSegmentViewController.updatePreview;
    }
    else
    {
        if (![_ctrl.fileCtrl isVideoPlaybackEnabled]) {
            [self showProgressHUDNotice:NSLocalizedString(@"ShowNoViewVideoTip", nil) showTime:1.0];
            return;
        }
        
        WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
        ICatchFile file = fileTable.fileList.at(indexPath.item);
        
        NSString *cachedKey = [NSString stringWithFormat:@"ID%d", file.getFileHandle()];
        _videoPlaybackIndex = indexPath.item;
        
        UIImage *image = [_mpbCache objectForKey:cachedKey];
        if (!image) {
            dispatch_suspend(_thumbnailQueue);
            
            [self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]
                              detailsMessage:nil
                                        mode:MBProgressHUDModeIndeterminate];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (!_run) {
                    return;
                }
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                dispatch_semaphore_wait(_mpbSemaphore, time);
                
                UIImage *image = [_ctrl.fileCtrl requestThumbnail:(ICatchFile *)&file];
                if (image != nil) {
                    [_mpbCache setObject:image forKey:cachedKey];
                }
                dispatch_semaphore_signal(_mpbSemaphore);
                dispatch_resume(_thumbnailQueue);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressHUD:YES];
                    
                    MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
                    mpbSegmentViewController.fileType = 0;
                    mpbSegmentViewController.updatePreview;
                    
                    //_message = @"test message with nil image";
                    
                    //MpbSegmentViewController *mpbSegmentViewController;
                    //mpbSegmentViewController.acceptMessage;
                    
                    //_videoPlaybackThumb = image;
                    //[self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
                });
            });
        } else {
            
            MpbSegmentViewController *mpbSegmentViewController = (MpbSegmentViewController *)self.parentViewController;
            mpbSegmentViewController.fileType = 0;
            mpbSegmentViewController.thumbImage = image;
            mpbSegmentViewController.updatePreview;
            
            //MpbSegmentViewController *mpbSegmentViewController;
            //mpbSegmentViewController.acceptMessage;
            
            //_videoPlaybackThumb = image;
            //[self performSegueWithIdentifier:@"PlaybackVideoSegue" sender:nil];
        }
    }
}

- (void)allPlaybackCallback:(NSIndexPath *)indexPath
{
    AppLog(@"%s", __func__);
    WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
    ICatchFile file = fileTable.fileList.at(indexPath.item);
    
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

- (void)collectionView          :(UICollectionView *)cv
        didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"item is clicked");

    if (_curMpbState == MpbStateNor) {
        if(_isEdit){
            NSLog(@"isEdit is clicked");
        }
        else{
            NSString *callbackName = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionPlaybackCallback)];
            SEL callback = NSSelectorFromString(callbackName);
            NSLog(@"item is clicked %@",callbackName);
            if ([self respondsToSelector:callback]) {
                //AppLog(@"callback-index: %ld", (long)indexPath.item);
                [self performSelector:callback withObject:indexPath afterDelay:0];
            } else {
                //AppLog(@"It's not support to playback this file.");
            }
        }
    } else {
        if(/*[_SSID containsString:@"C1GW"]||
           [_SSID containsString:@"D200GW"]*/
           [SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            MpbCollectionViewCell *cell = (MpbCollectionViewCell *)[cv cellForItemAtIndexPath:indexPath];
            if (cell.tag == 1) { // It's selected.
                cell.tag = 0;
                [cell setSelectedConfirmIconHidden:YES];
                [_FileListChooseItem removeObject:indexPath];
               // [_selItemsTable.selectedCells removeObject:indexPath];
                int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
                switch (sectionType) {
                    case TYPE_IMAGE:
                        _totalDownloadSize -= [[_FileListPhotoSize objectAtIndex:indexPath.row] intValue]>>10;
                        break;
                    case TYPE_VIDEO:
                        _totalDownloadSize -= [[_FileListVideoSize objectAtIndex:indexPath.row] intValue]>>10;
                        break;
                        
                    default:
                        break;
                }
                
            } else {
                cell.tag = 1;
                [cell setSelectedConfirmIconHidden:NO];
                [_FileListChooseItem addObject:indexPath];
                //[_selItemsTable.selectedCells addObject:indexPath];
                int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
                switch (sectionType) {
                    case TYPE_IMAGE:
                        _totalDownloadSize += [[_FileListPhotoSize objectAtIndex:indexPath.row] intValue]>>10;
                        break;
                    case TYPE_VIDEO:
                        _totalDownloadSize += [[_FileListVideoSize objectAtIndex:indexPath.row] intValue]>>10;
                        break;
                        
                    default:
                        break;
                }
            }
            self.ChooseItemcount = [_FileListChooseItem count];
           // self.selItemsTable.count = _selItemsTable.selectedCells.count;
            
            /*if (self.selItemsTable.count) {
                if (!_isSend) {
                    [self postButtonStateChangeNotification:YES];
                }
            } else {
                if (_isSend) {
                    [self postButtonStateChangeNotification:NO];
                }
            }*/
        }
        else
        {
            WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionDataTable)];
            ICatchFile file = fileTable.fileList.at(indexPath.item);
            
            NSLog(@"item is clicked %d",_curMpbState);
            /*
             WCFileType type = WCFileTypeUnknow;
             int sectionType = [[[_collDataArray objectForKey:@(indexPath.section)] objectForKey:@(SectionType)] intValue];
             switch (sectionType) {
             case WCFileTypeVideo:
             type = WCFileTypeVideo;
             break;
             
             case WCFileTypeImage:
             type = WCFileTypeImage;
             break;
             
             case WCFileTypeAll:
             type = [_ctrl.fileCtrl requestFileTypeAtAll:indexPath.item];
             break;
             
             case WCFileTypeAudio:
             case WCFileTypeText:
             default:
             break;
             }
             
             NSArray *a = @[indexPath, @(type)];
             */
            //    NSArray *fileCell = @[indexPath, [NSValue valueWithPointer:&file]];
            MpbCollectionViewCell *cell = (MpbCollectionViewCell *)[cv cellForItemAtIndexPath:indexPath];
            if (cell.tag == 1) { // It's selected.
                cell.tag = 0;
                [cell setSelectedConfirmIconHidden:YES];
                [_selItemsTable.selectedCells removeObject:indexPath];
                _totalDownloadSize -= file.getFileSize()>>10;
            } else {
                cell.tag = 1;
                [cell setSelectedConfirmIconHidden:NO];
                [_selItemsTable.selectedCells addObject:indexPath];
                _totalDownloadSize += file.getFileSize()>>10;
            }
            
            self.selItemsTable.count = _selItemsTable.selectedCells.count;
            
            if (self.selItemsTable.count) {
                if (!_isSend) {
                    [self postButtonStateChangeNotification:YES];
                }
            } else {
                if (_isSend) {
                    [self postButtonStateChangeNotification:NO];
                }
            }
        }
    }
}



- (void)postButtonStateChangeNotification:(BOOL)state
{
    _isSend = state;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraButtonsCurStateNotification"
                                                        object:@(state)];
}


/*
 - (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser
 captionViewForPhotoAtIndex:(NSUInteger)index
 {
 MWCaptionView *caption = nil;
 
 return caption;
 }
 */
- (void)showShareConfirmForphotoBrowser
{
    NSIndexPath *ip = [_selItemsTable.selectedCells firstObject];
    WifiCamFileTable *fileTable = [[_collDataArray objectForKey:@(ip.section)] objectForKey:@(SectionDataTable)];
    ICatchFile f = fileTable.fileList.at(ip.item);
    
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


- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController goHome:(id)sender
{
    [self goHome:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController playback_fullscreenBT_clicked:(id)sender
{
    [self playback_fullscreenBT_clicked:sender];
}
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController play:(id)sender
{
    [self play:sender];
}

- (MpbState)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController edit:(id)sender
{
    [self edit:sender];
    AppLog(@"%s, curMpbState: %d", __func__, _curMpbState);
    
    return _curMpbState;
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
    [self actionButtonPressed:sender];
}

#pragma mark AppDelegateProtocol
- (void)sdcardRemoveCallback
{
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
    
    /*http://192.168.1.254/NOVATEK/MOVIE/2014_0321_011922_002.MOV?custom=1&cmd=4
     001*/
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
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
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
                if([string containsString:@".JPG"]){
                    isVideo = NO;
                    [_FileListPhotoName addObject:currentElementValue];
                }
                else{
                    isVideo = YES;
                    [_FileListVideoName addObject:currentElementValue];
                }
                
               // [FileListName addObject:currentElementValue];
                
                //[[self.FileList objectAtIndex:Pens] objectAtIndex:Item];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"NAME"];
                
            }
            else if(FpathFlag)
            {
                FpathFlag = NO;
                if(isVideo){
                    [_FileListVideoFullName addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoFullName addObject:currentElementValue];
                }
                
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"FPATH"];
            }
            else if(SizeFlag)
            {
                SizeFlag = NO;
                if(isVideo){
                    [_FileListVideoSize addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoSize addObject:currentElementValue];
                }
               // [FileListSize addObject:currentElementValue];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"SIZE"];
            }
            else if(TimeCodeFlag)
            {
                TimeCodeFlag = NO;
                if(isVideo){
                    [_FileListVideoTimeCode addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoTimeCode addObject:currentElementValue];
                }
                //[FileListTimeCode addObject:currentElementValue];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"TIMECODE"];
            }
            else if(TimeFlag)
            {
                TimeFlag = NO;
                if(isVideo){
                    [_FileListVideoTime addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoTime addObject:currentElementValue];
                }
                //[FileListTime addObject:currentElementValue];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"TIME"];
            }
            else if(LockFlag)
            {
                LockFlag = NO;
                if(isVideo){
                    [_FileListVideoLock addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoLock addObject:currentElementValue];
                }
                //[FileListLock addObject:currentElementValue];
                //[self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"LOCK"];
            }
            else if(AttrFlag)
            {
                if(isVideo){
                    [_FileListVideoAttr addObject:currentElementValue];
                }
                else{
                    [_FileListPhotoAttr addObject:currentElementValue];
                }
                AttrFlag = NO;
                FileListFlag = NO;
                isVideo = NO;
                
                //[FileListAttr addObject:currentElementValue];
                
           //     [self.FileList addObject:self.FileProperty];


                //[_FileProperty removeObjectsInArray:_FileProperty];
                
                //[_FileProperty addObject:[NSNull null]];
               // [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"ATTR"];
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
    fileHandle = nil;
    NSLog(@"取得網站回應");
    FileNumber++;
    self.NVT_Download_totalLength = response.expectedContentLength;
    [self showProgressHUDWithMessage:@"请稍候 ..."
                      detailsMessage:nil
                                mode:MBProgressHUDModeDeterminate];

}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    float progress = 0;
    
    if(fileHandle) {
        // 找到檔案的尾巴
        [fileHandle seekToEndOfFile];
    }
    else {
        tmpPath = NSTemporaryDirectory();
        if(_curMpbMediaType == MpbMediaTypeVideo)
        {
            tmpfilePath = [tmpPath stringByAppendingPathComponent:[_FileListVideoName objectAtIndex:[[_FileListChooseItem objectAtIndex:FileNumber-1] row]]];
        }
        else
        {
             tmpfilePath = [tmpPath stringByAppendingPathComponent:[_FileListPhotoName objectAtIndex:[[_FileListChooseItem objectAtIndex:FileNumber-1] row]]];
        }
        // 建立檔案的URL
        [[NSFileManager defaultManager] createFileAtPath:tmpfilePath contents:nil attributes:nil];
        // 初始化檔案處理
        fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:tmpfilePath];
        
    }
    self.receiveLength += data.length;
    progress = (float)_receiveLength / (float)_NVT_Download_totalLength;
    self.downloadedPercent = MAX(0, MIN(100, progress*100));
    NSString *msg = [NSString stringWithFormat:@"%lu%%", (unsigned long)_downloadedPercent];
    NSString *number = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)FileNumber, (unsigned long)[_FileListChooseItem count]];
    [self showProgressHUDWithMessage:number
                      detailsMessage:nil
                                mode:MBProgressHUDModeDeterminate];
    
    [self updateProgressHUDWithMessage:nil detailsMessage:msg];
    
    // 寫入資料到硬碟
    [fileHandle writeData:data];
    NSLog(@"取得資料");
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"發生錯誤！");
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [fileHandle closeFile];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(_curMpbMediaType == MpbMediaTypeVideo)
    {
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:tmpfilePath]
     
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    if (error) {
                                        
                                        NSLog(@"Save video fail:%@",error);
                                        
                                    } else {
                                        
                                        NSLog(@"Save video succeed.");
                                        
                                    }
                                    
                                }];
    }
    else
    {
        UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:tmpfilePath];
        [library writeImageToSavedPhotosAlbum:[imgFromUrl3 CGImage] orientation:(ALAssetOrientation)imgFromUrl3.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"Save image fail：%@",error);
            }else{
                NSLog(@"Save image succeed.");
            }
        }];
    }
    if(FileNumber == _FileListChooseItem.count)
    {
        NSString *number = [NSString stringWithFormat:@"%lu / %lu", (unsigned long)FileNumber, (unsigned long)[_FileListChooseItem count]];
        [self showProgressHUDWithMessage:number
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
        [self showProgressHUDWithMessage:number
                          detailsMessage:nil
                                    mode:MBProgressHUDModeDeterminate];
        FileNumber = 0;
        NSLog(@"下載完成");
        [self hideProgressHUD:YES];

    }
    else{
        [self NvtdownloadDetail:(id)@"3"];
    }
    self.receiveLength = 0;
    self.NVT_Download_totalLength = 0;
   /* [self removeObserver:self forKeyPath:@"downloadedFileNumber"];
    [self removeObserver:self forKeyPath:@"downloadedPercent"];*/
   // NSLog(@"下載完成");
}
-(void) initLanguage{
    if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"English"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"en" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"German"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"de" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"French"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"fr" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Dutch"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"nl" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Italian"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"it" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Spanish"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"es" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Portuguese"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"pt-BR" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Russia"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ru" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Polish"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"pl" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Czech"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"cs" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Romanian"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ro" ofType:@"lproj"];
        _bundle = [NSBundle bundleWithPath:path];
    }
}
- (NSString*)getStringForKey:(NSString*)key withTable:(NSString*)table {
    if(_bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, _bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}
- (NSString*) inquiryContent:(sqlite3*) db tableName:(NSString*)tableName inquiryTag:(NSString*)tag {
    NSString *content = @"";
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        NSString *str = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
        NSLog(@"strBB = %@",str);
        const char *sql = [str UTF8String];//"select * from data3";
        sqlite3_stmt *statement =nil;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *_id,*name;
                
                _id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                //NSLog(@"Record: %@> %@ , %@",_id, name, content);
                if([name  isEqual: tag]) {
                    sqlite3_finalize(statement);
                    sqlite3_close(db);
                    return content;
                }
            }
            
            //sqlite3_finalize(statement);
        }
        //sqlite3_close(db);
    }
    return content;
}
@end
