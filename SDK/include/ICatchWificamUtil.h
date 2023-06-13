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

#ifndef __ICATCH_WIFICAM_UTIL_H__
#define __ICATCH_WIFICAM_UTIL_H__

#include <vector>
#include <string>

#include "type/ICatchVideoSize.h"
#include "type/ICatchWhiteBalance.h"
#include "type/ICatchCaptureDelay.h"
#include "type/ICatchBurstNumber.h"
#include "type/ICatchLightFrequency.h"
#include "type/ICatchDateStamp.h"

#include "ICatchWificamAPI.h"

using namespace std;

class ICATCH_API ICatchWificamUtil
{
public:
	static int convertImageSizes( vector<string> sizes, vector<unsigned int>& imageSizes );
	static int convertVideoSizes( vector<string> sizes, vector<ICatchVideoSize>& videoSizes );

	static int convertImageSize( string size, unsigned int& imageSize );
	static int convertVideoSize( string size, ICatchVideoSize& videoSize );

	static int convertWhiteBalances( vector<unsigned int> values, vector<ICatchWhiteBalance>& wbs );
	static int convertWhiteBalance( unsigned int value, ICatchWhiteBalance& wb );

	static int convertCaptureDelays( vector<unsigned int> values, vector<ICatchCaptureDelay>& cds );
	static int convertCaptureDelay( unsigned int value, ICatchCaptureDelay& cd );

	static int convertBurstNumbers( vector<unsigned int> values, vector<ICatchBurstNumber>& bns );
	static int convertBurstNumber( unsigned int value, ICatchBurstNumber& bn );

	static int convertLightFrequencies( vector<unsigned int> values, vector<ICatchLightFrequency>& lfs );
	static int convertLightFrequency( unsigned int value, ICatchLightFrequency& lf );

	static int convertDateStamps( vector<unsigned int> values, vector<ICatchDateStamp>& dss );
	static int convertDateStamp( unsigned int value, ICatchDateStamp& ds );

	static int decodeAAC(unsigned char* inputData, int frameSize, unsigned char* outputData, int bufferSize);
	static int decodeJPEG(unsigned char* inputData, int frameSize, unsigned char* outputData, int bufferSize);

	static int getImageResolution( string size, unsigned int& width, unsigned int& height );
};

#endif

