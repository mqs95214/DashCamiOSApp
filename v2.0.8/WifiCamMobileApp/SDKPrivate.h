//
//  SDKPrivate.h
//  WifiCamMobileApp
//
//  Created by ZJ on 2017/3/16.
//  Copyright © 2017年 iCatchTech. All rights reserved.
//

#ifndef SDKPrivate_h
#define SDKPrivate_h

typedef NS_ENUM(NSInteger, PTPDpcBurstNumber) {
    PTPDpcBurstNumber_HS = 0x0000,
    PTPDpcBurstNumber_OFF,
    PTPDpcBurstNumber_3,
    PTPDpcBurstNumber_5,
    PTPDpcBurstNumber_10,
    PTPDpcBurstNumber_7,
    PTPDpcBurstNumber_15,
    PTPDpcBurstNumber_30,
};

typedef NS_ENUM(NSInteger, PTPDpcWhiteBalance) {
    PTPDpcWhiteBalance_AUTO = 0x0001,
    PTPDpcWhiteBalance_DAYLIGHT,
    PTPDpcWhiteBalance_CLOUDY,
    PTPDpcWhiteBalance_FLUORESCENT,
    PTPDpcWhiteBalance_TUNGSTEN,
    PTPDpcWhiteBalance_UNDERWATER,
};

typedef NS_ENUM(NSInteger, CustomizePropertyID) {
    CustomizePropertyID_ScreenSaver = 0xd773,
    CustomizePropertyID_AutoPowerOff=0xd77f,
    CustomizePropertyID_PowerOnAutoRecord,
    CustomizePropertyID_EXposureCompensation = 0xd76c,
    CustomizePropertyID_ImageStabilization,
    CustomizePropertyID_VideoSizeQuality = 0xd76a,
    CustomizePropertyID_VideoFileLength = 0xd76b,
    CustomizePropertyID_FastMotionMovie=0xd726,
    CustomizePropertyID_WindNoiseReduction,
    CustomizePropertyID_ParkingModeSensor = 0xd76d,
    CustomizePropertyID_GSensor = 0xd76e,
    CustomizePropertyID_GPS = 0xd788,
    CustomizePropertyID_SpeedUnit = 0xd789,
    CustomizePropertyID_UltraDashStamp = 0xd774,
    CustomizePropertyID_TimeAndDateStamp = 0xd775,
    CustomizePropertyID_InformationStamp = 0xd776,
    CustomizePropertyID_LicensePlateStamp = 0xd830,
    CustomizePropertyID_PhotoEXposureCompensation = 0xd778,
    CustomizePropertyID_PhotoBurst = 0xd779,
    CustomizePropertyID_DelayTimer = 0xd77a,
    CustomizePropertyID_PhotoTimeAndDateStamp = 0xd77b,
    CustomizePropertyID_TimeZone = 0xd78a,
    CustomizePropertyID_Language = 0xd785,
    CustomizePropertyID_Country = 0xd78b,
    CustomizePropertyID_SubCountry = 0xd78c,
    CustomizePropertyID_DateTime = 0x5011,
    CustomizePropertyID_DateStyle = 0xd786,
    CustomizePropertyID_ResetAll = 0xd787,
    CustomizePropertyID_BeepSound = 0xd780,
    CustomizePropertyID_Announcements = 0xd781,
    CustomizePropertyID_AudioRec = 0xd782,
    CustomizePropertyID_RotateDisplay = 0xd783,
};
typedef NS_ENUM(NSInteger, U2PropertyID) {
    /*=======U2 VideoSetting======*/
    U2PropertyID_VideoSize = 0xd769,
    U2PropertyID_VideoFileLength = 0xd76b,
    U2PropertyID_VideoEXposureCompensation = 0xd76c,
    U2PropertyID_ParkingModeSensor = 0xd76d,
    U2PropertyID_GSensor = 0xd76e,
    U2PropertyID_ImageStabilization = 0xd76F,
    U2PropertyID_VideoTimeLapse = 0xd770,
    U2PropertyID_VideoTimeLapseInterval = 0xd771,
    U2PropertyID_VideoTimeLapseLength = 0xd772,
    U2PropertyID_ScreenSave = 0xd773,
    U2PropertyID_UltraDashStamp = 0xd774,
    U2PropertyID_VidoeTimeDateStamp = 0xd775,
    U2PropertyID_InformationStamp = 0xd776,
    U2PropertyID_GPS = 0xd788,
    U2PropertyID_SpeedUnits = 0xd789,
    U2PropertyID_LicensePlateStamp = 0xd830,
    /*=======U2 PhotoSetting======*/
    U2PropertyID_PhotoEXposureCompensation = 0xd778,
    U2PropertyID_PhotoBurst = 0xd779,
    U2PropertyID_CaptureDelayTimer = 0xd77a,
    U2PropertyID_PhotoTimeDateStamp = 0xd77b,
    U2PropertyID_PhotoTimeLapse = 0xd77c,
    U2PropertyID_PhotoTimeLapseInterval = 0xd77d,
    U2PropertyID_PhotoTimeLapseLength = 0xd77e,
    /*=======U2 SetupSetting======*/
    U2PropertyID_SetupAutoPowerOff = 0xd77f,
    U2PropertyID_BeepSound = 0xd780,
    U2PropertyID_Announcement = 0xd781,
    U2PropertyID_AudioRecording = 0xd782,
    U2PropertyID_Language= 0xd785,
    U2PropertyID_TimeDateStyle = 0xd786,
    U2PropertyID_TimeZoneDST = 0xd78a,
    U2PropertyID_CountryDST = 0xd78b,
    U2PropertyID_CountrySub = 0xd78c,
    U2PropertyID_RestoreDefaults = 0xd787,
    U2PropertyID_UpdateFwReboot = 0xd82e,
    U2PropertyID_SetupTimeAndDate = 0x5011,
};

