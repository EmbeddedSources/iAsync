import Foundation

import UIKit

public extension UITableView {
    
    func enumerateAllIndexPaths(@noescape block: (NSIndexPath) -> ())
    {
        let numberOfSections = self.numberOfSections()
        
        for section in 0..<numberOfSections {
            
            autoreleasepool {
                
                let numberOfRows = self.numberOfRowsInSection(section)
                
                for row in 0..<numberOfRows {
                    
                    autoreleasepool {
                        
                        let indexPath = NSIndexPath(forRow:row, inSection:section)
                        block(indexPath)
                    }
                }
            }
        }
    }
}
