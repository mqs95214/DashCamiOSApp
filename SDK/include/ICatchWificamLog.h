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

#ifndef __ICATCH_WIFICAM_LOG__
#define __ICATCH_WIFICAM_LOG__

#include <string>
#include "ICatchWificamAPI.h"
#include "type/ICatchLogLevel.h"

using namespace std;

#if defined( WIN32 )
typedef void (_stdcall *LogNotify )( string msg );
#else
typedef void (*LogNotify )( string msg );
#endif

class ICATCH_API ICatchWificamLog
{
public:
	static ICatchWificamLog* getInstance();

public:
	void setFileLogOutput(bool fileLog);
	void setFileLogPath(string path);

	void setSystemLogOutput(bool systemLog);

	void setRtpLog(bool enable);
	void setPtpLog(bool enable);

	void setRtpLogLevel(ICatchLogLevel logLevel);
	void setPtpLogLevel(ICatchLogLevel logLevel);

	void setLogCallback(LogNotify notify);
	void setDebugMode(bool debugMode);

private:
	ICatchWificamLog(){}
	static ICatchWificamLog* wificamLog;
};

#endif

