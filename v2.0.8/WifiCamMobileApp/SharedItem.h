//
//  SharedItem.h
//  WifiCamMobileApp
//
//  Created by MAC on 2018/8/21.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SharedItem : NSObject<UIActivityItemSource>
-(instancetype)initWithData:(UIImage*)img andFile:(NSURL*)file;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSURL *path;
@end


