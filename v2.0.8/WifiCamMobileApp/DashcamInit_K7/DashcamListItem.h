//
//  DashcamListItem.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/9/6.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SetTimeDateViewController.h"
NS_ASSUME_NONNULL_BEGIN
@interface DashcamListItem : NSObject{
}
@property(nonatomic,assign)int type;
@property(nonatomic,strong)NSString *text;
@property(nonatomic,strong)NSString *imageName;

-(id) initWithData:(NSString *)text ImageName:(NSString *)imageName DisplayType:(int)type;

@end
NS_ASSUME_NONNULL_END
