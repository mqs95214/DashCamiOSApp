//
//  ViewController.m
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import "ViewPreviewMenuController.h"
#ifndef HW_DECODE_H264

#endif
#import <SystemConfiguration/CaptiveNetwork.h>
#import <NodeMediaClient/NodeMediaClient.h>
#import "AppDelegate.h"
#import "SSID_SerialCheck.h"
//#import <IJKMediaFramework/IJKMediaFramework.h>


@interface ViewPreviewMenuController ()


@property (strong,nonatomic) NodePlayer *np;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;

@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;
@property(nonatomic) WifiCamStaticData *staticData;
@property(nonatomic) NSString *CurrentMode;
@property(nonatomic,strong)NSBundle *bundle;
@property(nonatomic,strong)CLLocationManager *locationManager;
@end
@implementation ViewPreviewMenuController {
    
    __weak IBOutlet UIButton *preview_countiBT;
    __weak IBOutlet UILabel *FileOnDashcam;
    __weak IBOutlet UILabel *Menu;
    __weak IBOutlet UILabel *FilesOnMobile;
    __weak IBOutlet UILabel *About;
   
    NSString *SSID;
    SSID_SerialCheck *SSIDSreial;
    NSString *dateFormat;
    AppDelegate *delegate;
}

- (void)viewDidLoad
{
    TRACE();
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
    _timeDateTitleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetLiveView" withTable:@""]];
    _sdCardInfoTitleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetFormatSDCard" withTable:@""]];
    _systemInfoText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetDashCamInfo" withTable:@""]];
    _lastFormatDateText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetLastFormatDate" withTable:@""]];
    _audioRecText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""]];
    
    _NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationDisconnectWiFi:) name:@"disconnectWiFi" object:nil];
   // [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    //set font size
    //self.NoPreviewLine3.adjustsFontSizeToFitWidth = YES;
    
    FileOnDashcam.font = [self adjFontSize2:FileOnDashcam];
    FilesOnMobile.font = FileOnDashcam.font;
    About.font = FileOnDashcam.font;
    Menu.font = FileOnDashcam.font;
    
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    if (@available(iOS 13, *)) {
        
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {//有開權限
            
            //[self recheckSSID];
            [self connectDashCam];
            
        } else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied) {//沒給權限
            return;
            
        } else {//詢問使用者權限
            
            [_locationManager requestWhenInUseAuthorization];
        }
        
    } else {
        
        //[self recheckSSID];
        [self connectDashCam];
    }
    
    
    
    
    
    

  
    
    
#ifdef HW_DECODE_H264
    // H.264

