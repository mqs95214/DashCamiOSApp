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

#ifndef __ICATCH_WIFICAM_PROPERTY_H__
#define __ICATCH_WIFICAM_PROPERTY_H__

#include <vector>
#include <string>

#include "type/ICatchDateStamp.h"
#include "type/ICatchBurstNumber.h"
#include "type/ICatchWhiteBalance.h"
#include "type/ICatchCaptureDelay.h"
#include "type/ICatchLightFrequency.h"
#include "type/ICatchCameraProperty.h"
#include "type/ICatchVideoFormat.h"

#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamProperty_pimpl;
class ICATCH_API ICatchWificamProperty
{
private:
	ICatchWificamProperty(ICatchWificamProperty_pimpl* property_pimpl);

public:
	int setPropertyValue(int propId, unsigned int value);
	int setPropertyValue(int propId, unsigned int value, int timeoutInSecs);
	int getCurrentPropertyValue(int propId, unsigned int& value);
	int getCurrentPropertyValue(int propId, unsigned int& value, int timeoutInSecs);
	int getSupportedPropertyValues(int propId, vector<unsigned int>& values);
	int getSupportedPropertyValues(int propId, vector<unsigned int>& values, int timeoutInSecs);

	int setPropertyValue(int propId, string value);
	int setPropertyValue(int propId, string value, int timeoutInSecs);
	int getCurrentPropertyValue(int propId, string& value);
	int getCurrentPropertyValue(int propId, string& value, int timeoutInSecs);
	int getSupportedPropertyValues(int propId, vector<string>& values);
	int getSupportedPropertyValues(int propId, vector<string>& values, int timeoutInSecs);

	int setPropertyValue(int propId, const unsigned char* byteValue, int valueSize, int timeoutInSecs);
	int getCurrentPropertyValue(int propId, unsigned char* byteValue, int bufferSize, int& valueSize, int timeoutInSecs);

    int setWhiteBalance(unsigned int value);
	int getSupportedWhiteBalances(vector<unsigned int>& wbs);
	int getCurrentWhiteBalance(unsigned int & wb);

	int setCaptureDelay(unsigned int value);
	int getSupportedCaptureDelays(vector<unsigned int >& cds);
	int getCurrentCaptureDelay(unsigned int& cd);

	int setImageSize(string value);
	int getSupportedImageSizes(vector<string>& imageSizes);
	int getCurrentImageSize(string& is);

	int setVideoSize(string value);
	int getSupportedVideoSizes(vector<string>& videoSizes);
	int getCurrentVideoSize(string& vs);

	int setLightFrequency(unsigned int value);
	int getSupportedLightFrequencies(vector<unsigned int>& lfs);
	int getCurrentLightFrequency(unsigned int& lf);

	int setBurstNumber(unsigned int value);
	int getSupportedBurstNumbers(vector<unsigned int>& bns);
	int getCurrentBurstNumber(unsigned int& bn);

	int setDateStamp(unsigned int value);
	int getSupportedDateStamps(vector<unsigned int>& dss);
	int getCurrentDateStamp(unsigned int& ds);

	int getSupportedTimeLapseIntervals(vector<unsigned int>& tlsis);
	int setTimeLapseInterval(unsigned int value);
	int getCurrentTimeLapseInterval(unsigned int& tlsi);

	int getSupportedTimeLapseDurations(vector<unsigned int>& tlsds);
	int setTimeLapseDuration(unsigned int value);
	int getCurrentTimeLapseDuration(unsigned int& tlsd);

	int getCurrentUpsideDown(unsigned int& upsd);
	int setUpsideDown(unsigned int upsd);

	int getCurrentSlowMotion(unsigned int& sm);
	int setSlowMotion(unsigned int sm);

	int getMaxZoomRatio(unsigned int& maxRatio);
	int getCurrentZoomRatio(unsigned int& curRatio);

	int getSupportedProperties(vector<ICatchCameraProperty>& caps);
	bool supportProperty(unsigned int property);

	int getSupportedStreamingInfos(vector<ICatchVideoFormat>& infos);
	int getCurrentStreamingInfo(ICatchVideoFormat& info);
	int setStreamingInfo(ICatchVideoFormat info);

	int getPreviewCacheTime(unsigned int& cacheTime);

private:
	friend class ICatchWificamSession;
	ICatchWificamProperty_pimpl* property_pimpl;

private:
	ICatchWificamProperty(ICatchWificamProperty& property);
	ICatchWificamProperty& operator = (const ICatchWificamProperty&);
};
#endif

