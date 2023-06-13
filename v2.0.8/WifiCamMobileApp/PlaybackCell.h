//
//  PlaybackCell.h
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/5/16.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaybackCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *fileNameLB;
@property (weak, nonatomic) IBOutlet UIButton *tapToPlay;
@property (weak, nonatomic) IBOutlet UIButton *checkBT;
@property (weak, nonatomic) IBOutlet UIView *cellBack;

@property (weak, nonatomic) IBOutlet UIImageView *Filethumbnail;
@property (weak, nonatomic) IBOutlet UIImageView *CheckBox;
@property (weak, nonatomic) IBOutlet UILabel *FileName;
@property (weak, nonatomic) IBOutlet UILabel *PhotoCreateTime;
@property (weak, nonatomic) IBOutlet UILabel *FileLenth;
@property (weak, nonatomic) IBOutlet UIImageView *LockBox;
@property (weak, nonatomic) IBOutlet UIImageView *PlayIcon;
@property (weak, nonatomic) IBOutlet UILabel *FileSize;
@end
