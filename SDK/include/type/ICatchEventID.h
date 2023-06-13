#ifndef __ICATCH_EVENT_TYPE_H__
#define __ICATCH_EVENT_TYPE_H__

typedef enum ICatchEventID {
	/*-----------------------------------------------------
	  * file events
	  */
	ICATCH_EVENT_FILE_ADDED						= 0x01,
	ICATCH_EVENT_FILE_REMOVED					= 0x02,
	ICATCH_EVENT_FILE_INFO_CHANGED				= 0x03,

	/*-----------------------------------------------------
	  * sd card events
	  */
	ICATCH_EVENT_SDCARD_FULL					= 0x11,
	ICATCH_EVENT_SDCARD_ERROR					= 0x12,
	ICATCH_EVENT_SDCARD_REMOVED					= 0x13,
	ICATCH_EVENT_SDCARD_INFO_CHANGED			= 0x14,

	/*-----------------------------------------------------
	  * other events
	  */
	ICATCH_EVENT_VIDEO_ON						= 0x21,
	ICATCH_EVENT_VIDEO_OFF						= 0x22,
	ICATCH_EVENT_CAPTURE_COMPLETE				= 0x23,
	ICATCH_EVENT_BATTERY_LEVEL_CHANGED			= 0x24,

	/*-----------------------------------------------------
	  * device events
	  */
	ICATCH_EVENT_DEVICE_INFO_CHANGED			= 0x31,

	ICATCH_EVENT_WHITE_BALANCE_PROP_CHANGED		= 0x32,
	ICATCH_EVENT_CAPTURE_DELAY_PROP_CHANGED		= 0x33,
	ICATCH_EVENT_IMAGE_SIZE_PROP_CHANGED		= 0x34,
	ICATCH_EVENT_VIDEO_SIZE_PROP_CHANGED		= 0x35,
	ICATCH_EVENT_LIGHT_FREQUENCY_PROP_CHANGED	= 0x36,
	ICATCH_EVENT_BURST_NUMBER_PROP_CHANGED		= 0x37,

	/*------------------------------------------------------
	  * SDK's inner events
	  */
	ICATCH_EVENT_SERVER_STREAM_ERROR				= 0x41,
	ICATCH_EVENT_MEDIA_STREAM_CLOSED				= 0x42,
	ICATCH_EVENT_VIDEO_STREAM_PLAYING_ENDED			= 0x43,
	ICATCH_EVENT_AUDIO_STREAM_PLAYING_ENDED			= 0x44,

	ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_PROGRESS	= 0x45,
	ICATCH_EVENT_VIDEO_PLAYBACK_CACHING_CHANGED		= 0x46,

	ICATCH_EVENT_AUDIO_PLAYBACK_CACHING_PROGRESS	= 0x47,
	ICATCH_EVENT_AUDIO_PLAYBACK_CACHING_CHANGED		= 0x48,

	ICATCH_EVENT_VIDEO_DOWNLOAD_PROGRESS			= 0x49,
	ICATCH_EVENT_CONNECTION_DISCONNECTED			= 0x4A,

	ICATCH_EVENT_CONNECTION_INITIALIZE_SUCCEED		= 0x4B,
	ICATCH_EVENT_CONNECTION_INITIALIZE_FAILED		= 0x4C,

	ICATCH_EVENT_H264_FRAME_RANGE_DROPPED			= 0x4E,

	/*-----------------------------------------------------
	* TimeLapse events
	*/
	ICATCH_EVENT_TIMELAPSE_START					= 0x50,//add by j.chen 2017/8/22
	ICATCH_EVENT_TIMELAPSE_STOP						= 0x51,
	ICATCH_EVENT_CAPTURE_START						= 0x52,

	/*-----------------------------------------------------
	* DeviceScan events
	*/
	ICATCH_EVENT_DEVICE_SCAN_ADD					= 0x55,

	/*-----------------------------------------------------
	* Tutk related events
	*/
	ICATCH_EVENT_TUTK_MODE_CHANGED					= 0x56,
	ICATCH_EVENT_TUTK_SETUP_PROGRESS				= 0x57,

	/*-----------------------------------------------------
	*  transport status
	*/
	ICATCH_EVENT_VIDEO_STREAM_STATUS				= 0x58,
	ICATCH_EVENT_AUDIO_STREAM_STATUS				= 0x59,

	/*-----------------------------------------------------
	*  fw update event
	*/
	ICATCH_EVENT_FW_UPDATE_CHECK					= 0x60,
	ICATCH_EVENT_FW_UPDATE_COMPLETED				= 0x61,
	ICATCH_EVENT_FW_UPDATE_POWEROFF					= 0x62,
	ICATCH_EVENT_FW_UPDATE_CHKSUMERR				= 0x63,
	ICATCH_EVENT_FW_UPDATE_NG						= 0x64,

	/*-----------------------------------------------------
	*  PIV file auto download
	*/
	ICATCH_EVENT_FILE_DOWNLOAD						= 0x67,

	/*-----------------------------------------------------
	*  Video thumbnail
	*/
	ICATCH_EVENT_VIDEO_THUMB_READY  				= 0x68,
	ICATCH_EVENT_VIDEO_THUMB_DONE   				= 0x69,
	ICATCH_EVENT_VIDEO_TRIM_DONE					= 0x6a,

	ICATCH_EVENT_UNDEFINED							= 0xFF,
} ICatchEventID;

#endif

