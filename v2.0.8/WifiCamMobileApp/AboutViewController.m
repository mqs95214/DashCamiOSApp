//
//  AboutViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2018/8/8.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "AboutViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
@interface AboutViewController ()
{
    SSID_SerialCheck *SSIDSreial;
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *AboutLabel;
@property (weak, nonatomic) IBOutlet UILabel *DeviceInfomation;
@property (weak, nonatomic) IBOutlet UILabel *Model;
@property (weak, nonatomic) IBOutlet UILabel *FirmwareVersion;
@property (weak, nonatomic) IBOutlet UILabel *AppInformation;
@property (weak, nonatomic) IBOutlet UILabel *JVCViewer;
//@property (weak, nonatomic) IBOutlet UILabel *CansonicIQViewer;
@property (weak, nonatomic) IBOutlet UILabel *Version;
//@property (weak, nonatomic) IBOutlet UILabel *CopyRight;
@property (weak, nonatomic) IBOutlet UILabel *ModelName;
@property (weak, nonatomic) IBOutlet UILabel *FirmwareNumber;
@property (weak, nonatomic) IBOutlet UILabel *VersionNum;
@property(nonatomic) NSString *SSID;
@property(nonatomic,strong)NSBundle *bundle;
@property (weak, nonatomic) IBOutlet UILabel *dashcamInformationText;
@property (weak, nonatomic) IBOutlet UILabel *appInformationText;
@property (weak, nonatomic) IBOutlet UILabel *appSettingText;
@property (weak, nonatomic) IBOutlet UILabel *instructionText;
@property (weak, nonatomic) IBOutlet UILabel *visitWebsite;

@end

@implementation AboutViewController
- (IBAction)DashcamInfoTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self performSegueWithIdentifier:@"aboutpage1_push" sender:sender];
}
- (IBAction)AppInfoTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self performSegueWithIdentifier:@"aboutpage2_push" sender:sender];
}
- (IBAction)AppSettingTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self performSegueWithIdentifier:@"aboutpage3_push" sender:sender];
}
- (IBAction)InstructionTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self performSegueWithIdentifier:@"aboutpage4_push" sender:sender];
}
- (IBAction)VisitWebsiteTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //[self performSegueWithIdentifier:@"aboutpage5_push" sender:sender];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://www.kenwood.com/cs/ce/"]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [delegate initLanguage];
    self.AboutLabel.text = [delegate getStringForKey:@"SETTING_ABOUT" withTable:@""];
    
    self.dashcamInformationText.text = [delegate getStringForKey:@"SetDashCamInformationTitle" withTable:@""];
    self.appInformationText.text = [delegate getStringForKey:@"SetAppInformationTitle" withTable:@""];
    self.appSettingText.text = [delegate getStringForKey:@"SetAppSettingTitle" withTable:@""];
    self.instructionText.text = [delegate getStringForKey:@"SetInstructionTitle" withTable:@""];
    self.visitWebsite.text = [delegate getStringForKey:@"SetVisitWebsiteTitle" withTable:@""];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    
    
    /*
    self.SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    // Do any additional setup after loading the view.
    self.AboutLabel.text = NSLocalizedString(@"SetAbout",@"");
    self.DeviceInfomation.text = NSLocalizedString(@"SetDeviceInformation", nil);
    self.Model.text = NSLocalizedString(@"SetDeviceModel", nil);
    self.FirmwareVersion.text = NSLocalizedString(@"SetFirmwareVersion", nil);
    self.AppInformation.text = NSLocalizedString(@"SetAppInformation", nil);
    //self.CansonicIQViewer.text = NSLocalizedString(@"SetIQViewer", nil);
    self.JVCViewer.text = NSLocalizedString(@"SetIQViewer", nil);
    self.Version.text = NSLocalizedString(@"SetAboutVersionTitle", nil);
    self.VersionNum.text = NSLocalizedString(@"SetAboutVersion", nil);
    //self.CopyRight.text = NSLocalizedString(@"SetCopyRight", nil);
    
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    if([SSIDSreial MatchSSIDReturn:self.SSID] == D200GW)
    {
        self.ModelName.text = @"BD200GW";
        [self NVTGetHttpCmd:@"3012"];
    
    }
    else if([SSIDSreial MatchSSIDReturn:self.SSID] == C1GW)
    {
         self.ModelName.text = @"C1GW";
        [self NVTGetHttpCmd:@"3012"];
    }
    else
    {
        self.ModelName.text = @"";
    }
    self.FirmwareNumber.text = [self.NVTGetHttpValueDict objectForKey:@"3012"];
    */
   /* "SetDeviceInformation" = "Device Information: ";
    "SetDeviceModel" = "Model: ";
    "SetFirmwareVersion" = "Firmware Ver: ";
    "SetAppInformation" = "App Information: ";
    "SetIQViewer" = "Cansonic iQ Viewer";
    "SetAboutVersionTitle" = "Version: ";
    "SetAboutVersion" = "V1.0_AHZEBB_A";
    "SetCopyRight" = "Copyright © 2017 Cansonic Inc. All rights reserved."*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*- (IBAction)OpenUrlLink:(id)sender {
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://tw.cansonic.com"]];
}*/
- (IBAction)goHome:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self dismissViewControllerAnimated:YES completion:^{
        AppLog(@"Setting -- QUIT");
        
    }];
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
    NSLog(@"GetValue = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    
    return [self.NVTGetHttpValueDict objectForKey:cmd];

    
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
@end
