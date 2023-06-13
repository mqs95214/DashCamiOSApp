//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "SetWirelessPasswordViewController.h"

@interface SetWirelessPasswordViewController ()
{
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation SetWirelessPasswordViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *passwordStr = @"";
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetWirelessLinkPasswordTitle" withTable:@""]];
    _backBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetBack" withTable:@""]];
    _nextBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNext" withTable:@""]];
    _passwordPrompt.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetPleaseInsert8Characters" withTable:@""]];
    _passwordConfirmPrompt.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetPleaseInsert8Characters" withTable:@""]];
    _passwordText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetPassword" withTable:@""]];
    _passwordCheckText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetDoubleCheckPassword" withTable:@""]];
    _NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    
    [self NVTGetHttpCmd:@"3029"];//SSID
    passwordStr = [_NVTGetHttpValueDict objectForKey:@"WirelessLinkPassword"];
    [_passwordTextField setText:passwordStr];
    [_passwordConfirmTextField setText:passwordStr];
    
    self.passwordTextField.delegate = self;
    self.passwordConfirmTextField.delegate = self;
    [_nextBtn setEnabled:YES];
}
- (IBAction)backBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *str = @"";
    if([_passwordConfirmTextField.text isEqualToString:_passwordTextField.text]) {
        str = [NSString stringWithFormat:@"%@",_passwordConfirmTextField.text];
        [self NVTSendHttpCmd:@"3004" Par2:str];
    }
    //NSLog(@"aaaaaa->   %@",[self NVTGetHttpCmd:@"3029"]);
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    FormatSDCardViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamFormat"];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.passwordTextField resignFirstResponder];
    [self.passwordConfirmTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
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
                    [_nextBtn setEnabled:YES];
                }
            } else {
                [_nextBtn setEnabled:NO];
            }
        }
        if(textField == self.passwordConfirmTextField) {
            if(self.passwordTextField.text.length == 8 &&
               textField.text.length >= 7 && string.length == 1) {
                NSString *str = [NSString stringWithFormat:@"%@%@",textField.text,string];
                if([str isEqualToString:_passwordTextField.text]) {
                    [_nextBtn setEnabled:YES];
                }
            } else {
                [_nextBtn setEnabled:NO];
            }
        }
        if(textField.text.length < 8 || string.length == 0 || range.length > 0) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
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

-(BOOL) isAllowInput:(NSString*)inputString {
    NSString *allowString = @"1234567890abcdefghijklmnopqrstupwxyzABCDEFGHIJKLMNOPQRSTUPWXYZ";
    NSCharacterSet *cs = [NSCharacterSet characterSetWithCharactersInString:allowString];
    NSString *outputString = [[inputString componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    return ![inputString isEqualToString:outputString];
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
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"MovieLiveViewLink"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = YES;
        ssidFlag = NO;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"SSID"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = YES;
        passwordFlag = NO;
    }
    else if([elementName isEqualToString:@"PASSPHRASE"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = YES;
    }
    else{
        storingFlag = FALSE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
        ssidFlag = NO;
        passwordFlag = NO;
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