#endif
}
-(void) connectDashCam {
    SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    reconnectCount = 0;
    
    
    
    [_preview_View setHidden:NO];
    _K7_Display_View.hidden = YES;
    self.NoPreviewView.hidden = NO;
    
    
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        if([SSIDSreial MatchSSIDReturn:SSID] == DRVA700W) {
            if([[self NVTGetHttpCmd:@"3204"] intValue] == 0) {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"NavigationK7Init"];
                [self presentViewController:vc animated:YES completion:NULL];
            } else {
                [self reloadDashcamData];
                [_preview_View setHidden:YES];
                _NoPreviewView.hidden = YES;
                _K7_Display_View.hidden = NO;
            }
        } else {
            if(_np == nil)
            {
                [self NodePlayerInit];
                [self NodePlaySetUrl];
                [self NodePlayerStart];
            }
            else
            {
                [self NodePlayerStop];
                [self NodePlaySetUrl];
                [self NodePlayerStart];
            }
        }
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        if ([[SDK instance] isSDKInitialized])
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
        if(_np == nil)
        {
            [self NodePlayerInit];
        }
        else
        {
            [self NodePlayerStop];
        }
    }
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        //self.NoPreviewView.hidden = YES;
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting"]];
        FileOnDashcam.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        [_Playback_Btn setEnabled:YES];
        [_Setting_Btn setEnabled:YES];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting"]];
        FileOnDashcam.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        //self.NoPreviewView.hidden = YES;
        [_Playback_Btn setEnabled:YES];
        [_Setting_Btn setEnabled:YES];
    }
    else
    {
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback_disable"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting_disable"]];
        
        FileOnDashcam.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        [_Playback_Btn setEnabled:NO];
        [_Setting_Btn setEnabled:NO];
    }
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //[self recheckSSID];
        [self connectDashCam];
    }
}
-(void)notificationDisconnectWiFi:(NSNotification *)notification{
    //NSString  *name=[notification name];
    //NSString  *object=[notification object];
    //NSLog(@"名称:%@----对象:%@",name,object);
    [self NodePlayerStop];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _K7_Display_View.hidden = YES;
        self.NoPreviewView.hidden = NO;
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback_disable"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting_disable"]];
        
        FileOnDashcam.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        
        [_Playback_Btn setEnabled:NO];
        [_Setting_Btn setEnabled:NO];
    });
}
-(void)dealloc{
    //NSLog(@"观察者销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)NodePlayerInit
{
    _np = [[NodePlayer alloc] init];
    [_np setNodePlayerDelegate:self];
    [_np setBufferTime:1000];
    [_np setContentMode:UIViewContentModeScaleToFill];

    [_np setPlayerView:self.UpperPreview];
    
}
-(void)NodePlaySetUrl
{
    if([SSIDSreial MatchSSIDReturn:SSID] == CANSONIC_Z3)
    {
        [_np setInputUrl:@"rtsp://192.168.1.1/MJPG?W=760&H=400&Q=50&BR=5000000"];
    }
    else if([SSIDSreial MatchSSIDReturn:SSID] == DUO_HD)
    {
        [_np setInputUrl:@"rtsp://192.168.1.1/MJPG?W=760&H=400&Q=50&BR=5000000"];
    }
    else if([SSIDSreial MatchSSIDReturn:SSID] == CANSONIC_S2Plus)
    {
        [_np setInputUrl:@"rtsp://192.168.1.1/H264?W=1280&H=720&BR=4000000&FPS=30"];
    }
    else if([SSIDSreial MatchSSIDReturn:SSID] == CANSONIC_U2 ||
            [SSIDSreial MatchSSIDReturn:SSID] == KVDR600W ||
            [SSIDSreial MatchSSIDReturn:SSID] == DRVA601W)
    {
        
        ICatchVideoFormat videoformat = [[SDK instance] getVideoFormatCustomer];//[self.ctrl.propCtrl retrieveVideoFormat];
        
        int ICH_CODEC_H264 = 41;
        int ICH_CODEC_JPEG = 64;
        NSString *bestResolution=@"";
        if (videoformat.getCodec() == ICH_CODEC_H264) {
            bestResolution = [NSString stringWithFormat:@"rtsp://192.168.1.1/H264?W=%d&H=%d&BR=%u&FPS=30",videoformat.getVideoW(),videoformat.getVideoH(),videoformat.getBitrate()];//FPS讀取異常
        } else if (videoformat.getCodec() == ICH_CODEC_JPEG) {
            bestResolution = [NSString stringWithFormat:@"rtsp://192.168.1.1/MJPG?W=%d&H=%d&BR=%u",videoformat.getVideoW(),videoformat.getVideoH(),videoformat.getBitrate()];
        }
        if(![bestResolution  isEqual: @""])
            [_np setInputUrl:bestResolution];
    }
    else
    {
        NSLog(@"url   - > %@",[self NVTGetHttpCmd:@"2019"]);
        if([self NVTGetHttpCmd:@"2019"] != nil) {
            [_np setInputUrl:[self NVTGetHttpCmd:@"2019"]];
        }
        
    }
}
-(void)NodePlayerStart
{
    [_np start];
}
-(void)NodePlayerStop
{
    [_np stop];
}
-(void)viewWillAppear:(BOOL)animated
{
    TRACE();
    [super viewWillAppear:animated];
    UILabel *label;
    UIFont *font;
    [delegate initLanguage];
    FileOnDashcam.text = [delegate getStringForKey:@"SetFileOnDashCam" withTable:@""];
    FilesOnMobile.text = [delegate getStringForKey:@"SetFileOnMobile" withTable:@""];
    Menu.text = [delegate getStringForKey:@"SetMenu" withTable:@""];
    About.text = [delegate getStringForKey:@"SetAbout" withTable:@""];
    self.NoPreviewLine1.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",[delegate getStringForKey:@"setNoPreviewInfo1" withTable:@""],[delegate getStringForKey:@"setNoPreviewInfo2" withTable:@""],[delegate getStringForKey:@"setNoPreviewInfo3" withTable:@""],[delegate getStringForKey:@"setNoPreviewInfo4" withTable:@""]];
    [self.MatchButton setTitle:[delegate getStringForKey:@"Connect" withTable:@""] forState:UIControlStateNormal];
    [self.MatchButton setTitle:[delegate getStringForKey:@"Connect" withTable:@""] forState:UIControlStateHighlighted];
    label = [self getLenghtText];
    font = [self adjFontSize:label];
    CGFloat fontSize = font.pointSize;
    self.NoPreviewLine1.font = [font fontWithSize:fontSize];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    
    SSID = [self recheckSSID];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(ReloadController) name:@"ViewControllerShouldReloadNotification" object:nil];

    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
            
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.delegate = self;
        
        if ([[SDK instance] isSDKInitialized])
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
    }
    
}


