//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SetWirelessPasswordViewController.h"

NS_ASSUME_NONNULL_BEGIN

const int unknown_speedUnits = 255,mph = 0,kmh = 1;

@interface SelectSpeedUnitsViewController : UIViewController<AppDelegateProtocol,NSXMLParserDelegate> {
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
    int units;
}

@property (weak, nonatomic) IBOutlet UIButton *kmhBtn;
@property (weak, nonatomic) IBOutlet UIButton *mphBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;
@end

NS_ASSUME_NONNULL_END
