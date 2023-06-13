//
//  FileListViewController.h
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/4/9.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MBProgressHUD.h"
#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GoogleMapsBase/GoogleMapsBase.h>
#import "AppDelegate.h"
typedef NS_ENUM(NSInteger, MetadataSerial) {
    Novatake_6x = 0x0001,
    Novatake_5x,
    Novatake_7x,
    trim,
    ICatchSerial,
    NoneSerial,
};

enum EditSelect_e {
    EditNone = 0,
    EditLockAction,
    EditUnLockAction,
    EditDeleteAction,
    EditShareAction,
    EditCutAction
};

enum {
    search_Bottom,
    search_Top
};

@interface FileListViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver,GMSMapViewDelegate,UIGestureRecognizerDelegate,AppDelegateProtocol>
-(instancetype)initWithData:(UIImage*)img andFile:(NSURL*)file;
@property(nonatomic) NSInteger viewType;
@property(nonatomic) NSInteger listType;
@property(nonatomic) NSInteger oriType;
@property(nonatomic) MBProgressHUD *progressHUD;


@end



