#ifndef __JDEBUG_LOG_H__
#define __JDEBUG_LOG_H__

#ifdef SHOW_DEBUG_LOGS
   #define NSDebugLog( ... ) NSLog( __VA_ARGS__ )
#else
   #define NSDebugLog( ... )
#endif

#endif //__JDEBUG_LOG_H__

