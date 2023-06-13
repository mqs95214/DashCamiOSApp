//
//  TestViewController.m
//  ScrollViewDemo
//
//  Created by gonghonglou on 2018/2/11.
//  Copyright © 2018年 Troy. All rights reserved.
//

#import "TestViewController.h"
#import "WifiCamAlertTable.h"

@interface TestViewController () <AppDelegateProtocol,UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

//@property (nonatomic, strong) MyScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UITableView *leftTableView;

@property (nonatomic, strong) UITableView *centerTableView;

@property (nonatomic, strong) UITableView *rightTableView;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *NavigationTitle;
@property (weak, nonatomic) IBOutlet UIView *BottonBar;
@property (weak, nonatomic) IBOutlet UIButton *NavigationTitleText;
@property (weak, nonatomic) IBOutlet UIButton *VideoSettingButton;
@property (weak, nonatomic) IBOutlet UIButton *PhotoSettingButton;
@property (weak, nonatomic) IBOutlet UIButton *SetupSettingButton;


@property(nonatomic) UISwitch *switchViewer;

@property(nonatomic) NSString *SSID;
@property(nonatomic) MBProgressHUD *progressHUD;

@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;
@property(nonatomic) NSMutableArray *VideoMenuTable;
@property(nonatomic) NSMutableArray *PhotoMenuTable;
@property(nonatomic) NSMutableArray *SetupMenuTable;

@property(nonatomic) NSMutableArray *SecondMenuTable;

@property(nonatomic) NSMutableArray *VideoMenuSettingTable;
@property(nonatomic) NSMutableArray *PhotoMenuSettingTable;
@property(nonatomic) NSMutableArray *SetupMenuSettingTable;

@property(nonatomic) NSMutableArray *SecondMenuSettingTable;

@property(nonatomic) NSInteger curSettingDetailType;
@property(nonatomic) NSInteger curSettingDetailItem;

@property (nonatomic, strong) NSMutableDictionary *NVTSettingValueDict;

@end

@implementation TestViewController
{
    SSID_SerialCheck *SSIDSreial;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //set title
#if 0
    self.NavigationTitleText.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.NavigationTitleText.imageEdgeInsets = UIEdgeInsetsMake(8, 0, 8, 0);
    self.NavigationTitleText.titleEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    
    [self layoutUI];
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTSettingValueDict = [[NSMutableDictionary alloc] init];
    }
    else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.camera = _wifiCam.camera;
        self.ctrl = _wifiCam.controler;
        [_ctrl.propCtrl updateAllProperty:_camera];
    }
    _VideoMenuTable = [[NSMutableArray alloc] init];
    _PhotoMenuTable = [[NSMutableArray alloc] init];
    _SetupMenuTable = [[NSMutableArray alloc] init];
    _SecondMenuTable = [[NSMutableArray alloc] init];
    _VideoMenuSettingTable = [[NSMutableArray alloc] init];
    _PhotoMenuSettingTable = [[NSMutableArray alloc] init];
    _SetupMenuSettingTable = [[NSMutableArray alloc] init];
    _SecondMenuSettingTable = [[NSMutableArray alloc] init];
    
    [_VideoMenuTable insertObject:_VideoMenuSettingTable
                         atIndex:SettingSectionTypeSetting];
    [_PhotoMenuTable insertObject:_PhotoMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    [_SetupMenuTable insertObject:_SetupMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    
    [_SecondMenuTable insertObject:_SecondMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.delegate = self;
    
#endif
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
#if 0
    [self showProgressHUDWithMessage:NSLocalizedString(@"LOAD_SETTING_DATA", nil)];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
        {
            if([SSIDSreial MatchSSIDReturn:self.SSID] == D200GW||
               [SSIDSreial MatchSSIDReturn:self.SSID] == D200 ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == BD200GW ||
               [SSIDSreial MatchSSIDReturn:self.SSID] == BD200)
            {
                /*[self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];*/
                //[self D200GWNvtfillMainMenuSettingTable:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
                    [SSIDSreial MatchSSIDReturn:self.SSID] == C1)
            {
                /*[self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];
                [self C1GWNvtfillMainMenuSettingTable:[SSIDSreial MatchSSIDReturn:self.SSID]];*/
            }
        }
        else if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
        {
            if([SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2)
            {
                //[self MenuSettingTableU2:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([SSIDSreial MatchSSIDReturn:self.SSID] == DUO_HD)
            {
                [self MenuSettingTableDUOHD:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.VideoSettingButton.selected = 1;
            [self.leftTableView reloadData];
            [self.centerTableView reloadData];
            [self.rightTableView reloadData];
            [self hideProgressHUD:YES];
        });
    });
#endif
}
#if 0
// 页面布局
- (void)layoutUI {
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.view.frame.size.height;
    //CGFloat NavigationWidth = self.NavigationTitle.frame.size.width;
    CGFloat NavigationHeight = self.NavigationTitle.frame.size.height;
   // CGFloat BottomBarWidth = self.BottonBar.frame.size.width;
    CGFloat BottomBarHeight = self.BottonBar.frame.size.height;
    // scroll view
    /*self.scrollView = [[MyScrollView alloc] initWithFrame:self.view.frame];*/
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.contentSize = CGSizeMake(viewWidth * 3, 0);
    //[self.view addSubview:self.scrollView];
    
    // left table view
    self.leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight-NavigationHeight-BottomBarHeight) style:UITableViewStylePlain];
    self.leftTableView.backgroundColor = [UIColor blackColor];
    self.leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.leftTableView.bounces = NO;
    [self.scrollView addSubview:self.leftTableView];
    
    // right table view
    self.centerTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewWidth, 0, viewWidth, viewHeight-NavigationHeight-BottomBarHeight) style:UITableViewStylePlain];
    self.centerTableView.backgroundColor = [UIColor blackColor];
    self.centerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.centerTableView.bounces = NO;
    [self.scrollView addSubview:self.centerTableView];
    
    
    self.rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(viewWidth*2, 0, viewWidth, viewHeight-NavigationHeight-BottomBarHeight) style:UITableViewStylePlain];
    self.rightTableView.backgroundColor = [UIColor blackColor];
    self.rightTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.rightTableView.bounces = NO;
    [self.scrollView addSubview:self.rightTableView];
    
    self.scrollView.delegate = self;
    self.leftTableView.delegate = self;
    self.leftTableView.dataSource = self;
    //self.leftTableView.rowHeight = 60;
    //self.leftTableView.tableFooterView = [UIView new];
    self.centerTableView.delegate = self;
    self.centerTableView.dataSource = self;
    
    self.rightTableView.delegate = self;
    self.rightTableView.dataSource = self;

    // pagControl
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    self.pageControl.numberOfPages = 3;
    self.pageControl.enabled = NO;

    
    self.NavigationTitleText.titleLabel.text = NSLocalizedString(@"VideoMenu", @"");
    
    [self.VideoSettingButton setImage:[UIImage imageNamed:@"App_video"] forState:UIControlStateNormal];
    
    [self.VideoSettingButton setImage:[UIImage imageNamed:@"App_video_select"] forState:UIControlStateSelected];
    
    [self.PhotoSettingButton setImage:[UIImage imageNamed:@"App_camera"] forState:UIControlStateNormal];
    
    [self.PhotoSettingButton setImage:[UIImage imageNamed:@"App_camera_select"] forState:UIControlStateSelected];
    
    [self.SetupSettingButton setImage:[UIImage imageNamed:@"App_setting_icon"] forState:UIControlStateNormal];
    
    [self.SetupSettingButton setImage:[UIImage imageNamed:@"App_setting_select"] forState:UIControlStateSelected];
}

