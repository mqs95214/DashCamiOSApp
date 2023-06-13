//
//  ViewController.m
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import "ViewController.h"
#import "ViewControllerPrivate.h"
#ifndef HW_DECODE_H264

#endif

#import <VideoToolbox/VideoToolbox.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AppDelegate.h"

#define TimeInterval [[[NSUserDefaults standardUserDefaults] stringForKey:@"LivePostTimeoutInterval"] doubleValue]

static void didDecompress( void *decompressionOutputRefCon, void *sourceFrameRefCon, OSStatus status, VTDecodeInfoFlags infoFlags, CVImageBufferRef pixelBuffer, CMTime presentationTimeStamp, CMTime presentationDuration ){
    
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(pixelBuffer);
}

@implementation ViewController {
    /**
     * 20150630  guo.jiang
     * Deprecated ! (USE WifiCamObserver & WifiCamSDKEventListener.)
     */
    
    VideoRecOffListener *videoRecOffListener;
    VideoRecOnListener *videoRecOnListener;
    BatteryLevelListener *batteryLevelListener;
    StillCaptureDoneListener *stillCaptureDoneListener;
    SDCardFullListener *sdCardFullListener;
    TimelapseStopListener *timelapseStopListener;
    TimelapseCaptureStartedListener *timelapseCaptureStartedListener;
    TimelapseCaptureCompleteListener *timelapseCaptureCompleteListener;
    VideoRecPostTimeListener *videoRecPostTimeListener;
    FileDownloadListener *fileDownloadListener; //ICATCH_EVENT_FILE_DOWNLOAD
    
    uint8_t *_sps;
    NSInteger _spsSize;
    uint8_t *_pps;
    NSInteger _ppsSize;
    CMVideoFormatDescriptionRef _decoderFormatDescription;
    VTDecompressionSessionRef _deocderSession;
    NSString *SSID;
    int NvtStateRecording;
    SSID_SerialCheck *SSIDSreial;
    NSTimer *sensorNumberChangetimer;
    int sensorNumberChangeData;
    
    AppDelegate *delegate;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    TRACE();
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCloseController:) name:@"closeViewController" object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    SSIDSreial = [[SSID_SerialCheck alloc]init];
    SSID = [self recheckSSID];
    [self.navigationController setNavigationBarHidden:YES];
    [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
    [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        self.preview.hidden = YES;
        self.NvtHttpValueDict = [[NSMutableDictionary alloc] init];
        
        if (!self.previewSemaphore) {
            self.previewSemaphore = dispatch_semaphore_create(1);
        }
        [self Novatek_constructPreviewData];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            self.NvtPreviewMode = [self NvtGetPreivewMode];
            if(![self.NvtPreviewMode isEqualToString:@"0"])
            {
                [self NvtSetPreivewMode:@"3001" Par2:@"1"];
            }
            NSLog(@"NvtPreviewMode = %@",self.NvtPreviewMode);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
                [self.videoToggle setImage:[UIImage imageNamed:@"control_dashcam_video_select"]
                                   forState:UIControlStateNormal];
                [self.cameraToggle setImage:[UIImage imageNamed:@"control_dashcam_camera_noselect"] forState:UIControlStateNormal];
                [self NvtVideoModeRemainTime];
                [self NodePlayerInit];
            });
        });
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        self.preview.hidden = NO;
        
        if([[SDK instance] isSDKInitialized])
        {
            WifiCamManager *app = [WifiCamManager instance];
            self.wifiCam = [app.wifiCams objectAtIndex:0];
            self.camera = _wifiCam.camera;
            self.ctrl = _wifiCam.controler;
            self.staticData = [WifiCamStaticData instance];
            
        }
        else
        {
            [[SDK instance] initializeSDK];
            [WifiCamControl scan];
            WifiCamManager *app = [WifiCamManager instance];
            self.wifiCam = [app.wifiCams objectAtIndex:0];
            _wifiCam.camera = [WifiCamControl createOneCamera];
            self.camera = _wifiCam.camera;
            self.ctrl = _wifiCam.controler;
        }
        
        [self ICatch_constructPreviewData];
        [self p_initPreviewGUI];
        
        //=========comment this line by tom==================//
        //self.enableAudioButton.hidden = YES;
        //self.sizeButton.userInteractionEnabled = NO;
        //self.selftimerButton.userInteractionEnabled = NO;
        //=========comment this line by tom==================//
        /*if ([self.enableAudioButton isHidden]) {
            [self.enableAudioButton removeFromSuperview];
        }*/
        // Test
        //    self.pvCache = [NSMutableArray arrayWithCapacity:30];
        
        UITapGestureRecognizer *tap0 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomController:)];
        [_preview addGestureRecognizer:tap0];
        
        #ifdef HW_DECODE_H264
        // H.264
        self.avslayer = [[AVSampleBufferDisplayLayer alloc] init];
        
        self.avslayer.frame = _preview.frame;
       /* self.avslayer.position = CGPointMake(CGRectGetMidX(_preview.bounds), CGRectGetMidY(_preview.bounds));*/
        self.avslayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.avslayer.backgroundColor = [[UIColor blackColor] CGColor];
        
        CMTimebaseRef controlTimebase;
        CMTimebaseCreateWithMasterClock(CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase);
        self.avslayer.controlTimebase = controlTimebase;
        //    CMTimebaseSetTime(self.avslayer.controlTimebase, CMTimeMake(5, 1));
        CMTimebaseSetRate(self.avslayer.controlTimebase, 1.0);
        
        //[self.view.layer insertSublayer:_avslayer below:_preview.layer];
        
        self.h264View = [[UIView alloc] initWithFrame:self.view.bounds];
        [_h264View.layer addSublayer:_avslayer];
        [self.view insertSubview:_h264View belowSubview:_preview];
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showZoomController:)];
        [_h264View addGestureRecognizer:tap1];
        #endif
    }
}
-(void)notificationCloseController:(NSNotification *)notification{
    //NSString  *name=[notification name];
    //NSString  *object=[notification object];
    //NSLog(@"名称:%@----对象:%@",name,object);
    [self.progressHUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)showLiveGUIIfNeeded:(WifiCamPreviewMode)curMode
{
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PreferenceSpecifier:Live"] && (curMode == WifiCamPreviewModeVideoOff || curMode == WifiCamPreviewModeVideoOn) && [[SDK instance] isStreamSupportPublish]) {
                //============comment this line by Tom===============//
                //_liveSwitch.hidden = NO;
                //_liveTitle.hidden = NO;
                //_liveResolution.hidden = NO;
            } else {
                //============comment this line by Tom===============//
                //_liveSwitch.hidden = YES;
                //_liveTitle.hidden = YES;
                //_liveResolution.hidden = YES;
            }
        });
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    TRACE();
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;

    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recoverFromDisconnection)
                                             name    :@"kCameraNetworkConnectedNotification"
                                             object  :nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reconnectNotification:)
                                             name    :@"kCameraReconnectNotification"
                                             object  :nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];

    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
     
      
    }
}


-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    


    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        
        if (self.isEnterBackground) {
            return;
        }
        //if (_camera.previewMode == WifiCamPreviewModeVideoOff) {
        
        //} else {
        //[self showProgressHUDWithMessage:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AudioServicesPlaySystemSound(_changeModeSound);
            self.PVRun = NO;
            _camera.previewMode = WifiCamPreviewModeVideoOff;
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
            if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self hideProgressHUD:YES];
                    [self showErrorAlertView];
                });
            } else {
                dispatch_semaphore_signal(_previewSemaphore);
                self.PVRun = YES;
                [self runPreview:ICATCH_VIDEO_PREVIEW_MODE];
            }
        });
        //}
        if ([self capableOf:WifiCamAbilityBatteryLevel]) {
            [self updateBatteryLevelIcon];
        }
        AppLog(@"curDateStamp: %d", _camera.curDateStamp);

        
        // Update the AWB icon after setting new awb value
        if ([self capableOf:WifiCamAbilityWhiteBalance]) {
            [self updateWhiteBalanceIcon:_camera.curWhiteBalance];
        }
        
        // Update the Timelapse icon
        if ([self capableOf:WifiCamAbilityTimeLapse]
            && _camera.previewMode == WifiCamPreviewModeTimelapseOff
            && _camera.curTimelapseInterval != 0) {
            //=========comment this line by tom==================//
           /* self.timelapseStateImageView.hidden = NO;*/
            if (_camera.timelapseType == WifiCamTimelapseTypeVideo) {
                //=========comment this line by tom==================//
                //self.timelapseStateImageView.image = [UIImage imageNamed:@"timelapse_video"];
            } else {
                //=========comment this line by tom==================//
                //self.timelapseStateImageView.image = [UIImage imageNamed:@"timelapse_capture"];
            }
        } else {
            //=========comment this line by tom==================//
            //self.timelapseStateImageView.hidden = YES;
        }
        
        // Update the Slow-Motion icon
        if ([self capableOf:WifiCamAbilitySlowMotion]
            && _camera.previewMode == WifiCamPreviewModeVideoOff
            && _camera.curSlowMotion == 1) {
            //=========comment this line by tom==================//
            //self.slowMotionStateImageView.hidden = NO;
        } else {
            //=========comment this line by tom==================//
            //self.slowMotionStateImageView.hidden = YES;
        }
        
        // Update the Invert-Mode icon
        if ([self capableOf:WifiCamAbilityUpsideDown]
            && _camera.curInvertMode == 1) {
            //=========comment this line by tom==================//
            //self.invertModeStateImageView.hidden = NO;
        } else {
            //=========comment this line by tom==================//
            //self.invertModeStateImageView.hidden = YES;
        }
        
        // Update delay capture icon after enable burst capture
        if ([self capableOf:WifiCamAbilityDelayCapture]
            && _camera.previewMode == WifiCamPreviewModeCameraOff) {
            [self updateCaptureDelayItem:_camera.curCaptureDelay];
        }
        
        // Burst-capture icon
        if ([self capableOf:WifiCamAbilityBurstNumber]
            && _camera.previewMode == WifiCamPreviewModeCameraOff) {
            [self updateBurstCaptureIcon:_camera.curBurstNumber];
        }
        
        // Movie Rec timer
        if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]
            && (_camera.previewMode == WifiCamPreviewModeVideoOn
                || (_camera.previewMode == WifiCamPreviewModeTimelapseOn
                    /*&& _camera.timelapseType == WifiCamTimelapseTypeVideo*/))) {
                    self.movieRecordTimerLabel.hidden = NO;
                } else {
                 //self.movieRecordTimerLabel.hidden = YES;
                }
        if(_camera.previewMode == WifiCamPreviewModeCameraOff || _camera.previewMode == WifiCamPreviewModeCameraOn)
        {
            self.movieRecordTimerLabel.text = [[NSString alloc] initWithFormat:@"%d",[[SDK instance] retrieveFreeSpaceOfImage]];
        }
        else
        {
            self.movieRecordTimerLabel.text = [Tool translateSecsToString:[[SDK instance] retrieveFreeSpaceOfVideo]];
        }
        
        // Update the size icon after delete or capture
        if ([self capableOf:WifiCamAbilityImageSize]
            && _camera.previewMode == WifiCamPreviewModeCameraOff) {
            [self updateImageSizeOnScreen:_camera.curImageSize];
        } else if ([self capableOf:WifiCamAbilityVideoSize]
                   && _camera.previewMode == WifiCamPreviewModeVideoOff) {
            [self updateVideoSizeOnScreen:_camera.curVideoSize];
        } else if (_camera.previewMode == WifiCamPreviewModeTimelapseOff) {
            if (_camera.timelapseType == WifiCamTimelapseTypeStill) {
                [self updateImageSizeOnScreen:_camera.curImageSize];
            } else {
                [self updateVideoSizeOnScreen:_camera.curVideoSize];
            }
        }
        
        // Movie rec
        if ([self capableOf:WifiCamAbilityMovieRecord]) {
            videoRecOnListener = new VideoRecOnListener(self);
            [_ctrl.comCtrl addObserver:ICATCH_EVENT_VIDEO_ON
                              listener:videoRecOnListener
                           isCustomize:NO];
        }
        
        if (_camera.enableAutoDownload) {
            fileDownloadListener = new FileDownloadListener(self);
            [_ctrl.comCtrl addObserver:ICATCH_EVENT_FILE_DOWNLOAD
                              listener:fileDownloadListener
                           isCustomize:NO];
        }
        
        // Zoom In/Out
        //============comment this line by Tom===============//
        //uint maxZoomRatio = [_ctrl.propCtrl retrieveMaxZoomRatio];
        //uint curZoomRatio = [_ctrl.propCtrl retrieveCurrentZoomRatio];
        //AppLog(@"maxZoomRatio: %d", maxZoomRatio);
        //AppLog(@"curZoomRatio: %d", curZoomRatio);
        //self.zoomSlider.minimumValue = 1.0;
        //self.zoomSlider.maximumValue = maxZoomRatio/10.0;
        //self.zoomSlider.value = curZoomRatio/10.0;
        //_zoomValueLabel.text = [NSString stringWithFormat:@"x%0.1f",curZoomRatio/10.0];
        
        // Check SD card
        if (![_ctrl.propCtrl checkSDExist]) {
            [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""] showTime:2.0];
        } else if ((_camera.previewMode == WifiCamPreviewModeCameraOff && _camera.storageSpaceForImage <= 0)
                   || (_camera.previewMode == WifiCamPreviewModeVideoOff && [[SDK instance] retrieveFreeSpaceOfImage]<=0)) {
            [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""] showTime:2.0];
        }
        
        if (_PVRun) {
            return;
        }
        self.PVRun = YES;
        //============comment this line by Tom===============//
        //_noPreviewLabel.hidden = YES;
        
        switch (_camera.previewMode) {
            case WifiCamPreviewModeCameraOff:
            case WifiCamPreviewModeCameraOn:
                [self runPreview:ICATCH_STILL_PREVIEW_MODE];
                break;
                
            case WifiCamPreviewModeTimelapseOff:
            case WifiCamPreviewModeTimelapseOn:
                if (_camera.timelapseType == WifiCamTimelapseTypeVideo) {
                    // mark by allen.chuang 2015.1.15 ICOM-2692
                    //if( [_ctrl.propCtrl changeTimelapseType:ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE] == WCRetSuccess)
                    //    AppLog(@"change to ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE success");
                    [self runPreview:ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE];
                } else {
                    // mark by allen.chuang 2015.1.15 ICOM-2692
                    //if( [_ctrl.propCtrl changeTimelapseType:ICATCH_TIMELAPSE_STILL_PREVIEW_MODE] == WCRetSuccess)
                    //    AppLog(@"change to ICATCH_TIMELAPSE_STILL_PREVIEW_MODE success");
                    [self runPreview:ICATCH_TIMELAPSE_STILL_PREVIEW_MODE];
                }
                
                break;
                
            case WifiCamPreviewModeVideoOff:
            case WifiCamPreviewModeVideoOn:
                [self runPreview:ICATCH_VIDEO_PREVIEW_MODE];
                
                break;
                
            default:
                break;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    TRACE();
    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        if (self.currentVideoData.length == 0) {
            self.savedCamera.thumbnail = (id)_preview.image;
        }
        
        
        [self hideZoomController:YES];
        
        //    AppLog(@"self.PVRun = NO");
        // Stop preview
        //    self.PVRun = NO;
        
        [self removeObservers];
        
        if (!_normalAlert.hidden) {
            [_normalAlert dismissWithClickedButtonIndex:0 animated:NO];
        }
        
        // Save data to sqlite
        #if 0
            NSError *error = nil;
            if (![self.savedCamera.managedObjectContext save:&error]) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
                 */
                AppLog(@"Unresolved error %@, %@", error, [error userInfo]);
        #ifdef DEBUG
                abort();
        #endif
            } else {
                AppLog(@"Saved to sqlite.");
            }
        #endif
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraNetworkConnectedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraReconnectNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];

}

- (void)dealloc {
    NSLog(@"**DEALLOC**");
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [self p_deconstructPreviewData];
        //[[SDK instance] destroySDK];
    }
    if(sensorNumberChangetimer != nil) {
        [sensorNumberChangetimer invalidate];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)NodePlayerInit
{
    _np = [[NodePlayer alloc] init];
    [_np setNodePlayerDelegate:self];
    [_np setBufferTime:1500];
    [_np setConnectWaitTimeout:5000];
    [_np setContentMode:UIViewContentModeScaleToFill];
    [_np setInputUrl:@"rtsp://192.168.1.254/xxx.mov"];
    [_np setPlayerView:self.NodePlayerView];
    [_np start];
    
}
-(void)NodePlaySetUrl
{
    if([SSIDSreial MatchSSIDReturn:SSID] == CANSONIC_Z3)
    {
        [_np setInputUrl:@"rtsp://192.168.1.1/MJPG?W=760&H=400&Q=50&BR=5000000"];
    }
    else if([SSIDSreial MatchSSIDReturn:SSID] == CANSONIC_S2Plus)
    {
        [_np setInputUrl:@"rtsp://192.168.1.1/H264?W=1280&H=720&BR=4000000&FPS=30"];
    }
    else
    {
        [_np setInputUrl:@"rtsp://192.168.1.254/xxx.mov"];
    }
}

