//
//  CustomSettingViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/9.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "CustomSettingViewController.h"
#import "WifiCamAlertTable.h"

#import "VideoSettingTableViewCell.h"
#import "PhotoSettingTableViewCell.h"
#import "SetupSettingTableViewCell.h"
#import "MBProgressHUD.h"
#import "CustomSettingSubViewController.h"



@interface CustomSettingViewController ()<AppDelegateProtocol,UIScrollViewDelegate,NSXMLParserDelegate,UITableViewDelegate, UITableViewDataSource>
{
    int DateStyleChoose;
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    
    
    BOOL storingFlag; //查询标签所对应的元素是否存在
    
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StringFlag;
    BOOL FileListFlag;
    BOOL NameFlag;
    BOOL FpathFlag;
    BOOL SizeFlag;
    BOOL TimeCodeFlag;
    BOOL TimeFlag;
    BOOL LockFlag;
    BOOL AttrFlag;
    BOOL StoreFlag;
    BOOL passwordFlag;
    BOOL isVideo;
    NSArray *elementToParse;  //要存储的元素
    NSFileHandle *fileHandle;
    int FileNumber;
    NSString *tmpPath;
    NSString *tmpfilePath;
    
    NSString *timeFormat;
    
    AppDelegate *delegate;
}

@property (weak, nonatomic) IBOutlet UITableView *VideoTable;
@property (weak, nonatomic) IBOutlet UITableView *PhotoTable;
@property (weak, nonatomic) IBOutlet UITableView *SetupTable;
@property (weak, nonatomic) IBOutlet UIButton *VideoModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *PhotoModeBtn;
@property (weak, nonatomic) IBOutlet UIButton *SetupModeBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *ScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;


@property(nonatomic) NSMutableArray *VideoMenuTableArray;
@property(nonatomic) NSMutableArray *PhotoMenuTableArray;
@property(nonatomic) NSMutableArray *SetupMenuTableArray;

@property(nonatomic) NSMutableArray *SecondMenuTable;

@property(nonatomic) NSMutableArray *VideoMenuSettingTable;
@property(nonatomic) NSMutableArray *PhotoMenuSettingTable;
@property(nonatomic) NSMutableArray *SetupMenuSettingTable;

@property(nonatomic) NSMutableArray *SecondMenuSettingTable;

@property(nonatomic) NSMutableArray *subMenuTable;


@property(nonatomic) NSInteger curSettingDetailType;
@property(nonatomic) NSInteger curSettingDetailItem;

@property (nonatomic, strong) NSMutableDictionary *NVTSettingValueDict;

@property(nonatomic) MBProgressHUD *progressHUD;

@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;



@property (nonatomic) SSID_SerialCheck *SSIDSreial;
@property (nonatomic) NSString *SSID;
@property (nonatomic, strong) UIPageControl *pageControl;
@property(nonatomic) UIDatePicker *datePicker;
@property(nonatomic) UIView *BackView;
@property(nonatomic) UIView *TopView;
@property(nonatomic) UIButton *DatePickerOK;
@property(nonatomic) UIButton *DatePickerCancel;

@property(nonatomic) UIButton *BtnLeftChoice;
@property(nonatomic) UIButton *BtnRightChoice;
@property(nonatomic) UITextField *DateStyle;
@property(nonatomic) NSString *DatePickerStringDate;
@property(nonatomic) NSString *DatePickerStringTime;
@property(nonatomic) NSString *TimeAndDate;
@property(nonatomic,strong)NSBundle *bundle;

@end

@implementation CustomSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCloseController:) name:@"closeCustomSettingViewController" object:nil];
    
    self.VideoTable.backgroundColor = UIColor.clearColor;
    self.PhotoTable.backgroundColor = UIColor.clearColor;
    self.SetupTable.backgroundColor = UIColor.clearColor;
    if([[delegate getTimeFormat]  isEqual: @"12H"]) {
        timeFormat = @"12H";
    } else if([[delegate getTimeFormat]  isEqual: @"24H"]) {
        timeFormat = @"24H";
    } else {
        timeFormat = @"12H";
    }
    
    //set title
    [self getSSID];
    [self setupUI];
    [self InitVar];
    
    [self configScrollView];
    [self configTableView];
    // Do any additional setup after loading the view.
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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.DatePickerOK removeFromSuperview];
    [self.DatePickerCancel removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.BackView removeFromSuperview];
    [self.TopView removeFromSuperview];
    [self.DateStyle removeFromSuperview];
    [self.BtnLeftChoice removeFromSuperview];
    [self.BtnRightChoice removeFromSuperview];
    DateStyleChoose = 0;
    [self.VideoTable reloadData];
    [self.PhotoTable reloadData];
    [self.SetupTable reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[VideoTable setRowHeight:25.0];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        [self NVTGetHttpCmd:@"3014"];

        
        if([self.SSIDSreial MatchSSIDReturn:self.SSID] == D200GW||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200 ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200GW ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200)
        {

            //[self D200GWNvtfillMainMenuSettingTable:[SSIDSreial MatchSSIDReturn:self.SSID]];
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1)
        {
           
            [self NVTGetHttpCmd:@"3118"];
            [self NVTGetHttpCmd:@"3119"];
            [self C1GWNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
        {
            [self NVTGetHttpCmd:@"3118"];
            [self NVTGetHttpCmd:@"3119"];
            [self CARDV312GWNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
        {
            
            [self NVTGetHttpCmd:@"3118"];
            [self NVTGetHttpCmd:@"3119"];
            [self DRVA301WNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            
        }
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
        {
            [self K6fillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DUO_HD)
        {
            [self DUOHDfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            
        }
    }
    [self.VideoTable reloadData];
    [self.PhotoTable reloadData];
    [self.SetupTable reloadData];
}
-(void)setupUI
{
    self.titlelabel.text = [delegate getStringForKey:@"VideoMenu" withTable:@""];
    [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_video"]];
    
    self.VideoModeBtn.selected = 1;
    self.PhotoModeBtn.selected = 0;
    self.SetupModeBtn.selected = 0;
    
    [self.VideoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_video"] forState:UIControlStateNormal];
    
    [self.VideoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_video_select"] forState:UIControlStateSelected];
    
    [self.PhotoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_camera"] forState:UIControlStateNormal];
    
    [self.PhotoModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_camera_select"] forState:UIControlStateSelected];
    
    [self.SetupModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_setting"] forState:UIControlStateNormal];
    
    [self.SetupModeBtn setImage:[UIImage imageNamed:@"control_dashcamsetting_setting_select"] forState:UIControlStateSelected];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.pageControl.numberOfPages = 3;
    self.pageControl.enabled = NO;
}

-(void)InitVar
{
    
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTSettingValueDict = [[NSMutableDictionary alloc] init];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        WifiCamManager *app = [WifiCamManager instance];
        self.wifiCam = [app.wifiCams objectAtIndex:0];
        self.camera = _wifiCam.camera;
        self.ctrl = _wifiCam.controler;
        [_ctrl.propCtrl updateAllProperty:_camera];
    }
    
    self.VideoMenuTableArray = [[NSMutableArray alloc] init];
    self.PhotoMenuTableArray = [[NSMutableArray alloc] init];
    self.SetupMenuTableArray = [[NSMutableArray alloc] init];
    self.SecondMenuTable = [[NSMutableArray alloc] init];
    self.VideoMenuSettingTable = [[NSMutableArray alloc] init];
    self.PhotoMenuSettingTable = [[NSMutableArray alloc] init];
    self.SetupMenuSettingTable = [[NSMutableArray alloc] init];
    self.SecondMenuSettingTable = [[NSMutableArray alloc] init];
    
    self.subMenuTable = [[NSMutableArray alloc] init];

    
    
    [self.VideoMenuTableArray insertObject:_VideoMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    [self.PhotoMenuTableArray insertObject:_PhotoMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    [self.SetupMenuTableArray insertObject:_SetupMenuSettingTable
                          atIndex:SettingSectionTypeSetting];
    
    [self.SecondMenuTable insertObject:_SecondMenuSettingTable
                           atIndex:SettingSectionTypeSetting];
    
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.delegate = self;
}




-(void)getSSID
{
    self.SSID = [self recheckSSID];
    self.SSIDSreial = [[SSID_SerialCheck alloc] init];
}

-(void)configScrollView
{
  self.ScrollView.delegate = self;
}
-(void)configTableView
{
   self.VideoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.PhotoTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.SetupTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.VideoTable.delegate = self;
    self.VideoTable.dataSource = self;
    
    self.PhotoTable.delegate = self;
    self.PhotoTable.dataSource = self;
    
    self.SetupTable.delegate = self;
    self.SetupTable.dataSource = self;
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

- (void)K6fillMainMenuSettingTable:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    [self.PhotoMenuSettingTable removeAllObjects];
    [self.SetupMenuSettingTable removeAllObjects];
    
    [self K6VideoSettingDataCell:ModelName];
    [self K6PhotoSettingDataCell:ModelName];
    [self K6SetupSettingDataCell:ModelName];
}

- (void)DUOHDfillMainMenuSettingTable:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    [self.PhotoMenuSettingTable removeAllObjects];
    [self.SetupMenuSettingTable removeAllObjects];

    [self DUOHDVideoSettingDataCell:ModelName];
    [self DUOHDPhotoSettingDataCell:ModelName];
    [self DUOHDSetupSettingDataCell:ModelName];
}

-(void)CARDV312GWNvtfillMainMenuSettingTable:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    [self.PhotoMenuSettingTable removeAllObjects];
    [self.SetupMenuSettingTable removeAllObjects];
    
    [self CARDV312GWNvtVideoSettingDataCell:ModelName];
    [self CARDV312GWNvtPhotoSettingDataCell:ModelName];
    [self CARDV312GWNvtSetupSettingDataCell:ModelName];
    
}

- (void)C1GWNvtfillMainMenuSettingTable:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    [self.PhotoMenuSettingTable removeAllObjects];
    [self.SetupMenuSettingTable removeAllObjects];
    
    [self C1GWNvtVideoSettingDataCell:ModelName];
    [self C1GWNvtPhotoSettingDataCell:ModelName];
    [self C1GWNvtSetupSettingDataCell:ModelName];
}

- (void)DRVA301WNvtfillMainMenuSettingTable:(int)ModelName
{
    [self.VideoMenuSettingTable removeAllObjects];
    [self.PhotoMenuSettingTable removeAllObjects];
    [self.SetupMenuSettingTable removeAllObjects];
    
    [self DRVA301WNvtVideoSettingDataCell:ModelName];
    [self DRVA301WNvtPhotoSettingDataCell:ModelName];
    [self DRVA301WNvtSetupSettingDataCell:ModelName];
}
- (void)C1GWNvtVideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetParkingModeSensor" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtParkingModeSensor)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillGSensorTable:ModelName];
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGPS" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtGPS)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillSpeedUnitTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillScreenSaverTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetUltraDashStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeUltraDashStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeTimeAndDateStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetInformationStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeInformationStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillLicensePlateStampTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
}

- (void)C1GWNvtPhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillPhotoExposureCompensationTable:ModelName];
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypePhotoTimeAndDateStamp)};
    
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
}
- (void)C1GWNvtSetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillDeviceSoundsTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillDateTimeTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillTimeZoneTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillLanguageTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillCountryTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    
}
- (void)DRVA301WNvtVideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetParkingModeSensor" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtParkingModeSensor)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillGSensorTable:ModelName];
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGPS" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtGPS)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillSpeedUnitTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] != DRVA700W) {
        table = [self fillScreenSaverTable];
        if (table) {
            [self.VideoMenuSettingTable addObject:table];
        }
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetKENWOODStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeUltraDashStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeTimeAndDateStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetInformationStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeInformationStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillLicensePlateStampTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
}

- (void)DRVA301WNvtPhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillPhotoExposureCompensationTable:ModelName];
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypePhotoTimeAndDateStamp)};
    
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
}
- (void)DRVA301WNvtSetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillDeviceSoundsTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillDateTimeTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillTimeZoneTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] != DRVA700W) {
        table = [self fillLanguageTable:ModelName];
        if (table) {
            [self.SetupMenuSettingTable addObject:table];
        }
    }
    table = [self fillCountryTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetImageReversal" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeRotateDisplay)};
    
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W) {
        table = [self fillResetAllTable:ModelName];
        
        if (table) {
            [self.SetupMenuSettingTable addObject:table];
        }
        table = [self fillPasswordChangeTable:ModelName];
        
        if (table) {
            [self.SetupMenuSettingTable addObject:table];
        }
    }
}
-(void)CARDV312GWNvtVideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    

    
    table = [self fillLicensePlateStampTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    

    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetParkingModeSensor" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtParkingModeSensor)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    

    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeTimeAndDateStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetSpeedStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeSpeedStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGPSLocationStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeNvtGPS)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillGSensorTable:ModelName];
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }

    
    

}

