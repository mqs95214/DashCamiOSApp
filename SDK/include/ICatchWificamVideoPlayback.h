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

#ifndef __ICATCH_WIFICAM_VIDEO_PLAYBACK_H__
#define __ICATCH_WIFICAM_VIDEO_PLAYBACK_H__

#include "type/ICatchFile.h"
#include "type/ICatchFrameBuffer.h"
#include "type/ICatchVideoFormat.h"
#include "type/ICatchAudioFormat.h"

#include "ICatchWificamAPI.h"

class ICatchWificamVideoPlayback_pimpl;
class ICATCH_API ICatchWificamVideoPlayback
{
private:
	ICatchWificamVideoPlayback(ICatchWificamVideoPlayback_pimpl* videoPlayback_pimpl);

public:
	int play(ICatchFile file);
	int play(ICatchFile file, bool disableAudio);
	int play(ICatchFile file, bool disableAudio, bool fromRemote);
	int stop();

	bool containsVideoStream();
	bool containsAudioStream();

	int getVideoFormat(ICatchVideoFormat& videoFormat);
	int getAudioFormat(ICatchAudioFormat& audioFormat);

	int getNextVideoFrame(ICatchFrameBuffer* buffer);
	int getNextAudioFrame(ICatchFrameBuffer* buffer);

	int startThumbnailGet( string filename, int width, int height, int q, int startTime, int endTime, int interval );
	int stopThumbnailGet();

	int downloadVideoThumbnail(string filePath, char* buffer, int bufferSize);
	int deleteVideoThumbnail(string filePath);

	int trimVideo( string filename, int startTime, int endTime );

public:
	int getLength(double& timeInSecs);

	int pause();
	int resume();
	int seek(double timeInSecs);

	int fastForward(double speed);
	int rewind(double speed);

private:
	friend class ICatchWificamSession;
	ICatchWificamVideoPlayback_pimpl* videoPlayback_pimpl;

private:
	ICatchWificamVideoPlayback(ICatchWificamVideoPlayback& videoPlayback);
	ICatchWificamVideoPlayback& operator = (const ICatchWificamVideoPlayback&);
};

#endif

