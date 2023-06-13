#ifndef __ICATCH_ERROR_H__
#define __ICATCH_ERROR_H__

enum ICatchError
{
	ICH_SUCCEED							= 0,

	ICH_DEVICE_BUSY						= -1,
	ICH_DEVICE_ERROR					= -2,

	ICH_NOT_SUPPORTED					= -3,
	ICH_NOT_IMPLEMENTED					= -4,

	ICH_TRY_AGAIN						= -5,
	ICH_BUF_TOO_SMALL					= -6,

	ICH_OUT_OF_MEMORY					= -7,

	ICH_FILE_NOT_FOUND					= -8,
	ICH_PATH_NOT_FOUND					= -9,

	ICH_INVALID_SESSION					= -11,
	ICH_INVALID_ARGUMENT				= -12,

	ICH_TIME_OUT						= -14,
	ICH_SOCKET_ERROR					= -15,

	ICH_PERMISSION_DENIED				= -16,

	ICH_UNKNOWN_ERROR					= -17,
	ICH_STREAM_NOT_RUNNING				= -18,

	ICH_WIFI_DISCONNECTED				= -19,
	ICH_STREAM_NOT_SUPPORT				= -20,
	ICH_BATTERY_LEVEL_NOT_SUPPORTED		= -40,

	ICH_MODE_NOT_SUPPORT 				= -41,
	ICH_MODE_SET_ILLEGAL				= -42,
	ICH_MODE_CAMERA_BUSY				= -43,
	ICH_MODE_PTP_CLIENT_INVALID			= -44,
	ICH_MODE_CHANGE_FAILED				= -45,

	ICH_WB_NOT_SUPPORTED 				= -46,
	ICH_WB_GET_FAILED 					= -47,
	ICH_WB_SET_FAILED 					= -48,

	ICH_CAP_DELAY_NOT_SUPPORTED 		= -49,
	ICH_CAP_DELAY_GET_FAILED 			= -50,
	ICH_CAP_DELAY_SET_FAILED 			= -51,

	ICH_IMAGE_SIZE_NOT_SUPPORTED 		= -52,
	ICH_IMAGE_SIZE_GET_FAILED 			= -53,
	ICH_IMAGE_SIZE_SET_FAILED 			= -54,

	ICH_VIDEO_SIZE_NOT_SUPPORTED 		= -55,
	ICH_VIDEO_SIZE_GET_FAILED 			= -56,
	ICH_VIDEO_SIZE_SET_FAILED 			= -57,

	ICH_LIGHT_FREQ_NOT_SUPPORTED 		= -58,
	ICH_LIGHT_FREQ_GET_FAILED 			= -59,
	ICH_LIGHT_FREQ_SET_FAILED 			= -60,

	ICH_BURST_NUMBER_NOT_SUPPORTED 		= -61,
	ICH_BURST_NUMBER_GET_FAILED 		= -62,
	ICH_BURST_NUMBER_SET_FAILED 		= -63,

	ICH_CAPTURE_ERROR 					= -64,
	ICH_STORAGE_FORMAT_ERROR 			= -65,

	ICH_IMAGE_SIZE_FORMAT_ERROR 		= -66,
	ICH_VIDEO_SIZE_FORMAT_ERROR 		= -67,

	ICH_SD_CARD_NOT_EXIST 				= -68,

	/*-----------------------------------------------
	  * !!!Add new error code there.
	  * ----------------------------------------------*/
	ICH_FREE_SPACE_IN_IMAGE_NOT_SUPPORTED	= -69,
	ICH_REMAIN_RECORD_TIME_NOT_SUPPORTED	= -70,
	ICH_MTP_GET_OBJECTS_ERROR				= -71,

	ICH_LISTENER_EXISTS						= -72,
	ICH_LISTENER_NOT_EXISTS					= -73,

	ICH_PROP_NOT_EXIST						= -74,
	ICH_PROP_TYPE_ERROR						= -75,
	ICH_PROP_VALUE_ERROR					= -76,
	ICH_PROP_PARSE_ERROR					= -77,

	ICH_SEEK_FAILED							= -78,
	ICH_PAUSE_FAILED						= -79,
	ICH_RESUME_FAILED						= -80,

	ICH_PB_MEM_FULL							= -81,
	ICH_PB_CACHING							= -82,
	ICH_PB_PLAY_END							= -83,

	ICH_PB_STREAM_PAUSED					= -84,

	ICH_VIDEO_STREAM_CLOSED					= -85,
	ICH_AUDIO_STREAM_CLOSED					= -86,

	ICH_SESSION_PASSWORD_ERR				= -90,
	ICH_PTP_INIT_FAILED						= -91,
	ICH_TUTK_INIT_FAILED					= -92,
	ICH_WAIT_TIME_OUT						= -93,
	
	ICH_PUBLISH_ALREADY_START               = -94,
    ICH_PUBLISH_ALREADY_STOP                = -95,
	/*-----------------------------------------------
	* Generic error
	*----------------------------------------------*/
	ICH_OPEN_FAIL							= -100,
	ICH_NOT_FOUND							= -101,
	ICH_NULL								= -102,
};

/**--------------------------------------------------------------
 * check icatch value, return bool or icatch value
 */
#define CHECK_ICHE_RET_I( ret )		\
do {								\
	if( ret != ICH_SUCCEED ) {		\
		ICATCH_API_OUT();			\
		return ret;					\
	}								\
} while( 0 );

#define CHECK_ICHE_RET_B( ret )		\
do {								\
	if( ret != ICH_SUCCEED ) {		\
		ICATCH_API_OUT();			\
		return false;				\
	}								\
} while( 0 );

/**--------------------------------------------------------------
 * check bool value, return bool or icatch value(ICH_UNKNOWN_ERROR)
 */
#define CHECK_BOOL_RET_I( ret )		\
do {								\
	if( ret != true ) {				\
		ICATCH_API_OUT();			\
		return ICH_UNKNOWN_ERROR;	\
	}								\
} while( 0 );

#define CHECK_BOOL_RET_B( ret )		\
do {								\
	if( ret != true ) {				\
		ICATCH_API_OUT();			\
		return false;				\
	}								\
} while( 0 );

/**---------------------------------------------------
 * check icatch value, return bool or icatch value
 */
#define RTP_CHECK_RET_ICH( ret )	\
do {								\
	if( ret != ICH_SUCCEED ) {		\
		ICATCH_API_OUT();			\
		return ret;					\
	}								\
} while( 0 );

#define RTP_CHECK_RET_BOOL( ret )	\
do {								\
	if( ret != true ) {				\
		ICATCH_API_OUT();			\
		return false;				\
	}								\
} while( 0 );


#endif

