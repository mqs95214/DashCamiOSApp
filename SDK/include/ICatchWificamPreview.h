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

#ifndef __ICATCH_WIFICAM_MEDIA_H__
#define __ICATCH_WIFICAM_MEDIA_H__

#include <vector>

#include "type/ICatchVideoFormat.h"
#include "type/ICatchAudioFormat.h"
#include "type/ICatchPreviewMode.h"
#include "type/ICatchFrameBuffer.h"
#include "type/ICatchStreamParam.h"
#include "type/ICatchFileFormat.h"

#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamPreview_pimpl;
class ICATCH_API ICatchWificamPreview
{
private:
	ICatchWificamPreview(ICatchWificamPreview_pimpl* preview_pimpl);

public:
	int start(ICatchStreamParam& param, ICatchPreviewMode previewMode);
	int start(ICatchStreamParam& param, ICatchPreviewMode previewMode, bool disableAudio);
	int start(ICatchStreamParam& param, ICatchPreviewMode previewMode, bool disableAudio, bool convertVideo, bool convertAudio);
	int start(ICatchPreviewMode previewMode);
	int stop();

	int enableAudio();
	int disableAudio();

	int changePreviewMode(ICatchPreviewMode previewMode);

	bool containsVideoStream();
	int getNextVideoFrame(ICatchFrameBuffer* buffer);

	int getVideoFormat(ICatchVideoFormat& videoFormat);
	int getAudioFormat(ICatchAudioFormat& audioFormat);

	bool containsAudioStream();
	int getNextAudioFrame(ICatchFrameBuffer* buffer);

	int startSavePreviewStream(string filePath, string fileName, int fileFormat, bool saveAudio);
	int stopSavePreviewStream();

	int startPublishStreaming(string rtmpUrl);
	int stopPublishStreaming();
	int isStreamSupportPublish();
	int getThumbnail(ICatchFrameBuffer* buffer);
private:
	friend class ICatchWificamSession;
	ICatchWificamPreview_pimpl* preview_pimpl;

private:
	ICatchWificamPreview(ICatchWificamPreview& preview);
	ICatchWificamPreview& operator = (const ICatchWificamPreview&);
};

#endif

