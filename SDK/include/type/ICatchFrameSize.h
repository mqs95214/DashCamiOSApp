//
//  FrameSize.h
//  iCatchWifcamMobileSDK
//
//  Created by SA2 on 11/13/13.
//  Copyright (c) 2013 SA2. All rights reserved.
//

#ifndef __ICATCH_FRAME_SIZE_H__
#define __ICATCH_FRAME_SIZE_H__

#include "ICatchWificamAPI.h"

class ICATCH_API FrameSize {
public:
	FrameSize( int width, int height );
	int getFrameWidth();
	int getFrameHeight();
	void setFrameWidth( int width );
	void setFrameHeight( int height );

private:
	int width;
	int height;
};

enum StreamSource {
	/* stream comes from sensor */
	STREAM_TYEP_REAL_TIME,

	/* stream comes from file */
	STREAM_TYPE_FROM_FILE
};

#endif