-(void)viewWillLayoutSubviews {

    [super viewWillLayoutSubviews];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_preview_View setHidden:NO];
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        //self.NoPreviewView.hidden = YES;
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting"]];
        FileOnDashcam.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        [_Playback_Btn setEnabled:YES];
        [_Setting_Btn setEnabled:YES];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting"]];
        FileOnDashcam.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        //self.NoPreviewView.hidden = YES;
        [_Playback_Btn setEnabled:YES];
        [_Setting_Btn setEnabled:YES];
    }
    else
    {
        [self.Playback_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcam_playback_disable"]];
        [self.Setting_BtnImage setImage:[UIImage imageNamed:@"control_menu_dashcamsetting_disable"]];
        
        FileOnDashcam.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        Menu.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1];
        [_Playback_Btn setEnabled:NO];
        [_Setting_Btn setEnabled:NO];
    }
        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
        {
            
            if(![self.CurrentMode isEqualToString:@"0"])
            {
                [self SetCurrentMode:@"3001" Par2:@"1"];
            }
            self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
            if([SSIDSreial MatchSSIDReturn:SSID] == DRVA700W) {
                if([[self NVTGetHttpCmd:@"3204"] intValue] == 0) {
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
                    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"NavigationK7Init"];
                    [self presentViewController:vc animated:YES completion:NULL];
                } else {
                    [self reloadDashcamData];
                    [_preview_View setHidden:YES];
                    _NoPreviewView.hidden = YES;
                    _K7_Display_View.hidden = NO;
                }
            } else {
                if(_np == nil)
                {
                    [self NodePlayerInit];
                    [self NodePlaySetUrl];
                    [self NodePlayerStart];
                }
                else
                {
                    [self NodePlayerStop];
                    [self NodePlaySetUrl];
                    [self NodePlayerStart];
                }
            }
        }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
            //.....SomeCodeHere
            if(_np == nil)
            {
                [self NodePlayerInit];
                [self NodePlaySetUrl];
                [self NodePlayerStart];
            }
            else
            {
                [self NodePlayerStop];
                [self NodePlaySetUrl];
                [self NodePlayerStart];
            }
        }
        else {
            if(_np != nil) {
                [self NodePlayerStop];
            }
            _K7_Display_View.hidden = YES;
            self.NoPreviewView.hidden = NO;
            [self hideProgressHUD:YES];
        }
    
    
}

