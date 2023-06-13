//
//  AppDelegate.h
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kDownloadProgressNotification @"downloadProgressNotification"
static NSString *AppVer = @"V1.0.3";
@protocol AppDelegateProtocol <NSObject>
@optional
-(void)applicationDidEnterBackground:(UIApplication *)application NS_AVAILABLE_IOS(4_0);
-(void)applicationDidBecomeActive:(UIApplication *)application NS_AVAILABLE_IOS(4_0);
-(void)notifyPropertiesReady;
-(NSString *)notifyConnectionBroken;
-(void)sdcardRemoveCallback;
-(void)setButtonEnable:(BOOL)value;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate,NSURLSessionDataDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic,strong) UINavigationController *rootNavController;
@property (nonatomic,assign)BOOL allowRotation;
@property(nonatomic) BOOL isReconnecting;
//
- (void)saveContext;
@property (nonatomic, weak) IBOutlet id<AppDelegateProtocol> delegate;

//NSURLSession
- (void)beginDownloadWithUrl:(NSString *)downloadURLString;
- (void)pauseDownload;
- (void)continueDownload;
@property (nonatomic , strong) NSOutputStream *stream;
@property (nonatomic , strong) NSURLSessionDataTask *task;
@property (nonatomic , assign) NSInteger totalLength;
@property (nonatomic , assign) NSInteger currentDataLenght;

@property (strong, nonatomic) NSBundle *bundle_language;
-(NSString*) getAppVer;
-(NSBundle*) getBundleLanguage;
-(NSString*) getDateFormat;
-(NSString*) getSpeedUnit;
-(NSString*) getTimeFormat;
-(NSString*) getLanguage;
-(NSString*) getStringForKey:(NSString*)key withTable:(NSString*)table;
-(void) initLanguage;
- (bool) addData:(sqlite3*) db tableName:(NSString*)tableName list:(NSMutableArray*) dataList;
- (NSString*) inquiryContent:(sqlite3*) db tableName:(NSString*)tableName inquiryTag:(NSString*)tag;
- (bool) inquiryData:(sqlite3*) db tableName:(NSString*)tableName inquiryTag:(NSString*)tag;
- (int) inquiryDataCount:(sqlite3*) db tableName:(NSString*)tableName;
- (bool) modifyData:(sqlite3*) db tableName:(NSString*)tableName columnName1:(NSString*)columnName1 cur:(NSString*)data1 columnName2:(NSString*)columnName2 modify:(NSString*)data2;
- (bool) deleteData:(sqlite3*) db tableName:(NSString*)tableName columnName:(NSString*)columnName cur:(NSString*)data1;
@end
