
#ifdef NS_BLOCK_ASSERTIONS

#undef NSAssert
#undef NSAssert1
#undef NSAssert2
#undef NSAssert3
#undef NSAssert4
#undef NSAssert5

#define NSAssert(condition, desc ) \
    if ( !(condition) )            \
    {                              \
       NSLog( @"%@", desc );       \
    }                                  


#define NSAssert1(condition, desc, x1) \
    if ( !(condition) )               \
    {                                 \
       NSLog( desc, x1 );             \
    }                                  

#define NSAssert2(condition, desc, x1, x2) \
    if ( !(condition) )                   \
    {                                     \
       NSLog( desc, x1, x2 );             \
    }                                  

#define NSAssert3(condition, desc, x1, x2, x3) \
    if ( !(condition) )                       \
    {                                         \
       NSLog( desc, x1, x2, x3 );             \
    }                                  

#define NSAssert4(condition, desc, x1, x2, x3, x4) \
    if ( !(condition) )                           \
    {                                             \
       NSLog( desc, x1, x2, x3, x4 );             \
    }                                  

#define NSAssert5(condition, desc, x1, x2, x3, x4, x5) \
    if ( !(condition) )                               \
    {                                                 \
       NSLog( desc, x1, x2, x3, x4, x5 );             \
    }                                  


#endif

