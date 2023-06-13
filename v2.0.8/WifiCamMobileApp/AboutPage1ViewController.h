//
//  AboutPage1ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/3.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSID_SerialCheck.h"
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface AboutPage1ViewController : UIViewController<AppDelegateProtocol,NSXMLParserDelegate>{
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
    BOOL ssidFlag;
    BOOL passwordFlag;
    BOOL isVideo;
    NSArray *elementToParse;  //要存储的元素
    NSFileHandle *fileHandle;
}

@property (nonatomic, strong) SSID_SerialCheck *SSIDSreial;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;@property(nonatomic) NSString *SSID;
@end

NS_ASSUME_NONNULL_END
