//
//  VideoFileCutViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2018/9/5.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MBProgressHUD.h"
#import <Foundation/Foundation.h>
typedef NS_ENUM (NSInteger, MetadataSerial_Cut) {
    Cut_Novatake_6x = 0x0001,
    Cut_Novatake_5x,
    Cut_Novatake_7x,
    Cut_ICatchSerial,
    Cut_trim,
    Cut_NoneSerial,
};
enum {
    search_bottom,
    search_top
};
@interface VideoFileCutViewController : UIViewController<AppDelegateProtocol,UIGestureRecognizerDelegate>
@property (strong, nonatomic) NSString *NeedCutVideoName;
@property(nonatomic) MBProgressHUD *progressHUD;

@end
