//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SetCompletedViewController.h"
#import <NodeMediaClient/NodeMediaClient.h>
#import "SSID_SerialCheck.h"
#import <SystemConfiguration/CaptiveNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectInitPositionViewController : UIViewController<AppDelegateProtocol,NodePlayerDelegate,NSXMLParserDelegate> {
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
    
    
    NSString *SSID;
    SSID_SerialCheck *SSIDSreial;
}
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong,nonatomic) NodePlayer *np;
@property (weak, nonatomic) IBOutlet UIView *nodePlayerView;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;
@property (weak, nonatomic) IBOutlet UILabel *info1;
@end

NS_ASSUME_NONNULL_END
