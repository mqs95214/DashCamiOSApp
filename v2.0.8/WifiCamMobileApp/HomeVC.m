//
//  HomeVC.m
//  WifiCamMobileApp
//
//  Created by Guo on 5/19/15.
//  Copyright (c) 2015 iCatchTech. All rights reserved.
//

#import "HomeVC.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "WifiCamControl.h"
#include "PreviewSDKEventListener.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ViewController.h"
#import "Camera.h"
#import <Photos/Photos.h>
#import "Reachability+Ext.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <objc/runtime.h>
#include <ifaddrs.h>
#include <net/if.h>


#define kTitleLength 15

@interface UIButton (UIButtonWiFiCamButton)
@property(nonatomic) id isRecorded;
@end
static char isSlotRecored;
@implementation UIButton (UIButtonWiFiCamButton)
-(id)isRecorded {
    return objc_getAssociatedObject(self, &isSlotRecored);
}

-(void)setIsRecorded:(id)isRecorded {
    objc_setAssociatedObject(self, &isSlotRecored, isRecorded, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end

@interface HomeVC ()
<
UIAlertViewDelegate,
NSFetchedResultsControllerDelegate,
CBCentralManagerDelegate,
CBPeripheralDelegate
>
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UILabel *infoNumber1;
@property (weak, nonatomic) IBOutlet UILabel *info3;
@property (weak, nonatomic) IBOutlet UILabel *infoNumber2;
@property (weak, nonatomic) IBOutlet UILabel *info4;
@property (weak, nonatomic) IBOutlet UILabel *info5;
@property (weak, nonatomic) IBOutlet UILabel *infoNumber3;
@property (weak, nonatomic) IBOutlet UILabel *info6;
@property (weak, nonatomic) IBOutlet UILabel *info7;
@property (weak, nonatomic) IBOutlet UILabel *info8;
@property (weak, nonatomic) IBOutlet UILabel *info9;
@property(weak, nonatomic) IBOutlet UIButton *addCamBtn1;
@property(weak, nonatomic) IBOutlet UIButton *addCamBtn2;
@property(weak, nonatomic) IBOutlet UIButton *addCamBtn3;
@property(weak, nonatomic) IBOutlet UIButton *remCamBtn3;
@property(weak, nonatomic) IBOutlet UIButton *remCamBtn2;
@property(weak, nonatomic) IBOutlet UIButton *remCamBtn1;
@property(weak, nonatomic) IBOutlet UIButton *camThumbBtn1;
@property(weak, nonatomic) IBOutlet UIButton *camThumbBtn2;
@property(weak, nonatomic) IBOutlet UIButton *camThumbBtn3;
@property(weak, nonatomic) IBOutlet UIImageView *icon1;
@property(weak, nonatomic) IBOutlet UIImageView *icon2;
@property(weak, nonatomic) IBOutlet UIImageView *icon3;
@property(weak, nonatomic) IBOutlet UIButton *photoBg;
@property(weak, nonatomic) IBOutlet UIButton *videoBg;
@property(weak, nonatomic) IBOutlet UIButton *photoThumb;
@property(weak, nonatomic) IBOutlet UIButton *videoThumb;
@property(weak, nonatomic) IBOutlet UILabel *mediaOnMyIphone;
@property(weak, nonatomic) IBOutlet UINavigationItem *Navbar;
@property(weak, nonatomic) IBOutlet UILabel *photosLabel;
@property(weak, nonatomic) IBOutlet UILabel *videosLabel;
@property (weak, nonatomic) IBOutlet UIButton *ContinueBtn;
@property (weak, nonatomic) IBOutlet UIButton *ConnectBtn;
@property(nonatomic) WifiCam *wifiCam;
@property(nonatomic) WifiCamCamera *camera;
@property(nonatomic) WifiCamControlCenter *ctrl;
@property(nonatomic) Reachability *wifiReachability;
@property(nonatomic) ConnectionListener *connectionChangedListener;
@property(strong, nonatomic) UIAlertView *connErrAlert;
@property(strong, nonatomic) UIAlertView *connErrAlert1;
@property(strong, nonatomic) UIAlertView *reconnAlert;
@property(strong, nonatomic) UIAlertView *customerIDAlert;
@property(nonatomic) NSInteger AppError;
@property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic) int cameraTobeRemoved;
@property(nonatomic, strong) NSMutableArray *photos;
@property(nonatomic, strong) NSMutableArray *thumbs;
@property(nonatomic, strong) NSMutableArray *assets;
@property(nonatomic, strong) ALAssetsLibrary *ALAssetsLibrary;
@property(nonatomic) NSMutableArray *selections;
@property(nonatomic) CBCentralManager *myCentralManager;
@property(nonatomic) NSMutableString *receivedCmd;
@property(nonatomic) NSString *cameraSSID;
@property(nonatomic) NSString *cameraPWD;
@property(nonatomic) id current_sender;
@property(nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property(nonatomic, strong) UIAlertView *inputIpAlert;

@property (nonatomic, strong) NSMutableDictionary *ssidCacheDict;

@property(nonatomic,strong)NSBundle *bundle;
@end


@implementation HomeVC
{
    SSID_SerialCheck *SSIDSreial;
    AppDelegate *delegate;
}

- (NSMutableDictionary *)ssidCacheDict {
    if (_ssidCacheDict == nil) {
        _ssidCacheDict = [NSMutableDictionary dictionary];
    }
    
    return _ssidCacheDict;
}

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
  
    NSLog(@"viewDidLoad");
    
#if 0
    self.connErrAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectError", nil)
                                                   message:NSLocalizedString(@"NoWifiConnection", nil)
                                                  delegate:self
                                         cancelButtonTitle:NSLocalizedString(@"Sure", nil)
                                         otherButtonTitles:nil, nil];
    _connErrAlert.tag = APP_CONNECT_ERROR_TAG;
    
    self.connErrAlert1 = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectError", nil)
                                                    message:NSLocalizedString(@"Connected to other Wi-Fi", nil)
                                                   delegate:self
                                          cancelButtonTitle:NSLocalizedString(@"Sure", nil)
                                          otherButtonTitles:nil, nil];
    
    self.reconnAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectError", nil)
                                                  message:NSLocalizedString(@"TimeoutError", nil)
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"STREAM_RECONNECT", nil)
                                        otherButtonTitles:NSLocalizedString(@"Sure", nil), nil];
    _reconnAlert.tag = APP_RECONNECT_ALERT_TAG;
    
    self.customerIDAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ConnectError",nil)
                                                      message:NSLocalizedString(@"ALERT_DOWNLOAD_CORRECT_APP", nil)
                                                     delegate:self
                                            cancelButtonTitle:NSLocalizedString(@"Exit", nil)
                                            otherButtonTitles:nil, nil];
    _customerIDAlert.tag = APP_CUSTOMER_ALERT_TAG;

    self.wifiReachability = [Reachability reachabilityForLocalWiFi];
    #endif
    //_photosLabel.text = NSLocalizedString(@"PhotosLabel", nil);
    //_videosLabel.text = NSLocalizedString(@"Videos", nil);
    //_mediaOnMyIphone.text = NSLocalizedString(@"Media on My iPhone", nil);
    //[_addCamBtn1 setTitle:NSLocalizedString(@"Add New Camera", nil) forState:UIControlStateNormal];
    //[_addCamBtn2 setTitle:NSLocalizedString(@"Add New Camera", nil) forState:UIControlStateNormal];
    //[_addCamBtn3 setTitle:NSLocalizedString(@"Add New Camera", nil) forState:UIControlStateNormal];
    
    
    // register timer for check SSID
    //_theTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkConnectionStatus) userInfo:nil repeats:YES];
   #if 0
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    self.myCentralManager = [[CBCentralManager alloc] initWithDelegate:self
                                                                 queue:nil
                                                               options:nil];
    
    NSUserDefaults *defaultSettings = [NSUserDefaults standardUserDefaults];
    
