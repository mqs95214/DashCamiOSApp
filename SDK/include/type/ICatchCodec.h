#ifndef __ICATCH_CODEC_H__
#define __ICATCH_CODEC_H__

typedef enum ICatchCodec {
	ICATCH_CODEC_QCELP				= 0x01,
	ICATCH_CODEC_AMR				= 0x02,
	ICATCH_CODEC_AMR_WB				= 0x03,
	ICATCH_CODEC_MPA				= 0x04,
	ICATCH_CODEC_MPA_ROBUST			= 0x05,
	ICATCH_CODEC_X_MP3_DRAFT_00		= 0x06,
	ICATCH_CODEC_MP4A_LATM			= 0x07,
	ICATCH_CODEC_VORBIS				= 0x08,
	ICATCH_CODEC_VP8				= 0x09,
	ICATCH_CODEC_AC3				= 0x10,
	ICATCH_CODEC_EAC3				= 0x21,
	ICATCH_CODEC_MP4V_ES			= 0x22,
	ICATCH_CODEC_MPEG4_GENERIC		= 0x23,
	ICATCH_CODEC_MPV				= 0x24,
	ICATCH_CODEC_MP2T				= 0x25,
	ICATCH_CODEC_H261				= 0x26,
	ICATCH_CODEC_H263_1998			= 0x27,
	ICATCH_CODEC_H263_2000			= 0x28,
	ICATCH_CODEC_H264				= 0x29,
	ICATCH_CODEC_DV					= 0x30,
	ICATCH_CODEC_JPEG				= 0x40,
	ICATCH_CODEC_X_QT				= 0x41,
	ICATCH_CODEC_X_QT_QUICKTIME		= 0x42,
	ICATCH_CODEC_PCMU				= 0x43,
	ICATCH_CODEC_GSM				= 0x44,
	ICATCH_CODEC_DVI4				= 0x45,
	ICATCH_CODEC_PCMA				= 0x46,
	ICATCH_CODEC_MP1S				= 0x47,
	ICATCH_CODEC_MP2P				= 0x48,
	ICATCH_CODEC_L8					= 0x49,
	ICATCH_CODEC_L16				= 0x50,
	ICATCH_CODEC_L20				= 0x60,
	ICATCH_CODEC_L24				= 0x61,
	ICATCH_CODEC_G726_16			= 0x62,
	ICATCH_CODEC_G726_24			= 0x63,
	ICATCH_CODEC_G726_32			= 0x64,
	ICATCH_CODEC_G726_40			= 0x65,
	ICATCH_CODEC_SPEEX				= 0x66,
	ICATCH_CODEC_ILBC				= 0x67,
	ICATCH_CODEC_OPUS				= 0x68,
	ICATCH_CODEC_T140				= 0x69,
	ICATCH_CODEC_DAT12				= 0x70,
	ICATCH_CODEC_VND_ONVIF_METADATA	= 0x81,

	/* SDK add */
	ICATCH_CODEC_PCM				= 0x81,
	ICATCH_CODEC_RGB565				= 0x82,
	ICATCH_CODEC_RGB888				= 0x83,
	ICATCH_CODEC_BGR888				= 0x84,
	ICATCH_CODEC_ARGB_8888			= 0x85,
	ICATCH_CODEC_RGBA_8888			= 0x86,

	/* General false */
	ICATCH_CODEC_UNKNOWN			= 0x90,
} IcatchCodec;

#endif

