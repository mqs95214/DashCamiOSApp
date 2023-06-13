//
//  AboutPage4ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AboutPage4ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *instructionTitle;
@property (weak, nonatomic) IBOutlet UILabel *mainScreenText;
@property (weak, nonatomic) IBOutlet UILabel *previewText;
@property (weak, nonatomic) IBOutlet UILabel *filesonDashCamText;
@property (weak, nonatomic) IBOutlet UILabel *filesonMobileText;
@property (weak, nonatomic) IBOutlet UILabel *dashCamMenuText;
@property (nonatomic) int sendData;
@end

NS_ASSUME_NONNULL_END