#endif
    /*
     #if LIVE_DEBUG
     BOOL enableLive = [defaultSettings boolForKey:@"PreferenceSpecifier:Live"];
     if (enableLive) {
     _inputIpAlert = [[UIAlertView alloc] initWithTitle:@"Camera IP Address"
     message           :@"please enter ip addr:"
     delegate          :self
     cancelButtonTitle :@"Cancel"
     otherButtonTitles :@"Ok", nil];
     [_inputIpAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
     UITextField *text = [_inputIpAlert textFieldAtIndex:0];
     text.clearButtonMode = UITextFieldViewModeWhileEditing;
     
     NSString *ipAddr = [defaultSettings objectForKey:@"ipAddr"];
     if (!ipAddr) {
     text.placeholder = @"please enter ip addr";
     [_inputIpAlert show];
     } else {
     text.text = ipAddr;
     }
     
     _inputIpAlert.tag = APP_INPUTIPADDR_ALERT_TAG;
     _navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClink)];
     }
     #else
     if ([defaultSettings objectForKey:@"ipAddr"]) {
     [defaultSettings setObject:nil forKey:@"ipAddr"];
     }
     #endif
     
     #if kV50_Test
     _inputIpAlert = [[UIAlertView alloc] initWithTitle:@"Preview URL"
     message           :@"please enter pv URL:"
     delegate          :self
     cancelButtonTitle :@"Cancel"
     otherButtonTitles :@"Ok", nil];
     [_inputIpAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
     UITextField *text = [_inputIpAlert textFieldAtIndex:0];
     text.clearButtonMode = UITextFieldViewModeWhileEditing;
     
     NSString *ipAddr = [defaultSettings objectForKey:@"pvURL"];
     if (!ipAddr) {
     text.placeholder = @"please enter pv URL";
     [_inputIpAlert show];
     } else {
     text.text = ipAddr;
     }
     
     _inputIpAlert.tag = APP_INPUTPVURL_ALERT_TAG;
     _navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editClink)];
     #endif
     */
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    //[self loadAssets];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    #if 0
    appDelegate.isReconnecting = YES;

     if (_myCentralManager.state == CBCentralManagerStatePoweredOn) {
     [_myCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
     NSLog(@"Scanning started");
     }
    
    [self.ssidCacheDict removeAllObjects];
    #endif
    
    UILabel *label;
    
    
    
    //self.info1.text = NSLocalizedString(@"setInformation1",@"");
    [delegate initLanguage];
    self.info1.text = [delegate getStringForKey:@"setInformation1" withTable:@""];
    self.info2.text = [delegate getStringForKey:@"setInformation2" withTable:@""];
    self.info3.text = [delegate getStringForKey:@"setInformation3" withTable:@""];
    self.info4.text = [NSString stringWithFormat:@"%@\n%@",[delegate getStringForKey:@"setInformation4" withTable:@""],[delegate getStringForKey:@"setInformation5" withTable:@""]];
    self.info6.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",[delegate getStringForKey:@"setInformation6" withTable:@""],[delegate getStringForKey:@"setInformation7" withTable:@""],[delegate getStringForKey:@"setInformation8" withTable:@""],[delegate getStringForKey:@"setInformation9" withTable:@""]];
    self.infoNumber1.text = [delegate getStringForKey:@"setInformationNumber1" withTable:@""];
    self.infoNumber2.text = [delegate getStringForKey:@"setInformationNumber2" withTable:@""];
    self.infoNumber3.text = [delegate getStringForKey:@"setInformationNumber3" withTable:@""];
    [self.ContinueBtn setTitle:[delegate getStringForKey:@"Continue" withTable:@""] forState:UIControlStateNormal];
    [self.ContinueBtn setTitle:[delegate getStringForKey:@"Continue" withTable:@""] forState:UIControlStateHighlighted];
    [self.ConnectBtn setTitle:[delegate getStringForKey:@"Connect" withTable:@""] forState:UIControlStateNormal];
    [self.ConnectBtn setTitle:[delegate getStringForKey:@"Connect" withTable:@""] forState:UIControlStateHighlighted];
    label = [self getLenghtText];
    UIFont *font;
    font = [self adjFontSize:label];
    CGFloat fontSize = font.pointSize;
    self.info1.font = [font fontWithSize:fontSize];
    self.info2.font = [font fontWithSize:fontSize];
    self.info3.font = [font fontWithSize:fontSize];
    self.info4.font = [font fontWithSize:fontSize];
    self.info6.font = [font fontWithSize:fontSize];
    int width = self.info6.frame.size.width;
    [self.info6 sizeToFit];
    CGRect rect = CGRectMake(self.info6.frame.origin.x, self.info6.frame.origin.y, width, self.info6.frame.size.height);
    
    [self.info6 setFrame:rect];
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
    
    while(count < 5) {
        if(count == 0) {
            str = self.info1.text;
        } else if(count == 1) {
            str = self.info2.text;
        } else if(count == 2) {
            str = self.info3.text;
        } else if(count == 3) {
            str = self.info4.text;
        } else if(count == 4) {
            str = self.info6.text;
        }
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
    rect = [self.info6 bounds];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self hideProgressHUD:YES];
    //NSLog(@"viewDidAppear1");
    /*TRACE();
    
    AppLog(@"1: %f", _addCamBtn1.frame.origin.y);
    AppLog(@"2: %f", _addCamBtn2.frame.origin.y);
    AppLog(@"3: %f", _addCamBtn3.frame.origin.y);
    AppLog(@"mediaOnMyIphone: %f", _mediaOnMyIphone.frame.origin.y);*/
    
    
    //float gap = (_mediaOnMyIphone.frame.origin.y - _addCamBtn1.frame.size.height * 3) / 4;
    //    float x = _addCamBtn1.frame.origin.x;
    //    float w = _addCamBtn1.frame.size.width;
    //float h = _addCamBtn1.frame.size.height;
    //CGFloat remy1 = _remCamBtn1.frame.origin.y - gap;
    //CGFloat remy2 = _remCamBtn2.frame.origin.y - (gap*2+h);
    //CGFloat remy3 = _remCamBtn2.frame.origin.y - (gap*3+h*2);
    
    //_remCamBtn1.transform = CGAffineTransformTranslate(_remCamBtn1.transform, 0, -remy1);
    //_remCamBtn2.transform = CGAffineTransformTranslate(_remCamBtn2.transform, 0, -remy2);
    //_remCamBtn3.transform = CGAffineTransformTranslate(_remCamBtn3.transform, 0, -remy3);
    
    //CGFloat ty1 = _addCamBtn1.frame.origin.y - gap;
    //_icon1.transform = _camThumbBtn1.transform = _addCamBtn1.transform = CGAffineTransformTranslate(_addCamBtn1.transform, 0, -ty1);
    //CGFloat ty2 = _addCamBtn2.frame.origin.y - (gap*2 + h);
    //_icon2.transform = _camThumbBtn2.transform = _addCamBtn2.transform = _remCamBtn2.transform = CGAffineTransformTranslate(_addCamBtn2.transform, 0, -ty2);
    //CGFloat ty3 = _addCamBtn3.frame.origin.y - (gap*3 + h*2);
    //_icon3.transform = _camThumbBtn3.transform = _addCamBtn3.transform = _remCamBtn3.transform = CGAffineTransformTranslate(_addCamBtn3.transform, 0, -ty3);
    
   // [self.view needsUpdateConstraints];
    //NSLog(@"viewDidAppear2");
  //  NSError *error = nil;
    //NSLog(@"viewDidAppear3");
    //if (![[self fetchedResultsController] performFetch:&error]) {
     
         /*Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.*/
     
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
        //abort();
#endif
    //}
    
    //[self checkConnectionStatus];
    //NSLog(@"viewDidAppear4");
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.delegate = self;
    //NSLog(@"viewDidAppear5");
    #if 0
    [self.wifiReachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkConnectionStatus) name:kReachabilityChangedNotification object:nil];
