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
        copyDemoComic()
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
            
            let demoComicRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DemoComic")
            demoComicRequest.returnsObjectsAsFaults = false
            let demoComicResult = try context.fetch(demoComicRequest)
            if demoComicResult.isEmpty{
                let entity = NSEntityDescription.entity(forEntityName: "DemoComic", in: context)!
                let newSetting = NSManagedObject(entity: entity, insertInto: context)
                
                newSetting.setValue(false, forKeyPath: "copied")
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
    
    public func copyDemoComic(){
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DemoComic")
            request.returnsObjectsAsFaults = false
            let result = try context.fetch(request)
            if !result.isEmpty{
                guard let comicEntity = result[0] as? NSManagedObject else{
                    fatalError("Unable to cast DemoComic")
                }
                let value = comicEntity.value(forKey: "copied") as! Bool
                if  value == false {
                    if let stringPath = Bundle.main.url(forResource: "#1 Pepper & Carrot The Potion of Flight", withExtension: "cbz"){
                        let fileManager = FileManager.default
                        let targetPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(stringPath.lastPathComponent, isDirectory: false)
                        try fileManager.copyItem(at: stringPath, to: targetPath)
                        comicEntity.setValue(true, forKeyPath: "copied")
                        do{
                            try context.save()
                        } catch let error as NSError{
                            print(error)
                        }
                    }
                }
            }
        }catch let error as NSError{
            print(error)
        }
    }
    
}
