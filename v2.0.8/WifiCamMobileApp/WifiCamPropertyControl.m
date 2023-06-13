//
//  WifiCamPropertyControl.m
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 14-6-23.
//  Copyright (c) 2014年 iCatchTech. All rights reserved.
//

#import "WifiCamPropertyControl.h"
#import "SSID_SerialCheck.h"
#import "CustomSettingViewController.h"
#include "ICatchWificamConfig.h"


@implementation WifiCamPropertyControl
/*
 - (BOOL)isMediaStreamRecording {
 return [[SDK instance] isMediaStreamRecording];
 }
 
 -(BOOL)isVideoTimelapseOn {
 return [[SDK instance] isVideoTimelapseOn];
 }
 -(BOOL)isStillTimelapseOn {
 return [[SDK instance] isStillTimelapseOn];
 }
 */
- (BOOL)connected {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] isConnected];
    });
    return retVal;
}

- (BOOL)checkSDExist {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] checkSDExist];
    });
    return retVal;
}

- (BOOL)videoStreamEnabled {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] videoStreamEnabled];
    });
    return retVal;
}

- (BOOL)audioStreamEnabled {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] audioStreamEnabled];
    });
    return retVal;
}
- (BOOL)changeParkingModeSensor:(uint)curParkingModeSensor
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_ParkingModeSensor value:curParkingModeSensor];
    });
    
    return retVal;
}

- (BOOL)changeVideoSize2:(uint)curVideoSize
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:U2PropertyID_VideoSize value:curVideoSize];
    });
    
    return retVal;
}
- (BOOL)changeGSensor:(uint)curGSensor
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_GSensor value:curGSensor];
    });
    
    return retVal;
}
- (BOOL)changeSpeedUnit:(uint)curSpeedUnit
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_SpeedUnit value:curSpeedUnit];
    });
    
    return retVal;
}
- (BOOL)changePhotoBurst:(uint)curPhotoBurst
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_PhotoBurst value:curPhotoBurst];
    });
    
    return retVal;
}
- (BOOL)changeSDFormat
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] formatSD];
    });
    
    return retVal;
}
- (BOOL)changeResetAll:(uint)curResetAll
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_ResetAll value:curResetAll];
    });
    
    return retVal;
}
- (BOOL)changeDelayTimer:(uint)curDelayTimer
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_DelayTimer value:curDelayTimer];
    });
    
    return retVal;
}
- (BOOL)changeTimeZone:(uint)curTimeZone
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_TimeZone value:curTimeZone];
    });
    
    return retVal;
}
- (BOOL)changeLanguage:(uint)curLanguage
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_Language value:curLanguage];
    });
    
    return retVal;
}
- (BOOL)changeExposureCompensation:(uint)curExposureCompensation
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_EXposureCompensation value:curExposureCompensation];
    });
    
    return retVal;
}
- (BOOL)changePhotoExposureCompensation:(uint)curExposureCompensation
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_PhotoEXposureCompensation value:curExposureCompensation];
    });
    
    return retVal;
}
- (BOOL)SetCustomLock:(NSString *)ssid {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeStringProperty:0xD802 value:ssid];
    });
    return retVal;
}
- (BOOL)changeSSID:(NSString *)ssid {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeStringProperty:0xD83C value:ssid];
    });
    return retVal;
}

- (BOOL)changePassword:(NSString *)password {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeStringProperty:0xD83D value:password];
    });
    return retVal;
}

// add - 2017.3.17
- (BOOL)changeScreenSaver:(uint)curScreenSaver
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_ScreenSaver value:curScreenSaver];
    });
    
    return retVal;
}

- (BOOL)changeAutoPowerOff:(uint)curAutoPowerOff
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_AutoPowerOff value:curAutoPowerOff];
    });
    
    return retVal;
}
- (int)changeImageSize:(string)size{
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeImageSize:size];
    });
    return retVal;
}

- (int)changeVideoSize:(string)size{
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeVideoSize:size];
    });
    
    uint cacheTime = [[SDK instance] previewCacheTime];
    ICatchWificamConfig::getInstance()->setPreviewCacheParam(cacheTime);
    return retVal;
}

-(int)changeDelayedCaptureTime:(unsigned int)time{
    __block int retVal = ICH_NULL;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeDelayedCaptureTime:time];
    });
    return retVal;
}

-(int)changeWhiteBalance:(unsigned int)value{
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeWhiteBalance:value];
    });
    return retVal;
}

-(int)changeLightFrequency:(unsigned int)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeLightFrequency:value];
    });
    return retVal;
}
-(int)changeBurstNumber:(unsigned int)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeBurstNumber:value];
    });
    return retVal;
}
-(int)changeDateStamp:(unsigned int)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeDateStamp:value];
    });
    return retVal;
}
-(int)changeTimelapseType:(ICatchPreviewMode)mode {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeTimelapseType:mode];
    });
    return retVal;
}
-(int)changeTimelapseInterval:(unsigned int)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeTimelapseInterval:value];
    });
    return retVal;
}
-(int)changeTimelapseDuration:(unsigned int)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeTimelapseDuration:value];
    });
    return retVal;
}

- (int)changeUpsideDown:(uint)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeUpsideDown:value];
    });
    return retVal;
}

- (int)changeSlowMotion:(uint)value {
    __block int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] changeSlowMotion:value];
    });
    return retVal;
}

- (uint)parseScreenSaverInArray:(NSInteger)index
{
    __block vector<uint> vSSs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vSSs = [[SDK instance] retrieveSupportedScreenSaver];
    });
    
    return vSSs.at(index);
}

- (uint)parseAutoPowerOffInArray:(NSInteger)index
{
    __block vector<uint> vAPOs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vAPOs = [[SDK instance] retrieveSupportedAutoPowerOff];
    });
    
    return vAPOs.at(index);
}

- (uint)parseParkingModeSensorInArray:(NSInteger)index
{
    __block vector<uint> vPms = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vPms = [[SDK instance] retrieveSupportedParkingModeSensor];
    });
    
    return vPms.at(index);
}
- (uint)parseGSensorInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> vGs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vGs = [[SDK instance] retrieveSupportedGSensor:ModelName];
    });
    
    return vGs.at(index);
}
- (uint)parseSpeedUnitInArray:(NSInteger)index
{
    __block vector<uint> vSpd = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vSpd = [[SDK instance] retrieveSupportedSpeedUnit];
    });
    
    return vSpd.at(index);
}
- (uint)parsePhotoBurstInArray:(NSInteger)index
{
    __block vector<uint> pBst = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        pBst = [[SDK instance] retrieveSupportedPhotoBurst];
    });
    
    return pBst.at(index);
}
- (uint)parseDelayTimerInArray:(NSInteger)index
{
    __block vector<uint> pDelayTimer = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        pDelayTimer = [[SDK instance] retrieveSupportedDelayTimer];
    });
    
    return pDelayTimer.at(index);
}
- (uint)parseTimeZoneInArray:(NSInteger)index
{
    __block vector<uint> sTimeZone = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        sTimeZone = [[SDK instance] retrieveSupportedTimeZone];
    });
    
    return sTimeZone.at(index);
}
- (uint)parseLanguageInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> sLanguage = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        sLanguage = [[SDK instance] retrieveSupportedLanguage:ModelName];
    });
    
    return sLanguage.at(index);
}
- (uint)parseExposureCompensationInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> vECs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vECs = [[SDK instance] retrieveSupportedExposureCompensation:ModelName];
    });
    
    return vECs.at(index);
}
- (uint)parsePhotoExposureCompensationInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> vECs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vECs = [[SDK instance] retrieveSupportedPhotoExposureCompensation:ModelName];
    });
    
    return vECs.at(index);
}
- (BOOL)changeFastMotionMovie:(uint)curFastMotionMovie
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_FastMotionMovie value:curFastMotionMovie];
    });
    
    return retVal;
}
- (BOOL)changeCountry:(uint)curCountry
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_Country value:curCountry];
    });
    
    return retVal;
}
- (BOOL)changeSubCountry:(uint)curCountry
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_SubCountry value:curCountry];
    });
    
    return retVal;
}
- (BOOL)changeDevieceSounds:(uint)curDeviceSounds ClickPosition:(uint)curIndex
{
    __block BOOL retVal = NO;

    dispatch_sync([[SDK instance] sdkQueue], ^{
        printf("SoundcurDeviceSounds = %d\n",curDeviceSounds);
        printf("SoundcurIndex = %d\n",curIndex);
        if(curDeviceSounds == 0){
            retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_BeepSound value:curIndex+1];
        }
        else if(curDeviceSounds == 1){
            retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_AudioRec value:curIndex+1];
        }
        else if(curDeviceSounds == 2){
            retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_Announcements value:curIndex+1];
        }
        printf("retVal = %d\n",retVal);
    });
    
    return retVal;
}
- (BOOL)changeVideoQuality:(uint)curVideoQuality
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_VideoSizeQuality value:curVideoQuality];
    });
    
    return retVal;
}
- (BOOL)changeVideoFileLength:(uint)curVideoFileLength
{
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] setCustomizeIntProperty:CustomizePropertyID_VideoFileLength value:curVideoFileLength];
    });
    
    return retVal;
}
- (uint)parseVideoQualityInArray:(NSInteger)index
{
    __block vector<uint> vVQ = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vVQ = [[SDK instance] retrieveSupportedVideoQuality];
    });
    
    return  vVQ.at(index);
}
- (uint)parseVideoFileLengthInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> vVFLs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vVFLs = [[SDK instance] retrieveSupportedVideoFileLength:ModelName];
    });
    
    return  vVFLs.at(index);
}


