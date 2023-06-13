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

#ifndef __ICATCH_WIFI_CAM_PLAYBACK_H__
#define __ICATCH_WIFI_CAM_PLAYBACK_H__

#include <vector>

#include "type/ICatchFile.h"
#include "type/ICatchFrameBuffer.h"

#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamPlayback_pimpl;
class ICATCH_API ICatchWificamPlayback
{
private:
	ICatchWificamPlayback(ICatchWificamPlayback_pimpl* playback_pimpl);

public:
	/* 
	* listFiles API extension
	* bref : count files from remote device.
	*/
	int getFileCount();

	/*
	* listFiles API extension
	* bref : 
	*	list range files. only get a party of files from remote device.
	*
	* param :
	* type [in] : refrence ICatchFileType.h
	* startIndex [in] : value [0~getFileCount() - 2]
	* endIndex [in] : valuse [1 ~ getFileCount() -1]
	* timeoutInSecs [in] : unit seconds 
	* files [out] : refrence ICatchFile.h
	*
	* return value:
	*	ICH_SUCCEED = 0 is success. other error code is fail. 
	*
	* Warning : 
	*	1. first call getFileCount API,  second call listFiles.
	*	2. endIndex - startIndex < 800.
	*   3. endIndex - startIndex may not equal files.size().
	*   4. real file count is files.size().
	*
	* Eg get all files:
	*	getFileCount() = 1000
	*   1. startIndex = 0, endIndex = 799
	*	2. startIndex = 800 , endIndex = 1000 - 1
	*/
	int listFiles(ICatchFileType type, int startIndex, int endIndex, int timeoutInSecs, vector<ICatchFile> &files);

	int listFiles(ICatchFileType type, vector<ICatchFile>& files);
	int listFiles(ICatchFileType type, vector<ICatchFile>& files, int timeoutInSecs);
	int openFileTransChannel();
	int downloadFileQuick(ICatchFile* file, string path);
	int closeFileTransChannel();

	int downloadFile(ICatchFile* file, ICatchFrameBuffer* dataBuffer);
	int downloadFile(ICatchFile* file, string path);
	int downloadFile( string srcPath, string dstPath );
	int uploadFile(string localPath, string remotePath);
	int uploadFileQuick(string localPath, string remotePath);
	int cancelFileDownload();

	int deleteFile(ICatchFile* file);

	int getThumbnail(ICatchFile* file, ICatchFrameBuffer* dataBuffer);
	int getQuickview(ICatchFile* file, ICatchFrameBuffer* dataBuffer);

private:
	friend class ICatchWificamSession;
	ICatchWificamPlayback_pimpl* playback_pimpl;

private:
	ICatchWificamPlayback(ICatchWificamPlayback& playback);
	ICatchWificamPlayback& operator = (const ICatchWificamPlayback&);
};

#endif

