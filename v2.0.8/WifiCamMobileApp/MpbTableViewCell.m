//
//  MpbTableViewCell.m
//  WifiCamMobileApp
//
//  Created by ZJ on 2017/3/24.
//  Copyright © 2017年 iCatchTech. All rights reserved.
//

#import "MpbTableViewCell.h"

@interface MpbTableViewCell()
{
    SSID_SerialCheck *SSIDSreial;
}

@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLab;
@property (weak, nonatomic) IBOutlet UILabel *fileDateLab;
@property (weak, nonatomic) IBOutlet UIImageView *LockIcon;

@property(weak, nonatomic) IBOutlet UIImageView *selectedComfirmIcon;
@property(weak, nonatomic) IBOutlet UIImageView *videoStaticIcon;

@end

@implementation MpbTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:NO];
    
   /* self.CellBackGroung.backgroundColor = [UIColor colorWithRed:76/255.0 green:29/255.0 blue:31/255.0 alpha:1];*/
    // Configure the view for the selected state
}


-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:NO animated:NO];
    
   /* self.CellBackGroung.backgroundColor = [UIColor colorWithRed:76/255.0 green:29/255.0 blue:31/255.0 alpha:1];*/
}
- (UILabel*) getCellLabel:(int) position {
    switch (position) {
        case 0:
            return self.fileNameLab;
            break;
        case 1:
            return self.fileSizeLab;
            break;
        case 2:
            return self.fileDateLab;
            break;
        default:
            return self.fileNameLab;
            break;
    }
}
- (UILabel*) getFileNameLabel {
    return self.fileNameLab;
}
- (void) setFileNameText:(NSString*)text {
    [self.fileNameLab setText:text];
}
- (void) setCellLabelSize:(CGFloat)labelSize {
    UIFont *font = self.fileNameLab.font;
    self.fileNameLab.font = [font fontWithSize:labelSize];
    self.fileSizeLab.font = [font fontWithSize:(labelSize-5.0)];
    self.fileDateLab.font = [font fontWithSize:(labelSize-5.0)];
}
- (void)setFile:(ICatchFile *)file DateFormat:(NSString*)dateFormat {
    SSIDSreial = [[SSID_SerialCheck alloc] init];
    
    
    if([SSIDSreial CheckSSIDSerial:self.SSID] == NOVATEK_SSIDSerial)
    {
        self.fileNameLab.text = [NSString stringWithFormat:@"%@",_NvtName];
        self.fileSizeLab.text = [self translateSize:_NvtSize>>10];
        self.fileDateLab.text = _NvtDate;
        self.videoStaticIcon.hidden = _NvtType == TYPE_IMAGE ? YES : NO;
    }
    else
    {
        self.fileNameLab.text = [NSString stringWithFormat:@"%s", file->getFileName().c_str()];
        self.fileSizeLab.text = [self translateSize:file->getFileSize()>>10];
        self.fileDateLab.text = [self translateDate:file->getFileDate() DateFormat:dateFormat];//[NSString stringWithFormat:@"%s", file->getFileDate().c_str()];
        self.videoStaticIcon.hidden = file->getFileType() == TYPE_IMAGE ? YES : NO;
    }
}

- (NSString *)translateSize:(unsigned long long)sizeInKB
{
    NSString *humanDownloadFileSize = nil;
    double temp = (double)sizeInKB/1024; // MB
    if (temp > 1024) {
        temp /= 1024;
        humanDownloadFileSize = [NSString stringWithFormat:@"%.2fGB", temp];
    } else {
        humanDownloadFileSize = [NSString stringWithFormat:@"%.2fMB", temp];
    }
    return humanDownloadFileSize;
}

- (NSString *)translateDate:(string)date DateFormat:(NSString*)dateFormat{
    NSMutableString *dateStr = [NSMutableString string];
    
    NSString *dateString = [NSString stringWithFormat:@"%s", date.c_str()];
    //AppLogDebug(AppLogTagAPP, @"dateString: %@", dateString);
    
    NSDate *date_ns;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (dateString.length == 15) {
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(0, 4)]];
        [dateStr appendString:@"/"];
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(4, 2)]];
        [dateStr appendString:@"/"];
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(6, 2)]];
        [dateStr appendString:@" "];
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(9, 2)]];
        [dateStr appendString:@":"];
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(11, 2)]];
        [dateStr appendString:@":"];
        [dateStr appendString:[dateString substringWithRange:NSMakeRange(13, 2)]];
        
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        date_ns=[dateFormatter dateFromString:dateStr];
        
        
        if([dateFormat  isEqual: @"DDMMYYYY"]) {
            [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
        } else if([dateFormat  isEqual: @"MMDDYYYY"]) {
            [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
        } else if([dateFormat  isEqual: @"YYYYMMDD"]) {
            [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        }
        dateStr = [dateFormatter stringFromDate:date_ns];
        
        return dateStr.copy;
    } else {
        return dateString;
    }
}

- (void)setSelectedConfirmIconHidden:(BOOL)value
{
    [self.selectedComfirmIcon setHidden:value];
}
- (void)setClickOffIcon
{
    [self.selectedComfirmIcon setImage:[UIImage imageNamed:@"check_off"]];
}
- (void)setClickOnIcon
{
    [self.selectedComfirmIcon setImage:[UIImage imageNamed:@"click_ok"]];
}
- (void)setClickIconHidden:(BOOL)value
{
    [self.selectedComfirmIcon setHidden:value];
}
- (void)setLockIconHidden:(BOOL)value
{
    [self.LockIcon setHidden:value];
}
- (void)setCellBGHidden:(BOOL)value;
{
    [self.CellBackGround setHidden:value];
}
- (void)setIconClear:(BOOL)value
{
    self.selectedComfirmIcon = nil;
}
- (void)setIconremove
{
    [self.selectedComfirmIcon removeFromSuperview];
}
@end