- (void)MenuSettingTableDUOHD:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    if(self.VideoSettingButton.selected == 0 && self.PhotoSettingButton.selected == 0 && self.SetupSettingButton.selected == 0)
    {
        [self DUOHDVideoSettingDataCell:ModelName];
        [self DUOHDPhotoSettingDataCell:ModelName];
        [self DUOHDSetupSettingDataCell:ModelName];
    }
    else
    {
        if(self.VideoSettingButton.selected)
        {
            [self DUOHDVideoSettingDataCell:ModelName];
        }
        else if(self.PhotoSettingButton.selected)
        {
            [self DUOHDPhotoSettingDataCell:ModelName];
        }
        else if(self.SetupSettingButton.selected)
        {
            [self DUOHDSetupSettingDataCell:ModelName];
        }
    }

    /*else
    {
        if(self.VideoSettingButton.selected)
        {
            [self DUOHDVideoSettingDataCell:ModelName];
        }
        else if(self.PhotoSettingButton.selected)
        {
            [self DUOHDPhotoSettingDataCell:ModelName];
        }
        else if(self.SetupSettingButton.selected)
        {
            [self DUOHDSetupSettingDataCell:ModelName];
        }
    }*/
   /* if(buttonSettingIndex == 0)
    {
        [self DUOHDVideoSettingDataCell:ModelName];
    }
    else if(buttonSettingIndex == 1)
    {
        [self DUOHDPhotoSettingDataCell:ModelName];
    }
    else if(buttonSettingIndex == 2)
    {
        [self DUOHDSetupSettingDataCell:ModelName];
    }*/
}

- (void)DUOHDVideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetAudioRec", @""),
              @(SettingTableDetailType):@(SettingDetailTypeAudioRecording)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillLicensePlateStampTable];
    if(table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetParkingModeSensor", @""),
              @(SettingTableDetailType):@(SettingDetailTypeParkingModeSensor)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetTimeAndDateStamp", @""),
              @(SettingTableDetailType):@(SettingDetailTypeTimeAndDateStamp)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetGPS", @""),
              @(SettingTableDetailType):@(SettingDetailTypeGPS)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetModelNumberStamp", @""),
              @(SettingTableDetailType):@(SettingDetailTypeModelNumberStamp)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetSpeedStamp", @""),
              @(SettingTableDetailType):@(SettingDetailTypeSpeedStamp)};
    
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillGSensorTable:ModelName];
    if (table) {
        [_VideoMenuSettingTable addObject:table];
    }
    
}
- (void)DUOHDPhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillPhotoExposureCompensationTable:ModelName];
    if (table) {
        [_PhotoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetTimeAndDateStamp", @""),
              @(SettingTableDetailType):@(SettingDetailTypePhotoTimeAndDateStamp)};
    
    if (table) {
        [_PhotoMenuSettingTable addObject:table];
    }
}

- (void)DUOHDSetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if(table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    /*table = [self fillDateTimeTable];
    if(table) {
        [_SetupMenuSettingTable addObject:table];
    }*/
    
    table = [self fillLanguageTable:ModelName];
    if(table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillCountryTable:ModelName];
    if(table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetSpeedDisplay", @""),
              @(SettingTableDetailType):@(SettingDetailTypeSpeedDisplay)};
    
    if (table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetScreenSaver", @""),
              @(SettingTableDetailType):@(SettingDetailTypeScreenSaver)};
    
    if (table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetDeviceSounds", @""),
              @(SettingTableDetailType):@(SettingDetailTypeDeviceSounds)};
    
    if (table) {
        [_SetupMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetDeviceSounds_Announcements", @""),
              @(SettingTableDetailType):@(SettingDetailTypeAnnouncement)};
    
    if (table) {
        [_SetupMenuSettingTable addObject:table];
    }
    

    table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetKeepUserSetting", @""),
              @(SettingTableDetailType):@(SettingDetailTypeKeepUserSetting)};
    
    if (table) {
        [_SetupMenuSettingTable addObject:table];
    }
}

- (NSDictionary *)fillCustomVideoSizeTable:(int)ModelName
{
    NSDictionary *table = nil;
    WifiCamAlertTable *vsArray;
    
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curVideoSize;
        curVideoSize = [[self.NVTSettingValueDict objectForKey:@"2002"] intValue];;
        vsArray = [self NvtprepareDataForVideoSize:curVideoSize];
        //vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength];
        if (vsArray.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"ALERT_TITLE_SET_VIDEO_RESOLUTION", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcVideoSize:curVideoSize],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoSize),
                      @(SettingTableDetailData):vsArray.array,
                      @(SettingTableDetailLastItem):@(vsArray.lastIndex)};
        }
    }
    else
    {
        uint curVideoSize = [[SDK instance] retrieveCurrentCustomVideoSize:ModelName];
        
        WifiCamAlertTable *vs = [_ctrl.propCtrl prepareDataForCustomVideoSize:curVideoSize Model:ModelName];
        if (vs.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"ALERT_TITLE_SET_VIDEO_RESOLUTION", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcCustomVideoSizeValue:curVideoSize Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeCustomVideoSize),
                      @(SettingTableDetailData):vs.array,
                      @(SettingTableDetailLastItem):@(vs.lastIndex)};
        }
    }
    
    
    return table;
}
- (NSDictionary *)fillExposureCompensationTable:(int)ModelName
{
    NSDictionary *table = nil;
    WifiCamAlertTable *ec;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curExposureCompensation = [[self.NVTSettingValueDict objectForKey:@"2005"] intValue];
        ec = [self NvtprepareDataForExposureCompensation:curExposureCompensation];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetExposureCompensation", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcExposureCompensationValue:curExposureCompensation],
                      @(SettingTableDetailType):@(SettingDetailTypeExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    else
    {
        uint curExposureCompensation = [[SDK instance] retrieveCurrentExposureCompensation:ModelName];
        ec = [_ctrl.propCtrl prepareDataForExposureCompensation:curExposureCompensation Model:ModelName];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetExposureCompensation", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcExposureCompensationValue:curExposureCompensation Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    
    
    return table;
}

- (NSDictionary *)fillLicensePlateStampTable
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *curLicensePlateStamp = [self.NVTSettingValueDict objectForKey:@"3118"];
        WifiCamAlertTable *ssArray = [self NvtprepareDataForLicensePlateStamp:curLicensePlateStamp];
        if (ssArray.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLicensePlateStamp", @""),
                      @(SettingTableDetailTextLabel):curLicensePlateStamp,
                      @(SettingTableDetailType):@(SettingDetailTypeLicensePlateStamp),
                      @(SettingTableDetailData):ssArray.array,
                      @(SettingTableDetailLastItem):@(ssArray.lastIndex)};
        }
    }
    else
    {
        NSString *curLicensePlateStamp = [[SDK instance] retrieveCurrentLicensePlateStamp];
        
        WifiCamAlertTable *ssArray = [_ctrl.propCtrl prepareDataForLicensePlateStamp:curLicensePlateStamp];
        
        if (ssArray.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLicensePlateStamp", @""),
                      @(SettingTableDetailTextLabel):curLicensePlateStamp,
                      @(SettingTableDetailType):@(SettingDetailTypeLicensePlateStamp),
                      @(SettingTableDetailData):ssArray.array,
                      @(SettingTableDetailLastItem):@(ssArray.lastIndex)};
        }
    }
    return table;
}

