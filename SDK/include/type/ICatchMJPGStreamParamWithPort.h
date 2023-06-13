#ifndef iCatchWificamMobileSDK_MjpgParam_withPort_h
#define iCatchWificamMobileSDK_MjpgParam_withPort_h

#include "ICatchWificamAPI.h"
#include "ICatchMJPGStreamParam.h"

class ICATCH_API ICatchMJPGStreamParamWithPort : public ICatchMJPGStreamParam {
public:
	ICatchMJPGStreamParamWithPort( int port = 554, int width = 640, int height = 360, int bitrate = 5000000, int qSize = 50 );
	string getCmdLineParam();

private:
	int port;
};

#endif

