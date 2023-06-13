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

#ifndef __ICATCH_WIFICAM_ASSIST_H__
#define __ICATCH_WIFICAM_ASSIST_H__

#include <string>
#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamSession;

class ICATCH_API ICatchWificamAssist
{
public:
	static ICatchWificamAssist* getInstance();
	static void destroy();

	bool supportLocalPlay(string file);

	int updateFw(ICatchWificamSession* session, string fwFile);
	void notifyUpdateFw();

	int simpleConfig(string essid, string passwd, string key, string ipAddr, string macAddr);
	int simpleConfig(string essid, string passwd, string key, string ipAddr, string macAddr, int timeout);
	int simpleConfigGet(string& content);
	int simpleConfigCancel();

private:
	ICatchWificamAssist();
	static ICatchWificamAssist* instance;
};

#endif

