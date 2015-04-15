import Foundation

public extension UITableView {

    func withinUpdates(@autoclosure block: () -> ()) {
        
        beginUpdates()
        
        block()
        
        endUpdates()
    }
}
