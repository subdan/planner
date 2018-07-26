//
//  CoreDataStack.swift
//  planner
//
//  Created by Daniil Subbotin on 05/07/2018.
//  Copyright © 2018 Daniil Subbotin. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
    static let shared = CoreDataStack(modelName: "Model")
    
    lazy var viewContent: NSManagedObjectContext = {
        return persistanceContainer.viewContext
    }()
    
    private var modelName: String
    
    private lazy var persistanceContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores(completionHandler: { (description, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
            }
        })
        return container
    }()
    
    private init(modelName: String) {
        self.modelName = modelName
    }
    
    func saveContext() {
        guard viewContent.hasChanges else { return }
        
        do {
            try viewContent.save()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}
