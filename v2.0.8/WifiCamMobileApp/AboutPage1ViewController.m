//
//  AboutPage1ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/3.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "AboutPage1ViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@interface AboutPage1ViewController ()
{
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *title_label;
@property (weak, nonatomic) IBOutlet UILabel *dashcamInfo_label;
@property (weak, nonatomic) IBOutlet UILabel *model_label;
@property (weak, nonatomic) IBOutlet UILabel *modelName;
@property (weak, nonatomic) IBOutlet UILabel *curFirmwareVer;
@property (weak, nonatomic) IBOutlet UILabel *curFirmwareVerInfo;
@property (weak, nonatomic) IBOutlet UILabel *theLatestFirmwareVer;
@property (weak, nonatomic) IBOutlet UILabel *theLatestFirmwareVerInfo;
@property (weak, nonatomic) IBOutlet UILabel *wirelessLinkInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *wirelessLinkSSIDText;
@property (weak, nonatomic) IBOutlet UILabel *wirelessLinkSSIDDataText;
@property (weak, nonatomic) IBOutlet UILabel *wirelessLinkPasswordText;
@property (weak, nonatomic) IBOutlet UILabel *wirelessLinkPasswordDataText;
@property (weak, nonatomic) IBOutlet UILabel *satelliteInfoTitle;
@property (weak, nonatomic) IBOutlet UILabel *satelliteTotalText;
@property (weak, nonatomic) IBOutlet UILabel *satelliteTotalDataText;
@property (weak, nonatomic) IBOutlet UILabel *satellitePositionText;
@property (weak, nonatomic) IBOutlet UILabel *satellitePositionDataText;

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation AboutPage1ViewController
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

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    
    self.title_label.text = [delegate getStringForKey:@"SetDashCamInformationTitle" withTable:@""];
    self.dashcamInfo_label.text = [NSString stringWithFormat:@"%@:",[delegate getStringForKey:@"SetDashCamInformationTitle" withTable:@""]];
    self.model_label.text = [delegate getStringForKey:@"SetDeviceModel" withTable:@""];
    self.curFirmwareVer.text = [delegate getStringForKey:@"SetFirmwareVersion" withTable:@""];
    
    self.wirelessLinkInfoTitle.text = [delegate getStringForKey:@"SetWirelessLinkInformation" withTable:@""];
    self.wirelessLinkSSIDText.text = [delegate getStringForKey:@"SetWirelessLinkSSID" withTable:@""];
    self.wirelessLinkPasswordText.text = [delegate getStringForKey:@"SetWirelessLinkPassword" withTable:@""];
    self.satelliteInfoTitle.text = [delegate getStringForKey:@"SetSatelliteSignalInformation" withTable:@""];
    self.satelliteTotalText.text = [delegate getStringForKey:@"SetSatelliteSignalTotal" withTable:@""];
    self.satellitePositionText.text = [delegate getStringForKey:@"SetSatelliteSignalPosition" withTable:@""];
    _SSIDSreial = [[SSID_SerialCheck alloc] init];
    self.SSID = [self recheckSSID];
    if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        [_wirelessLinkInfoTitle setHidden:NO];
        [_wirelessLinkSSIDText setHidden:NO];
        [_wirelessLinkSSIDDataText setHidden:NO];
        [_wirelessLinkPasswordText setHidden:NO];
        [_wirelessLinkPasswordDataText setHidden:NO];
        [_satelliteInfoTitle setHidden:NO];
        [_satelliteTotalText setHidden:NO];
        [_satelliteTotalDataText setHidden:NO];
        [_satellitePositionText setHidden:NO];
        [_satellitePositionDataText setHidden:NO];
        
    } else {
        [_wirelessLinkInfoTitle setHidden:YES];
        [_wirelessLinkSSIDText setHidden:YES];
        [_wirelessLinkSSIDDataText setHidden:YES];
        [_wirelessLinkPasswordText setHidden:YES];
        [_wirelessLinkPasswordDataText setHidden:YES];
        [_satelliteInfoTitle setHidden:YES];
        [_satelliteTotalText setHidden:YES];
        [_satelliteTotalDataText setHidden:YES];
        [_satellitePositionText setHidden:YES];
        [_satellitePositionDataText setHidden:YES];
    }
    // Do any additional setup after loading the view.
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *str = @"";
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    if([_SSIDSreial MatchSSIDReturn:self.SSID] == D200GW)
    {
        self.modelName.text = @"BD200GW";
        str = [self NVTGetHttpCmd:@"3012"];
        
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == C1GW)
    {
        self.modelName.text = @"C1GW";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == CARDV312GW)
    {
        self.modelName.text = @"CARDV312GW";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == KVDR300W)
    {
        self.modelName.text = @"JVC KVDR300W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == KVDR400W)
    {
        self.modelName.text = @"JVC KVDR400W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == KVDR500W)
    {
        self.modelName.text = @"JVC KVDR500W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA301W)
    {
        self.modelName.text = @"KENWOOD DRVA301W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA401W)
    {
        self.modelName.text = @"KENWOOD DRVA401W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA501W)
    {
        self.modelName.text = @"KENWOOD DRVA501W";
        str = [self NVTGetHttpCmd:@"3012"];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == KVDR600W)
    {
        self.modelName.text = @"KENWOOD KVDR600W";
        str = [[SDK instance] retrieveCameraFWVersion];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA601W)
    {
        self.modelName.text = @"KENWOOD DRVA601W";
        str = [[SDK instance] retrieveCameraFWVersion];
    }
    else if([_SSIDSreial MatchSSIDReturn:self.SSID] == DRVA700W)
    {
        self.modelName.text = @"KENWOOD DRVA700W";
        str = [self NVTGetHttpCmd:@"3012"];
        [self NVTGetHttpCmd:@"3029"];//SSID
        [_wirelessLinkSSIDDataText setText:[_NVTGetHttpValueDict objectForKey:@"SSID"]];
        [_wirelessLinkPasswordDataText setText:[_NVTGetHttpValueDict objectForKey:@"WirelessLinkPassword"]];
        [_satelliteTotalDataText setText:[self NVTGetHttpCmd:@"3202"]];
        if([[self NVTGetHttpCmd:@"3123"] isEqualToString:@"-1"]) {
            [_satellitePositionDataText setText:[delegate getStringForKey:@"SetSatelliteSignalInvalid" withTable:@""]];
        } else {
            [_satellitePositionDataText setText:[delegate getStringForKey:@"SetSatelliteSignalValid" withTable:@""]];
        }
        
    }
    else
    {
        self.modelName.text = @"";
    }
    self.curFirmwareVerInfo.text = str ;
}
- (IBAction)backTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIViewController *vc = [[self.navigationController viewControllers] firstObject];
    if([vc isEqual:self]) {
        
        [self dismissViewControllerAnimated:NO completion:^{}];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
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
    
    return [self.NVTGetHttpValueDict objectForKey:cmd];
    
    
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
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"SSID"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        ssidFlag = YES;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"PASSPHRASE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        ssidFlag = NO;
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

@end
