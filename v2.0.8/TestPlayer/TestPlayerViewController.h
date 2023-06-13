//
//  ViewController.h
//  Player
//
//  Created by zqnb on 16/6/13.
//  Copyright © 2016年 yxy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TestPlayerViewController : UIViewController<NSXMLParserDelegate>{

NSString *currentElementCommand;  //用于存储元素标签的值
NSString *currentElementStatus;  //用于存储元素标签的值
NSString *currentElementValue;  //用于存储元素标签的值


BOOL storingFlag; //查询标签所对应的元素是否存在

BOOL CmdFlag;
BOOL StatusFlag;
BOOL ValueFlag;
BOOL StrogeValueFlag;

NSArray *elementToParse;  //要存储的元素
}

@end