- (NSDictionary *)fillVideoFileLengthTable:(int)ModelName
{
    NSDictionary *table = nil;
    uint curVideoFileLength;
    WifiCamAlertTable *vfl;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        curVideoFileLength = [[self.NVTSettingValueDict objectForKey:@"2003"] intValue];
        vfl = [self NvtprepareDataForVideoFileLength:curVideoFileLength];
        //vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength];
        if (vfl.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetVideoFileLength", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcVideoFileLength:curVideoFileLength],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoFileLength),
                      @(SettingTableDetailData):vfl.array,
                      @(SettingTableDetailLastItem):@(vfl.lastIndex)};
        }
    }
    else
    {
        curVideoFileLength = [[SDK instance] retrieveCurrentVideoFileLength:ModelName];
        vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength ModelName:ModelName];
        if (vfl.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetVideoFileLength", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcVideoFileLength:curVideoFileLength Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoFileLength),
                      @(SettingTableDetailData):vfl.array,
                      @(SettingTableDetailLastItem):@(vfl.lastIndex)};
        }
        
    }
    
    
    return table;
}

- (NSDictionary *)fillGSensorTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curGSensor = [[self.NVTSettingValueDict objectForKey:@"2011"] intValue];
        WifiCamAlertTable *gs = [self NvtprepareDataForGSensor:curGSensor];
        if (gs.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetGSensor", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcGSensorValue:curGSensor],
                      @(SettingTableDetailType):@(SettingDetailTypeGSensor),
                      @(SettingTableDetailData):gs.array,
                      @(SettingTableDetailLastItem):@(gs.lastIndex)};
        }
    }
    else
    {
        uint curGSensor = [[SDK instance] retrieveCurrentGSensor:ModelName];
        WifiCamAlertTable *gs = [_ctrl.propCtrl prepareDataForGSensor:curGSensor Model:ModelName];
        if (gs.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetGSensor", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcGSensorValue:curGSensor Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeGSensor),
                      @(SettingTableDetailData):gs.array,
                      @(SettingTableDetailLastItem):@(gs.lastIndex)};
        }
    }
    
    return table;
}
- (NSDictionary *)fillLanguageTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curLanguage = [[self.NVTSettingValueDict objectForKey:@"3008"] intValue];
        WifiCamAlertTable *language = [self NvtprepareDataForLanguage:curLanguage];
        if (language.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLanguage", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcLanguage:curLanguage],
                      @(SettingTableDetailType):@(SettingDetailTypeLanguage),
                      @(SettingTableDetailData):language.array,
                      @(SettingTableDetailLastItem):@(language.lastIndex)};
        }
    }
    else
    {
        uint curLanguage = [[SDK instance] retrieveCurrentLanguage:ModelName];
        WifiCamAlertTable *language = [_ctrl.propCtrl prepareDataForLanguage:curLanguage  Model:ModelName];
        
        if (language.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLanguage", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcLanguage:curLanguage Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeLanguage),
                      @(SettingTableDetailData):language.array,
                      @(SettingTableDetailLastItem):@(language.lastIndex)};
        }
    }
    return table;
}
- (NSDictionary *)fillCountryTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint titleCountry;
        uint curCountry = [[self.NVTSettingValueDict objectForKey:@"3110"] intValue];
        if(curCountry >= 0 && curCountry <=5)
            titleCountry = 0;
        else if(curCountry > 5 && curCountry <=11)
            titleCountry = 1;
        else if(curCountry == 12)
            titleCountry = 2;
        else if(curCountry > 12 && curCountry <=16)
            titleCountry = 3;
        else if(curCountry == 17)
            titleCountry = 4;
        else if(curCountry == 18)
            titleCountry = 5;
        else if(curCountry == 19)
            titleCountry = 6;
        else if(curCountry > 19 && curCountry <=30)
            titleCountry = 7;
        else
            titleCountry = curCountry-23;
        
        WifiCamAlertTable *country = [self NvtprepareDataForCountry:titleCountry];
        if (country.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetCountry", @""),
                      @(SettingTableDetailTextLabel):[self NvtDetailcalcCountry:curCountry],
                      @(SettingTableDetailType):@(SettingDetailTypeCountry),
                      @(SettingTableDetailData):country.array,
                      @(SettingTableDetailLastItem):@(country.lastIndex)};
        }
    }
    else
    {
        uint curCountry = [[SDK instance] retrieveCurrentCountry:ModelName];
        //uint SubCurCountry = [[SDK instance] retrieveSubCurrentCountry];
        WifiCamAlertTable *country;
        country = [_ctrl.propCtrl prepareDataForCountry:curCountry Model:ModelName];
        if(country.array) {
            
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetCountry", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcCountry:curCountry Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeCountry),
                      @(SettingTableDetailData):country.array,
                      @(SettingTableDetailLastItem):@(country.lastIndex)};
        }
        
        
        
        /*if(((curCountry-1) != United_State) && ((curCountry-1) != Canada) && ((curCountry-1) != Mexico)&& ((curCountry-1) != Russia))
        {
            country = [_ctrl.propCtrl prepareDataForCountry:curCountry];
            if (country.array) {
                table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetCountry", @""),
                          @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcCountry:curCountry],
                          @(SettingTableDetailType):@(SettingDetailTypeCountry),
                          @(SettingTableDetailData):country.array,
                          @(SettingTableDetailLastItem):@(country.lastIndex)};
            }
        }
        else
        {
            country = [_ctrl.propCtrl prepareDataForCountry:curCountry];
            if (country.array) {
                table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetCountry", @""),
                          @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcSubCountry:SubCurCountry],
                          @(SettingTableDetailType):@(SettingDetailTypeCountry),
                          @(SettingTableDetailData):country.array,
                          @(SettingTableDetailLastItem):@(country.lastIndex)};
            }
        }*/
    }
    
    
    return table;
}
- (NSDictionary *)fillPhotoExposureCompensationTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curExposureCompensation = [[self.NVTSettingValueDict objectForKey:@"2005"] intValue];
        WifiCamAlertTable *ec = [self NvtprepareDataForPhotoExposureCompensation:curExposureCompensation];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetExposureCompensation", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcExposureCompensationValue:curExposureCompensation],
                      @(SettingTableDetailType):@(SettingDetailTypePhotoExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    else
    {
        uint curExposureCompensation = [[SDK instance] retrieveCurrentPhotoExposureCompensation:ModelName];
        WifiCamAlertTable *ec = [_ctrl.propCtrl prepareDataForPhotoExposureCompensation:curExposureCompensation Model:ModelName];
        
        if (ec.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetExposureCompensation", @""),
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcExposureCompensationValue:curExposureCompensation Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypePhotoExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    
    return table;
}

- (NSDictionary *)fillSDFormatTable:(int)ModelName
{
    NSDictionary *table = nil;
    //uint curSpeedUnit = [[SDK instance] retrieveCurrentSpeedUnit];
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        WifiCamAlertTable *sdformat = [self NvtprepareDataForSDFormat];
        if (sdformat.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetSDFormat", @""),
                      //@(SettingTableDetailTextLabel):[_ctrl.propCtrl calcSpeedUnitValue:curSpeedUnit],
                      @(SettingTableDetailType):@(SettingDetailTypeSDFormat),
                      @(SettingTableDetailData):sdformat.array,
                      @(SettingTableDetailLastItem):@(sdformat.lastIndex)};
        }
    }
    else
    {
        WifiCamAlertTable *sdformat = [_ctrl.propCtrl prepareDataForSDFormat:ModelName];
        
        if (sdformat.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetSDFormat", @""),
                      //@(SettingTableDetailTextLabel):[_ctrl.propCtrl calcSpeedUnitValue:curSpeedUnit],
                      @(SettingTableDetailType):@(SettingDetailTypeSDFormat),
                      @(SettingTableDetailData):sdformat.array,
                      @(SettingTableDetailLastItem):@(sdformat.lastIndex)};
        }
    }
    return table;
}

