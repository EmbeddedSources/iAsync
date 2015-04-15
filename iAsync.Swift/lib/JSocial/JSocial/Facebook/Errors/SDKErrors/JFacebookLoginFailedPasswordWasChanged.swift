import Foundation

import Accounts

public class JFacebookLoginFailedPasswordWasChanged : JFacebookSDKErrors {
    
    override public var localizedDescription: String {
        return NSLocalizedString(
            "J_FACEBOOK_LOGIN_ERROR_USER_DENIED_PERMISSION",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }
    
    public override func writeErrorWithJLogger() {
        
        writeErrorToNSLog()
    }
    
    internal override class func isMineFacebookNativeError(nativeError: NSError) -> Bool
    {
//        let userInfo = nativeError.userInfo
//    
//        let error   = userInfo?[FBErrorInnerErrorKey] as? NSError
//        let reason  = userInfo?[FBErrorLoginFailedReason] as? String
//        let session = userInfo?[FBErrorSessionKey] as? FBSession
//        
//        if error != nil
//            && reason == "com.facebook.sdk:SystemLoginCancelled"
//            && error != nil
//        {
//            let subError = userInfo?[FBErrorInnerErrorKey] as? NSError
//            
//            let code: Int = nativeError.code
//            
//            return code == FBErrorCode.LoginFailedOrCancelled.rawValue
//                && (subError?.code == Int(ACErrorPermissionDenied.value))
//                && (subError?.domain ?? "") == ACErrorDomain
//        }
    
        return false
    }
}