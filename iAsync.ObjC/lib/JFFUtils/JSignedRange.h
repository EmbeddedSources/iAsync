#ifndef JFFUTILS_JSIGNED_RANGE_H_INCLUDED
#define JFFUTILS_JSIGNED_RANGE_H_INCLUDED

#include <Foundation/NSObjCRuntime.h>

typedef struct {
    NSInteger location;
    NSInteger length;
} JSignedRange;

#ifdef __cplusplus
extern "C"
{
#endif
    
#ifndef __cplusplus
extern
#endif
JSignedRange JSignedRangeMake(NSInteger location, NSInteger length);
 
#ifdef __cplusplus
}
#endif

#endif //JFFUTILS_JSIGNED_RANGE_H_INCLUDED
