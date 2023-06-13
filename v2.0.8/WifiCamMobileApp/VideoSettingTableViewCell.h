//
//  VideoSettingTableViewCell.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/9.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *VideoItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *VideoDetailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewer;

@end

NS_ASSUME_NONNULL_END