- (void)viewWillDisappear:(BOOL)animated {
    TRACE();
   [super viewWillDisappear:animated];

    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ViewControllerShouldReloadNotification" object:nil];
        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
        {
            
        }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {

        }
        [_np stop];
}
-(UILabel*)getLenghtText {
    UILabel *label = [[UILabel alloc] init];
    UIFont *font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:18];//
    NSMutableArray *arrayText = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLenght = [[NSMutableArray alloc] init];
    NSRange range;
    NSString *str;
    NSString *curStr;
    int selectedIndex = 0;
    int count = 0;
    int maxLenght = 0;
    
    while(count < 1) {
        str = _NoPreviewLine1.text;
        do {
            range = [str rangeOfString:@"\n"];
            if(range.location == NSNotFound) {
                
            } else {
                curStr = [str substringWithRange:NSMakeRange(0, range.location)];
                [arrayText addObject:curStr];
                [arrayLenght addObject:[NSString stringWithFormat:@"%d",curStr.length]];
                
                str = [str substringWithRange:NSMakeRange(range.location+1, str.length-(range.location+1))];
            }
        } while(range.location != NSNotFound);
        [arrayText addObject:str];
        [arrayLenght addObject:[NSString stringWithFormat:@"%d",str.length]];
        count++;
    }
    
    for(int i=0;i<arrayText.count;i++) {
        if([[arrayLenght objectAtIndex:i] intValue] > maxLenght) {
            maxLenght = [[arrayLenght objectAtIndex:i] intValue];
            selectedIndex = i;
        }
    }
    if(arrayText.count > selectedIndex)
        [label setText:[arrayText objectAtIndex:selectedIndex]];
    else {
        [label setText:@""];
    }
    font = [font fontWithSize:18];
    [label setFont:font];
    return label;
}
-(UIFont*)adjFontSize:(UILabel*)label{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float curFontSize = label.font.pointSize;
    UIFont *font = label.font;
    
    CGRect rect;
    rect = [self.NoPreviewLine1 bounds];
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
        if(size.width < screenWidth*0.8 && size.height <= rect.size.height) {
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
-(UIFont*)adjFontSize2:(UILabel*)label{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
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
        if(size.width < screenWidth*0.84 && size.height <= rect.size.height) {
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
-(void)ReloadController{

    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {

    }

    UIStoryboard *MyStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil ];
    ViewPreviewMenuController *vc = [MyStoryboard instantiateViewControllerWithIdentifier:@"PreviewStoryID"];
    [self presentViewController:vc animated:NO completion:nil];
}



#pragma mark - Initialization




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
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    [self.progressHUD hide:YES afterDelay:15.0];
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

#pragma mark - Preview GUI
#pragma mark - Preview

- (IBAction)Match_Action:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                       options:@{}
                             completionHandler:nil];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"goSettingSegue"]) {
       
        
        
    }
    else if([segue.identifier isEqualToString:@"PreviewDetailSegue"]) {
        NSLog(@"segue.identifier isEqualToString:goFileSegue");
   
    }
    else if([segue.identifier isEqualToString:@"PreviewDetailNovatekSegue"])
    {
        
    }
    else if([segue.identifier isEqualToString:@"goFileSegue"]) {
        NSLog(@"segue.identifier isEqualToString:goFileSegue");
        UINavigationController *navVC = [segue destinationViewController];
        FileListViewController *fileListViewController = (FileListViewController *)navVC.topViewController;
        fileListViewController.oriType = 0;
    }
}

- (IBAction)settingAction:(id)sender {

    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        [self performSegueWithIdentifier:@"goSettingSegue" sender:sender];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [self performSegueWithIdentifier:@"goSettingSegue" sender:sender];
    }

}


- (IBAction)mpbAction:(id)sender
{
    
        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
        {//
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            //[self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if ([[self NVTGetHttpCmd:@"3024"] isEqualToString:@"0"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showProgressHUDNotice:NSLocalizedString(@"NoCard", nil) showTime:2.0];
                    });
                    return;
                }


                    dispatch_async(dispatch_get_main_queue(), ^{
                        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
                        {
                            [_np stop];

                        }
                        [self hideProgressHUD:YES];
                        [self performSegueWithIdentifier:@"goMpbSegue" sender:sender];
                        
                    });
            });
        }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            //[self showProgressHUDWithMessage:[self getStringForKey:@"STREAM_ERROR_CAPTURING_CAPTURE" withTable:@""]];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (![_ctrl.propCtrl checkSDExist]) {
                    printf("wfcwc");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showProgressHUDNotice:NSLocalizedString(@"NoCard", nil) showTime:2.0];
                    });
                    return;
                }
                
                //        [self stopYoutubeLive];

                dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [self performSegueWithIdentifier:@"goMpbSegue" sender:sender];
                        
                });
                
            });
        }
}
#pragma mark - ICatchWificamListener

- (IBAction)preview_countiBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_np != nil) {
        [_np stop];
    }
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {

         [self performSegueWithIdentifier:@"PreviewDetailNovatekSegue" sender:sender];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {

       
            [[SDK instance] destroySDK];
            [self performSegueWithIdentifier:@"PreviewDetailSegue" sender:sender];


    }
    
    
}

- (IBAction)AboutAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial || [SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        [_np stop];
       /* [_ijkplayer stop];
        [_ijkplayer shutdown];
        self.PlayerView = nil;
        [self removeMovieNotificationObservers];*/
        
    }
    [self performSegueWithIdentifier:@"goAboutSegue" sender:sender];
}

- (IBAction)preview_settingBT_clicked:(id)sender {
    
        if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
        {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [_np stop];
            [self performSegueWithIdentifier:@"goSettingSegue" sender:sender];
        }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
             AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            [_np stop];
            [self performSegueWithIdentifier:@"goSettingSegue" sender:sender];
        }

}

