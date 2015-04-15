import Foundation

public extension UITableView {
    
    func selectAllRowsAnimated(animated: Bool) {

        enumerateAllIndexPaths( { (indexPath: NSIndexPath) -> () in
            
            self.selectRowAtIndexPath(indexPath, animated:animated, scrollPosition:.None)
        })
    }
    
    func deselectAllRowsAnimated(animated: Bool) {
    
        enumerateAllIndexPaths( { (indexPath: NSIndexPath) -> () in
            
            self.deselectRowAtIndexPath(indexPath, animated:animated)
        })
    }
}