- (BOOL)capableOf:(WifiCamAbility)ability {
    return (_camera.ability & ability) == ability ? YES : NO;
}


-(void)recoverFromDisconnection {
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        [self Novatek_constructPreviewData];
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.camera = _wifiCam.camera;
        self.ctrl = _wifiCam.controler;
        self.staticData = [WifiCamStaticData instance];
        
        [self ICatch_constructPreviewData];
        [self p_initPreviewGUI];
        
     
    }
       [self viewDidAppear:YES];
}


#pragma mark - Initialization
- (void)Novatek_constructPreviewData {
    NSString *stillCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"Capture_Shutter" ofType:@"WAV"];
    id url = [NSURL fileURLWithPath:stillCaptureSoundUri];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_stillCaptureSound);
    
    NSString *delayCaptureBeepUri = [[NSBundle mainBundle] pathForResource:@"DelayCapture_BEEP" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:delayCaptureBeepUri];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_delayCaptureSound);
    
    NSString *changeModeSoundUri = [[NSBundle mainBundle] pathForResource:@"ChangeMode" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:changeModeSoundUri];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_changeModeSound);
    
    NSString *videoCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"StartStopVideoRec" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:videoCaptureSoundUri];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_videoCaptureSound);
    
    NSString *burstCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"BurstCapture&TimelapseCapture" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:burstCaptureSoundUri];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_burstCaptureSound);
    
}
- (void)ICatch_constructPreviewData {
    BOOL onlyStillFunction = YES;
    
    self.previewGroup = dispatch_group_create();
    self.audioQueue = dispatch_queue_create("WifiCam.GCD.Queue.Preview.Audio", 0);
    self.videoQueue = dispatch_queue_create("WifiCam.GCD.Queue.Preview.Video", 0);
    
    //    self.AudioRun = YES;
    if (!self.previewSemaphore) {
        self.previewSemaphore = dispatch_semaphore_create(1);
    }
    NSString *stillCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"Capture_Shutter" ofType:@"WAV"];
    id url = [NSURL fileURLWithPath:stillCaptureSoundUri];
    //    OSStatus errcode =
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_stillCaptureSound);
    //    NSAssert1(errcode == 0, @"Failed to load sound ", @"Capture_Shutter.WAV");
    
    NSString *delayCaptureBeepUri = [[NSBundle mainBundle] pathForResource:@"DelayCapture_BEEP" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:delayCaptureBeepUri];
    //    errcode =
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_delayCaptureSound);
    //    NSAssert1(errcode == 0, @"Failed to load sound ", @"DelayCapture_BEEP.WAV");
    
    NSString *changeModeSoundUri = [[NSBundle mainBundle] pathForResource:@"ChangeMode" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:changeModeSoundUri];
    //    errcode =
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_changeModeSound);
    //    NSAssert1(errcode == 0, @"Failed to load sound ", @"ChangeMode.WAV");
    
    NSString *videoCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"StartStopVideoRec" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:videoCaptureSoundUri];
    //    errcode =
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_videoCaptureSound);
    //    NSAssert1(errcode == 0, @"Failed to load sound ", @"StartStopVideoRec.WAV");
    
    NSString *burstCaptureSoundUri = [[NSBundle mainBundle] pathForResource:@"BurstCapture&TimelapseCapture" ofType:@"WAV"];
    url = [NSURL fileURLWithPath:burstCaptureSoundUri];
    //    errcode =
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &_burstCaptureSound);
    //    NSAssert1(errcode == 0, @"Failed to load sound ", @"BurstCapture&TimelapseCapture.WAV");
    
    self.alertTableArray = [[NSMutableArray alloc] init];
    
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
        [self p_initTimelapseRec];
        onlyStillFunction = NO;
    } else {
        //=========comment this line by tom==================//
        //[self.timelapseToggle removeFromSuperview];
        //[self.timelapseStateImageView removeFromSuperview];
    }
    //sensorNumberChangetimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sensorNumberChangeFunction) userInfo:nil repeats:YES];
    if ([self capableOf:WifiCamAbilityMovieRecord]) {
        if ([self capableOf:WifiCamAbilityVideoSize]) {
            if( _camera.cameraMode == MODE_TIMELAPSE_VIDEO
               || _camera.cameraMode == MODE_TIMELAPSE_VIDEO_OFF){
                self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForTimeLapseVideoSize:_camera.curVideoSize];
            }else
                self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForVideoSize:_camera.curVideoSize];
        }
        [self p_initMovieRec];
        onlyStillFunction = NO;
    }
    
    if ([self capableOf:WifiCamAbilityStillCapture]){
        if ([self capableOf:WifiCamAbilityImageSize]) {
            self.tbPhotoSizeArray = [_ctrl.propCtrl prepareDataForImageSize:_camera.curImageSize];
        }
        if ([self capableOf:WifiCamAbilityDelayCapture]) {
            self.tbDelayCaptureTimeArray = [_ctrl.propCtrl prepareDataForDelayCapture:_camera.curCaptureDelay];
        }
        if (onlyStillFunction) {
            _camera.previewMode = WifiCamPreviewModeCameraOff;
        }
    }
    
    AppLog(@"_camera.cameraMode: %d", _camera.cameraMode);
    switch (_camera.cameraMode) {
        case MODE_VIDEO_OFF:
            _camera.previewMode = WifiCamPreviewModeVideoOff;
            break;
            
        case MODE_CAMERA:
            _camera.previewMode = WifiCamPreviewModeCameraOff;
            break;
            
        case MODE_IDLE:
            break;
            
        case MODE_SHARED:
            break;
            
        case MODE_TIMELAPSE_STILL_OFF:
            _camera.previewMode = WifiCamPreviewModeTimelapseOff;
            _camera.timelapseType = WifiCamTimelapseTypeStill;
            break;
            
        case MODE_TIMELAPSE_STILL:
            _camera.previewMode = WifiCamPreviewModeTimelapseOn;
            _camera.timelapseType = WifiCamTimelapseTypeStill;
            break;
            
        case MODE_TIMELAPSE_VIDEO_OFF:
            _camera.previewMode =WifiCamPreviewModeTimelapseOff;
            _camera.timelapseType =WifiCamTimelapseTypeVideo;
            break;
            
        case MODE_TIMELAPSE_VIDEO:
            _camera.previewMode = WifiCamPreviewModeTimelapseOn;
            _camera.timelapseType = WifiCamTimelapseTypeVideo;
            break;
            
        case MODE_VIDEO_ON:
            _camera.previewMode = WifiCamPreviewModeVideoOn;
            break;
            
        case MODE_UNDEFINED:
        default:
            break;
    }
    
    [self updatePreviewSceneByMode:_camera.previewMode];
}

- (void)p_initMovieRec {
    AppLog(@"%s", __func__);
    [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
    [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
    self.stopOn = [UIImage imageNamed:@"control_dashcam_record"];
    self.stopOff = [UIImage imageNamed:@"control_dashcam_record_stop"];
    
    if (_camera.movieRecording) {
        [self addMovieRecListener];
        if (![_videoCaptureTimer isValid]) {
            self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target  :self
                                                                    selector:@selector(movieRecordingTimerCallback:)
                                                                    userInfo:nil
                                                                    repeats :YES];
            
            if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                self.movieRecordElapsedTimeInSeconds = [_ctrl.propCtrl retrieveCurrentMovieRecordElapsedTime];
                AppLog(@"elapsedTimeInSeconds: %d", _movieRecordElapsedTimeInSeconds);
                self.movieRecordTimerLabel.text = [Tool translateSecsToString:_movieRecordElapsedTimeInSeconds];
            }
            
        }
        _camera.previewMode = WifiCamPreviewModeVideoOn;
    }
}

- (void)p_initTimelapseRec {
    BOOL isTimelapseAlreadyStarted = NO;
    
    if (_camera.stillTimelapseOn) {
        AppLog(@"stillTimelapse On");
        _camera.timelapseType = WifiCamTimelapseTypeStill;
        isTimelapseAlreadyStarted = YES;
    } else if (_camera.videoTimelapseOn) {
        AppLog(@"videoTimelapseOn On");
        _camera.timelapseType = WifiCamTimelapseTypeVideo;
        isTimelapseAlreadyStarted = YES;
    }
    
    if (isTimelapseAlreadyStarted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![_videoCaptureTimer isValid]) {
                self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                        target  :self
                                                                        selector:@selector(movieRecordingTimerCallback:)
                                                                        userInfo:nil
                                                                        repeats :YES];
                if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                    self.movieRecordElapsedTimeInSeconds = [_ctrl.propCtrl retrieveCurrentMovieRecordElapsedTime];
                    AppLog(@"elapsedTimeInSeconds: %d", _movieRecordElapsedTimeInSeconds);
                    self.movieRecordTimerLabel.text = [Tool translateSecsToString:_movieRecordElapsedTimeInSeconds];
                }
            }
        });
        [self addTimelapseRecListener];
        _camera.previewMode = WifiCamPreviewModeTimelapseOn;
    }
}

- (void)p_initPreviewGUI {
    if ([self capableOf:WifiCamAbilityStillCapture
         && self.snapButton.hidden]) {
        self.snapButton.hidden = NO;
    }
    /*if (self.mpbToggle.hidden) {
        self.mpbToggle.hidden = NO;
    }*/
    self.snapButton.exclusiveTouch = YES;
    //self.mpbToggle.exclusiveTouch = YES;
    self.cameraToggle.exclusiveTouch = YES;
    self.videoToggle.exclusiveTouch = YES;
    //self.selftimerButton.exclusiveTouch = YES;
    //self.sizeButton.exclusiveTouch = YES;
    self.view.exclusiveTouch = YES;
}

- (void)p_deconstructPreviewData {
    AudioServicesDisposeSystemSoundID(_stillCaptureSound);
    AudioServicesDisposeSystemSoundID(_delayCaptureSound);
    AudioServicesDisposeSystemSoundID(_changeModeSound);
    AudioServicesDisposeSystemSoundID(_videoCaptureSound);
    AudioServicesDisposeSystemSoundID(_burstCaptureSound);
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

- (void)showProgressHUDNotice:(NSString *)message
                     showTime:(NSTimeInterval)time {
    if(self.progressHUD == nil)
        return;
    if (message) {
        [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeText;
        [self.progressHUD hide:YES afterDelay:time];
    } else {
        [self.progressHUD hide:YES];
    }
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    if(self.progressHUD == nil)
        return;
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:15.0];
}

- (void)showProgressHUDCompleteMessage:(NSString *)message {
    if(self.progressHUD == nil)
        return;
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
    if(self.progressHUD == nil)
        return;
    [self.progressHUD hide:animated];
}

#pragma mark - Preview GUI
- (void)updateBatteryLevelIcon {
    //============comment this line by Tom===============//
    //[self.batteryState setHidden:NO];
    
    NSString *imagePath = [_ctrl.propCtrl prepareDataForBatteryLevel];
    UIImage *batteryStatusImage = [UIImage imageNamed:imagePath];
    //============comment this line by Tom===============//
    //[self.batteryState setImage:batteryStatusImage];
    self.batteryLowAlertShowed = NO;
    
    batteryLevelListener = new BatteryLevelListener(self);
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_BATTERY_LEVEL_CHANGED
                      listener:batteryLevelListener
                   isCustomize:NO];
}

- (void)updateWhiteBalanceIcon:(unsigned int)curWhiteBalance
{
    NSString  *imageName = [_staticData.awbDict objectForKey:@(curWhiteBalance)];
    //=========comment this line by tom==================//
    //[self.awbLabel setImage:[UIImage imageNamed:imageName]];
}

- (void)updateCaptureDelayItem:(unsigned int)curCaptureDelay {
    if (curCaptureDelay == CAP_DELAY_NO) {
        _tbDelayCaptureTimeArray.lastIndex = 0;
    }
    NSString *title = [_staticData.captureDelayDict objectForKey:@(curCaptureDelay)];
    //=========comment this line by tom==================//
    //[self.selftimerLabel setText:title];
    /*[self.selftimerButton setImage:[UIImage imageNamed:@"btn_selftimer_n"]
                          forState:UIControlStateNormal];*/
    //self.selftimerLabel.hidden = NO;
   // self.selftimerButton.hidden = NO;
}

- (void)updateBurstCaptureIcon:(unsigned int)curBurstNumber {
    if (curBurstNumber != BURST_NUMBER_OFF) {
        NSDictionary *burstNumberStringTable = [[WifiCamStaticData instance] burstNumberStringDict];
        id imageName = [[burstNumberStringTable objectForKey:@(curBurstNumber)] lastObject];
        UIImage *continuousCaptureImage = [UIImage imageNamed:imageName];
        //=========comment this line by tom==================//
        //_burstCaptureStateImageView.image = continuousCaptureImage;
        //=========comment this line by tom==================//
        //self.burstCaptureStateImageView.hidden = NO;
    } else {
        //=========comment this line by tom==================//
        //self.burstCaptureStateImageView.hidden = YES;
    }
}

- (void)updateSizeItemWithTitle:(NSString *)title
                     andStorage:(NSString *)storage {
    AppLogDebug(AppLogTagAPP, @"videoSize: %@, videoStorage: %@", title, storage);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (title) {
            //=========comment this line by tom==================//
            //[self.sizeButton setTitle:title forState:UIControlStateNormal];
        }
        //=========comment this line by tom==================//
        //[self.sizeLabel setText:storage];
    });
}

- (void)updateImageSizeOnScreen:(string)imageSize {
    NSArray *imageArray = [_ctrl.propCtrl prepareDataForStorageSpaceOfImage: imageSize];
    _camera.storageSpaceForImage = [[imageArray lastObject] unsignedIntValue];
    NSString *storage = [NSString stringWithFormat:@"%d", _camera.storageSpaceForImage];
    [self updateSizeItemWithTitle:[imageArray firstObject]
                       andStorage:storage];
}

- (void)updateVideoSizeOnScreen:(string)videoSize {
    NSArray *videoArray = [_ctrl.propCtrl prepareDataForStorageSpaceOfVideo: videoSize];
    _camera.storageSpaceForVideo = [[videoArray lastObject] unsignedIntValue];
    NSLog(@"APSLPLPLLLLLLL  ->   %d",_camera.storageSpaceForVideo);
    NSString *storage = [Tool translateSecsToString: _camera.storageSpaceForVideo];
    [self updateSizeItemWithTitle:[videoArray firstObject] andStorage:storage];
}

- (void)setToCameraOffScene
{
    //=========comment this line by tom==================//
    self.snapButton.enabled = YES;
    //self.mpbToggle.enabled = YES;
    //self.settingButton.enabled = YES;
    self.cameraToggle.userInteractionEnabled = YES;
    self.videoToggle.userInteractionEnabled = YES;
    //[self.cameraToggle setEnabled:YES];
    //[self.videoToggle setEnabled:YES];
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
         //=========comment this line by tom==================//
       // [self.timelapseToggle setEnabled:YES];
    }
    
    // DelayCapture Item
    if ([self capableOf:WifiCamAbilityDelayCapture]) {
        [self updateCaptureDelayItem:_camera.curCaptureDelay];
    }
    // CaptureSize Item
    if ([self capableOf:WifiCamAbilityImageSize]) {
        //=========comment this line by tom==================//
        /*if (self.sizeButton.hidden) {
            self.sizeButton.hidden = NO;
            self.sizeLabel.hidden = NO;
        }
        self.sizeButton.enabled = YES;*/
        self.tbPhotoSizeArray = [_ctrl.propCtrl prepareDataForImageSize:_camera.curImageSize];
        [self updateImageSizeOnScreen:_camera.curImageSize];
        
    } else {
        //=========comment this line by tom==================//
        //self.sizeButton.hidden = YES;
        //self.sizeLabel.hidden = YES;
    }
    // WhiteBalance
    //=========comment this line by tom==================//
    if ([self capableOf:WifiCamAbilityWhiteBalance]
        /*&& self.awbLabel.hidden*/) {
       // self.awbLabel.hidden = NO;
    }
    // timelapse icon
    //=========comment this line by tom==================//
    /*if (self.timelapseStateImageView.hidden == NO) {
        self.timelapseStateImageView.hidden = YES;
    }*/
    // slow-motion
    //=========comment this line by tom==================//
    /*if (self.slowMotionStateImageView.hidden == NO) {
        self.slowMotionStateImageView.hidden = YES;
    }*/
    // invert-mode
    if (_camera.curInvertMode == 1) {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = NO;
    } else {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = YES;
    }
    // Burst-Capture icon
    if ([self capableOf:WifiCamAbilityBurstNumber]) {
        //self.burstCaptureStateImageView.hidden = NO;
        [self updateBurstCaptureIcon:_camera.curBurstNumber];
    }
    // movie record timer label
    /*
     if (!self.movieRecordTimerLabel.hidden) {
     self.movieRecordTimerLabel.hidden = YES;
     }
     */
    
    
    // Video Toggle & Timelapse Toggle & Camera Toggle
    if ([self capableOf:WifiCamAbilityMovieRecord]) {
        if (self.videoToggle.hidden) {
            self.videoToggle.hidden = NO;
        }
        [self.videoToggle setImage:[UIImage imageNamed:@"control_dashcam_video_noselect"]
                          forState:UIControlStateNormal];
        self.videoToggle.userInteractionEnabled = YES;
    }
    
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
         //=========comment this line by tom==================//
       /* if (self.timelapseToggle.hidden) {
            self.timelapseToggle.hidden = NO;
        }
        
        [self.timelapseToggle setImage:[UIImage imageNamed:@"timelapse_off"]
                              forState:UIControlStateNormal];
        self.timelapseToggle.enabled = YES;*/
    }
    
    if ([self capableOf:WifiCamAbilityStillCapture]) {
        if (self.cameraToggle.hidden) {
            self.cameraToggle.hidden = NO;
        }
        
        [self.cameraToggle setImage:[UIImage imageNamed:@"control_dashcam_camera_select"]
                           forState:UIControlStateNormal];
        self.cameraToggle.userInteractionEnabled = YES;
        [_titleIcon setImage:[UIImage imageNamed:@"title_camera"]];
        [_titleText setText:[delegate getStringForKey:@"SetPhotoMode" withTable:@""]];
        
        [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_takenpic"]
                         forState:UIControlStateNormal];
    }
    
    
    //self.autoDownloadThumbImage.hidden = YES;
}

