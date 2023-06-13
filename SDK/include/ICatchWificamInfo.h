/**************************************************************************
 *
 *         Copyright (c) 2014 by iCatch Technology Co., Ltd.
 *
 *  This software is copyrighted by and is the property of Sunplus
 *  Technology Co., Ltd. All rights are reserved by Sunplus Technology
 *  Co., Ltd. This software may only be used in accordance with the
 *  corresponding license agreement. Any unauthorized use, duplication,
 *  distribution, or disclosure of this software is expressly forbidden.
 *
 *  This Copyright notice MUST not be removed or modified without prior
 *  written consent of Sunplus Technology Co., Ltd.
 *
 *  Sunplus Technology Co., Ltd. reserves the right to modify this
 *  software without notice.
 *
 *  Sunplus Technology Co., Ltd.
 *  19, Innovation First Road, Science-Based Industrial Park,
 *  Hsin-Chu, Taiwan, R.O.C.
 *
 **************************************************************************/

#ifndef __ICATCH_WIFICAM_INFO_H__
#define __ICATCH_WIFICAM_INFO_H__

#include <string>
#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamInfo_pimpl;

class ICATCH_API ICatchWificamInfo
{
private:
	ICatchWificamInfo(ICatchWificamInfo_pimpl* info_pimpl);

public:
	string getSDKVersion();
	string getCameraProductName();
	string getCameraFWVersion();

private:
	static string sdkVersion;

private:
	friend class ICatchWificamSession;
	ICatchWificamInfo_pimpl* info_pimpl;

private:
	ICatchWificamInfo(ICatchWificamInfo& info);
	ICatchWificamInfo& operator = (const ICatchWificamInfo&);
};

#endif

