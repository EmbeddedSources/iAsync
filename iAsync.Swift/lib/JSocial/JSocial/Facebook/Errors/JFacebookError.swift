import Foundation

public class JFacebookError : JSocialError {
    
    override func jffErrorsDomain() -> String {
        
        return "com.just_for_fun.facebook.library"
    }
}