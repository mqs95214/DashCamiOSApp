//
//  SSID_SerialCheck.h
//  WifiCamMobileApp
//
//  Created by MAC on 2018/11/5.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum Serial{
    NoSerial = 0,
    ICATCH_SSIDSerial,
    NOVATEK_SSIDSerial,
} Serial;
typedef enum Model{
    SSIDModelNone = 0,
    CANSONIC_Z3,
    CANSONIC_U2,
    CANSONIC_S2Plus,
    DUO_HD,
    C1GW,
    C1,
    BD200GW,
    BD200,
    D200GW,
    D200,
    CARDV312GW,
    KVDR300W,
    KVDR400W,
    KVDR500W,
    KVDR600W,
    DRVA301W,
    DRVA401W,
    DRVA501W,
    DRVA601W,
    DRVA700W,
}Model;

typedef enum architecture{
NoneArch = 0,
isV50,
isV35,
}architecture;

@interface SSID_SerialCheck : NSObject
- (int)CheckSSIDSerial:(NSString *)SSID;
- (int)MatchSSIDReturn:(NSString *)SSID;
- (int)CheckICatchArch:(NSString *)SSID;
@end

NS_ASSUME_NONNULL_END
