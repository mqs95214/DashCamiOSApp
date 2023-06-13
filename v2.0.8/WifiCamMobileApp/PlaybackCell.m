//
//  PlaybackCell.m
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/5/16.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "PlaybackCell.h"

@implementation PlaybackCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:NO];

    self.cellBack.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.298];
    // Configure the view for the selected state
}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:NO];
    
    self.cellBack.backgroundColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:0.298];
}
@end
