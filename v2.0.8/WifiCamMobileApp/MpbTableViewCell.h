//
//  MpbTableViewCell.h
//  WifiCamMobileApp
//
//  Created by ZJ on 2017/3/24.
//  Copyright © 2017年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSID_SerialCheck.h"
@interface MpbTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *CellBackGround;

@property (weak, nonatomic) IBOutlet UIImageView *fileThumbs;

@property (nonatomic) NSString *NvtName;
@property (nonatomic) unsigned long long NvtSize;
@property (nonatomic) NSString *NvtDate;
@property (nonatomic) int NvtType;
@property (nonatomic) NSString *SSID;
- (void)setFile:(ICatchFile *)file DateFormat:(NSString*)dateFormat;
- (void)setSelectedConfirmIconHidden:(BOOL)value;
- (void)setClickIconHidden:(BOOL)value;
- (void)setClickOffIcon;
- (void)setClickOnIcon;
- (void)setLockIconHidden:(BOOL)value;
- (void)setCellBGHidden:(BOOL)value;
- (void)setIconClear:(BOOL)value;
- (void)setIconremove;
- (UILabel*) getFileNameLabel;
- (void) setCellLabelSize:(CGFloat)labelSize;
- (UILabel*) getCellLabel:(int)position;
- (void) setFileNameText:(NSString*)text;
@end
