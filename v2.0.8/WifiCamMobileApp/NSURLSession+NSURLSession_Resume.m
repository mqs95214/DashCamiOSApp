//
//  NSURLSession+NSURLSession_Resume.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/8/13.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "NSURLSession+NSURLSession_Resume.h"
#import <UIKit/UIKit.h>

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)

static NSData * correctRequestData(NSData *data) {
    if (!data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:data] != nil) {
        return data;
    }
    NSMutableDictionary *archive = [[NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!archive) {
        return nil;
    }
    NSInteger k = 0;
    id objectss = archive[@"$objects"];
    while ([objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",k]] != nil) {
        k += 1;
    }
    NSInteger i = 0;
    while ([archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",i]];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
        i++;
    }
    if ([archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *arr = archive[@"$objects"];
        NSMutableDictionary *dic = arr[1];
        id obj = [dic objectForKey:@"__nsurlrequest_proto_props"];
        if (obj) {
            [dic setValue:obj forKey:[NSString stringWithFormat:@"$%ld",i+k]];
            [dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [arr replaceObjectAtIndex:1 withObject:dic];
            archive[@"$objects"] = arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [archive[@"$top"] setObject:archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return result;
}

#pragma mark- private


static NSMutableDictionary *getResumeDictionary(NSData *data) {
    return [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
}

static NSData *getCorrectResumeData(NSData *data) {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    if (data == nil) {
        return  nil;
    }
    NSMutableDictionary *resumeDictionary = getResumeDictionary(data);
    if (resumeDictionary == nil) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] = correctRequestData(resumeDictionary[kResumeCurrentRequest]);
    resumeDictionary[kResumeOriginalRequest] = correctRequestData(resumeDictionary[kResumeOriginalRequest]);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}

@implementation NSURLSession (NSURLSession_Resume)

- (NSURLSessionDownloadTask *)downloadTaskWithCorrectResumeData:(NSData *)resumeData {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    NSData *cData = getCorrectResumeData(resumeData);
    cData = cData ? cData:resumeData;
    NSURLSessionDownloadTask *task = [self downloadTaskWithResumeData:cData];
    NSMutableDictionary *resumeDic = getResumeDictionary(cData);
    if (resumeDic) {
        if (task.originalRequest == nil) {
            NSData *originalReqData = resumeDic[kResumeOriginalRequest];
            NSURLRequest *originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:originalReqData ];
            if (originalRequest) {
                [task setValue:originalRequest forKey:@"originalRequest"];
            }
        }
        if (task.currentRequest == nil) {
            NSData *currentReqData = resumeDic[kResumeCurrentRequest];
            NSURLRequest *currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:currentReqData];
            if (currentRequest) {
                [task setValue:currentRequest forKey:@"currentRequest"];
            }
        }
    }
    return task;
}
@end