#endif
    //NSLog(@"viewDidAppear6");
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return UIInterfaceOrientationPortrait;
}
- (NSString *)cacheSSID:(NSString *)title {
    NSString *showTitle = title;
    
    if (title.length > kTitleLength) {
//        showTitle = [[title substringToIndex:12] stringByAppendingString:@"..."];
        showTitle = [[title substringToIndex:kTitleLength] stringByAppendingString:@"\n"];
        showTitle = [showTitle stringByAppendingString:[title substringFromIndex:kTitleLength]];
    }
    
    if ([self.ssidCacheDict.allKeys containsObject:showTitle]) {
        self.ssidCacheDict[showTitle] = title;
    } else {
        [self.ssidCacheDict setObject:title forKey:showTitle];
    }
    
    return showTitle;
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

- (void)editClink
{
    [_inputIpAlert show];
}
// scheduler check
// 1. SSID
// 2. Connection
-(void)checkConnectionStatus
{
    NSDictionary *ifs = [self fetchSSIDInfo];
    current_ssid= [ifs objectForKey:@"SSID"];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.fetchedResultsController.sections.count > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:0];
//                    AppLog(@"num : %d",[sectionInfo numberOfObjects]);
            if([sectionInfo numberOfObjects] > 0) {
                
                for (int i=0; i<[sectionInfo numberOfObjects]; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    Camera *camera = (Camera *)[self.fetchedResultsController objectAtIndexPath:indexPath];
                    //                AppLog(@"ssid: %@", camera.wifi_ssid);
                    int id0 = [camera.id intValue];
                    //                AppLog(@"id0: %d", id0);
                    
                    NSString *title = camera.wifi_ssid;
                    
                    NSString *showTitle = [self cacheSSID:title];
                    
                    UIImage *image = (UIImage *)camera.thumbnail;
                    switch (id0) {
                        case 0:
                            if (image) {
                                [_camThumbBtn1 setBackgroundImage:image
                                                         forState:UIControlStateNormal];
                            }
                            [_addCamBtn1 setTitle:showTitle forState:UIControlStateNormal];
                            if( [title isEqualToString:current_ssid]){
                                [_addCamBtn1 setTitleColor:UIColorFromRGB(0x32A3DE) forState:UIControlStateNormal];
                                _icon1.image = [UIImage imageNamed:@"connected_sign"];
                            }else{
                                [_addCamBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                _icon1.image = [UIImage imageNamed:@"disconnected_sign"];
                            }
                            
                            _addCamBtn1.isRecorded = @YES;
                            [_remCamBtn1 setHidden:NO];
                            break;
                        case 1:
                            if (image) {
                                [_camThumbBtn2 setBackgroundImage:image
                                                         forState:UIControlStateNormal];
                            }
                            [_addCamBtn2 setTitle:showTitle forState:UIControlStateNormal];
                            if( [title isEqualToString:current_ssid]){
                                [_addCamBtn2 setTitleColor:UIColorFromRGB(0x32A3DE) forState:UIControlStateNormal];
                                _icon2.image = [UIImage imageNamed:@"connected_sign"];
                            }else{
                                [_addCamBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                _icon2.image = [UIImage imageNamed:@"disconnected_sign"];
                            }
                            
                            _addCamBtn2.isRecorded = @YES;
                            [_remCamBtn2 setHidden:NO];
                            break;
                        case 2:
                            if (image) {
                                [_camThumbBtn3 setBackgroundImage:image
                                                         forState:UIControlStateNormal];
                            }
                            [_addCamBtn3 setTitle:showTitle forState:UIControlStateNormal];
                            if( [title isEqualToString:current_ssid]){
                                [_addCamBtn3 setTitleColor:UIColorFromRGB(0x32A3DE) forState:UIControlStateNormal];
                                _icon3.image = [UIImage imageNamed:@"connected_sign"];
                            }else{
                                [_addCamBtn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                                _icon3.image = [UIImage imageNamed:@"disconnected_sign"];
                            }
                            
                            _addCamBtn3.isRecorded = @YES;
                            [_remCamBtn3 setHidden:NO];
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    });
    

}
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);
        if (info && [info count]) { break; }
    }
    return info;
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_myCentralManager.state == CBManagerStatePoweredOn) {
        [_myCentralManager stopScan];
    }
    //[_timer invalidate];
    [self.wifiReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)setButtonRadius:(UIButton *)button withRadius:(CGFloat)radius {
    button.layer.cornerRadius = radius;
    button.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)enableButtons:(BOOL)value {
    self.addCamBtn1.userInteractionEnabled = value;
    self.addCamBtn2.userInteractionEnabled = value;
    self.addCamBtn3.userInteractionEnabled = value;
    self.videoThumb.userInteractionEnabled = value;
    self.photoThumb.userInteractionEnabled = value;
}
struct ifaddrs *interfaces;
/*
- (BOOL) isWiFiEnabled {
    NSCountedSet * cset = [NSCountedSet new];
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                NSString *obj = [NSString stringWithUTF8String:interface->ifa_name];
                AppLog(@"interface: %@", obj);
                [cset addObject:obj];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}
*/
- (IBAction)addCamera:(id)sender {
    UIButton *btn = (UIButton *)sender;
    NSString *buttonTitle = btn.titleLabel.text;
    buttonTitle = self.ssidCacheDict[buttonTitle];
    
    if (![btn.isRecorded boolValue]) {
        /* Register a new camera */
        // Check redundance
        NSError *error = nil;
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
            abort();
#endif
        }
        if (self.fetchedResultsController.sections.count > 0) {
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:0];
            if([sectionInfo numberOfObjects] > 0) {
                for (int i=0; i<[sectionInfo numberOfObjects]; ++i) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
                    Camera *camera = (Camera *)[self.fetchedResultsController objectAtIndexPath:indexPath];
                    if ([camera.wifi_ssid isEqualToString:current_ssid]
                        || [camera.wifi_ssid isEqualToString:_cameraSSID]) {
                        return;
                    }
                }
            }
        } // --- Check redundance ---
        
        [self performSegueWithIdentifier:@"addCameraSegue" sender:@[@(btn.tag)]];
    } else {
        /* Open a camera */
        if (current_ssid) {
            if ([buttonTitle isEqualToString:current_ssid]) {
                // Goto PV
                [self connect:@[@(btn.tag), current_ssid]];
            } else {
                if (_myCentralManager.state == CBManagerStatePoweredOn) {
                     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        NSLog(@"Scanning started");
                        [_myCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
                    });
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Connected" message:@"To preview your Wi-Fi Camera, please turn on Bluetooth." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        } else {
            // Wi-Fi is disconnected
            NSString *msg = [NSString stringWithFormat:@"Please turn on Wi-Fi."];
        }
    }
}

