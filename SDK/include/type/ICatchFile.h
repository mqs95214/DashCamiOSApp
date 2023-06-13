#ifndef __ICATCH_FILE_H__
#define __ICATCH_FILE_H__

#include <string>
#include "ICatchFileType.h"
#include "ICatchWificamAPI.h"

using namespace std;

class ICatchWificamPlayback;

class ICATCH_API ICatchFile {
public:
	ICatchFile(int fileHandle);
	ICatchFile(int fileHandle, ICatchFileType type, string filePath, unsigned long long fileSize);
	ICatchFile(int fileHandle, ICatchFileType type, string filePath, string fileName, unsigned long long fileSize);
	ICatchFile(int fileHandle, ICatchFileType type, string filePath, unsigned long long fileSize, string date);
	ICatchFile(int fileHandle, ICatchFileType type, string filePath, unsigned long long fileSize, string date, double frameRate, unsigned int fileWidth, unsigned int fileHeight, unsigned int fileDuration);

	int getFileHandle();
	string getFilePath();
	string getFileName();
	string getFileDate();
	ICatchFileType getFileType();
	unsigned long long getFileSize();
	double getFileFrameRate();
	unsigned int getFileWidth();
	unsigned int getFileHeight();
	unsigned int getFileProtection();
	unsigned int getFileDuration();

	void setFileSize(unsigned long long fileSize);
	void setFileProtection( unsigned int protection );

private:
	void resetAttribute();

private:
	int					fileHandle;

	string				fileName;
	string				filePath;
	string				fileDate;
	ICatchFileType		fileType;
	unsigned int 		fileDuration;
	unsigned long long	fileSize;
	double				frameRate;
	unsigned int		fileWidth;
	unsigned int		fileHeight;
	unsigned int 		fileProtection;
};

#endif
