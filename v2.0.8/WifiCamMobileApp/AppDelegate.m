//
//  AppDelegate.m
//  WifiCamMobileApp
//
//  Created by Sunmedia Apple on 13-12-5.
//  Copyright (c) 2013年 iCatchTech. All rights reserved.
//

#import "AppDelegate.h"
#import "ExceptionHandler.h"
#ifdef DEBUG
#include "ICatchWificamConfig.h"
#endif
#import "TestHttpViewController.h"
#import "HomeVC.h"
#import "DashcamInitViewController.h"
#include "WifiCamSDKEventListener.h"
#import "WifiCamControl.h"
#import "Reachability+Ext.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ViewController.h"
//#import <BuglyHotfix/Bugly.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SSID_SerialCheck.h"
#import "ViewPreviewMenuController.h"
#import "MpbSegmentViewController.h"
#import "CustomSettingViewController.h"
#import "NovatekRecordingViewController.h"
#import "NSURLSession+NSURLSession_Resume.h"

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

typedef void(^CompletionHandlerType)();

@interface AppDelegate ()
{
    int count;
    BOOL current_Network;
    UIViewController *preController;
    sqlite3 *db;
    NSString *databaseName;
    NSString *tableName;
    
}
@property(nonatomic) BOOL enableLog;
@property(nonatomic) FILE *appLogFile;
//@property (nonatomic) FILE *sdkLogFile;
@property(nonatomic) WifiCamObserver *globalObserver;
@property(strong, nonatomic) UIAlertView *reconnectionAlertView;
@property(strong, nonatomic) UIAlertView *connectionErrorAlertView;
@property(strong, nonatomic) UIAlertView *connectionErrorAlertView1;
@property(strong, nonatomic) UIAlertView *connectingAlertView;
@property(nonatomic) NSString *current_ssid;
@property(nonatomic) NSTimer *timer;
@property(nonatomic) WifiCamObserver *sdcardRemoveObserver;
@property(nonatomic) BOOL isTimeout;
@property(nonatomic) NSTimer *timeOutTimer;
@property(nonatomic) SSID_SerialCheck *SSIDSreial;

@end


#define UmengAppkey @"55765a2467e58ed0a60031d8"
static NSString * const kClientID = @"759186550079-prbjm58kcrideo6lh4uukdqqp2q9bc67.apps.googleusercontent.com";