- (uint)parseFastMotionMovieInArray:(NSInteger)index
{
    __block vector<uint> vFMMs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vFMMs = [[SDK instance] retrieveSupportedFastMotionMovie];
    });
    
    return vFMMs.at(index);
}
- (uint)parseCountryInArray:(NSInteger)index Model:(int)ModelName
{
    __block vector<uint> vCountry = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vCountry = [[SDK instance] retrieveSupportedCountry:ModelName];
    });
    
    return vCountry.at(index);
}

- (unsigned int)retrieveDelayedCaptureTime {
    __block unsigned int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveDelayedCaptureTime];
    });
    return retVal;
}

- (unsigned int)retrieveBurstNumber {
    __block unsigned int retVal = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveBurstNumber];
    });
    return retVal;
}

- (unsigned int)parseDelayCaptureInArray:(NSInteger)index
{
    __block vector<unsigned int> vDCs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vDCs = [[SDK instance] retrieveSupportedCaptureDelays];
    });
    return vDCs.at(index);
    
}

- (string)parseImageSizeInArray:(NSInteger)index
{
    __block vector<string> vISs = vector<string>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vISs = [[SDK instance] retrieveSupportedImageSizes];
    });
    return vISs.at(index);
}

- (string)parseTimeLapseVideoSizeInArray:(NSInteger)index
{
    
    __block vector<string> vVSs = vector<string>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        long int mask;
        int j=0;
        vVSs = [[SDK instance] retrieveSupportedVideoSizes];
        mask = [[SDK instance] getCustomizePropertyIntValue:0xD7FB];
        if( mask >0){
            for(vector<string>::iterator it = vVSs.begin();
                it != vVSs.end();
                ++it,++j) {
                AppLog(@"%s", (*it).c_str());
                // erase mask size
                if( j==0 ){
                    if( (0x01 & mask ) == 0 ){
                        AppLog(@"remove %s",(*it).c_str() );
                        vVSs.erase(it);
                        --it;
                    }
                }
                else if( ((0x01 << j )&mask) == 0 ){
                    AppLog(@"remove %s",(*it).c_str() );
                    vVSs.erase(it);
                    --it;
                }
            }
        }
        
    });
    return vVSs.at(index);
}
- (string)parseVideoSizeInArray:(NSInteger)index
{
    __block vector<string> vVSs = vector<string>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vVSs = [[SDK instance] retrieveSupportedVideoSizes];
    });
    return vVSs.at(index);
}
- (uint)parseVideoSizeInArray2:(NSInteger)index
{
    __block vector<uint> vSSs = vector<uint>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vSSs = [[SDK instance] retrieveSupportedVideoSize2];
    });
    
    return vSSs.at(index);
}

- (unsigned int)parseWhiteBalanceInArray:(NSInteger)index
{
    __block vector<unsigned int> vWBs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vWBs = [[SDK instance] retrieveSupportedWhiteBalances];
    });
    return vWBs.at(index);
}

- (unsigned int)parsePowerFrequencyInArray:(NSInteger)index
{
    __block vector<unsigned int> vLFs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vLFs = [[SDK instance] retrieveSupportedLightFrequencies];
    });
    return vLFs.at(index);
}

- (unsigned int)parseBurstNumberInArray:(NSInteger)index
{
    __block vector<unsigned int> vBNs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vBNs = [[SDK instance] retrieveSupportedBurstNumbers];
    });
    return vBNs.at(index);
}

- (unsigned int)parseDateStampInArray:(NSInteger)index
{
    __block vector<unsigned int> vDSs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vDSs = [[SDK instance] retrieveSupportedDateStamps];
    });
    return vDSs.at(index);
}

- (unsigned int)parseTimelapseIntervalInArray:(NSInteger)index
{
    __block vector<unsigned int> vVTIs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vVTIs = [[SDK instance] retrieveSupportedTimelapseInterval];
    });
    return vVTIs.at(index);
}

- (unsigned int)parseTimelapseDurationInArray:(NSInteger)index
{
    __block vector<unsigned int> vVTDs = vector<unsigned int>();
    dispatch_sync([[SDK instance] sdkQueue], ^{
        vVTDs = [[SDK instance] retrieveSupportedTimelapseDuration];
    });
    return vVTDs.at(index);
}

/*
 - (NSArray *)prepareDataForStorageSpaceOfImage:(string)imageSize
 {
 NSDictionary *curStaticImageSizeDict = [[WifiCamStaticData instance] imageSizeDict];
 NSString *key = [NSString stringWithFormat:@"%s", imageSize.c_str()];
 NSString *title = [curStaticImageSizeDict objectForKey:key];
 unsigned int n = [[SDK instance] retrieveFreeSpaceOfImage];
 
 return [NSArray arrayWithObjects:title, @(MAX(0, n)), nil];
 }
 */

- (NSArray *)prepareDataForStorageSpaceOfVideo:(string)videoSize
{
    __block NSArray *a = nil;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        NSDictionary *curStaticVideoSizeDict = [[WifiCamStaticData instance] videoSizeDict];
        NSString *key = [NSString stringWithFormat:@"%s", videoSize.c_str()];
        NSArray *curStaticVideoSizeArray = [curStaticVideoSizeDict objectForKey:key];
        NSString *title = [curStaticVideoSizeArray firstObject];
        unsigned int iStorage = [[SDK instance] retrieveFreeSpaceOfVideo];
        
        a = [NSArray arrayWithObjects:title, @(MAX(0, iStorage)), nil];
    });
    
    return a;
}


//
- (WifiCamAlertTable *)prepareDataForDelayCapture:(unsigned int)curDelayCapture
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int i = 0;
        SDK *sdk = [SDK instance];
        vector <unsigned int> v = [sdk retrieveSupportedCaptureDelays];
        NSDictionary *dict = [[WifiCamStaticData instance] captureDelayDict];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:v.size()];
        [TAA.array removeAllObjects];
        
        
        for (vector <unsigned int>::iterator it = v.begin();
             it != v.end();
             ++it, ++i) {
            NSString *s = [dict objectForKey:@(*it)];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curDelayCapture) {
                TAA.lastIndex = i;
            }
        }
        
        AppLog(@"TAA.lastIndex: %lu", (unsigned long)TAA.lastIndex);
    });
    return TAA;
}

// Modify by Allen.Chuang 2014.10.3
// parse imagesize string from camera and calucate as M size
- (WifiCamAlertTable *)prepareDataForImageSize:(string)curImageSize
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int i = 0;
        NSString *images = nil;
        NSString *sizeString = nil;
        SDK *sdk = [SDK instance];
        
        vector<string> vISs = [sdk retrieveSupportedImageSizes];
        for(vector<string>::iterator it = vISs.begin(); it != vISs.end(); ++it) {
            AppLog(@"%s", (*it).c_str());
        }
        
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vISs.size()];
        
        for (vector <string>::iterator it = vISs.begin();
             it != vISs.end();
             ++it, ++i) {
            images = [NSString stringWithFormat:@"%s",(*it).c_str()];
            sizeString = [self calcImageSizeToNum:images];
            [TAA.array addObject:sizeString];
            if (*it == curImageSize) {
                TAA.lastIndex = i;
            }
        }
    });
    return TAA;
}


- (NSArray *)prepareDataForStorageSpaceOfImage:(string)imageSize
{
    __block NSArray *a = nil;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        unsigned int freeSpace = [[SDK instance] retrieveFreeSpaceOfImage];
        NSString *images = [NSString stringWithFormat:@"%s",imageSize.c_str()];
        NSString *sizeString = [self calcImageSizeToNum:images];
        a = [NSArray arrayWithObjects:sizeString, @(MAX(0, freeSpace)), nil];
    });
    return a;
}

-(NSString *)calcImageSizeToNum:(NSString *)size
{
    NSArray *xyArray = [size componentsSeparatedByString:@"x"];
    float imgX = [[xyArray objectAtIndex:0] floatValue];
    float imgY = [[xyArray objectAtIndex:1] floatValue];
    float numberToRound =(imgX*imgY/1000000);
    int sizeNum = (int) round(numberToRound);
    AppLog(@"roundf(%.2f) = %d",numberToRound, sizeNum);
    
    return sizeNum == 0 ? @"VGA" : [NSString stringWithFormat:@"%dM",sizeNum];
}

/*
 - (WifiCamAlertTable *)prepareDataForImageSize:(string)curImageSize
 {
 int i = 0;
 SDK *sdk = [SDK instance];
 
 vector<string> vISs = [sdk retrieveSupportedImageSizes];
 for(vector<string>::iterator it = vISs.begin(); it != vISs.end(); ++it) {
 AppLog(@"%s", (*it).c_str());
 }
 
 WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
 TAA.array = [[NSMutableArray alloc] initWithCapacity:vISs.size()];
 NSDictionary *imageSizeDict = [[WifiCamStaticData instance] imageSizeDict];
 
 for (vector <string>::iterator it = vISs.begin();
 it != vISs.end();
 ++it, ++i) {
 NSString *key = [NSString stringWithFormat:@"%s", (*it).c_str()];
 NSString *size = [imageSizeDict objectForKey:key];
 size = [size stringByAppendingFormat:@"(%@)", key];
 [TAA.array addObject:size];
 if (*it == curImageSize) {
 TAA.lastIndex = i;
 }
 }
 
 return TAA;
 }
 */

