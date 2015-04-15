//
//  JCoreData.h
//  JCoreData
//
//  Created by Vladimir Gorbenko on 21.12.14.
//  Copyright (c) 2014 EmbeddedSources. All rights reserved.
//

import Foundation
import CoreData

public struct DefaultCoreDataStruct {

    public let managedObjectContext: NSManagedObjectContext

    public init(modelName: String, bundle: NSBundle, sqliteFileName: String) {
    
        let applicationDocumentsDirectory: NSURL = {
            // The directory the application uses to store the Core Data store file. This code uses a directory named "your apple id here" in the application's documents Application Support directory.
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            return urls.last as NSURL
        }()
        
        let managedObjectModel = { () -> NSManagedObjectModel in
            
            // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
            let modelURL = bundle.URLForResource(modelName, withExtension: "momd")
            return NSManagedObjectModel(contentsOfURL: modelURL!)!
        }()
        
        let coordinator = { () -> NSPersistentStoreCoordinator in
            
            // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
            // Create the coordinator and store
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            let url = applicationDocumentsDirectory.URLByAppendingPathComponent(sqliteFileName)
            var error: NSError? = nil
            var failureReason = "There was an error creating or loading the application's saved data."
            if coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
                // Report any error we got.
                let dict = NSMutableDictionary()
                dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
                dict[NSLocalizedFailureReasonErrorKey] = failureReason
                dict[NSUnderlyingErrorKey] = error
                error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
                // Replace this with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
            
            return coordinator
        }()
        
        self.managedObjectContext = {
            // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
            var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext
        }()
    }
}
