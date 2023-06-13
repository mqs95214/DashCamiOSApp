//
//  CollectionViewController.h
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ActivityWrapper.h"
#import "MpbSegmentViewController.h"
#import "SSID_SerialCheck.h"

@interface MpbViewController : UICollectionViewController <UIAlertViewDelegate,
  UIPopoverControllerDelegate, UIActionSheetDelegate,
UICollectionViewDelegateFlowLayout, ActivityWrapperDelegate, MpbSegmentViewControllerDelegate,NSXMLParserDelegate,NSURLConnectionDataDelegate> {
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
    /*NSMutableArray *FileListVideoName;
    NSMutableArray *FileListPhotoName;
    //NSMutableArray *FileListName;
    NSMutableArray *FileListVideoFullName;
    NSMutableArray *FileListPhotoFullName;
    NSMutableArray *FileListVideoSize;
    NSMutableArray *FileListPhotoSize;
    NSMutableArray *FileListVideoTimeCode;
    NSMutableArray *FileListPhotoTimeCode;
    NSMutableArray *FileListVideoTime;
    NSMutableArray *FileListPhotoTime;
    NSMutableArray *FileListVideoLock;
    NSMutableArray *FileListPhotoLock;
    NSMutableArray *FileListVideoAttr;
    NSMutableArray *FileListPhotoAttr;*/

    SSID_SerialCheck *SSIDSreial;
    sqlite3 *db;
    NSString *databaseName;
    NSString *tableName;
}

@property(nonatomic,strong)NSBundle *bundle;
@property(nonatomic, getter = isEnableHeader) BOOL enableHeader;
@property(nonatomic, getter = isEnableHeader) BOOL enableFooter;
@property int observerNo;
@property(nonatomic) BOOL isSend;
@property(nonatomic) BOOL isEdit;
@property NSString* message;


@property(nonatomic) NSMutableArray *FileListVideoName;
@property(nonatomic) NSMutableArray *FileListPhotoName;
@property(nonatomic) NSMutableArray *FileListVideoFullName;
@property(nonatomic) NSMutableArray *FileListPhotoFullName;
@property(nonatomic) NSMutableArray *FileListVideoSize;
@property(nonatomic) NSMutableArray *FileListPhotoSize;
@property(nonatomic) NSMutableArray *FileListVideoTimeCode;
@property(nonatomic) NSMutableArray *FileListPhotoTimeCode;
@property(nonatomic) NSMutableArray *FileListVideoTime;
@property(nonatomic) NSMutableArray *FileListPhotoTime;
@property(nonatomic) NSMutableArray *FileListVideoLock;
@property(nonatomic) NSMutableArray *FileListPhotoLock;
@property(nonatomic) NSMutableArray *FileListVideoAttr;
@property(nonatomic) NSMutableArray *FileListPhotoAttr;
@property(nonatomic) NSMutableArray *FileListChooseItem;
@property (nonatomic,assign) long long NVT_Download_totalLength;
@property(nonatomic, assign)long long receiveLength;
@property(nonatomic) NSString *NvtFileWigth;
@property(nonatomic) NSString *NvtFileHeight;
@property(nonatomic) NSString *NvtFileLength;
@property(nonatomic) NSString *NvtThumbnilPath;

@property(nonatomic) NSUInteger videoIndex;
@property(nonatomic) NSUInteger ChooseItemcount;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;
@property(nonatomic) NSString *SSID;
//@property (nonatomic, strong) NSMutableArray *FileListVideo;
//@property (nonatomic, strong) NSMutableArray *FileListPhoto;

//@property (strong, nonatomic) NSMutableArray *FileProperty;
//@property (strong, nonatomic) NSMutableArray *FileList;
//@property (nonatomic, strong) NSMutableArray *FileProperty;
//@property (nonatomic, strong) NSMutableArray *FileList;
@property(nonatomic) MpbMediaType curMpbMediaType;
+ (instancetype)mpbViewControllerWithIdentifier:(NSString *)identifier;

-(void) setEditStatus;

@end
