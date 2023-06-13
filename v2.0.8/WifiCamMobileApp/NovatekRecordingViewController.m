//
//  NovatekRecordingViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "NovatekRecordingViewController.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import "SSID_SerialCheck.h"
#import "MBProgressHUD.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "AppDelegate.h"
@interface NovatekRecordingViewController ()<NodePlayerDelegate,NSXMLParserDelegate,AppDelegateProtocol>
{
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    
    
    BOOL storingFlag; //查询标签所对应的元素是否存在
    
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StrogeValueFlag;
    BOOL MovieLiveFlag;
    BOOL SensorNumberFlag;
    
    NSArray *elementToParse;  //要存储的元素
    NSTimer *timer;
    int preChangeSensor;
    
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UIImageView *titleIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIView *NodePlayerView;
@property (strong,nonatomic) NodePlayer *np;
@property(nonatomic) NSString *SSID;
@property(nonatomic) MBProgressHUD *progressHUD;
@property(nonatomic) SSID_SerialCheck *SSIDSreial;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;
@property(nonatomic) NSString *NvtPreviewMode;
@property(nonatomic) dispatch_semaphore_t previewSemaphore;

@property (weak, nonatomic) IBOutlet UIButton *VideoButton;
@property (weak, nonatomic) IBOutlet UIButton *CaptureButton;
@property (weak, nonatomic) IBOutlet UIButton *RecordingButton;
@property (weak, nonatomic) IBOutlet UILabel *RecordingText;


@property(nonatomic) SystemSoundID stillCaptureSound;
@property(nonatomic) SystemSoundID delayCaptureSound;
@property(nonatomic) SystemSoundID changeModeSound;
@property(nonatomic) SystemSoundID videoCaptureSound;
@property(nonatomic) SystemSoundID burstCaptureSound;
@property(nonatomic) NSTimer *videoCaptureTimer;
@property(nonatomic) int NvtStateRecording;
@property(nonatomic,strong)NSBundle *bundle;

@end

@implementation NovatekRecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCloseController:) name:@"closeNovatekRecordingViewController" object:nil];
    [self setupUI];
    
    self.SSID = [self recheckSSID];
    self.SSIDSreial = [[SSID_SerialCheck alloc] init];
    
    [self Novatek_constructPreviewData];
    
    if (!self.previewSemaphore) {
        self.previewSemaphore = dispatch_semaphore_create(1);
    }
    [self NovatekInitMode];
    
    
    
    [self NvtVideoModeRemainTime];
    preChangeSensor = 255;
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(checkModeChange:) userInfo:nil repeats:YES];
    
    
    
    
    // Do any additional setup after loading the view.
}

-(void)checkModeChange:(NSTimer *)timer {
    [self NVTGetHttpCmd:@"3014"];
    int data = [[self.NVTGetHttpValueDict objectForKey:@"2002"] intValue];
    if(preChangeSensor != 255 && preChangeSensor != data) {
       self.RecordingButton.selected = !self.RecordingButton.selected; dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //[self NvtMovieRecordingStop];
            if ([_videoCaptureTimer isValid]) {
                [_videoCaptureTimer invalidate];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.RecordingText.textColor = [UIColor whiteColor];
                [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
                [self NvtVideoModeRemainTime];
                
            });
        });
    }
    preChangeSensor = data;
    //NSLog(@"2002 data ->   %d",data);
    //[self NVTGetHttpCmd:@"3030"];
    //nt mode = [[self.NVTGetHttpValueDict objectForKey:@"2009"] intValue];
    //NSLog(@"change mode ->   %d",mode);
    
}