- (void)setToCameraOnScene {
    //=========comment this line by tom==================//
    self.snapButton.enabled = NO;
    //self.mpbToggle.enabled = NO;
    //self.settingButton.enabled = NO;
    self.cameraToggle.userInteractionEnabled = NO;
    self.videoToggle.userInteractionEnabled = NO;
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
         //=========comment this line by tom==================//
       // self.timelapseToggle.enabled = NO;
    }
}

- (void)setToVideoOffScene {
    //=========comment this line by tom==================//
    //[self.mpbToggle setEnabled:YES];
    //[self.settingButton setEnabled:YES];
    //[self.enableAudioButton setEnabled:YES];
    
    // DelayCapture Item
    //=========comment this line by tom==================//
    if ([self capableOf:WifiCamAbilityDelayCapture]/* && ![self.selftimerButton isHidden]*/) {
        
        //[self.selftimerButton setHidden:YES];
        //[self.selftimerLabel setHidden:YES];
        
    }
    
    // CaptureSize Item
    if ([self capableOf:WifiCamAbilityVideoSize]) {
        //=========comment this line by tom==================//
        /*
        if ([self.sizeButton isHidden]) {
            [self.sizeButton setHidden:NO];
            [self.sizeLabel setHidden:NO];
        }
        [self.sizeButton setEnabled:YES];*/
        self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForVideoSize:_camera.curVideoSize];
        [self updateVideoSizeOnScreen:_camera.curVideoSize];
    } else {
        //=========comment this line by tom==================//
        //[self.sizeButton setHidden:YES];
       // [self.sizeLabel setHidden:YES];
    }
    
    // WhiteBalance
    //=========comment this line by tom==================//
    if ([self capableOf:WifiCamAbilityWhiteBalance]/* && [self.awbLabel isHidden]*/) {
        /*[self.awbLabel setHidden:NO];*/
    }
    
    // timelapse icon
    //=========comment this line by tom==================//
    /*if (self.timelapseStateImageView.hidden == NO) {
        self.timelapseStateImageView.hidden = YES;
    }*/
    
    // slow-motion
    if (_camera.curSlowMotion == 1) {
        //=========comment this line by tom==================//
       // self.slowMotionStateImageView.hidden = NO;
    } else {
        //=========comment this line by tom==================//
       // self.slowMotionStateImageView.hidden = YES;
    }
    
    // invert-mode
    if (_camera.curInvertMode == 1) {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = NO;
    } else {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = YES;
    }
    
    // Burst-Capture icon
    //=========comment this line by tom==================//
    /*if (!self.burstCaptureStateImageView.hidden) {
        self.burstCaptureStateImageView.hidden = YES;
    }*/
    
    // Camera Toggle &Timelapse Toggle & Video Toggle
    if ([self capableOf:WifiCamAbilityStillCapture]) {
        if (self.cameraToggle.isHidden) {
            self.cameraToggle.hidden = NO;
        }
        [self.cameraToggle setImage:[UIImage imageNamed:@"control_dashcam_camera_noselect"]
                           forState:UIControlStateNormal];
        self.cameraToggle.userInteractionEnabled = YES;
    }
    
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
         //=========comment this line by tom==================//
       /* if (self.timelapseToggle.isHidden) {
            self.timelapseToggle.hidden = NO;
        }
        [self.timelapseToggle setImage:[UIImage imageNamed:@"timelapse_off"]
                              forState:UIControlStateNormal];
        [self.timelapseToggle setEnabled:YES];*/
    }
    
    if ([self capableOf:WifiCamAbilityMovieRecord]) {
        if (self.videoToggle.isHidden) {
            self.videoToggle.hidden = NO;
        }
        [self.videoToggle setImage:[UIImage imageNamed:@"control_dashcam_video_select"]
                          forState:UIControlStateNormal];
        [self.videoToggle setEnabled:YES];
        [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
        [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
        
        [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_record"]
                         forState:UIControlStateNormal];
        
        // movie record timer label
        if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
            self.movieRecordTimerLabel.textColor = [UIColor whiteColor];
            unsigned int RemainVideoTime = [[SDK instance] retrieveFreeSpaceOfVideo];
            self.movieRecordTimerLabel.text = [Tool translateSecsToString:RemainVideoTime];
            //self.movieRecordTimerLabel.hidden = YES;
        }
    }
    //============comment this line by Tom===============//
    /*if (self.autoDownloadThumbImage.image) {
        self.autoDownloadThumbImage.hidden = NO;
    }*/
    
    
#if 0
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *curLiveSize = [defaults stringForKey:@"LiveSize"];
    if ([defaults boolForKey:@"PreferenceSpecifier:Live"] && curLiveSize) {
        self.liveResolution.text = curLiveSize;
    } else {
        self.liveResolution.text = nil;
    }
#endif
}

- (void)setToVideoOnScene
{
    [self setToVideoOffScene];
    
    if ([self capableOf:WifiCamAbilityStillCapture]) {
        self.cameraToggle.userInteractionEnabled = NO;
    }
    //=========comment this line by tom==================//
    self.videoToggle.userInteractionEnabled = NO;
    //self.mpbToggle.enabled = NO;
    //self.settingButton.enabled = NO;
    //self.enableAudioButton.enabled = NO;
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
         //=========comment this line by tom==================//
       // self.timelapseToggle.enabled = NO;
    }
    if ([self capableOf:WifiCamAbilityVideoSize]) {
        //=========comment this line by tom==================//
        //self.sizeButton.enabled = NO;
    }
    
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        self.movieRecordTimerLabel.textColor = [UIColor whiteColor];
        self.movieRecordTimerLabel.text = @"00:00:00";
        //self.movieRecordTimerLabel.hidden = NO;
    }
}

- (void)setToTimelapseOffScene
{
    //=========comment this line by tom==================//
    //[self.mpbToggle setEnabled:YES];
    //[self.settingButton setEnabled:YES];
    
    //[_ctrl.propCtrl updateAllProperty:_camera];
    int retVal = [_ctrl.propCtrl retrieveCurrentTimelapseInterval];
    if (retVal >= 0) {
        _camera.curTimelapseInterval = retVal;
    }
    
    retVal = [[SDK instance] retrieveTimelapseDuration];
    if (retVal >= 0) {
        _camera.curTimelapseDuration = retVal;
    }
    
    // DelayCapture Item
    //=========comment this line by tom==================//
    if ([self capableOf:WifiCamAbilityDelayCapture]/* && ![self.selftimerButton isHidden]*/) {
        //[self.selftimerButton setHidden:YES];
        //[self.selftimerLabel setHidden:YES];
    }
    
    // CaptureSize Item
    //  if (![self.sizeButton isHidden]) {
    //    [self.sizeButton setHidden:YES];
    //    [self.sizeLabel setHidden:YES];
    //  }
    if ([self capableOf:WifiCamAbilityVideoSize] || [self capableOf:WifiCamAbilityImageSize]) {
        //=========comment this line by tom==================//
       /* if ([self.sizeButton isHidden]) {
            [self.sizeButton setHidden:NO];
            [self.sizeLabel setHidden:NO];
        }
        [self.sizeButton setEnabled:YES];*/
        
        // update current video size. V35 cannot support 4K,2K in timelapse mode, so camera will auto-change video size
        // add by Allen
        _camera.curVideoSize = [_ctrl.propCtrl retrieveCurrentVideoSize2];
        
        //self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForVideoSize:_camera.curVideoSize];
        //        self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForTimeLapseVideoSize:_camera.curVideoSize];
        
        
        if (_camera.timelapseType == WifiCamTimelapseTypeVideo) {
            self.tbVideoSizeArray = [_ctrl.propCtrl prepareDataForTimeLapseVideoSize:_camera.curVideoSize];
            [self updateVideoSizeOnScreen:_camera.curVideoSize];
        } else {
            self.tbPhotoSizeArray = [_ctrl.propCtrl prepareDataForImageSize:_camera.curImageSize];
            [self updateImageSizeOnScreen:_camera.curImageSize];
        }
        
        
        
    } else {
        //=========comment this line by tom==================//
        //self.sizeButton.hidden = NO;
        //self.sizeLabel.hidden = NO;
    }
    
    
    // AWB
    if ([self capableOf:WifiCamAbilityWhiteBalance]
        /*&& self.awbLabel.hidden*/) {
        //self.awbLabel.hidden = NO;
    }
    
    // timelapse icon
    //=========comment this line by tom==================//
    /*if (_camera.curTimelapseInterval != 0) {
        self.timelapseStateImageView.hidden = NO;
    }*/
    
    //=========comment this line by tom==================//
    // slow-motion
    /*if (self.slowMotionStateImageView.hidden == NO) {
        self.slowMotionStateImageView.hidden = YES;
    }*/
    
    //
    if (_camera.curInvertMode == 1) {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = NO;
    } else {
        //=========comment this line by tom==================//
        //self.invertModeStateImageView.hidden = YES;
    }
    
    // Burst-Capture icon
    //=========comment this line by tom==================//
    /*if (!self.burstCaptureStateImageView.hidden) {
        self.burstCaptureStateImageView.hidden = YES;
    }*/
    
    
    // Camera Toggle & Video Toggle &Timelapse Toggle
    if ([self capableOf:WifiCamAbilityStillCapture]) {
        if (self.cameraToggle.isHidden) {
            self.cameraToggle.hidden = NO;
        }
        [self.cameraToggle setImage:[UIImage imageNamed:@"camera_off"]
                           forState:UIControlStateNormal];
        self.cameraToggle.userInteractionEnabled = YES;
    }
    
    if ([self capableOf:WifiCamAbilityMovieRecord]) {
        if (self.videoToggle.isHidden) {
            self.videoToggle.hidden = NO;
        }
        [self.videoToggle setImage:[UIImage imageNamed:@"video_off"]
                          forState:UIControlStateNormal];
        [self.videoToggle setEnabled:YES];
        
        // movie record timer label
        if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
            //self.movieRecordTimerLabel.hidden = YES;
        }
        
    }
    
    if ([self capableOf:WifiCamAbilityTimeLapse]) {
        //============comment this line by Tom===============//
        /*if (self.timelapseToggle.isHidden) {
            self.timelapseToggle.hidden = NO;
        }
        [self.timelapseToggle setImage:[UIImage imageNamed:@"timelapse_on"]
                              forState:UIControlStateNormal];
        
        [self.timelapseToggle setEnabled:YES];*/
        [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
        [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
        
        [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_record"]
                         forState:UIControlStateNormal];
    }
    //============comment this line by Tom===============//
    //self.autoDownloadThumbImage.hidden = YES;
}

- (void)setToTimelapseOnScene
{
    [self setToTimelapseOffScene];
    
    if ([self capableOf:WifiCamAbilityStillCapture]) {
        self.cameraToggle.userInteractionEnabled = NO;
    }
    if ([self capableOf:WifiCamAbilityMovieRecord]) {
        self.videoToggle.userInteractionEnabled = NO;
    }
    //=========comment this line by tom==================//
    //self.mpbToggle.enabled = NO;
    //self.settingButton.enabled = NO;
    //self.timelapseToggle.enabled = NO;
    if ([self capableOf:WifiCamAbilityVideoSize]) {
        //=========comment this line by tom==================//
        //self.sizeButton.enabled = NO;
    }
    
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        self.movieRecordTimerLabel.text = @"00:00:00";
        //self.movieRecordTimerLabel.hidden = NO;
    }
    
}

- (void)updatePreviewSceneByMode:(WifiCamPreviewMode)mode
{
    _camera.previewMode = mode;
    AppLog(@"camera.previewMode: %lu", (unsigned long)_camera.previewMode);
    switch (mode) {
        case WifiCamPreviewModeCameraOff:
            [self setToCameraOffScene];
            break;
        case WifiCamPreviewModeCameraOn:
            [self setToCameraOnScene];
            break;
        case WifiCamPreviewModeVideoOff:
            [self setToVideoOffScene];
            break;
        case WifiCamPreviewModeVideoOn:
            [self setToVideoOnScene];
            break;
        case WifiCamPreviewModeTimelapseOff:
            [self setToTimelapseOffScene];
            break;
        case WifiCamPreviewModeTimelapseOn:
            [self setToTimelapseOnScene];
            break;
        default:
            break;
    }
}

#pragma mark - Preview
- (void)runPreview:(ICatchPreviewMode)mode
{
    if (self.isEnterBackground) {
        return;
    }
    
    AppLog(@"%s start(%d)", __func__, mode);
    self.videoPlayFlag = NO;
    
    self.previewMode = mode;
    dispatch_queue_t previewQ = dispatch_queue_create("WifiCam.GCD.Queue.Preview", DISPATCH_QUEUE_SERIAL);
    dispatch_time_t timeOutCount = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
    
    [self showProgressHUDWithMessage:nil];
    dispatch_async(previewQ, ^{
        if (dispatch_semaphore_wait(_previewSemaphore, timeOutCount) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self showErrorAlertView];
            });
            return;
        }
        
        int ret = ICH_NULL;
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"PreferenceSpecifier:Live"] && (_camera.previewMode == WifiCamPreviewModeVideoOff || _camera.previewMode == WifiCamPreviewModeVideoOn)) {
            ret = [[SDK instance] startMediaStream:mode enableAudio:self.AudioRun enableLive:YES];
        } else {
            ret = [_ctrl.actCtrl startPreview:mode withAudioEnabled:self.AudioRun];
        }
        if (ret != ICH_SUCCEED) {
            dispatch_semaphore_signal(_previewSemaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePreviewSceneByMode:_camera.previewMode];
                [self hideProgressHUD:YES];
                _preview.image = nil;
                //============comment this line by Tom===============//
                //_noPreviewLabel.hidden = NO;
                if (ret == ICH_STREAM_NOT_SUPPORT) {
                    //============comment this line by Tom===============//
                    //_noPreviewLabel.text = NSLocalizedString(@"PreviewNotSupported", nil);
                } else {
                    //============comment this line by Tom===============//
                    //_noPreviewLabel.text = NSLocalizedString(@"StartPVFailed", nil);
                }
                _preview.userInteractionEnabled = NO;
#ifdef HW_DECODE_H264
                _h264View.userInteractionEnabled = NO;
#endif
            });
            return;
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePreviewSceneByMode:_camera.previewMode];
                [self hideProgressHUD:YES];
                //============comment this line by Tom===============//
                //_noPreviewLabel.hidden = YES;
                _preview.userInteractionEnabled = YES;
#ifdef HW_DECODE_H264
                _h264View.userInteractionEnabled = YES;
#endif
                if (![_ctrl.propCtrl checkSDExist]) {
                    [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""] showTime:2.0];
                } else if (((_camera.previewMode == WifiCamPreviewModeCameraOff && _camera.storageSpaceForImage <= 0)
                            || ((_camera.previewMode == WifiCamPreviewModeVideoOff || _camera.previewMode == WifiCamPreviewModeVideoOn) && [[SDK instance] retrieveFreeSpaceOfImage]<=0)) && [_ctrl.propCtrl connected]) {
                    [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""] showTime:2.0];
                } else {
                    
                }
                
