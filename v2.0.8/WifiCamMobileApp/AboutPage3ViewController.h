//
//  AboutPage3ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface AboutPage3ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *appSettingTitle;
@property (nonatomic) NSMutableArray *list;
    @property (nonatomic) NSMutableArray *list_database;
    @property (nonatomic) int curLayer;
    @property (nonatomic) NSMutableArray *contentList;
@end
enum {
    TimeFormat_e,
    DateStyle_e,
    Unit_e,
    Language_e
};
NS_ASSUME_NONNULL_END
