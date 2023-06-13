//
//  WifiCamPropertyControl.h
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 14-6-23.
//  Copyright (c) 2014年 iCatchTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WifiCamAlertTable.h"
#import "WifiCamAVData.h"

@interface WifiCamPropertyControl : NSObject

// Inquire state info
//- (BOOL)isMediaStreamRecording;
//-(BOOL)isVideoTimelapseOn;
//-(BOOL)isStillTimelapseOn;
- (BOOL)connected;
- (BOOL)checkSDExist;
- (BOOL)videoStreamEnabled;
- (BOOL)audioStreamEnabled;

// Change those property value
-(int)changeImageSize:(string)size;
-(int)changeVideoSize:(string)size;
-(int)changeDelayedCaptureTime:(unsigned int)time;
-(int)changeWhiteBalance:(unsigned int)value;
-(int)changeLightFrequency:(unsigned int)value;
-(int)changeBurstNumber:(unsigned int)value;
-(int)changeDateStamp:(unsigned int)value;
-(int)changeTimelapseType:(ICatchPreviewMode)mode;
-(int)changeTimelapseInterval:(unsigned int)value;
-(int)changeTimelapseDuration:(unsigned int)value;
-(int)changeUpsideDown:(uint)value;
-(int)changeSlowMotion:(uint)value;
-(BOOL)SetCustomLock:(NSString *)ssid;
-(BOOL)changeSSID:(NSString *)ssid;

-(BOOL)changePassword:(NSString *)password;

- (BOOL)changeScreenSaver:(uint)curScreenSaver;
- (uint)parseScreenSaverInArray:(NSInteger)index;
- (BOOL)changeAutoPowerOff:(uint)curAutoPowerOff;
- (uint)parseAutoPowerOffInArray:(NSInteger)index;
- (BOOL)changeParkingModeSensor:(uint)curParkingModeSensor;
- (BOOL)changeVideoSize2:(uint)curVideoSize;
- (BOOL)changeGSensor:(uint)curGSensor;
- (BOOL)changeSpeedUnit:(uint)curSpeedUnit;
- (BOOL)changePhotoBurst:(uint)curPhotoBurst;
- (BOOL)changeSDFormat;
- (BOOL)changeResetAll:(uint)curResetAll;
- (BOOL)changeDelayTimer:(uint)curDelayTimer;
- (BOOL)changeTimeZone:(uint)curTimeZone;
- (BOOL)changeLanguage:(uint)curLanguage;
- (BOOL)changeExposureCompensation:(uint)curExposureCompensation;
- (BOOL)changePhotoExposureCompensation:(uint)curExposureCompensation;
- (uint)parseParkingModeSensorInArray:(NSInteger)index;
- (uint)parseGSensorInArray:(NSInteger)index Model:(int)ModelName;
- (uint)parseSpeedUnitInArray:(NSInteger)index;
- (uint)parsePhotoBurstInArray:(NSInteger)index;
- (uint)parseDelayTimerInArray:(NSInteger)index;
- (uint)parseTimeZoneInArray:(NSInteger)index;
- (uint)parseLanguageInArray:(NSInteger)index Model:(int)ModelName;;
- (uint)parseExposureCompensationInArray:(NSInteger)index Model:(int)ModelName;
- (uint)parsePhotoExposureCompensationInArray:(NSInteger)index Model:(int)ModelName;
- (BOOL)changeVideoQuality:(uint)curVideoQuality;
- (BOOL)changeVideoFileLength:(uint)curVideoFileLength;
- (uint)parseVideoQualityInArray:(NSInteger)index;
- (uint)parseVideoFileLengthInArray:(NSInteger)index Model:(int)ModelName;
- (BOOL)changeFastMotionMovie:(uint)curFastMotionMovie;
- (BOOL)changeCountry:(uint)curCountry;
- (BOOL)changeSubCountry:(uint)curCountry;
- (BOOL)changeDevieceSounds:(uint)curDeviceSounds ClickPosition:(uint)curIndex;
- (uint)parseFastMotionMovieInArray:(NSInteger)index;
- (uint)parseCountryInArray:(NSInteger)index Model:(int)ModelName;;
   
// Figure out property value using index value within array
-(unsigned int)parseDelayCaptureInArray:(NSInteger)index;
-(string)parseImageSizeInArray:(NSInteger)index;
-(string)parseVideoSizeInArray:(NSInteger)index;
- (uint)parseVideoSizeInArray2:(NSInteger)index;
-(string)parseTimeLapseVideoSizeInArray:(NSInteger)index;
-(unsigned int)parseWhiteBalanceInArray:(NSInteger)index;
-(unsigned int)parsePowerFrequencyInArray:(NSInteger)index;
-(unsigned int)parseBurstNumberInArray:(NSInteger)index;
-(unsigned int)parseDateStampInArray:(NSInteger)index;
-(unsigned int)parseTimelapseIntervalInArray:(NSInteger)index;
-(unsigned int)parseTimelapseDurationInArray:(NSInteger)index;

// Assemble those infomation into an container
-(NSArray *)prepareDataForStorageSpaceOfImage:(string)imageSize;
-(NSArray *)prepareDataForStorageSpaceOfVideo:(string)videoSize;
-(WifiCamAlertTable *)prepareDataForDelayCapture:(unsigned int)curDelayCapture;
-(WifiCamAlertTable *)prepareDataForImageSize:(string)curImageSize;
-(WifiCamAlertTable *)prepareDataForVideoSize:(string)curVideoSize;
-(WifiCamAlertTable *)prepareDataForTimeLapseVideoSize:(string)curVideoSize;
-(WifiCamAlertTable *)prepareDataForLightFrequency:(unsigned int)curLightFrequency;
-(WifiCamAlertTable *)prepareDataForWhiteBalance:(unsigned int)curWhiteBalance;
-(WifiCamAlertTable *)prepareDataForBurstNumber:(unsigned int)curBurstNumber;
-(WifiCamAlertTable *)prepareDataForDateStamp:(unsigned int)curDateStamp;
-(NSString *)calcImageSizeToNum:(NSString *)size;