- (IBAction)removeCameraByBtn:(UIButton*)sender{
        self.cameraTobeRemoved = sender.tag-100.0;
    
        BOOL showAlert = YES;
        switch (_cameraTobeRemoved) {
            case 0:
                if ([_addCamBtn1.titleLabel.text isEqualToString:NSLocalizedString(@"Add New Camera", nil)]) {
                    showAlert = NO;
                }
                break;
            case 1:
                if ([_addCamBtn2.titleLabel.text isEqualToString:NSLocalizedString(@"Add New Camera", nil)]) {
                    showAlert = NO;
                }
                break;
            case 2:
                if ([_addCamBtn3.titleLabel.text isEqualToString:NSLocalizedString(@"Add New Camera", nil)]) {
                    showAlert = NO;
                }
                break;
            default:
                break;
        }
        if (showAlert == YES) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",nil)
                                                            message:NSLocalizedString(@"Are you sure you want to remove this record", nil)
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                                  otherButtonTitles:NSLocalizedString(@"Sure",nil), nil];
            alert.tag = 5;
            [alert show];
        }
}
- (IBAction)removeCamera:(id)sender {
    
    UIButton *testBtn = sender;
    UILongPressGestureRecognizer *testGuesture = sender;
    if ([testBtn isKindOfClass:[UIButton class]]) {
        self.cameraTobeRemoved = (int)testBtn.tag;
    } else if ([testGuesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (testGuesture.state == UIGestureRecognizerStateBegan) {
            self.cameraTobeRemoved = (int)testGuesture.view.tag;
        } else {
            return;
        }
    }
    
    BOOL showAlert = NO;
    switch (_cameraTobeRemoved) {
        case 0:
            if ([_addCamBtn1.isRecorded boolValue]) {
                showAlert = YES;
            }
            break;
        case 1:
            if ([_addCamBtn2.isRecorded boolValue]) {
                showAlert = YES;
            }
            break;
        case 2:
            if ([_addCamBtn3.isRecorded boolValue]) {
                showAlert = YES;
            }
            break;
        default:
            break;
    }
    if (showAlert) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning",nil)
                                                        message:NSLocalizedString(@"Are you sure you want to remove this record", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel",nil)
                                              otherButtonTitles:NSLocalizedString(@"Sure",nil), nil];
        alert.tag = 5;
        [alert show];
    }

}