#if 1
                [self showLiveGUIIfNeeded:_camera.previewMode];
#else
                if ([[SDK instance] isStreamSupportPublish]) {
                    //============comment this line by Tom===============//
                    //_liveSwitch.hidden = NO;
                    //_liveTitle.hidden = NO;
                    //_liveResolution.hidden = NO;
                } else {
                    //============comment this line by Tom===============//
                    //_liveSwitch.hidden = YES;
                    //_liveTitle.hidden = YES;
                    //_liveResolution.hidden = YES;
                }
#endif
            });
            
            WifiCamSDKEventListener *listener = new WifiCamSDKEventListener(self, @selector(streamCloseCallback));
            self.streamObserver = [[WifiCamObserver alloc] initWithListener:listener
                                                                  eventType:ICATCH_EVENT_MEDIA_STREAM_CLOSED
                                                               isCustomized:NO isGlobal:NO];
            [[SDK instance] addObserver:_streamObserver];
        }
        
        if ([_ctrl.propCtrl audioStreamEnabled] && self.AudioRun) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //=========comment this line by tom==================//
                /*self.enableAudioButton.tag = 0;
                [self.enableAudioButton setBackgroundImage:[UIImage imageNamed:@"audio_on"]
                                                  forState:UIControlStateNormal];
                self.enableAudioButton.enabled = YES;*/
                
            });
            dispatch_group_async(self.previewGroup, self.audioQueue, ^{[self playbackAudio];});
        } else {
            self.AudioRun = NO;
            AppLog(@"Streaming doesn't contains audio.");
        }
        
        
        if ([_ctrl.propCtrl videoStreamEnabled]) {
            dispatch_group_async(self.previewGroup, self.videoQueue, ^{[self playbackVideo];});
        } else {
            AppLog(@"Streaming doesn't contains video.");
        }
        
        dispatch_group_notify(_previewGroup, previewQ, ^{
            [[SDK instance] removeObserver:_streamObserver];
            delete _streamObserver.listener;
            _streamObserver.listener = NULL;
            self.streamObserver = nil;
            
            [_ctrl.actCtrl stopPreview];
            dispatch_semaphore_signal(_previewSemaphore);
        });
    });
}


-(BOOL)dataIsValidJPEG:(NSData *)data
{
    if (!data || data.length < 2) return NO;
    
    NSInteger totalBytes = data.length;
    const char *bytes = (const char*)[data bytes];
    
    return (bytes[0] == (char)0xff &&
            bytes[1] == (char)0xd8 &&
            bytes[totalBytes-2] == (char)0xff &&
            bytes[totalBytes-1] == (char)0xd9);
}

- (BOOL)dataIsIFrame:(NSData *)data {
    if (!data || data.length < 5) return NO;
    
    //    char array[] = {0x00, 0x00, 0x00, 0x01, 0x65};
    const char *bytes = (const char*)[data bytes];
    //    printf("%02x, %02x, %02x, %02x, %02x \n", bytes[0], bytes[1], bytes[2], bytes[3], bytes[4]);
    return bytes[4] == 0x65 ? YES : NO;
}

-(BOOL)initH264Env:(ICatchVideoFormat)format {
    
    AppLog(@"w:%d, h: %d", format.getVideoW(), format.getVideoH());
    
    _spsSize = format.getCsd_0_size()-4;
    _sps = (uint8_t *)malloc(_spsSize);
    memcpy(_sps, format.getCsd_0()+4, _spsSize);
    /*
     printf("sps:");
     for(int i=0;i<_spsSize;++i) {
     printf("0x%x ", _sps[i]);
     }
     printf("\n");
     */
    
    _ppsSize = format.getCsd_1_size()-4;
    _pps = (uint8_t *)malloc(_ppsSize);
    memcpy(_pps, format.getCsd_1()+4, _ppsSize);
    /*
     printf("pps:");
     for(int i=0;i<_ppsSize;++i) {
     printf("0x%x ", _pps[i]);
     }
     printf("\n");
     */
    
    AppLog(@"sps:%ld, pps: %ld", (long)_spsSize, (long)_ppsSize);
    
    const uint8_t* const parameterSetPointers[2] = { _sps, _pps };
    const size_t parameterSetSizes[2] = { static_cast<size_t>(_spsSize), static_cast<size_t>(_ppsSize) };
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault,
                                                                          2, //param count
                                                                          parameterSetPointers,
                                                                          parameterSetSizes,
                                                                          4, //nal start code size
                                                                          &_decoderFormatDescription);
    if(status != noErr) {
        NSLog(@"IOS8VT: reset decoder session failed status=%d", (int)status);
    } else {
        CFDictionaryRef attrs = NULL;
        const void *keys[] = { kCVPixelBufferPixelFormatTypeKey };
        //      kCVPixelFormatType_420YpCbCr8Planar is YUV420
        //      kCVPixelFormatType_420YpCbCr8BiPlanarFullRange is NV12
        uint32_t v = kCVPixelFormatType_32BGRA;
        const void *values[] = { CFNumberCreate(NULL, kCFNumberSInt32Type, &v) };
        attrs = CFDictionaryCreate(NULL, keys, values, 1, NULL, NULL);
        
        VTDecompressionOutputCallbackRecord callBackRecord;
        callBackRecord.decompressionOutputCallback = didDecompress;
        callBackRecord.decompressionOutputRefCon = NULL;
        
        VTDecompressionSessionCreate(kCFAllocatorDefault,
                                     _decoderFormatDescription,
                                     NULL, attrs,
                                     &callBackRecord,
                                     &_deocderSession);
        CFRelease(attrs);
    }
    
    return YES;
}

-(void)clearH264Env {
    if(_deocderSession) {
        VTDecompressionSessionInvalidate(_deocderSession);
        CFRelease(_deocderSession);
        _deocderSession = NULL;
    }
    
    if(_decoderFormatDescription) {
        CFRelease(_decoderFormatDescription);
        _decoderFormatDescription = NULL;
    }
    free(_sps);
    free(_pps);
    _spsSize = _ppsSize = 0;
}

-(void)decodeAndDisplayH264Frame:(NSData *)frame {
    CMBlockBufferRef blockBuffer = NULL;
    CMSampleBufferRef sampleBuffer = NULL;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                         (void*)frame.bytes, frame.length,
                                                         kCFAllocatorNull,
                                                         NULL, 0, frame.length,
                                                         0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        const size_t sampleSizeArray[] = {frame.length};
        
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        CFRelease(blockBuffer);
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        if (status == kCMBlockBufferNoErr) {
            if ([_avslayer isReadyForMoreMediaData]) {
                dispatch_sync(dispatch_get_main_queue(),^{
                    [_avslayer enqueueSampleBuffer:sampleBuffer];
                });
            }
            CFRelease(sampleBuffer);
        }
    }
}

// MARK: - save last video frame
- (CVPixelBufferRef)decodeToPixelBufferRef:(NSData*)vp {
    CVPixelBufferRef outputPixelBuffer = NULL;
    
    CMBlockBufferRef blockBuffer = NULL;
    OSStatus status  = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault,
                                                          (void*)vp.bytes, vp.length,
                                                          kCFAllocatorNull,
                                                          NULL, 0, vp.length,
                                                          0, &blockBuffer);
    if(status == kCMBlockBufferNoErr) {
        CMSampleBufferRef sampleBuffer = NULL;
        const size_t sampleSizeArray[] = {vp.length};
        status = CMSampleBufferCreateReady(kCFAllocatorDefault,
                                           blockBuffer,
                                           _decoderFormatDescription ,
                                           1, 0, NULL, 1, sampleSizeArray,
                                           &sampleBuffer);
        if (status == kCMBlockBufferNoErr && sampleBuffer) {
            VTDecodeFrameFlags flags = 0;
            VTDecodeInfoFlags flagOut = 0;
            OSStatus decodeStatus = VTDecompressionSessionDecodeFrame(_deocderSession,
                                                                      sampleBuffer,
                                                                      flags,
                                                                      &outputPixelBuffer,
                                                                      &flagOut);
            
            if(decodeStatus == kVTInvalidSessionErr) {
                NSLog(@"IOS8VT: Invalid session, reset decoder session");
            } else if(decodeStatus == kVTVideoDecoderBadDataErr) {
                NSLog(@"IOS8VT: decode failed status=%d(Bad data)", (int)decodeStatus);
            } else if(decodeStatus != noErr) {
                NSLog(@"IOS8VT: decode failed status=%d", (int)decodeStatus);
            }
            
            CFRelease(sampleBuffer);
        }
        CFRelease(blockBuffer);
    }
    
    return outputPixelBuffer;
}

- (UIImage *)imageFromPixelBufferRef:(NSData *)data {
    CVPixelBufferRef pixelBuffer = [self decodeToPixelBufferRef:data];
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    UIImage *image = [UIImage imageWithCIImage:ciImage];
    //    AppLog("last image: %@", image);
    return image;
}

- (NSMutableData *)currentVideoData {
    if (_currentVideoData == nil) {
        _currentVideoData = [NSMutableData data];
    }
    
    return _currentVideoData;
}

- (void)recordCurrentVideoFrame:(NSData *)data {
    if ([self dataIsIFrame:data]) {
        self.currentVideoData.length = 0;
        [self.currentVideoData appendData:data];
    }
}

- (void)saveLastVideoFrame:(UIImage *)image {
    CGSize size = CGSizeMake(120, 120);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    self.savedCamera.thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
}

-(void)playbackVideoH264:(ICatchVideoFormat) format {
    //    NSMutableData *videoFrameData = nil;
#ifdef HW_DECODE_H264
    NSRange headerRange = NSMakeRange(0, 4);
    NSMutableData *headFrame = nil;
    uint32_t nalSize = 0;
#else

#endif
    
    while (_PVRun) {
#ifdef HW_DECODE_H264
        if (_readyGoToSetting) {
            AppLog(@"Sleep 1 second.");
            [NSThread sleepForTimeInterval:1.0];
            continue;
        }
        
        //flush avslayer when active from background
        if (self.avslayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
            [self.avslayer flush];
        }
        
        // HW decode
        [self initH264Env:format];
        for(;;) {
            @autoreleasepool {
                // 1st frame contains sps & pps data.
#if RUN_DEBUG
                NSDate *begin = [NSDate date];
                WifiCamAVData *avData = [[SDK instance] getVideoData2];
                NSDate *end = [NSDate date];
                NSTimeInterval elapse = [end timeIntervalSinceDate:begin];
                AppLog(@"[V]Get %lu, elapse: %f", (unsigned long)avData.data.length, elapse);
#else
                NSDate *begin = [NSDate date];
                WifiCamAVData *avData = [[SDK instance] getVideoData2];
#endif
                if (avData.data.length > 0) {
                    self.curVideoPTS = avData.time;
                    
                    NSUInteger loc = (4+_spsSize)+(4+_ppsSize);
                    nalSize = (uint32_t)(avData.data.length - loc - 4);
                    NSRange iRange = NSMakeRange(loc, avData.data.length - loc);
                    const uint8_t lengthBytes[] = {(uint8_t)(nalSize>>24),
                        (uint8_t)(nalSize>>16), (uint8_t)(nalSize>>8), (uint8_t)nalSize};
                    headFrame = [NSMutableData dataWithData:[avData.data subdataWithRange:iRange]];
                    [headFrame replaceBytesInRange:headerRange withBytes:lengthBytes];
                    NSDate *end1 = [NSDate date];
                    
                    [self decodeAndDisplayH264Frame:headFrame];
                    NSDate *end = [NSDate date];
                    AppLog(@"getVideoDataTime: %f, decodeTime: %f, PTS: %f", [end1 timeIntervalSinceDate:begin] * 1000, [end timeIntervalSinceDate:end1] * 1000, avData.time);
                    
                    [self recordCurrentVideoFrame:headFrame];
                    break;
                }
            }
        }
        while (_PVRun) {
            @autoreleasepool {
#if RUN_DEBUG
                NSDate *begin = [NSDate date];
                WifiCamAVData *avData = [[SDK instance] getVideoData2];
                NSDate *end = [NSDate date];
                NSTimeInterval elapse = [end timeIntervalSinceDate:begin];
                AppLog(@"[V]Get %lu, elapse: %f", (unsigned long)avData.data.length, elapse);
#else
                WifiCamAVData *avData = [[SDK instance] getVideoData2];
#endif
                if (avData.data.length > 0) {
                    self.curVideoPTS = avData.time;
                    nalSize = (uint32_t)(avData.data.length - 4);
                    const uint8_t lengthBytes[] = {(uint8_t)(nalSize>>24),
                        (uint8_t)(nalSize>>16), (uint8_t)(nalSize>>8), (uint8_t)nalSize};
                    [avData.data replaceBytesInRange:headerRange withBytes:lengthBytes];
                    self.videoPlayFlag = YES;
                    [self decodeAndDisplayH264Frame:avData.data];
                    
                    [self recordCurrentVideoFrame:avData.data];
                }
            }
        }
        
        if (self.currentVideoData.length > 0) {
            [self saveLastVideoFrame:[self imageFromPixelBufferRef:self.currentVideoData]];
        }
        
        [self clearH264Env];
#else
        // Decode using FFmpeg
        videoFrameData = [[SDK instance] getVideoData];
        if (videoFrameData) {
            [ff_h264_decoder fillData:(uint8_t *)videoFrameData.bytes
                                 size:videoFrameData.length];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *receivedImage = ff_h264_decoder.currentImage;
                if (_PVRun && receivedImage) {
                    _preview.image = receivedImage;
                }
                
            });
            
        }
#endif
    }
}

-(void)playbackVideoMJPEG {
    //    NSMutableData *videoFrameData = nil;
    //    UIImage *receivedImage = nil;
    
    while (_PVRun) {
        @autoreleasepool {
            if (_readyGoToSetting) {
                AppLog(@"Sleep 1 second.");
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
#if RUN_DEBUG
            NSDate *begin = [NSDate date];
            WifiCamAVData *avData = [[SDK instance] getVideoData2];
            NSDate *end = [NSDate date];
            NSTimeInterval elapse = [end timeIntervalSinceDate:begin];
            AppLog(@"[V]Get %lu, elapse: %f", (unsigned long)avData.data.length, elapse);
#else
            WifiCamAVData *avData = [[SDK instance] getVideoData2];
#endif
            if (avData.data.length > 0) {
                self.curVideoPTS = avData.time;
                if (![self dataIsValidJPEG:avData.data]) {
                    AppLog(@"Invalid JPEG.");
                    continue;
                }
                
                UIImage *receivedImage = [[UIImage alloc] initWithData:avData.data];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (_PVRun && receivedImage) {
                        self.videoPlayFlag = YES;
                        //                        TRACE();
                        _preview.image = receivedImage;
                        
                    }
                });
                
                //            videoFrameData = nil;
                receivedImage = nil;
            }
        }
    }
}

- (void)playbackVideo {
    
    /*
     dispatch_queue_t mainQueue = dispatch_get_main_queue();
     NSMutableData *videoFrameData = nil;
     UIImage *receivedImage = nil;
     */
    
    ICatchVideoFormat format = [_ctrl.propCtrl retrieveVideoFormat];
    if (format.getCodec() == ICATCH_CODEC_JPEG) {
        AppLog(@"playbackVideoMJPEG");
#ifdef HW_DECODE_H264
        dispatch_async(dispatch_get_main_queue(), ^{
            _preview.hidden = NO;
            //_avslayer.hidden = YES;
            _h264View.hidden = YES;
        });
#endif
        [self playbackVideoMJPEG];
        
    } else if (format.getCodec() == ICATCH_CODEC_H264) {
        
        AppLog(@"playbackVideoH264");
#ifdef HW_DECODE_H264
        // HW decode
        dispatch_async(dispatch_get_main_queue(), ^{
            //_avslayer.hidden = NO;
            _h264View.hidden = NO;
            _avslayer.frame = _preview.frame;
            /*_avslayer.position = CGPointMake(CGRectGetMidX(_preview.bounds), CGRectGetMidY(_preview.bounds));*/
            _preview.hidden = YES;
        });
#endif
        [self playbackVideoH264:format];
    } else {
        AppLog(@"Unknown codec.");
    }
    
    AppLog(@"Break video");
}

