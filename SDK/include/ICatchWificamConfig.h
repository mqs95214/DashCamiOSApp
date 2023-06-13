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

#ifndef __ICATCH_WIFICAM_CONFIG_H__
#define __ICATCH_WIFICAM_CONFIG_H__

#include <string>
#include "ICatchWificamAPI.h"

using namespace std;

class ICATCH_API ICatchWificamConfig
{
private:
	ICatchWificamConfig();
	static ICatchWificamConfig* instance;

public:
	static ICatchWificamConfig* getInstance();

	// SDK connection check params config
	bool setConnectionCheckParam(int ptpTimeoutCheckCount, int rtpTimeoutInSecs);
	bool setConnectionCheckParam(int ptpTimeoutCheckCount, double ptpTimeoutCheckIntervalInSecs, int rtpTimeoutInSecs);

	int getRtpTimeoutInSecs();
	int getPtpTimeoutCheckCount();
	double getPtpTimeoutCheckIntervalInSecs();

	bool enablePTPIP();
	bool disablePTPIP();

	// preview cache config
	bool setPreviewCacheParam(int cacheTimeInMs, int dropFrameTimeOverMs = 200);
	int getPreviewCacheTime();
	int getDropFrameTime();

	// save streaming file log.
	bool enableDumpMediaStream(bool videoStream, string filePath);
	bool disableDumpMediaStream(bool videoStream);
	bool enableSoftwareDecoder(bool softwareDecoder);
	void allowMosaic(bool mosaic);
};

#endif

