#import "JFFSharedDispatchersStorage.h"

#include <map>
#include <string>

@implementation JFFSharedDispatchersStorage
{
@public
    std::map< std::string, dispatch_queue_t > _dispatchByLabel;
}

+(dispatch_queue_t)dispatchQueueGetOrCreate:( const char *)label_
                                  attribute:( dispatch_queue_attr_t )attr_
{
    static dispatch_once_t once_;
    static JFFSharedDispatchersStorage* instance_;

    dispatch_once( &once_, ^
    {
        instance_ = [ JFFSharedDispatchersStorage new ];
    } );

    @synchronized( instance_ )
    {
        //const std::string& labelStr_( label_ );
        std::string labelStr_( label_ );

        std::map< std::string, dispatch_queue_t >& dispatchByLabel_ = instance_->_dispatchByLabel;

        dispatch_queue_t result_ = dispatchByLabel_[ labelStr_ ];
        if ( result_ == NULL )
        {
            result_ = dispatch_queue_create( label_, attr_ );
            dispatchByLabel_[ labelStr_ ] = result_;
        }

        return result_;
    }
}

@end