@implementation AppDelegate
/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[GIDSignIn sharedInstance] handleURL:url
                               sourceApplication:sourceApplication
                                      annotation:annotation];
}*/

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    sleep(2);
    self.current_ssid = [self checkSSID];
    self.SSIDSreial = [[SSID_SerialCheck alloc] init];
    
   // NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    //current_Network = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [GMSServices provideAPIKey:@"AIzaSyC_PN1wG75Vp8-Ah0GG2ElKkQcERU-6iz4"];
    NSLog(@"didFinishLaunchingWithOptions");
    if (@available(iOS 11.0, *)) {
        
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
    }
    
  //  if([self.current_ssid ])
    
    if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == NOVATEK_SSIDSerial)
    {
        UINavigationController *rootNavController = (UINavigationController *)self.window.rootViewController;
        /*TestHttpViewController *homeVC = (TestHttpViewController *)rootNavController.topViewController;*/
        HomeVC *homeVC = (HomeVC *)rootNavController.topViewController;
        homeVC.managedObjectContext = self.managedObjectContext;
        
        
        /*DashcamInitViewController *dashcamInitViewController = (DashcamInitViewController *)_rootNavController.topViewController;
        dashcamInitViewController.managedObjectContext = self.managedObjectContext;*/
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == ICATCH_SSIDSerial)
    {
        NSDate *date = [NSDate date];

        [self registerDefaultsFromSettingsBundle];

        //[GIDSignIn sharedInstance].clientID = kClientID;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults stringForKey:@"RTMPURL"]) {
            [defaults setObject:@"rtmp://a.rtmp.youtube.com/live2/7m5m-wuhz-ryaq-89ss" forKey:@"RTMPURL"];
        }
        
        // Enalbe log
        NSUserDefaults *defaultSettings = [NSUserDefaults standardUserDefaults];
        self.enableLog = [defaultSettings boolForKey:@"PreferenceSpecifier:Log"];
        
    //    self.enableLog = YES; // Test on iOS9
        if (_enableLog) {
            [self startLogToFile];
        } else {
            [self cleanLogs];
        }
        
        AppLogInfo(AppLogTagAPP, @"=================== app run starting ====================");
        AppLogInfo(AppLogTagAPP, @"App Version: %@", [defaultSettings stringForKey:@"PreferenceSpecifiers:1"]);
        AppLogInfo(AppLogTagAPP, @"Build: %@", [defaultSettings stringForKey:@"PreferenceSpecifiers:2"]);
        
        NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        AppLogInfo(AppLogTagAPP, @"Run Date: %@", [dateformatter stringFromDate:date]);
        AppLogInfo(AppLogTagAPP, @"=========================================================");
        
        //
        [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
        
        //
        //UINavigationController *rootNavController = (UINavigationController *)self.window.rootViewController;
        _rootNavController = (UINavigationController *)self.window.rootViewController;
        /*TestHttpViewController *homeVC = (TestHttpViewController *)rootNavController.topViewController;*/
        HomeVC *homeVC = (HomeVC *)_rootNavController.topViewController;
        homeVC.managedObjectContext = self.managedObjectContext;
        
        
        [self addGlobalObserver];
    }
    else
    {
        //UINavigationController *rootNavController = (UINavigationController *)self.window.rootViewController;
        _rootNavController = (UINavigationController *)self.window.rootViewController;
        /*TestHttpViewController *homeVC = (TestHttpViewController *)rootNavController.topViewController;*/
        HomeVC *homeVC = (HomeVC *)_rootNavController.topViewController;
        homeVC.managedObjectContext = self.managedObjectContext;
        
        /*DashcamInitViewController *dashcamInitViewController = (DashcamInitViewController *)_rootNavController.topViewController;
        dashcamInitViewController.managedObjectContext = self.managedObjectContext;*/
    
    }
    self.isReconnecting = YES;
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(checkCurrentNetworkStatus)
                                                    userInfo:nil repeats:YES];
    }
    
    return YES;
}
-(NSString*) getAppVer {
    return AppVer;
}
-(NSBundle*) getBundleLanguage {
    return _bundle_language;
}
-(NSString*) getDateFormat {
    return [self inquiryContent:db tableName:tableName inquiryTag:@"DateStyle"];
}
-(NSString*) getSpeedUnit {
    return [self inquiryContent:db tableName:tableName inquiryTag:@"Unit"];
}
-(NSString*) getTimeFormat {
    return [self inquiryContent:db tableName:tableName inquiryTag:@"TimeFormat"];
}
-(NSString*) getLanguage {
    return [self inquiryContent:db tableName:tableName inquiryTag:@"Language"];
}
-(NSString*) getStringForKey:(NSString*)key withTable:(NSString*)table {
    if(_bundle_language) {
        return NSLocalizedStringFromTableInBundle(key, table, _bundle_language, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}
-(void) initLanguage{
    
    databaseName = @"info";
    tableName = @"appsetting";
    if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"English"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"en" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"German"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"de" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"French"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"fr" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Dutch"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"nl" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Italian"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"it" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Spanish"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"es" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Portuguese"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"pt-BR" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Russia"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ru" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Polish"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"pl" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Czech"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"cs" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    } else if([[self inquiryContent:db tableName:tableName inquiryTag:@"Language"]  isEqual: @"Romanian"]) {
        NSString *path = [[NSBundle mainBundle]pathForResource:@"ro" ofType:@"lproj"];
        _bundle_language = [NSBundle bundleWithPath:path];
    }
}
- (bool) addData:(sqlite3*) db tableName:(NSString*)tableName list:(NSMutableArray*) dataList {
    
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"insert into %@(_id,name,content) values(%@,'%@','%@')",tableName,[dataList objectAtIndex:0],[dataList objectAtIndex:1],[dataList objectAtIndex:2]];
        NSLog(@"strAA = %@",str);
        const char *insertSql=[str UTF8String];//"insert into appsetting(_id,name,content) values(0,'Orange','iOTEC Systems')";
        //const char *insertSql="insert into appsetting(_id,name,address) values(0,'Orange','iOTEC Systems')";
        if (sqlite3_exec(db, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"INSERT OK");
            return YES;
        }else{
            sqlite3_close(db);
            NSLog(@"Insert error: %s",errorMsg);
            return NO;
        }
    } else {
        return NO;
    }
    
}
- (NSString*) inquiryContent:(sqlite3*) db tableName:(NSString*)tableName inquiryTag:(NSString*)tag {
    NSString *content = @"";
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        NSString *str = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
        NSLog(@"strBB = %@",str);
        const char *sql = [str UTF8String];//"select * from data3";
        sqlite3_stmt *statement =nil;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *_id,*name;
                
                _id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                //NSLog(@"Record: %@> %@ , %@",_id, name, content);
                if([name  isEqual: tag]) {
                    sqlite3_finalize(statement);
                    sqlite3_close(db);
                    return content;
                }
            }
            
            //sqlite3_finalize(statement);
        }
        //sqlite3_close(db);
    }
    return content;
}
- (bool) inquiryData:(sqlite3*) db tableName:(NSString*)tableName inquiryTag:(NSString*)tag {
    bool hasInquiryData = false;
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        NSString *str = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
        
        const char *sql = [str UTF8String];//"select * from data3";
        sqlite3_stmt *statement =nil;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *_id,*name, *content;
                
                _id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                NSLog(@"Record: %@> %@ , %@",_id, name, content);
                if([name  isEqual: tag]) {
                    hasInquiryData = true;
                    break;
                }
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    return hasInquiryData;
}
- (int) inquiryDataCount:(sqlite3*) db tableName:(NSString*)tableName {
    int count = 0;
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        NSString *str = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
        NSLog(@"strBB = %@",str);
        const char *sql = [str UTF8String];//"select * from data3";
        sqlite3_stmt *statement =nil;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                count++;
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
    NSLog(@"database count = %d",count);
    return count;
}
- (bool) modifyData:(sqlite3*) db tableName:(NSString*)tableName columnName1:(NSString*)columnName1 cur:(NSString*)data1 columnName2:(NSString*)columnName2 modify:(NSString*)data2 {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'",tableName,columnName1,data1,columnName2,data2];
        NSLog(@"strYY = %@",str);
        const char *sql = [str UTF8String];//"UPDATE member SET name='Apple' WHERE name='Orange'";
        
        if (sqlite3_exec(db, sql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"UPDATE OK");
            sqlite3_close(db);
            return YES;
        }else{
            NSLog(@"UPDATE error: %s",errorMsg);
            sqlite3_close(db);
            return NO;
        }
    } else {
        return NO;
    }
}
- (bool) deleteData:(sqlite3*) db tableName:(NSString*)tableName columnName:(NSString*)columnName cur:(NSString*)data1 {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@='%@'",tableName,columnName,data1];
        const char *sql = [str UTF8String];//"DELETE FROM member WHERE name='Apple'";
        
        if (sqlite3_exec(db, sql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"DELETE OK");
            return YES;
        }else{
            NSLog(@"DELETE error: %s",errorMsg);
            return NO;
        }
    } else {
        return NO;
    }
}
/*- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}
*/
#if 1
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    
    if (_allowRotation) {
        return UIInterfaceOrientationMaskAllButUpsideDown;

    }else{
        return UIInterfaceOrientationMaskPortrait;
    }
}
#endif
- (UIViewController *)getCurrentVC
{
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        if(resultVC!=nil) {
            preController = resultVC;
        }
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
- (UIViewController*)_topViewController:(UIViewController*)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;    }
    return nil;
}
- (void)checkCurrentNetworkStatus
{
    
    self.current_ssid = [self checkSSID];
    if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == ICATCH_SSIDSerial || [self.SSIDSreial CheckSSIDSerial:self.current_ssid] == NOVATEK_SSIDSerial)
    {
        current_Network = YES;
    }
    else
    {
        if(current_Network)
        {//
            UIViewController *curController = [self getCurrentVC];
            if(curController!=nil) {
                if ([curController isKindOfClass:[ViewPreviewMenuController class]]){
                    current_Network = NO;
                    NSLog(@"curController  ViewPreviewMenuController");
                    if(preController != nil) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"disconnectWiFi" object:@"close"];
                    }
                } else if ([curController isKindOfClass:[MpbSegmentViewController class]]){
                    current_Network = NO;
                    NSLog(@"curController  MpbSegmentViewController");
                    if(preController != nil) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeMpbSegmentViewController" object:@"close"];
                    }
                } else if([curController isKindOfClass:[CustomSettingViewController class]]) {
                    current_Network = NO;
                    NSLog(@"curController  CustomSettingViewController");
                    if(preController != nil) {
                        //[curController dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeCustomSettingViewController" object:@"close"];
                    }
                } else if([curController isKindOfClass:[ViewController class]]) {
                    current_Network = NO;
                    NSLog(@"curController  ViewController");
                    if(preController != nil) {
                        //[curController dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeViewController" object:@"close"];
                    }
                } else if([curController isKindOfClass:[NovatekRecordingViewController class]]) {
                    current_Network = NO;
                    NSLog(@"curController  NovatekRecordingViewController");
                    if(preController != nil) {
                        //[curController dismissViewControllerAnimated:YES completion:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeNovatekRecordingViewController" object:@"close"];
                    }
                }
            }
        }
    }
