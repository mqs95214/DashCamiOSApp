//
//  MpbTableViewController.h
//  WifiCamMobileApp
//
//  Created by ZJ on 2017/3/24.
//  Copyright © 2017年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MpbSegmentViewController.h"
#import "SSID_SerialCheck.h"
#import "AppDelegate.h"
@class MpbTableViewController;


@interface MpbTableViewController : UITableViewController <MpbSegmentViewControllerDelegate, AppDelegateProtocol,NSXMLParserDelegate,NSURLConnectionDataDelegate,UIGestureRecognizerDelegate>
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
    NSString *DocumentsfilePath;
    bool isDownloadError;
    NSURLConnection *connect;
}


@property(nonatomic) NSMutableDictionary *FileVideoInfo;
@property(nonatomic) NSMutableDictionary *FilePhotoInfo;

@property(nonatomic) NSMutableArray *FileListVideoProperty;
@property(nonatomic) NSMutableArray *FileListPhotoProperty;

@property(nonatomic) NSArray *FileListVideoPropertyCopy;
@property(nonatomic) NSArray *FileListPhotoPropertyCopy;

@property(nonatomic) NSMutableArray *FileListICatchPropertyTemp;
@property(nonatomic) NSMutableArray *FileListICatchPropertySort;
@property(nonatomic) NSMutableArray *FileListVideoPropertyTemp;
@property(nonatomic) NSMutableArray *FileListVideoPropertySort;
@property(nonatomic) NSMutableArray *FileListPhotoPropertyTemp;
@property(nonatomic) NSMutableArray *FileListPhotoPropertySort;

@property(nonatomic) NSMutableArray *FileListChooseItem;
@property (nonatomic,assign) long long NVT_Download_totalLength;
@property(nonatomic, assign)long long receiveLength;
@property(nonatomic) NSString *NvtFileWigth;
@property(nonatomic) NSString *NvtFileHeight;
@property(nonatomic) NSString *NvtFileLength;
@property(nonatomic) NSString *NvtThumbnilPath;
@property(nonatomic) NSString *NvtPlayerUrl;


@property(nonatomic) NSUInteger NvtFileTable;
@property(nonatomic) NSUInteger NvtFileTotalCount;
@property(nonatomic) NSUInteger videoIndex;
@property(nonatomic) NSUInteger ChooseItemcount;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;

@property(nonatomic) MpbMediaType curMpbMediaType;

+ (instancetype)tableViewControllerWithIdentifier:(NSString *)identifier;
- (void)updateVideoPbProgress:(double)value;
- (void)updateVideoPbProgressState:(BOOL)caching;
- (void)stopVideoPb;
- (void)showServerStreamError;
@end
