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

#ifndef __ICATCH_WIFICAM_CONTROL_H__
#define __ICATCH_WIFICAM_CONTROL_H__

#include <vector>
#include <string>

#include "type/CameraMode.h"
#include "type/ICatchMode.h"
#include "type/ICatchEventID.h"

#include "ICatchWificamAPI.h"
#include "ICatchWificamListener.h"

using namespace std;

class ICatchWificamControl_pimpl;
class ICATCH_API ICatchWificamControl
{
private:
	ICatchWificamControl(ICatchWificamControl_pimpl* control_pimpl);

public:
	int getCurrentBatteryLevel(unsigned int& bl);

	int getSupportedModes(vector<ICatchMode>& modes);
	ICatchCameraMode getCurrentCameraMode();
	bool supportVideoPlayback();

	int startTimeLapse();
	int stopTimeLapse();

	int startMovieRecord();
	int stopMovieRecord();

	int capturePhoto();
	int capturePhoto(int timeoutInSecs);
	int triggerCapturePhoto();

	int isSDCardExist(bool& exist);
	int getFreeSpaceInImages( unsigned int& count );
	int getRemainRecordingTime( unsigned int& secs );

	int formatStorage();
	int formatStorage(int timeoutInSecs);

	int zoomIn();
	int zoomOut();

	int pan(int xshift, int yshfit);
	int panReset();

	int toStandbyMode();

	int addEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener);
	int delEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener);

	int addCustomEventListener( unsigned int customEvtID, ICatchWificamListener* listener );
	int delCustomEventListener( unsigned int customEvtID, ICatchWificamListener* listener );

private:
	friend class ICatchWificamSession;
	ICatchWificamControl_pimpl* control_pimpl;

private:
	ICatchWificamControl(ICatchWificamControl& control);
	ICatchWificamControl& operator = (const ICatchWificamControl&);
};

#endif