- (WifiCamAlertTable *)prepareDataForTimeLapseVideoSize:(string)curVideoSize
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int i = 0;
        int j = 0;
        SDK *sdk = [SDK instance];
        
        vector<string> vVSs = [sdk retrieveSupportedVideoSizes];
        
        // fetch mask value for timelapse video size
        int mask = [sdk getCustomizePropertyIntValue:0xD7FB];
        int umask = 0x0001;
        if( mask >0){
            AppLog(@"%s TimeLapse mask : %d",__func__, mask);
            for(vector<string>::iterator it = vVSs.begin();
                it != vVSs.end();
                it++,j++) {
                AppLog(@"%s", (*it).c_str());
                // erase mask size
                if( j==0 ){
                    if( (umask & mask) == 0){
                        AppLog(@"remove %s",(*it).c_str() );
                        vVSs.erase(it);
                        it--;
                    }
                }
                else if( ((umask << j ) & mask) == 0 ){
                    AppLog(@"remove %s",(*it).c_str() );
                    vVSs.erase(it);
                    it--;
                }
            }
            
        }
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vVSs.size()];
        NSDictionary *videoSizeDict = [[WifiCamStaticData instance] videoSizeDict];
        
        for (vector <string>::iterator it = vVSs.begin();
             it != vVSs.end();
             ++it, ++i) {
            NSString *key = [NSString stringWithFormat:@"%s", (*it).c_str()];
            NSArray   *a = [videoSizeDict objectForKey:key];
            NSString  *first = [a firstObject];
            NSString  *last = [a lastObject];
            
            if (last != nil) {
                NSString *s = [first stringByAppendingFormat:@" %@", last]; // Customize
                
                if (s != nil) {
                    [TAA.array addObject:s];
                }
                
                if (*it == curVideoSize) {
                    TAA.lastIndex = i;
                }
            }
        }
    });
    return TAA;
}