#if 0
    if (![Reachability didConnectedToCameraHotspot]) {
       // if (!_isReconnecting) {
            //[self notifyDisconnectionEvent];
            
           /* [vc.navigationController presentedViewController:vc animated:NO completion:nil];*/
            if(count == 5 && !current_Network)
            {
                count = 0;
                current_Network = YES;
               /* for (UIViewController *controller in self.window.rootViewController.navigationController.viewControllers)
                {
                    if ([controller isKindOfClass:[ViewPreviewMenuController class]]){
                        [self.window.rootViewController.navigationController popToViewController:controller animated:YES];
                        break;
                    }
                }*/
                UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:[NSBundle mainBundle]];
                ViewPreviewMenuController *controllerD = [storyboard instantiateViewControllerWithIdentifier:@"PreviewStoryID"];
                [self.window.rootViewController.navigationController pushViewController:controllerD animated:YES];
                /*ViewPreviewMenuController *vc = [[ViewPreviewMenuController alloc] init];
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                [self.window.rootViewController presentViewController:nav animated:YES completion:nil];*/
                /*[self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];*/
                 
                
                /*[self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];
                UIStoryboard *MyStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil ];
                UINavigationController *rootNavController = (UINavigationController *)self.window.rootViewController;
                ViewController *vc = [MyStoryboard instantiateViewControllerWithIdentifier:@"PreviewStoryID"];
                [self.window.rootViewController.navigationController pushViewController:vc animated:NO];*/
                /*[self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];*/
            /*ViewController *VC = [[ViewController alloc] init];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:VC];
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];*/
            }
            else
            {
                count++;
            }
        }
        else
        {
            count = 0;
            current_Network = NO;
        }
