#ifndef __ICATCH_MEDIA_FORMAT_H__
#define __ICATCH_MEDIA_FORMAT_H__

#include <string>
#include <string.h>
#include "ICatchWificamAPI.h"

using namespace std;

#define MAX_MEDIA_ATTR_SIZE 255

class ICATCH_API ICatchVideoFormat {
public:

	ICatchVideoFormat();
	ICatchVideoFormat(const ICatchVideoFormat& another);
	ICatchVideoFormat( unsigned int value );

	~ICatchVideoFormat();

	string getMineType();
	void setMineType(string mineType);

	int getCodec();
	void setCodec(int codec);

	int getVideoW();
	void setVideoW(int videoW);

	int getVideoH();
	void setVideoH(int videoH);

	unsigned int getBitrate();
	void setBitrate( unsigned int bitrate );

	int getDurationUs();
	void setDurationUs(int durationUs);

	int getMaxInputSize();
	void setMaxInputSize(int maxInputSize);

	int getCsd_0_size();
	const unsigned char* getCsd_0();
	int setCsd_0(const unsigned char* csd_0, int dataSize);

	int getCsd_1_size();
	const unsigned char* getCsd_1();
	int setCsd_1(const unsigned char* csd_1, int dataSize);

	void setFps(unsigned int fps);
	unsigned int getFps();

private:
	string mineType;
	int codec;

	int videoW;
	int videoH;

	unsigned int bitrate;

	int durationUs;
	int maxInputSize;

	int csd_0_size;
	int csd_1_size;

	unsigned char* csd_0;
	unsigned char* csd_1;

	unsigned int fps;
};

#endif
