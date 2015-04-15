import Foundation

public class JFacebookLoginFailedCanceledError : JFacebookSDKErrors {
    
    override public var localizedDescription: String {
        return "FACEBOOK_LOGIN_ERROR_CANCELED"
    }
    
    override public func writeErrorWithJLogger() {}
    
    internal class override func isMineFacebookNativeError(nativeError: NSError) -> Bool {
        
//        let code = nativeError.code
//        let userInfo = nativeError.userInfo
//        
//        let reason = userInfo?[FBErrorLoginFailedReason] as? String
//        
//        if let reason = reason {
//            
//            return reason == FBErrorReauthorizeFailedReasonUserCancelled
//                && code == FBErrorCode.LoginFailedOrCancelled.rawValue
//        }
        
        return false
    }
}