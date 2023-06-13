//
//  InstructionContentViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/13.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface InstructionContentViewController : UIViewController

@property (nonatomic) int receiver;
enum {
    mainScreen_e,
    preview_e,
    filesonDashcam_e,
    filesonMobile_e,
    dashcamMenu_e
};

@end

NS_ASSUME_NONNULL_END
