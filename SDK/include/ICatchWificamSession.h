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

#ifndef __ICATCH_WIFICAM_SESSION_H__
#define __ICATCH_WIFICAM_SESSION_H__

#include <string>

#include "type/ICatchEventID.h"
#include "type/ICatchCameraProperty.h"

#include "ICatchWificamAPI.h"
#include "ICatchWificamListener.h"

using namespace std;

class ICatchWificamInfo;
class ICatchWificamState;
class ICatchWificamPreview;
class ICatchWificamControl;
class ICatchWificamProperty;
class ICatchWificamPlayback;
class ICatchWificamVideoPlayback;
class ICatchWificamSession_pimpl;

class ICATCH_API ICatchWificamSession
{
public:
	/* wake up camera */
	static int wakeUpCamera(string macAddress);

	/* start or stop device scan */
	static bool startDeviceScan();
	static bool stopDeviceScan();

	/* init device, before using p2p connection */
	static bool deviceInit(string ipAddr);

public:
	/* listener add or remove api */
	static int addEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener);
	static int delEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener);
	static int addEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener, bool forAllSession);
	static int delEventListener(ICatchEventID icatchEvtID, ICatchWificamListener* listener, bool forAllSession);

public:
	ICatchWificamSession();
	~ICatchWificamSession();

public:
	/* get the id of this session */
	int getSessionID();

	/* prepare of destroy session */
	int prepareSession(string ipAddr, string username = "anonymous", string password = "anonymous@icatchtek.com");
	bool destroySession();

	/* to check whether the connection status between app and camera. */
	bool checkConnection();

	/* get feature client */
	ICatchWificamInfo* getInfoClient();
	ICatchWificamState* getStateClient();
	ICatchWificamPreview* getPreviewClient();
	ICatchWificamControl* getControlClient();
	ICatchWificamProperty* getPropertyClient();
	ICatchWificamPlayback* getPlaybackClient();
	ICatchWificamVideoPlayback* getVideoPlaybackClient();

private:
	ICatchWificamInfo*			infoClient;
	ICatchWificamState*			stateClient;
	ICatchWificamPreview*		previewClient;
	ICatchWificamControl*		controlClient;
	ICatchWificamPlayback*		playbackClient;
	ICatchWificamProperty*		propertyClient;
	ICatchWificamVideoPlayback*	videoPlaybackClient;

private:
	friend class ICatchWificamAssist;
	friend class ICatchMJPGStreamParam;
	ICatchWificamSession_pimpl* session_pimpl;

private:
	ICatchWificamSession(ICatchWificamSession& session);
	ICatchWificamSession& operator = (const ICatchWificamSession&);
};

#endif