-(void)CARDV312GWNvtPhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
     table = [self fillPhotoExposureCompensationTable:ModelName];
     if (table) {
     [self.PhotoMenuSettingTable addObject:table];
     }
     
     table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
     @(SettingTableDetailType):@(SettingDetailTypePhotoTimeAndDateStamp)};
     
     if (table) {
     [self.PhotoMenuSettingTable addObject:table];
     }

}

-(void)CARDV312GWNvtSetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillDateTimeTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillTimeZoneTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillLanguageTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillSpeedUnitTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }

    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetScreenSaver" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeScreenSaver)};
    
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetScreenSaver" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeDeviceSounds)};
    
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillAutoPowerOffTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    

}

- (void)DUOHDVideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillLicensePlateStampTable];
    if(table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    table = [self fillGSensorTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
}
- (void)DUOHDPhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillPhotoExposureCompensationTable:ModelName];
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
}
- (void)DUOHDSetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if(table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    /*table = [self fillDateTimeTable];
    if(table) {
        [self.SetupMenuSettingTable addObject:table];
    }*/
    
    table = [self fillLanguageTable:ModelName];
    if(table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
}
- (void)K6VideoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    
    table = [self fillCustomVideoSizeTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    
    table = [self fillVideoFileLengthTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillExposureCompensationTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetParkingModeSensor" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeParkingModeSensor)};
    
    if(table)
    {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillGSensorTable:ModelName];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGPS" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeGPS)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillSpeedUnitTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = [self fillScreenSaverTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetKENWOODStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeUltraDashStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeTimeAndDateStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetInformationStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeInformationStamp)};
    
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
    
    
    table = [self fillLicensePlateStampTable];
    if (table) {
        [self.VideoMenuSettingTable addObject:table];
    }
}

- (void)K6PhotoSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillPhotoExposureCompensationTable:ModelName];
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
    //table = [self fillPhotoBurstTable];
    //if (table) {
    //    [self.PhotoMenuSettingTable addObject:table];
    //}
    
    //table = [self fillDelayTimerTable];
    //if (table) {
    //    [self.PhotoMenuSettingTable addObject:table];
    //}
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeAndDateStamp" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypePhotoTimeAndDateStamp)};
    
    if (table) {
        [self.PhotoMenuSettingTable addObject:table];
    }
}
- (void)K6SetupSettingDataCell:(int)ModelName
{
    NSDictionary *table = nil;
    table = [self fillSDFormatTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    //table = [self fillAutoPowerOffTable];
    //if (table) {
    //    [self.SetupMenuSettingTable addObject:table];
    //}
    table = [self fillDeviceSoundsTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillDateTimeTable];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillTimeZoneTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    table = [self fillLanguageTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = [self fillCountryTable:ModelName];
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
    table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetImageReversal" withTable:@""],
              @(SettingTableDetailType):@(SettingDetailTypeRotateDisplay)};
    
    if (table) {
        [self.SetupMenuSettingTable addObject:table];
    }
    
}
- (NSDictionary *)fillCustomVideoSizeTable:(int)ModelName
{
    
    NSDictionary *table = nil;
    WifiCamAlertTable *vsArray;
    
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curVideoSize;
        curVideoSize = [[self.NVTSettingValueDict objectForKey:@"2002"] intValue];
        
        if(ModelName == C1GW)
        {
            vsArray = [self NvtprepareDataForVideoSize:curVideoSize Item:2 Model:ModelName];
        } else if(ModelName == CARDV312GW)
        {
            vsArray = [self NvtprepareDataForVideoSize:curVideoSize Item:3 Model:ModelName];
        } else if(ModelName == KVDR300W || ModelName == KVDR400W ||
                  ModelName == DRVA301W || ModelName == DRVA401W)
        {
            vsArray = [self NvtprepareDataForVideoSize:curVideoSize Item:2 Model:ModelName];
        } else if(ModelName == KVDR500W || ModelName == DRVA501W ||
                  ModelName == DRVA700W)
        {
            vsArray = [self NvtprepareDataForVideoSize:curVideoSize Item:3 Model:ModelName];
        }
        //vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength];
        if (vsArray.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"ALERT_TITLE_SET_VIDEO_RESOLUTION" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcVideoSize:curVideoSize Model:ModelName],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"ALERT_TITLE_SET_VIDEO_RESOLUTION" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcCustomVideoSizeValue:curVideoSize Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoSize),
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
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curExposureCompensation = [[self.NVTSettingValueDict objectForKey:@"2005"] intValue];
        ec = [self NvtprepareDataForExposureCompensation:curExposureCompensation];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetExposureCompensation" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetExposureCompensation" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcExposureCompensationValue:curExposureCompensation Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    
    
    return table;
}


- (NSDictionary *)fillTimeZoneTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curTimeZone = [[self.NVTSettingValueDict objectForKey:@"3109"] intValue];
        WifiCamAlertTable *timezone = [self NvtprepareDataForTimeZone:curTimeZone];
        if (timezone.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeZone" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcTimeZone:curTimeZone],
                      @(SettingTableDetailType):@(SettingDetailTypeTimeZone),
                      @(SettingTableDetailData):timezone.array,
                      @(SettingTableDetailLastItem):@(timezone.lastIndex)};
        }
    }
    else
    {
        uint curTimeZone = [[SDK instance] retrieveCurrentTimeZone];
        WifiCamAlertTable *timezone = [_ctrl.propCtrl prepareDataForTimeZone:curTimeZone];
        
        if (timezone.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetTimeZone" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcTimeZone:curTimeZone],
                      @(SettingTableDetailType):@(SettingDetailTypeTimeZone),
                      @(SettingTableDetailData):timezone.array,
                      @(SettingTableDetailLastItem):@(timezone.lastIndex)};
        }
    }
    return table;
}
- (NSDictionary *)fillSDFormatTable:(int)ModelName
{
    NSDictionary *table = nil;
    //uint curSpeedUnit = [[SDK instance] retrieveCurrentSpeedUnit];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        WifiCamAlertTable *sdformat = [self NvtprepareDataForSDFormat];
        if (sdformat.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetSDFormat" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetSDFormat" withTable:@""],
                      //@(SettingTableDetailTextLabel):[_ctrl.propCtrl calcSpeedUnitValue:curSpeedUnit],
                      @(SettingTableDetailType):@(SettingDetailTypeSDFormat),
                      @(SettingTableDetailData):sdformat.array,
                      @(SettingTableDetailLastItem):@(sdformat.lastIndex)};
        }
    }
    return table;
}
- (NSDictionary *)fillPhotoExposureCompensationTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curExposureCompensation = [[self.NVTSettingValueDict objectForKey:@"3201"] intValue];
        WifiCamAlertTable *ec = [self NvtprepareDataForPhotoExposureCompensation:curExposureCompensation];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetExposureCompensation" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetExposureCompensation" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcExposureCompensationValue:curExposureCompensation Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypePhotoExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }
    }
    
    return table;
}
- (NSDictionary *)fillVideoFileLengthTable:(int)ModelName
{
    NSDictionary *table = nil;
    uint curVideoFileLength;
    WifiCamAlertTable *vfl;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(ModelName == C1GW || ModelName == KVDR300W || ModelName == KVDR400W ||
           ModelName == KVDR500W || ModelName == DRVA301W ||
           ModelName == DRVA401W || ModelName == DRVA501W ||
           ModelName == DRVA700W)
        {
            curVideoFileLength = [[self.NVTSettingValueDict objectForKey:@"2003"] intValue];
        }
        else if(ModelName == CARDV312GW)
        {
            curVideoFileLength = [[self.NVTSettingValueDict objectForKey:@"2016"] intValue];
        }
        else
        {
              curVideoFileLength = 0;
        }
        
        vfl = [self NvtprepareDataForVideoFileLength:curVideoFileLength Model:ModelName];
        //vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength];
        if (vfl.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetVideoFileLength" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcVideoFileLength:curVideoFileLength Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoFileLength),
                      @(SettingTableDetailData):vfl.array,
                      @(SettingTableDetailLastItem):@(vfl.lastIndex)};
        }
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        curVideoFileLength = [[SDK instance] retrieveCurrentVideoFileLength:ModelName];
        vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength ModelName:ModelName];
        if (vfl.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetVideoFileLength" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcVideoFileLength:curVideoFileLength Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeVideoFileLength),
                      @(SettingTableDetailData):vfl.array,
                      @(SettingTableDetailLastItem):@(vfl.lastIndex)};
        }
        
    }
    
    
    return table;
}
- (NSDictionary *)fillLicensePlateStampTable
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *curLicensePlateStamp = [self.NVTSettingValueDict objectForKey:@"3118"];
        WifiCamAlertTable *ssArray = [self NvtprepareDataForLicensePlateStamp:curLicensePlateStamp];
        if (ssArray.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetLicensePlateStamp" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetLicensePlateStamp" withTable:@""],
                      @(SettingTableDetailTextLabel):curLicensePlateStamp,
                      @(SettingTableDetailType):@(SettingDetailTypeLicensePlateStamp),
                      @(SettingTableDetailData):ssArray.array,
                      @(SettingTableDetailLastItem):@(ssArray.lastIndex)};
        }
    }
    return table;
}
- (NSDictionary *)fillDeviceSoundsTable
{
    NSDictionary *table = nil;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1 ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        WifiCamAlertTable *devicesounds = [self NvtprepareDataForDeviceSounds];
        if (devicesounds.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetDeviceSounds" withTable:@""],
                      @(SettingTableDetailTextLabel):@"",
                      @(SettingTableDetailType):@(SettingDetailTypeDeviceSounds),
                      @(SettingTableDetailData):devicesounds.array,
                      @(SettingTableDetailLastItem):@(devicesounds.lastIndex)};
        }
    }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
            [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
    {
        WifiCamAlertTable *devicesounds = [self NvtprepareDataForDeviceSounds];
        if (devicesounds.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetDeviceSounds" withTable:@""],
                      @(SettingTableDetailTextLabel):@"",
                      @(SettingTableDetailType):@(SettingDetailTypeDeviceSounds),
                      @(SettingTableDetailData):devicesounds.array,
                      @(SettingTableDetailLastItem):@(devicesounds.lastIndex)};
        }
    }
    else
    {
        WifiCamAlertTable *devicesounds = [_ctrl.propCtrl prepareDataForDeviceSounds];
        
        if (devicesounds.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetDeviceSounds" withTable:@""],
                      @(SettingTableDetailTextLabel):@"",
                      @(SettingTableDetailType):@(SettingDetailTypeDeviceSounds),
                      @(SettingTableDetailData):devicesounds.array,
                      @(SettingTableDetailLastItem):@(devicesounds.lastIndex)};
        }
    }
    return table;
}