- (IBAction)preview_fileBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(SSID != nil)
    {
        if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
            [self NodePlayerStop];
        }
        else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
        {
            [self NodePlayerStop];
        }
    }
    [self performSegueWithIdentifier:@"goFileSegue" sender:sender];

}
- (IBAction)formatBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(self.progressHUD != nil) {
        [self.progressHUD show:YES];
    }
    [self NVTSendHttpCmd:@"3010" Par2:@"1"];
    [self getLastFormatDate];
    [self performSelector:@selector(reloadDashcamData) withObject:nil afterDelay:1.9];
    [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:2];
}
- (IBAction)DashcamInfoBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"NavigationDashcamInfo"];//NavigationDashcamInfo
    [self presentViewController:vc animated:YES completion:NULL];
}
- (IBAction)AudioOnBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(self.progressHUD != nil) {
        [self.progressHUD show:YES];
    }
    [self NVTSendHttpCmd:@"2007" Par2:@"0"];
    [self performSelector:@selector(reloadDashcamData) withObject:nil afterDelay:1.9];
    [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:2];
}
- (IBAction)AudioOffBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(self.progressHUD != nil) {
        [self.progressHUD show:YES];
    }
    [self NVTSendHttpCmd:@"2007" Par2:@"1"];
    [self performSelector:@selector(reloadDashcamData) withObject:nil afterDelay:1.9];
    [self performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:2];
}
- (IBAction)PreviewBtn_K7_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_np != nil) {
        [_np stop];
    }
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        
        [self performSegueWithIdentifier:@"PreviewDetailNovatekSegue" sender:sender];
    }
    else if([SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial)
    {
        
        
        [[SDK instance] destroySDK];
        [self performSegueWithIdentifier:@"PreviewDetailSegue" sender:sender];
        
        
    }
}
-(void)hideProgressHUD {
    [self hideProgressHUD:YES];
}
-(void)reloadDashcamData {
    [self NVTGetHttpCmd:@"3014"];
    [self getDashcamTimeDate];
    [self getCountryTimeZone];
    [self getLastFormatDate];
    [self getAudioRecState];
}
-(void)getDashcamTimeDate {
    NSString *str = [self NVTGetHttpCmd:@"3119"];
    if(str == nil) {
        return;
    }
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    NSString *year,*month,*day;
    NSString *displayDateStr = @"";
    NSRange range = [str rangeOfString:@" "];
    if(range.location != NSNotFound) {
        NSString *strDate = [str substringWithRange:NSMakeRange(0, range.location)];
        displayDateStr = strDate;
        NSRange range = [strDate rangeOfString:@"/"];
        if(range.location != NSNotFound) {
            year = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
            displayDateStr = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
            range = [displayDateStr rangeOfString:@"/"];
            if(range.location != NSNotFound) {
                month = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
                day = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
            }
        }
        range = [str rangeOfString:@" "];
        if(range.location != NSNotFound) {
            strDate = [str substringWithRange:NSMakeRange(range.location, str.length-range.location)];
        }
        NSLog(@"AAAA->%@",strDate);
        if([dateFormat  isEqual: @"DDMMYYYY"]) {
            displayDateStr = [NSString stringWithFormat:@"%@/%@/%@%@",day,month,year,strDate];
        } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
            displayDateStr = [NSString stringWithFormat:@"%@/%@/%@%@",month,day,year,strDate];
        } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
            displayDateStr = [NSString stringWithFormat:@"%@/%@/%@%@",year,month,day,strDate];
        }
    }
    
    [_timeDateInfoText setText:displayDateStr];
}
-(void)getCountryTimeZone {
    int country = 255,timezoneDST = 255;
    NSString *strTemp = @"";
    country = [[_NVTGetHttpValueDict objectForKey:@"3110"] intValue];
    timezoneDST = [[_NVTGetHttpValueDict objectForKey:@"3109"] intValue];
    
    if(country >= country_UnitedStates_EST && country <= country_UnitedStates_HST) {
        strTemp = [delegate getStringForKey:@"SetCountry_UnitedState" withTable:nil];
    } else if(country >= country_Canada_NST && country <= country_Canada_PST) {
        strTemp = [delegate getStringForKey:@"SetCountry_Canada" withTable:nil];
    } else if(country >= country_Russia_KALT && country <= country_Russia_PETT) {
        strTemp = [delegate getStringForKey:@"SetCountry_Russia" withTable:nil];
    } else if(country == country_Spain) {
        strTemp = [delegate getStringForKey:@"SetCountry_Spain" withTable:nil];
    } else if(country == country_Germany) {
        strTemp = [delegate getStringForKey:@"SetCountry_Germany" withTable:nil];
    } else if(country == country_France) {
        strTemp = [delegate getStringForKey:@"SetCountry_France" withTable:nil];
    } else if(country == country_Italy) {
        strTemp = [delegate getStringForKey:@"SetCountry_Italy" withTable:nil];
    } else if(country == country_Netherlands) {
        strTemp = [delegate getStringForKey:@"SetCountry_Netherlands" withTable:nil];
    } else if(country == country_Belgium) {
        strTemp = [delegate getStringForKey:@"SetCountry_Belgium" withTable:nil];
    } else if(country == country_Poland) {
        strTemp = [delegate getStringForKey:@"SetCountry_Poland" withTable:nil];
    } else if(country == country_Czech) {
        strTemp = [delegate getStringForKey:@"SetCountry_Czech" withTable:nil];
    } else if(country == country_Romania) {
        strTemp = [delegate getStringForKey:@"SetCountry_Romania" withTable:nil];
    } else if(country == country_UnitedKingdom) {
        strTemp = [delegate getStringForKey:@"SetCountry_UnitedKingdom" withTable:nil];
    } else if(country == country_others) {
        strTemp = [delegate getStringForKey:@"SetCountry_Other" withTable:nil];
    } else {
        strTemp = @"";
    }
    if(timezoneDST == 0) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-12"];
    } else if(timezoneDST == 1) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-11"];
    } else if(timezoneDST == 2) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-10"];
    } else if(timezoneDST == 3) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-9"];
    } else if(timezoneDST == 4) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-8"];
    } else if(timezoneDST == 5) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-7"];
    } else if(timezoneDST == 6) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-6"];
    } else if(timezoneDST == 7) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-5"];
    } else if(timezoneDST == 8) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-4"];
    } else if(timezoneDST == 9) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-3.5"];
    } else if(timezoneDST == 10) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-3"];
    } else if(timezoneDST == 11) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-2.5"];
    } else if(timezoneDST == 12) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-2"];
    } else if(timezoneDST == 13) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"-1"];
    } else if(timezoneDST == 14) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"GMT"];
    } else if(timezoneDST == 15) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+1"];
    } else if(timezoneDST == 16) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+2"];
    } else if(timezoneDST == 17) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+3"];
    } else if(timezoneDST == 18) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+4"];
    } else if(timezoneDST == 19) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+5"];
    } else if(timezoneDST == 20) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+6"];
    } else if(timezoneDST == 21) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+7"];
    } else if(timezoneDST == 22) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+8"];
    } else if(timezoneDST == 23) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+9"];
    } else if(timezoneDST == 24) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+10"];
    } else if(timezoneDST == 25) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+11"];
    } else if(timezoneDST == 26) {
        strTemp = [NSString stringWithFormat:@"%@, GMT %@",strTemp,@"+12"];
    } else {
        
    }
    [_countryTimeZoneText setText:strTemp];
}
-(bool) checkSdCardExist {
    bool cardExist = NO;
    if ([[self NVTGetHttpCmd:@"3024"] isEqualToString:@"1"]) {
        cardExist = YES;
    } else {
        cardExist = NO;
    }
    return cardExist;
}
-(void) getLastFormatDate {
    if([self checkSdCardExist] == NO) {
        [_lastFormatDateInfoText setText:[delegate getStringForKey:@"SetNoSDCard" withTable:@""]];
        return;
    }
    
    NSString *str = [self NVTGetHttpCmd:@"3203"];//@"   0, 0, 0, 0, 0, 0";
    NSString *strTemp = @"";//只有年月日 xxxx/xx/xx
    if(str == nil) {
        return;
    }
    NSRange range;
    range = [str rangeOfString:@","];
    if(!(range.location == NSNotFound)) {
        str = [str stringByReplacingCharactersInRange:range withString:@"/"];
    } else {
        return;
    }
    range = [str rangeOfString:@","];
    if(!(range.location == NSNotFound)) {
        str = [str stringByReplacingCharactersInRange:range withString:@"/"];
    } else {
        return;
    }
    range = [str rangeOfString:@","];
    if(!(range.location == NSNotFound)) {
        str = [str stringByReplacingCharactersInRange:range withString:@"-"];
        strTemp = [str substringWithRange:NSMakeRange(0, range.location)];
        strTemp = [strTemp stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    } else {
        return;
    }
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@":"];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@" "];//年月日時分秒都有 xxxx/xx/xx xx:xx:xx
    if([strTemp isEqualToString:@"0000/00/00"] ||
       [strTemp isEqualToString:@"00/00/00"]) {
        [_lastFormatDateInfoText setText:@"----/--/--"];
    } else {
        NSString *year,*month,*day;
        NSString *displayDateStr = @"";
        NSRange range = [str rangeOfString:@" "];
        if(range.location != NSNotFound) {
            NSString *strDate = [strTemp substringWithRange:NSMakeRange(0, range.location)];
            displayDateStr = strDate;
            NSRange range = [strDate rangeOfString:@"/"];
            if(range.location != NSNotFound) {
                year = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
                displayDateStr = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
                range = [displayDateStr rangeOfString:@"/"];
                if(range.location != NSNotFound) {
                    month = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
                    day = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
                }
            }
            if([dateFormat  isEqual: @"DDMMYYYY"]) {
                displayDateStr = [NSString stringWithFormat:@"%@/%@/%@",day,month,year];
            } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
                displayDateStr = [NSString stringWithFormat:@"%@/%@/%@",month,day,year];
            } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
                displayDateStr = [NSString stringWithFormat:@"%@/%@/%@",year,month,day];
            }
        }
        [_lastFormatDateInfoText setText:displayDateStr];
    }
    
}
-(void) getAudioRecState {
    int state = [[_NVTGetHttpValueDict objectForKey:@"2007"] intValue];
    if(state == 0) {
        [_audioOnBtn setImage:[UIImage imageNamed:@"control_audio"] forState:UIControlStateNormal];
        [_audioOffBtn setImage:[UIImage imageNamed:@"control_audio_off_disable"] forState:UIControlStateNormal];
    } else {
        [_audioOnBtn setImage:[UIImage imageNamed:@"control_audio_disable"] forState:UIControlStateNormal];
        [_audioOffBtn setImage:[UIImage imageNamed:@"control_audio_off"] forState:UIControlStateNormal];
    }
}
#pragma Selector func


