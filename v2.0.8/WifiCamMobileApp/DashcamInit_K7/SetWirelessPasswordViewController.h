//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "FormatSDCardViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetWirelessPasswordViewController : UIViewController<AppDelegateProtocol,UITextFieldDelegate,NSXMLParserDelegate> {
    NSString *currentElementCommand;  //用于存储元素标签的值
    NSString *currentElementStatus;  //用于存储元素标签的值
    NSString *currentElementValue;  //用于存储元素标签的值
    BOOL storingFlag; //查询标签所对应的元素是否存在
    
    BOOL CmdFlag;
    BOOL StatusFlag;
    BOOL ValueFlag;
    BOOL StringFlag;
    BOOL MovieLiveFlag;
    BOOL ssidFlag;
    BOOL passwordFlag;
    BOOL StrogeValueFlag;
}
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UILabel *passwordText;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordCheckText;
@property (weak, nonatomic) IBOutlet UITextField *passwordConfirmTextField;
@property (weak, nonatomic) IBOutlet UILabel *passwordPrompt;
@property (weak, nonatomic) IBOutlet UILabel *passwordConfirmPrompt;
@property (weak, nonatomic) IBOutlet UIButton *passwordVisibilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *passwordConfirmVisibilityBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *NVTGetHttpValueDict;
@end

NS_ASSUME_NONNULL_END
