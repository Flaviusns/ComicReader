//
//  AppSettings.swift
//  ComicReader
//
//  Created by Flavius Stan on 10/05/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import Foundation
import CoreData

class ComicReaderAppSettings{
    
    var container: NSPersistentContainer!
    
    init(container: NSPersistentContainer!){
        guard container != nil else{
            fatalError("This class needs a persisten container")
        }
        
        self.container = container
        let context = container.viewContext
        
        initializeSettings(context: context)

    }
    
    public func initializeSettings(context: NSManagedObjectContext){
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicAppSettings")
            request.returnsObjectsAsFaults = false
            let result = try context.fetch(request)
            if result.isEmpty{
                print("Empty")
                
                let entity = NSEntityDescription.entity(forEntityName: "ComicAppSettings", in: context)!
                let newSetting = NSManagedObject(entity: entity, insertInto: context)
                
                newSetting.setValue(1, forKeyPath: "orderby")
                newSetting.setValue(2, forKey: "exportquality")
                if #available(iOS 13, *){
                    newSetting.setValue(1, forKey: "cameramode")
                }else{
                    newSetting.setValue(0, forKey: "cameramode")
                }
                do{
                    try context.save()
                } catch let error as NSError{
                    print(error)
                }
            }
        }catch let error as NSError{
            print(error)
        }
    }
    
}