- (void)removeCameraAtIndex:(NSUInteger)index {
    NSString *nullTitle = NSLocalizedString(@"Add New Camera", nil);
    UIImage *nullThumbnail = [UIImage imageNamed:@"empty_thumb"];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Camera"
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"id = %@", @(index)];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && fetchedObjects && fetchedObjects.count>0) {
        [self.managedObjectContext deleteObject:fetchedObjects[0]];
        if ([self.managedObjectContext save:&error]) {
            
            if (index == 0) {
                [_addCamBtn1 setTitle:nullTitle forState:UIControlStateNormal];
                [_camThumbBtn1 setBackgroundImage:nullThumbnail
                                         forState:UIControlStateNormal];
                [_addCamBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _icon1.image = [UIImage imageNamed:@"addIcon"];
                _addCamBtn1.isRecorded = @NO;
                _remCamBtn1.hidden = YES;
            } else if (index == 1) {
                [_addCamBtn2 setTitle:nullTitle forState:UIControlStateNormal];
                [_camThumbBtn2 setBackgroundImage:nullThumbnail
                                         forState:UIControlStateNormal];
                [_addCamBtn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _icon2.image = [UIImage imageNamed:@"addIcon"];
                _addCamBtn2.isRecorded = @NO;
                _remCamBtn2.hidden = YES;

            } else {
                [_addCamBtn3 setTitle:nullTitle forState:UIControlStateNormal];
                [_camThumbBtn3 setBackgroundImage:nullThumbnail
                                         forState:UIControlStateNormal];
                [_addCamBtn3 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                _icon3.image = [UIImage imageNamed:@"addIcon"];
                _addCamBtn3.isRecorded = @NO;
                _remCamBtn3.hidden = YES;

            }
        }
    } else {
        AppLog(@"fetch failed.");
    }
}

- (NSString *)checkSSID
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

- (void)connect:(id)sender
{
    SSIDSreial = [[SSID_SerialCheck alloc] init];
#if 0
    self.AppError = 0;
    if (!_connErrAlert.hidden) {
        //AppLog(@"dismiss connErrAlert");
        [_connErrAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
    if (!_connErrAlert1.hidden) {
        //AppLog(@"dismiss connErrAlert");
        [_connErrAlert1 dismissWithClickedButtonIndex:0 animated:NO];
    }
    if (!_reconnAlert.hidden) {
        //AppLog(@"dismiss reconnAlert");
        [_reconnAlert dismissWithClickedButtonIndex:0 animated:NO];
    }
#endif
    //NSString *connectingMessage = [NSString stringWithFormat:@"%@ %@ ...", NSLocalizedString(@"Connect to",nil),[self checkSSID]];
    //[self showGCDNoteWithMessage:connectingMessage withAnimated:YES withAcvity:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        AppLogTRACE();
        int totalCheckCount = 4;
        NSString *ssid = [self checkSSID];
        
        if(ssid == nil)
        {
            [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
        }
        else
        {
            if([SSIDSreial CheckSSIDSerial:ssid] == NOVATEK_SSIDSerial)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[self hideGCDiscreetNoteView:YES];
                    //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    //appDelegate.isReconnecting = NO;
                    [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
                });
            }
            else if([SSIDSreial CheckSSIDSerial:ssid] == ICATCH_SSIDSerial)
            {
            #if 0
            while (totalCheckCount-- > 0) {
                @autoreleasepool {
                    if ([Reachability didConnectedToCameraHotspot]) {
                        if ([[SDK instance] initializeSDK]) {
                            
                            [WifiCamControl scan];
                            
                            WifiCamManager *app = [WifiCamManager instance];
                            self.wifiCam = [app.wifiCams objectAtIndex:0];
                            _wifiCam.camera = [WifiCamControl createOneCamera];
                            self.camera = _wifiCam.camera;
                            self.ctrl = _wifiCam.controler;
                            
                            if ([[SDK instance] isSDKInitialized]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self hideGCDiscreetNoteView:YES];
                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                    appDelegate.isReconnecting = NO;
                                    [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
                                });
                            }/* else {
                                totalCheckCount = 4;
                                continue;
                            }*/
                            
                           // return;
                        }
                    }
                
                    AppLog(@"[%d]NotReachable -- Sleep 500ms", totalCheckCount);
                    [NSThread sleepForTimeInterval:0.5];
                }
            }
            #else
                if ([[SDK instance] initializeSDK]) {
                    
                    [WifiCamControl scan];
                    
                    WifiCamManager *app = [WifiCamManager instance];
                    self.wifiCam = [app.wifiCams objectAtIndex:0];
                    _wifiCam.camera = [WifiCamControl createOneCamera];
                    self.camera = _wifiCam.camera;
                    self.ctrl = _wifiCam.controler;
                    
                    if ([[SDK instance] isSDKInitialized]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //[self hideGCDiscreetNoteView:YES];
                            //AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                           // appDelegate.isReconnecting = NO;
                            [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
                        });
                    }
                }
            #endif
            #if 0
            if (totalCheckCount <= 0 && _AppError == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
                });
            }
            #endif
            }
            else
            {
                [self performSegueWithIdentifier:@"newPreviewSegue" sender:sender];
            }
        }
    });
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"newPreviewSegue"]) {
#if 0
        NSArray *data = (NSArray *)sender;
        UINavigationController *navController = [segue destinationViewController];
        ViewController *vc = (ViewController *)navController.topViewController;
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Camera" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"id = %@",[data firstObject]];
        [fetchRequest setPredicate:predicate];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (!error && fetchedObjects && fetchedObjects.count>0) {
            
            vc.savedCamera = (Camera *)fetchedObjects[0];
            AppLog(@"Already have one camera: %d", [[data firstObject] intValue]);
        } else {
            vc.savedCamera = (Camera *)[NSEntityDescription insertNewObjectForEntityForName:@"Camera"
                                                                     inManagedObjectContext:self.managedObjectContext];
            AppLog(@"Create a camera");
        }
        
        vc.savedCamera.id = [data firstObject];
        vc.savedCamera.wifi_ssid = [data lastObject];
#endif
    }
}

- (IBAction)showLocalMediaBrowser:(UIButton *)sender {
    // Browser
#if 0
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    NSMutableArray *thumbs = [[NSMutableArray alloc] init];
    MWPhoto *photo, *thumb;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = YES;
    BOOL autoPlayOnAppear = NO;
    @synchronized(_assets) {
        NSMutableArray *copy = [_assets copy];
        if (NSClassFromString(@"PHAsset")) {
            // Photos library
            UIScreen *screen = [UIScreen mainScreen];
            CGFloat scale = screen.scale;
            // Sizing is very rough... more thought required in a real implementation
            CGFloat imageSize = MAX(screen.bounds.size.width, screen.bounds.size.height) * 1.5;
            CGSize imageTargetSize = CGSizeMake(imageSize * scale, imageSize * scale);
            CGSize thumbTargetSize = CGSizeMake(imageSize / 3.0 * scale, imageSize / 3.0 * scale);
            for (PHAsset *asset in copy) {
                if (sender.tag == 11 && asset.mediaType == PHAssetMediaTypeImage) {
                    [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                    [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
                } else if (sender.tag == 12 && asset.mediaType == PHAssetMediaTypeVideo) {
                    [photos addObject:[MWPhoto photoWithAsset:asset targetSize:imageTargetSize]];
                    [thumbs addObject:[MWPhoto photoWithAsset:asset targetSize:thumbTargetSize]];
                }
            }
        } else {
            // Assets library
            for (ALAsset *asset in copy) {
                if (sender.tag == 11 && [asset valueForProperty:ALAssetPropertyType] == ALAssetTypePhoto) {
                    photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                    [photos addObject:photo];
                    thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                    [thumbs addObject:thumb];
                } else if (sender.tag == 12 && [asset valueForProperty:ALAssetPropertyType] == ALAssetTypeVideo) {
                    photo = [MWPhoto photoWithURL:asset.defaultRepresentation.url];
                    [photos addObject:photo];
                    thumb = [MWPhoto photoWithImage:[UIImage imageWithCGImage:asset.thumbnail]];
                    [thumbs addObject:thumb];
                    photo.videoURL = asset.defaultRepresentation.url;
                    thumb.isVideo = YES;
                }

            }
        }
    }
    
    self.photos = photos;
    self.thumbs = thumbs;
    
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = NO;
    browser.autoPlayOnAppear = autoPlayOnAppear;
    [browser setCurrentPhotoIndex:0];
    
    // Test custom selection images
    //    browser.customImageSelectedIconName = @"ImageSelected.png";
    //    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nc animated:YES completion:nil];

    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        

        
    });
#endif
}
/*
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    AppLog(@"get the media info: %@", info);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}
*/