- (NSDictionary *)fillDateTimeTable
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *curDateTime = [[[self.NVTSettingValueDict objectForKey:@"3119"] substringWithRange:NSMakeRange(0, [[self.NVTSettingValueDict objectForKey:@"3119"] length]-3)] stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        WifiCamAlertTable *DateTime = [self NvtprepareDataForDateTime:curDateTime];
        if (DateTime.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetDateTime" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetDateTime" withTable:@""],
                      @(SettingTableDetailTextLabel):resultDateTime,
                      @(SettingTableDetailType):@(SettingDetailTypeDateTime),
                      @(SettingTableDetailData):DateTime.array,
                      @(SettingTableDetailLastItem):@(DateTime.lastIndex)};
        }
    }
    return table;
}
- (NSDictionary *)fillSpeedUnitTable
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curSpeedUnit = [[self.NVTSettingValueDict objectForKey:@"3111"] intValue];
        WifiCamAlertTable *spdunit = [self NvtprepareDataForSpeedUnit:curSpeedUnit];
        if (spdunit.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetSpeedUnit" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcSpeedUnitValue:curSpeedUnit],
                      @(SettingTableDetailType):@(SettingDetailTypeSpeedUnit),
                      @(SettingTableDetailData):spdunit.array,
                      @(SettingTableDetailLastItem):@(spdunit.lastIndex)};
        }
    }
    else
    {
        uint curSpeedUnit = [[SDK instance] retrieveCurrentSpeedUnit];
        WifiCamAlertTable *spdunit = [_ctrl.propCtrl prepareDataForSpeedUnit:curSpeedUnit];
        if (spdunit.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetSpeedUnit" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcSpeedUnitValue:curSpeedUnit],
                      @(SettingTableDetailType):@(SettingDetailTypeSpeedUnit),
                      @(SettingTableDetailData):spdunit.array,
                      @(SettingTableDetailLastItem):@(spdunit.lastIndex)};
        }
    }
    
    
    return table;
}


- (NSDictionary *)fillGSensorTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curGSensor = [[self.NVTSettingValueDict objectForKey:@"2011"] intValue];
        WifiCamAlertTable *gs = [self NvtprepareDataForGSensor:curGSensor];
        if (gs.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGSensor" withTable:@""],
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
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetGSensor" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcGSensorValue:curGSensor Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeGSensor),
                      @(SettingTableDetailData):gs.array,
                      @(SettingTableDetailLastItem):@(gs.lastIndex)};
        }
    }
    
    return table;
}
- (NSDictionary *)fillPasswordChangeTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        [self NVTGetHttpCmd:@"3029"];
        WifiCamAlertTable *passwordChange = [self NvtprepareDataForPasswordChange];
        if (passwordChange.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetWirelessLinkPassword2" withTable:@""],
                      @(SettingTableDetailTextLabel):[_NVTSettingValueDict objectForKey:@"WirelessLinkPassword"],
                      @(SettingTableDetailType):@(SettingDetailTypePasswordChange),
                      @(SettingTableDetailData):passwordChange.array,
                      @(SettingTableDetailLastItem):@(passwordChange.lastIndex)};
        }
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        
    }
    
    
    return table;
}

- (NSDictionary *)fillCountryTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint titleCountry;
        uint curCountry = [[self.NVTSettingValueDict objectForKey:@"3110"] intValue];
        if(curCountry >= 0 && curCountry <= 5)
            titleCountry = 0;
        else if(curCountry >= 6 && curCountry <= 11)
            titleCountry = 1;
        else if(curCountry >= 12 && curCountry <= 22)
            titleCountry = 2;
        else
            titleCountry = curCountry-20;
        
        WifiCamAlertTable *country = [self NvtprepareDataForCountry:titleCountry];
        if (country.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetCountry" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtDetailcalcCountry:curCountry],
                      @(SettingTableDetailType):@(SettingDetailTypeCountry),
                      @(SettingTableDetailData):country.array,
                      @(SettingTableDetailLastItem):@(country.lastIndex)};
        }
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if(ModelName == CANSONIC_U2 ||
           ModelName == KVDR600W ||
           ModelName == DRVA601W) {
            uint curCountry = [[SDK instance] retrieveCurrentCountry:ModelName];
            uint curCountry2 = [[SDK instance] retrieveSubCurrentCountry];
            WifiCamAlertTable *gs = [_ctrl.propCtrl prepareDataForCountry:curCountry Country2:curCountry2 Model:ModelName];
            if (gs.array) {
                table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetCountry" withTable:@""],
                          @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcCountry:curCountry Country2:curCountry2 Model:ModelName],
                          @(SettingTableDetailType):@(SettingDetailTypeCountry),
                          @(SettingTableDetailData):gs.array,
                          @(SettingTableDetailLastItem):@(gs.lastIndex)};
            }
        }
        //prepareDataForCountry
        /*uint curCountry = [[SDK instance] retrieveCurrentCountry];
         uint SubCurCountry = [[SDK instance] retrieveSubCurrentCountry];
         WifiCamAlertTable *country;
         if(((curCountry-1) != United_State) && ((curCountry-1) != Canada) && ((curCountry-1) != Mexico)&& ((curCountry-1) != Russia))
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



- (NSDictionary *)fillScreenSaverTable
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        uint curScreenSaver = [[self.NVTSettingValueDict objectForKey:@"3113"] intValue];
        WifiCamAlertTable *ssArray = [self NvtprepareDataForScreenSaver:curScreenSaver];
        if (ssArray.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetScreenSaver" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcScreenSaverTime:curScreenSaver],
                      @(SettingTableDetailType):@(SettingDetailTypeScreenSaver),
                      @(SettingTableDetailData):ssArray.array,
                      @(SettingTableDetailLastItem):@(ssArray.lastIndex)};
        }
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        uint curScreenSaver = [[SDK instance] retrieveCurrentScreenSaver];
        WifiCamAlertTable *ssArray = [_ctrl.propCtrl prepareDataForScreenSaver:curScreenSaver];
        
        if (ssArray.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetScreenSaver" withTable:@""],
                      @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcScreenSaverTime:curScreenSaver],
                      @(SettingTableDetailType):@(SettingDetailTypeScreenSaver),
                      @(SettingTableDetailData):ssArray.array,
                      @(SettingTableDetailLastItem):@(ssArray.lastIndex)};
        }
    }
    return table;
}


- (NSDictionary *)fillLanguageTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {

        uint curLanguage = [[self.NVTSettingValueDict objectForKey:@"3008"] intValue];

        
        WifiCamAlertTable *language = [self NvtprepareDataForLanguage:curLanguage Model:ModelName];
        if (language.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetLanguage" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcLanguage:curLanguage Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeLanguage),
                      @(SettingTableDetailData):language.array,
                      @(SettingTableDetailLastItem):@(language.lastIndex)};
        }
    }
    else
    {
        /* uint curLanguage = [[SDK instance] retrieveCurrentLanguage];
         WifiCamAlertTable *language = [_ctrl.propCtrl prepareDataForLanguage:curLanguage];
         
         if (language.array) {
         table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLanguage", @""),
         @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcLanguage:curLanguage],
         @(SettingTableDetailType):@(SettingDetailTypeLanguage),
         @(SettingTableDetailData):language.array,
         @(SettingTableDetailLastItem):@(language.lastIndex)};
         }*/
    }
    return table;
}



- (NSDictionary *)fillResetAllTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        
        //uint curResetAll = [[self.NVTSettingValueDict objectForKey:@"3008"] intValue];
        
        
        WifiCamAlertTable *resetAll = [self NvtprepareDataForResetAll];
        if (resetAll.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetResetAll" withTable:@""],
                      //@(SettingTableDetailTextLabel):[self NvtcalcResetAll:curResetAll],
                      @(SettingTableDetailType):@(SettingDetailTypeResetAll),
                      @(SettingTableDetailData):resetAll.array,
                      @(SettingTableDetailLastItem):@(resetAll.lastIndex)};
        }
    }
    else
    {
        /* uint curLanguage = [[SDK instance] retrieveCurrentLanguage];
         WifiCamAlertTable *language = [_ctrl.propCtrl prepareDataForLanguage:curLanguage];
         
         if (language.array) {
         table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLanguage", @""),
         @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcLanguage:curLanguage],
         @(SettingTableDetailType):@(SettingDetailTypeLanguage),
         @(SettingTableDetailData):language.array,
         @(SettingTableDetailLastItem):@(language.lastIndex)};
         }*/
    }
    return table;
}

- (NSDictionary *)fillAutoPowerOffTable:(int)ModelName
{
    NSDictionary *table = nil;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        
        uint curLanguage = [[self.NVTSettingValueDict objectForKey:@"3007"] intValue];
        
        
        WifiCamAlertTable *AutoPowerOff = [self NvtprepareDataForAutoPowerOff:curLanguage Model:ModelName];
        if (AutoPowerOff.array) {
            table = @{@(SettingTableTextLabel):[delegate getStringForKey:@"SetAutoPowerOff" withTable:@""],
                      @(SettingTableDetailTextLabel):[self NvtcalcAutoPowerOffValue:curLanguage Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypeAutoPowerOff),
                      @(SettingTableDetailData):AutoPowerOff.array,
                      @(SettingTableDetailLastItem):@(AutoPowerOff.lastIndex)};
        }
    }
    else
    {
        /* uint curLanguage = [[SDK instance] retrieveCurrentLanguage];
         WifiCamAlertTable *language = [_ctrl.propCtrl prepareDataForLanguage:curLanguage];
         
         if (language.array) {
         table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetLanguage", @""),
         @(SettingTableDetailTextLabel):[_ctrl.propCtrl calcLanguage:curLanguage],
         @(SettingTableDetailType):@(SettingDetailTypeLanguage),
         @(SettingTableDetailData):language.array,
         @(SettingTableDetailLastItem):@(language.lastIndex)};
         }*/
    }
    return table;
}

