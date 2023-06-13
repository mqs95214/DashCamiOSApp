//
//  SetupSettingTableViewCell.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/9.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SetupSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *SetupItemLabel;
@property (weak, nonatomic) IBOutlet UILabel *SetupDetailLabel;
@property (weak, nonatomic) IBOutlet UISwitch *SwitchViewer;

@end

NS_ASSUME_NONNULL_END
