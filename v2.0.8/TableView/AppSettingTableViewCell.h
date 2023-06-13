//
//  AppSettingTableViewCell.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/13.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppSettingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *leftText;
@property (weak, nonatomic) IBOutlet UILabel *rightText;
@property (weak, nonatomic) IBOutlet UILabel *centerText;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

NS_ASSUME_NONNULL_END
