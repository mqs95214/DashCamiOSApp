#ifndef __STREAM_PARAM_H__
#define __STREAM_PARAM_H__

#include <string>
#include "ICatchWificamAPI.h"

using namespace std;

class ICATCH_API ICatchStreamParam {
public:
	virtual string getCmdLineParam() = 0;
	virtual int getVideoWidth() = 0;
	virtual int getVideoHeight() = 0;
	virtual ~ICatchStreamParam() {};
};

#endif
