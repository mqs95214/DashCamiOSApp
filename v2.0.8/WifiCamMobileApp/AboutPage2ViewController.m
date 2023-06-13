//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "AboutPage2ViewController.h"

@interface AboutPage2ViewController ()
{
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation AboutPage2ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    NSString *version = [NSString stringWithFormat:@"V%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSLog(@"AboutPage2ViewController");
    [_appinformationTitle setText:[delegate getStringForKey:@"SetAppInformationTitle" withTable:@""]];
    [_appInfo setText:[delegate getStringForKey:@"SetAppInformation" withTable:@""]];
    [_productName setText:[delegate getStringForKey:@"SetProductName" withTable:@""]];
    [_appVersionName setText:[delegate getStringForKey:@"SetAboutVersionTitle" withTable:@""]];
    [_appVersion setText:version];
    

    // Do any additional setup after loading the view.
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