/*- (NSDictionary *)NovatekPhotoExposureCompensationTable:(int)ModelName
{
    NSDictionary *table = nil;

    uint curExposureCompensation = [[self.NVTSettingValueDict objectForKey:@"2005"] intValue];
    WifiCamAlertTable *ec = [self NvtprepareDataForPhotoExposureCompensation:curExposureCompensation];
        if (ec.array) {
            table = @{@(SettingTableTextLabel):NSLocalizedString(@"SetExposureCompensation", @""),
                      @(SettingTableDetailTextLabel):[self NvtcalcExposureCompensationValue:curExposureCompensation Model:ModelName],
                      @(SettingTableDetailType):@(SettingDetailTypePhotoExposureCompensation),
                      @(SettingTableDetailData):ec.array,
                      @(SettingTableDetailLastItem):@(ec.lastIndex)};
        }

    
    return table;
}*/


/*-(NSDictionary *)NovatekVideoSizeTable:(int)ModelName
{
    NSDictionary *table = nil;
    WifiCamAlertTable *vsArray;
    NSDictionary *videoSizeTable;
    uint curVideoSize;
    
    curVideoSize = [[self.NVTSettingValueDict objectForKey:@"2002"] intValue];
    if(ModelName == CARDV312GW)
    {
        vsArray = [self NvtprepareDataForVideoSize:curVideoSize Item:3 Model:ModelName];
    }
    
    //vfl = [_ctrl.propCtrl prepareDataForVideoFileLength:curVideoFileLength];
    if (vsArray.array) {
        table = @{@(SettingTableTextLabel):NSLocalizedString(@"ALERT_TITLE_SET_VIDEO_RESOLUTION", @""),
                  @(SettingTableDetailTextLabel):[self NvtcalcVideoSize:curVideoSize Model:ModelName],
                  @(SettingTableDetailType):@(SettingDetailTypeVideoSize),
                  @(SettingTableDetailData):vsArray.array,
                  @(SettingTableDetailLastItem):@(vsArray.lastIndex)};
    }
}*/

- (WifiCamAlertTable *)NvtprepareDataForDeviceSounds
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    
    
    TAA.array = [[NSMutableArray alloc] init];
    int i = 0;
    NSString *s = nil;
    
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1 ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W)
    {
        for (i = 0 ; i <= 1 ; i++) {
            s = [self NvtcalcDeviceSounds:i];
            
            if (s) {
                [TAA.array addObject:s];
            }
        }
    }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        for (i = 0 ; i <= 1 ; i++) {
            s = [self NvtcalcDeviceSounds:i];
            
            if (s) {
                [TAA.array addObject:s];
            }
        }
    }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
            [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
    {
        for (i = 0 ; i <= 2 ; i++) {
            s = [self NvtcalcDeviceSounds:i];
            
            if (s) {
                [TAA.array addObject:s];
            }
        }
    }
    else
    {
        for (i = 0 ; i <= 1 ; i++) {
            s = [self NvtcalcDeviceSounds:i];
            
            if (s) {
                [TAA.array addObject:s];
            }
        }
    }
    
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    return TAA;
}

-(WifiCamAlertTable *)NvtprepareDataForResetAll
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDVFLs = (vector<uint>)2;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    //AppLogInfo(AppLogTagAPP, @"curVideoSize: %d", curVideoSize);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
        
        s = [self NvtcalcResetAll:i];
        
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        //if (i == curVideoSize && !InvalidSelectedIndex) {
        //    TAA.lastIndex = i;
        //    InvalidSelectedIndex = YES;
        //}
    }
    
    if (!InvalidSelectedIndex) {
        AppLogError(AppLogTagAPP, @"Undefined Number");
        TAA.lastIndex = UNDEFINED_NUM;
    }
    
    
    return TAA;
}
-(WifiCamAlertTable *)NvtprepareDataForVideoSize:(uint)curVideoSize Item:(int)total Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDVFLs = (vector<uint>)total;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curVideoSize: %d", curVideoSize);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {

        s = [self NvtcalcVideoSize:i Model:ModelName];

        
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
- (WifiCamAlertTable *)NvtprepareDataForPasswordChange
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDAPs =(vector<uint>)3;
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
    int i = 0;
    NSString *s = nil;
    
    for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
        s = @"";
        
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
- (WifiCamAlertTable *)NvtprepareDataForCountry:(uint)curCountry
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    BOOL InvalidSelectedIndex = NO;
    
    vector<uint> vDAPs =(vector<uint>)14;
    
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
-(WifiCamAlertTable *)NvtprepareDataForVideoFileLength:(uint)curVideoFileLength Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    vector<uint> vDVFLs;
    BOOL InvalidSelectedIndex = NO;
    
    if(ModelName == C1GW)
    {
        vDVFLs = (vector<uint>)3;
    }
    else if(ModelName == CARDV312GW)
    {
        vDVFLs = (vector<uint>)3;
    }
    else
    {
        vDVFLs = (vector<uint>)3;
    }

    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curVideoFileLength: %d", curVideoFileLength);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
        s = [self NvtcalcVideoFileLength:i Model:ModelName];
        
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
-(WifiCamAlertTable *)NvtprepareDataForAutoPowerOff:(uint)curAutoPowerOff Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    vector<uint> vDVFLs;
    BOOL InvalidSelectedIndex = NO;
    
    if(ModelName == CARDV312GW)
    {
        vDVFLs = (vector<uint>)3;
    }
    else
    {
        vDVFLs = (vector<uint>)3;
    }
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curAutoPowerOff: %d", curAutoPowerOff);
    for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
        s = [self NvtcalcAutoPowerOffValue:i Model:ModelName];
        
        if (s) {
            [TAA.array addObject:s];
        }
        
        if (i == curAutoPowerOff && !InvalidSelectedIndex) {
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
- (WifiCamAlertTable *)NvtprepareDataForLanguage:(uint)curLanguage Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    vector<uint> vDAPs;
    BOOL InvalidSelectedIndex = NO;
    
    if(ModelName == C1GW)
    {
        vDAPs = (vector<uint>)3;
    }
    else if(ModelName == CARDV312GW)
    {
        vDAPs = (vector<uint>)10;
    }
    else if(ModelName == KVDR300W || ModelName == KVDR400W ||
            ModelName == DRVA301W || ModelName == DRVA401W ||
            ModelName == KVDR500W || ModelName == DRVA501W ||
            ModelName == DRVA700W) {
        vDAPs = (vector<uint>)11;
    }
    else
    {
        vDAPs = (vector<uint>)3;
    }
    
    TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
    int i = 0;
    NSString *s = nil;
    
    AppLogInfo(AppLogTagAPP, @"curLanguage: %d", curLanguage);
    for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
        s = [self NvtcalcLanguage:i Model:ModelName];
        
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
/*- (WifiCamAlertTable *)NvtprepareDataForPhotoExposureCompensation:(uint)curExposureCompensation
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
}*/
- (NSString *)NvtcalcResetAll:(uint)curResetAll
{
    if(curResetAll == 0)
    {
        return [delegate getStringForKey:@"SetRestoreDefaults_OK" withTable:@""];
    }
    else
    {
        return [delegate getStringForKey:@"SetRestoreDefaults_Cancel" withTable:@""];
    }
    
}
- (NSString *)NvtcalcVideoSize:(uint)curVideoSize Model:(int)ModelName
{
    if(ModelName == CARDV312GW)
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080P"];
        }
        else if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"720P"];
        }
        else if(curVideoSize == 2)
        {
            return [NSString stringWithFormat:@"720P 60FPS"];
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else if(ModelName == C1GW)
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080P 30FPS"];
        }
        else if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"720P 60FPS"];
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else if(ModelName == KVDR300W || ModelName == KVDR400W ||
            ModelName == DRVA301W || ModelName == DRVA401W)
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080P 30FPS"];
        }
        else if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"720P 60FPS"];
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else if(ModelName == KVDR500W || ModelName == DRVA501W ||
            ModelName == DRVA700W)
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080p 30fps Dual"];
        }
        else if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"1440p 30fps"];
        }
        else if(curVideoSize == 2)
        {
            return [NSString stringWithFormat:@"1080p 30fps"];
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080P 30FPS"];
        }
        else if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"720P 60FPS"];
        }
        else
        {
            return [NSString stringWithFormat:@"", curVideoSize];
        }
    }
}

