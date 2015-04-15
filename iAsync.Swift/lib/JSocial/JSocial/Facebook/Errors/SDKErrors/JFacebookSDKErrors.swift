import Foundation

import JUtils
//import FacebookSDK

public class JFacebookSDKErrors : JError {
    
    func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.facebook.sdk.errors.library"
    }
    
    let nativeError: NSError
    
    override public var localizedDescription: String {
        return NSLocalizedString(
            "J_FACEBOOK_GENERAL_ERROR",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }
    
    required public init(nativeError: NSError) {
        
        self.nativeError = nativeError
        super.init(description: "")
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal class func isMineFacebookNativeError(error: NSError) -> Bool {
        
        return false
    }
    
//    public class func createFacebookSDKErrorsWithNativeError(nativeError: NSError) -> JFacebookSDKErrors {
//        
//        var errorClass: JFacebookSDKErrors.Type!
//        
//        let domain = nativeError.domain
//        
//        if domain == FacebookSDKDomain {
//            
//            let errorClasses: [JFacebookSDKErrors.Type] =
//            [
//            JFacebookLoginFailedCanceledError.self,
//            JFacebookLoginFailedAccessForbidden.self,
//            JFacebookLoginFailedPasswordWasChanged.self,
//            ]
//            
//            errorClass = firstMatch(errorClasses) { (someClass: JFacebookSDKErrors.Type) -> Bool in
//            
//                return someClass.isMineFacebookNativeError(nativeError)
//            }
//        }
//        
//        errorClass = errorClass ?? JFacebookSDKErrors.self
//        
//        return errorClass(nativeError: nativeError)
//    }

    public override func copyWithZone(zone: NSZone) -> AnyObject {
        
        return self.dynamicType(nativeError: nativeError)
    }
    
    override public var errorLogDescription: String {
        let result = "\(self.dynamicType) : \(localizedDescription) nativeError:\(nativeError.errorLogDescription)"
        return result
    }
}
