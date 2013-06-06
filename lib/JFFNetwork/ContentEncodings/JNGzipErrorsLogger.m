#import "JNGzipErrorsLogger.h"

@implementation JNGzipErrorsLogger

+(NSString*)zipErrorMessageFromCode:(int)errorCode
{
   static NSString* zip_errors_[] = 
   {
        @"Z_VERSION_ERROR"
      , @"Z_BUF_ERROR"                              
      , @"Z_MEM_ERROR"                             
      , @"Z_DATA_ERROR"
      , @"Z_STREAM_ERROR"                           
      , @"Z_ERRNO"
   };

    
   int error_index_     = errorCode + abs( Z_VERSION_ERROR );
   int max_error_index_ = Z_ERRNO   + abs( Z_VERSION_ERROR );

   if ( error_index_ > max_error_index_ )
   {
      return @"Z_UnknownError";
   }

   return zip_errors_[ error_index_ ];
}

@end
