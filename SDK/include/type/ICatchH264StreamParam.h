#ifndef __ICATCH_H264_STREAM_PARAM_H__
#define __ICATCH_H264_STREAM_PARAM_H__

#include "ICatchWificamAPI.h"
#include "ICatchStreamParam.h"
#include "ICatchFrameSize.h"

class ICATCH_API ICatchH264StreamParam : public ICatchStreamParam {
public:
	ICatchH264StreamParam(int width = 640, int height = 360, int bitrate = 5000000, int fps = 30);
	virtual ~ICatchH264StreamParam();
	string getCmdLineParam();
	int getVideoWidth();
	int getVideoHeight();

protected:
	int bitrate;
	int fps;

	FrameSize* frameSize;
};

#endif