-(void)globalReconnect
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:NSLocalizedString(@"Connecting", nil)
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil, nil];
        [alert show];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraNetworkDisconnectedNotification"
                                                                object:nil];
            [NSThread sleepForTimeInterval:1.0];
            
            int totalCheckCount = 60; // 60times : 30s
            
            while (totalCheckCount-- > 0) {
                @autoreleasepool {
                    if ([Reachability didConnectedToCameraHotspot]) {
                        //[[SDK instance] destroySDK];
                        if ([[SDK instance] initializeSDK]) {
                            
                            // modify by allen.chuang - 20140703
                            /*
                             if( [[SDK instance] isValidCustomerID:0x0100] == false){
                             dispatch_async(dispatch_get_main_queue(), ^{
                             AppLog(@"CustomerID mismatch");
                             [_customerIDAlert show];
                             _AppError=1;
                             });
                             break;
                             }
                             */
                            
                            [WifiCamControl scan];
                            
                            WifiCamManager *app = [WifiCamManager instance];
                            self.wifiCam = [app.wifiCams objectAtIndex:0];
                            _wifiCam.camera = [WifiCamControl createOneCamera];
                            self.camera = _wifiCam.camera;
                            self.ctrl = _wifiCam.controler;
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                AppDelegate *appDetegale = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                appDetegale.isReconnecting = NO;
                                [alert dismissWithClickedButtonIndex:0 animated:NO];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraNetworkConnectedNotification"
                                                                                    object:nil];
                                [self performSegueWithIdentifier:@"newPreviewSegue" sender:_current_sender];
                            });
                            break;
                        }
                    }
                    
                    AppLog(@"[%d]NotReachable -- Sleep 500ms", totalCheckCount);
                    [NSThread sleepForTimeInterval:0.5];
                }
            }
            
            if (totalCheckCount <= 0 && _AppError == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:NO];
//                    [_reconnAlert show];
                    NSString *ssid = [self checkSSID];
                    if (ssid == nil) {
                        [_connErrAlert show];
                    } else if (![ssid isEqualToString:current_ssid]) {
                        [_connErrAlert1 show];
                    } else {
                        [_reconnAlert show];
                    }
                });
            }
            
        });
        
        
    });
}

- (void)showReconnectAlert
{
    if (!_reconnAlert.visible) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_reconnAlert show];
        });
    }
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case APP_RECONNECT_ALERT_TAG:
            //[self dismissViewControllerAnimated:YES completion:nil];
            //[self.navigationController popToRootViewControllerAnimated:YES];
            if (buttonIndex == 0) {
                [self globalReconnect];
            }
            break;
            
        case APP_CUSTOMER_ALERT_TAG:
            AppLog(@"dismissViewControllerAnimated - start");
            [self dismissViewControllerAnimated:YES completion:^{
                AppLog(@"dismissViewControllerAnimated - complete");
            }];
            [[SDK instance] destroySDK];
            exit(0);
            break;
            
        case 5:
            if (buttonIndex == 1) {
                [self removeCameraAtIndex:_cameraTobeRemoved];
            }
            break;
            
        case APP_INPUTIPADDR_ALERT_TAG:
            if (buttonIndex == 1) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *ipAddr = [alertView textFieldAtIndex:0].text;
                AppLogDebug(AppLogTagAPP, @"ipAddr: %@", ipAddr);
                [defaults setObject:ipAddr forKey:@"ipAddr"];
            }
            break;
            
        case APP_INPUTPVURL_ALERT_TAG:
            if (buttonIndex == 1) {
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *pvURL = [alertView textFieldAtIndex:0].text;
                AppLogDebug(AppLogTagAPP, @"pvURL: %@", pvURL);
                [defaults setObject:pvURL forKey:@"pvURL"];
            }
            break;
            
        default:
            break;
    }
}


#pragma mark - Fetched results controller
- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        TRACE();
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Camera"
                                                  inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
        
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
    return _fetchedResultsController;
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
}
/*
 -(void)controllerWillChangeContent:(NSFetchedResultsController *)controller
 {
 
 }
 
-(void)controller:(NSFetchedResultsController *)controller
  didChangeObject:(id)anObject
      atIndexPath:(NSIndexPath *)indexPath
    forChangeType:(NSFetchedResultsChangeType)type
     newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            break;
            
        case NSFetchedResultsChangeDelete:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        default:
            break;
    }
}

-(void)controller:(NSFetchedResultsController *)controller
 didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo
          atIndex:(NSUInteger)sectionIndex
    forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            break;
            
        case NSFetchedResultsChangeDelete:
            break;
            
        default:
            break;
    }
}
*/
#pragma mark - Load Assets
- (void)loadAssets {
    // get current SSID
    NSDictionary *ifs = [self fetchSSIDInfo];
    current_ssid= [ifs objectForKey:@"SSID"] ;
    
    if (NSClassFromString(@"PHAsset")) {
        // Check library permissions
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self performLoadAssets];
                }
            }];
        } else if (status == PHAuthorizationStatusAuthorized) {
            [self performLoadAssets];
        }
    } else {
        // Assets library
        [self performLoadAssets];
    }
}

