import Foundation

public extension NSDate {
    
    var beginningOfDay: NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        
        let units: NSCalendarUnit = .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay
        
        let components = calendar.components(units, fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    var endOfDay: NSDate {
        
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: beginningOfDay, options: .allZeros)!
        
        return date.dateByAddingTimeInterval(-1.0)
    }
}