- (WifiCamAlertTable *)prepareDataForVideoSize:(string)curVideoSize
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int i = 0;
        SDK *sdk = [SDK instance];
        
        vector<string> vVSs = [sdk retrieveSupportedVideoSizes];
        //vVSs.push_back("3840x2160 10");
        //vVSs.push_back("2704x1524 15");
        for(vector<string>::iterator it = vVSs.begin();
            it != vVSs.end();
            ++it) {
            AppLog(@"%s", (*it).c_str());
        }
        
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vVSs.size()];
        NSDictionary *videoSizeDict = [[WifiCamStaticData instance] videoSizeDict];
        
        for (vector <string>::iterator it = vVSs.begin();
             it != vVSs.end();
             ++it, ++i) {
            NSString *key = [NSString stringWithFormat:@"%s", (*it).c_str()];
            NSArray   *a = [videoSizeDict objectForKey:key];
            NSString  *first = [a firstObject];
            NSString  *last = [a lastObject];
            
            if (last != nil) {
                NSString *s = [first stringByAppendingFormat:@" %@", last]; // Customize
                
                if (s != nil) {
                    [TAA.array addObject:s];
                }
                
                if (*it == curVideoSize) {
                    TAA.lastIndex = i;
                }
            }
        }
    });
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForLightFrequency:(unsigned int)curLightFrequency
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int i = 0;
        SDK *sdk = [SDK instance];
        BOOL InvalidSelectedIndex = NO;
        vector<unsigned int> vLFs = [sdk retrieveSupportedLightFrequencies];
        vector<ICatchLightFrequency> supportedEnumedLightFrequencies;
        ICatchWificamUtil::convertLightFrequencies(vLFs, supportedEnumedLightFrequencies);
        NSDictionary *dict = [[WifiCamStaticData instance] powerFrequencyDict];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:supportedEnumedLightFrequencies.size()];
        
        for (vector <ICatchLightFrequency>::iterator it = supportedEnumedLightFrequencies.begin();
             it != supportedEnumedLightFrequencies.end();
             ++it, ++i) {
            NSString *s = [dict objectForKey:@(*it)];
            
            if (s != nil && ![s isEqualToString:@""]) {
                [TAA.array addObject:s];
            }
            
            if (*it == curLightFrequency && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        if (!InvalidSelectedIndex) {
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForWhiteBalance:(unsigned int)curWhiteBalance
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        BOOL InvalidSelectedIndex = NO;
        vector<unsigned int> vWBs = [sdk retrieveSupportedWhiteBalances];
        vector<ICatchWhiteBalance> supportedEnumedWhiteBalances;
        ICatchWificamUtil::convertWhiteBalances(vWBs, supportedEnumedWhiteBalances);
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:supportedEnumedWhiteBalances.size()];
        int i = 0;
        NSDictionary *dict = [[WifiCamStaticData instance] whiteBalanceDict];
        
        for (vector <ICatchWhiteBalance>::iterator it = supportedEnumedWhiteBalances.begin();
             it != supportedEnumedWhiteBalances.end();
             ++it, ++i) {
            NSString *s = [dict objectForKey:@(*it)];
            
            if (s != nil) {
                [TAA.array addObject:s];
            }
            
            if (*it == curWhiteBalance && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        if (!InvalidSelectedIndex) {
            AppLog(@"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForBurstNumber:(unsigned int)curBurstNumber
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        
        BOOL InvalidSelectedIndex = NO;
        vector<unsigned int> vBNs = [sdk retrieveSupportedBurstNumbers];
        AppLog(@"vBNs.size(): %lu", vBNs.size());
        vector<ICatchBurstNumber> supportedEnumedBurstNumbers;
        ICatchWificamUtil::convertBurstNumbers(vBNs, supportedEnumedBurstNumbers);
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:supportedEnumedBurstNumbers.size()];
        AppLog(@"supportedEnumedBurstNumbers.size(): %lu", supportedEnumedBurstNumbers.size());
        int i = 0;
        NSDictionary *dict = [[WifiCamStaticData instance] burstNumberStringDict];
        
        for (vector <ICatchBurstNumber>::iterator it = supportedEnumedBurstNumbers.begin();
             it != supportedEnumedBurstNumbers.end();
             ++it, ++i) {
            NSString *s = [[dict objectForKey:@(*it)] firstObject];
            
            if (s != nil) {
                [TAA.array addObject:s];
            }
            
            if (*it == curBurstNumber && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        if (!InvalidSelectedIndex) {
            AppLog(@"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForDateStamp:(unsigned int)curDateStamp
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        
        BOOL InvalidSelectedIndex = NO;
        vector<unsigned int> vDSs = [sdk retrieveSupportedDateStamps];
        vector<ICatchDateStamp> supportedEnumedDataStamps;
        ICatchWificamUtil::convertDateStamps(vDSs, supportedEnumedDataStamps);
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:supportedEnumedDataStamps.size()];
        int i =0;
        NSDictionary *dict = [[WifiCamStaticData instance] dateStampDict];
        
        for(vector<ICatchDateStamp>::iterator it = supportedEnumedDataStamps.begin();
            it != supportedEnumedDataStamps.end();
            ++it, ++i) {
            NSString *s = [dict objectForKey:@(*it)];
            
            if (s != nil) {
                [TAA.array addObject:s];
            }
            
            if (*it == curDateStamp && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLog(@"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForTimelapseInterval:(unsigned int)curTimelapseInterval
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        
        BOOL InvalidSelectedIndex = NO;
        
        vector<unsigned int> vTIs = [sdk retrieveSupportedTimelapseInterval];
        
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vTIs.size()];
        int i =0;
        //    NSDictionary *dict = [[WifiCamStaticData instance] timelapseIntervalDict];
        
        AppLog(@"curTimelapseInterval: %d", curTimelapseInterval);
        for(vector<unsigned int>::iterator it = vTIs.begin();
            it != vTIs.end();
            ++it, ++i) {
            AppLog(@"Interval Item Value: %u", *it);
            //        NSString *s = [dict objectForKey:@(*it)];
            NSString *s = nil;
            
            if (0 == *it) {
                s = NSLocalizedString(@"SETTING_CAP_TL_INTERVAL_OFF", nil);
            }else if( *it >= 0xFFFE){
                s = NSLocalizedString(@"SETTING_CAP_TL_INTERVAL_0.5_S", nil);
            }else if (*it >= 60 && *it < 3600) {
                s = [NSString stringWithFormat:@"%dm", (*it/60)];
            } else if (*it >= 3600) {
                s = [NSString stringWithFormat:@"%dhr", (*it/3600)];
            } else {
                s = [NSString stringWithFormat:@"%ds", *it];
            }
            
            if (s != nil) {
                [TAA.array addObject:s];
            }
            
            if (*it == curTimelapseInterval && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLog(@"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}


- (WifiCamAlertTable *)prepareDataForTimelapseDuration:(unsigned int)curTimelapseDuration
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        
        BOOL InvalidSelectedIndex = NO;
        vector<unsigned int> vTDs = [sdk retrieveSupportedTimelapseDuration];
        
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vTDs.size()];
        int i =0;
        //    NSDictionary *dict = [[WifiCamStaticData instance] timelapseDurationDict];
        
        AppLog(@"curTimelapseDuration: %d",curTimelapseDuration);
        for(vector<unsigned int>::iterator it = vTDs.begin();
            it != vTDs.end();
            ++it, ++i) {
            //AppLog(@"Duration Item Value:%d", *it);
            //        NSString *s = [dict objectForKey:@(*it)];
            NSString *s = nil;
            if (0xFFFF == *it) {
                s = NSLocalizedString(@"SETTING_CAP_TL_DURATION_Unlimited", nil);
            } else if (*it >= 60 && *it < 3600) {
                s = [NSString stringWithFormat:@"%dhr", (*it/60)];
            } else {
                s = [NSString stringWithFormat:@"%dm", *it];
            }
            
            if (s != nil) {
                [TAA.array addObject:s];
            }
            
            if (*it == curTimelapseDuration && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLog(@"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    return TAA;
}

// add - 2017.3.16
- (WifiCamAlertTable *)prepareDataForScreenSaver:(uint)curScreenSaver
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDSSs = [[SDK instance] retrieveSupportedScreenSaver];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDSSs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curScreenSaver: %d", curScreenSaver);
        for (vector<uint>::iterator it = vDSSs.begin(); it != vDSSs.end(); ++it, ++i) {
            s = [self calcScreenSaverTime:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curScreenSaver && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (NSString *)calcScreenSaverTime:(uint)curScreenSaver
{
    if (curScreenSaver == 1) {
        return @"Off";
    }
    else if(curScreenSaver == 2)
    {
        return @"30 Seconds";
    }
    else if(curScreenSaver == 3)
    {
        return @"2 Minutes";
    }
    else {
        return [NSString stringWithFormat:@"%ds", curScreenSaver];
    }
}

- (WifiCamAlertTable *)prepareDataForAutoPowerOff:(uint)curAutoPowerOff
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDAPs = [[SDK instance] retrieveSupportedAutoPowerOff];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curAutoPowerOff: %d", curAutoPowerOff);
        for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
            s = [self calcAutoPowerOffTime:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curAutoPowerOff && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForDeviceSounds
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        
        
        TAA.array = [[NSMutableArray alloc] init];
        int i = 0;
        NSString *s = nil;
        
        
        for (i = 1 ; i <= 3 ; i++) {
            s = [self calcDeviceSounds:i];
            
            if (s) {
                [TAA.array addObject:s];
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForTimeZone:(uint)curTimeZone
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDAPs = [[SDK instance] retrieveSupportedTimeZone];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curTimeZone: %d", curTimeZone);
        for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
            s = [self calcTimeZone:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curTimeZone && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
                printf("Timezon lastIndex = %lu",(unsigned long)TAA.lastIndex);
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForLanguage:(uint)curLanguage Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDAPs = [[SDK instance] retrieveSupportedLanguage:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curLanguage: %d", curLanguage);
        for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
            s = [self calcLanguage:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curLanguage && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForCountry:(uint)curCountry Country2:(uint)curCountry2 Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDAPs = [[SDK instance] retrieveSupportedCountry:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDAPs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curCountry: %d", curCountry);
        for (vector<uint>::iterator it = vDAPs.begin(); it != vDAPs.end(); ++it, ++i) {
                if(ModelName == DUO_HD)
                {
                    s = [self DUOHDcalcCountry:*it Model:ModelName];
                }
                else
                {
                    s = [self calcCountry_layer2:*it Model:ModelName];
                }
                if (s) {
                    
                    [TAA.array addObject:s];
                }
                
                if (*it == curCountry && !InvalidSelectedIndex) {
                    TAA.lastIndex = i;
                    InvalidSelectedIndex = YES;
                }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (NSString *)calcAutoPowerOffTime:(uint)curAutoPowerOff
{
    if (1 == curAutoPowerOff) {
        return [NSString stringWithFormat:NSLocalizedString(@"SetAutoPowerOff10Sec",@"")];
    }
    else if(2 == curAutoPowerOff){
        return [NSString stringWithFormat:NSLocalizedString(@"SetAutoPowerOff2Mins",@"")];
    }
    else if(3 == curAutoPowerOff){
        return [NSString stringWithFormat:NSLocalizedString(@"SetAutoPowerOff5Mins",@"")];
    }
    else {
        return [NSString stringWithFormat:@"%ds", curAutoPowerOff];
    }
}
- (NSString *)calcDeviceSounds:(uint)curDeviceSounds
{
    if (1 == curDeviceSounds) {
        return [NSString stringWithFormat:@"Beep"];
    }
    else if(2 == curDeviceSounds){
        return [NSString stringWithFormat:@"Audio Rec"];
    }
    else if(3 == curDeviceSounds){
        return [NSString stringWithFormat:@"Announcements"];
    }
    else {
        return [NSString stringWithFormat:@""];
    }
}
- (NSString *)calcTimeZone:(uint)curTimeZone
{
    if(curTimeZone == 1) return [NSString stringWithFormat:@"-12"];
    else if(curTimeZone == 2) return [NSString stringWithFormat:@"-11"];
    else if(curTimeZone == 3) return [NSString stringWithFormat:@"-10"];
    else if(curTimeZone == 4) return [NSString stringWithFormat:@"-9"];
    else if(curTimeZone == 5) return [NSString stringWithFormat:@"-8"];
    else if(curTimeZone == 6) return [NSString stringWithFormat:@"-7"];
    else if(curTimeZone == 7) return [NSString stringWithFormat:@"-6"];
    else if(curTimeZone == 8) return [NSString stringWithFormat:@"-5"];
    else if(curTimeZone == 9) return [NSString stringWithFormat:@"-4"];
    else if(curTimeZone == 10) return [NSString stringWithFormat:@"-3.5"];
    else if(curTimeZone == 11) return [NSString stringWithFormat:@"-3"];
    else if(curTimeZone == 12) return [NSString stringWithFormat:@"-2.5"];
    else if(curTimeZone == 13) return [NSString stringWithFormat:@"-2"];
    else if(curTimeZone == 14) return [NSString stringWithFormat:@"-1"];
    else if(curTimeZone == 15) return [NSString stringWithFormat:@"GMT"];
    else if(curTimeZone == 16) return [NSString stringWithFormat:@"+1"];
    else if(curTimeZone == 17) return [NSString stringWithFormat:@"+2"];
    else if(curTimeZone == 18) return [NSString stringWithFormat:@"+3"];
    else if(curTimeZone == 19) return [NSString stringWithFormat:@"+4"];
    else if(curTimeZone == 20) return [NSString stringWithFormat:@"+5"];
    else if(curTimeZone == 21) return [NSString stringWithFormat:@"+6"];
    else if(curTimeZone == 22) return [NSString stringWithFormat:@"+7"];
    else if(curTimeZone == 23) return [NSString stringWithFormat:@"+8"];
    else if(curTimeZone == 24) return [NSString stringWithFormat:@"+9"];
    else if(curTimeZone == 25) return [NSString stringWithFormat:@"+10"];
    else if(curTimeZone == 26) return [NSString stringWithFormat:@"+11"];
    else if(curTimeZone == 27) return [NSString stringWithFormat:@"+12"];
    else
        return [NSString stringWithFormat:@"%d", curTimeZone];
    
}
- (NSString *)calcLanguage:(uint)curLanguage Model:(int)ModelName
{
    if(ModelName == CANSONIC_U2)
    {
        if(curLanguage == 1)
        {
            return NSLocalizedString(@"SetVideoGsensorHigh",@"");
        }
        else if(curLanguage == 2)
        {
            return NSLocalizedString(@"SetVideoGsensorMedium",@"");
        }
        else if(curLanguage == 3)
        {
            return NSLocalizedString(@"SetVideoGsensorLow",@"");
        }
        else if(curLanguage == 4)
        {
            return NSLocalizedString(@"SetSettingOFF",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == CANSONIC_Z3)
    {
        if(curLanguage == 0)
        {
            return NSLocalizedString(@"SetVideoGsensorHigh",@"");
        }
        else if(curLanguage == 1)
        {
            return NSLocalizedString(@"SetVideoGsensorMedium",@"");
        }
        else if(curLanguage == 2)
        {
            return NSLocalizedString(@"SetVideoGsensorLow",@"");
        }
        else if(curLanguage == 3)
        {
            return NSLocalizedString(@"SetSettingOFF",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == DUO_HD)
    {
        if(curLanguage == DUO_LN_English)
        {
            return NSLocalizedString(@"SetLanguageEn",@"");
        }
        else if(curLanguage == DUO_LN_Danish)
        {
            return NSLocalizedString(@"SetLanguageDa",@"");
        }
        else if(curLanguage == DUO_LN_German)
        {
            return NSLocalizedString(@"SetLanguageGe",@"");
        }
        else if(curLanguage == DUO_LN_Spanish)
        {
            return NSLocalizedString(@"SetLanguageSp",@"");
        }
        else if(curLanguage == DUO_LN_French)
        {
            return NSLocalizedString(@"SetLanguageFr",@"");
        }
        else if(curLanguage == DUO_LN_ltalian)
        {
            return NSLocalizedString(@"SetLanguageItali",@"");
        }
        else if(curLanguage == DUO_LN_Dutch)
        {
            return NSLocalizedString(@"SetLanguageDutch",@"");
        }
        else if(curLanguage == DUO_LN_Norwegian)
        {
            return NSLocalizedString(@"SetLanguageNorway",@"");
        }
        else if(curLanguage == DUO_LN_Finnish)
        {
            return NSLocalizedString(@"SetLanguageFinnish",@"");
        }
        else if(curLanguage == DUO_LN_Swedish)
        {
            return NSLocalizedString(@"SetLanguageSwedish",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)DUOHDcalcCountry:(uint)curCountry Model:(int)ModelName
{
#if 0
    if(ModelName == DUO_HD)
    {
        if(curCountry == DUO_Country_UK_Ireland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Belgium)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Denmark)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Finland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_France)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Germany)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Italy)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Netherlands)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Norway)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Poland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Spain)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Sweden)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_USA_Eastern)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_USA_Central)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_USA_Mountain)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_USA_Pacific)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_USA_Alaska)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_USA_Hawaii)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_Canada_Newfoundland)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Canada_Atlantic)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Canada_Eastern)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Canada_Central)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Canada_Mountain)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Canada_Pacific)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Eastern)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Central)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Mountain)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Pacific)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Other)
        {
            return NSLocalizedString(@"SetCountry_Other", @"");
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else
    {
        return [NSString stringWithFormat:@""];
    }
#endif
    return nil;
}
- (NSString *)calcCountry:(uint)curCountry Country2:(uint)curCountry2 Model:(int)ModelName
{
    if(ModelName == DUO_HD)
    {
        if(curCountry == DUO_Country_UK_Ireland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Belgium)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Denmark)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Finland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_France)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Germany)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Italy)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Netherlands)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Norway)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Poland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Spain)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Sweden)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_USA_Eastern)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_Canada_Newfoundland)
        {
             return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Eastern)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Other)
        {
            return NSLocalizedString(@"SetCountry_Other", @"");
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else
    {
        if (1 == curCountry) {
            if(curCountry2 == 1)
                return NSLocalizedString(@"SetCountry_UnitedStateEST", @"");
            if(curCountry2 == 2)
                return NSLocalizedString(@"SetCountry_UnitedStateCST", @"");
            if(curCountry2 == 3)
                return NSLocalizedString(@"SetCountry_UnitedStateMST", @"");
            if(curCountry2 == 4)
                return NSLocalizedString(@"SetCountry_UnitedStatePST", @"");
            if(curCountry2 == 5)
                return NSLocalizedString(@"SetCountry_UnitedStateAKST", @"");
            if(curCountry2 == 6)
                return NSLocalizedString(@"SetCountry_UnitedStateHST", @"");
        }
        else if(2 == curCountry) {
            if(curCountry2 == 7)
                return NSLocalizedString(@"SetCountry_CanadaNST", @"");
            if(curCountry2 == 8)
                return NSLocalizedString(@"SetCountry_CanadaAST", @"");
            if(curCountry2 == 9)
                return NSLocalizedString(@"SetCountry_CanadaEST", @"");
            if(curCountry2 == 10)
                return NSLocalizedString(@"SetCountry_CanadaCST", @"");
            if(curCountry2 == 11)
                return NSLocalizedString(@"SetCountry_CanadaMST", @"");
            if(curCountry2 == 12)
                return NSLocalizedString(@"SetCountry_CanadaPST", @"");
        }
        else if(3 == curCountry) {
            if(curCountry2 == 13)
                return NSLocalizedString(@"SetCountry_RussiaKALT", @"");
            if(curCountry2 == 14)
                return NSLocalizedString(@"SetCountry_RussiaMSK", @"");
            if(curCountry2 == 15)
                return NSLocalizedString(@"SetCountry_RussiaSAMT", @"");
            if(curCountry2 == 16)
                return NSLocalizedString(@"SetCountry_RussiaYEKT", @"");
            if(curCountry2 == 17)
                return NSLocalizedString(@"SetCountry_RussiaOMST", @"");
            if(curCountry2 == 18)
                return NSLocalizedString(@"SetCountry_RussiaKRAT", @"");
            if(curCountry2 == 19)
                return NSLocalizedString(@"SetCountry_RussiaIRKT", @"");
            if(curCountry2 == 20)
                return NSLocalizedString(@"SetCountry_RussiaYAKT", @"");
            if(curCountry2 == 21)
                return NSLocalizedString(@"SetCountry_RussiaVLAT", @"");
            if(curCountry2 == 22)
                return NSLocalizedString(@"SetCountry_RussiaMAGT", @"");
            if(curCountry2 == 23)
                return NSLocalizedString(@"SetCountry_RussiaPETT", @"");
        }
        else if(4 == curCountry)
            return NSLocalizedString(@"SetCountry_Spain", @"");
        else if(5 == curCountry)
            return NSLocalizedString(@"SetCountry_Germany", @"");
        else if(6 == curCountry)
            return NSLocalizedString(@"SetCountry_France", @"");
        else if(7 == curCountry)
            return NSLocalizedString(@"SetCountry_Italy", @"");
        else if(8 == curCountry)
            return NSLocalizedString(@"SetCountry_Netherlands", @"");
        else if(9 == curCountry)
            return NSLocalizedString(@"SetCountry_Belgium", @"");
        else if(10 == curCountry)
            return NSLocalizedString(@"SetCountry_Poland", @"");
        else if(11 == curCountry)
            return NSLocalizedString(@"SetCountry_Czech", @"");
        else if(12 == curCountry)
            return NSLocalizedString(@"SetCountry_Romania", @"");
        else if(13 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        else if(14 == curCountry)
            return NSLocalizedString(@"SetCountry_Other", @"");
        else {
            return [NSString stringWithFormat:@""];
        }
    }
    return [NSString stringWithFormat:@""];
}
- (NSString *)calcCountry_layer2:(uint)curCountry Model:(int)ModelName
{
    if(ModelName == DUO_HD)
    {
        if(curCountry == DUO_Country_UK_Ireland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Belgium)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Denmark)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Finland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_France)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Germany)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Italy)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Netherlands)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Norway)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Poland)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Spain)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_Sweden)
        {
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        }
        else if(curCountry == DUO_Country_USA_Eastern)
        {
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        }
        else if(curCountry == DUO_Country_Canada_Newfoundland)
        {
            return NSLocalizedString(@"SetCountry_Canada", @"");
        }
        else if(curCountry == DUO_Country_Mexico_Eastern)
        {
            return NSLocalizedString(@"SetCountry_Mexico", @"");
        }
        else if(curCountry == DUO_Country_Other)
        {
            return NSLocalizedString(@"SetCountry_Other", @"");
        }
        else
        {
            return [NSString stringWithFormat:@""];
        }
    }
    else
    {
        if (1 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedState", @"");
        else if(2 == curCountry)
            return NSLocalizedString(@"SetCountry_Canada", @"");
        else if(3 == curCountry)
            return NSLocalizedString(@"SetCountry_Russia", @"");
        else if(4 == curCountry)
            return NSLocalizedString(@"SetCountry_Spain", @"");
        else if(5 == curCountry)
            return NSLocalizedString(@"SetCountry_Germany", @"");
        else if(6 == curCountry)
            return NSLocalizedString(@"SetCountry_France", @"");
        else if(7 == curCountry)
            return NSLocalizedString(@"SetCountry_Italy", @"");
        else if(8 == curCountry)
            return NSLocalizedString(@"SetCountry_Netherlands", @"");
        else if(9 == curCountry)
            return NSLocalizedString(@"SetCountry_Belgium", @"");
        else if(10 == curCountry)
            return NSLocalizedString(@"SetCountry_Poland", @"");
        else if(11 == curCountry)
            return NSLocalizedString(@"SetCountry_Czech", @"");
        else if(12 == curCountry)
            return NSLocalizedString(@"SetCountry_Romania", @"");
        else if(13 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedKingdom", @"");
        else if(14 == curCountry)
            return NSLocalizedString(@"SetCountry_Other", @"");
        else {
            return [NSString stringWithFormat:@""];
        }
    }
    return [NSString stringWithFormat:@""];
}
- (NSString *)calcSubCountry:(uint)curCountry Model:(int)ModelName
{
    if(ModelName == DUO_HD)
    {
      return [NSString stringWithFormat:@""];
    }
    else
    {
        if (1 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStateEST", @"");
        else if(2 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStateCST", @"");
        else if(3 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStateMST", @"");
        else if(4 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStatePST", @"");
        else if(5 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStateAKST", @"");
        else if(6 == curCountry)
            return NSLocalizedString(@"SetCountry_UnitedStateHST", @"");
        else if(7 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaNST", @"");
        else if(8 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaAST", @"");
        else if(9 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaEST", @"");
        else if(10 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaCST", @"");
        else if(11 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaMST", @"");
        else if(12 == curCountry)
            return NSLocalizedString(@"SetCountry_CanadaPST", @"");
        else if(13 == curCountry)
            return NSLocalizedString(@"SetCountry_MexicoEST", @"");
        else if(14 == curCountry)
            return NSLocalizedString(@"SetCountry_MexicoCST", @"");
        else if(15 == curCountry)
            return NSLocalizedString(@"SetCountry_MexicoMST", @"");
        else if(16 == curCountry)
            return NSLocalizedString(@"SetCountry_MexicoPST", @"");
        else if(17 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaKALT", @"");
        else if(18 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaMSK", @"");
        else if(19 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaSAMT", @"");
        else if(20 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaYEKT", @"");
        else if(21 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaOMST", @"");
        else if(22 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaKRAT", @"");
        else if(23 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaIRKT", @"");
        else if(24 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaYAKT", @"");
        else if(25 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaVLAT", @"");
        else if(26 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaMAGT", @"");
        else if(27 == curCountry)
            return NSLocalizedString(@"SetCountry_RussiaPETT", @"");
        else {
            return [NSString stringWithFormat:@""];
        }
    }
}
- (WifiCamAlertTable *)prepareDataForExposureCompensation:(uint)curExposureCompensation Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedExposureCompensation:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curExposureCompensation: %d", curExposureCompensation);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcExposureCompensationValue:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curExposureCompensation && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForPhotoBurst:(uint)curPhotoBurst
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedPhotoBurst];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curPhotoBurst: %d", curPhotoBurst);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcPhotoBurstValue:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curPhotoBurst && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForDelayTimer:(uint)curDelayTimer
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedDelayTimer];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curDelayTimer: %d", curDelayTimer);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcDelayTimerValue:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curDelayTimer && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForPhotoExposureCompensation:(uint)curExposureCompensation Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedPhotoExposureCompensation:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curExposureCompensation: %d", curExposureCompensation);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcExposureCompensationValue:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curExposureCompensation && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForParkingModeSensor:(uint)curParkingModeSensor
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedParkingModeSensor];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curParkingModeSensor: %d", curParkingModeSensor);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcParkingModeSensorValue:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curParkingModeSensor && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForCustomVideoSize:(uint)curVideoSize Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedCustomVideoSize:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curVideoSize: %d", curVideoSize);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcCustomVideoSizeValue:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curVideoSize && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (WifiCamAlertTable *)prepareDataForGSensor:(uint)curGSensor Model:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedGSensor:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curGSensor: %d", curGSensor);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcGSensorValue:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curGSensor && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForSpeedUnit:(uint)curSpeedUnit
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDECs = [[SDK instance] retrieveSupportedSpeedUnit];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDECs.size()];
        int i = 0;
        NSString *s = nil;
        
        //printf("\nproperty int value vDECs: %d\n", *iit);
        AppLogInfo(AppLogTagAPP, @"curSpeedUnit: %d", curSpeedUnit);
        for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
            s = [self calcSpeedUnitValue:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curSpeedUnit && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForSDFormat:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        
        TAA.array = [[NSMutableArray alloc] init];
        
        int start,end;
        NSString *s = nil;
        
        //printf("\nproperty int value vDECs: %d\n", *iit);
        //AppLogInfo(AppLogTagAPP, @"curSpeedUnit: %d", curSpeedUnit);
        /*for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
         s = [self calcSpeedUnitValue:*it];
         
         if (s) {
         [TAA.array addObject:s];
         }
         
         if (*it == curSpeedUnit && !InvalidSelectedIndex) {
         TAA.lastIndex = i;
         InvalidSelectedIndex = YES;
         }
         }*/
        if(ModelName == CANSONIC_U2 ||
           ModelName == DRVA601W || ModelName == KVDR600W)
        {
            start = 1;
            end = 2;
        }
        else
        {
            start = 0;
            end = 1;
        }
        
        
        for(int i = start ; i <= end ; i++)
        {
            s = [self calcSDFormatValue:i Model:ModelName];
            if (s) {
                [TAA.array addObject:s];
            }
            if(i == end){
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForResetAll
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        
        TAA.array = [[NSMutableArray alloc] init];
        int i = 0;
        NSString *s = nil;
        
        //printf("\nproperty int value vDECs: %d\n", *iit);
        //AppLogInfo(AppLogTagAPP, @"curSpeedUnit: %d", curSpeedUnit);
        /*for (vector<uint>::iterator it = vDECs.begin(); it != vDECs.end(); ++it, ++i) {
         s = [self calcSpeedUnitValue:*it];
         
         if (s) {
         [TAA.array addObject:s];
         }
         
         if (*it == curSpeedUnit && !InvalidSelectedIndex) {
         TAA.lastIndex = i;
         InvalidSelectedIndex = YES;
         }
         }*/
        for(int i = 1 ; i <= 2 ; i++)
        {
            s = [self calcResetAllValue:i];
            if (s) {
                [TAA.array addObject:s];
            }
            if(i == 2){
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForLicensePlateStamp:(NSString *)curLicensePlateStamp
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<string> vSTRs = (vector<string>)0 /*[[SDK instance] retrieveSupportedLicensePlateStamp]*/;
        
        TAA.array = [[NSMutableArray alloc] init];
        int i = 0;
        NSString *s = nil;
        
        // AppLogInfo(AppLogTagAPP, @"LicensePlateStamp: %", curLicensePlateStamp);
        for (vector<string>::iterator it = vSTRs.begin(); it != vSTRs.end(); ++it, ++i) {
            s = [self calcLicensePlateStampValue:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (it == (vSTRs.end()-1) && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForDateTime:(NSString *)curDateTime
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<string> vSTRs = [[SDK instance] retrieveSupportedDateTime];
        
        TAA.array = [[NSMutableArray alloc] init];

        

        // AppLogInfo(AppLogTagAPP, @"LicensePlateStamp: %", curLicensePlateStamp);

        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (NSString *)calcCustomVideoSizeValue:(uint)curVideoSize Model:(int)ModelName
{
    if(ModelName == CANSONIC_U2)
    {
        if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"4k 30fps"];
        }
        else if(curVideoSize == 2)
        {
            return [NSString stringWithFormat:@"1080p 60fps"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == DRVA601W || ModelName == KVDR600W)
    {
        
        if(curVideoSize == 1)
        {
            return [NSString stringWithFormat:@"1440P+1440P 30fps"];
        }
        else if(curVideoSize == 2)
        {
            return [NSString stringWithFormat:@"4K 30fps"];
        }
        else if(curVideoSize == 3)
        {
            return [NSString stringWithFormat:@"1440P 30fps"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == CANSONIC_Z3)
    {
        if(curVideoSize == 0)
        {
            return [NSString stringWithFormat:@"1080p 60fps"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == DUO_HD)
    {
        if(curVideoSize == 0)
        {
           return [NSString stringWithFormat:@"Dual"];
        }
        else if(curVideoSize == 1)
        {
           return [NSString stringWithFormat:@"Left"];
        }
        else if(curVideoSize == 2)
        {
           return [NSString stringWithFormat:@"Right"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else
    {
         return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcParkingModeSensorValue:(uint)curParkingModeSensor
{
    if(curParkingModeSensor == 1)
    {
        return [NSString stringWithFormat:@"ON"];
    }
    else if(curParkingModeSensor == 2)
    {
        return [NSString stringWithFormat:@"OFF"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcVideoSizeDUOHD:(uint)curDUOHDVideoSize
{
    if(curDUOHDVideoSize == 0)
    {
        return NSLocalizedString(@"DUOHDCameraSelectDual",@"");
    }
    else if(curDUOHDVideoSize == 1)
    {
        return NSLocalizedString(@"DUOHDCameraSelectLeft",@"");
    }
    else if(curDUOHDVideoSize == 2)
    {
        return NSLocalizedString(@"DUOHDCameraSelectRight",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcVideoSizeU2:(uint)curU2VideoSize
{
    if(curU2VideoSize == 1)
    {
        return NSLocalizedString(@"U2VideoSize4K",@"");
    }
    else if(curU2VideoSize == 2)
    {
        return NSLocalizedString(@"U2VideoSize1080p",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcVideoSizeZ3:(uint)curZ3VideoSize
{
    if(curZ3VideoSize == 0)
    {
        return NSLocalizedString(@"Z3CameraSelectDual",@"");
    }
    else if(curZ3VideoSize == 1)
    {
        return NSLocalizedString(@"Z3CameraSelectLeft",@"");
    }
    else if(curZ3VideoSize == 2)
    {
        return NSLocalizedString(@"Z3CameraSelectRight",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcAudioRecDUOHD:(uint)curDUOHDAudioRec
{
    if(curDUOHDAudioRec == 0)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOn",@"");
    }
    else if(curDUOHDAudioRec == 1)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOff",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcAudioRecZ3:(uint)curZ3AudioRec
{
    if(curZ3AudioRec == 0)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOn",@"");
    }
    else if(curZ3AudioRec == 1)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOff",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcAudioRecU2:(uint)curU2AudioRec
{
    if(curU2AudioRec == 1)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOn",@"");
    }
    else if(curU2AudioRec == 2)
    {
        return NSLocalizedString(@"SetDeviceSounds_AudioRecOff",@"");
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcGSensorValue:(uint)curGSensor Model:(int)ModelName
{
    if(ModelName == CANSONIC_U2 ||
       ModelName == DRVA601W || ModelName == KVDR600W)
    {
        if(curGSensor == 1)
        {
            return NSLocalizedString(@"SetVideoGsensorHigh",@"");
        }
        else if(curGSensor == 2)
        {
            return NSLocalizedString(@"SetVideoGsensorMedium",@"");
        }
        else if(curGSensor == 3)
        {
            return NSLocalizedString(@"SetVideoGsensorLow",@"");
        }
        else if(curGSensor == 4)
        {
            return NSLocalizedString(@"SetSettingOFF",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == CANSONIC_Z3)
    {
        if(curGSensor == 0)
        {
            return NSLocalizedString(@"SetVideoGsensorHigh",@"");
        }
        else if(curGSensor == 1)
        {
            return NSLocalizedString(@"SetVideoGsensorMedium",@"");
        }
        else if(curGSensor == 2)
        {
            return NSLocalizedString(@"SetVideoGsensorLow",@"");
        }
        else if(curGSensor == 3)
        {
            return NSLocalizedString(@"SetSettingOFF",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == DUO_HD)
    {
        if(curGSensor == 0)
        {
            return NSLocalizedString(@"SetVideoGsensorHigh",@"");
        }
        else if(curGSensor == 1)
        {
            return NSLocalizedString(@"SetVideoGsensorMedium",@"");
        }
        else if(curGSensor == 2)
        {
            return NSLocalizedString(@"SetVideoGsensorLow",@"");
        }
        else if(curGSensor == 3)
        {
            return NSLocalizedString(@"SetSettingOFF",@"");
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else
    {
         return NSLocalizedString(@"unlimited", @"");
    }

    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcSDFormatValue:(uint)curFormat Model:(int)ModelName
{
    if(ModelName == CANSONIC_U2 ||
       ModelName == DRVA601W || ModelName == KVDR600W)
    {
        if(curFormat == 1)
        {
            return [NSString stringWithFormat:@"YES"];
        }
        else if(curFormat == 2)
        {
            return [NSString stringWithFormat:@"NO"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == CANSONIC_Z3)
    {
        if(curFormat == 0)
        {
            return [NSString stringWithFormat:@"YES"];
        }
        else if(curFormat == 1)
        {
            return [NSString stringWithFormat:@"NO"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else if(ModelName == DUO_HD)
    {
        if(curFormat == 0)
        {
            return [NSString stringWithFormat:@"YES"];
        }
        else if(curFormat == 1)
        {
            return [NSString stringWithFormat:@"NO"];
        }
        else
        {
            return NSLocalizedString(@"unlimited", @"");
        }
    }
    else
    {
         return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcResetAllValue:(uint)curResetAll
{
    if(curResetAll == 1)
    {
        return [NSString stringWithFormat:@"YES"];
    }
    else if(curResetAll == 2)
    {
        return [NSString stringWithFormat:@"NO"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
}
- (NSString *)calcSpeedUnitValue:(uint)curSpeedUnit
{
    if(curSpeedUnit == 1)
    {
        return [NSString stringWithFormat:@"MPH"];
    }
    else if(curSpeedUnit == 2)
    {
        return [NSString stringWithFormat:@"KMH"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcPhotoBurstValue:(uint)curPhotoBurst
{
    if(curPhotoBurst == 1)
    {
        return [NSString stringWithFormat:@"OFF"];
    }
    else if(curPhotoBurst == 2)
    {
        return [NSString stringWithFormat:@"3 shot 1S"];
    }
    else if(curPhotoBurst == 3)
    {
        return [NSString stringWithFormat:@"15 shot 1S"];
    }
    else if(curPhotoBurst == 4)
    {
        return [NSString stringWithFormat:@"30 shot 1S"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}

- (NSString *)calcDelayTimerValue:(uint)curDelayTimer
{
    if(curDelayTimer == 1)
    {
        return [NSString stringWithFormat:@"OFF"];
    }
    else if(curDelayTimer == 2)
    {
        return [NSString stringWithFormat:@"Delay 2S"];
    }
    else if(curDelayTimer == 3)
    {
        return [NSString stringWithFormat:@"Delay 10S"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcLicensePlateStampValue:(string)curLicensePlateStamp
{
    /* if(curSpeedUnit == 1)
     {
     return [NSString stringWithFormat:@"MPH"];
     }
     else if(curSpeedUnit == 2)
     {
     return [NSString stringWithFormat:@"KMH"];
     }
     else
     {
     return NSLocalizedString(@"unlimited", @"");
     }*/
    return [NSString stringWithFormat:@"%s",curLicensePlateStamp.c_str()];
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}
- (NSString *)calcLicenseDateTimeValue:(NSString*)curDateTime
{
    NSString *Year;
    NSString *Mon;
    NSString *Day;
    NSString *Hour;
    NSString *Minute;

    if([[SDK instance] retrieveCurrentDateStyle] == 1)
    {
        NSLog(@"curDateTime = %@",curDateTime);
        Year = [curDateTime substringWithRange:NSMakeRange(0,4)];
        Mon = [curDateTime substringWithRange:NSMakeRange(4,2)];
        Day = [curDateTime substringWithRange:NSMakeRange(6,2)];
        Hour = [curDateTime substringWithRange:NSMakeRange(9,2)];
        Minute = [curDateTime substringWithRange:NSMakeRange(11,2)];
        return [NSString stringWithFormat:@"%@/%@/%@,%@:%@",Year,Mon,Day,Hour,Minute];

    }
    else if([[SDK instance] retrieveCurrentDateStyle] == 2)
    {
        NSLog(@"curDateTime = %@",curDateTime);
        Year = [curDateTime substringWithRange:NSMakeRange(0,4)];
        Mon = [curDateTime substringWithRange:NSMakeRange(4,2)];
        Day = [curDateTime substringWithRange:NSMakeRange(6,2)];
        Hour = [curDateTime substringWithRange:NSMakeRange(9,2)];
        Minute = [curDateTime substringWithRange:NSMakeRange(11,2)];
        return [NSString stringWithFormat:@"%@/%@/%@,%@:%@",Mon,Day,Year,Hour,Minute];
    }
    else if([[SDK instance] retrieveCurrentDateStyle] == 3)
    {
        NSLog(@"curDateTime = %@",curDateTime);
        Year = [curDateTime substringWithRange:NSMakeRange(0,4)];
        Mon = [curDateTime substringWithRange:NSMakeRange(4,2)];
        Day = [curDateTime substringWithRange:NSMakeRange(6,2)];
        Hour = [curDateTime substringWithRange:NSMakeRange(9,2)];
        Minute = [curDateTime substringWithRange:NSMakeRange(11,2)];
        return [NSString stringWithFormat:@"%@/%@/%@,%@:%@",Day,Mon,Year,Hour,Minute];
    }
    else
    {
        return nil;
    }
    
}
- (NSString *)calcExposureCompensationValue:(uint)curExposureCompensation Model:(int)ModelName
{
    int ICatchDefaultValue = 0;
    int Threshold = 0x80000000;
    int rateThreshold = 0x40000000;
    float rate = 1.0;
    NSString *prefix = nil;
    
    // 最高位为1表示负值，为0表示正值
    /*if (curExposureCompensation & Threshold) {
     prefix = @"EV -";
     } else {
     prefix = @"EV ";
     }*/
    if(ModelName == CANSONIC_U2 ||
       ModelName == DRVA601W || ModelName == KVDR600W)
    {
        ICatchDefaultValue = 1;
    }
    else if(ModelName == CANSONIC_Z3 || ModelName == DUO_HD)
    {
        ICatchDefaultValue = 0;
    }
    
    if (curExposureCompensation == ICatchDefaultValue) {
        prefix = @"+";
    } else if(curExposureCompensation == ICatchDefaultValue+1) {
        prefix = @"+";
    } else if(curExposureCompensation == ICatchDefaultValue+2) {
        prefix = @"";
    } else if(curExposureCompensation == ICatchDefaultValue+3) {
        prefix = @"-";
    } else if(curExposureCompensation == ICatchDefaultValue+4) {
        prefix = @"-";
    }
    

    ICatchDefaultValue = 0;
    // 第二位表示小数点向左移动的位数 1：移动一位 0：不移动
    if (rateThreshold & curExposureCompensation) {
        rate = 10.0;
    }
    
    int temp = ~(Threshold | rateThreshold);
    int value/* = curExposureCompensation & temp*/;
    if(ModelName == CANSONIC_U2 ||
       ModelName == DRVA601W || ModelName == KVDR600W)
    {
         ICatchDefaultValue = 1;
    }
    else
    {
         ICatchDefaultValue = 0;
    }

        if (curExposureCompensation == ICatchDefaultValue) {
            value = 2;
        } else if(curExposureCompensation == ICatchDefaultValue+1) {
            value = 1;
        } else if(curExposureCompensation == ICatchDefaultValue+2) {
            value = 0;
        } else if(curExposureCompensation == ICatchDefaultValue+3) {
            value = 1;
        } else if(curExposureCompensation == ICatchDefaultValue+4) {
            value = 2;
        }
    
    
    return [prefix stringByAppendingFormat:@"%.1f", (double)value / rate];
}

- (WifiCamAlertTable *)prepareDataForVideoQuality:(uint)curVideoQuality
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDVFLs = [[SDK instance] retrieveSupportedVideoQuality];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curVideoQuality: %d", curVideoQuality);
        for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
            s = [self calcVideoQuality:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curVideoQuality && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}
- (WifiCamAlertTable *)prepareDataForVideoFileLength:(uint)curVideoFileLength ModelName:(int)ModelName
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDVFLs = [[SDK instance] retrieveSupportedVideoFileLength:ModelName];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDVFLs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curVideoFileLength: %d", curVideoFileLength);
        for (vector<uint>::iterator it = vDVFLs.begin(); it != vDVFLs.end(); ++it, ++i) {
            s = [self calcVideoFileLength:*it Model:ModelName];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curVideoFileLength && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}


- (NSString *)calcVideoSizeInt:(uint)curVideoSizeInt
{
    if (curVideoSizeInt == 0) {
        return NSLocalizedString(@"unlimited", @"");
    } else {
        return [NSString stringWithFormat:@"%ds", curVideoSizeInt];
    }
}
- (NSString *)calcVideoQuality:(uint)curVideoQuality
{
    if(curVideoQuality == 1)
    {
        return [NSString stringWithFormat:@"High"];
    }
    else if(curVideoQuality == 2)
    {
        return [NSString stringWithFormat:@"Medium"];
    }
    else if(curVideoQuality == 3)
    {
        return [NSString stringWithFormat:@"Low"];
    }
    else
    {
        return NSLocalizedString(@"unlimited", @"");
    }
    /*return NSLocalizedString(@"unlimited", @"");*/
    //return [NSString stringWithFormat:@"%d Minute", curVideoQuality];
}


- (NSString *)calcVideoFileLength:(uint)curVideoFileLength Model:(int)ModelName
{

    if(curVideoFileLength == 1)
    {
        return [NSString stringWithFormat:NSLocalizedString(@"SetSeamLess_1Minutes",@"")];;
    }
    else if(curVideoFileLength == 2)
    {
        return [NSString stringWithFormat:NSLocalizedString(@"SetSeamLess_3Minutes",@"")];;
    }
    else if(curVideoFileLength == 3)
    {
        return [NSString stringWithFormat:NSLocalizedString(@"SetSeamLess_5Minutes",@"")];;
    }
    else
    {
        return [NSString stringWithFormat:@"%d Minutes", curVideoFileLength];
    }
}

- (WifiCamAlertTable *)prepareDataForFastMotionMovie:(uint)curFastMotionMovie
{
    WifiCamAlertTable *TAA = [[WifiCamAlertTable alloc] init];
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        BOOL InvalidSelectedIndex = NO;
        
        vector<uint> vDFMMs = [[SDK instance] retrieveSupportedFastMotionMovie];
        
        TAA.array = [[NSMutableArray alloc] initWithCapacity:vDFMMs.size()];
        int i = 0;
        NSString *s = nil;
        
        AppLogInfo(AppLogTagAPP, @"curFastMotionMovie: %d", curFastMotionMovie);
        for (vector<uint>::iterator it = vDFMMs.begin(); it != vDFMMs.end(); ++it, ++i) {
            s = [self calcFastMotionMovieRate:*it];
            
            if (s) {
                [TAA.array addObject:s];
            }
            
            if (*it == curFastMotionMovie && !InvalidSelectedIndex) {
                TAA.lastIndex = i;
                InvalidSelectedIndex = YES;
            }
        }
        
        if (!InvalidSelectedIndex) {
            AppLogError(AppLogTagAPP, @"Undefined Number");
            TAA.lastIndex = UNDEFINED_NUM;
        }
    });
    
    return TAA;
}

- (NSString *)calcFastMotionMovieRate:(uint)curFastMotionMovie
{
    if (curFastMotionMovie == 0) {
        return @"Off";
    } else {
        return [NSString stringWithFormat:@"%dx", curFastMotionMovie];
    }
}

- (ICatchVideoFormat)retrieveVideoFormat
{
    return [[SDK instance] getVideoFormat];
}

- (ICatchAudioFormat)retrieveAudioFormat {
    return [[SDK instance] getAudioFormat];
}

- (WifiCamAVData *)prepareDataForPlaybackVideoFrame
{
    return [[SDK instance] getPlaybackFrameData];
}

- (WifiCamAVData *)prepareDataForPlaybackAudioTrack
{
    return [[SDK instance] getPlaybackAudioData];
}

- (ICatchFrameBuffer *)prepareDataForPlaybackAudioTrack1
{
    return [[SDK instance] getPlaybackAudioData1];
}

- (ICatchVideoFormat)retrievePlaybackVideoFormat
{
    return [[SDK instance] getPlaybackVideoFormat];
}

- (ICatchAudioFormat)retrievePlaybackAudioFormat {
    return [[SDK instance] getPlaybackAudioFormat];
}

- (NSString *)prepareDataForBatteryLevel
{
    __block uint level = -1;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        level = [[SDK instance] retrieveBatteryLevel];
    });
    return [self transBatteryLevel2NStr:level];
}

- (NSString *)transBatteryLevel2NStr:(unsigned int)value
{
    NSString *retVal = nil;
    
    if (value < 10) {
        retVal = @"battery_0";
    } else if (value < 40) {
        retVal = @"battery_1";
    } else if (value < 70) {
        retVal = @"battery_2";
    } else if (value <= 100) {
        retVal = @"battery_3";
    } else {
        AppLog(@"battery raw value: %d", value);
        retVal = @"battery_4";
    }
    
    return retVal;
}

//

-(uint)retrieveMaxZoomRatio
{
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveMaxZoomRatio];
    });
    return retVal;
}

-(uint)retrieveCurrentZoomRatio
{
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveCurrentZoomRatio];
    });
    return retVal;
}

-(uint)retrieveCurrentUpsideDown {
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveCurrentUpsideDown];
    });
    return retVal;
}

-(uint)retrieveCurrentSlowMotion {
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveCurrentSlowMotion];
    });
    return retVal;
}

-(uint)retrieveCurrentMovieRecordElapsedTime {
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] getCustomizePropertyIntValue:0xD7FD];
    });
    return retVal;
}



-(int)retrieveCurrentTimelapseInterval {
    __block uint retVal = 0;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        retVal = [[SDK instance] retrieveTimelapseInterval];
    });
    return retVal;
}

//add by allen
-(string) retrieveCurrentVideoSize2{
    __block string videoSize="";
    dispatch_sync([[SDK instance] sdkQueue], ^{
        videoSize = [[SDK instance] retrieveVideoSizeByPropertyCode];
    });
    return videoSize;
}

-(BOOL)isSupportMethod2ChangeVideoSize {
    __block BOOL retVal = NO;
    dispatch_sync([[SDK instance] sdkQueue], ^{
        if (([[SDK instance] getCustomizePropertyIntValue:0xD7FC] & 0x0001) == 1) {
            AppLog(@"D7FC is ON");
            retVal = YES;
        } else if (([[SDK instance] getCustomizePropertyIntValue:0xD7FC] & 0x0001) == 0){
            retVal = NO;
        } else {
            retVal = NO;
        }
    });
    
    return retVal;
}

-(BOOL)isSupportPV {
    __block BOOL retVal = NO;
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        int value = [[SDK instance] getCustomizePropertyIntValue:0xD7FF];
        AppLog(@"Support PV: %d", value);
        if (value == 1) {
            retVal = YES;
        } else {
            retVal = NO;
        }
    });
    return retVal;
}

-(void)updateAllProperty:(WifiCamCamera *)camera {
    
    dispatch_sync([[SDK instance] sdkQueue], ^{
        SDK *sdk = [SDK instance];
        
        //camera.cameraMode = [sdk retrieveCurrentCameraMode];
        camera.curImageSize = [sdk retrieveImageSize];
        camera.curVideoSize = [sdk retrieveVideoSize];
        AppLog(@"video Size: %@", [NSString stringWithFormat:@"%s",camera.curVideoSize.c_str()]);
        camera.curCaptureDelay = [sdk retrieveDelayedCaptureTime];
        camera.curWhiteBalance = [sdk retrieveWhiteBalanceValue];
        camera.curSlowMotion = [sdk retrieveCurrentSlowMotion];
        camera.curInvertMode = [sdk retrieveCurrentUpsideDown];
        camera.curBurstNumber = [sdk retrieveBurstNumber];
        camera.storageSpaceForImage = [sdk retrieveFreeSpaceOfImage];
        camera.storageSpaceForVideo = [sdk retrieveFreeSpaceOfVideo];
        camera.curLightFrequency = [sdk retrieveLightFrequency];
        camera.curDateStamp = [sdk retrieveDateStamp];
        AppLog(@"date-stamp: %d", camera.curDateStamp);
        
        int retValue = [sdk retrieveTimelapseInterval];
        if (retValue >= 0) {
            camera.curTimelapseInterval = retValue;
        }
        AppLog(@"timelapse-interval: %d", camera.curTimelapseInterval);
        
        retValue = [sdk retrieveTimelapseDuration];
        if (retValue >= 0) {
            camera.curTimelapseDuration = retValue;
        }
        //        camera.cameraFWVersion = [sdk retrieveCameraFWVersion];
        //        camera.cameraProductName = [sdk retrieveCameraProductName];
        //        camera.ssid = [sdk getCustomizePropertyStringValue:0xD83C];
        //        camera.password = [sdk getCustomizePropertyStringValue:0xD83D];
        //camera.previewMode = WifiCamPreviewModeVideoOff;
        camera.movieRecording = [sdk isMediaStreamRecording];
        camera.stillTimelapseOn = [sdk isStillTimelapseOn];
        camera.videoTimelapseOn = [sdk isVideoTimelapseOn];
        //camera.timelapseType = WifiCamTimelapseTypeVideo;
    });
}

@end
