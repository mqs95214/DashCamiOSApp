//
//  PlayerViewController.h
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/5/18.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>

@interface PlayerViewController : UIViewController

@property PHAsset *mediaAsset;
@property (strong,nonatomic) AVPlayerViewController *avPlayerViewController;
@property (strong,nonatomic) AVPlayer *avPlayer;

@end
