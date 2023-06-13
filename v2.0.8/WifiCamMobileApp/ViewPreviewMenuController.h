//
//  ViewController.h
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NodeMediaClient/NodeMediaClient.h>

#import "FileListViewController.h"
#import "ViewController.h"
#include "WifiCamSDKEventListener.h"
#import "WifiCamManager.h"
#import "WifiCamControl.h"
#import "Camera.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#include "PreviewSDKEventListener.h"
#include "WifiCamControlCenter.h"
#import "DashcamInitViewController.h"
@class Camera;
@interface ViewPreviewMenuController : UIViewController<UIAlertViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
NSXMLParserDelegate,
AppDelegateProtocol,
//SettingDelegate,
NodePlayerDelegate,
CLLocationManagerDelegate>
{
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    
    
    BOOL storingFlag; //查询标签所对应的元素是否存在
    
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StringFlag;
    BOOL MovieLiveFlag;
    BOOL StrogeValueFlag;
    BOOL ssidFlag;
    BOOL passwordFlag;
    
    NSArray *elementToParse;  //要存储的元素
    
    int reconnectCount;
}

@property(nonatomic) MBProgressHUD *progressHUD;
@property (weak, nonatomic) IBOutlet UIButton *MatchButton;

@property (weak, nonatomic) IBOutlet UILabel *NoPreviewLine1;
@property (weak, nonatomic) IBOutlet UILabel *NoPreviewLine2;
@property (weak, nonatomic) IBOutlet UILabel *NoPreviewLine3;
@property (weak, nonatomic) IBOutlet UILabel *NoPreviewLine4;
@property (weak, nonatomic) IBOutlet UIView *NoPreviewView;
@property (weak, nonatomic) IBOutlet UIView *UpperPreview;
@property (weak, nonatomic) IBOutlet UIImageView *Playback_BtnImage;
@property (weak, nonatomic) IBOutlet UIImageView *Setting_BtnImage;
@property (weak, nonatomic) IBOutlet UIButton *Playback_Btn;
@property (weak, nonatomic) IBOutlet UIButton *Setting_Btn;
@property (weak, nonatomic) IBOutlet UIView *K7_Display_View;
@property (weak, nonatomic) IBOutlet UIView *preview_View;
@property (weak, nonatomic) IBOutlet UILabel *timeDateInfoText;
@property (weak, nonatomic) IBOutlet UILabel *countryTimeZoneText;
@property (weak, nonatomic) IBOutlet UILabel *lastFormatDateText;
@property (weak, nonatomic) IBOutlet UIButton *audioOnBtn;
@property (weak, nonatomic) IBOutlet UIButton *audioOffBtn;
@property (weak, nonatomic) IBOutlet UILabel *timeDateTitleText;
@property (weak, nonatomic) IBOutlet UILabel *sdCardInfoTitleText;
@property (weak, nonatomic) IBOutlet UILabel *lastFormatDateInfoText;
@property (weak, nonatomic) IBOutlet UILabel *systemInfoText;
@property (weak, nonatomic) IBOutlet UILabel *audioRecText;

@property (nonatomic, strong) Camera *savedCamera;
@end



