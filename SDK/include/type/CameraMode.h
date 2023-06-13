#ifndef __ICATCH_CAMERA_MODE_H__
#define __ICATCH_CAMERA_MODE_H__

enum ICatchCameraMode {
	MODE_VIDEO_OFF			= 0x0001,	//"VideoModeOff"
	MODE_SHARED				= 0x0002,	//"ShareMode"
	MODE_CAMERA				= 0x0003,	//"CameraMode"
	MODE_IDLE				= 0x0004,	//"IdleMode"
	MODE_TIMELAPSE_STILL	= 0x0007,	//"TimeLapse Still"
	MODE_TIMELAPSE_VIDEO	= 0x0008,	//"TimeLapse Video"
	MODE_TIMELAPSE_STILL_OFF= 0x0009,	//"Timelapse Still OFF"
	MODE_TIMELAPSE_VIDEO_OFF= 0x000A,	//"TImelapse Video OFF"
	MODE_VIDEO_ON			= 0x0011,	//"VideoModeOn"
	MODE_UNDEFINED			= 0xFFBF,	//"Undefined mode"
};

#endif