-(void)notificationCloseController:(NSNotification *)notification{
    //NSString  *name=[notification name];
    //NSString  *object=[notification object];
    //NSLog(@"名称:%@----对象:%@",name,object);
    [self stopTimer];
    [self.progressHUD hide:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)stopTimer {
    if([timer isValid]) {
        [timer invalidate];
    }
    timer = nil;
}
-(void)dealloc{
    [self stopTimer];
    //NSLog(@"观察者销毁了");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    
    /*[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    */
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = NO;
    
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopTimer];
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil
     ];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];*/
}
-(void)setupUI
{
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    [self.navigationController setNavigationBarHidden:YES];
    [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
    [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
    
    
    [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
    [self.VideoButton setImage:[UIImage imageNamed:@"control_dashcam_video_select"]
                      forState:UIControlStateNormal];
    [self.CaptureButton setImage:[UIImage imageNamed:@"control_dashcam_camera_noselect"] forState:UIControlStateNormal];
}

-(void)NovatekInitMode
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.NvtPreviewMode = [self NvtGetPreivewMode];
        if(![self.NvtPreviewMode isEqualToString:@"0"])
        {
            [self NvtSetPreivewMode:@"3001" Par2:@"1"];
        }
        NSLog(@"NvtPreviewMode = %@",self.NvtPreviewMode);
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
            [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
            
            [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
            [self.VideoButton setImage:[UIImage imageNamed:@"control_dashcam_video_select"]
                              forState:UIControlStateNormal];
            [self.CaptureButton setImage:[UIImage imageNamed:@"control_dashcam_camera_noselect"] forState:UIControlStateNormal];
            [self NvtVideoModeRemainTime];
            [self NodePlayerInit];
            [self NodePlaySetUrl];
            [self NodePlayerStart];
        });
    });
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

- (void)NvtVideoModeRemainTime{
    if([self checkSdCardExist] == NO) {
        self.RecordingText.text = [delegate getStringForKey:@"SetNoSDCard" withTable:@""];
        return;
    }
    self.RecordingText.text = [Tool translateSecsToString:[[self NVTGetHttpCmd:@"2009"] integerValue]];
}

- (void)NodePlayerInit
{
    _np = [[NodePlayer alloc] init];
    [_np setNodePlayerDelegate:self];
    [_np setBufferTime:1000];
    [_np setContentMode:UIViewContentModeScaleToFill];
    
    [_np setPlayerView:self.NodePlayerView];
    
}
-(void)NodePlaySetUrl
{
    //[_np setInputUrl:@"rtsp://192.168.1.254/xxx.mov"];
    if([self NVTGetHttpCmd:@"2019"] != nil) {
        [_np setInputUrl:[self NVTGetHttpCmd:@"2019"]];
        [_np start];
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

- (NSString *)NvtGetPreivewMode{
    return [self NVTGetHttpCmd:@"3037"];
}

- (void)NvtSetPreivewMode:(NSString *)cmd Par2:(NSString *)par{
    [self NVTSendHttpCmd:cmd Par2:par];
}

- (void)NvtStillModeRemainNumber{
    if([self checkSdCardExist] == NO) {
        self.RecordingText.text = [delegate getStringForKey:@"SetNoSDCard" withTable:@""];
        return;
    }
    self.RecordingText.text = [self NVTGetHttpCmd:@"1003"];
}

- (void)NvtStillCapture{
    [self NVTGetHttpCmd:@"1001"];
}

- (void)NvtMovieRecordingStart{
    [self NVTSendHttpCmd:@"2001" Par2:@"1"];
}

- (void)NvtMovieRecordingStop{
    [self NVTSendHttpCmd:@"2001" Par2:@"0"];
}

- (void)NvtVideoRecordingTime{
    if([self checkSdCardExist] == NO) {
        self.RecordingText.text = [delegate getStringForKey:@"SetNoSDCard" withTable:@""];
        return;
    }
    self.RecordingText.text = [Tool translateSecsToString:[[self NVTGetHttpCmd:@"2016"] integerValue]];
}

- (void)movieRecordingTimerCallback:(NSTimer *)sender {
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if(self.RecordingButton.selected)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self NvtVideoRecordingTime];
                    
                });
            });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self NvtVideoModeRemainTime];
                });
            });
        }
    }
}

- (IBAction)Back:(id)sender {
    [_np stop];
    _np = nil;
    //[self.navigationController popViewControllerAnimated:YES];
    [ self dismissViewControllerAnimated: YES completion: nil ];
}


- (IBAction)VideoAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NvtPreviewMode = [self NvtGetPreivewMode];
        if(![self.NvtPreviewMode isEqualToString:@"0"])
        {
            [self showProgressHUDWithMessage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(_changeModeSound);
                [self NvtSetPreivewMode:@"3001" Par2:@"1"];
                [_np stop:NO];
                //[_np setInputUrl:@"rtsp://192.168.1.254/xxx.mov"];
                //NSLog(@"url   - > %@",[self NVTGetHttpCmd:@"2019"]);
                
                if([self NVTGetHttpCmd:@"2019"] != nil) {
                    [_np setInputUrl:[self NVTGetHttpCmd:@"2019"]];
                    [_np start];
                }
            
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.VideoButton setImage:[UIImage imageNamed:@"control_dashcam_video_select"] forState:UIControlStateNormal];
                    [self.CaptureButton setImage:[UIImage imageNamed:@"control_dashcam_camera_noselect"] forState:UIControlStateNormal];
                    [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
                    [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                    [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                    
                    
                    [self NvtVideoModeRemainTime];
                    [self hideProgressHUD:YES];
                });
            });
        }
    }
}

