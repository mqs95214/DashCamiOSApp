//
//  DashcamListItem.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/9/6.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DashcamListItem.h"
@interface DashcamListItem () {
    
}
@end
@implementation DashcamListItem
-(id) initWithData:(NSString *)text ImageName:(NSString *)imageName DisplayType:(int)type {
    self = [super init];
    _text = text;
    _imageName = imageName;
    _type = type;
    return self;
}
@end