- (void)playbackAudio {
    /*
     NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
     NSString *cacheDirectory = [paths objectAtIndex:0];
     NSString *toFilePath = [cacheDirectory stringByAppendingPathComponent:@"test.raw"];
     AppLog(@"TO : %@", toFilePath);
     FILE *toFileHandle = fopen(toFilePath.UTF8String, "wb");
     */
    //    NSData *audioBufferData = nil;
    //    NSMutableData *audioBuffer3Data = [[NSMutableData alloc] init];
    self.al = [[HYOpenALHelper alloc] init];
    ICatchAudioFormat format = [_ctrl.propCtrl retrieveAudioFormat];
    
    AppLog(@"freq: %d, chl: %d, bit:%d", format.getFrequency(), format.getNChannels(), format.getSampleBits());
    
    if (![_al initOpenAL:format.getFrequency() channel:format.getNChannels() sampleBit:format.getSampleBits()]) {
        AppLog(@"Init OpenAL failed.");
        return;
    }
    
    while (_PVRun) {
        @autoreleasepool {
            if (_readyGoToSetting || !_AudioRun) {
                [NSThread sleepForTimeInterval:1.0];
                continue;
            }
            
            NSDate *begin = [NSDate date];
            WifiCamAVData *wifiCamData = [[SDK instance] getAudioData2];
            NSDate *end = [NSDate date];
            NSTimeInterval elapse = [end timeIntervalSinceDate:begin];
            AppLog(@"[A]Get %lu, elapse: %f", (unsigned long)wifiCamData.data.length, elapse);
            
            if (wifiCamData.data.length > 0 && self.videoPlayFlag) {
                [_al insertPCMDataToQueue:wifiCamData.data.bytes
                                     size:wifiCamData.data.length];
                [_al play];
            }
            
            //            if (wifiCamData.time >= _curVideoPTS + 0.1 && _curVideoPTS != 0) {
            //                [NSThread sleepForTimeInterval:0.003];
            //            }
            //            if((wifiCamData.time >= _curVideoPTS - 0.25 && _curVideoPTS != 0) ||
            //               (wifiCamData.time <= _curVideoPTS + 0.25 && _curVideoPTS != 0)) {
            //                [_al play];
            //            } else {
            //                [_al pause];
            //            }
            //        }
            
            //                    int count = [_al getInfo];
            //                    if(count < 4) {
            //                        if (count == 1) {
            //                            [_al play];
            //                        }
            //
            //                        [audioBuffer3Data setLength:0];
            //
            //                        for (int i=0; i<3; ++i) {
            //
            //                            NSDate *begin = [NSDate date];
            //                            WifiCamAVData *wifiCamData = [[SDK instance] getAudioData2];
            //                            NSDate *end = [NSDate date];
            //                            NSTimeInterval elapse = [end timeIntervalSinceDate:begin];
            //                            AppLog(@"[A]Get %lu, elapse: %f", (unsigned long)wifiCamData.data.length, elapse);
            //
            //                            if (wifiCamData) {
            //                                [audioBuffer3Data appendData:wifiCamData.data];
            //                            }
            //                        }
            //
            //                        if(audioBuffer3Data.length>0) {
            //                            [_al insertPCMDataToQueue:audioBuffer3Data.bytes
            //                                                 size:audioBuffer3Data.length];
            //                        }
            //                    }
        }
    }
    [_al clean];
    self.al = nil;
    /*
     fwrite(audioBufferData.bytes, sizeof(char), audioBufferData.length, toFileHandle);
     fclose(toFileHandle);
     */
    AppLog(@"Break audio");
}

- (IBAction)toggleAudio:(UIButton *)sender {
    [self showProgressHUDWithMessage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(![[SDK instance] openAudio: sender.tag == 0 ? NO : YES]) {
            [self hideProgressHUD:YES];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (sender.tag == 0) {
                sender.tag = 1;
                [sender setBackgroundImage:[UIImage imageNamed:@"audio_off"]
                                  forState:UIControlStateNormal];
                self.AudioRun = NO;
            } else {
                sender.tag = 0;
                [sender setBackgroundImage:[UIImage imageNamed:@"audio_on"]
                                  forState:UIControlStateNormal];
                self.AudioRun = YES;
            }
            [self hideProgressHUD:YES];
            _camera.enableAudio = self.AudioRun;
        });
    });
}

- (IBAction)captureAction:(id)sender
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
        self.NvtPreviewMode = [self NvtGetPreivewMode];
        if([self.NvtPreviewMode isEqualToString:@"4"])
        {
            [self showProgressHUDWithMessage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(_stillCaptureSound);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self NvtStillModeRemainNumber];
                    [self hideProgressHUD:YES];
                    
                });
                [self NvtStillCapture];
            });
        }
        else
        {
            
            _snapButton.selected = !_snapButton.selected;
            
            if(_snapButton.selected)
            {
                NvtStateRecording = 1;
                [self showProgressHUDWithMessage:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_np stop:NO];
                    [self NvtMovieRecordingStart];
                   /* dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);*/
                    dispatch_semaphore_wait(_previewSemaphore, DISPATCH_TIME_FOREVER);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [_np start];
                        [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                        [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                        
                        [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_record_stop"] forState:UIControlStateNormal];
                        self.movieRecordTimerLabel.textColor = [UIColor whiteColor];
                        self.movieRecordTimerLabel.text = @"00:00:00";
                        if (![_videoCaptureTimer isValid]) {
                            self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                    target  :self
                                                                                    selector:@selector(movieRecordingTimerCallback:)
                                                                                    userInfo:nil
                                                                                    repeats :YES];
                        }
                        
                        
                         //[self NvtVideoRecordingTime];
                        
                    });
                });
            }
            else
            {
                NvtStateRecording = 0;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self NvtMovieRecordingStop];
                    if ([_videoCaptureTimer isValid]) {
                        [_videoCaptureTimer invalidate];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.movieRecordTimerLabel.textColor = [UIColor whiteColor];
                        [_titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                        [_titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                        
                        [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
                        [self NvtVideoModeRemainTime];
                        
                    });
                });
            }

        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        NSLog(@"_camera.cameraMode: %d", _camera.cameraMode);
        // Capture
        switch(_camera.previewMode) {
            case WifiCamPreviewModeCameraOff:
                [self stillCapture];
                break;
            case WifiCamPreviewModeVideoOff:
                [self startMovieRec];
                break;
            case WifiCamPreviewModeVideoOn:
                [self stopMovieRec];
                break;
            case WifiCamPreviewModeCameraOn:
                break;
            case WifiCamPreviewModeTimelapseOff:
                if (_camera.curTimelapseInterval != 0 && _camera.curTimelapseDuration>0) {
                    [self startTimelapseRec];
                } else {
                    [self showTimelapseOffAlert];
                }
                break;
            case WifiCamPreviewModeTimelapseOn:
                [self stopTimelapseRec];
                break;
            default:
                break;
        }
    }
}

- (void)showTimelapseOffAlert {
    [self showProgressHUDNotice:[delegate getStringForKey:@"TimelapseOff" withTable:@""] showTime:2.0];
}

- (void)stillCapture {
   
    if (![self capableOf:WifiCamAbilityNewCaptureWay]) {
        [self showProgressHUDWithMessage:nil];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOn];
        });
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //        dispatch_async(dispatch_get_main_queue(), ^{
        [self updateImageSizeOnScreen:_camera.curImageSize];
        //        });
        
        if (![_ctrl.propCtrl checkSDExist]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""]
                                   showTime:1.0];
                [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
            });
            return;
        }
        if ([[SDK instance] retrieveFreeSpaceOfImage]<=0/*![[SDK instance] checkstillCapture]*/ && [_ctrl.propCtrl connected]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""]
                                   showTime:1.0];
                [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
            });
            return;
        }
        
        if (![[SDK instance] checkstillCapture]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"STREAM_CAPTURE_FAILED" withTable:@""]
                                   showTime:1.0];
                [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
            });
            return;
        }
        
        self.burstCaptureCount = [[_staticData.burstNumberDict objectForKey:@(_camera.curBurstNumber)] integerValue];
        NSInteger delayCaptureCount = [[_staticData.delayCaptureDict objectForKey:@(_camera.curCaptureDelay)] integerValue]*2 - 1;
        
        // Stop streaming right now?
        if (// Doesn't support delay-capture, stop right now.
            ![self capableOf:WifiCamAbilityDelayCapture]
            // Support delay-capture, but it's OFF, stop right now.
            || _camera.curCaptureDelay == CAP_DELAY_NO
            
            // Doesn't support ***(stop after delay), stop right now.
            || ![self capableOf:WifiCamAbilityLatestDelayCapture]) {
            
            if (![self capableOf:WifiCamAbilityBurstNumber] || _burstCaptureCount == 0 || _burstCaptureCount > 0) {
                
                AudioServicesPlaySystemSound(_stillCaptureSound);
            }
            
            if (![self capableOf:WifiCamAbilityNewCaptureWay]) {
                AppLog(@"Stop PV");
                self.PVRun = NO;
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
                if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [self showErrorAlertView];
                        [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
                    });
                    return;
                }
            }
        } else {
            AppLog(@"Don't stop right now.");
        }
        
        
        // Capture
        stillCaptureDoneListener = new StillCaptureDoneListener(self);
        [_ctrl.comCtrl addObserver:ICATCH_EVENT_CAPTURE_COMPLETE
                          listener:stillCaptureDoneListener
                       isCustomize:NO];
        if( [self capableOf:WifiCamAbilityLatestDelayCapture] ){
            
            [_ctrl.actCtrl triggerCapturePhoto];
            [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
            dispatch_async(dispatch_get_main_queue(), ^{
            self.movieRecordTimerLabel.text = [[NSString alloc] initWithFormat:@"%d",[[SDK instance] retrieveFreeSpaceOfImage]];
            });
            // Delay-capture sound effect
            if ([self capableOf:WifiCamAbilityDelayCapture] && delayCaptureCount > 0) {
                NSUInteger edgedCount = delayCaptureCount/2;
                
                BOOL isRush = NO;
                while (delayCaptureCount > 0) {
                    AudioServicesPlaySystemSound(_delayCaptureSound);
                    
                    if (delayCaptureCount > edgedCount && !isRush) {
                        [NSThread sleepForTimeInterval:0.5];AppLog(@"sleep 0.5s");
                    } else {
                        if (!isRush) {
                            delayCaptureCount *= 2;
                        }
                        [NSThread sleepForTimeInterval:0.25];AppLog(@"sleep 0.25s");
                        isRush = YES;
                    }
                    --delayCaptureCount;
                }
                
                AppLog(@"Stop streaming ASAP before camera take a picture.");
                AudioServicesPlaySystemSound(_stillCaptureSound);
                
                
                
                if ([self capableOf:WifiCamAbilityLatestDelayCapture] && ![self capableOf:WifiCamAbilityNewCaptureWay]) {
                    AppLog(@"Stop PV");
                    self.PVRun = NO;
                    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 5ull * NSEC_PER_SEC);
                    if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self hideProgressHUD:YES];
                            [self showErrorAlertView];
                            [self updatePreviewSceneByMode:WifiCamPreviewModeCameraOff];
                        });
                    }
                }
            } else if ([self capableOf:WifiCamAbilityBurstNumber] && _burstCaptureCount > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.burstCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:0.15
                                                                            target  :self
                                                                            selector:@selector(burstCaptureTimerCallback:)
                                                                            userInfo:nil
                                                                            repeats :YES];
                });
            }
        }
        else // use old capture procedure
        {
            [_ctrl.actCtrl capturePhoto];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.movieRecordTimerLabel.text = [[NSString alloc] initWithFormat:@"%d",[[SDK instance] retrieveFreeSpaceOfImage]];
        });
        
    });
}

- (void)startMovieRec {
    AudioServicesPlaySystemSound(_videoCaptureSound);
    [self showProgressHUDWithMessage:nil];
    AppLog(@"startMovieRec");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateVideoSizeOnScreen:_camera.curVideoSize];
        });
        
        if (![_ctrl.propCtrl checkSDExist]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""]
                                   showTime:1.0];
            });
            return;
        }
        NSLog(@"timerRERRRRR->   %d",[[SDK instance] retrieveFreeSpaceOfImage]);
        if ([[SDK instance] retrieveFreeSpaceOfImage]<=0 && [_ctrl.propCtrl connected]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""]
                                   showTime:1.0];
            });
            return;
        }
        
        //if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
            AppLog(@"Support to get recorded time!");
            videoRecPostTimeListener = new VideoRecPostTimeListener(self);
            [_ctrl.comCtrl addObserver:(ICatchEventID)0x5001
                              listener:videoRecPostTimeListener
                           isCustomize:YES];
        //} else {
        //    AppLog(@"Don't support to get recorded time.");
        //}
        
        TRACE();
        BOOL ret = [_ctrl.actCtrl startMovieRecord];
        TRACE();
        [NSThread sleepForTimeInterval:0.2];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                [self updatePreviewSceneByMode:WifiCamPreviewModeVideoOn];
                [self addMovieRecListener];
                
                //if (![self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                    if (![_videoCaptureTimer isValid]) {
                        self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                target  :self
                                                                                selector:@selector(movieRecordingTimerCallback:)
                                                                                userInfo:nil
                                                                                repeats :YES];
                    }
                //}
                [self hideProgressHUD:YES];
                _Recording = YES;
            } else {
                [self showProgressHUDNotice:@"Failed to begin movie recording." showTime:2.0];
                //if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                    [_ctrl.comCtrl removeObserver:(ICatchEventID)0x5001
                                         listener:videoRecPostTimeListener
                                      isCustomize:YES];
                    if (videoRecPostTimeListener) {
                        delete videoRecPostTimeListener;
                        videoRecPostTimeListener = NULL;
                    }
                //}
            }
        });
    });
}

- (void)stopMovieRec
{
    AudioServicesPlaySystemSound(_videoCaptureSound);
    [self showProgressHUDWithMessage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
            [_ctrl.comCtrl removeObserver:(ICatchEventID)0x5001
                                 listener:videoRecPostTimeListener
                              isCustomize:YES];
            if (videoRecPostTimeListener) {
                delete videoRecPostTimeListener;
                videoRecPostTimeListener = NULL;
            }
        //}
        TRACE();
        BOOL ret = [_ctrl.actCtrl stopMovieRecord];
        TRACE();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                if (!_Living) {
                    [self updatePreviewSceneByMode:WifiCamPreviewModeVideoOff];
                } else {
                    _camera.previewMode = WifiCamPreviewModeVideoOff;
                }
                [self remMovieRecListener];
                if ([_videoCaptureTimer isValid]) {
                    [_videoCaptureTimer invalidate];
                    self.movieRecordElapsedTimeInSeconds = 0;
                }
                [self hideProgressHUD:YES];
                _Recording = NO;
            } else {
                [self showProgressHUDNotice:@"Failed to stop movie recording."
                                   showTime:2.0];
            }
        });
    });
}

- (void)startTimelapseRec {
    AudioServicesPlaySystemSound(_videoCaptureSound);
    [self showProgressHUDWithMessage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_camera.timelapseType == WifiCamTimelapseTypeStill) {
                [self updateImageSizeOnScreen:_camera.curImageSize];
            } else {
                [self updateVideoSizeOnScreen:_camera.curVideoSize];
            }
        });
        
        if (![_ctrl.propCtrl checkSDExist]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""]
                                   showTime:1.5];
            });
            
            return;
        }
        if ([_ctrl.propCtrl connected]) {
            if (_camera.timelapseType == WifiCamTimelapseTypeStill && [[SDK instance] retrieveFreeSpaceOfImage]<=0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""]
                                       showTime:1.0];
                });
                return;
            } else if (_camera.timelapseType == WifiCamTimelapseTypeVideo && [[SDK instance] retrieveFreeSpaceOfImage]<=0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""]
                                       showTime:1.0];
                });
                return;
            } else {
                
            }
        }
        
        BOOL ret = [_ctrl.actCtrl startTimelapseRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                [self updatePreviewSceneByMode:WifiCamPreviewModeTimelapseOn];
                [self addTimelapseRecListener];
                if (![_videoCaptureTimer isValid]) {
                    self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                            target  :self
                                                                            selector:@selector(movieRecordingTimerCallback:)
                                                                            userInfo:nil
                                                                            repeats :YES];
                }
                [self hideProgressHUD:YES];
            } else {
                [self showProgressHUDNotice:@"Failed to begin time-lapse recording" showTime:2.0];
            }
            
        });
    });
}

- (void)stopTimelapseRec {
    AudioServicesPlaySystemSound(_videoCaptureSound);
    [self showProgressHUDWithMessage:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL ret = [_ctrl.actCtrl stopTimelapseRecord];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret) {
                [self remTimelapseRecListener];
                [self hideProgressHUD:YES];
            } else {
                [self showProgressHUDNotice:@"Failed to stop time-lapse recording" showTime:2.0];
            }
            
            if ([_videoCaptureTimer isValid]) {
                [_videoCaptureTimer invalidate];
                self.movieRecordElapsedTimeInSeconds = 0;
            }
            [self updatePreviewSceneByMode:WifiCamPreviewModeTimelapseOff];
        });
    });
}




