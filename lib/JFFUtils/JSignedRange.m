#include "JSignedRange.h"

JSignedRange JSignedRangeMake( NSInteger location_, NSInteger length_ )
{
    JSignedRange range_;
    range_.location = location_;
    range_.length   = length_;
    return range_;
}
