#import "JFFSocialFacebookUser.h"

//Image urls docs
// http://developers.facebook.com/docs/reference/api/using-pictures/

@implementation JFFSocialFacebookUser
{
    NSURL *_largeImageURL;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    JFFSocialFacebookUser *copy = [[[self class] allocWithZone:zone] init];
    
    if (copy) {
        copy->_facebookID = [_facebookID copyWithZone:zone];
        copy->_email      = [_email      copyWithZone:zone];
        copy->_name       = [_name       copyWithZone:zone];
        copy->_gender     = [_gender     copyWithZone:zone];
        copy->_birthday   = [_birthday   copyWithZone:zone];
        copy->_biography  = [_biography  copyWithZone:zone];
    }
    
    return copy;
}

- (BOOL)isEqual:(JFFSocialFacebookUser *)object
{
    if (self == object)
        return YES;
    
    if (![object isKindOfClass:[self class]])
        return NO;
    
    return
       [NSObject object:_facebookID isEqualTo:object->_facebookID]
    && [NSObject object:_email      isEqualTo:object->_email     ]
    && [NSObject object:_name       isEqualTo:object->_name      ]
    && [NSObject object:_gender     isEqualTo:object->_gender    ]
    && [NSObject object:_birthday   isEqualTo:object->_birthday  ]
    && [NSObject object:_biography  isEqualTo:object->_biography ]
    ;
}

- (NSUInteger)hash
{
    return
      [_facebookID hash]
    + [_email      hash]
    + [_name       hash]
    + [_gender     hash]
    + [_birthday   hash]
    + [_biography  hash]
    ;
}

//http://graph.facebook.com/shaverm/picture?type=large
- (NSURL *)largeImageURL
{
    if (!_largeImageURL) {
        
        NSString *strURL = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?type=large", _facebookID];
        _largeImageURL = [strURL toURL];
    }
    
    return _largeImageURL;
}

// http://graph.facebook.com/shaverm/picture?width=40&height=60
- (NSURL *)imageURLForSize:(CGSize)size
{
    NSString *strURL = [[NSString alloc] initWithFormat:@"http://graph.facebook.com/%@/picture?width=%lu&height=%lu",
                        _facebookID,
                        (unsigned long)roundf(size.width ),
                        (unsigned long)roundf(size.height)
                        ];
    NSURL *result = [strURL toURL];
    
    return result;
}

@end
