//
//  SDK.h - Data Access Layer
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-6.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ICatchWificam.h"
#include "ICatchWifiCamAssist.h"
#import "WifiCamAVData.h"
#import "WifiCamObserver.h"
#include <vector>
#import <Photos/Photos.h>
#import "SDKPrivate.h"

using namespace std;


enum WCFileType {
  WCFileTypeImage  = TYPE_IMAGE,
  WCFileTypeVideo  = TYPE_VIDEO,
  WCFileTypeAudio  = TYPE_AUDIO,
  WCFileTypeText   = TYPE_TEXT,
  WCFileTypeAll    = TYPE_ALL,
  WCFileTypeUnknow = TYPE_UNKNOWN,
};

enum WCRetrunType {
  WCRetSuccess = ICH_SUCCEED,
  WCRetFail,
  WCRetNoSD,
  WCRetSDFUll,
};


@interface SDK : NSObject

@property (nonatomic, readonly) uint previewCacheTime;

#pragma mark - Global
@property (nonatomic) NSMutableArray *downloadArray;
@property (nonatomic) BOOL isBusy;
@property (nonatomic) NSUInteger downloadedTotalNumber;
@property (nonatomic) BOOL connected;
@property (nonatomic, readonly) dispatch_queue_t sdkQueue;
@property (nonatomic, readonly) BOOL isSDKInitialized;
@property (nonatomic, readonly) BOOL isSupportAutoDownload;

#pragma mark - API adapter layer
// SDK
+(SDK *)instance;
-(BOOL)initializeSDK;
-(void)destroySDK;
-(void)cleanUpDownloadDirectory;
-(void)enableLogSdkAtDiretctory:(NSString *)directoryName enable:(BOOL)enable;
-(BOOL)isConnected;

// MEDIA
-(int)startMediaStream:(ICatchPreviewMode)mode enableAudio:(BOOL)enableAudio;
- (int)startMediaStream:(ICatchPreviewMode)mode enableAudio:(BOOL)enableAudio enableLive:(BOOL)enableLive;
-(BOOL)stopMediaStream;
-(BOOL)isMediaStreamOn;
-(BOOL)videoStreamEnabled;
-(BOOL)audioStreamEnabled;
-(ICatchVideoFormat)getVideoFormat;
-(ICatchAudioFormat)getAudioFormat;
-(NSMutableData *)getVideoData;
-(NSData *)getAudioData;
-(BOOL)openAudio:(BOOL)isOpen;
- (WifiCamAVData *)getVideoData2;
- (WifiCamAVData *)getAudioData2;
- (WifiCamAVData *)getVideoData3;
- (WifiCamAVData *)getAudioData3;

// CONTROL
-(WCRetrunType)capturePhoto;
-(WCRetrunType)triggerCapturePhoto;
-(BOOL)startMovieRecord;
-(BOOL)stopMovieRecord;
-(BOOL)startTimelapseRecord;
-(BOOL)stopTimelapseRecord;
-(BOOL)formatSD;
-(BOOL)checkSDExist;
-(void)addObserver:(ICatchEventID)eventTypeId
          listener:(ICatchWificamListener *)listener
       isCustomize:(BOOL)isCustomize;
-(void)removeObserver:(ICatchEventID)eventTypeId
             listener:(ICatchWificamListener *)listener
          isCustomize:(BOOL)isCustomize;
-(void)addObserver:(WifiCamObserver *)observer;
-(void)removeObserver:(WifiCamObserver *)observer;
-(BOOL)zoomIn;
-(BOOL)zoomOut;

// Photo gallery
-(vector<ICatchFile>)requestFileListOfType:(WCFileType)fileType;
-(UIImage *)requestThumbnail:(ICatchFile *)file;
-(UIImage *)requestImage:(ICatchFile *)file;
-(NSString *)p_downloadFile:(ICatchFile *)f;
-(BOOL)downloadFile:(ICatchFile *)f;
-(void)cancelDownload;
-(BOOL)deleteFile:(ICatchFile *)f;
- (BOOL)openFileTransChannel;
- (NSString *)p_downloadFile2:(ICatchFile *)f;
- (BOOL)closeFileTransChannel;
-(BOOL)downloadFile2:(ICatchFile *)f;

// Video playback
-(WifiCamAVData *)getPlaybackFrameData;
-(WifiCamAVData *)getPlaybackAudioData;
- (ICatchFrameBuffer *)getPlaybackAudioData1;
-(NSData *)getPlaybackAudioData2;
-(ICatchVideoFormat)getPlaybackVideoFormat;
-(ICatchAudioFormat)getPlaybackAudioFormat;
-(BOOL)videoPlaybackEnabled;
-(BOOL)videoPlaybackStreamEnabled;
-(BOOL)audioPlaybackStreamEnabled;
-(double)play:(ICatchFile *)file;
-(BOOL)pause;
-(BOOL)resume;
-(BOOL)stop;
-(BOOL)seek:(double)point;

