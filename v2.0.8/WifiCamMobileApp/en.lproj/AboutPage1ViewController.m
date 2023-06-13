//
//  AboutPage1ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "AboutPage1ViewController.h"

@interface AboutPage1ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *dashcaminfo_label;
@property (weak, nonatomic) IBOutlet UILabel *model_label;
@property (weak, nonatomic) IBOutlet UILabel *modelName;
@property (weak, nonatomic) IBOutlet UILabel *curFirmwareVer;
@property (weak, nonatomic) IBOutlet UILabel *curFirmwareVerInfo;
@property (weak, nonatomic) IBOutlet UILabel *theLetestFirmwareVer;
@property (weak, nonatomic) IBOutlet UILabel *theLatestFirmwareVerInfo;


@end

@implementation AboutPage1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dashcaminfo_label.adjustsFontSizeToFitWidth = YES;
    _model_label.adjustsFontSizeToFitWidth = YES;
    _modelName.adjustsFontSizeToFitWidth = YES;
    _curFirmwareVer.adjustsFontSizeToFitWidth = YES;
    _curFirmwareVerInfo.adjustsFontSizeToFitWidth = YES;
    _theLetestFirmwareVer.adjustsFontSizeToFitWidth = YES;
    _theLatestFirmwareVerInfo.adjustsFontSizeToFitWidth = YES;
    // Do any additional setup after loading the view.
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