- (NSString *)recheckSSID
{
    //    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    //    NSLog(@"Networks: %@",networkInterfaces);
#if 0
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
#endif
    NSString *wifiName = nil;
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifnam in ifs) {
        NSDictionary *info = (__bridge_transfer NSDictionary *)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        //NSLog(@"%@--->   AAAA    %@",ifnam,info);
        if (info[@"SSID"]) {
            wifiName = info[@"SSID"];
        }
    }
    return wifiName;
    
}


- (NSString *)GetCurrentMode{
    return [self NVTGetHttpCmd:@"3037"];
}

- (void)SetCurrentMode:(NSString *)cmd Par2:(NSString *)par{
    [self NVTSendHttpCmd:cmd Par2:par];
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
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"MovieLiveViewLink"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = YES;
    }
    else if([elementName isEqualToString:@"SSID"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = YES;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"PASSPHRASE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = YES;
    }
    else{
        storingFlag = FALSE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
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
        else if(MovieLiveFlag){
            MovieLiveFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"2019"];
        }
        else if(ssidFlag){
            ssidFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"SSID"];
        }
        else if(passwordFlag){
            passwordFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"WirelessLinkPassword"];
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
- (void)closeProgressUI {
    [self hideProgressHUD:YES];
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
        if(event == 1003) {
            
            if(reconnectCount == 10) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideProgressHUD:YES];
                    [self NodePlayerStop];
                    reconnectCount = 0;
                });
            } else {
                reconnectCount++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial ||
               [SSIDSreial CheckSSIDSerial:SSID] == ICATCH_SSIDSerial) {
                [self showProgressHUDWithMessage:nil];
                [_Playback_Btn setEnabled:NO];
                [_Setting_Btn setEnabled:NO];
                
            } else {
                [self hideProgressHUD:YES];
            }
            
        });
    }
    if(event == 1001)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
            [_Playback_Btn setEnabled:YES];
            [_Setting_Btn setEnabled:YES];
        });
    }
    else if(event == 1004)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
        });
    }
    else if(event == 1102)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.NoPreviewView.hidden = YES;
            [self hideProgressHUD:YES];
        });
    }
}
@end
