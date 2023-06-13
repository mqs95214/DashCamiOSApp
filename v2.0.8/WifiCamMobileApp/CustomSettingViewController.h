//
//  CustomSettingViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/4/9.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SSID_SerialCheck.h"
#import "CustomSettingSubViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
NS_ASSUME_NONNULL_BEGIN

typedef enum U2SettingCountry{
    United_State = 0,
    Canada,
    Russia,
    Spain,
    Germany,
    France,
    Italy,
    Netherlands,
    Belgium,
    Poland,
    Czech,
    Romania,
    UnitedKingdom,
    Other,
    CountryMax,
}U2SettingCountry;

typedef enum DUOHDSettingLanguage{
    DUO_LN_English = 0,
    DUO_LN_Danish,
    DUO_LN_German,
    DUO_LN_Spanish,
    DUO_LN_French,
    DUO_LN_ltalian,
    DUO_LN_Dutch,
    DUO_LN_Norwegian,
    DUO_LN_Finnish,
    DUO_LN_Swedish,
    DUO_LN_LanguageMax,
}DUOHDSettingLanguage;

typedef enum DUOHDSettingCountry{
    DUO_Country_UK_Ireland = 0,
    DUO_Country_Belgium,
    DUO_Country_Denmark,
    DUO_Country_Finland,
    DUO_Country_France,
    DUO_Country_Germany,
    DUO_Country_Italy,
    DUO_Country_Netherlands,
    DUO_Country_Norway,
    DUO_Country_Poland,
    DUO_Country_Spain,
    DUO_Country_Sweden,
    DUO_Country_USA_Eastern,
    DUO_Country_USA_Central,
    DUO_Country_USA_Mountain,
    DUO_Country_USA_Pacific,
    DUO_Country_USA_Alaska,
    DUO_Country_USA_Hawaii,
    DUO_Country_Canada_Newfoundland,
    DUO_Country_Canada_Atlantic,
    DUO_Country_Canada_Eastern,
    DUO_Country_Canada_Central,
    DUO_Country_Canada_Mountain,
    DUO_Country_Canada_Pacific,
    DUO_Country_Mexico_Eastern,
    DUO_Country_Mexico_Central,
    DUO_Country_Mexico_Mountain,
    DUO_Country_Mexico_Pacific,
    DUO_Country_Other,
    DUO_CountryMax,
}DUOHDSettingCountry;


typedef NS_OPTIONS(NSUInteger, SettingSectionType) {
    SettingSectionTypeSetting = 0,
    SettingSectionTypeAlertAction = 1,
    SettingSectionTypeNewFeature = 2,
    SettingSectionTypePhoto = 3,
};

typedef enum SettingTableInfo {
    SettingTableTextLabel,
    SettingTableDetailTextLabel,
    SettingTableDetailType,
    SettingTableDetailData,
    SettingTableDetailLastItem,
    
}SettingTableInfo;


/*Novatek Commond 3014 讀取Setting 所有參數*/



@interface CustomSettingViewController : UIViewController
- (void)back;
@end

NS_ASSUME_NONNULL_END