- (NSDictionary *)fillDateTimeTable
{
    NSDictionary *table = nil;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *curDateTime = [self.NVTSettingValueDict objectForKey:@"3119"];
        WifiCamAlertTable *DateTime = [self NvtprepareDataForDateTime:curDateTime];
        if (DateTime.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetDateTime", @""),
                      @(SettingTableDetailTextLabel):curDateTime,
                      @(SettingTableDetailType):@(SettingDetailTypeDateTime),
                      @(SettingTableDetailData):DateTime.array,
                      @(SettingTableDetailLastItem):@(DateTime.lastIndex)};
        }
    }
    else
    {
        NSString *curDateTime = [[SDK instance] retrieveCurrentDateTime];
        WifiCamAlertTable *DateTime = [_ctrl.propCtrl prepareDataForDateTime:curDateTime];
        NSString *resultDateTime = [_ctrl.propCtrl calcLicenseDateTimeValue:curDateTime];
        if (DateTime.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetDateTime", @""),
                      @(SettingTableDetailTextLabel):resultDateTime,
                      @(SettingTableDetailType):@(SettingDetailTypeDateTime),
                      @(SettingTableDetailData):DateTime.array,
                      @(SettingTableDetailLastItem):@(DateTime.lastIndex)};
        }
    }
    return table;
}

