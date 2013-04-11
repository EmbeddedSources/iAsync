#import "UIDevice+PlatformName.h"

#include <sys/types.h>
#include <sys/sysctl.h>

static NSString *__platformName;

@implementation UIDevice (PlatformName)

// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
+ (NSString *)platformName
{
    if (!__platformName) {
        
        int mib[2];
        size_t len;
        char *machine;
        
        mib[0] = CTL_HW;
        mib[1] = HW_MACHINE;
        sysctl(mib, 2, NULL, &len, NULL, 0);
        machine = malloc(len);
        sysctl(mib, 2, machine, &len, NULL, 0);
        
        NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
        free(machine);
        __platformName = platform;
    }
    return __platformName;
}

@end
