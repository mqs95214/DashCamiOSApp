//
//  SetupSettingTableViewCell.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/9.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "SetupSettingTableViewCell.h"

@implementation SetupSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.SwitchViewer.backgroundColor = [UIColor colorWithRed:179/255.0 green:179/255.0 blue:179/255.0 alpha:1];
    self.SwitchViewer.layer.cornerRadius = 16.0;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    //动画高亮变色效果
    [UIView animateWithDuration:0.3 animations:^{
        if(highlighted)
            self.contentView.backgroundColor = [UIColor colorWithRed:129/255.0 green:131/255.0 blue:141/255.0 alpha:0.3];
        else
            self.contentView.backgroundColor = [UIColor clearColor];
    }];
    
}
@end