- (NSString *)NvtcalcExposureCompensationValue:(uint)curExposureCompensation Model:(int)ModelName
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
    
    return [prefix stringByAppendingFormat:@"%d", value];
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
        return [delegate getStringForKey:@"unlimited" withTable:@""];
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcAutoPowerOffValue:(uint)curAutoPowerOff Model:(int)ModelName
{
    if(ModelName == CARDV312GW)
    {
        if(curAutoPowerOff == 0)
        {
            return [NSString stringWithFormat:@"%@", [delegate getStringForKey:@"SetAutoPowerOff10Sec" withTable:@""]];
        }
        else if(curAutoPowerOff == 1)
        {
            return [NSString stringWithFormat:@"%@", [delegate getStringForKey:@"SetAutoPowerOff2Mins" withTable:@""]];
        }
        else if(curAutoPowerOff == 2)
        {
            return [NSString stringWithFormat:@"%@", [delegate getStringForKey:@"SetAutoPowerOff5Mins" withTable:@""]];
        }
        else
        {
            return [delegate getStringForKey:@"unlimited" withTable:@""];
        }
    }
    else
    {
         return [delegate getStringForKey:@"unlimited" withTable:@""];
    }

    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcGSensorValue:(uint)curGSensor
{
    if(curGSensor == 0)
    {
        return [delegate getStringForKey:@"SetVideoGsensorHigh" withTable:@""];
    }
    else if(curGSensor == 1)
    {
        return [delegate getStringForKey:@"SetVideoGsensorMedium" withTable:@""];
    }
    else if(curGSensor == 2)
    {
        return [delegate getStringForKey:@"SetVideoGsensorLow" withTable:@""];
    }
    else if(curGSensor == 3)
    {
        return [delegate getStringForKey:@"SetSettingOFF" withTable:@""];
    }
    else
    {
        return [delegate getStringForKey:@"unlimited" withTable:@""];
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcLicenseDateTimeValue:(string)curDateTime
{
    return [NSString stringWithFormat:@"%s",curDateTime.c_str()];
}
- (NSString *)NvtcalcLicensePlateStampValue:(string)curLicensePlateStamp
{
    return [NSString stringWithFormat:@"%s",curLicensePlateStamp.c_str()];
}
- (NSString *)NvtcalcVideoFileLength:(uint)curVideoFileLength Model:(int)ModelName
{
    // NSString *Str;
    if(ModelName == C1GW || ModelName == KVDR300W || ModelName == KVDR400W ||
       ModelName == KVDR500W || ModelName == DRVA301W ||
       ModelName == DRVA401W || ModelName == DRVA501W ||
       ModelName == DRVA700W)
    {
        if(curVideoFileLength == 0)
        {
            //  Str = [NSString stringWithFormat:@"%d Minute", 1];
            return [delegate getStringForKey:@"SetSeamLess_1Minutes" withTable:@""];
        }
        else if(curVideoFileLength == 1)
        {
            return [delegate getStringForKey:@"SetSeamLess_3Minutes" withTable:@""];
        }
        else if(curVideoFileLength == 2)
        {
            return [delegate getStringForKey:@"SetSeamLess_5Minutes" withTable:@""];
        }
        else
        {
            return [NSString stringWithFormat:@"%d Minutes", curVideoFileLength];
        }
    }
    else if(ModelName == CARDV312GW)
    {
        if(curVideoFileLength == 0)
        {
            //  Str = [NSString stringWithFormat:@"%d Minute", 1];
            return [delegate getStringForKey:@"SetSeamLess_2Minutes" withTable:@""];
        }
        else if(curVideoFileLength == 1)
        {
            return [delegate getStringForKey:@"SetSeamLess_3Minutes" withTable:@""];
        }
        else if(curVideoFileLength == 2)
        {
            return [delegate getStringForKey:@"SetSeamLess_5Minutes" withTable:@""];
        }
        else
        {
            return [NSString stringWithFormat:@"%d Minutes", curVideoFileLength];
        }
    }
    else
    {
         return [NSString stringWithFormat:@"%d Minutes", curVideoFileLength];
    }
}
- (NSString *)NvtcalcSDFormatValue:(uint)curFormat
{
    if(curFormat == 1)
    {
        return [delegate getStringForKey:@"SetFormatSDCard_OK" withTable:@""];
    }
    else if(curFormat == 2)
    {
        return [delegate getStringForKey:@"SetFormatSDCard_Cancel" withTable:@""];
    }
    else
    {
        return [delegate getStringForKey:@"unlimited" withTable:@""];
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)NvtcalcLanguage:(uint)curLanguage Model:(int)ModelName
{
    if(ModelName == C1GW)
    {
        if (0 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageEnglish" withTable:@""];
        }
        else if(1 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageCn" withTable:@""];
        }
        else if(2 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageZh" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@"%ds", curLanguage];
        }
    }
    else if(ModelName == CARDV312GW)
    {
        if (0 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageEnglish" withTable:@""];
        }
        else if(1 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageDa" withTable:@""];
        }
        else if(2 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageGerman" withTable:@""];
        }
        else if(3 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageSpanish" withTable:@""];
        }
        else if(4 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageFrench" withTable:@""];
        }
        else if(5 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageItalian" withTable:@""];
        }
        else if(6 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageDutch" withTable:@""];
        }
        else if(7 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageNorway" withTable:@""];
        }
        else if(8 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageFinnish" withTable:@""];
        }
        else if(9 == curLanguage){
            return [delegate getStringForKey:@"SetLanguageSwedish" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@"%ds", curLanguage];
        }
    } else if(ModelName == KVDR300W || ModelName == KVDR400W ||                                                     ModelName == DRVA301W || ModelName == DRVA401W ||
              ModelName == KVDR500W || ModelName == DRVA501W ||
              ModelName == DRVA700W) {
        if (0 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageEnglish" withTable:@""];
        }
        else if (1 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageGerman" withTable:@""];
        }
        else if (2 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageFrench" withTable:@""];
        }
        else if (3 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageDutch" withTable:@""];
        }
        else if (4 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageItalian" withTable:@""];
        }
        else if (5 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageSpanish" withTable:@""];
        }
        else if (6 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguagePortuguese" withTable:@""];
        }
        else if (7 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageRussia" withTable:@""];
        }
        else if (8 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguagePolish" withTable:@""];
        }
        else if (9 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageCzech" withTable:@""];
        }
        else if (10 == curLanguage) {
            return [delegate getStringForKey:@"SetLanguageRomanian" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@"%ds", curLanguage];
        }
    }
    else
    {
          return [NSString stringWithFormat:@"%ds", curLanguage];
    }
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
-(NSString *)NvtcalcCountry:(uint)curCountry
{
    if (United_State == curCountry) {
        return [delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""];
    }
    else if(Canada == curCountry){
        return [delegate getStringForKey:@"SetCountry_Canada" withTable:@""];
    }
    else if(Russia == curCountry){
        return [delegate getStringForKey:@"SetCountry_Russia" withTable:@""];
    }
    else if(Spain == curCountry){
        return [delegate getStringForKey:@"SetCountry_Spain" withTable:@""];
    }
    else if(Germany == curCountry){
        return [delegate getStringForKey:@"SetCountry_Germany" withTable:@""];
    }
    else if(France == curCountry){
        return [delegate getStringForKey:@"SetCountry_France" withTable:@""];
    }
    else if(Italy == curCountry){
        return [delegate getStringForKey:@"SetCountry_Italy" withTable:@""];
    }
    else if(Netherlands == curCountry){
        return [delegate getStringForKey:@"SetCountry_Netherlands" withTable:@""];
    }
    else if(Belgium == curCountry){
        return [delegate getStringForKey:@"SetCountry_Belgium" withTable:@""];
    }
    else if(Poland == curCountry){
        return [delegate getStringForKey:@"SetCountry_Poland" withTable:@""];
    }
    else if(Czech == curCountry){
        return [delegate getStringForKey:@"SetCountry_Czech" withTable:@""];
    }
    else if(Romania == curCountry){
        return [delegate getStringForKey:@"SetCountry_Romania" withTable:@""];
    }
    else if(UnitedKingdom == curCountry){
        return [delegate getStringForKey:@"SetCountry_UnitedKingdom" withTable:@""];
    }
    else if(Other == curCountry){
        return [delegate getStringForKey:@"SetCountry_Other" withTable:@""];
    }
    else if(CountryMax == curCountry){
        return [delegate getStringForKey:@"SetCountry_Other" withTable:@""];
    }
    else {
        return [NSString stringWithFormat:@""];
    }
}
-(NSString *)NvtDetailcalcCountry:(uint)curCountry
{
    if (0 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStateEST" withTable:@""];
    else if(1 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStateCST" withTable:@""];
    else if(2 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStateMST" withTable:@""];
    else if(3 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStatePST" withTable:@""];
    else if(4 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStateAKST" withTable:@""];
    else if(5 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedStateHST" withTable:@""];
    else if(6 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaNST" withTable:@""];
    else if(7 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaAST" withTable:@""];
    else if(8 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaEST" withTable:@""];
    else if(9 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaCST" withTable:@""];
    else if(10 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaMST" withTable:@""];
    else if(11 == curCountry)
        return [delegate getStringForKey:@"SetCountry_CanadaPST" withTable:@""];
    else if(12 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaKALT" withTable:@""];
    else if(13 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaMSK" withTable:@""];
    else if(14 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaSAMT" withTable:@""];
    else if(15 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaYEKT" withTable:@""];
    else if(16 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaOMST" withTable:@""];
    else if(17 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaKRAT" withTable:@""];
    else if(18 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaIRKT" withTable:@""];
    else if(19 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaYAKT" withTable:@""];
    else if(20 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaVLAT" withTable:@""];
    else if(21 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaMAGT" withTable:@""];
    else if(22 == curCountry)
        return [delegate getStringForKey:@"SetCountry_RussiaPETT" withTable:@""];
    else if(23 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Spain" withTable:@""];
    else if(24 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Germany" withTable:@""];
    else if(25 == curCountry)
        return [delegate getStringForKey:@"SetCountry_France" withTable:@""];
    else if(26 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Italy" withTable:@""];
    else if(27 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Netherlands" withTable:@""];
    else if(28 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Belgium" withTable:@""];
    else if(29 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Poland" withTable:@""];
    else if(30 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Czech" withTable:@""];
    else if(31 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Romania" withTable:@""];
    else if(32 == curCountry)
        return [delegate getStringForKey:@"SetCountry_UnitedKingdom" withTable:@""];
    else if(33 == curCountry)
        return [delegate getStringForKey:@"SetCountry_Other" withTable:@""];
    else {
        return [NSString stringWithFormat:@""];
    }
}
- (NSString *)NvtcalcDeviceSounds:(uint)curDeviceSounds
{
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
    {
        if (0 == curDeviceSounds) {
            return [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
        }
        else if(1 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
        }
        else if(2 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_Announcements" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@""];
        }
    }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        if(0 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
        }
        else if(1 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_Announcements" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@""];
        }
    } else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
              [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1 ||
              [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
              [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
              [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
              [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W)
    {
        if (0 == curDeviceSounds) {
            return [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
        }
        else if(1 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@""];
        }
    }
    else
    {
        if (0 == curDeviceSounds) {
            return [delegate getStringForKey:@"SetDeviceSounds_Beep" withTable:@""];
        }
        else if(1 == curDeviceSounds){
            return [delegate getStringForKey:@"SetDeviceSounds_AudioRec" withTable:@""];
        }
        else {
            return [NSString stringWithFormat:@""];
        }
    }
}
- (NSString *)NvtcalcScreenSaverTime:(uint)curScreenSaver
{
    if (curScreenSaver == 0) {
        return [delegate getStringForKey:@"SetSettingOFF" withTable:@""];
    }
    else if(curScreenSaver == 1)
    {
        return [delegate getStringForKey:@"SetScreenSaver_30Seconds" withTable:@""];
    }
    else if(curScreenSaver == 2)
    {
        return [delegate getStringForKey:@"SetScreenSaver_2Minutes" withTable:@""];
    }
    else {
        return [NSString stringWithFormat:@"%ds", curScreenSaver];
    }
}

- (void)back {
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)goBack:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)VideoAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.titlelabel.text = [delegate getStringForKey:@"VideoMenu" withTable:@""];
    [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_video"]];
    
    if(self.VideoModeBtn.selected == 0)
    {
        [self.pageControl setCurrentPage:0];
        [self.ScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}
- (IBAction)PhotoAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.titlelabel.text = [delegate getStringForKey:@"PhotoMenu" withTable:@""];
    [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_camera"]];
    
    if(self.PhotoModeBtn.selected == 0)
    {
        [self.pageControl setCurrentPage:1];
        [self.ScrollView setContentOffset:CGPointMake(self.pageControl.currentPage*CGRectGetWidth(self.view.frame), 0) animated:YES];
    }
}
- (IBAction)SetupAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    self.titlelabel.text = [delegate getStringForKey:@"SetupMenu" withTable:@""];
    [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_setting"]];
    
    if(self.SetupModeBtn.selected == 0)
    {
        [self.pageControl setCurrentPage:2];
        [self.ScrollView setContentOffset:CGPointMake(self.pageControl.currentPage*CGRectGetWidth(self.view.frame), 0) animated:YES];
    }
}
// UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:[UITableView class]])
    {
        //NSLog(@"-------是列表");
    }
    else
    {
        //NSLog(@"-------是視圖");
        if (scrollView == self.ScrollView) {
            NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
            if(pageIndex == 0)
            {
                self.titlelabel.text = [delegate getStringForKey:@"VideoMenu" withTable:@""];
                [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_video"]];
            }
            else if(pageIndex == 1)
            {
                self.titlelabel.text = [delegate getStringForKey:@"PhotoMenu" withTable:@""];
                [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_camera"]];
            }
            else if(pageIndex == 2)
            {
                self.titlelabel.text = [delegate getStringForKey:@"SetupMenu" withTable:@""];
                [self.titleImage setImage:[UIImage imageNamed:@"control_dashcamsetting_setting"]];
            }
            //NSLog(@"pageIndex = %ld",(long)pageIndex);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if([scrollView isKindOfClass:[UITableView class]])
    {
        //NSLog(@"-------是列表");
    }
    else
    {
        //NSLog(@"-------是視圖");
        if (scrollView == self.ScrollView) {
            //NSLog(@"scrollView.contentOffset.x = %f",scrollView.contentOffset.x);
            NSInteger pageIndex = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
            self.pageControl.currentPage = pageIndex;
            if(self.pageControl.currentPage == 0)
            {
                self.VideoModeBtn.selected = 1;
                self.PhotoModeBtn.selected = 0;
                self.SetupModeBtn.selected = 0;
            }
            else if(self.pageControl.currentPage == 1)
            {
                self.VideoModeBtn.selected = 0;
                self.PhotoModeBtn.selected = 1;
                self.SetupModeBtn.selected = 0;
            }
            else if(self.pageControl.currentPage == 2)
            {
                self.VideoModeBtn.selected = 0;
                self.PhotoModeBtn.selected = 0;
                self.SetupModeBtn.selected = 1;
            }
            //NSLog(@"pageIndex = %ld",(long)pageIndex);
        }
    }
}



// UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   if (tableView == self.VideoTable) {
       return [[self.VideoMenuTableArray objectAtIndex:0] count];
   }
    else if(tableView == self.PhotoTable)
    {
         return [[self.PhotoMenuTableArray objectAtIndex:0] count];
    }
    else
    {
        return [[self.SetupMenuTableArray objectAtIndex:0] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    VideoSettingTableViewCell *cellVideo = nil;
    PhotoSettingTableViewCell *cellPhoto = nil;
    SetupSettingTableViewCell *cellSetup = nil;
    
    if(tableView == self.VideoTable)
    {
        cellVideo = [tableView dequeueReusableCellWithIdentifier:@"VideoSetting" forIndexPath:indexPath];
        //cellVideo.VideoItemLabel.text = @"Video";
        cellVideo.selectionStyle = UITableViewCellSelectionStyleNone;
        [self ConfigSwitchVideo:[self.SSIDSreial MatchSSIDReturn:self.SSID] Cell:cellVideo Item:[(_VideoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue]];

        
        NSDictionary *dict = [[self.VideoMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        
        cellVideo.VideoItemLabel.text = [dict objectForKey:@(SettingTableTextLabel)];

        cellVideo.VideoDetailLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        
        
        
        return cellVideo;
    }
    else if(tableView == self.PhotoTable)
    {
        cellPhoto = [tableView dequeueReusableCellWithIdentifier:@"PhotoSetting" forIndexPath:indexPath];
        cellPhoto.selectionStyle = UITableViewCellSelectionStyleNone;
        
         [self ConfigSwitchPhoto:[self.SSIDSreial MatchSSIDReturn:self.SSID] Cell:cellPhoto Item:[(_PhotoMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue]];
        
        
        NSDictionary *dict = [[self.PhotoMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        
        cellPhoto.PhotoItemLabel.text = [dict objectForKey:@(SettingTableTextLabel)];
        
        cellPhoto.PhotoDetailLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        return cellPhoto;
    }
    else
    {
        cellSetup = [tableView dequeueReusableCellWithIdentifier:@"SetupSetting" forIndexPath:indexPath];
        cellSetup.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self ConfigSwitchSetup:[self.SSIDSreial MatchSSIDReturn:self.SSID] Cell:cellSetup Item:[(_SetupMenuSettingTable[indexPath.row])[@(SettingTableDetailType)] intValue]];
        

        NSDictionary *dict = [[self.SetupMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        NSAssert1([dict isKindOfClass:[NSDictionary class]], @"Object dict isn't an NSDictionary", nil);
        
        cellSetup.SetupItemLabel.text = [dict objectForKey:@(SettingTableTextLabel)];
        
        cellSetup.SetupDetailLabel.text = [dict objectForKey:@(SettingTableDetailTextLabel)];
        return cellSetup;
    }
}

- (NSIndexPath *) tableView               :(UITableView *)tableView
                  willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict;
    if(tableView == self.VideoTable)
    {
        dict = [[_VideoMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else if(tableView == self.PhotoTable)
    {
        dict = [[_PhotoMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    else if(tableView == self.SetupTable)
    {
        dict = [[_SetupMenuTableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [_subMenuTable setArray:[dict objectForKey:@(SettingTableDetailData)]];
    _curSettingDetailType = [[dict objectForKey:@(SettingTableDetailType)] integerValue];
    
    _curSettingDetailItem = [[dict objectForKey:@(SettingTableDetailLastItem)] integerValue];
    
    return indexPath;
}

- (void)tableView               :(UITableView *)tableView
        didSelectRowAtIndexPath :(NSIndexPath *)indexPath
{
    //取消cell的選中狀態
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_curSettingDetailType == SettingDetailTypeDateTime)
    {
        [self chooseDate];
    }
    else
    {
        if([self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200GW ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200 ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200GW ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200)
        {
            if(_curSettingDetailType != SettingDetailTypeNvtDeviceSounds&&
               _curSettingDetailType != SettingDetailTypeNvtParkingModeSensor&&
               _curSettingDetailType != SettingDetailTypeUltraDashStamp&&
               _curSettingDetailType != SettingDetailTypeAudioRecording&&
               _curSettingDetailType != SettingDetailTypePhotoTimeAndDateStamp &&
               _curSettingDetailType != SettingDetailTypeInformationStamp&&
               _curSettingDetailType != SettingDetailTypeTimeAndDateStamp)
            {
                [self performSegueWithIdentifier:@"goSubMenu" sender:self];
            }
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1 ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
        {
            if(_curSettingDetailType != SettingDetailTypeNvtGPS&&
               _curSettingDetailType != SettingDetailTypeNvtParkingModeSensor&&
               _curSettingDetailType != SettingDetailTypeUltraDashStamp&&
               _curSettingDetailType != SettingDetailTypePhotoTimeAndDateStamp &&
               _curSettingDetailType != SettingDetailTypeInformationStamp&&
               _curSettingDetailType != SettingDetailTypeTimeAndDateStamp&&
               _curSettingDetailType != SettingDetailTypeRotateDisplay)
            {
                [self performSegueWithIdentifier:@"goSubMenu" sender:self];
            }
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
        {
            if(_curSettingDetailType != SettingDetailTypeNvtGPS &&
               _curSettingDetailType != SettingDetailTypeTimeAndDateStamp&&
               _curSettingDetailType !=  SettingDetailTypeTimeAndDateStamp&&
               _curSettingDetailType !=  SettingDetailTypePhotoTimeAndDateStamp&&
               _curSettingDetailType != SettingDetailTypeNvtParkingModeSensor&&
               _curSettingDetailType != SettingDetailTypeSpeedStamp &&
               _curSettingDetailType != SettingDetailTypeDeviceSounds &&
               _curSettingDetailType != SettingDetailTypeScreenSaver
               )
            {
                [self performSegueWithIdentifier:@"goSubMenu" sender:self];
            }
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
        {
            if(_curSettingDetailType != SettingDetailTypeGPS&&
               _curSettingDetailType != SettingDetailTypeUltraDashStamp&&
               _curSettingDetailType != SettingDetailTypeTimeAndDateStamp&&
               _curSettingDetailType != SettingDetailTypeInformationStamp&&
               _curSettingDetailType != SettingDetailTypePhotoTimeAndDateStamp&&
               _curSettingDetailType != SettingDetailTypeParkingModeSensor&&
               _curSettingDetailType != SettingDetailTypeRotateDisplay
               )
            {
                [self performSegueWithIdentifier:@"goSubMenu" sender:self];
            }
        }
    }
}
-(void)ConfigSwitchVideo:(int)ModelName Cell:(VideoSettingTableViewCell *)cell Item:(int)item
{
    if(ModelName == C1GW || ModelName == KVDR300W || ModelName == KVDR400W ||
       ModelName == KVDR500W || ModelName == DRVA301W ||
       ModelName == DRVA401W || ModelName == DRVA501W ||
       ModelName == DRVA700W)
    {
        switch(item)
        {
            case SettingDetailTypeNvtGPS:
                [cell.SwitchViewer addTarget:self action:@selector(updateNvtGPSSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3200"] intValue];
                 cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeNvtParkingModeSensor:
                [cell.SwitchViewer addTarget:self action:@selector(updateParkingModeSensorSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3102"] intValue];
                 cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeUltraDashStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateUltraDashStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3106"] intValue];
                 cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeTimeAndDateStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"2008"] intValue];
                 cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeInformationStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateInformationStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3105"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    }
    else if(ModelName == CARDV312GW)
    {
        switch(item)
        {
            case SettingDetailTypeNvtGPS:
                [cell.SwitchViewer addTarget:self action:@selector(updateNvtGPSSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3105"] intValue];
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeNvtParkingModeSensor:
                [cell.SwitchViewer addTarget:self action:@selector(updateParkingModeSensorSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3102"] intValue];
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeTimeAndDateStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"2008"] intValue];
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeSpeedStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateSpeedStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3104"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    }
    else if(ModelName == DRVA601W || ModelName == KVDR600W)
    {
        switch(item)
        {
            case SettingDetailTypeParkingModeSensor:
                [cell.SwitchViewer addTarget:self action:@selector(updateParkingModeSensorSwitch:) forControlEvents:UIControlEventValueChanged];
                
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_ParkingModeSensor]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeGPS:
                [cell.SwitchViewer addTarget:self action:@selector(updateNvtGPSSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_GPS]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeTimeAndDateStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_TimeAndDateStamp]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeUltraDashStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateUltraDashStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_UltraDashStamp]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeInformationStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updateInformationStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_InformationStamp]-1);
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    }
}

-(void)ConfigSwitchPhoto:(int)ModelName Cell:(PhotoSettingTableViewCell *)cell Item:(int)item
{
    if(ModelName == CARDV312GW || ModelName == KVDR300W || ModelName == KVDR400W ||
       ModelName == KVDR500W || ModelName == DRVA301W ||
       ModelName == DRVA401W || ModelName == DRVA501W ||
       ModelName == DRVA700W)
    {
        switch(item)
        {
            case SettingDetailTypePhotoTimeAndDateStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updatePhotoTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3108"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    } else if(ModelName == DRVA601W || ModelName == KVDR600W) {
        switch(item)
        {
            case SettingDetailTypePhotoTimeAndDateStamp:
                [cell.SwitchViewer addTarget:self action:@selector(updatePhotoTimeAndDateStampSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_PhotoTimeAndDateStamp]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
        
    }
}

-(void)ConfigSwitchSetup:(int)ModelName Cell:(SetupSettingTableViewCell *)cell Item:(int)item
{
    if(ModelName == CARDV312GW)
    {
        switch(item)
        {
            case SettingDetailTypeScreenSaver:
                [cell.SwitchViewer addTarget:self action:@selector(updateScreenSaveSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3113"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            case SettingDetailTypeDeviceSounds:
                [cell.SwitchViewer addTarget:self action:@selector(updateDeviceSoundSwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3115"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    } else if(ModelName == KVDR300W || ModelName == KVDR400W ||
              ModelName == KVDR500W || ModelName == DRVA301W ||
              ModelName == DRVA401W || ModelName == DRVA501W ||
              ModelName == DRVA700W) {
        switch(item)
        {
            case SettingDetailTypeRotateDisplay:
                [cell.SwitchViewer addTarget:self action:@selector(updateRotateDisplaySwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = ![[self.NVTSettingValueDict objectForKey:@"3103"] intValue];
                
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle =UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
        
    } else if(ModelName == DRVA601W || ModelName == KVDR600W) {
        switch(item)
        {
            case SettingDetailTypeRotateDisplay:
                [cell.SwitchViewer addTarget:self action:@selector(updateRotateDisplaySwitch:) forControlEvents:UIControlEventValueChanged];
                cell.SwitchViewer.on = !([[SDK instance] getCustomizePropertyIntValue:CustomizePropertyID_RotateDisplay]-1);
                cell.SwitchViewer.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewControlleVidr].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"goSubMenu"]) {
        CustomSettingSubViewController *detail = [segue destinationViewController];
        
        detail.subMenuTable = _subMenuTable;
        detail.curSettingDetailType = _curSettingDetailType;
        detail.curSettingDetailItem = _curSettingDetailItem;
        if(self.VideoModeBtn.selected)
        {
            detail.curState = 0;
        }
        else if(self.PhotoModeBtn.selected)
        {
            detail.curState = 1;
        }
        else
        {
            detail.curState = 2;
        }
    }
}
-(void) datePickerDateChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    
    
    NSString *date = [formatter stringFromDate:datePicker.date];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        _DatePickerStringDate = date;
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        _DatePickerStringDate = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    //NSLog(@"DatePickerStringDate=====%@",_DatePickerStringDate);
}
-(void) datePickerTimeChanged:(UIDatePicker *)datePicker
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        formatter.dateFormat = @"HH:mm:ss";
        NSString *date = [formatter stringFromDate:datePicker.date];
        _DatePickerStringTime = date;
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        formatter.dateFormat = @"HH:mm";
        NSString *date = [formatter stringFromDate:datePicker.date];
        _DatePickerStringTime = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
        _DatePickerStringTime = [_DatePickerStringTime stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        _DatePickerStringTime = [_DatePickerStringTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        _DatePickerStringTime = [_DatePickerStringTime stringByAppendingString:@"00.0"];
    }
    //NSLog(@"DatePickerStringTime=====%@",_DatePickerStringTime);
}
- (IBAction)onClickButtonOfDateOK:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //formatter.dateFormat = @"yyyy-MM-dd";
    formatter.dateFormat = @"yyyy/MM/dd";
    
    
    NSString *date = [formatter stringFromDate:self.datePicker.date];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        _DatePickerStringDate = date;
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        _DatePickerStringDate = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    
    [self.DatePickerOK removeFromSuperview];
    [self.DatePickerCancel removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.DateStyle removeFromSuperview];
    [self.BtnLeftChoice removeFromSuperview];
    [self.BtnRightChoice removeFromSuperview];
    
    self.datePicker = [[UIDatePicker alloc] init];
    if([timeFormat  isEqual: @"12H"]) {//en_US en_GB
        self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    } else {
        self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    }
    
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.datePicker.frame = CGRectMake(0, self.view.bounds.size.height-150, self.view.bounds.size.width, 150);
    
    [[self view] addSubview:self.datePicker];
    [self.datePicker addTarget:self action:@selector(datePickerTimeChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.DatePickerOK = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-190, 60, 30)];
    self.DatePickerOK.backgroundColor = [UIColor whiteColor];
    self.DatePickerOK.layer.cornerRadius = 10.0;
    [self.DatePickerOK setTitle:[delegate getStringForKey:@"BtnOK" withTable:@""] forState:UIControlStateNormal];
    [self.DatePickerOK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.DatePickerOK addTarget:self action:@selector(onClickButtonOfTimeOK:) forControlEvents:UIControlEventTouchUpInside];
    
    self.DatePickerCancel = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height-190, 90, 30)];
    self.DatePickerCancel.backgroundColor = [UIColor whiteColor];
    self.DatePickerCancel.layer.cornerRadius = 10.0;
    [self.DatePickerCancel setTitle:[delegate getStringForKey:@"BtnCancel" withTable:@""] forState:UIControlStateNormal];
    [self.DatePickerCancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.DatePickerCancel addTarget:self action:@selector(onClickButtonOfCancle:) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:self.DatePickerOK];
    [[self view] addSubview:self.DatePickerCancel];
    
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        _DatePickerStringDate = [_DatePickerStringDate stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        [self NVTSendHttpStringCmd:@"3005" Par2:_DatePickerStringDate];
    }
}
- (IBAction)onClickButtonOfTimeOK:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        //formatter.dateFormat = @"HH:mm:ss";
        formatter.dateFormat = @"HH:mm";
        NSString *date = [formatter stringFromDate:self.datePicker.date];
        _DatePickerStringTime = date;
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        formatter.dateFormat = @"HH:mm";
        NSString *date = [formatter stringFromDate:self.datePicker.date];
        _DatePickerStringTime = [date stringByReplacingOccurrencesOfString:@"-" withString:@""];
        _DatePickerStringTime = [_DatePickerStringTime stringByReplacingOccurrencesOfString:@" " withString:@"T"];
        _DatePickerStringTime = [_DatePickerStringTime stringByReplacingOccurrencesOfString:@":" withString:@""];
        _DatePickerStringTime = [_DatePickerStringTime stringByAppendingString:@"00.0"];
    }
    [self.DatePickerOK removeFromSuperview];
    [self.DatePickerCancel removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.BackView removeFromSuperview];
    [self.TopView removeFromSuperview];
    [self.DateStyle removeFromSuperview];
    [self.BtnLeftChoice removeFromSuperview];
    [self.BtnRightChoice removeFromSuperview];
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        NSString *str = [NSString stringWithFormat:@"%@%@",_DatePickerStringTime,@":00"];
        [self NVTSendHttpStringCmd:@"3006" Par2:str];
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"LOAD_SETTING_DATA" withTable:@""]];
        
        /*if(buttonSettingIndex == 0)
            self.title = NSLocalizedString(@"VideoMenu", @"");
        else if(buttonSettingIndex == 1)
            self.title = NSLocalizedString(@"PhotoMenu", @"");
        else if(buttonSettingIndex == 2)
            self.title = NSLocalizedString(@"SettingMenu", @"");*/
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if([self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200GW ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200 ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200GW ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200)
            {
                [self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];
               // [self D200GWNvtfillMainMenuSettingTable:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == C1)
            {
                [self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];
                [self C1GWNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
            {
                [self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];
                [self DRVA301WNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
            {
                [self NVTGetHttpCmd:@"3014"];
                [self NVTGetHttpCmd:@"3118"];
                [self NVTGetHttpCmd:@"3119"];
                [self CARDV312GWNvtfillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
                    [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
            {
                //[self MenuSettingTableU2:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DUO_HD)
            {
                //[self MenuSettingTableDUOHD:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.VideoTable reloadData];
                [self.PhotoTable reloadData];
                [self.SetupTable reloadData];
                [self hideProgressHUD:YES];
            });
        });
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        NSString *str = [_DatePickerStringDate stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
        [self showProgressHUDWithMessage:[delegate getStringForKey:@"LOAD_SETTING_DATA" withTable:@""]];
        NSString *strcatDateMM;
        NSString *strcatDateDD;
        NSString *strcatDateYY;
        NSString *strcatDateTemp=@"";
        //NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        strcatDateMM = [_DatePickerStringDate substringWithRange:NSMakeRange(5,2)];
        strcatDateDD = [_DatePickerStringDate substringWithRange:NSMakeRange(8,2)];
        strcatDateYY = [_DatePickerStringDate substringWithRange:NSMakeRange(0,4)];
        self.TimeAndDate = [strcatDateTemp stringByAppendingFormat:@"%@%@%@T%@",strcatDateYY,strcatDateMM,strcatDateDD,_DatePickerStringTime];
        //NSLog(@"date2=====%@",self.TimeAndDate);
        
        [[SDK instance] setCustomizeStringProperty:CustomizePropertyID_DateTime value:self.TimeAndDate];
        if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
           [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
        {
            [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_DateStyle value:DateStyleChoose+1];
            DateStyleChoose = 0;
        }
        else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DUO_HD)
        {
            [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_DateStyle value:DateStyleChoose+1];
            DateStyleChoose = 0;
        }
        /*DateStyleChoose*/
        UIColor *myWhite = [[UIColor alloc]initWithRed:1 green:1 blue:1 alpha:1];
        self.view.backgroundColor = myWhite;
        /*if(buttonSettingIndex == 0)
            self.title = NSLocalizedString(@"VideoMenu", @"");
        else if(buttonSettingIndex == 1)
            self.title = NSLocalizedString(@"PhotoMenu", @"");
        else if(buttonSettingIndex == 2)
            self.title = NSLocalizedString(@"SettingMenu", @"");*/
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CANSONIC_U2 ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
            {
                [self K6fillMainMenuSettingTable:[self.SSIDSreial MatchSSIDReturn:self.SSID]];
                
                //[self MenuSettingTableU2:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DUO_HD)
            {
                //[self MenuSettingTableDUOHD:[SSIDSreial MatchSSIDReturn:self.SSID]];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.VideoTable reloadData];
                [self.PhotoTable reloadData];
                [self.SetupTable reloadData];
                [self hideProgressHUD:YES];
            });
        });
        
        
    }
    
    
}
- (IBAction)onClickButtonOfCancle:(id)sender {
    [self.DatePickerOK removeFromSuperview];
    [self.DatePickerCancel removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.BackView removeFromSuperview];
    [self.TopView removeFromSuperview];
    [self.DateStyle removeFromSuperview];
    [self.BtnLeftChoice removeFromSuperview];
    [self.BtnRightChoice removeFromSuperview];
    DateStyleChoose = 0;
    // UIColor *myWhite = [[UIColor alloc]initWithRed:1 green:1 blue:1 alpha:1];
}
- (IBAction)btnClickedOfLeftChoice:(id)sender {
    [self.DateStyle removeFromSuperview];
    if(DateStyleChoose == 2)
    {
        DateStyleChoose = 0;
    }
    else
    {
        DateStyleChoose++;
    }
    self.DateStyle = [[UITextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-70-65)/2, self.view.bounds.size.height-190, self.view.bounds.size.width-70-(self.view.bounds.size.width/4), 30)];
    self.DateStyle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if(DateStyleChoose == 0)
        self.DateStyle.placeholder = @"YYYY / MM / DD";
    else if(DateStyleChoose == 1)
        self.DateStyle.placeholder = @"YYYY / DD / MM";
    else if(DateStyleChoose == 2)
        self.DateStyle.placeholder = @"MM / DD / YYYY";
    [self.DateStyle setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.DateStyle.enabled = NO;
    [[self view] addSubview:self.DateStyle];
}
- (IBAction)btnClickedOfRightChoice:(id)sender {
    [self.DateStyle removeFromSuperview];
    if(DateStyleChoose == 0)
    {
        DateStyleChoose = 2;
    }
    else
    {
        DateStyleChoose--;
    }
    self.DateStyle = [[UITextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-70-65)/2, self.view.bounds.size.height-190, self.view.bounds.size.width-70-(self.view.bounds.size.width/4), 30)];
    self.DateStyle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if(DateStyleChoose == 0)
        self.DateStyle.placeholder = @"YYYY / MM / DD";
    else if(DateStyleChoose == 1)
        self.DateStyle.placeholder = @"MM / DD / YYYY";
    else if(DateStyleChoose == 2)
        self.DateStyle.placeholder = @"DD / MM / YYYY";
    [self.DateStyle setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.DateStyle.enabled = NO;
    [[self view] addSubview:self.DateStyle];
}
-(void)chooseDate
{
    [self.DatePickerOK removeFromSuperview];
    [self.DatePickerCancel removeFromSuperview];
    [self.datePicker removeFromSuperview];
    [self.BackView removeFromSuperview];
    [self.TopView removeFromSuperview];
    [self.DateStyle removeFromSuperview];
    [self.BtnLeftChoice removeFromSuperview];
    [self.BtnRightChoice removeFromSuperview];
    DateStyleChoose = 0;
#if 1
    self.datePicker = [[UIDatePicker alloc] init];
    UIColor *myBlack = [[UIColor alloc]initWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    UIColor *myTopColor = [[UIColor alloc]initWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.BackView = [[UIView alloc] init];
    self.BackView.backgroundColor = myBlack;
    self.BackView.frame = CGRectMake(0, self.view.bounds.size.height-200, self.view.bounds.size.width, 200);
    
    self.TopView = [[UIView alloc] init];
    self.TopView.backgroundColor = myTopColor;
    self.TopView.frame = CGRectMake(0, self.view.bounds.size.height-195, self.view.bounds.size.width, 40);
    
    self.datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    
    self.datePicker.frame = CGRectMake(0, self.view.bounds.size.height-150, self.view.bounds.size.width, 150);
    
    
    [[self view] addSubview:self.BackView];
    [[self view] addSubview:self.TopView];
    [[self view] addSubview:self.datePicker];
    
    
    [self.datePicker addTarget:self action:@selector(datePickerDateChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.DatePickerOK = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width-70, self.view.bounds.size.height-190, 60, 30)];
    self.DatePickerOK.backgroundColor = [UIColor whiteColor];
    self.DatePickerOK.layer.cornerRadius = 10.0;
    [self.DatePickerOK setTitle:[delegate getStringForKey:@"BtnOK" withTable:@""] forState:UIControlStateNormal];
    [self.DatePickerOK setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.DatePickerOK addTarget:self action:@selector(onClickButtonOfDateOK:) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.BtnLeftChoice = [[UIButton alloc] initWithFrame:CGRectMake(10, self.view.bounds.size.height-190, 20, 30)];
    [self.BtnLeftChoice setImage:[UIImage imageNamed:@"icon_left"] forState:UIControlStateNormal];
    [self.BtnLeftChoice addTarget:self action:@selector(btnClickedOfLeftChoice:) forControlEvents:UIControlEventTouchUpInside];
    
    self.BtnRightChoice = [[UIButton alloc] initWithFrame:CGRectMake(45, self.view.bounds.size.height-190, 20, 30)];
    [self.BtnRightChoice setImage:[UIImage imageNamed:@"icon_left"] forState:UIControlStateNormal];
    self.BtnRightChoice.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    [self.BtnRightChoice addTarget:self action:@selector(btnClickedOfRightChoice:) forControlEvents:UIControlEventTouchUpInside];
    
    self.DateStyle = [[UITextField alloc] initWithFrame:CGRectMake((self.view.bounds.size.width-70-65)/2, self.view.bounds.size.height-190, self.view.bounds.size.width-70-(self.view.bounds.size.width/4), 30)];
    self.DateStyle.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.DateStyle.placeholder = @"YYYY / MM / DD";
    [self.DateStyle setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.DateStyle.enabled = NO;
    [[self view] addSubview:self.DatePickerOK];
    [[self view] addSubview:self.BtnLeftChoice];
    [[self view] addSubview:self.BtnRightChoice];
    [[self view] addSubview:self.DateStyle];
    //[[self view] addSubview:self.DatePickerCancel];
    // [datePicker removeFromSuperview];
#endif
}



- (IBAction)updateNvtGPSSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint gpsValue;
     if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
        [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
     {
         if ([switchView isOn])
         {
             gpsValue = 0;
         }
         else
         {
             gpsValue = 1;
         }
         [self NVTSendHttpCmd:@"3200" Par2:[[NSString alloc] initWithFormat:@"%d",gpsValue]];
     }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
    {
        if ([switchView isOn])
        {
            gpsValue = 0;
        }
        else
        {
            gpsValue = 1;
        }
        [self NVTSendHttpCmd:@"3105" Par2:[[NSString alloc] initWithFormat:@"%d",gpsValue]];
    }
    else if([self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W ||
            [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W)
    {
        if ([switchView isOn])
        {
            gpsValue = 1;
        }
        else
        {
            gpsValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_GPS value:gpsValue];
    }
 
}
- (IBAction)updateParkingModeSensorSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint ParkingModeSensorValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        if ([switchView isOn])
        {
            ParkingModeSensorValue = 0;
        }
        else
        {
            ParkingModeSensorValue = 1;
        }
        [self NVTSendHttpCmd:@"3102" Par2:[[NSString alloc] initWithFormat:@"%d",ParkingModeSensorValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            ParkingModeSensorValue = 1;
        }
        else
        {
            ParkingModeSensorValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_ParkingModeSensor value:ParkingModeSensorValue];
    }
}
- (IBAction)updateTimeAndDateStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint TimeAndDateValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        if ([switchView isOn])
        {
            TimeAndDateValue = 0;
        }
        else
        {
            TimeAndDateValue = 1;
        }
        [self NVTSendHttpCmd:@"2008" Par2:[[NSString alloc] initWithFormat:@"%d",TimeAndDateValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            TimeAndDateValue = 1;
        }
        else
        {
            TimeAndDateValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_TimeAndDateStamp value:/*switchView.isOn*/TimeAndDateValue];
    }
}
- (IBAction)updatePhotoTimeAndDateStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint PhotoTimeAndDateStampValue;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if ([switchView isOn])
        {
            PhotoTimeAndDateStampValue = 0;
        }
        else
        {
            PhotoTimeAndDateStampValue = 1;
        }
        [self NVTSendHttpCmd:@"3108" Par2:[[NSString alloc] initWithFormat:@"%d",PhotoTimeAndDateStampValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            PhotoTimeAndDateStampValue = 1;
        }
        else
        {
            PhotoTimeAndDateStampValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_PhotoTimeAndDateStamp value:/*switchView.isOn*/PhotoTimeAndDateStampValue];
    }
}
- (IBAction)updateRotateDisplaySwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint RotateDisplayValue;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if ([switchView isOn])
        {
            RotateDisplayValue = 0;
        }
        else
        {
            RotateDisplayValue = 1;
        }
        [self NVTSendHttpCmd:@"3103" Par2:[[NSString alloc] initWithFormat:@"%d",RotateDisplayValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            RotateDisplayValue = 1;
        }
        else
        {
            RotateDisplayValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_RotateDisplay value:/*switchView.isOn*/RotateDisplayValue];
    }
}
- (IBAction)updateDeviceSoundSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint DeviceSoundValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == C1GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW )
    {
        if ([switchView isOn])
        {
            DeviceSoundValue = 0;
        }
        else
        {
            DeviceSoundValue = 1;
        }
        [self NVTSendHttpCmd:@"3115" Par2:[[NSString alloc] initWithFormat:@"%d",DeviceSoundValue]];
    }
}

- (IBAction)updateUltraDashStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint UltraDashStampValue;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if ([switchView isOn])
        {
            UltraDashStampValue = 0;
        }
        else
        {
            UltraDashStampValue = 1;
        }
        [self NVTSendHttpCmd:@"3106" Par2:[[NSString alloc] initWithFormat:@"%d",UltraDashStampValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            UltraDashStampValue = 1;
        }
        else
        {
            UltraDashStampValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_UltraDashStamp value:UltraDashStampValue];
    }
}

- (IBAction)updateAudioRecordingSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint AudioRecordingValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == BD200 ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200GW ||
       [self.SSIDSreial MatchSSIDReturn:self.SSID] == D200)
    {
        if ([switchView isOn])
        {
            AudioRecordingValue = 0;
        }
        else
        {
            AudioRecordingValue = 1;
        }
        [self NVTSendHttpCmd:@"2007" Par2:[[NSString alloc] initWithFormat:@"%d",AudioRecordingValue]];
    }
}
- (IBAction)updateInformationStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint InformationStampValue;
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if ([switchView isOn])
        {
            InformationStampValue = 0;
        }
        else
        {
            InformationStampValue = 1;
        }
        [self NVTSendHttpCmd:@"3105" Par2:[[NSString alloc] initWithFormat:@"%d",InformationStampValue]];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.SSID] == ICATCH_SSIDSerial)
    {
        if ([switchView isOn])
        {
            InformationStampValue = 1;
        }
        else
        {
            InformationStampValue = 2;
        }
        [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_InformationStamp value:/*switchView.isOn*/InformationStampValue];
    }
}


- (IBAction)updateSpeedStampSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint SpeedStampValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
    {
        if ([switchView isOn])
        {
            SpeedStampValue = 0;
        }
        else
        {
            SpeedStampValue = 1;
        }
        [self NVTSendHttpCmd:@"3104" Par2:[[NSString alloc] initWithFormat:@"%d",SpeedStampValue]];
    }

}



- (IBAction)updateScreenSaveSwitch:(id)sender {
    UISwitch *switchView = (UISwitch *)sender;
    uint SpeedStampValue;
    if([self.SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
    {
        if ([switchView isOn])
        {
            SpeedStampValue = 0;
        }
        else
        {
            SpeedStampValue = 1;
        }
        [self NVTSendHttpCmd:@"3113" Par2:[[NSString alloc] initWithFormat:@"%d",SpeedStampValue]];
    }
    
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
    // NSLog(@"NVT ALL COMMAND = @%@",[self.NVTSettingValueDict allKeys]);
    //for(NSString *key in self.NVTSettingValueDict){
    //    NSLog(@"command value = %@",[self.NVTSettingValueDict objectForKey:cmd]);
     //}
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    NSLog(@"GetValue = %@",[self.NVTSettingValueDict objectForKey:cmd]);
    
    return [self.NVTSettingValueDict objectForKey:cmd];
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    
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
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"PASSPHRASE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        passwordFlag = YES;
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
            [self.NVTSettingValueDict setValue:currentElementStatus forKey:currentElementCommand];
        }
        else if(ValueFlag){
            ValueFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTSettingValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(StringFlag){
            StringFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            if([self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W ||
               [self.SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W) {
                if([currentElementCommand  isEqual: @"9121"]) {
                    currentElementCommand = @"3118";
                }
            }
            [self.NVTSettingValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(passwordFlag){
            passwordFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTSettingValueDict setValue:currentElementValue forKey:@"WirelessLinkPassword"];
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
