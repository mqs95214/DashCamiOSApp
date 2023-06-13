//
//  CustomSettingSubViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/7.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "CustomSettingSubViewController.h"
#import "CustomSettingSubDetailViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "SSID_SerialCheck.h"
#import "SettingSubMenu.h"
@interface CustomSettingSubViewController ()
{
    SSID_SerialCheck *SSIDSreial;
    AppDelegate *delegate;
}
@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;
@property(nonatomic) MBProgressHUD *progressHUD;
@property(nonatomic) UITextField *LicensePlateStamp;
@property(nonatomic) UIButton *PlateOK;
@property(nonatomic) UIView *underLine;
@property(nonatomic) NSString *SSID;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;

@property (weak, nonatomic) IBOutlet UIButton *VideoModeBtn;

@property (weak, nonatomic) IBOutlet UIButton *PhotoModeBtn;

@property (weak, nonatomic) IBOutlet UITableView *SubTable;

@property (weak, nonatomic) IBOutlet UIButton *SetupModeBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordPrompt;
@property (weak, nonatomic) IBOutlet UILabel *passwordConfirmPrompt;
@property (weak, nonatomic) IBOutlet UIButton *passwordVisibilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwordConfirmVisibilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwordOkBtn;

@property(nonatomic,strong)NSBundle *bundle;
@property (weak, nonatomic) IBOutlet UIView *underLineView;
@property (strong, nonatomic) IBOutlet UIView *currentSizeView;

@end



@implementation CustomSettingSubViewController