-(ICatchVideoFormat)retrieveVideoFormat;
-(ICatchAudioFormat)retrieveAudioFormat;
-(WifiCamAVData *)prepareDataForPlaybackVideoFrame;
-(WifiCamAVData *)prepareDataForPlaybackAudioTrack;
- (ICatchFrameBuffer *)prepareDataForPlaybackAudioTrack1;
-(ICatchVideoFormat)retrievePlaybackVideoFormat;
-(ICatchAudioFormat)retrievePlaybackAudioFormat;
-(NSString *)prepareDataForBatteryLevel;

-(WifiCamAlertTable *)prepareDataForTimelapseInterval:(unsigned int)curVideoTimelapseInterval;
-(WifiCamAlertTable *)prepareDataForTimelapseDuration:(unsigned int)curVideoTimelapseDuration;

- (WifiCamAlertTable *)prepareDataForScreenSaver:(uint)curScreenSaver;
- (NSString *)calcScreenSaverTime:(uint)curScreenSaver;
- (WifiCamAlertTable *)prepareDataForAutoPowerOff:(uint)curAutoPowerOff;
- (WifiCamAlertTable *)prepareDataForDeviceSounds;
- (WifiCamAlertTable *)prepareDataForTimeZone:(uint)curTimeZone;
- (WifiCamAlertTable *)prepareDataForLanguage:(uint)curLanguage Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForCountry:(uint)curCountry Country2:(uint)curCountry2 Model:(int)ModelName;
- (NSString *)calcAutoPowerOffTime:(uint)curAutoPowerOff;
- (NSString *)calcDeviceSounds:(uint)curDeviceSounds;
- (NSString *)calcTimeZone:(uint)curTimeZone;
- (NSString *)calcLanguage:(uint)curLanguage Model:(int)ModelName;
- (NSString *)DUOHDcalcCountry:(uint)curCountry Model:(int)ModelName;
- (NSString *)calcCountry:(uint)curCountry Country2:(uint)curCountry2 Model:(int)ModelName;
- (NSString *)calcCountry_layer2:(uint)curCountry Model:(int)ModelName;
- (NSString *)calcSubCountry:(uint)curCountry Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForCustomVideoSize:(uint)curVideoSize Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForExposureCompensation:(uint)curExposureCompensation Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForPhotoBurst:(uint)curPhotoBurst;
- (WifiCamAlertTable *)prepareDataForDelayTimer:(uint)curDelayTimer;
- (WifiCamAlertTable *)prepareDataForPhotoExposureCompensation:(uint)curExposureCompensation Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForParkingModeSensor:(uint)curParkingModeSensor;
- (WifiCamAlertTable *)prepareDataForGSensor:(uint)curGSensor Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForSpeedUnit:(uint)curSpeedUnit;
- (WifiCamAlertTable *)prepareDataForSDFormat:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForResetAll;
- (WifiCamAlertTable *)prepareDataForDateTime:(NSString *)curDateTime;
- (WifiCamAlertTable *)prepareDataForLicensePlateStamp:(NSString *)curLicensePlateStamp;
- (NSString *)calcCustomVideoSizeValue:(uint)curVideoSize Model:(int)ModelName;
- (NSString *)calcParkingModeSensorValue:(uint)curParkingModeSensor;
- (NSString *)calcGSensorValue:(uint)curGSensor Model:(int)ModelName;
- (NSString *)calcSDFormatValue:(uint)curSDFormat Model:(int)ModelName;
- (NSString *)calcResetAllValue:(uint)curResetAll;
- (NSString *)calcSpeedUnitValue:(uint)curSpeedUnit;
- (NSString *)calcPhotoBurstValue:(uint)curPhotoBurst;
- (NSString *)calcDelayTimerValue:(uint)curDelayTimer;
- (NSString *)calcLicensePlateStampValue:(string)curLicensePlateStamp;
- (NSString *)calcLicenseDateTimeValue:(NSString*)curDateTime;
- (NSString *)calcExposureCompensationValue:(uint)curExposureCompensation Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForVideoSizeInt:(uint)curVideoSizeInt;
- (WifiCamAlertTable *)prepareDataForVideoQuality:(uint)curVideoQuality;
- (WifiCamAlertTable *)prepareDataForVideoFileLength:(uint)curVideoFileLength ModelName:(int)ModelName;
- (NSString *)calcVideoSizeInt:(uint)curVideoSizeInt;
- (NSString *)calcVideoQuality:(uint)curVideoQuality;
- (NSString *)calcVideoFileLength:(uint)curVideoFileLength Model:(int)ModelName;
- (WifiCamAlertTable *)prepareDataForFastMotionMovie:(uint)curFastMotionMovie;
- (NSString *)calcFastMotionMovieRate:(uint)curFastMotionMovie;

//
-(unsigned int)retrieveDelayedCaptureTime;
-(unsigned int)retrieveBurstNumber;
-(uint)retrieveMaxZoomRatio;
-(uint)retrieveCurrentZoomRatio;
-(uint)retrieveCurrentUpsideDown;
-(uint)retrieveCurrentSlowMotion;
-(uint)retrieveCurrentMovieRecordElapsedTime;
-(int)retrieveCurrentTimelapseInterval;
-(string) retrieveCurrentVideoSize2;

-(BOOL)isSupportMethod2ChangeVideoSize;
-(BOOL)isSupportPV;

// Update
-(void)updateAllProperty:(WifiCamCamera *)camera;
@end