- (void)performLoadAssets {
    
    // Initialise
    if (!_assets) {
        _assets = [NSMutableArray new];
    } else {
        [_assets removeAllObjects];
    }
    
    _photoThumb.tag = 0;
    _videoThumb.tag = 0;
    
    // Load
    if (NSClassFromString(@"PHAsset")) {
        
        // Photos library iOS >= 8
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            PHFetchResult *assetsFetchResult = nil;
            PHFetchResult *topLevelUserCollections = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
            for (int i=0; i<topLevelUserCollections.count; ++i) {
                PHCollection *collection = [topLevelUserCollections objectAtIndex:i];
                if ([collection.localizedTitle isEqualToString:@"iQViewer"/*@"WiFiCam"*/]) {
                    if (![collection isKindOfClass:[PHAssetCollection class]]) {
                        continue;
                    }
                    // Configure the AAPLAssetGridViewController with the asset collection.
                    PHAssetCollection *assetCollection = (PHAssetCollection *)collection;
                    PHFetchOptions *options = [PHFetchOptions new];
                    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                    assetsFetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                    break;
                }
            }
            if (!assetsFetchResult) {
                AppLog(@"assetsFetchResult was nil.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *noImage = [UIImage imageNamed:@"empty_thumb"];
                    [_videoThumb setBackgroundImage:noImage forState:UIControlStateNormal];
                    [_photoThumb setBackgroundImage:noImage forState:UIControlStateNormal];
                });
                return;
            }
            
            [assetsFetchResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                //Add
                [_assets addObject:obj];

                PHAsset *asset = obj;
                if (_photoThumb.tag == 0 && asset.mediaType == PHAssetMediaTypeImage) {
                    _photoThumb.tag = 11;
                    PHImageManager *manager = [PHImageManager defaultManager];
                    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
                    options.resizeMode = PHImageRequestOptionsResizeModeExact;
                    [manager requestImageForAsset:asset
                                       targetSize:_photoThumb.frame.size
                                      contentMode:PHImageContentModeAspectFit
                                          options:options
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (result) {
                                                [_photoThumb setBackgroundImage:result forState:UIControlStateNormal];
                                            } else {
                                                [self performLoadAssets];
                                            }
                                        });
                                        
                                    }];
                    
                } else if (_videoThumb.tag == 0 && asset.mediaType == PHAssetMediaTypeVideo) {
                    _videoThumb.tag = 12;
                    PHCachingImageManager *manager = [[PHCachingImageManager alloc] init];
                    PHImageRequestOptions * options = [[PHImageRequestOptions alloc] init];
                    options.resizeMode = PHImageRequestOptionsResizeModeExact;
                    [manager requestImageForAsset:asset
                                       targetSize:_videoThumb.frame.size
                                      contentMode:PHImageContentModeAspectFit
                                          options:options
                                    resultHandler:^(UIImage *result, NSDictionary *info) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if (result) {
                                                [_videoThumb setBackgroundImage:result forState:UIControlStateNormal];
                                            } else {
                                                [self performLoadAssets];
                                            }
                                        });
                                        
                                    }];
                }
                
            }];
            
            if (assetsFetchResult.count > 0) {
                AppLog(@"_assets.count: %lu", (unsigned long)_assets.count);
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *noImage = [UIImage imageNamed:@"empty_thumb"];
                    [_videoThumb setBackgroundImage:noImage forState:UIControlStateNormal];
                    [_photoThumb setBackgroundImage:noImage forState:UIControlStateNormal];
                });
            }
        });
        
    } else {
        
        /*
         ALAssetsLibrary：代表整个PhotoLibrary，我们可以生成一个它的实例对象，这个实例对象就相当于是照片库的句柄。
         ALAssetsGroup：照片库的分组，我们可以通过ALAssetsLibrary的实例获取所有的分组的句柄。
         ALAsset：一个ALAsset的实例代表一个资产，也就是一个photo或者video，我们可以通过他的实例获取对应的缩略图或者原图等等。
         */
        
        // Assets Library iOS < 8
        _ALAssetsLibrary = [[ALAssetsLibrary alloc] init];
        // Run in the background as it takes a while to get all assets from the library
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
            NSMutableArray *assetURLDictionaries = [[NSMutableArray alloc] init];
            
            // Process assets
            void (^assetEnumerator)(ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    NSString *assetType = [result valueForProperty:ALAssetPropertyType];
                    
                    if (_photoThumb.tag == 0 && [assetType isEqualToString:ALAssetTypePhoto]) {
                        [self loadFirstPhotoThumbnail:result];
                    } else if (_videoThumb.tag == 0 && [assetType isEqualToString:ALAssetTypeVideo]) {
                        [self loadFirstVideoThumbnail:result];
                    }
                    
                    if ([assetType isEqualToString:ALAssetTypePhoto] || [assetType isEqualToString:ALAssetTypeVideo]) {
                        [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                        NSURL *url = result.defaultRepresentation.url;
                        [_ALAssetsLibrary assetForURL:url
                                          resultBlock:^(ALAsset *asset) {
                                              if (asset) {
                                                  @synchronized(_assets) {
                                                      [_assets addObject:asset];
                                                  }
                                              }
                                          }
                                         failureBlock:^(NSError *error){
                                             NSLog(@"operation was not successfull!");
                                         }];
                    }
                }
            };
            
            // Process groups
            void (^ assetGroupEnumerator) (ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop) {
                if (group) {
                    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:assetEnumerator];
                    [assetGroups addObject:group];
                }
            };
            
            // Process!
            [_ALAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:^(NSError *error) {
                                              NSLog(@"There is an error");
                                          }];
            
        });
        
    }
    
}

- (void)loadFirstPhotoThumbnail:(ALAsset*)asset {
//    NSString *photoURL=[NSString stringWithFormat:@"%@",asset.defaultRepresentation.url];
//    NSLog(@"photoURL:%@", photoURL);
    
    //UIImage* photo = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
    //NSLog(@"PHOTO:%@", photo);
    //NSLog(@"photoSize:%@", NSStringFromCGSize(photo.size));
    
    UIImage* photoThumbnail = [UIImage imageWithCGImage:asset.thumbnail];
//    NSLog(@"PHOTO2:%@", photoThumbnail);
//    NSLog(@"photoSize2:%@", NSStringFromCGSize(photoThumbnail.size));
    if (_photoThumb.tag == 0 && photoThumbnail) {
        _photoThumb.tag = 11;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_photoThumb setBackgroundImage:photoThumbnail forState:UIControlStateNormal];
        });
    }
}

- (void)loadFirstVideoThumbnail:(ALAsset*)asset {
//    NSString *photoURL=[NSString stringWithFormat:@"%@",asset.defaultRepresentation.url];
//    NSLog(@"videoURL:%@", photoURL);
    
    UIImage* videoThumbnail = [UIImage imageWithCGImage:asset.thumbnail];
//    NSLog(@"VIDEO2:%@", videoThumbnail);
//    NSLog(@"videoSize2:%@", NSStringFromCGSize(videoThumbnail.size));
    if (_videoThumb.tag == 0) {
        _videoThumb.tag = 12;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_videoThumb setBackgroundImage:videoThumbnail forState:UIControlStateNormal];
            
        });
    }
}



#pragma mark - AppDelegateProtocol
-(void)applicationDidBecomeActive:(UIApplication *)application {
    //[self loadAssets];
    [self checkConnectionStatus];
    /*
	if (_myCentralManager.state == CBCentralManagerStatePoweredOn
        && !_discoveredPeripheral) {
        [_myCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        NSLog(@"Scanning started");
    }
     */
}

#pragma mark - CBCentralManagerDelegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    /*
    if (central.state == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        NSLog(@"Starting to scan.");
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkConnectionStatus];
        });
        self.discoveredPeripheral = nil;
    }*/
}

-(void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                 RSSI:(NSNumber *)RSSI {
    NSLog(@"Discoverd %@ at %@", peripheral.name, RSSI);
    
    if ([peripheral.name isEqualToString:current_ssid]) {
        [_myCentralManager stopScan];
        NSLog(@"Connecting to peripheral %@", peripheral);
        [_myCentralManager connectPeripheral:peripheral options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Peripheral connected.");
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral disconnected.");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkConnectionStatus];
    });
    self.cameraSSID = nil;
    self.cameraPWD = nil;
    /*
    if (central.state == CBCentralManagerStatePoweredOn) {
        [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        NSLog(@"Scanning started");
    }
     */
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Get Connected" message:@"Connect failed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    });
}

#pragma mark - CBPeripheralDelegate
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"Service count: %lu", (long)peripheral.services.count);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
        // test
        break;
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    
    NSLog(@"Characteristic count: %lu", (long)service.characteristics.count);
    for (CBCharacteristic *characteristic in service.characteristics) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
        if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
            NSLog(@"It can be writed.");
            
