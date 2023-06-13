#ifndef __ICATCH_FILE_TYPE_H__
#define __ICATCH_FILE_TYPE_H__

enum ICatchFileType {
	TYPE_IMAGE		= 0x01,
	TYPE_VIDEO		= 0x02,
	TYPE_AUDIO		= 0x04,
	TYPE_TEXT		= 0x08,
	TYPE_ALL		= 0x0F,
	TYPE_UNKNOWN	= 0x10,
};

#endif