//
-(BOOL)isMediaStreamRecording;
-(BOOL)isVideoTimelapseOn;
-(BOOL)isStillTimelapseOn;

// Properties
-(vector<ICatchMode>)retrieveSupportedCameraModes;
-(vector<ICatchCameraProperty>)retrieveSupportedCameraCapabilities;
-(vector<unsigned int>)retrieveSupportedWhiteBalances;
-(vector<unsigned int>)retrieveSupportedCaptureDelays;
-(vector<string>)retrieveSupportedImageSizes;
-(vector<string>)retrieveSupportedVideoSizes;
-(vector<unsigned int>)retrieveSupportedLightFrequencies;
-(vector<unsigned int>)retrieveSupportedBurstNumbers;
-(vector<unsigned int>)retrieveSupportedDateStamps;
-(vector<unsigned int>)retrieveSupportedTimelapseInterval;
-(vector<unsigned int>)retrieveSupportedTimelapseDuration;
-(string)retrieveImageSize;
-(string)retrieveVideoSize;
-(string)retrieveVideoSizeByPropertyCode;
-(unsigned int)retrieveDelayedCaptureTime;
-(unsigned int)retrieveWhiteBalanceValue;
-(unsigned int)retrieveLightFrequency;
-(unsigned int)retrieveBurstNumber;
-(unsigned int)retrieveDateStamp;
-(int)retrieveTimelapseInterval;
-(int)retrieveTimelapseDuration;
-(unsigned int)retrieveBatteryLevel;
-(BOOL)checkstillCapture;
-(unsigned int)retrieveFreeSpaceOfImage;
-(unsigned int)retrieveFreeSpaceOfVideo;
-(NSString *)retrieveCameraFWVersion;
-(NSString *)retrieveCameraProductName;
-(uint)retrieveMaxZoomRatio;
-(uint)retrieveCurrentZoomRatio;
-(uint)retrieveCurrentUpsideDown;
-(uint)retrieveCurrentSlowMotion;
-(ICatchCameraMode)retrieveCurrentCameraMode;

// Customize Property
- (BOOL)retrieveCurrentPowerOnAutoRecord;
- (BOOL)retrieveCurrentImageStabilization;
- (NSString *)retrieveCurrentLicensePlateStamp;
- (NSString *)retrieveCurrentDateTime;
- (vector<string>)retrieveSupportedDateTime;
- (vector<string>)retrieveSupportedLicensePlateStamp;
/*Tom Add*/
- (vector<uint>)retrieveSupportedDUOHDVideoSize;
- (vector<uint>)retrieveSupportedU2VideoSize;
- (vector<uint>)retrieveSupportedZ3VideoSize;
- (vector<uint>)retrieveSupportedDUOHDAudioRec;
- (vector<uint>)retrieveSupportedU2AudioRec;
- (vector<uint>)retrieveSupportedZ3AudioRec;
/*********/
- (vector<uint>)retrieveSupportedCustomVideoSize:(int)ModelName;
- (vector<uint>)retrieveSupportedScreenSaver;
- (vector<uint>)retrieveSupportedVideoSize2;
- (vector<uint>)retrieveSupportedAutoPowerOff;
- (vector<uint>)retrieveSupportedTimeZone;
- (vector<uint>)retrieveSupportedLanguage:(int)ModelName;
- (vector<uint>)retrieveSupportedCountry:(int)ModelName;
- (vector<uint>)retrieveSupportedSubCountry;
- (vector<uint>)retrieveSupportedPowerOnAutoRecord;
- (vector<uint>)retrieveSupportedExposureCompensation:(int)ModelName;
- (vector<uint>)retrieveSupportedPhotoExposureCompensation:(int)ModelName;
- (vector<uint>)retrieveSupportedPhotoBurst;
- (vector<uint>)retrieveSupportedDelayTimer;
- (vector<uint>)retrieveSupportedParkingModeSensor;
- (vector<uint>)retrieveSupportedGSensor:(int)ModelName;
- (vector<uint>)retrieveSupportedSpeedUnit;
- (vector<uint>)retrieveSupportedImageStabilization;
- (vector<uint>)retrieveSupportedVideoQuality;
- (vector<uint>)retrieveSupportedVideoFileLength:(int)ModelName;
/*Tom Add*/
- (vector<uint>)retrieveSupportedVideoFileLengthOfDUOHD;
- (vector<uint>)retrieveSupportedVideoFileLengthOfU2;
- (vector<uint>)retrieveSupportedVideoFileLengthOfZ3;
/**/
- (vector<uint>)retrieveSupportedFastMotionMovie;
- (vector<uint>)retrieveSupportedWindNoiseReduction;


