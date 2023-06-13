#ifndef __ICATCH_WIFICAM_API_H__
#define __ICATCH_WIFICAM_API_H__

#if defined(WIN32) && !defined(MINGW)
	#if defined(WIFICAM_SDK_CLASS_EXPORT)
		#define ICATCH_API _declspec(dllexport)
	#else
		#define ICATCH_API _declspec(dllimport)
	#endif
#else
	#define ICATCH_API 
#endif

/*#if defined(__MINGW__) || defined(CYGWIN) || defined(ANDROID) || defined(LINUX) || defined(IOS)
#define ICATCH_API 
#endif
*/

#endif

