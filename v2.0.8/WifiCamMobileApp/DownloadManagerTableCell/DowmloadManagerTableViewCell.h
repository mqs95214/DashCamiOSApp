//
//  DowmloadManagerTableViewCell.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/8/16.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#ifndef DowmloadManagerTableViewCell_h
#define DowmloadManagerTableViewCell_h
#import <UIKit/UIKit.h>
@interface DowmloadManagerTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *progressText;
@property (weak, nonatomic) IBOutlet UIButton *stateImageBtn;

@end
#endif /* DowmloadManagerTableViewCell_h */
