#ifndef JFFUTILS_JSIGNED_RANGE_H_INCLUDED
#define JFFUTILS_JSIGNED_RANGE_H_INCLUDED

#include <Foundation/NSObjCRuntime.h>

typedef struct
{
   NSInteger location;
   NSInteger length;
} JSignedRange;

JSignedRange JSignedRangeMake( NSInteger location_, NSInteger length_ );

#endif //JFFUTILS_JSIGNED_RANGE_H_INCLUDED