typedef NS_ENUM(NSInteger, Z3PropertyID) {
    /*=======Z3 VideoSetting======*/
    Z3PropertyID_CameraSelect =0xd762,
    Z3PropertyID_VideoQuality = 0xd765,
    Z3PropertyID_VideoFileLength = 0xd766,
    Z3PropertyID_VideoEXposureCompensation = 0xd769,
    Z3PropertyID_ParkingModeSensor = 0xd767,
    Z3PropertyID_GSensor = 0xd76d,
    Z3PropertyID_GPS = 0xd77d,
    Z3PropertyID_ScreenSave = 0xd774,
    Z3PropertyID_UltraDashStamp = 0xd77e,
    Z3PropertyID_VidoeTimeDateStamp = 0xd763,
    Z3PropertyID_InformationStamp = 0xd77a,
    Z3PropertyID_SpeedUnits = 0xd76a,
    Z3PropertyID_LicensePlateStamp = 0xd830,
    /*=======Z3 PhotoSetting======*/
    Z3PropertyID_PhotoEXposureCompensation = 0xd760,
    Z3PropertyID_PhotoTimeAndStamp = 0xd761,
    /*=======Z3 SetupSetting======*/
    Z3PropertyID_SetupAutoPowerOff = 0xd777,
    Z3PropertyID_BeepSound = 0xd775,
    Z3PropertyID_Announcement = 0xd776,
    Z3PropertyID_AudioRecording = 0xd764,
    Z3PropertyID_Language= 0xd770,
    Z3PropertyID_TimeDateStyle = 0xd780,
    Z3PropertyID_TimeZoneDST = 0xd76f,
    Z3PropertyID_CountryDST = 0xd771,
    Z3PropertyID_CountryUSA = 0xd783,
    Z3PropertyID_CountryCANADA = 0xd784,
    Z3PropertyID_CountryMEXICO = 0xd785,
    Z3PropertyID_CountryRUSSIA = 0xd786,
    Z3PropertyID_SetupTimeAndDate = 0x5011,
};

typedef NS_ENUM(NSInteger,DUOHDPropertyID) {
    /*=======DUOHD VideoSetting======*/
    DUOPropertyID_CameraSelect =0xd762,
    DUOPropertyID_AudioRecording =0xd740,
    DUOPropertyID_VideoFileLength = 0xd766,
    DUOPropertyID_VideoEXposureCompensation = 0xd769,
    DUOPropertyID_ParkingModeSensor = 0xd767,
    DUOPropertyID_GSensor = 0xd76d,
    DUOPropertyID_GPS = 0xd77d,
    DUOPropertyID_ModelNumberStamp = 0xd77e,
    DUOPropertyID_VidoeTimeDateStamp = 0xd763,
    DUOPropertyID_SpeedStamp = 0xd76a,
    DUOPropertyID_LicensePlateStamp = 0xd830,
    /*=======DUO PhotoSetting======*/
    DUOPropertyID_PhotoEXposureCompensation = 0xd760,
    DUOPropertyID_PhotoTimeAndStamp = 0xd761,
    /*=======DUO SetupSetting======*/
    DUOPropertyID_SetupAutoPowerOff = 0xd777,
    DUOPropertyID_ScreenSave = 0xd775,
    DUOPropertyID_SpeedUnit = 0xd775,
    DUOPropertyID_SpeedDisplay = 0xd775,
    DUOPropertyID_BeepSound = 0xd775,
    DUOPropertyID_Announcement = 0xd776,
    DUOPropertyID_Language= 0xd770,
    DUOPropertyID_TimeZoneDST = 0xd76f,
    DUODUOPropertyID_CountryDST = 0xd771,
    DUOPropertyID_Country = 0xd771,
    DUOPropertyID_KeepUserSetting = 0xd781,
    DUOPropertyID_SetupTimeAndDate = 0x5011,
};
#endif /* SDKPrivate_h */
