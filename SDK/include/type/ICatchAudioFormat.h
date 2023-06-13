#ifndef __ICATCH_AUDIO_FORMAT_H__
#define __ICATCH_AUDIO_FORMAT_H__

#include <string>
#include <string.h>
#include "ICatchWificamAPI.h"

using namespace std;

class ICATCH_API ICatchAudioFormat {
public:

	ICatchAudioFormat();
	ICatchAudioFormat(const ICatchAudioFormat& another);

	int getCodec();
	void setCodec(int codec);

	int getFrequency();
	void setFrequency(int frequency);

	int getSampleBits();
	void setSampleBits(int sampleBits);

	int getNChannels();
	void setNChannels(int nChannels);

private:
	int codec;
	int frequency;
	int nChannels;
	int	sampleBits;
};

#endif