- (IBAction)CaptureAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.NvtPreviewMode = [self NvtGetPreivewMode];
        if(![self.NvtPreviewMode isEqualToString:@"4"])
        {
            [self showProgressHUDWithMessage:nil];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AudioServicesPlaySystemSound(_changeModeSound);
                [self NvtSetPreivewMode:@"3001" Par2:@"0"];
                [_np stop:NO];
                if([self NVTGetHttpCmd:@"2019"] != nil) {
                    [_np setInputUrl:[self NVTGetHttpCmd:@"2019"]];
                    [_np start];
                }
                //[_np setInputUrl:@"http://192.168.1.254:8192"];
                NSLog(@"url   - > %@",[self NVTGetHttpCmd:@"2019"]);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.VideoButton setImage:[UIImage imageNamed:@"control_dashcam_video_noselect"] forState:UIControlStateNormal];
                    [self.CaptureButton setImage:[UIImage imageNamed:@"control_dashcam_camera_select"] forState:UIControlStateNormal];
                    [self.titleIcon setImage:[UIImage imageNamed:@"title_camera"]];
                    [self.titleText setText:[delegate getStringForKey:@"SetPhotoMode" withTable:@""]];
                    
                    
                    [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_takenpic"] forState:UIControlStateNormal];
                    [self NvtStillModeRemainNumber];
                    [self hideProgressHUD:YES];
                    //[self NvtStillCapture];
                    
                    
                });
            });
        }
    }
}

- (IBAction)RecordingAction:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if([self.SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        if([self checkSdCardExist] == NO) {
            return;
        }
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
            
            self.RecordingButton.selected = !self.RecordingButton.selected;
            
            if(self.RecordingButton.selected)
            {
                self.NvtStateRecording = 1;
                [self showProgressHUDWithMessage:nil];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [_np stop:NO];
                    /* dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, 1ull * NSEC_PER_SEC);*/
                    /*dispatch_semaphore_wait(_previewSemaphore, DISPATCH_TIME_FOREVER);*/
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideProgressHUD:YES];
                        [_np start];
                        [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                        [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                        
                        [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record_stop"] forState:UIControlStateNormal];
                        self.RecordingText.textColor = [UIColor whiteColor];
                        self.RecordingText.text = @"00:00:00";
                        if (![_videoCaptureTimer isValid]) {
                            self.videoCaptureTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                    target  :self
                                                                                    selector:@selector(movieRecordingTimerCallback:)
                                                                                    userInfo:nil
                                                                                    repeats :YES];
                        }
                        
                        
                        //[self NvtVideoRecordingTime];
                        
                    });
                    
                    [self NvtMovieRecordingStart];
                });
            }
            else
            {
                self.NvtStateRecording = 0;
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self NvtMovieRecordingStop];
                    if ([_videoCaptureTimer isValid]) {
                        [_videoCaptureTimer invalidate];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.RecordingText.textColor = [UIColor whiteColor];
                        [self.titleIcon setImage:[UIImage imageNamed:@"title_video"]];
                        [self.titleText setText:[delegate getStringForKey:@"SetVideoMode" withTable:@""]];
                        [self.RecordingButton setImage:[UIImage imageNamed:@"control_dashcam_record"] forState:UIControlStateNormal];
                        [self NvtVideoModeRemainTime];
                        
                    });
                });
            }
            
        }
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSString *)recheckSSID
{
    //    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    //    NSLog(@"Networks: %@",networkInterfaces);
    
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
    //NSLog(@"NAVATAKE STRING = %@",str);
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    
    [m_parser setDelegate:self];
    
    BOOL flag = [m_parser parse]; //开始解析
    if(flag) {
        //NSLog(@"解析指定路径的xml文件成功");
    }
    else {
        //NSLog(@"解析指定路径的xml文件失败");
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
        SensorNumberFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        SensorNumberFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        SensorNumberFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Type"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        SensorNumberFlag = YES;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"MovieLiveViewLink"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        SensorNumberFlag = NO;
        MovieLiveFlag = YES;
    }
    else{
        storingFlag = FALSE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        SensorNumberFlag = NO;
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
        else if(SensorNumberFlag) {
            SensorNumberFlag = NO;
            currentElementStatus = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementStatus forKey:currentElementCommand];
        }
        else if(MovieLiveFlag){
            MovieLiveFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"2019"];
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
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showProgressHUDWithMessage:nil];
        });
    }
    else if(event == 1102)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
        });
    }
    else if(event == 1103)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideProgressHUD:YES];
            
        });
    }
}

@end
