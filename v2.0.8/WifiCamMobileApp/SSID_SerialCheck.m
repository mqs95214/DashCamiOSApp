//
//  SSID_SerialCheck.m
//  WifiCamMobileApp
//
//  Created by MAC on 2018/11/5.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "SSID_SerialCheck.h"

NSString *NOVATEK_C1GW = @"C1GW";
NSString *NOVATEK_C1 = @"C1";
NSString *NOVATEK_D200GW = @"D200GW";
NSString *NOVATEK_D200 = @"D200";
NSString *NOVATEK_BD200GW = @"BD200GW";
NSString *NOVATEK_BD200 = @"BD200";
NSString *NOVATEK_312GW = @"NVT_CARDV 312GW";
NSString *NOVATEK_JK3 = @"KVDR300W";
NSString *NOVATEK_JK4 = @"KVDR400W";
NSString *NOVATEK_JK5 = @"KVDR500W";
NSString *NOVATEK_K3 = @"DRVA301W";
NSString *NOVATEK_K4 = @"DRVA401W";
NSString *NOVATEK_K5 = @"DRVA501W";
NSString *NOVATEK_KX2 = @"DRVA700W";

NSString *ICATCH_U2 = @"Cansonic U2";
NSString *ICATCH_S2Plus = @"Cansonic S2+";
NSString *ICATCH_Z3 = @"UltraDash Z3";
NSString *ICATCH_DUOHD = @"DUO-HD";
NSString *ICATCH_JK6 = @"KVDR600W";
NSString *ICATCH_K6 = @"DRVA601W";
@implementation SSID_SerialCheck

-(int)CheckSSIDSerial:(NSString *)SSID
{
    if([SSID containsString:NOVATEK_C1GW] || [SSID containsString:NOVATEK_D200GW] ||
       [SSID containsString:NOVATEK_C1] || [SSID containsString:NOVATEK_D200] || [SSID containsString:NOVATEK_BD200GW] || [SSID containsString:NOVATEK_BD200] || [SSID containsString:NOVATEK_312GW]||[SSID containsString:NOVATEK_JK3] ||
       [SSID containsString:NOVATEK_JK4] || [SSID containsString:NOVATEK_JK5] ||
       [SSID containsString:NOVATEK_K3] || [SSID containsString:NOVATEK_K4] ||
       [SSID containsString:NOVATEK_K5] || [SSID containsString:NOVATEK_KX2] )
    {
        return NOVATEK_SSIDSerial;
    }
    else if([SSID containsString:ICATCH_U2]||[SSID containsString:ICATCH_S2Plus]||[SSID containsString:ICATCH_Z3]||[SSID containsString:ICATCH_DUOHD] ||
            [SSID containsString:ICATCH_K6] || [SSID containsString:ICATCH_JK6])
    {
        return ICATCH_SSIDSerial;
    }
    else
    {
        return NoSerial;
    }
}
-(int)MatchSSIDReturn:(NSString *)SSID
{
    if([SSID containsString:ICATCH_Z3])
    {
        return CANSONIC_Z3;
    }
    else if([SSID containsString:ICATCH_S2Plus])
    {
        return CANSONIC_S2Plus;
    }
    else if([SSID containsString:ICATCH_U2])
    {
        return CANSONIC_U2;
    }
    else if([SSID containsString:ICATCH_DUOHD])
    {
        return DUO_HD;
    }
    else if([SSID containsString:NOVATEK_C1GW])
    {
        return C1GW;
    }
    else if([SSID containsString:NOVATEK_C1])
    {
        return C1;
    }
    else if([SSID containsString:NOVATEK_BD200GW])
    {
        return BD200GW;
    }
    else if([SSID containsString:NOVATEK_D200GW])
    {
        return BD200;
    }
    else if([SSID containsString:NOVATEK_D200GW])
    {
        return D200GW;
    }
    else if([SSID containsString:NOVATEK_D200])
    {
        return D200;
    }
    else if([SSID containsString:NOVATEK_312GW])
    {
        return CARDV312GW;
    }
    else if([SSID containsString:NOVATEK_JK3])
    {
        return KVDR300W;
    }
    else if([SSID containsString:NOVATEK_JK4])
    {
        return KVDR400W;
    }
    else if([SSID containsString:NOVATEK_JK5])
    {
        return KVDR500W;
    }
    else if([SSID containsString:ICATCH_JK6])
    {
        return KVDR600W;
    }
    else if([SSID containsString:NOVATEK_K3])
    {
        return DRVA301W;
    }
    else if([SSID containsString:NOVATEK_K4])
    {
        return DRVA401W;
    }
    else if([SSID containsString:NOVATEK_K5])
    {
        return DRVA501W;
    }
    else if([SSID containsString:ICATCH_K6])
    {
        return DRVA601W;
    }
    else if([SSID containsString:NOVATEK_KX2])
    {
        return DRVA700W;
    }
    else
    {
        return SSIDModelNone;
    }
}

-(int)CheckICatchArch:(NSString *)SSID
{
    if([SSID containsString:ICATCH_Z3] || [SSID containsString:ICATCH_DUOHD])
    {
        return isV35;
    }
    else if([SSID containsString:ICATCH_U2] || [SSID containsString:ICATCH_S2Plus])
    {
        return isV50;
    }
    else
    {
        return NoneArch;
    }
}
@end
