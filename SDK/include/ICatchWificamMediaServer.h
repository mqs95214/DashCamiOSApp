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

#ifndef __ICATCH_WIFICAM_MEDIA_SERVER_H__
#define __ICATCH_WIFICAM_MEDIA_SERVER_H__

#include <string>
#include "type/ICatchCodec.h"
#include "type/ICatchFrameBuffer.h"

#include "ICatchWificamAPI.h"


using namespace std;

class ICATCH_API ICatchWificamMediaServer
{
private:
	ICatchWificamMediaServer();
	static ICatchWificamMediaServer* instance;

public:
	static ICatchWificamMediaServer* getInstance();

public:
    int startMediaServer(string localVideoFile);

    int startMediaServer(bool hasVideo, ICatchCodec video_codec, bool hasAudio, ICatchCodec audio_codec);
    int startMediaServer(bool hasVideo, ICatchCodec video_codec, bool hasAudio, ICatchCodec audio_codec, int sample_rate, int sample_chnl, int sample_bits);

    int closeMediaServer();

    int writeVideoFrame(ICatchFrameBuffer* videoFrame);
    int writeAudioFrame(ICatchFrameBuffer* audioFrame);

private:
	ICatchWificamMediaServer(ICatchWificamMediaServer& mediaServer);
	ICatchWificamMediaServer& operator = (const ICatchWificamMediaServer&);

};

#endif