- (void)movieRecordingTimerCallback:(NSTimer *)sender {
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        if(_snapButton.selected)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                   // [self.snapButton setImage:[UIImage imageNamed:@"stop_off"] forState:UIControlStateNormal];
                   // self.movieRecordTimerLabel.textColor = [UIColor redColor];
                    [self NvtVideoRecordingTime];
                    
                });
            });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    //self.movieRecordTimerLabel.textColor = [UIColor whiteColor];
                    //[self.snapButton setImage:[UIImage imageNamed:@"stop_on"] forState:UIControlStateNormal];
                    [self NvtVideoModeRemainTime];
                });
            });
        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        UIImage *image = nil;
        if (_videoCaptureStopOn) {
            self.videoCaptureStopOn = NO;
            image = _stopOff;
        } else {
            self.videoCaptureStopOn = YES;
            image = _stopOff;
        }
        //if (_movieRecordElapsedTimeInSeconds < _camera.storageSpaceForVideo
        //    || _camera.previewMode == WifiCamPreviewModeTimelapseOn) {
        ++self.movieRecordElapsedTimeInSeconds;
        //}
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.snapButton setImage:image forState:UIControlStateNormal];
        });
    }
}


- (void)burstCaptureTimerCallback:(NSTimer *)sender {
    AppLog(@"_burstCaptureCount: %lu", (unsigned long)_burstCaptureCount);
    if (self.burstCaptureCount-- <= 0) {
        [sender invalidate];
    } else {
        AppLog(@"burst capture... %lu", (unsigned long)_burstCaptureCount);
        AudioServicesPlaySystemSound(_burstCaptureSound);
    }
}

- (IBAction)showZoomController:(UITapGestureRecognizer *)sender {
    //============comment this line by Tom===============//
    /*
    if ([self capableOf:WifiCamAbilityDateStamp] && _camera.curDateStamp != DATE_STAMP_OFF) {
        return;
    }
    if ([self capableOf:WifiCamAbilityZoom] && _zoomSlider.hidden) {
        [self hideZoomController:NO];
        if (![_hideZoomControllerTimer isValid]) {
            _hideZoomControllerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                        target:self
                                                                      selector:@selector(autoHideZoomController)
                                                                      userInfo:nil
                                                                       repeats:NO];
        }
    } else {
        [self hideZoomController:YES];
    }*/
}

- (void)hideZoomController: (BOOL)value {
    //============comment this line by Tom===============//
    //_zoomSlider.hidden = value;
    //_zoomInButton.hidden = value;
    //_zoomOutButton.hidden = value;
    //_zoomValueLabel.hidden = value;
}

- (void)autoHideZoomController
{
    //============comment this line by Tom===============//
   // [self hideZoomController:YES];
}

- (IBAction)zoomCtrlBeenTouched:(id)sender {
    //============comment this line by Tom===============//
    //[_hideZoomControllerTimer invalidate];
}

- (IBAction)zoomValueChanged:(id)sender {
    //============comment this line by Tom===============//
  /*  __block BOOL err = NO;
    //[_hideZoomControllerTimer invalidate];
    
    [self showProgressHUDWithMessage:NSLocalizedString(@"STREAM_ERROR_CAPTURING_CAPTURE", nil)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        uint curZoomRatio = [_ctrl.propCtrl retrieveCurrentZoomRatio];
        uint tryCount = 0;
        
        AppLog(@"curZoomRatio: %d", curZoomRatio);
        AppLog(@"self.zoomSlider.value: %f", self.zoomSlider.value);
        if (self.zoomSlider.value*10.0 > curZoomRatio) {
            while (self.zoomSlider.value*10.0 > curZoomRatio) {
                AppLog(@"zoomIn:%d", curZoomRatio);
                [_ctrl.actCtrl zoomIn];
                uint r = [_ctrl.propCtrl retrieveCurrentZoomRatio];
                if (r <= curZoomRatio) {
                    AppLog(@"r, curZoomRatio: %d, %d", r, curZoomRatio);
                    if (tryCount++ > 20) {
                        err = YES;
                        break;
                    } else {
                        [NSThread sleepForTimeInterval:0.1];
                    }
                } else {
                    
                    curZoomRatio = r;
                }
            }
        } else if (self.zoomSlider.value*10.0  < curZoomRatio){
            while (self.zoomSlider.value*10.0 < curZoomRatio) {
                AppLog(@"zoomOut:%d", curZoomRatio);
                [_ctrl.actCtrl zoomOut];
                uint r = [_ctrl.propCtrl retrieveCurrentZoomRatio];
                if (r >= curZoomRatio) {
                    AppLog(@"r, curZoomRatio: %d, %d", r, curZoomRatio);
                    if (tryCount++ > 20) {
                        err = YES;
                        break;
                    } else {
                        [NSThread sleepForTimeInterval:0.1];
                    }
                } else {
                    curZoomRatio = r;
                }
            }
            
        } else {
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (err) {
                UISlider *slider = sender;
                slider.value = curZoomRatio / 10.0;
                [self showProgressHUDNotice:NSLocalizedString(@"Zoom In/Out failed.", nil) showTime:1.0];
            } else {
                _zoomValueLabel.text = [NSString stringWithFormat:@"x%0.1f", curZoomRatio/10.0];
                [self hideProgressHUD:YES];
            }
            self.zoomSlider.value = curZoomRatio / 10.0;//add 2016.12.27 (move the zoom bar)
            
            if (![_hideZoomControllerTimer isValid]) {
                _hideZoomControllerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                            target:self
                                                                          selector:@selector(autoHideZoomController)
                                                                          userInfo:nil
                                                                           repeats:NO];
            }
        });
    });
    */
}

- (IBAction)zoomIn:(id)sender {
    //============comment this line by Tom===============//
    /*[_hideZoomControllerTimer invalidate];
    
    [self showProgressHUDWithMessage:NSLocalizedString(@"STREAM_ERROR_CAPTURING_CAPTURE", nil)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_ctrl.actCtrl zoomIn];
        uint curZoomRatio = [_ctrl.propCtrl retrieveCurrentZoomRatio];
        AppLog(@"curZoomRatio: %d", curZoomRatio);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
            [self updateZoomCtrl:curZoomRatio];
        });
    });*/
    
}

- (IBAction)zoomOut:(id)sender {
    //============comment this line by Tom===============//
   /* [_hideZoomControllerTimer invalidate];
    
    [self showProgressHUDWithMessage:NSLocalizedString(@"STREAM_ERROR_CAPTURING_CAPTURE", nil)];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_ctrl.actCtrl zoomOut];
        uint curZoomRatio = [_ctrl.propCtrl retrieveCurrentZoomRatio];
        AppLog(@"curZoomRatio: %d", curZoomRatio);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
            [self updateZoomCtrl:curZoomRatio];
        });
    });*/
}

- (void)updateZoomCtrl: (uint)curZoomRatio {
    //============comment this line by Tom===============//
    /*self.zoomSlider.value = curZoomRatio/10.0;
    _zoomValueLabel.text = [NSString stringWithFormat:@"x%0.1f", curZoomRatio/10.0];
    
    if (![_hideZoomControllerTimer isValid]) {
        _hideZoomControllerTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                                    target:self
                                                                  selector:@selector(autoHideZoomController)
                                                                  userInfo:nil
                                                                   repeats:NO];
    }*/
    
}

- (void)showBusyNotice
{
    NSString *busyInfo = nil;
    
    if (_camera.previewMode == WifiCamPreviewModeCameraOn) {
        busyInfo = @"STREAM_ERROR_CAPTURING";
    } else if (_camera.previewMode == WifiCamPreviewModeVideoOn) {
        busyInfo = @"STREAM_ERROR_RECORDING";
    } else if (_camera.previewMode == WifiCamPreviewModeTimelapseOn) {
        busyInfo = @"STREAM_ERROR_CAPTURING";
    }
    [self showProgressHUDNotice:[delegate getStringForKey:busyInfo withTable:@""] showTime:2.0];
}


- (IBAction)settingAction:(id)sender {
    TRACE();
    //    dispatch_suspend(_audioQueue);
    //    dispatch_suspend(_videoQueue);
    //    if( _camera.previewMode != WifiCamPreviewModeCameraOff &&  _camera.previewMode != WifiCamPreviewModeCameraOn)
    //    [self stopYoutubeLive];
    self.PVRun = NO;
    self.readyGoToSetting = YES;
    [self performSegueWithIdentifier:@"goSettingSegue" sender:sender];
}

-(void)goHome {
    TRACE();
    self.readyGoToSetting = NO;
    //    dispatch_resume(_audioQueue);
    //    dispatch_resume(_videoQueue);
}

- (IBAction)mpbAction:(id)sender
{
    [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![_ctrl.propCtrl checkSDExist]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showProgressHUDNotice:[delegate getStringForKey:@"NoCard" withTable:@""] showTime:2.0];
            });
            return;
        }
        
        //        [self stopYoutubeLive];
        self.PVRun = NO;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if ((dispatch_semaphore_wait(_previewSemaphore, time) != 0)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self showErrorAlertView];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                dispatch_semaphore_signal(_previewSemaphore);
                [self hideProgressHUD:YES];
                [self performSegueWithIdentifier:@"goMpbSegue" sender:sender];
                
            });
        }
    });
}

- (IBAction)changeToCameraState:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        self.NvtPreviewMode = [self NvtGetPreivewMode];
        if(![self.NvtPreviewMode isEqualToString:@"4"])
        {
            [self showProgressHUDWithMessage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(_changeModeSound);
                [self NvtSetPreivewMode:@"3001" Par2:@"0"];
                [_np stop:NO];
                [_np setInputUrl:@"http://192.168.1.254:8192"];
                [_np start];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.videoToggle setImage:[UIImage imageNamed:@"video_off"] forState:UIControlStateNormal];
                    [self.cameraToggle setImage:[UIImage imageNamed:@"camera_on"] forState:UIControlStateNormal];
                    [_titleIcon setImage:[UIImage imageNamed:@"title_camera"]];
                    [_titleText setText:[delegate getStringForKey:@"SetPhotoMode" withTable:@""]];
                    [self.snapButton setImage:[UIImage imageNamed:@"control_dashcam_takenpic"] forState:UIControlStateNormal];
                    [self NvtStillModeRemainNumber];
                    [self hideProgressHUD:YES];
                    //[self NvtStillCapture];
                    
    
                });
            });
        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        if (_camera.previewMode == WifiCamPreviewModeCameraOff) {
            return;
        }
        [self showProgressHUDWithMessage:nil];
        self.movieRecordTimerLabel.text = [[NSString alloc] initWithFormat:@"%d",[[SDK instance] retrieveFreeSpaceOfImage]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AudioServicesPlaySystemSound(_changeModeSound);
            //        [self stopYoutubeLive];
            self.PVRun = NO;
            _camera.previewMode = WifiCamPreviewModeCameraOff;
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
            if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressHUD:YES];
                    [self showErrorAlertView];
                });
            } else {
                dispatch_semaphore_signal(_previewSemaphore);
                self.PVRun = YES;

                [self runPreview:ICATCH_STILL_PREVIEW_MODE];
            }
        });
    }
}

- (IBAction)changeToVideoState:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
         self.NvtPreviewMode = [self NvtGetPreivewMode];
        if(![self.NvtPreviewMode isEqualToString:@"0"])
        {
            [self showProgressHUDWithMessage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(_changeModeSound);
                [self NvtSetPreivewMode:@"3001" Par2:@"1"];
                [_np stop:NO];
                [_np setInputUrl:@"rtsp://192.168.1.254/xxx.mov"];
                [_np start];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.videoToggle setImage:[UIImage imageNamed:@"control_dashcam_video_select"] forState:UIControlStateNormal];
                    [self.cameraToggle setImage:[UIImage imageNamed:@"camera_off"] forState:UIControlStateNormal];
                    [self.snapButton setImage:[UIImage imageNamed:@"icon_record"] forState:UIControlStateNormal];

                    [self NvtVideoModeRemainTime];
                    [self hideProgressHUD:YES];
                });
            });
        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        if (_camera.previewMode == WifiCamPreviewModeVideoOff) {
            return;
        }
        [self showProgressHUDWithMessage:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AudioServicesPlaySystemSound(_changeModeSound);
            self.PVRun = NO;
            _camera.previewMode = WifiCamPreviewModeVideoOff;
            dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
            if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressHUD:YES];
                    [self showErrorAlertView];
                });
            } else {
                dispatch_semaphore_signal(_previewSemaphore);
                self.PVRun = YES;
                [self runPreview:ICATCH_VIDEO_PREVIEW_MODE];
            }
        });
    }
}

- (IBAction)changeToTimelapseState:(UIButton *)sender {
    if (_camera.previewMode == WifiCamPreviewModeTimelapseOff) {
        return;
    }
    
    [self showProgressHUDWithMessage:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AudioServicesPlaySystemSound(_changeModeSound);
        //        [self stopYoutubeLive];
        self.PVRun = NO;
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if (dispatch_semaphore_wait(_previewSemaphore, time) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self showErrorAlertView];
            });
        } else {
            dispatch_semaphore_signal(_previewSemaphore);
            self.PVRun = YES;
            _camera.previewMode = WifiCamPreviewModeTimelapseOff;
            if (_camera.timelapseType == WifiCamTimelapseTypeVideo) {
                [self runPreview:ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE];
            } else {
                [self runPreview:ICATCH_TIMELAPSE_STILL_PREVIEW_MODE];
            }
        }
    });
    
}

- (void)setButtonEnable:(BOOL)value
{
    //=========comment this line by tom==================//
    self.snapButton.enabled = value;
    //self.mpbToggle.enabled = value;
    //self.settingButton.enabled = value;
    self.cameraToggle.userInteractionEnabled = value;
    self.videoToggle.userInteractionEnabled = value;
    //self.timelapseToggle.enabled = value;
    //self.sizeButton.enabled = value;
    //self.selftimerButton.enabled = value;
}

- (IBAction)changeDelayCaptureTime:(id)sender
{
    [_alertTableArray setArray:_tbDelayCaptureTimeArray.array];
    self.curSettingState = SETTING_DELAY_CAPTURE;
    
    UIView      *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 275, 130)
                                                          style:UITableViewStylePlain];
    [containerView addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
}

- (IBAction)changeCaptureSize:(id)sender
{
    NSString *alertTitle = nil;
    
    if (_camera.previewMode == WifiCamPreviewModeCameraOff) {
        alertTitle = [delegate getStringForKey:@"SetPhotoResolution" withTable:@""];
        [_alertTableArray setArray:_tbPhotoSizeArray.array];
        self.curSettingState = SETTING_STILL_CAPTURE;
        
    } else if (_camera.previewMode == WifiCamPreviewModeVideoOff){
        alertTitle = [delegate getStringForKey:@"ALERT_TITLE_SET_VIDEO_RESOLUTION" withTable:@""];
        [_alertTableArray setArray:_tbVideoSizeArray.array];
        self.curSettingState = SETTING_VIDEO_CAPTURE;
        
    } else if (_camera.previewMode == WifiCamPreviewModeTimelapseOff) {
        if (_camera.timelapseType == WifiCamTimelapseTypeStill) {
            alertTitle = [delegate getStringForKey:@"SetPhotoResolution" withTable:@""];
            [_alertTableArray setArray:_tbPhotoSizeArray.array];
            self.curSettingState = SETTING_STILL_CAPTURE;
        } else {
            alertTitle = [delegate getStringForKey:@"ALERT_TITLE_SET_VIDEO_RESOLUTION" withTable:@""];
            [_alertTableArray setArray:_tbVideoSizeArray.array];
            self.curSettingState = SETTING_VIDEO_CAPTURE;
        }
        
    }
    
    UIView      *demoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 150)];
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, 275, 130)
                                                          style:UITableViewStylePlain];
    [demoView addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)didReceiveMemoryWarning
{
    AppLog(@"ReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)showErrorAlertView
{
    AppLog(@"Timeout");
    self.normalAlert = [[UIAlertView alloc] initWithTitle:nil
                                       message           :[delegate getStringForKey:@"ActionTimeOut." withTable:@""]
                                       delegate          :self
                                       cancelButtonTitle :[delegate getStringForKey:@"Sure" withTable:@""]
                                       otherButtonTitles :nil, nil];
    _normalAlert.tag = APP_RECONNECT_ALERT_TAG;
    [_normalAlert show];
}


- (void)addMovieRecListener
{
    videoRecOffListener = new VideoRecOffListener(self);
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_VIDEO_OFF
                      listener:videoRecOffListener isCustomize:NO];
    sdCardFullListener = new SDCardFullListener(self);
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_SDCARD_FULL
                      listener:sdCardFullListener isCustomize:NO];
    if(sensorNumberChangetimer != nil) {
        [sensorNumberChangetimer invalidate];
    }
    sensorNumberChangetimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sensorNumberChangeFunction) userInfo:nil repeats:YES];
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        [self addObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"
                  options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)remMovieRecListener
{
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_OFF
                         listener:videoRecOffListener
                      isCustomize:NO];
    if (videoRecOffListener) {
        delete videoRecOffListener;
        videoRecOffListener = NULL;
    }
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_SDCARD_FULL
                         listener:sdCardFullListener isCustomize:NO];
    if (sdCardFullListener) {
        delete sdCardFullListener;
        sdCardFullListener = NULL;
    }
    if(sensorNumberChangetimer != nil) {
        [sensorNumberChangetimer invalidate];
    }
    
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        if( [self observationInfo]){
            @try{
                [self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
            }@catch (NSException *exception) {}
        }
        //[self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
    }
}

