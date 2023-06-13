//
//  ICatchMJPGStreamParam.h
//  iCatchWifcamMobileSDK
//
//  Created by SA2 on 11/13/13.
//  Copyright (c) 2013 SA2. All rights reserved.
//

#ifndef __ICATCH_MJPG_STREAM_PARAM_H__
#define __ICATCH_MJPG_STREAM_PARAM_H__

#include "ICatchWificamAPI.h"
#include "ICatchFrameSize.h"
#include "ICatchStreamParam.h"

class ICatchWificamSession;
class ICatchWificamSession_pimpl;

class ICATCH_API ICatchMJPGStreamParam : public ICatchStreamParam
{
public:
	ICatchMJPGStreamParam(int width = 640, int height = 360, int bitrate = 5000000, int qSize = 50);
	ICatchMJPGStreamParam( ICatchWificamSession* session, int bitrate = 5000000, int qSize = 50);
	virtual ~ICatchMJPGStreamParam();
	string getCmdLineParam();
	int getVideoWidth();
	int getVideoHeight();

private:
	ICatchMJPGStreamParam(ICatchWificamSession_pimpl* session_pimpl, int bitrate = 5000000, int qSize = 50);
	int createStreamParameter(ICatchWificamSession_pimpl* session_pimpl, int bitrate, int qSize);

private:
	friend class ICatchWificamPreview_pimpl;

protected:
	static const int MIN_QSIZE = 20;
	static const int MAX_QSIZE = 100;
	static const int MIN_BITRATE = 1000;
	static const int MAX_BITRATE = 10000000;
	static FrameSize FRAME_LISTS[ 5 ];

	int qSize;
	int bitrate;

	FrameSize* frameSize;
	StreamSource source;
};

#endif
