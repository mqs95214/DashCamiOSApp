//
//  FileCollectionViewCell.h
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/5/18.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *file_cellIV;
@property (weak, nonatomic) IBOutlet UIImageView *file_cell_checkIV;
@property (weak, nonatomic) IBOutlet UIButton *file_cellBT;

@end
