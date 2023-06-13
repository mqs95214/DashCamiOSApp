#ifndef __ICATCH_FRAME_BUFFER_H__
#define __ICATCH_FRAME_BUFFER_H__

#include "ICatchCodec.h"
#include "ICatchWificamAPI.h"

class ICATCH_API ICatchFrameBuffer {
public:
	ICatchFrameBuffer(int bufferSize);
	ICatchFrameBuffer(unsigned char* buffer, int bufferSize);

	virtual ~ICatchFrameBuffer();

	int getBufferSize();
	unsigned char* getBuffer();

	int getFrameSize();
	bool setFrameSize(int dataSize);

	void setPresentationTime(double presentationTime);
	double getPresentationTime();

	void setCodec(IcatchCodec codec);
	IcatchCodec getCodec();

	void setDecodeTime(long long t);
	long long getDecodeTime();

private:
	unsigned char* buffer;
	int frameSize;

	int		bufferSize;
	double	presentationTime;
	long long decode_time_;

	IcatchCodec codec;

	bool innerAlloc;
};

#endif