@synthesize subMenuTable;
@synthesize curSettingDetailType;
@synthesize curSettingDetailItem;
#define LicensePlateStampTextLimit 9

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.delegate = self;
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    
    /*關掉 Navigation Bar 返回文字*/
    [self.VideoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_video"] forState:UIControlStateNormal];
    
    [self.VideoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_video_select"] forState:UIControlStateSelected];
    
    [self.PhotoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_camera"] forState:UIControlStateNormal];
    
    [self.PhotoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_camera_select"] forState:UIControlStateSelected];
    
    [self.SetupModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_setting"] forState:UIControlStateNormal];
    
    [self.SetupModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_setting_select"] forState:UIControlStateSelected];

    _passwordText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNewPassword" withTable:@""]];
    _passwordConfirmText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetConfirmNewPassword" withTable:@""]];
    _passwordPrompt.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetPleaseInsert8Characters" withTable:@""]];
    _passwordConfirmPrompt.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetPleaseInsert8Characters" withTable:@""]];
    _passwordOkBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"BtnOK" withTable:@""]];
    if(self.curState == 0)
    {
        self.VideoModeBtn.selected = 1;
        self.PhotoModeBtn.selected = 0;
        self.SetupModeBtn.selected = 0;
    }
    else if(self.curState == 1)
    {
        self.VideoModeBtn.selected = 0;
        self.PhotoModeBtn.selected = 1;
        self.SetupModeBtn.selected = 0;
    }
    else
    {
        
        self.VideoModeBtn.selected = 0;
        self.PhotoModeBtn.selected = 0;
        self.SetupModeBtn.selected = 1;
    }
    self.SubTable.backgroundColor = UIColor.clearColor;
    self.SubTable.sectionIndexBackgroundColor = UIColor.clearColor;
    self.SubTable.sectionIndexTrackingBackgroundColor = UIColor.clearColor;
    self.SubTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.SubTable.delegate = self;
    self.SubTable.dataSource = self;
    
    
    [_SubTable setHidden:NO];
    [_passwordView setHidden:YES];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
        [self NVTGetHttpCmd:@"3014"];
        [self NVTGetHttpCmd:@"3118"];
        [self NVTGetHttpCmd:@"3119"];
        if(curSettingDetailType == SettingDetailTypePasswordChange) {
            self.passwordTextField.delegate = self;
            self.passwordConfirmTextField.delegate = self;
            [_SubTable setHidden:YES];
            [_passwordView setHidden:NO];
        } else {
            [_SubTable setHidden:NO];
            [_passwordView setHidden:YES];
        }
    }
    else
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.camera = _wifiCam.camera;
        self.ctrl = _wifiCam.controler;
    }
    
    

}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    bool isOk = false;
    //7 = first 第一次加載是7 排除重複加載
    for(int i=0;i<[[[self view] subviews] count];i++) {
        if([[[self view] subviews] objectAtIndex:i] == self.LicensePlateStamp) {
            isOk = true;
        }
    }
    if(isOk == true) {
        return;
    }
    //if((unsigned long)[[[self view] subviews] count] > 7) {
    //    return;
    //}
    //NSLog(@"ASASApppppppppp ->  %lu",(unsigned long)[[[self view] subviews] count]);
    float topSafeBorder = 0.0;
    if (@available(iOS 11.0, *)) {
        topSafeBorder = self.view.safeAreaInsets.top;
        //NSLog(@"oooooRRR   %f",topSafeBorder);
    } else {
        topSafeBorder = 0;
        // Fallback on earlier versions
    };
    if(curSettingDetailType == SettingDetailTypeLicensePlateStamp)
    {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        //=====================TextField========================
        
        
        /*if (@available(iOS 11.0, *)) {
            self.titleText.text = [NSString stringWithFormat:@"%2.2f,%2.2f,%2.2f,%2.2f ",self.view.safeAreaInsets.top,self.view.safeAreaInsets.bottom,self.view.safeAreaInsets.left,self.view.safeAreaInsets.right];
        } else {
            // Fallback on earlier versions
        }*/
        CGFloat sizeHeight = screenSize.height*62/896;
        self.LicensePlateStamp = [[UITextField alloc] initWithFrame:CGRectMake(10, topSafeBorder+sizeHeight, UIScreen.mainScreen.bounds.size.width-20, 50)];
        self.LicensePlateStamp.delegate = self;
        self.underLine = [[UIView alloc]initWithFrame:CGRectMake(0,topSafeBorder+self.LicensePlateStamp.frame.size.height-6,self.LicensePlateStamp.frame.size.width,2)];
        [self.LicensePlateStamp setTextColor:[UIColor whiteColor]];
        //[LicensePlateStamp setBackgroundColor:[UIColor lightGrayColor]];
        self.underLine.backgroundColor = [UIColor lightGrayColor];
        [[self view] addSubview:self.LicensePlateStamp];
        [self.LicensePlateStamp addSubview:self.underLine];
        NSString *curLicensePlateStamp = @"";
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial) {
            [self NVTGetHttpCmd:@"3118"];
            curLicensePlateStamp = [self.NVTGetHttpValueDict objectForKey:@"3118"];
            if([curLicensePlateStamp  isEqualToString: @"         "]) {
                curLicensePlateStamp = @"";
            }
        } else {
            NSRange range;
            curLicensePlateStamp = [[SDK instance] retrieveCurrentLicensePlateStamp];
            if([curLicensePlateStamp  isEqualToString: @"         "]) {
                curLicensePlateStamp = @"";
            }
            
            
        }
        float space = self.LicensePlateStamp.frame.size.width/18;
        NSString *labelText = curLicensePlateStamp;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];
        
        self.LicensePlateStamp.attributedText = attributedString;
        
        [self.LicensePlateStamp addTarget:self
                                   action:@selector(textFieldDidChange:)
         
                         forControlEvents:UIControlEventEditingChanged];
        
        
        //[self.LicensePlateStamp setText:curLicensePlateStamp];
        [self.LicensePlateStamp becomeFirstResponder];
        
        //=====================Button========================
        
        self.PlateOK = [[UIButton alloc] initWithFrame:CGRectMake(0, topSafeBorder+self.LicensePlateStamp.frame.size.height+sizeHeight, UIScreen.mainScreen.bounds.size.width, self.LicensePlateStamp.frame.size.height)];
        self.PlateOK.backgroundColor = [UIColor clearColor];
        
        [self.PlateOK setTitle:[delegate getStringForKey:@"BtnOK" withTable:@""] forState:UIControlStateNormal];
        [self.PlateOK setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [self.PlateOK addTarget:self action:@selector(onClickButtonOfPlateTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        
        [[self view] addSubview:self.PlateOK];
        
    }
}

-(void)textFieldDidChange :(UITextField *) textField{
    float space = textField.frame.size.width/18;
    NSString *labelText = textField.text;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText attributes:@{NSKernAttributeName:@(space)}];

    self.LicensePlateStamp.attributedText = attributedString;
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *title = nil;
    UIImage *image;
    switch (curSettingDetailType) {
        case SettingDetailTypeWhiteBalance:
            title = [delegate getStringForKey:@"SETTING_AWB" withTable:@""];
            break;
            
        case SettingDetailTypePowerFrequency:
            title = [delegate getStringForKey:@"SETTING_POWER_SUPPLY" withTable:@""];
            break;
            
        case SettingDetailTypeBurstNumber:
            title = [delegate getStringForKey:@"SetPhotoBurst" withTable:@""];
            break;
        case SettingDetailTypeDelayTimer:
            title = [delegate getStringForKey:@"SetDelayTime" withTable:@""];
            break;
        case SettingDetailTypeAbout:
            title = [delegate getStringForKey:@"SETTING_ABOUT" withTable:@""];
            break;
            
        case SettingDetailTypeDateStamp:
            title = [delegate getStringForKey:@"SETTING_DATESTAMP" withTable:@""];
            break;
        case SettingDetailTypeVideoQuality:
            title = [delegate getStringForKey:@"SetVideoQuality" withTable:@""];
            break;
        case SettingDetailTypeTimelapseInterval:
            title = [delegate getStringForKey:@"SETTING_CAP_TIMESCAPE_INTERVAL" withTable:@""];
            break;
            
        case SetttngDetailTypeTimelapseDuration:
            title = [delegate getStringForKey:@"SETTING_CAP_TIMESCAPE_LIMIT" withTable:@""];
            break;
            
        case SettingDetailTypeUpsideDown:
            title = [delegate getStringForKey:@"SETTING_UPSIDE_DOWN" withTable:@""];
            break;
            
        case SettingDetailTypeSlowMotion:
            title = [delegate getStringForKey:@"SETTING_SLOW_MOTION" withTable:@""];
            break;
            
        case SettingDetailTypeImageSize:
            title = [delegate getStringForKey:@"SetPhotoResolution" withTable:@""];
            break;
            
        case SettingDetailTypeVideoSize:
            title = [delegate getStringForKey:@"ALERT_TITLE_SET_VIDEO_RESOLUTION" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_video"];
            break;
            
        case SettingDetailTypeCaptureDelay:
            title = [delegate getStringForKey:@"ALERT_TITLE_SET_SELF_TIMER" withTable:@""];
            break;
            
        case SettingDetailTypeLiveSize:
            title = [delegate getStringForKey:@"LIVE_RESOLUTION" withTable:@""];
            break;
            
        case SettingDetailTypeScreenSaver:
            title = [delegate getStringForKey:@"SetScreenSaver" withTable:@""];
            break;
            
        case SettingDetailTypeAutoPowerOff:
            title = [delegate getStringForKey:@"SetAutoPowerOff" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
            
        case SettingDetailTypeExposureCompensation:
            title = [delegate getStringForKey:@"SetExposureCompensation" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_video"];
            break;
            
        case SettingDetailTypeVideoFileLength:
            title = [delegate getStringForKey:@"SetVideoFileLength" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_video"];
            break;
            
        case SettingDetailTypeFastMotionMovie:
            title = [delegate getStringForKey:@"SetFastMotionMovie" withTable:@""];
            break;
        case SettingDetailTypeResetAll:
            title = [delegate getStringForKey:@"SetResetAll" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypeCountry:
            title = [delegate getStringForKey:@"SetCountry" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypeLanguage:
            title = [delegate getStringForKey:@"SetLanguage" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypeTimeZone:
            title = [delegate getStringForKey:@"SetTimeZone" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypeSDFormat:
            title = [delegate getStringForKey:@"SetSDFormat" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypePhotoExposureCompensation:
            title = [delegate getStringForKey:@"SetExposureCompensation" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_camera"];
            break;
        case SettingDetailTypeGSensor:
            title = [delegate getStringForKey:@"SetGSensor" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_video"];
            break;
        case SettingDetailTypeSpeedUnit:
            title = [delegate getStringForKey:@"SetSpeedUnit" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypeLicensePlateStamp:
            title = [delegate getStringForKey:@"SetLicensePlateStamp" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_video"];
            break;
        case SettingDetailTypeDeviceSounds:
        case SettingDetailTypeNvtDeviceSounds:
            title = [delegate getStringForKey:@"SetDeviceSounds" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        case SettingDetailTypePasswordChange:
            title = [delegate getStringForKey:@"SetWirelessLinkPassword2" withTable:@""];
            image = [UIImage imageNamed:@"control_dashcamsetting_setting"];
            break;
        default:
            break;
    }
    //[self.navigationItem setTitle:title];
    self.titleText.text = title;
    self.titleImage.image = image;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recoverFromDisconnection)
                                             name    :@"kCameraNetworkConnectedNotification"
                                             object  :nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kCameraNetworkConnectedNotification" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)recoverFromDisconnection
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        self.progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MWPhotoBrowser.bundle/images/Checitekmark.png"]];
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
- (NSInteger) tableView             :(UITableView *)tableView
              numberOfRowsInSection :(NSInteger)section
{
    return [subMenuTable count];
}

- (UITableViewCell *) tableView             :(UITableView *)tableView
                      cellForRowAtIndexPath :(NSIndexPath *)indexPath
{
      SettingSubMenu *cell = [tableView dequeueReusableCellWithIdentifier:@"SubMenuCell" forIndexPath:indexPath];

   /*
    static NSString *CellIdentifier = @"settingDetailCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }*/

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if(curSettingDetailType == SettingDetailTypePasswordChange) {
        
    } else {
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        cell.textLabel.font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:17];
        if(curSettingDetailItem == indexPath.row)
        {
            cell.textLabel.textColor = [UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1];
        }
        else
        {
            cell.textLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
        }
        
        cell.textLabel.text = [delegate getStringForKey:[subMenuTable objectAtIndex:indexPath.row] withTable:@""];
    }
    
    
    return cell;
}

#pragma mark - Table view data delegate
- (void)tableView               :(UITableView *)tableView
        didSelectRowAtIndexPath :(NSIndexPath *)indexPath
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    uint value = 0;
    uint country_value = 0;
    BOOL errorHappen = NO;
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (curSettingDetailType) {
        case SettingDetailTypeWhiteBalance:
            value = [_ctrl.propCtrl parseWhiteBalanceInArray:indexPath.row];
            if ([_ctrl.propCtrl changeWhiteBalance:value] == WCRetSuccess) {
                _camera.curWhiteBalance = value;
            } else {
                errorHappen = YES;
            }
            break;
            
        case SettingDetailTypePowerFrequency:
            value = [_ctrl.propCtrl parsePowerFrequencyInArray:indexPath.row];
            if ([_ctrl.propCtrl changeLightFrequency:value] == WCRetSuccess) {
                _camera.curLightFrequency = value;
            } else {
                errorHappen = YES;
            }
            break;
            
        case SettingDetailTypeBurstNumber:
            value = [_ctrl.propCtrl parseBurstNumberInArray:indexPath.row];
            AppLog(@"_camera.curBurstNumber: %d", _camera.curBurstNumber);
            if ([_ctrl.propCtrl changeBurstNumber:value] == WCRetSuccess) {
                _camera.curBurstNumber = value;
                
                AppLog(@"_camera.curBurstNumber: %d", _camera.curBurstNumber);
            } else {
                errorHappen = YES;
            }
            
            break;
            
        case SettingDetailTypeDateStamp:
            value = [_ctrl.propCtrl parseDateStampInArray:indexPath.row];
            if ([_ctrl.propCtrl changeDateStamp:value] == WCRetSuccess) {
                AppLog(@"set date stamp to value: %d", value);
                _camera.curDateStamp = value;
            } else {
                errorHappen = YES;
            }
            break;
            
        case SettingDetailTypeTimelapseInterval:
            value = [_ctrl.propCtrl parseTimelapseIntervalInArray:indexPath.row];
            AppLog(@"set timelapse interval to : %d", value);
            if ([_ctrl.propCtrl changeTimelapseInterval:value] == WCRetSuccess) {
                _camera.curTimelapseInterval = value;
                
                // Re-Get
                //_camera.curCaptureDelay = [_ctrl.propCtrl retrieveDelayedCaptureTime];
                //_camera.curBurstNumber = [_ctrl.propCtrl retrieveBurstNumber];
            } else {
                errorHappen = YES;
            }
            break;
            
        case SetttngDetailTypeTimelapseDuration:
            value = [_ctrl.propCtrl parseTimelapseDurationInArray:indexPath.row];
            AppLog(@"set timelapse duration to : %d", value);
            if ([_ctrl.propCtrl changeTimelapseDuration:value] == WCRetSuccess) {
                _camera.curTimelapseDuration = value;
            } else {
                errorHappen = YES;
            }
            break;
            
        case SettingDetailTypeTimelapseType: {
            ICatchPreviewMode mode = ICATCH_TIMELAPSE_STILL_PREVIEW_MODE;
            if (indexPath.row == 0) {
                value = WifiCamTimelapseTypeStill;
                mode = ICATCH_TIMELAPSE_STILL_PREVIEW_MODE;
            } else if (indexPath.row == 1) {
                value = WifiCamTimelapseTypeVideo;
                mode = ICATCH_TIMELAPSE_VIDEO_PREVIEW_MODE;
            }
            
            if ([_ctrl.propCtrl changeTimelapseType:mode] == WCRetSuccess) {
                _camera.timelapseType = value;
            } else {
                errorHappen = YES;
            }
        }
            break;
            
        case SettingDetailTypeUpsideDown:
            if ([_ctrl.propCtrl changeUpsideDown:(uint)indexPath.row] != WCRetSuccess) {
                errorHappen = YES;
            } else {
                _camera.curInvertMode = (uint)indexPath.row;
            }
            break;
            
        case SettingDetailTypeSlowMotion:
            if ([_ctrl.propCtrl changeSlowMotion:(uint)indexPath.row] != WCRetSuccess) {
                errorHappen = YES;
            } else {
                _camera.curSlowMotion = (uint)indexPath.row;
            }
            break;
            
        case SettingDetailTypeImageSize:
        {
            string value = [_ctrl.propCtrl parseImageSizeInArray:indexPath.row];
            if ([_ctrl.propCtrl changeImageSize:value] != WCRetSuccess) {
                errorHappen = YES;
            } else {
                _camera.curImageSize = value;
            }
            break;
        }
            
        case SettingDetailTypeVideoSize:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"2002" Par2:IndexPathRow];
                errorHappen = NO;
                [NSThread sleepForTimeInterval:1.0];
            }
            else
            {
                /*string value = [_ctrl.propCtrl parseVideoSizeInArray:indexPath.row];
                if ([_ctrl.propCtrl changeVideoSize:value] != WCRetSuccess) {
                    errorHappen = YES;
                } else {
                    _camera.curVideoSize = value;
                }*/
                uint value = [_ctrl.propCtrl parseVideoSizeInArray2:indexPath.row];
                if ([_ctrl.propCtrl changeVideoSize2:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
            
        case SettingDetailTypeCaptureDelay: {
            unsigned int curCaptureDelay = [_ctrl.propCtrl parseDelayCaptureInArray:indexPath.row];
            if ([_ctrl.propCtrl changeDelayedCaptureTime:curCaptureDelay] != WCRetSuccess) {
                errorHappen = YES;
            } else {
                _camera.curCaptureDelay = curCaptureDelay;
            }
        }
            break;
            
        case SettingDetailTypeLiveSize:
        {
            NSString *liveSize = [subMenuTable objectAtIndex:indexPath.row];
            AppLogDebug(AppLogTagAPP, @"%@", liveSize);
            NSArray *sizeAr = [liveSize componentsSeparatedByString:@" "];
            if (!liveSize) {
                errorHappen = YES;
            } else {
                [[NSUserDefaults standardUserDefaults] setObject:sizeAr[1] forKey:@"LiveSize"];
            }
            break;
        }
            
        case SettingDetailTypeScreenSaver:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3113" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseScreenSaverInArray:indexPath.row];
                if ([_ctrl.propCtrl changeScreenSaver:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
            
        case SettingDetailTypeAutoPowerOff:
        {
            if([SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3007" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseAutoPowerOffInArray:indexPath.row];
                if ([_ctrl.propCtrl changeAutoPowerOff:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypeParkingModeSensor:
        {
            uint value = [_ctrl.propCtrl parseParkingModeSensorInArray:indexPath.row];
            if ([_ctrl.propCtrl changeParkingModeSensor:value] == WCRetSuccess) {
                errorHappen = YES;
            }
            break;
        }
        case SettingDetailTypeGSensor:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"2011" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseGSensorInArray:indexPath.row Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
                if ([_ctrl.propCtrl changeGSensor:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypeSpeedUnit:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3111" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseSpeedUnitInArray:indexPath.row];
                if ([_ctrl.propCtrl changeSpeedUnit:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypePhotoBurst:
        {
            uint value = [_ctrl.propCtrl parsePhotoBurstInArray:indexPath.row];
            if ([_ctrl.propCtrl changePhotoBurst:value] == WCRetSuccess) {
                errorHappen = YES;
            }
            break;
        }
        case SettingDetailTypeDelayTimer:
        {
            uint value = [_ctrl.propCtrl parseDelayTimerInArray:indexPath.row];
            if ([_ctrl.propCtrl changeDelayTimer:value] == WCRetSuccess) {
                errorHappen = YES;
            }
            break;
        }
        case SettingDetailTypeTimeZone:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3109" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseTimeZoneInArray:indexPath.row];
                if ([_ctrl.propCtrl changeTimeZone:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypeLanguage:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3008" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                /* uint value = [_ctrl.propCtrl parseLanguageInArray:indexPath.row];
                 if ([_ctrl.propCtrl changeLanguage:value] == WCRetSuccess) {
                 errorHappen = YES;
                 }*/
            }
            break;
        }
        case SettingDetailTypeSDFormat:
        {
            /*uint value = [_ctrl.propCtrl parseDelayTimerInArray:indexPath.row];
             if ([_ctrl.propCtrl changeDelayTimer:value] == WCRetSuccess) {
             errorHappen = YES;
             }*/
            //printf("\nSettingDetailTypeSDFormat = %d",indexPath.row);
            if(indexPath.row == 0)
            {
                if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
                {
                    [self NVTSendHttpCmd:@"3010" Par2:@"1"];
                    errorHappen = NO;
                }
                else
                {
                    if ([_ctrl.propCtrl changeSDFormat] == WCRetSuccess) {
                        errorHappen = YES;
                    }
                }
            }
            
            /*uint value = [_ctrl.propCtrl parseDelayTimerInArray:indexPath.row];
             if ([_ctrl.propCtrl changeDelayTimer:value] == WCRetSuccess) {
             errorHappen = YES;
             }*/
            break;
        }
        case SettingDetailTypeResetAll:
        {
            /*uint value = [_ctrl.propCtrl parseDelayTimerInArray:indexPath.row];
             if ([_ctrl.propCtrl changeDelayTimer:value] == WCRetSuccess) {
             errorHappen = YES;
             }*/
            //printf("\nSettingDetailTypeSDFormat = %d",indexPath.row);
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                errorHappen = NO;
                if(indexPath.row == 0)
                {
                    [self NVTGetHttpCmd:@"3011"];
                }
            }
            else
            {
                if(indexPath.row == 0)
                {
                    if ([_ctrl.propCtrl changeResetAll:1] == WCRetSuccess) {
                        errorHappen = YES;
                    }
                }
                else
                {
                    errorHappen = YES;
                }
            }
            /*uint value = [_ctrl.propCtrl parseDelayTimerInArray:indexPath.row];
             if ([_ctrl.propCtrl changeDelayTimer:value] == WCRetSuccess) {
             errorHappen = YES;
             }*/
            break;
        }
            /* case SettingDetailTypeScreenSaver:
             {
             uint value = [_ctrl.propCtrl parseSpeedUnitInArray:indexPath.row];
             if ([_ctrl.propCtrl changeSpeedUnit:value] == WCRetSuccess) {
             errorHappen = YES;
             }
             break;
             }*/
        case SettingDetailTypeExposureCompensation:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"2005" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parseExposureCompensationInArray:indexPath.row Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
                if ([_ctrl.propCtrl changeExposureCompensation:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypePhotoExposureCompensation:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                [self NVTSendHttpCmd:@"3201" Par2:IndexPathRow];
                errorHappen = NO;
            }
            else
            {
                uint value = [_ctrl.propCtrl parsePhotoExposureCompensationInArray:indexPath.row  Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
                if ([_ctrl.propCtrl changePhotoExposureCompensation:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
        case SettingDetailTypeVideoQuality:
        {
            uint value = [_ctrl.propCtrl parseVideoQualityInArray:indexPath.row];
            if ([_ctrl.propCtrl changeVideoQuality:value] == WCRetSuccess) {
                errorHappen = YES;
            }
            break;
        }
        case SettingDetailTypeVideoFileLength:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW)
                {
                    NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                    [self NVTSendHttpCmd:@"2003" Par2:IndexPathRow];
                    errorHappen = NO;
                }
                else if([SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
                {
                    NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                    [self NVTSendHttpCmd:@"2016" Par2:IndexPathRow];
                    errorHappen = NO;
                }
                else if([SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
                        [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W) {
                    NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
                    [self NVTSendHttpCmd:@"2003" Par2:IndexPathRow];
                    errorHappen = NO;
                }
            }
            else
            {
                uint value = [_ctrl.propCtrl parseVideoFileLengthInArray:indexPath.row Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
                if ([_ctrl.propCtrl changeVideoFileLength:value] == WCRetSuccess) {
                    errorHappen = YES;
                }
            }
            break;
        }
            /*
             case SettingDetailTypeFastMotionMovie:
             {
             uint value = [_ctrl.propCtrl parseFastMotionMovieInArray:indexPath.row];
             if ([_ctrl.propCtrl changeFastMotionMovie:value] == WCRetSuccess) {
             errorHappen = YES;
             }
             break;
             }*/
        case SettingDetailTypeCountry:
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                if(indexPath.row >= 3)
                {
                    value = indexPath.row+20;
                    NSString *IndexPathRow = [NSString stringWithFormat:@"%ld",(long)value];
                    [self NVTSendHttpCmd:@"3110" Par2:IndexPathRow];
                }
                
                
                errorHappen = NO;
            }
            else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
            {
                if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                   [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                   [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
                {
                    if(indexPath.row >= 3)
                    {
                        value = (uint)(indexPath.row+1);
                        [_ctrl.propCtrl changeCountry:value];
                        //[self NVTSendHttpCmd:@"3110" Par2:IndexPathRow];
                    }
                    /*else if(indexPath.row >=4 && indexPath.row <=6)
                    {
                        value = (uint)(indexPath.row+1);
                        [_ctrl.propCtrl changeCountry:value];
                        //[self NVTSendHttpCmd:@"3110" Par2:IndexPathRow];
                    }
                    else if(indexPath.row >= 8)
                    {
                        value = (uint)(indexPath.row+1);
                        [_ctrl.propCtrl changeCountry:value];
                        //[self NVTSendHttpCmd:@"3110" Par2:IndexPathRow];
                    }*/
                    
                    
                    errorHappen = NO;
                    /* if(indexPath.row == 0)
                     {
                     country_value = 1;
                     }
                     else if(indexPath.row == 2){
                     country_value = 7;
                     }
                     else if(indexPath.row == 3){
                     country_value = 8;
                     }
                     else if(indexPath.row == 4){
                     country_value = 9;
                     }*/
                    /*uint value = [_ctrl.propCtrl parseCountryInArray:indexPath.row];
                     if(value != 1 && value != 2 && value != 4 && value != 8)
                     {
                     if ([_ctrl.propCtrl changeCountry:indexPath.row+1] == WCRetSuccess) {
                     errorHappen = YES;
                     }
                     }*/
                }
            }
            break;
        }
            /*case SettingDetailTypeDeviceSounds:
             {
             if(indexPath.row == 0){
             country_value = 1;
             }
             else if(indexPath.row == 1){
             country_value = 2;
             }
             else if(indexPath.row == 2){
             country_value = 3;
             }
             if ([_ctrl.propCtrl changeDevieceSounds:country_value ClickPosition:indexPath.row] == WCRetSuccess) {
             errorHappen = YES;
             }
             }*/
        case SettingDetailTypeAbout:
        default:
            break;
    }
    
    [_ctrl.propCtrl updateAllProperty:_camera];
    if (errorHappen) {
        [self showProgressHUDNotice:[delegate getStringForKey:@"STREAM_SET_ERROR" withTable:@""] showTime:2.0];
    } else {
        
        if(curSettingDetailType == SettingDetailTypeCountry)
        {
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                /*uint curCountry = [[self.NVTGetHttpValueDict objectForKey:@"3110"] intValue];*/
                if(indexPath.row <= 2)
                {
                    curSettingDetailItem = indexPath.row;
                    [self performSegueWithIdentifier:@"SubDetailMenu" sender:self];
                }
                else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
            {
                if(indexPath.row  <= 2)
                {
                    curSettingDetailItem = indexPath.row;
                    [self performSegueWithIdentifier:@"SubDetailMenu" sender:self];
                }
                else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
                /* uint curCountry = [_ctrl.propCtrl parseCountryInArray:indexPath.row];
                 if(curCountry == 1 || curCountry == 2 || curCountry == 4 || curCountry == 8)
                 {
                 curSettingDetailItem = indexPath.row;
                 [self performSegueWithIdentifier:@"showSubDetail" sender:self];
                 }
                 else{
                 [self.navigationController popToRootViewControllerAnimated:YES];
                 }*/
            }
        }
        else if(curSettingDetailType == SettingDetailTypeDeviceSounds){
            if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W)
            {
                if(indexPath.row == 0){
                    curSettingDetailItem = SettingBeep;
                }
                else if(indexPath.row == 1){
                    curSettingDetailItem = SettingAudioRec;
                }
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
            {
                if(indexPath.row == 0){
                    curSettingDetailItem = SettingAudioRec;
                }
                else if(indexPath.row == 1){
                    curSettingDetailItem = SettingAnnouncements;
                }
            }
            
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                    [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
            {
                if(indexPath.row == 0){
                    curSettingDetailItem = 0;
                }
                else if(indexPath.row == 1){
                    curSettingDetailItem = 1;
                }
                else if(indexPath.row == 2){
                    curSettingDetailItem = 2;
                }
            }
            else
            {
                if(indexPath.row == 0){
                    curSettingDetailItem = 0;
                }
                else if(indexPath.row == 1){
                    curSettingDetailItem = 1;
                }
                else if(indexPath.row == 2){
                    curSettingDetailItem = 2;
                }
            }
            [self performSegueWithIdentifier:@"SubDetailMenu" sender:self];
        }
        else{
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)tableView         :(UITableView *)tableView
        willDisplayCell   :(UITableViewCell *)cell
        forRowAtIndexPath :(NSIndexPath *)indexPath
{
    printf("indexPath.row = %ld\n",indexPath.row);
    if ((curSettingDetailItem == indexPath.row) && (curSettingDetailType != SettingDetailTypeAbout)) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewControlleVidr].
    // Pass the selected object to the new view controller.
    if(curSettingDetailType == SettingDetailTypeCountry)
    {
        //uint curCountry = [_ctrl.propCtrl parseCountryInArray:indexPath.row];
        if ([[segue identifier] isEqualToString:@"SubDetailMenu"]) {
            CustomSettingSubViewController *detail = [segue destinationViewController];
            
            detail.subMenuTable = subMenuTable;
            detail.curSettingDetailType = curSettingDetailType;
            detail.curSettingDetailItem = curSettingDetailItem;
        }
    }
    else if(curSettingDetailType == SettingDetailTypeDeviceSounds){
        if ([[segue identifier] isEqualToString:@"SubDetailMenu"]) {
            CustomSettingSubViewController *detail = [segue destinationViewController];
            
            detail.subMenuTable = subMenuTable;
            detail.curSettingDetailType = curSettingDetailType;
            detail.curSettingDetailItem = curSettingDetailItem;
        }
    }
}
- (IBAction)BackAction:(id)sender {AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    self.underLine.backgroundColor = [UIColor lightGrayColor];
    return [textField resignFirstResponder];
}
-(void) textFieldDidBeginEditing:(UITextField *)textField{
    
    self.underLine.backgroundColor = [UIColor colorWithRed:255.0/255 green:125.0/255 blue:190.0/255 alpha:1];
    self.LicensePlateStamp.keyboardType = UIKeyboardTypeASCIICapable;
    self.LicensePlateStamp.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
}
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.passwordTextField resignFirstResponder];
    [self.passwordConfirmTextField resignFirstResponder];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(nonnull NSString *)string{
    if(curSettingDetailType == SettingDetailTypeLicensePlateStamp) {
        NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        //NSRange lowercaseCharRange;
        //lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
        NSCharacterSet *cs;
        
        cs = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-."]invertedSet];
        if(toBeString.length > LicensePlateStampTextLimit)
        {
            /*if(lowercaseCharRange.location != NSNotFound){
             textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
             }*/
            textField.text = [toBeString substringToIndex:LicensePlateStampTextLimit];
            return NO;
        }
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@"="];
        BOOL canChange = [string isEqualToString:filtered];
        
        return canChange;
    } else if(curSettingDetailType == SettingDetailTypePasswordChange) {
        if(![self isAllowInput:string] && string.length > 0) {
            return NO;
        }
        if(textField == self.passwordTextField ||
           textField == self.passwordConfirmTextField) {
            if(textField == self.passwordTextField) {
                if(textField.text.length == 1 && string.length == 0) {
                    [_passwordPrompt setHidden:NO];
                } else {
                    [_passwordPrompt setHidden:YES];
                }
                
            }
            if(textField == self.passwordConfirmTextField) {
                if(textField.text.length == 1 && string.length == 0) {
                    [_passwordConfirmPrompt setHidden:NO];
                } else {
                    [_passwordConfirmPrompt setHidden:YES];
                }
                
            }
            if(textField == self.passwordTextField) {
                if(self.passwordConfirmTextField.text.length == 8 && textField.text.length >= 7 && string.length == 1) {
                    NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
                    if([str isEqualToString:_passwordConfirmTextField.text]) {
                        [_passwordOkBtn setEnabled:YES];
                    }
                } else {
                    [_passwordOkBtn setEnabled:NO];
                }
            }
            if(textField == self.passwordConfirmTextField) {
                if(self.passwordTextField.text.length == 8 &&
                   textField.text.length >= 7 && string.length == 1) {
                    NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
                    if([str isEqualToString:_passwordTextField.text]) {
                        [_passwordOkBtn setEnabled:YES];
                    }
                } else {
                    [_passwordOkBtn setEnabled:NO];
                }
            }
            if(textField.text.length < 8 || string.length == 0 || range.length > 0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

-(BOOL) isAllowInput:(NSString*)inputString {
    NSString *allowString = @"1234567890abcdefghijklmnopqrstupwxyzABCDEFGHIJKLMNOPQRSTUPWXYZ";
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:allowString];
    NSString *outputString = [[inputString componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return ![inputString isEqualToString:outputString];
}

- (IBAction)passwordOkBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([_passwordConfirmTextField.text isEqualToString:_passwordTextField.text] && _passwordConfirmTextField.text.length == 8) {
        NSString *str = @"";
        str = [NSString stringWithFormat:@"%@",_passwordConfirmTextField.text];
        [self NVTSendHttpStringCmd:@"3004" Par2:str];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)passwordVisibilityBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIImage *image = [_passwordVisibilityBtn imageForState:UIControlStateNormal];
    UIImage *image2 = [UIImage imageNamed:@"control_passwords_close"];
    if([image isEqual:image2]) {
        [_passwordVisibilityBtn setImage:[UIImage imageNamed:@"control_passwords_open"] forState:UIControlStateNormal];
        
        [_passwordTextField setSecureTextEntry:NO];
    } else {
        [_passwordVisibilityBtn setImage:[UIImage imageNamed:@"control_passwords_close"] forState:UIControlStateNormal];
        [_passwordTextField setSecureTextEntry:YES];
    }
}
- (IBAction)passwordConfirmVisibilityBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIImage *image = [_passwordConfirmVisibilityBtn imageForState:UIControlStateNormal];
    UIImage *image2 = [UIImage imageNamed:@"control_passwords_close"];
    if([image isEqual:image2]) {
        [_passwordConfirmVisibilityBtn setImage:[UIImage imageNamed:@"control_passwords_open"] forState:UIControlStateNormal];
        
        [_passwordConfirmTextField setSecureTextEntry:NO];
    } else {
        [_passwordConfirmVisibilityBtn setImage:[UIImage imageNamed:@"control_passwords_close"] forState:UIControlStateNormal];
        [_passwordConfirmTextField setSecureTextEntry:YES];
    }
}
- (IBAction)onClickButtonOfPlateTouchUp:(id)sender {
    self.PlateOK.backgroundColor = [UIColor clearColor];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *LicensePlateHttpString;
        LicensePlateHttpString = [_LicensePlateStamp.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [self NVTSendHttpStringCmd:@"3100" Par2:LicensePlateHttpString];
    }
    else
    {
        if(_LicensePlateStamp.text.length == 9) {
            
        } else if(_LicensePlateStamp.text.length == 8) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@" "];
        } else if(_LicensePlateStamp.text.length == 7) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"  "];
        } else if(_LicensePlateStamp.text.length == 6) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"   "];
        } else if(_LicensePlateStamp.text.length == 5) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"    "];
        } else if(_LicensePlateStamp.text.length == 4) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"     "];
        } else if(_LicensePlateStamp.text.length == 3) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"      "];
        } else if(_LicensePlateStamp.text.length == 2) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"       "];
        } else if(_LicensePlateStamp.text.length == 1) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"        "];
        } else if(_LicensePlateStamp.text.length == 0) {
            _LicensePlateStamp.text = [_LicensePlateStamp.text stringByAppendingString:@"         "];
        }
        [[SDK instance] setCustomizeStringProperty:CustomizePropertyID_LicensePlateStamp value:/*switchView.isOn*/self.LicensePlateStamp.text];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
    //NSLog(@"ssid : %@", ssid);
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
    //NSLog(@"GetValue = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    
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
- (void)NVTSendHttpStringCmd:(NSString *)cmd Par2:(NSString *)par{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&str=",par];
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
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NAVATAKE STRING = %@",str);
    
    
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
            if([SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W) {
                if([currentElementCommand  isEqual: @"9121"]) {
                    currentElementCommand = @"3118";
                }
            }
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
@end
