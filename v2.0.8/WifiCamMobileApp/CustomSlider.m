//
//  CustomSlider.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/8/19.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CustomSlider.h"
@implementation CustomSlider
-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 13;
    rect.size.width = rect.size.width + 25;
    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], 15, 15);
}
@end
