#include "JSignedRange.h"

//TODO remove JSignedRangeMake
JSignedRange JSignedRangeMake(NSInteger location, NSInteger length)
{
   JSignedRange range;
   range.location = location;
   range.length   = length;
   return range;
}
