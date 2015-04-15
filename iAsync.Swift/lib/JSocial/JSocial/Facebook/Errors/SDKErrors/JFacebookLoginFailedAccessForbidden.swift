import Foundation

public class JFacebookLoginFailedAccessForbidden : JFacebookSDKErrors {
    
    override public var localizedDescription: String {
        return NSLocalizedString(
            "J_FACEBOOK_LOGIN_ERROR_ACCESS_FORBIDDEN",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }
    
    override public func writeErrorWithJLogger() {}
    
    //This error happens when user forbid access when it try access it or something ither very strange
    //TODO retest it
    private class func isMineFacebookNativeError_whenInvalidSettings(nativeError: NSError) -> Bool {

        let userInfo = nativeError.userInfo
        
        let jsonPattern =
        [
            FBErrorInnerErrorKey         : NSError.self,
            FBErrorParsedJSONResponseKey : ["body" : ["error" : ["code" : 190, "error_subcode" : 65001]]]
        ]
        
        let error     = userInfo?[FBErrorInnerErrorKey] as? NSError
        let bodyError = ((userInfo?[FBErrorParsedJSONResponseKey] as? NSDictionary)?["body"] as? NSDictionary)?["error"] as? NSDictionary
        let code      = bodyError?["code"] as? Int
        let subCode   = bodyError?["error_subcode"] as? Int
        
        if error != nil && code == 190 && subCode == 65001 {
        
            let subError = userInfo?[FBErrorInnerErrorKey] as? NSError
            let code = nativeError.code
            
            let subErrorCodeEquals = (subError?.code == Int(ACErrorUnknown.value))
            
            return (code == FBErrorCode.HTTPError.rawValue)
                && subErrorCodeEquals
                && (subError?.domain ?? "") == ACErrorDomain
        }
        
        return false
    }
    
    private class func isMineFacebookNativeError_whenForbidWebLogin(nativeError: NSError) -> Bool
    {
        let code = nativeError.code
        let userInfo = nativeError.userInfo
    
        let reasonEquals = (userInfo?[FBErrorLoginFailedReason] as? String ?? "") == FBErrorLoginFailedReasonUserCancelledValue
        
        return code == FBErrorCode.LoginFailedOrCancelled.rawValue
            && reasonEquals
            && nativeError.domain == FacebookSDKDomain
    }
    
    internal override class func isMineFacebookNativeError(nativeError: NSError) -> Bool
    {
        let result =
            isMineFacebookNativeError_whenInvalidSettings(nativeError)
            || isMineFacebookNativeError_whenForbidWebLogin(nativeError)
    
        if result {
            return true
        }
    
        let code = nativeError.code
        let userInfo = nativeError.userInfo
        
        let reasonEquals = (userInfo?[FBErrorLoginFailedReason] as? String ?? "") == FBErrorLoginFailedReasonSystemDisallowedWithoutErrorValue
    
        return code == FBErrorCode.LoginFailedOrCancelled.rawValue && reasonEquals
    }
}
