//
//  CustomSettingSubViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/7.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

typedef enum CustomSettingDetailType{
    SettingDetailTypeWhiteBalance = 0,
    SettingDetailTypePowerFrequency,
    SettingDetailTypeBurstNumber,
    SettingDetailTypeAbout,
    SettingDetailTypeDateStamp,
    SettingDetailTypeTimelapseType,
    SettingDetailTypeTimelapseInterval,
    SetttngDetailTypeTimelapseDuration,
    SettingDetailTypeUpsideDown,
    SettingDetailTypeSlowMotion,
    SettingDetailTypeImageSize,
    SettingDetailTypeVideoSize,
    SettingDetailTypeCaptureDelay,
    SettingDetailTypeLiveSize,
    //add - 2017.3.17
    SettingDetailTypeScreenSaver,
    SettingDetailTypeAutoPowerOff,
    SettingDetailTypeExposureCompensation,
    SettingDetailTypePhotoExposureCompensation,
    SettingDetailTypePhotoBurst,
    SettingDetailTypeDelayTimer,
    SettingDetailTypeParkingModeSensor,
    SettingDetailTypeGSensor,
    SettingDetailTypeVideoSizeInt,
    SettingDetailTypeVideoQuality,
    SettingDetailTypeVideoFileLength,
    SettingDetailTypeFastMotionMovie,
    SettingDetailTypePowerOnAutoRecord,
    SettingDetailTypeGPS,
    SettingDetailTypeSpeedUnit,
    SettingDetailTypeSDFormat,
    SettingDetailTypeLicensePlateStamp,
    SettingDetailTypeCansonicStamp,
    SettingDetailTypeTimeAndDateStamp,
    SettingDetailTypePhotoTimeAndDateStamp,
    SettingDetailTypeInformationStamp,
    SettingDetailTypeImageStabilization,
    SettingDetailTypeWindNoiseReduction,
    SettingDetailTypeTimeZone,
    SettingDetailTypeDateTime,
    SettingDetailTypeLanguage,
    SettingDetailTypeCountry,
    SettingDetailTypeDeviceSounds,
    SettingDetailTypeResetAll,
    SettingDetailTypeAudioRecording,
    SettingDetailTypeUltraDashStamp,
    SettingDetailTypeRotateDisplay,
    SettingDetailTypeNvtParkingModeSensor,
    SettingDetailTypeNvtDeviceSounds,
    SettingDetailTypeNvtGPS,
    /*add Tom*/
    SettingDetailTypeSpeedStamp,
    SettingDetailTypeModelNumberStamp,
    SettingDetailTypeSpeedDisplay,
    SettingDetailTypeAnnouncement,
    SettingDetailTypeKeepUserSetting,
    /**/
    SettingDetailTypePasswordChange,
}SettingDetailType;

typedef enum CustomSettingDetailTableInfo {
    SettingDetailTableTextLabel,
    SettingDetailTableDetailTextLabel,
    SettingDetailTableDetailType,
    SettingDetailTableDetailData,
    SettingDetailTableDetailLastItem,
    
}SettingDetailTableInfo;

typedef enum CustomSettingDeviceSoundsMenuInfo {
    SettingBeep,
    SettingAudioRec,
    SettingAnnouncements,
    
}SettingDeviceSoundsMenuInfo;

@interface CustomSettingSubViewController : UIViewController <UITextFieldDelegate,NSXMLParserDelegate,AppDelegateProtocol,UITableViewDelegate, UITableViewDataSource>
{
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    BOOL storingFlag; //查询标签所对应的元素是否存在
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StringFlag;
    BOOL FileListFlag;
    BOOL NameFlag;
    BOOL FpathFlag;
    BOOL SizeFlag;
    BOOL TimeCodeFlag;
    BOOL TimeFlag;
    BOOL LockFlag;
    BOOL AttrFlag;
    BOOL StoreFlag;
    BOOL isVideo;
    NSArray *elementToParse;  //要存储的元素
    NSFileHandle *fileHandle;
    int FileNumber;
    NSString *tmpPath;
    NSString *tmpfilePath;
}



@property NSArray *subMenuTable;
@property NSInteger curSettingDetailType;
@property NSInteger curSettingDetailItem;
@property NSInteger curState;
@property (weak, nonatomic) IBOutlet UILabel *passwordText;
@property (weak, nonatomic) IBOutlet UILabel *passwordConfirmText;
@end

NS_ASSUME_NONNULL_END
