#import "NSString+FileAttributes.h"

#import "JFFLogger.h"

#include <sys/xattr.h>

//doc: https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man2/setxattr.2.html

static void logErrnoGlobalVariable(const char *attributeName)
{
    switch (errno)
    {
        case ENOENT:
        {
            //options is set to XATTR_REPLACE and the named attribute does not exist.
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: No such file or directory"];
            break;
        }
        case EEXIST:
        {
            //options contains XATTR_CREATE and the named attribute already exists.
            //just ignore it
            break;
        }
        case ENOATTR:
        {
            //options is set to XATTR_REPLACE and the named attribute does not exist.
            NSString *str = [[NSString alloc] initWithFormat:@"addSkipBackupAttribute: %s attribute does not exist", attributeName];
            [[JLogger sharedJLogger] logError:str];
            break;
        }
        case ENOTSUP:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: The file system does not support extended attributes or has them disabled."];
            break;
        }
        case EROFS:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: The file system is mounted read-only."];
            break;
        }
        case ERANGE:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: The data size of the attribute is out of range (some attributes have size restric-tions)."];
            break;
        }
        case EPERM:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: Attributes cannot be associated with this type of object. For example, attributes are not allowed for resource forks."];
            break;
        }
        case EINVAL:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: name or options is invalid. name must be valid UTF-8 and options must make sense."];
            break;
        }
        case ENOTDIR:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: A component of path is not a directory."];
            break;
        }
        case ENAMETOOLONG:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: name exceeded XATTR_MAXNAMELEN UTF-8 bytes, or a component of path exceeded NAME_MAX characters, or the entire path exceeded PATH_MAX characters."];
            break;
        }
        case EACCES:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: Search permission is denied for a component of path or permission to set the attribute is denied."];
            break;
        }
        case ELOOP:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: Too many symbolic links were encountered resolving path."];
            break;
        }
        case EIO:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: An I/O error occurred while reading from or writing to the file system."];
            break;
        }
        case E2BIG:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: The data size of the extended attribute is too large."];
            break;
        }
        case ENOSPC:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: Not enough space left on the file system."];
            break;
        }
        default:
        {
            [[JLogger sharedJLogger] logError:@"addSkipBackupAttribute: unknown error type"];
            break;
        }
    }
}

@implementation NSString (FileAttributes)

- (void)addSkipBackupAttribute
{
    u_int8_t b = 1;
    
    const char *attributeName = "com.apple.MobileBackup";
    int result = setxattr([self fileSystemRepresentation], attributeName, &b, 1, 0, 0);
    
    if (result == -1) {
        logErrnoGlobalVariable(attributeName);
    }
}

@end
