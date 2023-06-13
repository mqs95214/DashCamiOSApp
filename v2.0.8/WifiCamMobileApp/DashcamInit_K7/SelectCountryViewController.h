//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SetTimeDateViewController.h"
#import "DashcamListItem.h"
#import "DashcamInitTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN
const int unknown_country = 255,country_UnitedStates_EST = 0,country_UnitedStates_HST = 5,country_Canada_NST = 6,country_Canada_PST = 11
,country_Russia_KALT = 12,country_Russia_PETT = 22,country_Spain = 23,country_Germany = 24,country_France = 25,country_Italy = 26,country_Netherlands = 27,country_Belgium = 28,country_Poland = 29,country_Czech = 30,country_Romania = 31,
country_UnitedKingdom = 32,country_others = 33;
const int countryMode = 0,countryUnitedStatesMode = 1,countryCanadaMode = 2,countryRussiaMode = 3,dstMode = 4;
@interface SelectCountryViewController : UIViewController<AppDelegateProtocol,UITableViewDataSource,UITableViewDelegate,NSXMLParserDelegate>{
    NSMutableArray *list;
    int curDisplayMode;
    int curCountry;
    
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    BOOL storingFlag; //查询标签所对应的元素是否存在
    
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StringFlag;
    BOOL MovieLiveFlag;
    BOOL StrogeValueFlag;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;

@end

NS_ASSUME_NONNULL_END
