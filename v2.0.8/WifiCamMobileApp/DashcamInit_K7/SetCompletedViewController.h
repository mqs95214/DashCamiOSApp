//
//  AboutPage2ViewController.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SetCompletedViewController : UIViewController<AppDelegateProtocol>
@property (weak, nonatomic) IBOutlet UILabel *info1Text;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@end

NS_ASSUME_NONNULL_END
