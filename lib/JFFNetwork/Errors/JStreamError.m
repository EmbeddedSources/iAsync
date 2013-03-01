#import "JStreamError.h"

@implementation JStreamError
{
@private
    CFStreamError _rawError;
}


-(id)init
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(id)initWithDescription:( NSString* )description_
                  domain:( NSString* )domain_
                    code:( NSInteger )code_
{
    [ self doesNotRecognizeSelector: _cmd ];
    return nil;
}

-(id)initWithStreamError:( CFStreamError )rawError_
{
    NSString* domain_ = [ NSString stringWithFormat: @"com.just_for_fun.library.network.CFError(%ld)", rawError_.domain ];
    
    self = [ super initWithDescription: NSLocalizedString( @"JNETWORK_CF_STREAM_ERROR", nil )
                                domain: domain_
                                  code: rawError_.error ];
    
    if ( nil == self )
    {
        return nil;
    }
    
    
    self->_rawError = rawError_;
    
    return self;
}

@end