-(WifiCamAlertTable *)NvtprepareDataForVideoFileLength:(uint)curVideoFileLength
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDVFLs = (vector<uint>)3;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curVideoFileLength: %d", curVideoFileLength);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
        s = [self NvtcalcVideoFileLength:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curVideoFileLength && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
-(WifiCamAlertTable *)NvtprepareDataForVideoSize:(uint)curVideoSize
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDVFLs = (vector<uint>)2;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curVideoSize: %d", curVideoSize);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
        s = [self NvtcalcVideoSize:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curVideoSize && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForExposureCompensation:(uint)curExposureCompensation
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDECs = (vector<uint>)5;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curExposureCompensation: %d", curExposureCompensation);
    for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
        s = [self NvtcalcExposureCompensationValue:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curExposureCompensation && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForGSensor:(uint)curGSensor
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    vector<uint> vDECs = (vector<uint>)4;
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curGSensor: %d", curGSensor);
    for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
        s = [self NvtcalcGSensorValue:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curGSensor && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForParkingModeSensor:(uint)curParkingModeSensor
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDECs = (vector<uint>)2;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curParkingModeSensor: %d", curParkingModeSensor);
    for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
        s = [self NvtcalcParkingModeSensorValue:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curParkingModeSensor && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForSpeedUnit:(uint)curSpeedUnit
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDECs = (vector<uint>)2;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
    int i = 0;
    NSString *s = nil;
    
    //printf("\nproperty int value vDECs: %d\n", *iit);
    AppLogInfo(AppLogTagAPP, @"curSpeedUnit: %d", curSpeedUnit);
    for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
        s = [self NvtcalcSpeedUnitValue:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curSpeedUnit && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForLicensePlateStamp:(NSString *)curLicensePlateStamp
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<string> vSTRs = (vector<string>)0;
    
    TAA.array = [[NSMutableArray alloc] init];
    int i = 0;
    NSString *s = nil;
    
    // AppLogInfo(AppLogTagAPP, @"LicensePlateStamp: %", curLicensePlateStamp);
    for (vector<string>::iterator it = vSTRs.begin(); it != vSTRs.end(); ++it, ++i) {
        s = [self NvtcalcLicensePlateStampValue:*it];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (it == (vSTRs.end()-1) && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForPhotoExposureCompensation:(uint)curExposureCompensation
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDECs = (vector<uint>)5;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curExposureCompensation: %d", curExposureCompensation);
    for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
        s = [self NvtcalcExposureCompensationValue:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curExposureCompensation && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForSDFormat
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    
    TAA.array = [[NSMutableArray alloc] init];
    NSString *s = nil;
    
    for(int i = 1 ; i <= 2 ; i++)
    {
        s = [self NvtcalcSDFormatValue:i];
        if (s) {
            [TAA.array addObject:s];
        }
        if(i == 2){
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForDateTime:(NSString *)curDateTime
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    NSString *str = [self.NVTSettingValueDict objectForKey:@"3119"];
    int strlen = (int)str.length;
    vector<string> vSTRs = (vector<string>)strlen;
    
    TAA.array = [[NSMutableArray alloc] init];
    int i = 0;
    NSString *s = nil;
    
    // AppLogInfo(AppLogTagAPP, @"LicensePlateStamp: %", curLicensePlateStamp);
    for (vector<string>::iterator it = vSTRs.begin(); it != vSTRs.end(); ++it, ++i) {
        s = [self NvtcalcLicenseDateTimeValue:*it];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (it == (vSTRs.end()-1) && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForTimeZone:(uint)curTimeZone
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDAPs = (vector<uint>)27;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curTimeZone: %d", curTimeZone);
    for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
        s = [self NvtcalcTimeZone:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curTimeZone && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
            printf("Timezon lastIndex = %lu",(unsigned long)TAA.lastIndex);
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForLanguage:(uint)curLanguage
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDAPs = (vector<uint>)3;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curLanguage: %d", curLanguage);
    for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
        s = [self NvtcalcLanguage:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curLanguage && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForCountry:(uint)curCountry
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDAPs =(vector<uint>)21;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curCountry: %d", curCountry);
    for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
        s = [self NvtcalcCountry:i];
        
        if (s) {
            
            [TAA.array addObject:s];
        }
        
        if (i == curCountry && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
        
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForScreenSaver:(uint)curScreenSaver
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDSSs = (vector<uint>)3;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDSSs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curScreenSaver: %d", curScreenSaver);
    for (vector<uint>::iterator it = vDSSs.begin(); it != vDSSs.end(); ++it, ++i) {
        s = [self NvtcalcScreenSaverTime:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curScreenSaver && !InvalidSelectedIndex) {
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForResetAll
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    
    TAA.array = [[NSMutableArray alloc] init];
    NSString *s = nil;
    
    for(int i = 0 ; i <= 1 ; i++)
    {
        s = [self NvtcalcResetAllValue:i];
        if (s) {
            [TAA.array addObject:s];
        }
        if(i == 1){
            TAA.lastIndex = i;
            InvalidSelectedIndex = YES;
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
- (WifiCamAlertTable *)NvtprepareDataForDeviceSounds
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    
    
    TAA.array = [[NSMutableArray alloc] init];
    int i = 0;
    NSString *s = nil;
    
    
    for (i = 0 ; i <= 1 ; i++) {
        s = [self NvtcalcDeviceSounds:i];
        
        if (s) {
            [TAA.array addObject:s];
        }
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}
- (NSString *)NvtcalcVideoFileLength:(uint)curVideoFileLength
{
    // NSString *Str;
    if(curVideoFileLength == 0)
    {
        //  Str = [NSString stringWithFormat:@"%d Minute", 1];
        return NSLocalizedString(@"SetSeamLess_1Minutes",@"");
    }
    else if(curVideoFileLength == 1)
    {
        return NSLocalizedString(@"SetSeamLess_3Minutes",@"");
    }
    else if(curVideoFileLength == 2)
    {
        return NSLocalizedString(@"SetSeamLess_5Minutes",@"");
    }
    else
    {
        return [NSString stringWithFormat:@"%d Minutes", curVideoFileLength];
    }
}
- (NSString *)NvtcalcVideoSize:(uint)curVideoSize
{
    if(curVideoSize == 0)
    {
        return [NSString stringWithFormat:@"1080P 30FPS"];
    }
    else if(curVideoSize == 1)
    {
        return [NSString stringWithFormat:@"720 60FPS"];
    }
    else
    {
        return [NSString stringWithFormat:@"%d Minutes", curVideoSize];
    }
}
- (NSString *)NvtcalcExposureCompensationValue:(uint)curExposureCompensation
{
    
    int rateThreshold = 0x40000000;
    float rate = 1.0;
    NSString *prefix = nil;
    
    // 最高位为1表示负值，为0表示正值
    /*if (curExposureCompensation & Threshold) {
     prefix = @"EV -";
     } else {
     prefix = @"EV ";
     }*/
    if (curExposureCompensation == 0) {
        prefix = @"+";
    } else if(curExposureCompensation == 1) {
        prefix = @"+";
    } else if(curExposureCompensation == 2) {
        prefix = @"";
    } else if(curExposureCompensation == 3) {
        prefix = @"-";
    } else if(curExposureCompensation == 4) {
        prefix = @"-";
    }
    
    // 第二位表示小数点向左移动的位数 1：移动一位 0：不移动
    if (rateThreshold & curExposureCompensation) {
        rate = 10.0;
    }
    
    int value = 0;
    if (curExposureCompensation == 0) {
        value = 2;
    } else if(curExposureCompensation == 1) {
        value = 1;
    } else if(curExposureCompensation == 2) {
        value = 0;
    } else if(curExposureCompensation == 3) {
        value = 1;
    } else if(curExposureCompensation == 4) {
        value = 2;
    }
    
    return [prefix stringByAppendingFormat:@"%.1f", value / rate];
}
- (NSString *)NvtcalcGSensorValue:(uint)curGSensor
{
    if(curGSensor == 0)
    {
        return NSLocalizedString(@"SetVideoGsensorHigh",@"");
    }
    else if(curGSensor == 1)
    {
        return NSLocalizedString(@"SetVideoGsensorMedium",@"");
    }
    else if(curGSensor == 2)
    {
        return NSLocalizedString(@"SetVideoGsensorLow",@"");
    }
    else if(curGSensor == 3)
    {
        return NSLocalizedString(@"SetSettingOFF",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcParkingModeSensorValue:(uint)curParkingModeSensor
{
    if(curParkingModeSensor == 0)
    {
        return [NSString stringWithFormat:@"On"];
    }
    else if(curParkingModeSensor == 1)
    {
        return [NSString stringWithFormat:@"OFF"];
    }
    else
    {
        return [NSString stringWithFormat:@"Nothing"];
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcSpeedUnitValue:(uint)curSpeedUnit
{
    if(curSpeedUnit == 0)
    {
        return [NSString stringWithFormat:@"MPH"];
    }
    else if(curSpeedUnit == 1)
    {
        return [NSString stringWithFormat:@"KMH"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcLicensePlateStampValue:(string)curLicensePlateStamp
{
    return [NSString stringWithFormat:@"%s",curLicensePlateStamp.c_str()];
}
- (NSString *)NvtcalcSDFormatValue:(uint)curFormat
{
    if(curFormat == 1)
    {
        return NSLocalizedString(@"SetFormatSDCard_OK", @"");
    }
    else if(curFormat == 2)
    {
        return NSLocalizedString(@"SetFormatSDCard_Cancel", @"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcLicenseDateTimeValue:(string)curDateTime
{
    return [NSString stringWithFormat:@"%s",curDateTime.c_str()];
}
- (NSString *)NvtcalcTimeZone:(uint)curTimeZone
{
    if(curTimeZone == 0) return [NSString stringWithFormat:@"-12"];
    else if(curTimeZone == 1) return [NSString stringWithFormat:@"-11"];
    else if(curTimeZone == 2) return [NSString stringWithFormat:@"-10"];
    else if(curTimeZone == 3) return [NSString stringWithFormat:@"-9"];
    else if(curTimeZone == 4) return [NSString stringWithFormat:@"-8"];
    else if(curTimeZone == 5) return [NSString stringWithFormat:@"-7"];
    else if(curTimeZone == 6) return [NSString stringWithFormat:@"-6"];
    else if(curTimeZone == 7) return [NSString stringWithFormat:@"-5"];
    else if(curTimeZone == 8) return [NSString stringWithFormat:@"-4"];
    else if(curTimeZone == 9) return [NSString stringWithFormat:@"-3.5"];
    else if(curTimeZone == 10) return [NSString stringWithFormat:@"-3"];
    else if(curTimeZone == 11) return [NSString stringWithFormat:@"-2.5"];
    else if(curTimeZone == 12) return [NSString stringWithFormat:@"-2"];
    else if(curTimeZone == 13) return [NSString stringWithFormat:@"-1"];
    else if(curTimeZone == 14) return [NSString stringWithFormat:@"GMT"];
    else if(curTimeZone == 15) return [NSString stringWithFormat:@"+1"];
    else if(curTimeZone == 16) return [NSString stringWithFormat:@"+2"];
    else if(curTimeZone == 17) return [NSString stringWithFormat:@"+3"];
    else if(curTimeZone == 18) return [NSString stringWithFormat:@"+4"];
    else if(curTimeZone == 19) return [NSString stringWithFormat:@"+5"];
    else if(curTimeZone == 20) return [NSString stringWithFormat:@"+6"];
    else if(curTimeZone == 21) return [NSString stringWithFormat:@"+7"];
    else if(curTimeZone == 22) return [NSString stringWithFormat:@"+8"];
    else if(curTimeZone == 23) return [NSString stringWithFormat:@"+9"];
    else if(curTimeZone == 24) return [NSString stringWithFormat:@"+10"];
    else if(curTimeZone == 25) return [NSString stringWithFormat:@"+11"];
    else if(curTimeZone == 26) return [NSString stringWithFormat:@"+12"];
    else
        return [NSString stringWithFormat:@"%d", curTimeZone];
    
}
- (NSString *)NvtcalcLanguage:(uint)curLanguage
{
    if (0 == curLanguage) {
        return NSLocalizedString(@"SetLanguageEn", @"");
    }
    else if(1 == curLanguage){
        return NSLocalizedString(@"SetLanguageCn", @"");
    }
    else if(2 == curLanguage){
        return NSLocalizedString(@"SetLanguageZh", @"");
    }
    else {
        return [NSString stringWithFormat:@"%ds", curLanguage];
    }
}
-(NSString *)NvtcalcCountry:(uint)curCountry
{
    if (United_State == curCountry) {
        return NSLocalizedString(@"SetCountry_UnitedState", @"");
    }
    else if(Canada == curCountry){
        return NSLocalizedString(@"SetCountry_Canada", @"");
    }
    else if(China == curCountry){
        return NSLocalizedString(@"SetCountry_China", @"");
    }
    else if(Mexico == curCountry){
        return NSLocalizedString(@"SetCountry_Mexico", @"");
    }
    else if(Korea == curCountry){
        return NSLocalizedString(@"SetCountry_Korea", @"");
    }
    else if(Japan == curCountry){
        return NSLocalizedString(@"SetCountry_Japan", @"");
    }
    else if(Taiwan == curCountry){
        return NSLocalizedString(@"SetCountry_Taiwan", @"");
    }
    else if(Russia == curCountry){
        return NSLocalizedString(@"SetCountry_Russia", @"");
    }
    else if(Spain == curCountry){
        return NSLocalizedString(@"SetCountry_Spain", @"");
    }
    else if(Norway == curCountry){
        return NSLocalizedString(@"SetCountry_Norway", @"");
    }
    else if(Finland == curCountry){
        return NSLocalizedString(@"SetCountry_Finland", @"");
    }
    else if(Sweden == curCountry){
        return NSLocalizedString(@"SetCountry_Sweden", @"");
    }
    else if(Germany == curCountry){
        return NSLocalizedString(@"SetCountry_Germany", @"");
    }
    else if(France == curCountry){
        return NSLocalizedString(@"SetCountry_France", @"");
    }
    else if(Italy == curCountry){
        return NSLocalizedString(@"SetCountry_Italy", @"");
    }
    else if(Netherlands == curCountry){
        return NSLocalizedString(@"SetCountry_Netherlands", @"");
    }
    else if(Belgium == curCountry){
        return NSLocalizedString(@"SetCountry_Belgium", @"");
    }
    else if(Denmark == curCountry){
        return NSLocalizedString(@"SetCountry_Denmark", @"");
    }
    else if(Poland == curCountry){
        return NSLocalizedString(@"SetCountry_Poland", @"");
    }
    else if(United_kingdom == curCountry){
        return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
    }
    else if(CountryMax == curCountry){
        return NSLocalizedString(@"SetCountry_Other", @"");
    }
    else {
        return [NSString stringWithFormat:@""];
    }
}
-(NSString *)NvtDetailcalcCountry:(uint)curCountry
{
    if (0 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStateEST", @"");
    else if(1 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStateCST", @"");
    else if(2 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStateMST", @"");
    else if(3 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStatePST", @"");
    else if(4 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStateAKST", @"");
    else if(5 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedStateHST", @"");
    else if(6 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaNST", @"");
    else if(7 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaAST", @"");
    else if(8 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaEST", @"");
    else if(9 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaCST", @"");
    else if(10 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaMST", @"");
    else if(11 == curCountry)
        return NSLocalizedString(@"SetCountry_CanadaPST", @"");
    else if(12 == curCountry)
        return NSLocalizedString(@"SetCountry_China", @"");
    else if(13 == curCountry)
        return NSLocalizedString(@"SetCountry_MexicoEST", @"");
    else if(14 == curCountry)
        return NSLocalizedString(@"SetCountry_MexicoCST", @"");
    else if(15 == curCountry)
        return NSLocalizedString(@"SetCountry_MexicoMST", @"");
    else if(16 == curCountry)
        return NSLocalizedString(@"SetCountry_MexicoPST", @"");
    else if(17 == curCountry)
        return NSLocalizedString(@"SetCountry_Korea", @"");
    else if(18 == curCountry)
        return NSLocalizedString(@"SetCountry_Japan", @"");
    else if(19 == curCountry)
        return NSLocalizedString(@"SetCountry_Taiwan", @"");
    else if(20 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaKALT", @"");
    else if(21 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaMSK", @"");
    else if(22 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaSAMT", @"");
    else if(23 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaYEKT", @"");
    else if(24 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaOMST", @"");
    else if(25 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaKRAT", @"");
    else if(26 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaIRKT", @"");
    else if(27 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaYAKT", @"");
    else if(28 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaVLAT", @"");
    else if(29 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaMAGT", @"");
    else if(30 == curCountry)
        return NSLocalizedString(@"SetCountry_RussiaPETT", @"");
    else if(31 == curCountry)
        return NSLocalizedString(@"SetCountry_Spain", @"");
    else if(32 == curCountry)
        return NSLocalizedString(@"SetCountry_Norway", @"");
    else if(33 == curCountry)
        return NSLocalizedString(@"SetCountry_Finland", @"");
    else if(34 == curCountry)
        return NSLocalizedString(@"SetCountry_Sweden", @"");
    else if(35 == curCountry)
        return NSLocalizedString(@"SetCountry_Germany", @"");
    else if(36 == curCountry)
        return NSLocalizedString(@"SetCountry_France", @"");
    else if(37 == curCountry)
        return NSLocalizedString(@"SetCountry_Italy", @"");
    else if(38 == curCountry)
        return NSLocalizedString(@"SetCountry_Netherlands", @"");
    else if(39 == curCountry)
        return NSLocalizedString(@"SetCountry_Belgium", @"");
    else if(40 == curCountry)
        return NSLocalizedString(@"SetCountry_Denmark", @"");
    else if(41 == curCountry)
        return NSLocalizedString(@"SetCountry_Poland", @"");
    else if(42 == curCountry)
        return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
    else if(43 == curCountry)
        return NSLocalizedString(@"SetCountry_Other", @"");
    else {
        return [NSString stringWithFormat:@""];
    }
}
- (NSString *)NvtcalcScreenSaverTime:(uint)curScreenSaver
{
    if (curScreenSaver == 0) {
        return NSLocalizedString(@"SetSettingOFF",@"");
    }
    else if(curScreenSaver == 1)
    {
        return NSLocalizedString(@"SetScreenSaver_30Seconds",@"");
    }
    else if(curScreenSaver == 2)
    {
        return NSLocalizedString(@"SetScreenSaver_2Minutes",@"");
    }
    else {
        return [NSString stringWithFormat:@"%ds", curScreenSaver];
    }
}
-(NSString *)NvtcalcResetAllValue:(uint)curResetAll
{
    if(curResetAll == 0)
    {
        return NSLocalizedString(@"SetRestoreDefaults_OK",@"");
    }
    else if(curResetAll == 1)
    {
        return NSLocalizedString(@"SetRestoreDefaults_Cancel",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)NvtcalcDeviceSounds:(uint)curDeviceSounds
{
    if (0 == curDeviceSounds) {
        return NSLocalizedString(@"SetDeviceSounds_Beep", @"");
    }
    else if(1 == curDeviceSounds){
        return NSLocalizedString(@"SetDeviceSounds_AudioRec", @"");
    }
    else {
        return [NSString stringWithFormat:@""];
    }
}


-(BOOL)CheckCellIsSwitch:(int)ModelName index:(NSIndexPath *)IndexPath CellNumber:(int)ItemNumber
{
    if(ModelName == DUO_HD)
    {
       if(ItemNumber == SettingDetailTypeAudioRecording ||
          ItemNumber == SettingDetailTypeParkingModeSensor ||
          ItemNumber == SettingDetailTypeTimeAndDateStamp ||
          ItemNumber == SettingDetailTypeSpeedStamp ||
          ItemNumber == SettingDetailTypeGPS ||
          ItemNumber == SettingDetailTypeModelNumberStamp ||
          ItemNumber == SettingDetailTypePhotoTimeAndDateStamp ||
          ItemNumber == SettingDetailTypeSpeedDisplay ||
          ItemNumber == SettingDetailTypeScreenSaver ||
          ItemNumber == SettingDetailTypeAnnouncement ||
          ItemNumber == SettingDetailTypeKeepUserSetting ||
          ItemNumber == SettingDetailTypeDeviceSounds
        )
       {
           //return [self ReturnItemSwitchValue:CellNumber Model:ModelName];
           return YES;
       }
       else
       {
           return NO;
       }
    }
    else
    {
        return NO;
    }
}
-(int)ReturnItemSwitchValue:(int)SettingTableDetailType Model:(int)ModelName
{
    if(ModelName == DUO_HD)
    {
        switch (SettingTableDetailType) {
            case SettingDetailTypeAudioRecording:
                return [[SDK instance] retrieveCurrentAudioRecording:ModelName];
            break;
                
            case SettingDetailTypeParkingModeSensor:
                return [[SDK instance] retrieveCurrentParkingModeSensor:ModelName];
            break;
                
            case SettingDetailTypeTimeAndDateStamp:
                return [[SDK instance] retrieveCurrentParkingModeSensor:ModelName];
            break;
                
            case SettingDetailTypeSpeedStamp:
                return [[SDK instance] retrieveCurrentSpeedStamp:ModelName];
            break;
            
            case SettingDetailTypeGPS:
                return [[SDK instance] retrieveCurrentGPS:ModelName];
            break;
                
            case SettingDetailTypeModelNumberStamp:
                return [[SDK instance] retrieveCurrentModelNumberStamp:ModelName];
            break;
                
            case SettingDetailTypePhotoTimeAndDateStamp:
                return [[SDK instance] retrieveCurrentPhotoTimeAndDateStamp:ModelName];
            break;
                
            case SettingDetailTypeSpeedDisplay:
                return [[SDK instance] retrieveCurrentSpeedDisplay:ModelName];
            break;
                
            case SettingDetailTypeScreenSaver:
                return [[SDK instance] retrieveCurrentScreenSaver:ModelName];
            break;
                
            case SettingDetailTypeDeviceSounds:
                return [[SDK instance] retrieveCurrentDeviceSound:ModelName];
            break;
            
            case SettingDetailTypeAnnouncement:
                return [[SDK instance] retrieveCurrentAnnouncement:ModelName];
            break;
                
            case SettingDetailTypeKeepUserSetting:
                return [[SDK instance] retrieveCurrentKeepUserSetting:ModelName];
            break;
                
            default:
                return 0;
            break;
        }
    }
    else
    {
        return 0;
    }
}
-(void)SwitchItemAddEvent:(int)SettingTableDetailType Model:(int)ModelName
{
    if(ModelName == DUO_HD)
    {
        switch (SettingTableDetailType) {
            case SettingDetailTypeAudioRecording:
                [self.switchViewer addTarget:self action:@selector(updateAudioRecordingSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeParkingModeSensor:
                [self.switchViewer addTarget:self action:@selector(updateParkingModeSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeTimeAndDateStamp:
                [self.switchViewer addTarget:self action:@selector(updateTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeSpeedStamp:
                [self.switchViewer addTarget:self action:@selector(updateSpeedStampSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeGPS:
                [self.switchViewer addTarget:self action:@selector(updateGPSSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeModelNumberStamp:
                [self.switchViewer addTarget:self action:@selector(updateModelNumberStampSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypePhotoTimeAndDateStamp:
                [self.switchViewer addTarget:self action:@selector(updatePhotoTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeSpeedDisplay:
                [self.switchViewer addTarget:self action:@selector(updateSpeedDisplaySwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeScreenSaver:
                [self.switchViewer addTarget:self action:@selector(updateScreenSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeDeviceSounds:
                [self.switchViewer addTarget:self action:@selector(updateDeviceSoundsSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeAnnouncement:
                [self.switchViewer addTarget:self action:@selector(updateAnnouncementSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            case SettingDetailTypeKeepUserSetting:
                [self.switchViewer addTarget:self action:@selector(updateKeepUserSettingSwitch:) forControlEvents:UIControlEventValueChanged];
                break;
            default:
                break;
        }
        
    }
}
#pragma mark - MBProgressHUD
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

// UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:[UITableView class]])
    {
        NSLog(@"-------是列表");
    }
    else
    {
        NSLog(@"-------是視圖");
        if (scrollView == self.scrollView) {
            NSLog(@"scrollView.contentOffset.x = %f",scrollView.contentOffset.x);
            NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
            self.pageControl.currentPage = pageIndex;
            if(self.pageControl.currentPage == 0)
            {
                self.VideoSettingButton.selected = 1;
                self.PhotoSettingButton.selected = 0;
                self.SetupSettingButton.selected = 0;
            }
            else if(self.pageControl.currentPage == 1)
            {
                self.VideoSettingButton.selected = 0;
                self.PhotoSettingButton.selected = 1;
                self.SetupSettingButton.selected = 0;
            }
            else if(self.pageControl.currentPage == 2)
            {
                self.VideoSettingButton.selected = 0;
                self.PhotoSettingButton.selected = 0;
                self.SetupSettingButton.selected = 1;
            }
            NSLog(@"pageIndex = %ld",(long)pageIndex);
        }
    }
}

// UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.leftTableView) {
        NSLog(@"Video count = %lu",(unsigned long)[[_VideoMenuTable objectAtIndex:section] count]);
         return [[_VideoMenuTable objectAtIndex:section] count];
    }
    else if(tableView == self.centerTableView)
    {
        NSLog(@"Photo count = %lu",(unsigned long)[[_PhotoMenuTable objectAtIndex:section] count]);
        return [[_PhotoMenuTable objectAtIndex:section] count];
    }
    else if(tableView == self.rightTableView)
    {
        NSLog(@"Setup count = %lu",(unsigned long)[[_SetupMenuTable objectAtIndex:section] count]);
        return [[_SetupMenuTable objectAtIndex:section] count];
    }
    else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"table_view_cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"table_view_cell"];
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor redColor];
    cell.contentView.superview.backgroundColor = [UIColor blackColor];
    
#if 1

#endif
    

    if (tableView == self.leftTableView) {
        
        
        NSDictionary *dict = [[self.VideoMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        int DetailType = [(_VideoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        
        cell.textLabel.text = [dict objectForKey:@(SettingTableTextLabel)];
        
        if([self CheckCellIsSwitch:[SSIDSreial MatchSSIDReturn:self.SSID] index:indexPath CellNumber:DetailType])
        {
            self.switchViewer = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.switchViewer.onTintColor = [UIColor redColor];
            self.switchViewer.tintColor = [UIColor redColor];
            [self SwitchItemAddEvent:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            self.switchViewer.on = [self ReturnItemSwitchValue:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            self.switchViewer.layer.cornerRadius = 15.5f;
            self.switchViewer.layer.masksToBounds = YES;
            self.switchViewer.backgroundColor = [UIColor whiteColor];
            
            /*[switchViewer addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];*/
            
            cell.accessoryView = nil;
            cell.accessoryView.backgroundColor = [UIColor blackColor];
            cell.accessoryView = self.switchViewer;
            self.switchViewer = nil;
        }
        else
        {
            cell.detailTextLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        }
        
       /* cell.textLabel.text = [NSString stringWithFormat:@"leftcell--%ld", (long)indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"leftcell--%ld", (long)indexPath.row];*/
    }
    else if(tableView == self.centerTableView)
    {
        NSDictionary *dict = [[self.PhotoMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        int DetailType = [(_PhotoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        
        cell.textLabel.text = [dict objectForKey:@(SettingTableTextLabel)];
        
        if([self CheckCellIsSwitch:[SSIDSreial MatchSSIDReturn:self.SSID] index:indexPath  CellNumber:DetailType])
        {
            
            
            self.switchViewer = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.switchViewer.onTintColor = [UIColor redColor];
            self.switchViewer.tintColor = [UIColor redColor];
            [self SwitchItemAddEvent:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            
            self.switchViewer.on = [self ReturnItemSwitchValue:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            self.switchViewer.layer.cornerRadius = 15.5f;
            self.switchViewer.layer.masksToBounds = YES;
            self.switchViewer.backgroundColor = [UIColor whiteColor];
            /*[switchViewer addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];*/
            
            cell.accessoryView = nil;
            cell.accessoryView.backgroundColor = [UIColor blackColor];
            cell.accessoryView = self.switchViewer;
            self.switchViewer = nil;
        }
        else
        {
            cell.detailTextLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        }
        
       /* cell.textLabel.text = [NSString stringWithFormat:@"cnetercell--%ld", (long)indexPath.row];
         cell.detailTextLabel.text = [NSString stringWithFormat:@"cnetercell--%ld", (long)indexPath.row];*/
    }
    else {
        NSDictionary *dict = [[self.SetupMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
         int DetailType = [(_SetupMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        
        cell.textLabel.text = [dict objectForKey:@(SettingTableTextLabel)];
        
        if([self CheckCellIsSwitch:[SSIDSreial MatchSSIDReturn:self.SSID] index:indexPath CellNumber:DetailType])
        {
            
            self.switchViewer = [[UISwitch alloc] initWithFrame:CGRectZero];
            self.switchViewer.onTintColor = [UIColor redColor];
            self.switchViewer.tintColor = [UIColor redColor];
            [self SwitchItemAddEvent:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            self.switchViewer.on = [self ReturnItemSwitchValue:DetailType Model:[SSIDSreial MatchSSIDReturn:self.SSID]];
            self.switchViewer.layer.cornerRadius = 15.5f;
            self.switchViewer.layer.masksToBounds = YES;
            self.switchViewer.backgroundColor = [UIColor whiteColor];
            /*[switchViewer addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventValueChanged];*/
            
            cell.accessoryView = nil;
            cell.accessoryView.backgroundColor = [UIColor blackColor];
            cell.accessoryView = self.switchViewer;
            self.switchViewer = nil;
        }
        else
        {
            cell.detailTextLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        }
       /* cell.textLabel.text = [NSString stringWithFormat:@"rightcell--%ld", (long)indexPath.row];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"rightcell--%ld", (long)indexPath.row];*/
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView               :(UITableView *)tableView
        didSelectRowAtIndexPath :(NSIndexPath *)indexPath
{
    int DetailItem = 0;
    if(tableView == self.leftTableView)
    {
        DetailItem = [(_VideoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        /*NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        [self.leftTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];*/
        NSLog(@"didcellleft");
    }
    else if(tableView == self.centerTableView)
    {
        DetailItem = [(_PhotoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        /*NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        [self.centerTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];*/
        
        NSLog(@"didcellcenter");
    }
    else if(tableView == self.rightTableView)
    {
        DetailItem = [(_SetupMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue];
        NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
        /*[self.rightTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];*/
        NSLog(@"didcellright");
    }
    if([self CheckCellIsSwitch:[SSIDSreial MatchSSIDReturn:self.SSID] index:indexPath CellNumber:DetailItem])
    {
        NSLog(@"isSwitch");
    }
    else
    {
         NSLog(@"NoSwitch");
    }

}


- (NSIndexPath *) tableView               :(UITableView *)tableView
                  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict;
    if(tableView == self.leftTableView)
    {
        dict = [[_VideoMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else if(tableView == self.centerTableView)
    {
        dict = [[_PhotoMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else
    {
         dict = [[_SetupMenuTable objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [_SecondMenuTable setArray:[dict objectForKey:@(SettingTableDetailData)]];
    _curSettingDetailType = [[dict objectForKey:@(SettingTableDetailType)] integerValue];
    _curSettingDetailItem = [[dict objectForKey:@(SettingTableDetailLastItem)] integerValue];
    
    return indexPath;
}
// UITableViewDelegate 左划按钮的回调方法
/*- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"删除", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"---执行删除操作---%ld", (long)indexPath.row);
    }];
    return @[deleteAction];
}*/

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.scrollView.scrollEnabled = NO;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(nullable NSIndexPath *)indexPath {
    self.scrollView.scrollEnabled = YES;
}

- (IBAction)VideoSettingAction:(id)sender {
    
    if(self.VideoSettingButton.selected == 0)
    {
        [self.pageControl setCurrentPage:0];
        [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage*CGRectGetWidth(self.view.frame), 0) animated:YES];
        //[self DUOHDVideoSettingDataCell:[SSIDSreial MatchSSIDReturn:self.SSID]];
    }
    
}
- (IBAction)PhotoSettingAction:(id)sender {
    
    if(self.PhotoSettingButton.selected == 0)
    {
        [self.pageControl setCurrentPage:1];
        [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage*CGRectGetWidth(self.view.frame), 0) animated:YES];
        
        //[self DUOHDPhotoSettingDataCell:[SSIDSreial MatchSSIDReturn:self.SSID]];
    }
}
- (IBAction)SetupSettingAction:(id)sender {
    
    if(self.SetupSettingButton.selected == 0)
    {
        [self.pageControl setCurrentPage:2];
        [self.scrollView setContentOffset:CGPointMake(self.pageControl.currentPage*CGRectGetWidth(self.view.frame), 0) animated:YES];
        
        //[self DUOHDSetupSettingDataCell:[SSIDSreial MatchSSIDReturn:self.SSID]];
    }
}



- (IBAction)updateAudioRecordingSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_AudioRecording value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateParkingModeSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_ParkingModeSensor value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateTimeAndDateStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_VidoeTimeDateStamp value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateSpeedStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_SpeedStamp value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateGPSSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_GPS value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateModelNumberStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_ModelNumberStamp value:Value];
        }
    }
    NSLog(@"Swich Event");
}

- (IBAction)updatePhotoTimeAndDateStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_PhotoTimeAndStamp value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateScreenSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_ScreenSave value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateDeviceSoundsSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_BeepSound value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateAnnouncementSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_Announcement value:Value];
        }
    }
    NSLog(@"Swich Event");
}
- (IBAction)updateKeepUserSettingSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_KeepUserSetting value:Value];
        }
    }
    NSLog(@"Swich Event");
}

- (IBAction)updateSpeedDisplaySwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint Value = 0;
    if([SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([SSIDSreial CheckICatchArch:self.SSID] == isV35)
        {
            if ([switchView isOn])
            {
                Value = 0;
            }
            else
            {
                Value = 1;
            }
            [[SDK instance] setCustomizeIntProperty:DUOPropertyID_SpeedDisplay value:Value];
        }
    }
    NSLog(@"Swich Event");
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
#endif
@end