-(void)sensorNumberChangeFunction {
    int curState = [[SDK instance] retrieveCurrentSensorNumberChangeData]-1;
    NSLog(@"receiver sensor number ->  %d",curState);
    if(sensorNumberChangeData == 0 && curState == 1) {
        sensorNumberChangeData = 1;
        [self stopMovieRec];
    } else if(curState == 0) {
        sensorNumberChangeData = 0;
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"movieRecordElapsedTimeInSeconds"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger sec = [[change objectForKey:NSKeyValueChangeNewKey] unsignedIntegerValue];
            self.movieRecordTimerLabel.text = [Tool translateSecsToString:sec];
        });
    }
}

- (void)addTimelapseRecListener
{
    timelapseStopListener = new TimelapseStopListener(self);
    timelapseCaptureStartedListener = new TimelapseCaptureStartedListener(self);
    timelapseCaptureCompleteListener = new TimelapseCaptureCompleteListener(self);
    sdCardFullListener = new SDCardFullListener(self);
    
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_TIMELAPSE_STOP
                      listener:timelapseStopListener isCustomize:NO];
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_CAPTURE_START
                      listener:timelapseCaptureStartedListener isCustomize:NO];
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_CAPTURE_COMPLETE
                      listener:timelapseCaptureCompleteListener isCustomize:NO];
    [_ctrl.comCtrl addObserver:ICATCH_EVENT_SDCARD_FULL
                      listener:sdCardFullListener isCustomize:NO];
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        [self addObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"
                  options:NSKeyValueObservingOptionNew context:nil];
        
    }
}

- (void)remTimelapseRecListener
{
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_TIMELAPSE_STOP
                         listener:timelapseStopListener isCustomize:NO];
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_CAPTURE_START
                         listener:timelapseCaptureStartedListener isCustomize:NO];
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_CAPTURE_COMPLETE
                         listener:timelapseCaptureCompleteListener isCustomize:NO];
    [_ctrl.comCtrl removeObserver:ICATCH_EVENT_SDCARD_FULL
                         listener:sdCardFullListener isCustomize:NO];
    
    if (timelapseStopListener) {
        delete timelapseStopListener; timelapseStopListener = NULL;
    }
    if (timelapseCaptureStartedListener) {
        delete timelapseCaptureStartedListener; timelapseCaptureStartedListener = NULL;
    }
    if (timelapseCaptureCompleteListener) {
        delete timelapseCaptureCompleteListener; timelapseCaptureCompleteListener = NULL;
    }
    if (sdCardFullListener) {
        delete sdCardFullListener; sdCardFullListener = NULL;
    }
    if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
        if( [self observationInfo]){
            @try{
                [self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
            }@catch (NSException *exception) {}
        }
        //[self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
    }
}

- (IBAction)returnBackToHome:(id)sender {
    
        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
       {
           [_np stop:NO];
           [self hideProgressHUD:YES];
           //[self.navigationController popToRootViewControllerAnimated:YES];
           [self dismissViewControllerAnimated:YES completion:^{
               
           }];
       }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
#if 1
            _PVRun = NO;
            [self hideProgressHUD:YES];
            [self stopYoutubeLive];
            //[[SDK instance] destroySDK];
            //[self.navigationController popToRootViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
#else
            [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
            [self stopYoutubeLive];
            self.PVRun = NO;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
                if ((dispatch_semaphore_wait(_previewSemaphore, time) != 0)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [self showErrorAlertView];
                    });
                    return;
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        dispatch_semaphore_signal(_previewSemaphore);
                        [self hideProgressHUD:YES];
                        [[SDK instance] destroySDK];
                        //[self.navigationController popToRootViewControllerAnimated:YES];
                        [self dismissViewControllerAnimated:YES completion:^{
                           
                        }];
                        //                [self dismissViewControllerAnimated:YES completion:^{
                        //                    [[SDK instance] destroySDK];
                        //                }];
                    });
                }
            });
#endif
        }
        else
        {
            self.PVRun = NO;
            [self hideProgressHUD:YES];
            //[self.navigationController popToRootViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:YES completion:^{

            }];
        }
    
}

- (void)selectDelayCaptureTimeAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != _tbDelayCaptureTimeArray.lastIndex) {
        
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            _tbDelayCaptureTimeArray.lastIndex = indexPath.row;
            
            unsigned int curCaptureDelay = [_ctrl.propCtrl parseDelayCaptureInArray:indexPath.row];
            /*
             if (curCaptureDelay != CAP_DELAY_NO) {
             // Disable burst capture
             _camera.curBurstNumber = BURST_NUMBER_OFF;
             [_ctrl.propCtrl changeBurstNumber:BURST_NUMBER_OFF];
             }
             */
            
            [_ctrl.propCtrl changeDelayedCaptureTime:curCaptureDelay];
            //_camera.curCaptureDelay = curCaptureDelay;
            
            // Re-Get
            //_camera.curBurstNumber = [_ctrl.propCtrl retrieveBurstNumber];
            //_camera.curTimelapseInterval = [_ctrl.propCtrl retrieveCurrentTimelapseInterval];
            [_ctrl.propCtrl updateAllProperty:_camera];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                //=========comment this line by tom==================//
                /*[self.selftimerLabel setText:[_staticData.captureDelayDict objectForKey:@(curCaptureDelay)]];*/
                [self updateBurstCaptureIcon:_camera.curBurstNumber];
                
            });
            
        });
    }
}

- (void)selectImageSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != _tbPhotoSizeArray.lastIndex) {
        
        //self.PVRun = NO;
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            /*
             dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
             if ((dispatch_semaphore_wait(_previewSemaphore, time) != 0)) {
             dispatch_async(dispatch_get_main_queue(), ^{
             [self hideProgressHUD:YES];
             [self showErrorAlertView];
             });
             
             } else {
             */
            
            _tbPhotoSizeArray.lastIndex = indexPath.row;
            string curImageSize = [_ctrl.propCtrl parseImageSizeInArray:indexPath.row];
            
            [_ctrl.propCtrl changeImageSize:curImageSize];
            //_camera.curImageSize = curImageSize;
            
            [_ctrl.propCtrl updateAllProperty:_camera];
            
            //dispatch_semaphore_signal(_previewSemaphore);
            //self.PVRun = YES;
            //[self runPreview:ICATCH_STILL_PREVIEW_MODE];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self updateImageSizeOnScreen:curImageSize];
                
            });
            //}
        });
        
        
        /*
         _tbPhotoSizeArray.lastIndex = indexPath.row;
         
         string curImageSize = [_ctrl.propCtrl parseImageSizeInArray:indexPath.row];
         _camera.curImageSize = curImageSize;
         [_ctrl.propCtrl changeImageSize:curImageSize];
         [self updateImageSizeOnScreen:curImageSize];
         */
    }
}

- (void)selectVideoSizeAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != _tbVideoSizeArray.lastIndex) {
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if ([_ctrl.propCtrl isSupportMethod2ChangeVideoSize]) {
                AppLog(@"New Method");
                self.PVRun = NO;
                
                dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
                if ((dispatch_semaphore_wait(_previewSemaphore, time) != 0)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [self showErrorAlertView];
                    });
                    
                } else {
                    _tbVideoSizeArray.lastIndex = indexPath.row;
                    string curVideoSize = "";
                    if( _camera.previewMode == WifiCamPreviewModeTimelapseOff || _camera.previewMode == WifiCamPreviewModeTimelapseOn)
                        curVideoSize = [_ctrl.propCtrl parseTimeLapseVideoSizeInArray:indexPath.row];
                    else
                        curVideoSize = [_ctrl.propCtrl parseVideoSizeInArray:indexPath.row];
                    //string curVideoSize = [_ctrl.propCtrl parseVideoSizeInArray:indexPath.row];
                    
                    
                    [_ctrl.propCtrl changeVideoSize:curVideoSize];
                    [_ctrl.propCtrl updateAllProperty:_camera];
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //============comment this line by Tom===============//
                        //_noPreviewLabel.hidden = YES;
                        [self updateVideoSizeOnScreen:curVideoSize];
                        //                        [self hideProgressHUD:YES];
                        _preview.userInteractionEnabled = YES;
#ifdef HW_DECODE_H264
                        _h264View.userInteractionEnabled = YES;
#endif
                    });
                    
                    
                    // Is support Slow-Motion under this video size?
                    // Update the Slow-Motion icon
                    if ([self capableOf:WifiCamAbilitySlowMotion]
                        && _camera.previewMode == WifiCamPreviewModeVideoOff) {
                        
                        _camera.curSlowMotion = [_ctrl.propCtrl retrieveCurrentSlowMotion];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (_camera.curSlowMotion == 1) {
                                //=========comment this line by tom==================//
                                //self.slowMotionStateImageView.hidden = NO;
                            } else {
                                //=========comment this line by tom==================//
                                //self.slowMotionStateImageView.hidden = YES;
                            }
                        });
                    }
                    
                    self.PVRun = YES;
                    dispatch_semaphore_signal(_previewSemaphore);
                    
                    if( _camera.previewMode == WifiCamPreviewModeTimelapseOff || _camera.previewMode == WifiCamPreviewModeTimelapseOn){
                        if (_camera.timelapseType == WifiCamTimelapseTypeVideo) {
                            if( [_ctrl.propCtrl changeTimelapseType:ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE] == WCRetSuccess)
                                AppLog(@"change to ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE success");
                            [self runPreview:ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE];
                        } else {
                            if( [_ctrl.propCtrl changeTimelapseType:ICATCH_TIMELAPSE_STILL_PREVIEW_MODE]== WCRetSuccess)
                                AppLog(@"change to ICATCH_TIMELAPSE_STILL_PREVIEW_MODE success");
                            [self runPreview:ICATCH_TIMELAPSE_STILL_PREVIEW_MODE];
                        }
                    }
                    else
                        [self runPreview:ICATCH_VIDEO_PREVIEW_MODE];
                    
                }
            } else {
                AppLog(@"Old Method");
                
                _tbVideoSizeArray.lastIndex = indexPath.row;
                string curVideoSize;
                if( _camera.previewMode == WifiCamPreviewModeTimelapseOff || _camera.previewMode == WifiCamPreviewModeTimelapseOn)
                    curVideoSize = [_ctrl.propCtrl parseTimeLapseVideoSizeInArray:indexPath.row];
                else
                    curVideoSize = [_ctrl.propCtrl parseVideoSizeInArray:indexPath.row];
                
                [_ctrl.propCtrl changeVideoSize:curVideoSize];
                [_ctrl.propCtrl updateAllProperty:_camera];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressHUD:YES];
                    [self updateVideoSizeOnScreen:curVideoSize];
                });
            }
            
        });
        
    }
}

/*-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                        duration:(NSTimeInterval)duration {
    
    if (!_avslayer.hidden) {
        self.avslayer.bounds = _preview.bounds;
        self.avslayer.position = CGPointMake(CGRectGetMidX(_preview.bounds), CGRectGetMidY(_preview.bounds));
        [self showLiveGUIIfNeeded:_camera.previewMode];
    }
    
    CGFloat y = -15;
    if (_notificationView.isShowing) {
        y = 15;
    }
    _notificationView.center = CGPointMake(self.view.bounds.size.width / 2, y);
    
  
}*/

//-(BOOL)prefersStatusBarHidden {
//    if (self.view.frame.size.width < self.view.frame.size.height) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

-(void)removeObservers {
    if ([self capableOf:WifiCamAbilityBatteryLevel] && batteryLevelListener) {
        [_ctrl.comCtrl removeObserver:ICATCH_EVENT_BATTERY_LEVEL_CHANGED
                             listener:batteryLevelListener
                          isCustomize:NO];
        delete batteryLevelListener;
        batteryLevelListener = NULL;
    }
    if ([self capableOf:WifiCamAbilityMovieRecord] && videoRecOnListener) {
        [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_ON
                             listener:videoRecOnListener
                          isCustomize:NO];
        delete videoRecOnListener;
        videoRecOnListener = NULL;
    }
    
    if (_camera.enableAutoDownload && fileDownloadListener) {
        [_ctrl.comCtrl removeObserver:ICATCH_EVENT_FILE_DOWNLOAD
                             listener:fileDownloadListener
                          isCustomize:NO];
        delete fileDownloadListener;
        fileDownloadListener = NULL;
    }
}

#pragma mark - ICatchWificamListener

- (void)updateMovieRecState:(MovieRecState)state
{
    if (state == MovieRecStoped) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            [self remMovieRecListener];
            [_ctrl.comCtrl removeObserver:ICATCH_EVENT_VIDEO_OFF
                                 listener:videoRecOffListener
                              isCustomize:NO];
            if (videoRecOffListener) {
                delete videoRecOffListener;
                videoRecOffListener = NULL;
            }
            
            if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                if( [self observationInfo]){
                    @try{
                        [self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
                    }@catch (NSException *exception) {}
                }
                //[self removeObserver:self forKeyPath:@"movieRecordElapsedTimeInSeconds"];
            }
            // Mark by Allen.Chuang 2015.1.28 ICOM-2754 , camera will stop record by itself.
            //[_ctrl.actCtrl stopMovieRecord];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePreviewSceneByMode:WifiCamPreviewModeVideoOff];
                
                if ([_videoCaptureTimer isValid]) {
                    [_videoCaptureTimer invalidate];
                    self.movieRecordElapsedTimeInSeconds = 0;
                }
            });
        });
    } else if (state == MovieRecStarted) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [_ctrl.actCtrl startMovieRecord];
            [self addMovieRecListener];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePreviewSceneByMode:WifiCamPreviewModeVideoOn];
                
                if (![_videoCaptureTimer isValid]) {
                    self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                            target  :self
                                                                            selector:@selector(movieRecordingTimerCallback:)
                                                                            userInfo:nil
                                                                            repeats :YES];
                }
            });
            
        });
    }
}

- (void)updateBatteryLevel
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_ctrl.propCtrl connected]) {
            return;
        }
        
        NSString *imagePath = [_ctrl.propCtrl prepareDataForBatteryLevel];
        UIImage *batteryStatusImage = [UIImage imageNamed:imagePath];
        //============comment this line by Tom===============//
        //[self.batteryState setImage:batteryStatusImage];
        
        if ([imagePath isEqualToString:@"battery_0"] && !_batteryLowAlertShowed) {
            self.batteryLowAlertShowed = YES;
            [self showProgressHUDNotice:[delegate getStringForKey:@"ALERT_LOW_BATTERY" withTable:@""] showTime:2.0];
            
        } else if ([imagePath isEqualToString:@"battery_4"]) {
            self.batteryLowAlertShowed = NO;
        }
    });
}
-(void)updateBatteryLevel:(int)value
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_ctrl.propCtrl connected]) {
            return;
        }
        
        NSString *imagePath = [_ctrl.propCtrl prepareDataForBatteryLevel];
        //NSString *imagePath = [_ctrl.propCtrl transBatteryLevel2NStr:value];
        UIImage *batteryStatusImage = [UIImage imageNamed:imagePath];
        //============comment this line by Tom===============//
        //[self.batteryState setImage:batteryStatusImage];
        
        if ([imagePath isEqualToString:@"battery_0"] && !_batteryLowAlertShowed) {
            self.batteryLowAlertShowed = YES;
            [self showProgressHUDNotice:[delegate getStringForKey:@"ALERT_LOW_BATTERY" withTable:@""] showTime:2.0];
            
        } else if ([imagePath isEqualToString:@"battery_4"]) {
            self.batteryLowAlertShowed = NO;
        }
    });
}
- (void)stopStillCapture
{
    TRACE();
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_ctrl.comCtrl removeObserver:ICATCH_EVENT_CAPTURE_COMPLETE
                             listener:stillCaptureDoneListener
                          isCustomize:NO];
        if (stillCaptureDoneListener) {
            delete stillCaptureDoneListener;
            stillCaptureDoneListener = NULL;
        }
        if( ! [self capableOf:WifiCamAbilityLatestDelayCapture] ){
            AppLog(@"wait 1 second");
            [NSThread sleepForTimeInterval:1]; // old method must slow start media stream
        }
        _camera.previewMode = WifiCamPreviewModeCameraOff;
        
        if (![self capableOf:WifiCamAbilityNewCaptureWay]) {
            dispatch_semaphore_signal(_previewSemaphore);
            self.PVRun = YES;
            [self runPreview:ICATCH_STILL_PREVIEW_MODE];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePreviewSceneByMode:_camera.previewMode];
            });
        }
    });
}

