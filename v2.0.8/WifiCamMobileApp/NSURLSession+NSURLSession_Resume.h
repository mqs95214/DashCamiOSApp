//
//  NSURLSession+NSURLSession_Resume.h
//  WifiCamMobileApp
//
//  Created by MAC on 2019/8/13.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURLSession (NSURLSession_Resume)
- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData;
@end

NS_ASSUME_NONNULL_END