/*Tom Add*/
- (uint)retrieveCurrentDUOHDVideoSize;
- (uint)retrieveCurrentU2VideoSize;
- (uint)retrieveCurrentZ3VideoSize;
- (uint)retrieveCurrentDUOHDAudioRec;
- (uint)retrieveCurrentU2AudioRec;
- (uint)retrieveCurrentZ3AudioRec;
/**/
- (uint)retrieveCurrentScreenSaver;
- (uint)retrieveCurrentAutoPowerOff;
- (uint)retrieveCurrentTimeZone;
- (uint)retrieveCurrentLanguage:(int)ModelName;
- (uint)retrieveCurrentCountry:(int)ModelName;
- (uint)retrieveSubCurrentCountry;
- (uint)retrieveCurrentBeepSound;
- (uint)retrieveCurrentAnnouncements;
/*Tom Add*/
- (uint)retrieveCurrentAudioRec;
- (uint)retrieveCurrentAudioRecOfDUOHD;
- (uint)retrieveCurrentAudioRecOfU2;
- (uint)retrieveCurrentAudioRecOfZ3;
/**/
- (uint)retrieveCurrentExposureCompensation:(int)ModelName;
/*Tom Add*/
- (uint)retrieveCurrentExposureCompensationOfDUOHD;
- (uint)retrieveCurrentExposureCompensationOfU2;
- (uint)retrieveCurrentExposureCompensationOfZ3;
/**/
- (uint)retrieveCurrentPhotoBurst;
- (uint)retrieveCurrentDelayTimer;
- (uint)retrieveCurrentPhotoExposureCompensation:(int)ModelName;
- (uint)retrieveCurrentDateStyle;
- (uint)retrieveCurrentParkingModeSensor;
- (uint)retrieveCurrentCustomVideoSize:(int)ModelName;
- (uint)retrieveCurrentGSensor:(int)ModelName;
- (uint)retrieveCurrentSpeedUnit;
- (uint)retrieveCurrentVideoSizeInt;
- (uint)retrieveCurrentVideoQality;
- (uint)retrieveCurrentVideoFileLength:(int)ModelName;
- (uint)retrieveCurrentSensorNumberChangeData;
- (uint)retrieveCurrentFastMotionMovie;

- (BOOL)retrieveCurrentWindNoiseReduction;
- (BOOL)retrieveCurrentGPS:(int)ModelName;
- (BOOL)retrieveCurrentUltraDashStamp;
- (BOOL)retrieveCurrentTimeAndDateStamp:(int)ModelName;
- (BOOL)retrieveCurrentPhotoTimeAndDateStamp:(int)ModelName;
- (BOOL)retrieveCurrentSpeedDisplay:(int)ModelName;
- (BOOL)retrieveCurrentScreenSaver:(int)ModelName;
- (BOOL)retrieveCurrentDeviceSound:(int)ModelName;
- (BOOL)retrieveCurrentAudioRecording:(int)ModelName;
- (BOOL)retrieveCurrentAnnouncement:(int)ModelName;
- (BOOL)retrieveCurrentKeepUserSetting:(int)ModelName;
- (BOOL)retrieveCurrentInformationStamp;
- (BOOL)retrieveCurrentParkingModeSensor:(int)ModelName;
- (BOOL)retrieveCurrentSpeedStamp:(int)ModelName;
- (BOOL)retrieveCurrentModelNumberStamp:(int)ModelName;
// Change properties
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

// Customize property stuff
-(int)getCustomizePropertyIntValue:(int)propid;
-(NSString *)getCustomizePropertyStringValue:(int)propid;
-(BOOL)setCustomizeIntProperty:(int)propid value:(uint)value;
-(BOOL)setCustomizeStringProperty:(int)propid value:(NSString *)value;
-(BOOL)isValidCustomerID:(int)customerid;
- (NSString *)getPreviewURL;
- (ICatchVideoFormat) getVideoFormatCustomer;
// --

-(UIImage *)getAutoDownloadImage;
-(void)updateFW:(string)fwPath;

- (PHFetchResult *)retrieveCameraRollAssetsResult;
- (BOOL)addNewAssetWithURL:(NSURL *)fileURL toAlbum:(NSString *)albumName andFileType:(ICatchFileType)fileType;
- (BOOL)savetoAlbum:(NSString *)albumName andAlbumAssetNum:(uint)assetNum andShareNum:(uint)shareNum;

#pragma mark - Live
- (int)startPublishStreaming:(string)rtmpUrl;
- (int)stopPublishStreaming;
- (BOOL)isStreamSupportPublish;

@end