- (void)stopTimelapse
{
    ICatchCameraMode mode = [[SDK instance] retrieveCurrentCameraMode];
    
    BOOL ret = NO;
    if (mode == MODE_TIMELAPSE_STILL || mode == MODE_TIMELAPSE_VIDEO) {
        AppLog(@"got event and call stopTimelapseRecord again.");
        ret = [_ctrl.actCtrl stopTimelapseRecord];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (ret) {
            [self remTimelapseRecListener];
        }
        
        if ([_videoCaptureTimer isValid]) {
            [_videoCaptureTimer invalidate];
            self.movieRecordElapsedTimeInSeconds = 0;
        }
        [self updatePreviewSceneByMode:WifiCamPreviewModeTimelapseOff];
    });
}

- (void)timelapseStartedNotice {
    AudioServicesPlaySystemSound(_burstCaptureSound);
}

- (void)timelapseCompletedNotice
{
    
    /*
     dispatch_async(dispatch_get_main_queue(), ^{
     [self showProgressHUDCompleteMessage:NSLocalizedString(@"Done", nil)];
     });
     */
}

- (void)postMovieRecordTime
{
    TRACE();
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_videoCaptureTimer isValid]) {
            self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                    target  :self
                                                                    selector:@selector(movieRecordingTimerCallback:)
                                                                    userInfo:nil
                                                                    repeats :YES];
        } else {
            self.movieRecordElapsedTimeInSeconds = 0;
        }
        
        [self hideProgressHUD:YES];
    });
    
    
}

- (void)postMovieRecordFileAddedEvent
{
    self.movieRecordElapsedTimeInSeconds = 0;
}

- (void)postFileDownloadEvent:(ICatchFile *)file {
    TRACE();
    printf("filePath: %s\n", file->getFilePath().c_str());
    printf("fileName: %s\n", file->getFileName().c_str());
    printf("fileDate: %s\n", file->getFileDate().c_str());
    printf("fileType: %d\n", file->getFileType());
    printf("fileSize: %llu\n", file->getFileSize());
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressHUDWithMessage:nil];
    });
    
    ICatchFile *f = new ICatchFile(file->getFileHandle(), file->getFileType(), file->getFilePath(), file->getFileSize());
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_ctrl.fileCtrl downloadFile:f];
        UIImage *image = [_ctrl.actCtrl getAutoDownloadImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            //============comment this line by Tom===============//
            //self.autoDownloadThumbImage.image = image;
            //self.autoDownloadThumbImage.hidden = NO;
            [self hideProgressHUD:YES];
        });
        
        delete f;
    });
}

-(void)sdFull {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [_ctrl.comCtrl removeObserver:ICATCH_EVENT_SDCARD_FULL
                             listener:sdCardFullListener isCustomize:NO];
        if (sdCardFullListener) {
            delete sdCardFullListener;
            sdCardFullListener = NULL;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_FULL" withTable:@""]
                               showTime:1.5];
            
        });
    });
}

#pragma mark - WifiCamSDKEventListener
-(void)streamCloseCallback {
    AppLog(@"streamCloseCallback");
    [self stopYoutubeLive];
    self.PVRun = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressHUDNotice:@"Streaming is stopped unexpected." showTime:2.0];
    });
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return _alertTableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                   reuseIdentifier:nil];
    [cell.textLabel setText:[_alertTableArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_curSettingState) {
        case SETTING_DELAY_CAPTURE:
            [self selectDelayCaptureTimeAtIndexPath:indexPath];
            break;
            
        case SETTING_STILL_CAPTURE:
            [self selectImageSizeAtIndexPath:indexPath];
            break;
            
        case SETTING_VIDEO_CAPTURE:
            [self selectVideoSizeAtIndexPath:indexPath];
            break;
            
        default:
            break;
    }
    
}

- (void)tableView         :(UITableView *)tableView
        willDisplayCell   :(UITableViewCell *)cell
        forRowAtIndexPath :(NSIndexPath *)indexPath
{
    NSInteger lastIndex = 0;
    
    switch (_curSettingState) {
        case SETTING_DELAY_CAPTURE:
            lastIndex = _tbDelayCaptureTimeArray.lastIndex;
            break;
            
        case SETTING_STILL_CAPTURE:
            lastIndex = _tbPhotoSizeArray.lastIndex;
            break;
            
        case SETTING_VIDEO_CAPTURE:
            lastIndex = _tbVideoSizeArray.lastIndex;
            break;
            
        default:
            break;
    }
    
    if (indexPath.row == lastIndex) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case APP_RECONNECT_ALERT_TAG:
            [self dismissViewControllerAnimated:YES completion:^{}];
            //exit(0);
            break;
            
        default:
            break;
    }
}


#pragma mark - AppDelegateProtocol
-(void)cleanContext {
    [self removeObservers];
    [self stopYoutubeLive];
    self.PVRun = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 10ull * NSEC_PER_SEC);
        if ((dispatch_semaphore_wait(_previewSemaphore, time) != 0)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                [self showErrorAlertView];
            });
            
        } else {
            dispatch_async([[SDK instance] sdkQueue], ^{
                dispatch_semaphore_signal(_previewSemaphore);
                TRACE();
                if ([[SDK instance] isConnected]) {
                    return;
                } else {
                    [[SDK instance] destroySDK];
                }
            });
        }
    });
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    AppLog("enter background");
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [self removeObservers];
        [self stopYoutubeLive];
        self.PVRun = NO;
        self.isEnterBackground = YES;
        [[SDK instance] destroySDK];
    }
}

-(NSString *)notifyConnectionBroken {
    switch(_camera.previewMode) {
        case WifiCamPreviewModeVideoOn: {
            if ([self capableOf:WifiCamAbilityGetMovieRecordedTime]) {
                [_ctrl.comCtrl removeObserver:(ICatchEventID)0x5001
                                     listener:videoRecPostTimeListener
                                  isCustomize:YES];
                if (videoRecPostTimeListener) {
                    delete videoRecPostTimeListener;
                    videoRecPostTimeListener = NULL;
                }
            }
            [self remMovieRecListener];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_videoCaptureTimer isValid]) {
                    [_videoCaptureTimer invalidate];
                    self.movieRecordElapsedTimeInSeconds = 0;
                }
                [self updatePreviewSceneByMode:WifiCamPreviewModeVideoOff];
            });
        }
            break;
        case WifiCamPreviewModeTimelapseOn: {
            [self remTimelapseRecListener];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([_videoCaptureTimer isValid]) {
                    [_videoCaptureTimer invalidate];
                    self.movieRecordElapsedTimeInSeconds = 0;
                }
                [self updatePreviewSceneByMode:WifiCamPreviewModeTimelapseOff];
            });
        }
            
            break;
        default:
            break;
    }
    
    [self cleanContext];
    return self.savedCamera.wifi_ssid;
}

- (void)sdcardRemoveCallback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showProgressHUDNotice:[delegate getStringForKey:@"CARD_REMOVED" withTable:@""] showTime:2.0];
    });
}


- (void)startYoutubeLive:(NSString *)postUrl
{
    //1.获取授权，成功后得到credential
    //2.利用credential创建Live频道，成功后得到推流addr
    //  share...
    //3.开始推流
    dispatch_async(_liveQueue/*dispatch_queue_create("WifiCam.GCD.Queue.YoutubeLive", DISPATCH_QUEUE_SERIAL)*/, ^{
        int ret = [[SDK instance] startPublishStreaming:[postUrl UTF8String]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ret != ICH_SUCCEED) {
                _Living = NO;
                
                [[SDK instance] stopPublishStreaming];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[delegate getStringForKey:@"Tips" withTable:@""] message:[delegate getStringForKey:@"LIVE_FAILED" withTable:@""] delegate:self cancelButtonTitle:[delegate getStringForKey:@"Sure" withTable:@""] otherButtonTitles:nil, nil];
                [alert show];
            }
        });
    });
}

- (void)startYoutubeLive
{
    //1.获取授权，成功后得到credential
    //2.利用credential创建Live频道，成功后得到推流addr
    //  share...
    //3.开始推流
    [self showProgressHUDWithMessage:[delegate getStringForKey:@"Start Live" withTable:@""]];
    
    dispatch_async(_liveQueue/*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
        int ret = [[SDK instance] startPublishStreaming:[[[NSUserDefaults standardUserDefaults] stringForKey:@"RTMPURL"] UTF8String]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
            
            if (ret != ICH_SUCCEED) {
                [[SDK instance] stopPublishStreaming];
                //============comment this line by Tom===============//
                //_liveSwitch.on = NO;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[delegate getStringForKey:@"Tips" withTable:@""] message:[delegate getStringForKey:@"LIVE_FAILED" withTable:@""] delegate:self cancelButtonTitle:[delegate getStringForKey:@"Sure" withTable:@""] otherButtonTitles:nil, nil];
                [alert show];
            } else {
                _Living = YES;
                [self setToVideoOnScene];
            }
        });
    });
    
    //4.开始直播，成功后得到Share addr
    //5.将Share addr生成二维码
    
    //    "rtmp://a.rtmp.youtube.com/live2/7m5m-wuhz-ryaq-89ss"
    //    dispatch_async(dispatch_queue_create("WifiCam.GCD.Queue.getQRCodebyUrl", DISPATCH_QUEUE_SERIAL), ^{
    //        UIImage *urlImage = [self getQRCodebyUrl:@"http://www.baidu.com"];
    //        if (urlImage) {
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                _autoDownloadThumbImage.image = urlImage;
    //                _autoDownloadThumbImage.hidden = NO;
    //            });
    //        }
    //    });
}

- (void)stopYoutubeLive
{
    //1.停止推流
    //2.停止直播
    if (_Living) {
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"Stop Live" withTable:@""]];
        
        dispatch_async(_liveQueue/*dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)*/, ^{
            //============comment this line by Tom===============//
           // _liveSwitch.on = NO;
            int ret = [[SDK instance] stopPublishStreaming];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideProgressHUD:YES];
                //============comment this line by Tom===============//
                /*
                _autoDownloadThumbImage.image = nil;
                _autoDownloadThumbImage.hidden = YES;*/
                _Living = NO;
                
                if (!_Recording) {
                    [self setToVideoOffScene];
                }
                
                if (ret != ICH_SUCCEED) {
                    [[SDK instance] stopPublishStreaming];
                }
            });
        });
    }
}


- (void)liveFailedUpdateGUI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideProgressHUD:YES];
        //============comment this line by Tom===============//
        /*_autoDownloadThumbImage.image = nil;
        _autoDownloadThumbImage.hidden = YES;*/
        
        _Living = NO;
        //============comment this line by Tom===============//
        //_liveSwitch.on = NO;
    });
}


- (NSString *)NvtGetPreivewMode{
    return [self NVTGetHttpCmd:@"3037"];
}

- (void)NvtSetPreivewMode:(NSString *)cmd Par2:(NSString *)par{
    [self NVTSendHttpCmd:cmd Par2:par];
}

- (void)NvtMovieRecordingStart{
    [self NVTSendHttpCmd:@"2001" Par2:@"1"];
}


- (void)NvtMovieRecordingStop{
    [self NVTSendHttpCmd:@"2001" Par2:@"0"];
}

- (void)NvtStillCapture{
    [self NVTGetHttpCmd:@"1001"];
}

- (void)NvtVideoModeRemainTime{
    self.movieRecordTimerLabel.text = [Tool translateSecsToString:[[self NVTGetHttpCmd:@"2009"] integerValue]];
}
- (void)NvtVideoRecordingTime{
    self.movieRecordTimerLabel.text = [Tool translateSecsToString:[[self NVTGetHttpCmd:@"2016"] integerValue]];
}
- (void)NvtStillModeRemainNumber{
    self.movieRecordTimerLabel.text = [self NVTGetHttpCmd:@"1003"];
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

    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    
    return [self.NvtHttpValueDict objectForKey:cmd];
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
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
    }
    else{
        storingFlag = FALSE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
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
            [self.NvtHttpValueDict setValue:currentElementStatus forKey:currentElementCommand];
        }
        else if(ValueFlag){
            ValueFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NvtHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
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


- (NSString *)recheckSSID
{
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

        }
    }
    NSLog(@"ssid : %@", ssid);

    
    return ssid;
}


- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
{
    //1.获取 当前设备 实例
    UIDevice *device = [UIDevice currentDevice] ;
    
    
    
    
    /**
     *  2.取得当前Device的方向，Device的方向类型为Integer
     *
     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
     *
     *  @param device.orientation
     *
     */
 //   CGSize screenSize = [[UIScreen mainScreen] bounds].size;
 //   CGRect rectNav = self.navigationController.navigationBar.frame;
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
            [self.navigationController setNavigationBarHidden:YES];
            self.ModeView.layer.cornerRadius = 10;
            self.ModeView.alpha = 0.5;
            if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
            {
                self.NodePlayerView.frame = CGRectMake(0, 0, self.view.frame.size.width
                                                       , self.view.frame.size.height);
            }
            else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
            {
                self.avslayer.frame = CGRectMake(0, 0, self.view.frame.size.width
                                                 , self.view.frame.size.height);
                self.avslayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }

            
            NSLog(@"屏幕向左横置");
            break;
            
        case UIDeviceOrientationLandscapeRight:
            [self.navigationController setNavigationBarHidden:YES];
            self.ModeView.layer.cornerRadius = 10;
            self.ModeView.alpha = 0.5;
            if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
            {
                self.NodePlayerView.frame = CGRectMake(0, 0, self.view.frame.size.width
                                                       , self.view.frame.size.height);
            }
            else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
            {
                self.avslayer.frame = CGRectMake(0, 0, self.view.frame.size.width
                                                 , self.view.frame.size.height);
                self.avslayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }

            
            NSLog(@"屏幕向右橫置");
            break;
            
        case UIDeviceOrientationPortrait:
            [self.navigationController setNavigationBarHidden:YES];
            self.ModeView.layer.cornerRadius = 0;
            self.ModeView.alpha = 1.0;
            if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
            {
                self.NodePlayerView.frame = CGRectMake(self.NodePlayerView.frame.origin.x, self.NodePlayerView.frame.origin.y, self.NodePlayerView.frame.size.width
                                                       , self.NodePlayerView.frame.size.height);
            }
            else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
            {
                self.avslayer.frame = CGRectMake(self.preview.frame.origin.x, self.preview.frame.origin.y, self.preview.frame.size.width
                                             , self.preview.frame.size.height);
                self.avslayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            }
            NSLog(@"屏幕直立");
            
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"屏幕直立，上下顛倒");
            break;
            
        default:
            NSLog(@"无法辨识");
            break;
    }
    
}
-(void)onEventCallback:(nonnull id)sender event:(int)event msg:(nonnull NSString*)msg
{
    switch (event) {
        case 1000:
            NSLog(@"NodePlayer正在连接视频");
            break;
        case 1001:
            NSLog(@"NodePlayer视频连接成功");
            break;
        case 1002:
            NSLog(@"NodePlayer视频连接失败, 会进行自动重连.");
            break;
        case 1003:
            NSLog(@"NodePlayer视频开始重连");
            break;
        case 1004:
            NSLog(@"NodePlayer视频播放结束");
            break;
        case 1005:
            NSLog(@"NodePlayer视频播放中网络异常, 会进行自动重连.");
            break;
        case 1006:
            
            NSLog(@"NodePlayer网络连接超时, 会进行自动重连");
            break;
        case 1100:
            NSLog(@"NodePlayer播放缓冲区为空");
            break;
        case 1101:
            NSLog(@"NodePlayer播放缓冲区正在缓冲数据");
            break;
        case 1102:
            if(NvtStateRecording)
            {
                dispatch_semaphore_signal(_previewSemaphore);
            }
            NSLog(@"NodePlayer播放缓冲区达到bufferTime设定值,开始播放");
            break;
        case 1103:
            NSLog(@"NodePlayer收到RTMP协议Stream EOF,或 NetStream.Play.UnpublishNotify, 会进行自动重连");
            break;
        case 1104:
            NSLog(@"NodePlayer解码后得到视频高宽, 格式为 width x height");
            NSLog(@"NodePlayer msg = %@",msg);
            break;
        default:
            break;
    }
    if(event == 1000 || event == 1003)
    {
      /*  dispatch_async(dispatch_get_main_queue(), ^{
            [self showProgressHUDWithMessage:nil];
        });*/
    }
    else if(event == 1102)
    {
        /*dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
        });*/
    }
}
@end
