//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SelectCountryViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface DashcamInitViewController : UIViewController<AppDelegateProtocol>
@property (weak, nonatomic) IBOutlet UILabel *info1;
@property (weak, nonatomic) IBOutlet UILabel *info2;
@property (weak, nonatomic) IBOutlet UILabel *info3;
@property (weak, nonatomic) IBOutlet UILabel *info4;
@property (weak, nonatomic) IBOutlet UILabel *info5;
@property (weak, nonatomic) IBOutlet UILabel *info6;
@property (weak, nonatomic) IBOutlet UILabel *info7;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

NS_ASSUME_NONNULL_END
