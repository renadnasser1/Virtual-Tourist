//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Renad nasser on 13/08/2020.
//  Copyright © 2020 Renad nasser. All rights reserved.
//

import Foundation
import CoreData

class DataController{
    
    /// Proprities
    let persistentContainar:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainar.viewContext
    }
    
    /// Intilaizer
    init(modelName:String) {
        persistentContainar = NSPersistentContainer(name: modelName)
    }
    
    /// Functions
    func load(complation: (() -> Void)? = nil) {
        persistentContainar.loadPersistentStores { (storeDescription, error) in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext(interval: 3)
            complation?()
        }
    }
    
}

extension DataController{
    
    func autoSaveViewContext(interval:TimeInterval = 30) {
        guard interval  > 0 else {
            print("cannot set negative autosave")
            return
        }
        
        if viewContext.hasChanges{
            try? viewContext.save()}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    
}