#endif
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, doneand throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //TRACE();
    NSLog(@"applicationWillResignActive");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"applicationDidEnterBackground");
    self.current_ssid = [self checkSSID];
    if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == NOVATEK_SSIDSerial)
    {
        [[Reachability reachabilityForLocalWiFi] stopNotifier];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        [self.timer invalidate];
        _isReconnecting = NO;
        [self.timeOutTimer invalidate];
        _isTimeout = NO;
        UIApplication *app = [UIApplication sharedApplication];
        UIBackgroundTaskIdentifier bgTask = 0;
        
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == ICATCH_SSIDSerial)
    {
        [self removeGlobalObserver];
        [[Reachability reachabilityForLocalWiFi] stopNotifier];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
        [self.timer invalidate];
        _isReconnecting = NO;
        [self.timeOutTimer invalidate];
        _isTimeout = NO;
        
        if (![[SDK instance] isBusy]) {
            if ([self.delegate respondsToSelector:@selector(applicationDidEnterBackground:)]) {
                AppLog(@"Execute delegate method.");
                [self.delegate applicationDidEnterBackground:nil];
            } else {
                AppLog(@"Execute default method.");
                dispatch_sync([[SDK instance] sdkQueue], ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraDestroySDKNotification"
                                                                        object:nil];
                    [[SDK instance] destroySDK];
                });
            }
            
            //[self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];
        } else {
            NSTimeInterval ti = 0;
            ti = [[UIApplication sharedApplication] backgroundTimeRemaining];
            NSLog(@"backgroundTimeRemaining: %f", ti);
        }
        
        if (!_connectingAlertView.hidden) {
            [_connectingAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        if (!_connectionErrorAlertView.hidden) {
            [_connectionErrorAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
        if (!_connectionErrorAlertView1.hidden) {
            [_connectionErrorAlertView1 dismissWithClickedButtonIndex:0 animated:NO];
        }
        if (!_reconnectionAlertView.hidden) {
            [_reconnectionAlertView dismissWithClickedButtonIndex:0 animated:NO];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"applicationWillEnterForeground");
    self.current_ssid = [self checkSSID];
    if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == NOVATEK_SSIDSerial)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerShouldReloadNotification" object:nil];
    }
    else if([self.SSIDSreial CheckSSIDSerial:self.current_ssid] == ICATCH_SSIDSerial)
    {
        [self addGlobalObserver];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerShouldReloadNotification" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerShouldReloadNotification" object:nil];
    }
    
    if (![self.timer isValid]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(checkCurrentNetworkStatus)
                                                    userInfo:nil repeats:YES];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    if ([self.delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [self.delegate applicationDidBecomeActive:nil];
        
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    AppLog(@"%s", __func__);
    //[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    if (_enableLog) {
        [self stopLog];
    }
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    TRACE();
}

#pragma mark - Log

- (void)startLogToFile
{
    // Get the document directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // Name the log folder & file
    NSDate *date = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyyMMdd-HHmmss"];
    NSString *name = [dateformatter stringFromDate:date];
    NSString *appLogFileName = [NSString stringWithFormat:@"APP-%@.log", name];
    // Create the log folder
    NSString *logDirectory = [documentsDirectory stringByAppendingPathComponent:name];
    [[NSFileManager defaultManager] createDirectoryAtPath:logDirectory withIntermediateDirectories:NO attributes:nil error:nil];
    // Create(Open) the log file
    NSString *appLogFilePath = [logDirectory stringByAppendingPathComponent:appLogFileName];
    self.appLogFile = freopen([appLogFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    
    //NSString *sdkLogFileName = [NSString stringWithFormat:@"SDK-%@.log", [NSDate date]];
    //NSString *sdkLogFilePath = [documentsDirectory stringByAppendingPathComponent:sdkLogFileName];
    //self.sdkLogFile = freopen([sdkLogFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    
    // Log4SDK
    [[SDK instance] enableLogSdkAtDiretctory:logDirectory enable:YES];
    
    TRACE();
}

- (void)stopLog
{
    TRACE();
    fclose(_appLogFile);
    //fclose(_sdkLogFile);
}

- (void)cleanLogs
{
   /* NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSArray *documentsDirectoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    NSString *logFilePath = nil;
    for (NSString *fileName in  documentsDirectoryContents) {
        if (![fileName isEqualToString:@"Camera.sqlite"] && ![fileName isEqualToString:@"Camera.sqlite-shm"] && ![fileName isEqualToString:@"Camera.sqlite-wal"]) {
            
            logFilePath = [documentsDirectory stringByAppendingPathComponent:fileName];
            [[NSFileManager defaultManager] removeItemAtPath:logFilePath error:nil];
        }
        
    }*/
}

// retrieve the default setting values
- (void)registerDefaultsFromSettingsBundle {
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    if(!settingsBundle) {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    for(NSDictionary *prefSpecification in preferences) {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if(key) {
            [defaultsToRegister setObject:[prefSpecification objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultsToRegister];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    //NSURL* modelURL=[[NSBundle mainBundle] URLForResource:@"Camera" withExtension:@"momd"];
    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    return _managedObjectModel;
}

/**
 Returns the URL to the application's documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // copy the default store (with a pre-populated data) into our Documents folder
    //
    NSString *documentsStorePath =
    [[[self applicationDocumentsDirectory] path] stringByAppendingPathComponent:@"Camera.sqlite"];
    AppLog(@"sqlite's path: %@", documentsStorePath);
   
    // if the expected store doesn't exist, copy the default store
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsStorePath]) {
        NSString *defaultStorePath = [[NSBundle mainBundle] pathForResource:@"Camera" ofType:@"sqlite"];
        if (defaultStorePath) {
            [[NSFileManager defaultManager] copyItemAtPath:defaultStorePath toPath:documentsStorePath error:NULL];
        }
    }
    
    _persistentStoreCoordinator =
    [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // add the default store to our coordinator
    NSError *error;
    NSURL *defaultStoreURL = [NSURL fileURLWithPath:documentsStorePath];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:defaultStoreURL
                                                         options:nil
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
        abort();
#endif
    }
    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Core Data Saving support
- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#ifdef DEBUG
            abort();
#endif
        }
    }
}
#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case APP_RECONNECT_ALERT_TAG:
            if (buttonIndex == 0) {
               [self globalReconnect];
            } else if (buttonIndex == 1) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];
                //exit(0);
            }
            
            break;
            
        case APP_CONNECT_ERROR_TAG:
            if (buttonIndex == 0) {
                [self.window.rootViewController dismissViewControllerAnimated:YES completion: nil];
                //exit(0);
            }
            break;
            
        case APP_CUSTOMER_ALERT_TAG:
            [[SDK instance] destroySDK];
            exit(0);
            break;
            
        case APP_TIMEOUT_ALERT_TAG:
            if (buttonIndex == 0) {
                AppLogTRACE();
                [self.window.rootViewController dismissViewControllerAnimated:YES completion:^{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[SDK instance] destroySDK];
                    });
                }];
            }
            break;
            
        default:
            break;
    }
}

#pragma mark - Observer
-(void)addGlobalObserver {
#if USE_SDK_EVENT_DISCONNECTED
    WifiCamSDKEventListener *listener = new WifiCamSDKEventListener(self, @selector(notifyDisconnectionEvent));
    self.globalObserver = [[WifiCamObserver alloc] initWithListener:listener eventType:ICATCH_EVENT_CONNECTION_DISCONNECTED isCustomized:NO isGlobal:YES];
    [[SDK instance] addObserver:_globalObserver];
#else
#endif
    
    WifiCamSDKEventListener *sdcardRemovelistener = new WifiCamSDKEventListener(self, @selector(notifySdCardRemoveEvent));
    self.sdcardRemoveObserver = [[WifiCamObserver alloc] initWithListener:sdcardRemovelistener eventType:ICATCH_EVENT_SDCARD_REMOVED isCustomized:NO isGlobal:YES];
    [[SDK instance] addObserver:self.sdcardRemoveObserver];
}

-(void)removeGlobalObserver {
#if USE_SDK_EVENT_DISCONNECTED
    [[SDK instance] removeObserver:_globalObserver];
    delete _globalObserver.listener;
    _globalObserver.listener = NULL;
    self.globalObserver = nil;
#esle
#endif
    
    [[SDK instance] removeObserver:self.sdcardRemoveObserver];
    delete self.sdcardRemoveObserver.listener;
    self.sdcardRemoveObserver.listener = NULL;
    self.sdcardRemoveObserver = nil;
}

- (void)notifySdCardRemoveEvent
{
    AppLog(@"SDCardRemoved event was received.");
    if ([self.delegate respondsToSelector:@selector(sdcardRemoveCallback)]) {
        [self.delegate sdcardRemoveCallback];
    }
}

-(void)notifyDisconnectionEvent {
#if USE_SDK_EVENT_DISCONNECTED
#else
    if (_current_ssid && [[self checkSSID] isEqualToString:_current_ssid] && [Reachability didConnectedToCameraHotspot]) {
        return;
    }
#endif
    
    AppLog(@"Disconnectino event was received.");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraNetworkDisconnectedNotification"
                                                        object:nil];

    _current_ssid = nil;
    if ([self.delegate respondsToSelector:@selector(notifyConnectionBroken)]) {
        _current_ssid = [self.delegate notifyConnectionBroken];
    } else {
        dispatch_async([[SDK instance] sdkQueue], ^{
            [[SDK instance] destroySDK];
        });
    }
    
    if (_current_ssid) {
        [NSThread sleepForTimeInterval:0.03];
        [self globalReconnect];
        
        if (![self.timeOutTimer isValid]) {
            self.timeOutTimer = [NSTimer scheduledTimerWithTimeInterval:55.0 target:self selector:@selector(timeOutHandle) userInfo:nil repeats:NO];
        }
    } else {
        if (!_reconnectionAlertView.visible) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_reconnectionAlertView show];
                _isReconnecting = YES;
            });
        }
    }
//    //[self removeGlobalObserver];
//    if (!_reconnectionAlertView.visible) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [_reconnectionAlertView show];
//        });
//    }
}

-(void)globalReconnect
{
    TRACE();
     [self addGlobalObserver];
#if USE_SDK_EVENT_DISCONNECTED
    if ([[SDK instance] isConnected]) {
        return;
    }
#else
    if (!_isTimeout) {
        if ([Reachability didConnectedToCameraHotspot] && [[SDK instance] isConnected]) {
            return;
        }
    }
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!_current_ssid) {
            TRACE();
            if (!_connectingAlertView) {
                self.connectingAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                      message:NSLocalizedString(@"Connecting", nil)
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:nil, nil];
            }
            
            [_connectingAlertView show];
        } else {
            TRACE();
            NSString *connectingMessage = [NSString stringWithFormat:@"%@ %@ ...", NSLocalizedString(@"Reconnect to",nil),_current_ssid];
            
            //========Add by Tom========//
            //[self showGCDNoteWithMessage:connectingMessage withAnimated:YES withAcvity:YES];
        }
        
        _isReconnecting = YES;
        dispatch_async([[SDK instance] sdkQueue], ^{
//            [NSThread sleepForTimeInterval:1.0];
            
            int totalCheckCount = 30; // 60times : 30s
            while (totalCheckCount-- > 0 && !_isTimeout) {
                @autoreleasepool {
                    if ([Reachability didConnectedToCameraHotspot]) {
                        [[SDK instance] destroySDK];
                        if ([[SDK instance] initializeSDK]) {
                            [WifiCamControl scan];
                            
                            WifiCamManager *app = [WifiCamManager instance];
                            WifiCam *wifiCam = [app.wifiCams objectAtIndex:0];
                            wifiCam.camera = [WifiCamControl createOneCamera];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                _isReconnecting = NO;
                                
                                if (!_current_ssid) {
                                    [_connectingAlertView dismissWithClickedButtonIndex:0 animated:NO];
                                } else {
                                    
                                }
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"kCameraNetworkConnectedNotification"
                                                                                    object:nil];
                            });
                            break;
                        }
                    }
                    
                    AppLog(@"[%d]NotReachable -- Sleep 500ms", totalCheckCount);
                    [NSThread sleepForTimeInterval:0.5];
                }
            }
            
            if (totalCheckCount <= 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!_current_ssid) {
                        [_connectingAlertView dismissWithClickedButtonIndex:0 animated:NO];
                    } else {
                        
                    }
//                    [_reconnectionAlertView show];
                    NSString *ssid = [self checkSSID];
                    if (ssid == nil) {
                        [_connectionErrorAlertView show];
                    } else {
                        if (_current_ssid && ![ssid isEqualToString:_current_ssid]) {
                            [_connectionErrorAlertView1 show];
                        } else {
                            [_reconnectionAlertView show];
                        }
                    }
                });
            }
            self.isTimeout = NO;
            [self.timeOutTimer invalidate];
        });
    });
}

- (void)timeOutHandle
{
    if (![[SDK instance] isConnected]) {
        TRACE();
        self.isTimeout = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            /*if (!_current_ssid) {
                [_connectingAlertView dismissWithClickedButtonIndex:0 animated:NO];
            } else {
                [self hideGCDiscreetNoteView:YES];
            }
            NSString *ssid = [self checkSSID];
            if (ssid == nil) {
                [_connectionErrorAlertView show];
            } else {
                if (_current_ssid && ![ssid isEqualToString:_current_ssid]) {
                    [_connectionErrorAlertView1 show];
                } else {
                    [_reconnectionAlertView show];
                }
            }*/
            UIAlertView *timeOutAlert = [[UIAlertView alloc] initWithTitle:nil
                                               message           :NSLocalizedString(@"ActionTimeOut.", nil)
                                               delegate          :self
                                               cancelButtonTitle :NSLocalizedString(@"Exit", nil)
                                               otherButtonTitles :nil, nil];
            timeOutAlert.tag = APP_TIMEOUT_ALERT_TAG;
            [timeOutAlert show];
        });
    }
}

- (NSString *)checkSSID
{
    //    NSArray * networkInterfaces = [NEHotspotHelper supportedNetworkInterfaces];
    //    NSLog(@"Networks: %@",networkInterfaces);
    
    NSString *ssid = nil;
    //NSString *bssid = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo((CFStringRef)CFArrayGetValueAtIndex(myArray, 0));
        /*
         Core Foundation functions have names that indicate when you own a returned object:
         
         Object-creation functions that have “Create” embedded in the name;
         Object-duplication functions that have “Copy” embedded in the name.
         If you own an object, it is your responsibility to relinquish ownership (using CFRelease) when you have finished with it.
         
         */
        CFRelease(myArray);
        if (myDict) {
            NSDictionary *dict = (NSDictionary *)CFBridgingRelease(myDict);
            ssid = [dict valueForKey:@"SSID"];
            //bssid = [dict valueForKey:@"BSSID"];
        }
    }
    //AppLog(@"ssid : %@", ssid);
    //NSLog(@"bssid: %@", bssid);
    
    return ssid;
}


/*
- (void)showGCDNoteWithMessage:(NSString *)message
                  withAnimated:(BOOL)animated
                    withAcvity:(BOOL)activity{
    TRACE();
    if ([self.delegate respondsToSelector:@selector(setButtonEnable:)]) {
        [self.delegate setButtonEnable:NO];
    }
    [self.notificationView setView:((ViewController *)(self.delegate)).view];
    [self.notificationView setTextLabel:message];
    [self.notificationView setShowActivity:activity];
    [self.notificationView show:animated];
    
}
*/
static void uncaughtExceptionHandler(NSException *exception) {
    /*NSLog(@"CRASH: %@", exception);
    
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);*/
}



//-------------------

- (void)beginDownloadWithUrl:(NSString *)downloadURLString {
    _currentDataLenght = 0;
    // 建立session
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    // 建立流
    // 這裡的XXX是視訊流下載後儲存的路徑
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *NewPaths;
    NewPaths = [path stringByAppendingString:@"/KENWOOD DASH CAM MANAGER"];
    NSRange searchIndex = [downloadURLString rangeOfString:@"/" options:NSBackwardsSearch];
    if(searchIndex.location == NSNotFound) {
        return;
    } else {
        
        NewPaths = [path stringByAppendingString:[NSString stringWithFormat:@"/KENWOOD DASH CAM MANAGER%@",[downloadURLString substringWithRange:NSMakeRange(searchIndex.location, downloadURLString.length-searchIndex.location)]]];
        //NSLog(@"filename  = %@ ",NewPaths);
    }
    
    self.stream = [NSOutputStream outputStreamToFileAtPath:NewPaths append:YES];
    
    // 建立請求
    // 這裡的url是你的網路視訊URL字串
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadURLString]];
    
    // 建立一個Data任務
    self.task = [session dataTaskWithRequest:request];
    // 利用KVC修改taskIdentifier的值，這是任務的標識
    [_task setValue:@(11111) forKeyPath:@"taskIdentifier"];
    
    [self.task resume];
}
- (void)URLSession:(NSURLSession* )session dataTask:(NSURLSessionDataTask* )dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    // 開啟流
    [self.stream open];
    
    // 獲得伺服器這次請求 返回資料的總長度
    self.totalLength = [response.allHeaderFields[@"Content-Length"] integerValue];
    
    // 接收這個請求，允許接收伺服器的資料
    completionHandler(NSURLSessionResponseAllow);
}

// 接收到伺服器返回的資料，一直回撥，直到下載完成,暫停時會停止呼叫
- (void)URLSession:(NSURLSession* )session dataTask:(NSURLSessionDataTask* )dataTask didReceiveData:(NSData *)data
{
    // 寫入資料
    [self.stream write:(const uint8_t *)data.bytes maxLength:data.length];
    _currentDataLenght+=data.length;
    // 下載進度
    //NSUInteger receivedSize = [UIUtil getDownloadFileLengthPathWithUrl:@"1122aabb"];
    //CGFloat progress = 1.0 * receivedSize / self.totalLength;
    
    NSLog(@"%lf    %ld",(float)_currentDataLenght/(float)_totalLength*100,(long)_currentDataLenght);
}

// 當任務下載完成或失敗會呼叫
- (void)URLSession:(NSURLSession* )session task:(NSURLSessionTask* )task didCompleteWithError:(NSError *)error
{
    if (error == nil) {
        // 下載成功 關閉流，取消任務
        [self.stream close];
        self.stream = nil;
        [self.task cancel];
        self.task = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadComplete_Novatek" object:@"close"];
        });
        
    } else {
        NSLog(@"error:   %@",error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadFailed_Novatek" object:@"close"];
        });
        
    }
    
}
@end
