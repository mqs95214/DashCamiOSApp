//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "SelectInitPositionViewController.h"

@interface SelectInitPositionViewController ()
{
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation SelectInitPositionViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([SSIDSreial CheckSSIDSerial:SSID] == NOVATEK_SSIDSerial)
    {
        self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
        if(_np == nil)
        {
            [self nodePlayerInit];
            [self NodePlaySetUrl];
            //[self NodePlayerStart];
        }
        else
        {
            [self NodePlayerStop];
            [self NodePlaySetUrl];
            [self NodePlayerStart];
        }
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectInstallationPosition" withTable:@""]];
    _backBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetBack" withTable:@""]];
    _nextBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNext" withTable:@""]];
    
    _info1.text = [NSString stringWithFormat:@"%@\n%@\n\n%@\n%@\n%@\n%@\n%@\n%@",[delegate getStringForKey:@"SetSelectInstallationPositionInfo1" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo2" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo3" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo4" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo5" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo6" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo7" withTable:@""],[delegate getStringForKey:@"SetSelectInstallationPositionInfo8" withTable:@""]];
    
    SSID = [self recheckSSID];
    SSIDSreial = [[SSID_SerialCheck alloc] init];
}
-(void)viewWillAppear:(BOOL)animated {
    UILabel *label;
    label = [self getLenghtText];
    UIFont *font;
    font = [self adjFontSize:label];
    CGFloat fontSize = font.pointSize;
    self.info1.font = [font fontWithSize:fontSize];
}
- (IBAction)backBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    SetCompletedViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamCompleted"];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) nodePlayerInit {
    _np = [[NodePlayer alloc] init];
    [_np setNodePlayerDelegate:self];
    [_np setBufferTime:1000];
    [_np setContentMode:UIViewContentModeScaleToFill];
    
    [_np setPlayerView:self.nodePlayerView];
}
-(void)NodePlaySetUrl
{
    //[_np setInputUrl:@"http://192.168.1.254:8192"];
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
        if(count == 0) {
            str = self.info1.text;
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
    rect = [self.info1 bounds];
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

- (NSString*)getStringForKey:(NSString*)key withTable:(NSString*)table {
    if(_bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, _bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"dashcamHome_show"]) {
        UIViewController *controller = segue.destinationViewController;
        if([controller isKindOfClass:[UINavigationController class]]) {
            NSLog(@"dashcamHome_show->UINavigationController");
        }
    }
}
-(void) performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    

}
- (IBAction)Back:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
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
