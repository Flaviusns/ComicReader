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
    var context: NSManagedObjectContext!
    
    init(container: NSPersistentContainer!){
        guard container != nil else{
            fatalError("This class needs a persisten container")
        }
        
        self.container = container
        self.context = container.viewContext
        
        initializeSettings()

    }
    
    public func initializeSettings(){
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
                    newSetting.setValue(0, forKey: "cameramode")
                }else{
                    newSetting.setValue(1, forKey: "cameramode")
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
    
    public func getValueFromKey(key: String) -> Int{
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicAppSettings")
            request.returnsObjectsAsFaults = false
            let result = try context.fetch(request)
            if !result.isEmpty{
                guard let settingsEntity = result[0] as? NSManagedObject else{
                    fatalError("Unable to cast ComicAppSettings")
                }
                return settingsEntity.value(forKey: key) as! Int
            }
            return -1
        }
        catch let error as NSError{
            print(error)
            return -1
        }
    }
    
    public func setValueForKey(key: String, value: Int) ->Bool {
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicAppSettings")
            request.returnsObjectsAsFaults = false
            let result = try context.fetch(request)
            if !result.isEmpty{
                guard let settingsEntity = result[0] as? NSManagedObject else{
                    fatalError("Unable to cast ComicAppSettings")
                }
                settingsEntity.setValue(value, forKey: key)
                
                try context.save()
                return true
            }
            return false
        }
        catch let error as NSError{
            print(error)
            return false
        }
    }
    
}
