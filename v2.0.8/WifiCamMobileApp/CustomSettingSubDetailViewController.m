//
//  CustomSettingSubDetailViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/7.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "CustomSettingSubDetailViewController.h"
#import "CustomSettingSubViewController.h"
#import "SSID_SerialCheck.h"
#import "SettingSubDetailMenu.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface CustomSettingSubDetailViewController ()
<AppDelegateProtocol,UIScrollViewDelegate,NSXMLParserDelegate,UITableViewDelegate, UITableViewDataSource>
{
    int MinItem;
    int DeviceValue;
    int CurCountryValue;
    int curSelectedMenu;
    SSID_SerialCheck *SSIDSreial;
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UITableView *SubDetailTable;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;
@property(nonatomic) MBProgressHUD *progressHUD;
@property(nonatomic) NSArray *TextCellContent;
@property(nonatomic) NSString *SSID;
@property(nonatomic,strong)NSBundle *bundle;
@end


@implementation CustomSettingSubDetailViewController

@synthesize subMenuTable;
@synthesize curSettingDetailType;
@synthesize curSettingDetailItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    self.SubDetailTable.backgroundColor = UIColor.clearColor;
    self.SubDetailTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.SubDetailTable.delegate = self;
    self.SubDetailTable.dataSource = self;
    
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    NSString *title = nil;
    NSString *str1,*str2,*str3,*str4,*str5,*str6,*str7,*str8,*str9,*str10,*str11;
    self.navigationController.navigationBar.topItem.title = @"";
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
        [self NVTGetHttpCmd:@"3014"];
        [self NVTGetHttpCmd:@"3118"];
        [self NVTGetHttpCmd:@"3119"];
    }
    else
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.camera = _wifiCam.camera;
        self.ctrl = _wifiCam.controler;
    }
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.delegate = self;
    
    /*switch (curSettingDetailType) {
        case SettingDetailTypeCountry:
            title = NSLocalizedString(@"SetCountry", @"");
            break;
            
        case SettingDetailTypeWhiteBalance:
            title = NSLocalizedString(@"SETTING_AWB", @"");
            break;
            
        case SettingDetailTypePowerFrequency:
            title = NSLocalizedString(@"SETTING_POWER_SUPPLY", @"");
            break;
            
        case SettingDetailTypeBurstNumber:
            title = NSLocalizedString(@"SETTING_BURST", @"");
            break;
            
        case SettingDetailTypeAbout:
            title = NSLocalizedString(@"SETTING_ABOUT", @"");
            break;
            
        case SettingDetailTypeDateStamp:
            title = NSLocalizedString(@"SETTING_DATESTAMP", @"");
            break;
        case SettingDetailTypeVideoQuality:
            title = NSLocalizedString(@"SetVideoQuality", @"");
            break;
        case SettingDetailTypeTimelapseInterval:
            title = NSLocalizedString(@"SETTING_CAP_TIMESCAPE_INTERVAL", @"");
            break;
            
        case SetttngDetailTypeTimelapseDuration:
            title = NSLocalizedString(@"SETTING_CAP_TIMESCAPE_LIMIT", @"");
            break;
            
        case SettingDetailTypeUpsideDown:
            title = NSLocalizedString(@"SETTING_UPSIDE_DOWN", @"");
            break;
            
        case SettingDetailTypeSlowMotion:
            title = NSLocalizedString(@"SETTING_SLOW_MOTION", nil);
            break;
            
        case SettingDetailTypeImageSize:
            title = NSLocalizedString(@"SetPhotoResolution", @"");
            break;
            
        case SettingDetailTypeVideoSize:
            title = NSLocalizedString(@"ALERT_TITLE_SET_VIDEO_RESOLUTION", @"");
            break;
            
        case SettingDetailTypeCaptureDelay:
            title = NSLocalizedString(@"ALERT_TITLE_SET_SELF_TIMER", @"");
            break;
            
        case SettingDetailTypeLiveSize:
            title = NSLocalizedString(@"LIVE_RESOLUTION", @"");
            break;
            
        case SettingDetailTypeScreenSaver:
            title = NSLocalizedString(@"SetScreenSaver", @"");
            break;
            
        case SettingDetailTypeAutoPowerOff:
            title = NSLocalizedString(@"SetAutoPowerOff", @"");
            break;
            
        case SettingDetailTypeExposureCompensation:
            title = NSLocalizedString(@"SetExposureCompensation", @"");
            break;
            
        case SettingDetailTypeVideoFileLength:
            title = NSLocalizedString(@"SetVideoFileLength", @"");
            break;
            
        case SettingDetailTypeFastMotionMovie:
            title = NSLocalizedString(@"SetFastMotionMovie", @"");
            break;
        case SettingDetailTypeResetAll:
            title = NSLocalizedString(@"SetResetAll", @"");
            break;
        case SettingDetailTypeLanguage:
            title = NSLocalizedString(@"SetLanguage", @"");
            break;
        case SettingDetailTypeTimeZone:
            title = NSLocalizedString(@"SetTimeZone", @"");
            break;
        case SettingDetailTypeSDFormat:
            title = NSLocalizedString(@"SetSDFormat", @"");
            break;
        case SettingDetailTypePhotoExposureCompensation:
            title = NSLocalizedString(@"SetExposureCompensation", @"");
            break;
        case SettingDetailTypeGSensor:
            title = NSLocalizedString(@"SetGSensor", @"");
            break;
        case SettingDetailTypeSpeedUnit:
            title = NSLocalizedString(@"SetSpeedUnit", @"");
            break;
        case SettingDetailTypeLicensePlateStamp:
            title = NSLocalizedString(@"SetLicensePlateStamp", @"");
            break;
        case SettingDetailTypeDeviceSounds:
        case SettingDetailTypeNvtDeviceSounds:
            title = NSLocalizedString(@"SetDeviceSounds", @"");
            break;
        default:
            break;
    }*/
    //[self.navigationItem setTitle:title];
    //self.titleText.text = title;
    if(curSettingDetailType == SettingDetailTypeCountry)
    {
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            CurCountryValue = [[self.NVTGetHttpValueDict objectForKey:@"3110"] intValue];
            if(curSettingDetailItem == 0)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""];
                MinItem = 0;
                curSettingDetailItem = CurCountryValue;
                str1 = [delegate getStringForKey:@"SetCountry_UnitedStateEST" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_UnitedStateCST" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_UnitedStateMST" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_UnitedStatePST" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_UnitedStateAKST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_UnitedStateHST" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,nil];
            }
            else if(curSettingDetailItem == 1)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_Canada" withTable:@""];
                curSettingDetailItem = CurCountryValue;
                MinItem = 6;
                str1 = [delegate getStringForKey:@"SetCountry_CanadaNST" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_CanadaAST" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_CanadaEST" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_CanadaCST" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_CanadaMST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_CanadaPST" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,nil];
            }
            else if(curSettingDetailItem == 2)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_Russia" withTable:@""];
                curSettingDetailItem = CurCountryValue;
                MinItem = 12;
                str1 = [delegate getStringForKey:@"SetCountry_RussiaKALT" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_RussiaMSK" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_RussiaSAMT" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_RussiaYEKT" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_RussiaOMST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_RussiaKRAT" withTable:@""];
                str7 = [delegate getStringForKey:@"SetCountry_RussiaIRKT" withTable:@""];
                str8 = [delegate getStringForKey:@"SetCountry_RussiaYAKT" withTable:@""];
                str9 = [delegate getStringForKey:@"SetCountry_RussiaVLAT" withTable:@""];
                str10 = [delegate getStringForKey:@"SetCountry_RussiaMAGT" withTable:@""];
                str11 = [delegate getStringForKey:@"SetCountry_RussiaPETT" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11,nil];
            }
        }
        else
        {
            if(curSettingDetailItem == 0)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""];
                str1 = [delegate getStringForKey:@"SetCountry_UnitedStateEST" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_UnitedStateCST" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_UnitedStateMST" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_UnitedStatePST" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_UnitedStateAKST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_UnitedStateHST" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,nil];
            }
            else if(curSettingDetailItem == 1)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_Canada" withTable:@""];
                str1 = [delegate getStringForKey:@"SetCountry_CanadaNST" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_CanadaAST" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_CanadaEST" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_CanadaCST" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_CanadaMST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_CanadaPST" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,nil];
            }
            else if(curSettingDetailItem == 2)
            {
                self.titleText.text = [delegate getStringForKey:@"SetCountry_Russia" withTable:@""];
                str1 = [delegate getStringForKey:@"SetCountry_RussiaKALT" withTable:@""];
                str2 = [delegate getStringForKey:@"SetCountry_RussiaMSK" withTable:@""];
                str3 = [delegate getStringForKey:@"SetCountry_RussiaSAMT" withTable:@""];
                str4 = [delegate getStringForKey:@"SetCountry_RussiaYEKT" withTable:@""];
                str5 = [delegate getStringForKey:@"SetCountry_RussiaOMST" withTable:@""];
                str6 = [delegate getStringForKey:@"SetCountry_RussiaKRAT" withTable:@""];
                str7 = [delegate getStringForKey:@"SetCountry_RussiaIRKT" withTable:@""];
                str8 = [delegate getStringForKey:@"SetCountry_RussiaYAKT" withTable:@""];
                str9 = [delegate getStringForKey:@"SetCountry_RussiaVLAT" withTable:@""];
                str10 = [delegate getStringForKey:@"SetCountry_RussiaMAGT" withTable:@""];
                str11 = [delegate getStringForKey:@"SetCountry_RussiaPETT" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,str3,str4,str5,str6,str7,str8,str9,str10,str11,nil];
            }
        }
        //[subMenuTable setValue:@"string" forKey:@"key1"];
        
    }
    else if(curSettingDetailType == SettingDetailTypeDeviceSounds)
    {
        printf("curSettingDetailItem = %ld\n",(long)curSettingDetailItem);
        if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
           [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
           [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
           [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
           [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
           [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
        {
            if(curSettingDetailItem == 0)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"3115"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingBeep;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_BeepOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_BeepOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 1)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"2007"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAudioRec;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 2)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Announcements" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"3116"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAnnouncements;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
        }
        else if([SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
        {
            if(curSettingDetailItem == 0)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"3115"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingBeep;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_BeepOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_BeepOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 1)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"2007"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAudioRec;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 2)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Announcements" withTable:@""];
                DeviceValue = [[self.NVTGetHttpValueDict objectForKey:@"3116"] intValue];
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAnnouncements;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
        }
        else if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
        {
            if(curSettingDetailItem == 0)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
                DeviceValue = [[SDK instance] retrieveCurrentBeepSound]-1;
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingBeep;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_BeepOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_BeepOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 1)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
                DeviceValue = [[SDK instance] retrieveCurrentAudioRec]-1;
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAudioRec;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AudioRecOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
            else if(curSettingDetailItem == 2)
            {
                self.titleText.text = [delegate getStringForKey:@"SetDeviceSounds_Announcements" withTable:@""];
                DeviceValue = [[SDK instance] retrieveCurrentAnnouncements]-1;
                curSettingDetailItem = DeviceValue;
                curSelectedMenu = SettingAnnouncements;
                str1 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOn" withTable:@""];
                str2 = [delegate getStringForKey:@"SetDeviceSounds_AnnouncementsOff" withTable:@""];
                self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
            }
        }
        self.TextCellContent = [NSArray arrayWithObjects:str1,str2,nil];
    }

    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (message) {
        [self.progressHUD show:YES];
        self.progressHUD.labelText = message;
        self.progressHUD.mode = MBProgressHUDModeText;
        [self.progressHUD hide:YES afterDelay:time];
    } else {
        [self.progressHUD hide:YES];
    }
}
- (IBAction)BackAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data delegate
- (void)tableView               :(UITableView *)tableView
        didSelectRowAtIndexPath :(NSIndexPath *)indexPath
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    uint value = 0;
    switch (curSettingDetailType) {
        case SettingDetailTypeCountry:
            if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
            {
                value = (uint)(MinItem+indexPath.row);
                NSString *SendValue = [NSString stringWithFormat:@"%ld",(long)value];
                [self NVTSendHttpCmd:@"3110" Par2:SendValue];
            }
            else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
            {
                if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                   [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                   [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
                {
                    
                    if(curSettingDetailItem == 0)
                        curSettingDetailItem = 1;
                    else if(curSettingDetailItem == 1)
                        curSettingDetailItem = 7;
                    else if(curSettingDetailItem == 2)
                        curSettingDetailItem = 13;
                    [_ctrl.propCtrl changeSubCountry:indexPath.row+curSettingDetailItem];
                }
            }
            break;
        case SettingDetailTypeDeviceSounds:
            if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W)
            {
                
                value =  (uint)(indexPath.row);
                NSString *SendValue = [NSString stringWithFormat:@"%ld",(long)value];
                if(curSelectedMenu == SettingBeep)
                {
                    [self NVTSendHttpCmd:@"3115" Par2:SendValue];
                }
                else if(curSelectedMenu == SettingAudioRec)
                {
                    [self NVTSendHttpCmd:@"2007" Par2:SendValue];
                }
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
            {
                
                value =  (uint)(indexPath.row);
                NSString *SendValue = [NSString stringWithFormat:@"%ld",(long)value];
                if(curSelectedMenu == SettingAudioRec)
                {
                    [self NVTSendHttpCmd:@"2007" Par2:SendValue];
                }
                else if(curSelectedMenu == SettingAnnouncements)
                {
                    [self NVTSendHttpCmd:@"3116" Par2:SendValue];
                }
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                    [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
            {
                
                value =  (uint)(indexPath.row);
                NSString *SendValue = [NSString stringWithFormat:@"%ld",(long)value];
                if(curSelectedMenu == SettingBeep)
                {
                    [self NVTSendHttpCmd:@"3115" Par2:SendValue];
                }
                else if(curSelectedMenu == SettingAudioRec)
                {
                    [self NVTSendHttpCmd:@"2007" Par2:SendValue];
                }
                else if(curSelectedMenu == SettingAnnouncements)
                {
                    [self NVTSendHttpCmd:@"3116" Par2:SendValue];
                }
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                    [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                    [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
            {
                [_ctrl.propCtrl changeDevieceSounds:curSelectedMenu ClickPosition:indexPath.row];
            }
            break;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger) tableView             :(UITableView *)tableView
              numberOfRowsInSection :(NSInteger)section
{
    return [self.TextCellContent count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingSubDetailMenu *cell = [tableView dequeueReusableCellWithIdentifier:@"SubDetailMenuCell" forIndexPath:indexPath];
    
    /*SettingSubMenu *cell = [tableView dequeueReusableCellWithIdentifier:@"SubMenuCell" forIndexPath:indexPath];*/
    
    //使用預設風格
    /*static NSString *CellIdentifier = @"SubDetailMenuCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }*/
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:17];
   /* UIFont *newFont = [UIFont fontWithName:@"Arial" size:13.0];
    
    cell.textLabel.font = newFont;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;*/
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        //[subMenuTable setValue:@"string" forKey:@"key1"];
        if(curSettingDetailType == SettingDetailTypeCountry ||
           curSettingDetailType == SettingDetailTypeDeviceSounds)
        {
            NSLog(@"curSettingDetailItem = %ld",(long)curSettingDetailItem);
            if((curSettingDetailItem - MinItem) == indexPath.row)
            {
                cell.textLabel.textColor = [UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1];
            }
            else
            {
                cell.textLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
            }
        }
        cell.textLabel.text = [self.TextCellContent objectAtIndex:indexPath.row];
    }
    else if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
            [SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
            [SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
    {
        if(curSettingDetailType == SettingDetailTypeCountry)
        {
              uint CurCountry = [[SDK instance] retrieveCurrentCountry:[SSIDSreial MatchSSIDReturn:self.SSID]];
             uint SubCurCountry = [[SDK instance] retrieveSubCurrentCountry];
             if(SubCurCountry >= 1 && SubCurCountry <=6)
             SubCurCountry = SubCurCountry-1;
             else if(SubCurCountry >= 7 && SubCurCountry <=12)
             SubCurCountry = SubCurCountry-7;
             else if(SubCurCountry >= 13 && SubCurCountry <=23)
             SubCurCountry = SubCurCountry-13;
             if(indexPath.row == (SubCurCountry) && ((CurCountry-1) == curSettingDetailItem))
             {
                cell.textLabel.textColor = [UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1];
             }
             else
             {
                 cell.textLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
             }
            /*if((curSettingDetailItem - MinItem) == indexPath.row)
            {
                cell.textLabel.textColor = [UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1];
            }
            else
            {
                cell.textLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
            }*/
        }
        else if(curSettingDetailType == SettingDetailTypeDeviceSounds)
        {
            if((curSettingDetailItem - MinItem) == indexPath.row)
            {
                cell.textLabel.textColor = [UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1];
            }
            else
            {
                cell.textLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
            }
            /*if(indexPath.row == (DeviceValue-1))
            {
                cell.textLabel.textColor = [UIColor colorWithRed:0/255.0 green:102/255.0 blue:255/255.0 alpha:1];
            }*/
        }
        cell.textLabel.text = [self.TextCellContent objectAtIndex:indexPath.row];
    }
    else
    {
        cell.textLabel.text = @"";
    }
    // Configure the cell...
    
    return cell;
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
