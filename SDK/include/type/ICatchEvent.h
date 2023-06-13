#ifndef __ICATCH_EVENT_H__
#define __ICATCH_EVENT_H__

#include "ICatchFile.h"
#include "ICatchWificamAPI.h"

class ICATCH_API ICatchEvent {
public:
	ICatchEvent(int eventID, int sessionID);

	virtual ~ICatchEvent();

public:
	int getEventID();
	int getSessionID();

	int getIntValue1();
	int getIntValue2();
	int getIntValue3();

	double getDoubleValue1();
	double getDoubleValue2();
	double getDoubleValue3();

	string getStringValue1();
	string getStringValue2();
	string getStringValue3();

	ICatchFile* const getFileValue();

	void setSessionID(int sessionID);

	void setIntValue1(int intValue1);
	void setIntValue2(int intValue2);
	void setIntValue3(int intValue3);
	void setDoubleValue1(double doubleValue1);
	void setDoubleValue2(double doubleValue2);
	void setDoubleValue3(double doubleValue3);

	void setStringValue1(string stringValue1);
	void setStringValue2(string stringValue2);
	void setStringValue3(string stringValue3);

	void setFileValue(ICatchFile& fileValue);

private:
	int			eventID;
	int			sessionID;

	int			intValue1;
	int			intValue2;
	int			intValue3;

	double		doubleValue1;
	double		doubleValue2;
	double		doubleValue3;

	string		stringValue1;
	string		stringValue2;
	string		stringValue3;

	ICatchFile*	fileValue;
};

#endif

