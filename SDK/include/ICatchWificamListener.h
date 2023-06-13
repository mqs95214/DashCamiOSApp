#ifndef __ICATCH_WIFICAM_EVENT_LISTENER__
#define __ICATCH_WIFICAM_EVENT_LISTENER__

#include "type/ICatchEvent.h"
#include "ICatchWificamAPI.h"

class ICATCH_API ICatchWificamListener {
public:
	virtual void eventNotify(ICatchEvent* icatchEvt) = 0;
public:
	virtual ~ICatchWificamListener(){ }
};

#endif

