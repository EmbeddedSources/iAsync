import Foundation

public class JFacebookAuthorizeError : JFacebookError {
    
    public override var localizedDescription: String {
        
        return NSLocalizedString(
            "J_FACEBOOK_AUTHORIZATION_FAILED",
            bundle: NSBundle(forClass: self.dynamicType),
            comment:"")
    }
    
    init() {
        super.init(description: "")
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func writeErrorWithJLogger() {}
}
