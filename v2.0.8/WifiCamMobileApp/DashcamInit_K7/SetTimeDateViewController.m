//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "SetTimeDateViewController.h"

@interface SetTimeDateViewController ()
{
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation SetTimeDateViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetTimeandDate" withTable:@""]];
    _timeText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetTime" withTable:@""]];
    _dateText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetDate" withTable:@""]];
    _backBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetBack" withTable:@""]];
    _nextBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNext" withTable:@""]];
    if([[delegate getDateFormat]  isEqual: @"DDMMYYYY"]) {
        dateFormat = @"DDMMYYYY";
    } else if([[delegate getDateFormat]  isEqual: @"MMDDYYYY"]) {
        dateFormat = @"MMDDYYYY";
    } else if([[delegate getDateFormat]  isEqual: @"YYYYMMDD"]) {
        dateFormat = @"YYYYMMDD";
    } else {
        dateFormat = @"DDMMYYYY";
    }
    if([[delegate getTimeFormat] isEqualToString:@"12H"]) {
        timeFormat = @"12H";
    } else if([[delegate getTimeFormat] isEqualToString:@"24H"]) {
        timeFormat = @"24H";
    } else {
        timeFormat = @"12H";
    }
    [self initDateText];
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    [self initDatePicker];
    [_DatePickerView setHidden:YES];
}
- (IBAction)backBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *str = @"";
    NSLog(@"%@",[self NVTGetHttpCmd:@"3119"]);
    //set date
    str = [_dateBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" / " withString:@"-"];
    [self NVTSendHttpCmd:@"3005" Par2:str];
    str = [_timeBtn.titleLabel.text stringByReplacingOccurrencesOfString:@" : " withString:@":"];
    [self NVTSendHttpCmd:@"3006" Par2:str];
    NSLog(@"%@",[self NVTGetHttpCmd:@"3119"]);
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    SelectSpeedUnitsViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamSpeedUnit"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)timeBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [_timeBtn setBackgroundImage:[UIImage imageNamed:@"info_square_select"] forState:UIControlStateNormal];
    [_dateBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_DatePickerView setHidden:NO];
    [self initTimePicker];
}

- (IBAction)dateBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [_timeBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_dateBtn setBackgroundImage:[UIImage imageNamed:@"info_square_select"] forState:UIControlStateNormal];
    [_DatePickerView setHidden:NO];
    [self initDatePicker];
}
- (IBAction)confirmDateBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSDate *date = [_datePicker date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *nowString = [formatter stringFromDate:date];
    nowString = [nowString stringByReplacingOccurrencesOfString:@":" withString:@" : "];
    nowString = [nowString stringByAppendingString:@" : 00"];
    [_timeBtn setTitle:nowString forState:UIControlStateNormal];
    
    [formatter setDateFormat:@"YYYY/MM/dd"];
    nowString = [formatter stringFromDate:date];
    nowString = [nowString stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
    
    [_dateBtn setTitle:nowString forState:UIControlStateNormal];
    [_timeBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_dateBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_DatePickerView setHidden:YES];
}
- (IBAction)cancelDateBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [_timeBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_dateBtn setBackgroundImage:[UIImage imageNamed:@"info_square"] forState:UIControlStateNormal];
    [_DatePickerView setHidden:YES];
}
/*-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [_DatePickerView setHidden:YES];
}*/
-(void)initDatePicker {
    NSString *curLocale = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:curLocale];
    [_datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    [_datePicker setDatePickerMode:UIDatePickerModeDate];
}

-(void)initTimePicker {
    [_datePicker setValue:[UIColor whiteColor] forKey:@"textColor"];
    [_datePicker setDatePickerMode:UIDatePickerModeTime];
    if([timeFormat  isEqual: @"12H"]) {//en_US en_GB
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    } else {
        _datePicker.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_GB"];
    }
}
-(void) initDateText {
    NSString *strDate;
    NSString *displayDateStr = @"",*year,*month,*day;
    NSDate *date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate *currentDate =[[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *nowString = [formatter stringFromDate:currentDate];
    strDate = [NSString stringWithFormat:@"%@",nowString];
    nowString = [nowString stringByReplacingOccurrencesOfString:@":" withString:@" : "];
    nowString = [nowString stringByAppendingString:@" : 00"];
    [_timeBtn setTitle:nowString forState:UIControlStateNormal];
    
    [formatter setDateFormat:@"YYYY/MM/dd"];
    nowString = [formatter stringFromDate:date];
    strDate = [NSString stringWithFormat:@"%@ %@:00",nowString,strDate];
    nowString = [nowString stringByReplacingOccurrencesOfString:@"/" withString:@" / "];
    displayDateStr = nowString;
    NSRange range = [nowString rangeOfString:@" / "];
    if(range.location != NSNotFound) {
        year = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
        displayDateStr = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
        range = [displayDateStr rangeOfString:@" / "];
        if(range.location != NSNotFound) {
            month = [displayDateStr substringWithRange:NSMakeRange(0, range.location)];
            day = [displayDateStr substringWithRange:NSMakeRange(range.location+range.length, displayDateStr.length-range.location-range.length)];
        }
    }
    if([dateFormat  isEqual: @"DDMMYYYY"]) {
        displayDateStr = [NSString stringWithFormat:@"%@ / %@ / %@",day,month,year];
    } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
        displayDateStr = [NSString stringWithFormat:@"%@ / %@ / %@",month,day,year];
    } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
        displayDateStr = [NSString stringWithFormat:@"%@ / %@ / %@",year,month,day];
    }
    [_dateBtn setTitle:displayDateStr forState:UIControlStateNormal];
    
    strDate = [strDate stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSDate *setDate = [formatter dateFromString:strDate];
    [_datePicker setDate:setDate];
}

- (void)NVTSendHttpCmd:(NSString *)cmd Par2:(NSString *)par{
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
