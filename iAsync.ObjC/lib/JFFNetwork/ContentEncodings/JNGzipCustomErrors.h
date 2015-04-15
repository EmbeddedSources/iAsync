#ifndef JFFNetwork_JNGzipCustomErrors_h
#define JFFNetwork_JNGzipCustomErrors_h

@class NSString;

extern NSString *kGzipErrorDomain;

typedef NS_ENUM(NSInteger, JNCustomGzipErrorsEnum)
{
    kJNGzipInitFailed    = -100,
    kJNGzipUnexpectedEOF = -101
};

#endif