//            NSString *cmd = @"bt wifi info essid,pwd\0";
//            NSString *cmd = @"{\"mode\":\"wifi\",\"action\":\"info\",\"essid\":\"\",\"pwd\":\"\",\"ipaddr\":\"\"}";
            NSString *cmd = @"{\"mode\":\"wifi\",\"action\":\"info\"}";
            NSData *data = [[NSData alloc] initWithBytes:[cmd UTF8String] length:cmd.length];
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
            break;
            
        } else {
            NSLog(@"It cannot be writed.");
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
            error:(NSError *)error {
    if (error) {
        NSLog(@"Error update characteristic value %@", [error localizedDescription]);
        return;
    }
    
    NSData *data = characteristic.value;
    printf("%s", [data bytes]);
    printf("\n");
    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"info: %@", info);
    char *d = (char *)[data bytes];
    NSMutableString *hex = [[NSMutableString alloc] init];
    for(int i=0; i<data.length; ++i) {
        [hex appendFormat:@"0x%02x ", *d++ & 0xFF];
    }
    printf("\n");
    NSLog(@"hex: %@", hex);
    
    
    if (!_receivedCmd) {
        self.receivedCmd = [[NSMutableString alloc] init];
    }
    
    if (!info) {
        return;
    }
    
    [_receivedCmd appendString:info];
    NSString *ssid;
    NSString *pwd;
    NSArray *subs;
    NSString *mode;
    NSString *action;
    uint err = YES;
    if ([_receivedCmd containsString:@"}"]) {
        NSLog(@"%@", _receivedCmd);
        NSArray *items = [_receivedCmd componentsSeparatedByString:@","];
        for (int i = 0; i < items.count; i++) {
            subs = [items[i] componentsSeparatedByString:@":"];
            if ([subs[0] isEqualToString:@" \"mode\""] || [subs[0] isEqualToString:@"{\"mode\""]) {
                mode = subs[1];
                NSLog(@"mode: %@", mode);
            } else if ([subs[0] isEqualToString:@" \"action\""] || [subs[0] isEqualToString:@"{\"action\""]) {
                action = subs[1];
                NSLog(@"action: %@", action);
            } else if ([subs[0] isEqualToString:@" \"essid\""] || [subs[0] isEqualToString:@"{\"essid\""]) {
                if (i == items.count - 1) {
                    ssid = [subs[1] substringWithRange:NSMakeRange(2, (((NSString *)subs[1]).length) - 4)];
                } else {
                    ssid = [subs[1] substringWithRange:NSMakeRange(2, (((NSString *)subs[1]).length) - 3)];
                }
                NSLog(@"SSID: %@", ssid);
            } else if ([subs[0] isEqualToString:@" \"pwd\""] || [subs[0] isEqualToString:@"{\"pwd\""]) {
                if (i == items.count - 1) {
                    pwd = [subs[1] substringWithRange:NSMakeRange(2, (((NSString *)subs[1]).length) - 4)];
                } else {
                    pwd = [subs[1] substringWithRange:NSMakeRange(2, (((NSString *)subs[1]).length) - 3)];
                }
                NSLog(@"Password: %@", pwd);
            } else if ([subs[0] isEqualToString:@" \"err\""] || [subs[0] isEqualToString:@"{\"err\""]) {
                if (i == items.count - 1) {
                    err = [[subs[1] substringWithRange:NSMakeRange(1, (((NSString *)subs[1]).length) - 2)] intValue];
                } else {
                    err = [subs[1] unsignedIntValue];
                }
            }
        }
        if (([mode isEqualToString:@" \"wifi\""] || [mode isEqualToString:@" \"wifi\"}"])
            && ([action isEqualToString:@" \"info\""] || [action isEqualToString:@" \"info\"}"])) {
            if (err == 0) {
                self.cameraSSID = ssid;
                self.cameraPWD = pwd;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"PortalSegue" sender:nil];
                });
                [_myCentralManager stopScan];
            } else {
                NSLog(@"Error: %u", err);
            }
        } else if (([mode isEqualToString:@" \"wifi\""] || [mode isEqualToString:@" \"wifi\"}"])
                   && ([action isEqualToString:@" \"enable\""] || [action isEqualToString:@" \"enable\"}"])) {
            if (err == 0) {
                NSString *cmd = @"{\"mode\":\"wifi\",\"action\":\"info\"}";
                NSData *data = [[NSData alloc] initWithBytes:[cmd UTF8String]
                                                      length:cmd.length];
                [peripheral writeValue:data
                     forCharacteristic:characteristic
                                  type:CBCharacteristicWriteWithResponse];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self checkConnectionStatus];
                });
            } else {
                NSLog(@"Error: %u", err);
            }
        } else {
        }
        _receivedCmd = nil;
    }
}
- (IBAction)home_settingBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                       options:@{}
                             completionHandler:nil];
}

- (IBAction)home_previewBT_clicked:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
   // current_ssid = [self checkSSID];
   /* if(current_ssid == nil)
    {
        [self connect:nil];
    }
    else
    {
        [self connect:@[@(0), current_ssid]];
    }*/
    [self connect:nil];
    //[self connect:@[@(0), current_ssid]];
}

//-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    if (error) {
//        NSLog(@"Error update characteristic value %@", [error localizedDescription]);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self showGCDNoteWithMessage:@"Failed" andTime:1.0 withAcvity:NO];
//        });
//        return;
//    }
//    
//    NSData *data = characteristic.value;
//    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    if (!_receivedCmd) {
//        self.receivedCmd = [[NSMutableString alloc] init];
//    }
//    
//    [_receivedCmd appendString:info];
//    if ([info containsString:@"\0"]) {
//        NSLog(@"%@", _receivedCmd);
//        NSArray *items = [_receivedCmd componentsSeparatedByString:@" "];
//        if ([items[1] isEqualToString:@"wifi"]
//                   && [items[2] isEqualToString:@"info"]) {
//            NSArray *subs = [items[4] componentsSeparatedByString:@"="];
//            uint err = [subs[1] unsignedIntValue];
//            if (err == 0) {
//                NSArray *s1 = [items[3] componentsSeparatedByString:@","];
//                NSArray *ss1 = [s1[0] componentsSeparatedByString:@"="];
//                self.cameraSSID = ss1[1];
//                NSLog(@"SSID: %@", ss1[1]);
//                NSArray *ss2 = [s1[1] componentsSeparatedByString:@"="];
//                self.cameraPWD = ss2[1];
//                NSLog(@"Password: %@", ss2[1]);
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self hideGCDiscreetNoteView:NO];
//                    [self performSegueWithIdentifier:@"PortalSegue" sender:nil];
//                });
//            } else {
//                NSLog(@"Error: %u", err);
//            }
//        } else if ([items[1] isEqualToString:@"wifi"]
//                   && [items[2] isEqualToString:@"enable"]) {
//            NSArray *subs = [items[4] componentsSeparatedByString:@"="];
//            uint err = [subs[1] unsignedIntValue];
//            if (err == 0) {
//                NSString *cmd = @"bt wifi enable ap\0";
//                NSData *data = [[NSData alloc] initWithBytes:[cmd UTF8String]
//                                                      length:cmd.length];
//                [peripheral writeValue:data
//                     forCharacteristic:characteristic
//                                  type:CBCharacteristicWriteWithResponse];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self checkConnectionStatus];
//                });
//            } else {
//                NSLog(@"Error: %u", err);
//            }
//        }
//        _receivedCmd = nil;
//    }
//}
@end
