//
//  ComicFinder.swift
//  ComicReader
//
//  Created by Flavius Stan on 17/03/2020.
//  Copyright © 2020 flaviusstan. All rights reserved.
//

import Foundation
import Zip
import CoreData

class ComicFinder{
    
    var container: NSPersistentContainer!
    
    init(container: NSPersistentContainer!) {
        self.container = container
    }
    
    
    func updateStorageComics(){
        
        do {
            let fileManager = FileManager.default
            let documentsPath = ComicFinder.getDocumentsDirectory()
            let tempPath = ComicFinder.getTempDirectory()
            let savedComics = getNameofSavedComics()
            print(documentsPath.path)
            let fileURLs = try fileManager.contentsOfDirectory(atPath: documentsPath.path)
            for item in fileURLs {
                if(item.contains(".cbz")){
                    let fileName = item.split(separator: ".")[0]
                    
                    if !savedComics.contains(String(fileName)){
                        let cbzPath = documentsPath.path  + "/" + item
                        print(fileManager.fileExists(atPath: cbzPath))                                                                
                        try Zip.unzipFile(URL(fileURLWithPath: cbzPath), destination: tempPath, overwrite: true, password: nil) // Unzip
                        let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
                        
                        var comicPages = [Data]()
                        //This for it's just to avoid hidden files in the folder
                        for page in comicPagesPath {
                            if(page.contains(".jpg") || page.contains(".png")){ //Find the first image and break.
                                comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                                break
                            }
                        }
                        
                        let newComic = Comic(name: String(fileName),path: cbzPath,cover: comicPages)
                        
                                               
                        saveNewComic(comicToSave: newComic)
                        
                        //Remove the comic from the temp directory
                        do{
                            try fileManager.removeItem(at: URL(fileURLWithPath: tempPath.path + "/" + fileName))
                        } catch {
                            print("Unable to delete the temp folder")
                        }
                        
                    }
                    
                }
            }
        } catch {
            print("Error while enumerating files: \(error.localizedDescription)")
        }
        
    }
    
    
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    } 
    
    
    
    private static func getTempDirectory() -> URL{
        return FileManager.default.temporaryDirectory
    }
    
    public func getSavedComics() -> [Comic]{
        var savedComics = [Comic]()
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
            request.returnsObjectsAsFaults = false
            let result = try container.viewContext.fetch(request)
            if result.isEmpty{
                print("Empty comic collection")
            }
            else{
                for item in result{
                    guard let comicEntity = item as? NSManagedObject else{
                        fatalError("Unable to cast comicEntity")
                    }
                    savedComics.append(Comic(name: comicEntity.value(forKey: "name") as! String, path: comicEntity.value(forKey: "path") as! String, cover: comicEntity.value(forKey: "cover") as! Data))
                }
            }
        }catch let error as NSError{
            print("FatalError \(error)")
        }
        
        return savedComics
    }
    
    static func removeTempComic(fileName: String){
        
        //Remove the comic from the temp directory
        do{
            
            try FileManager.default.removeItem(at: URL(fileURLWithPath: getTempDirectory().path + "/" + fileName))
            
        } catch {
            print("Unable to delete the temp folder")
        }
    }
    
    private func getNameofSavedComics() -> [String]{
        
        var savedComics = [String]()
        
        do{
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
            request.returnsObjectsAsFaults = false
            let result = try container.viewContext.fetch(request)
            if result.isEmpty{
                print("Empty comic collection")
            }
            else{
                for item in result{
                    guard let comicEntity = item as? NSManagedObject else{
                        fatalError("Unable to cast comicEntity")
                    }
                    savedComics.append(comicEntity.value(forKey: "name") as! String)
                }
            }
        }catch let error as NSError{
            print("FatalError \(error)")
        }
        
        return savedComics
    }
    
    static func getComicPages(fileName: String)-> [Data]{
        
        var comicPages = [Data]()
        let fileManager = FileManager.default
        let tempPath = getTempDirectory()
        let docPath = getDocumentsDirectory()
        let completePath = docPath.path + "/" + fileName + ".cbz"
        
        do {
            try Zip.unzipFile(URL(fileURLWithPath: completePath), destination: tempPath, overwrite: true, password: nil) // Unzip
            let comicPagesPath = try fileManager.contentsOfDirectory(atPath: tempPath.path + "/" + fileName + "/").sorted()
            
            for page in comicPagesPath {
                if(page.contains(".jpg") || page.contains(".png")){
                    comicPages.append(try Data(contentsOf: URL(fileURLWithPath: tempPath.path + "/" + fileName + "/" + page)))
                }
            }
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
        }
        
        return comicPages
    }
    
    func removeComic(comicToRemove: Comic) -> Bool{
        let docPath = ComicFinder.getDocumentsDirectory()
        let comicFile = comicToRemove.name + ".cbz"
        do {
            removeComicFromDataBase(comicToRemove: comicToRemove)
            try FileManager.default.removeItem(atPath: docPath.path + "/" + comicFile)
            return true
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
            return false
        }
    }
    
    func removeComic(comicToRemoveName: String) -> Bool{
        let docPath = ComicFinder.getDocumentsDirectory()
        let comicFile = comicToRemoveName + ".cbz"
        do {
            removeComicFromDataBase(comicToRemoveName: comicToRemoveName)
            try FileManager.default.removeItem(atPath: docPath.path + "/" + comicFile)
            return true
        } catch let error{
            print("Unable to get the comic pages" + error.localizedDescription)
            return false
        }
    }
    
    private func saveNewComic(comicToSave: Comic){
        
        let managedContext = container.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ComicEntity", in: managedContext)!
        let newComic = NSManagedObject(entity: entity, insertInto: managedContext)
        
        newComic.setValue(comicToSave.name, forKeyPath: "name")
        newComic.setValue(comicToSave.path, forKey: "path")
        newComic.setValue(comicToSave.comicsPages![0], forKey: "cover")
        
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    private func removeComicFromDataBase(comicToRemove: Comic){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicToRemove.name)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                managedContext.delete(entity)
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

    }
    
    private func removeComicFromDataBase(comicToRemoveName: String){
        let managedContext = container.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ComicEntity")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", comicToRemoveName)
        
        do {
            let result = try managedContext.fetch(request)
            if result.isEmpty{
                print("Empty Result")
            }
            else{
                guard let entity = result[0] as? NSManagedObject else{
                    fatalError("Unresolved error")
                }
                managedContext.delete(entity)
                try managedContext.save()
            }
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
    }
    
    
}
